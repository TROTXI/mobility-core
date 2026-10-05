// The three kinds of driver command, each run inside DriverService.execute's
// transaction after it has locked the principals, the driver and the receipt.
// They change the driver row and decide the response; execute writes the
// command receipt and event.
import type { PoolClient } from 'pg';
import type { Body } from '../transport/service.js';
import { TransportError, fail } from '../transport/errors.js';
import {
  editToken,
  opsDriver,
  success,
  view,
  type DriverService,
  type Output,
  type Row,
} from './driver-service.js';
import { DriverLockedError } from './service.js';
import {
  generateDriverCode,
  generatePin,
  hashDriverPin,
  isTrivialPin,
  verifyDriverPin,
} from './driver-pin.js';
import { cancelCredentialMail } from '../notifications/email.js';
import { cancelCredentialSms } from '../notifications/driver-sms.js';
import { ghanaPhone } from '../notifications/mnotify.js';

export interface DriverCommandResult {
  driver: Row | undefined;
  response: Output;
  pinVersion: number | null;
}

/** createDriver: a new driver record, optionally linked to an existing account. */
export async function createDriverRecord(
  drivers: DriverService,
  { client, body }: { client: PoolClient; body: Body },
): Promise<DriverCommandResult> {
  let driver: Row | undefined;
  let response!: Output;
  const name = String(body.name).trim();
  if (!name) fail(400, 'invalid_request', 'Driver name is required.');
  if (typeof body.userId === 'string') await drivers.linkedUser(client, body.userId);
  driver = (
    await client.query<Row>(
      'INSERT INTO app.drivers(name,phone,email,license_number,user_id) VALUES ($1,$2,$3,$4,$5) RETURNING *',
      [
        name,
        body.phone ?? null,
        body.email ?? null,
        body.licenseNumber ?? null,
        body.userId ?? null,
      ],
    )
  ).rows[0]!;
  response = success(
    201,
    { data: view(await opsDriver(client, driver.id)) },
    { ETag: editToken(driver), Location: `/v1/ops/drivers/${driver.id}` },
  );
  return { driver, response, pinVersion: null };
}

/** updateDriver: contact details, linkage and archiving. */
export async function updateDriverRecord(
  drivers: DriverService,
  {
    client,
    body,
    now,
    ...state
  }: { client: PoolClient; body: Body; now: Date; driver: Row | undefined },
): Promise<DriverCommandResult> {
  let { driver } = state;
  let response!: Output;
  if (!Object.keys(body).length) fail(400, 'invalid_request', 'Supply at least one driver field.');
  if (typeof body.userId === 'string') await drivers.linkedUser(client, body.userId);
  if (body.archived === true && !driver!.archived_at) {
    // Hold driver exclusive; guard_trip takes SHARE before any new assignment.
    // Do not lock trips here (trip commands acquire those before the driver).
    if (
      (
        await client.query(
          "SELECT 1 FROM app.trips WHERE assigned_driver_id=$1 AND status IN ('scheduled','active') LIMIT 1",
          [driver!.id],
        )
      ).rowCount
    )
      fail(
        409,
        'driver_has_open_trips',
        'Reassign or cancel open trips before archiving this driver.',
      );
  }
  const values: unknown[] = [driver!.id],
    sets: string[] = [];
  for (const [field, column] of Object.entries({
    name: 'name',
    phone: 'phone',
    email: 'email',
    licenseNumber: 'license_number',
    userId: 'user_id',
    archived: 'archived_at',
  })) {
    if (body[field] === undefined) continue;
    let value: unknown = body[field];
    if (field === 'name') {
      value = String(value).trim();
      if (!value) fail(400, 'invalid_request', 'Driver name is required.');
    }
    if (field === 'archived') value = value ? (driver!.archived_at ?? now) : null;
    values.push(value);
    sets.push(`${column}=$${values.length}`);
  }
  const oldUser = driver!.user_id,
    oldEmail = driver!.email,
    oldPhone = driver!.phone;
  driver = (
    await client.query<Row>(
      `UPDATE app.drivers SET ${sets.join(',')},version=version+1,updated_at=clock_timestamp() WHERE id=$1 RETURNING *`,
      values,
    )
  ).rows[0]!;
  if (oldUser && (driver.archived_at || oldUser !== driver.user_id))
    await drivers.revoke(client, oldUser, now);
  // Waiting credential mail was written for this driver, account and
  // address. Any of those changing makes it the wrong message to send.
  if (oldUser && (driver.archived_at || oldUser !== driver.user_id || oldEmail !== driver.email))
    await cancelCredentialMail(client, oldUser);
  if (oldUser && (driver.archived_at || oldUser !== driver.user_id || oldPhone !== driver.phone))
    await cancelCredentialSms(client, oldUser);
  response = success(
    200,
    { data: view(await opsDriver(client, driver.id)) },
    { ETag: editToken(driver) },
  );
  return { driver, response, pinVersion: null };
}

/**
 * issueDriverCredential, resetDriverPin, changeCredentialState and
 * changeDriverPin. A refused PIN change returns its error instead of
 * throwing, so the failed-attempt counter it wrote still commits.
 */
export async function credentialCommand(
  drivers: DriverService,
  {
    client,
    op,
    body,
    now,
    commandId,
    wantsEmail,
    wantsSms,
    temporaryUntil,
    ...state
  }: {
    client: PoolClient;
    op: string;
    body: Body;
    now: Date;
    commandId: string;
    wantsEmail: boolean;
    wantsSms: boolean;
    temporaryUntil: Date;
    driver: Row | undefined;
  },
): Promise<DriverCommandResult | TransportError> {
  let { driver } = state;
  let response!: Output;
  let pinVersion: number | null = null;
  if (driver!.archived_at) fail(409, 'driver_archived', 'This driver is archived.');
  let credential = (
    await client.query('SELECT * FROM app.driver_credentials WHERE driver_id=$1 FOR UPDATE', [
      driver!.id,
    ])
  ).rows[0];
  if (wantsEmail) {
    if (!driver!.email)
      fail(
        409,
        'driver_email_missing',
        "Add the driver's email address before emailing sign-in details.",
      );
    if (!drivers.options.email)
      fail(
        503,
        'email_unavailable',
        'Email delivery is not configured here. Issue without email and give the driver the details another way.',
      );
  }
  if (wantsSms) {
    try {
      ghanaPhone(driver!.phone ?? '');
    } catch (_) {
      fail(
        409,
        'driver_phone_missing',
        'Add a valid Ghana mobile number before sending SMS instructions.',
      );
    }
    if (!drivers.options.sms)
      fail(
        503,
        'sms_unavailable',
        'SMS delivery is not configured here. Choose email or show the details once.',
      );
  }
  if (op === 'issueDriverCredential') {
    if (credential) fail(409, 'credential_exists', 'This driver already has a credential.');
    if (driver!.user_id) await drivers.linkedUser(client, driver!.user_id);
    else {
      const user = (
        await client.query(
          "INSERT INTO app.users(role,display_name,phone) VALUES ('driver',$1,$2) RETURNING id",
          [driver!.name, driver!.phone],
        )
      ).rows[0];
      driver = (
        await client.query<Row>(
          'UPDATE app.drivers SET user_id=$2,version=version+1,updated_at=clock_timestamp() WHERE id=$1 RETURNING *',
          [driver!.id, user.id],
        )
      ).rows[0]!;
    }
    const pin = generatePin(),
      provided = typeof body.code === 'string' ? body.code : undefined;
    if (provided && !/^DR-[23456789ABCDEFGHJKMNPQRSTVWXYZ]{4}$/.test(provided))
      fail(
        400,
        'invalid_driver_code',
        'Use a four-character driver code from the supported alphabet.',
      );
    for (let attempt = 0; attempt < 5; attempt++) {
      credential = (
        await client.query(
          `INSERT INTO app.driver_credentials(driver_id,driver_code,pin_hash,must_change_pin,temporary_pin_expires_at)
          VALUES ($1,$2,$3,true,$4)
        ON CONFLICT(driver_code) DO NOTHING RETURNING *`,
          [
            driver!.id,
            provided ?? generateDriverCode(),
            hashDriverPin(pin, drivers.options.pinSecret),
            temporaryUntil,
          ],
        )
      ).rows[0];
      if (credential) break;
      if (provided) fail(409, 'driver_code_taken', 'This driver code is already in use.');
    }
    if (!credential)
      fail(
        409,
        'driver_code_unavailable',
        'Could not allocate a driver code; retry with a new request.',
      );
    pinVersion = credential.pin_version;
    response = success(
      201,
      {
        data: {
          code: credential.driver_code,
          pin,
          temporaryPinExpiresAt: temporaryUntil.toISOString(),
          email: await drivers.mail(client, wantsEmail, 'driver_credentials_issued', {
            driver: driver!,
            commandId,
            code: credential.driver_code,
            pin,
            pinVersion: credential.pin_version,
            expiresAt: temporaryUntil,
          }),
          sms: await drivers.mail(
            client,
            wantsSms,
            'driver_credentials_issued',
            {
              driver: driver!,
              commandId,
              code: credential.driver_code,
              pin,
              pinVersion: credential.pin_version,
              expiresAt: temporaryUntil,
            },
            'sms',
          ),
        },
      },
      { Location: `/v1/ops/drivers/${driver!.id}/credentials` },
    );
  } else {
    if (!credential || !driver!.user_id) fail(404, 'not_found', 'Driver credential not found.');
    await drivers.linkedUser(client, driver!.user_id);
    if (op === 'changeCredentialState') {
      if (body.action === 'unlock')
        await client.query(
          'UPDATE app.driver_credentials SET failed_attempts=0,locked_until=NULL,updated_at=$2 WHERE driver_id=$1',
          [driver!.id, now],
        );
      else {
        await client.query(
          'UPDATE app.driver_credentials SET status=$2,updated_at=$3 WHERE driver_id=$1',
          [driver!.id, body.action === 'suspend' ? 'suspended' : 'active', now],
        );
        if (body.action === 'suspend') {
          await drivers.revoke(client, driver!.user_id, now);
          await cancelCredentialSms(client, driver!.user_id);
        }
      }
      response = success();
    } else {
      if (op === 'changeDriverPin') {
        // An expired temporary PIN is not a credential any more; only a
        // fresh one from operations gets the driver back in.
        if (
          credential.must_change_pin &&
          credential.temporary_pin_expires_at &&
          credential.temporary_pin_expires_at <= now
        )
          return new TransportError(
            403,
            'temporary_pin_expired',
            'Your temporary PIN has expired. Ask Trotxi operations for a new one.',
          );
        if (credential.locked_until && credential.locked_until > now)
          return new DriverLockedError(
            Math.max(1, Math.ceil((credential.locked_until.getTime() - now.getTime()) / 1000)),
          );
        if (
          !verifyDriverPin(String(body.currentPin), credential.pin_hash, drivers.options.pinSecret)
        ) {
          const attempts = credential.failed_attempts + 1;
          await client.query(
            "UPDATE app.driver_credentials SET failed_attempts=$2,locked_until=CASE WHEN $2>=5 THEN $3::timestamptz+interval '15 minutes' ELSE locked_until END,updated_at=$3 WHERE driver_id=$1",
            [driver!.id, attempts, now],
          );
          return attempts >= 5
            ? new DriverLockedError(900)
            : new TransportError(401, 'invalid_driver_credentials', 'Current PIN is incorrect.');
        }
        if (
          isTrivialPin(String(body.newPin)) ||
          verifyDriverPin(String(body.newPin), credential.pin_hash, drivers.options.pinSecret)
        )
          fail(
            400,
            'weak_pin',
            'Choose a different PIN that is not repeated or sequential digits.',
          );
      }
      let pin = op === 'changeDriverPin' ? String(body.newPin) : generatePin();
      while (
        op === 'resetDriverPin' &&
        verifyDriverPin(pin, credential.pin_hash, drivers.options.pinSecret)
      )
        pin = generatePin();
      credential = (
        await client.query(
          `UPDATE app.driver_credentials SET pin_hash=$2,must_change_pin=$3,temporary_pin_expires_at=$5,
        pin_version=pin_version+1,failed_attempts=0,locked_until=NULL,pin_set_at=$4,updated_at=$4
        WHERE driver_id=$1 RETURNING *`,
          [
            driver!.id,
            hashDriverPin(pin, drivers.options.pinSecret),
            op === 'resetDriverPin',
            now,
            op === 'resetDriverPin' ? temporaryUntil : null,
          ],
        )
      ).rows[0];
      // Baseline revokes ALL sessions, including the one changing its PIN.
      await drivers.revoke(client, driver!.user_id, now);
      // Whatever credential mail is still waiting now describes a PIN
      // that no longer works.
      await cancelCredentialMail(client, driver!.user_id);
      await cancelCredentialSms(client, driver!.user_id);
      if (op === 'resetDriverPin') {
        pinVersion = credential.pin_version;
        response = success(200, {
          data: {
            code: credential.driver_code,
            pin,
            temporaryPinExpiresAt: temporaryUntil.toISOString(),
            email: await drivers.mail(client, wantsEmail, 'driver_pin_reset', {
              driver: driver!,
              commandId,
              code: credential.driver_code,
              pin,
              pinVersion: credential.pin_version,
              expiresAt: temporaryUntil,
            }),
            sms: await drivers.mail(
              client,
              wantsSms,
              'driver_pin_reset',
              {
                driver: driver!,
                commandId,
                code: credential.driver_code,
                pin,
                pinVersion: credential.pin_version,
                expiresAt: temporaryUntil,
              },
              'sms',
            ),
          },
        });
      } else response = success();
    }
  }
  return { driver, response, pinVersion };
}
