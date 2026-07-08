#!/usr/bin/env bash
# e2e-demo.sh — drive the whole Trotxi hybrid-model loop against a running API,
# end to end:
#
#   admin bootstrap → create fleet (route/stop/vehicle/trip)
#   → promote a user to driver → assign driver to trip
#   → rider signs in → subscribes → (fake) webhook → 44 rides
#   → rider confirms tomorrow's trip → gets a daily PIN
#   → driver opens the trip manifest (photo pass)
#   → driver boards the rider by PIN → one ride is debited (44 → 43)
#
# It prints every token + id at the end so you can then poke individual
# endpoints in Swagger (http://localhost:3000/docs) as admin / driver / rider.
#
# Prereqs: the API running locally in DEV mode — JWT_SECRET unset (dev auth
# secret) and PAYSTACK_SECRET_KEY unset (fake Paystack client):
#
#   cd services/api
#   export PATH="$HOME/.nvm/versions/node/v24.17.0/bin:$PATH"   # Node 24
#   node node_modules/tsx/dist/cli.mjs src/server.ts &          # start the API
#   bash scripts/e2e-demo.sh                                     # run the loop
#
# Override the base URL:  BASE_URL=http://localhost:3000 bash scripts/e2e-demo.sh

set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:3000}"
# DEV_AUTH_CONFIG.secret (services/api/src/modules/auth/jwt.ts) — used only to
# mint the bootstrap admin token; there is no other way to get the first admin.
DEV_SECRET="dev-only-insecure-secret-change-me-0123456789abcdef"
# FakePaystackClient dev secret (services/api/src/modules/payments/paystack.client.ts).
PAYSTACK_DEV_SECRET="fake-paystack-secret"

TODAY="$(date -u +%F)"
TRIP_AT="$(date -u -v+1d +%FT06:30:00Z 2>/dev/null || date -u -d '+1 day' +%FT06:30:00Z)"
STAMP="$(date +%s)"

for tool in node curl jq; do
  command -v "$tool" >/dev/null || { echo "missing required tool: $tool"; exit 1; }
done

green() { printf '\033[1;32m%s\033[0m\n' "$1"; }
cyan()  { printf '\n\033[1;36m▶ %s\033[0m\n' "$1"; }
die()   { printf '\033[1;31m✗ %s\033[0m\n' "$1"; exit 1; }

curl -sf "$BASE_URL/healthz" >/dev/null 2>&1 \
  || die "API not reachable at $BASE_URL — start it first (see the header of this script)."

# mint <userId> <role> → an access token signed with the DEV secret (2h)
mint() {
  node --input-type=module -e "
    import { SignJWT } from 'jose';
    const t = await new SignJWT({ role: process.argv[2] })
      .setProtectedHeader({ alg: 'HS256' })
      .setSubject(process.argv[1]).setIssuedAt()
      .setIssuer('trotxi').setAudience('trotxi-api').setExpirationTime('2h')
      .sign(new TextEncoder().encode('$DEV_SECRET'));
    console.log(t);
  " "$1" "$2"
}

# signin <sub> <name> → the sign-in JSON (fake Google verifier: idToken is JSON claims)
signin() {
  local claims body
  claims=$(jq -cn --arg sub "$1" --arg name "$2" '{sub:$sub,name:$name}')
  body=$(jq -cn --arg t "$claims" '{idToken:$t}')
  curl -s "$BASE_URL/auth/google" -H 'content-type: application/json' -d "$body"
}

auth() { echo "authorization: Bearer $1"; }
post() { curl -s "$BASE_URL$1" -H "$(auth "$2")" -H 'content-type: application/json' -d "$3"; }

# webhook <reference> → sign + deliver a fake Paystack charge.success
webhook() {
  local body sig
  body="{\"event\":\"charge.success\",\"data\":{\"reference\":\"$1\"}}"
  sig=$(node -e "process.stdout.write(require('crypto').createHmac('sha512','$PAYSTACK_DEV_SECRET').update(process.argv[1]).digest('hex'))" "$body")
  curl -s "$BASE_URL/webhooks/paystack" -H 'content-type: application/json' \
    -H "x-paystack-signature: $sig" -d "$body" >/dev/null
}

# --- 1. admin + fleet ---------------------------------------------------------
cyan "1. Admin (minted) creates route / stop / vehicle / trip"
ADMIN=$(mint "admin-$STAMP" admin)
ROUTE=$(post /admin/routes "$ADMIN" '{"name":"East Legon → Airport"}' | jq -r .id)
STOP=$(post /admin/stops "$ADMIN" '{"name":"East Legon Stop","latitude":5.63,"longitude":-0.16}' | jq -r .id)
post "/admin/routes/$ROUTE/stops" "$ADMIN" "$(jq -cn --arg s "$STOP" '{stopId:$s,seq:1}')" >/dev/null
VEHICLE=$(post /admin/vehicles "$ADMIN" "$(jq -cn --arg r "GR-$STAMP" '{registration:$r,capacity:15}')" | jq -r .id)
TRIP=$(post /admin/trips "$ADMIN" "$(jq -cn --arg r "$ROUTE" --arg at "$TRIP_AT" '{routeId:$r,scheduledAt:$at}')" | jq -r .id)
green "✓ route=$ROUTE  trip=$TRIP  vehicle=$VEHICLE"

# --- 2. driver bootstrap ------------------------------------------------------
cyan "2. Bootstrap a driver: sign in (commuter) → grant 'driver' → re-sign-in"
DUSER=$(signin "driver-$STAMP" "Kwame Driver" | jq -r .user.id)
DFLEET=$(post /admin/drivers "$ADMIN" "$(jq -cn --arg u "$DUSER" '{fullName:"Kwame Driver",userId:$u}')" | jq -r .id)
curl -s -X PUT "$BASE_URL/admin/trips/$TRIP/assignment" -H "$(auth "$ADMIN")" -H 'content-type: application/json' \
  -d "$(jq -cn --arg v "$VEHICLE" --arg d "$DFLEET" '{vehicleId:$v,assignedDriverId:$d}')" >/dev/null
curl -s -X PATCH "$BASE_URL/admin/users/$DUSER/role" -H "$(auth "$ADMIN")" -H 'content-type: application/json' \
  -d '{"role":"driver"}' >/dev/null
DRIVER=$(signin "driver-$STAMP" "Kwame Driver" | jq -r .accessToken)
DROLE=$(node -e "console.log(JSON.parse(Buffer.from(process.argv[1].split('.')[1],'base64')).role)" "$DRIVER")
[ "$DROLE" = "driver" ] || die "role grant failed — token role is '$DROLE'"
green "✓ driver promoted (token role='$DROLE') and assigned to the trip"

# --- 3. rider subscribes ------------------------------------------------------
cyan "3. Rider signs in → subscribes → webhook → rides allocated"
RJSON=$(signin "ama-$STAMP" "Ama Mensah")
RIDER=$(echo "$RJSON" | jq -r .accessToken)
REF=$(post /payments/subscribe "$RIDER" '{"plan":"monthly"}' | jq -r .reference)
webhook "$REF"
RIDES0=$(curl -s "$BASE_URL/me/rides" -H "$(auth "$RIDER")" | jq .remainingRides)
green "✓ Ama subscribed → remainingRides=$RIDES0"

# --- 4. rider confirms --------------------------------------------------------
cyan "4. Rider confirms tomorrow's trip → gets a daily PIN"
CONF=$(post /me/reservations "$RIDER" "$(jq -cn --arg t "$TRIP" --arg d "$TODAY" '{tripId:$t,travelDate:$d,direction:"morning",travelling:true}')")
RESV=$(echo "$CONF" | jq -r .id)
PIN=$(echo "$CONF" | jq -r .pin)
green "✓ reservation=$RESV  status=$(echo "$CONF" | jq -r .status)  pin=$PIN"

# --- 5. driver manifest -------------------------------------------------------
cyan "5. Driver opens the trip manifest (photo pass)"
curl -s "$BASE_URL/boarding/manifest?tripId=$TRIP" -H "$(auth "$DRIVER")" \
  | jq '{tripId, riders: [.riders[] | {name, direction, boarded}]}'

# --- 6. board by PIN ----------------------------------------------------------
cyan "6. Driver boards the rider by PIN → one ride is debited"
VP=$(post /boarding/verify-pin "$DRIVER" "$(jq -cn --arg r "$RESV" --arg p "$PIN" '{reservationId:$r,pin:$p}')")
echo "verify-pin → $VP"
RIDES1=$(curl -s "$BASE_URL/me/rides" -H "$(auth "$RIDER")" | jq .remainingRides)

cyan "RESULT"
echo "rides: $RIDES0 → $RIDES1   (deducted=$(echo "$VP" | jq -r .deducted))"
if [ "$RIDES1" = "$((RIDES0 - 1))" ] && [ "$(echo "$VP" | jq -r .deducted)" = "true" ]; then
  green "✓ FULL LOOP PASSED — ride consumed end to end"
else
  die "loop did not consume a ride as expected"
fi

# --- poke it yourself in Swagger ---------------------------------------------
cyan "Now try it in Swagger — $BASE_URL/docs (Authorize → paste a token, NO quotes)"
cat <<EOF
  ADMIN  token : $ADMIN
  DRIVER token : $DRIVER
  RIDER  token : $RIDER

  tripId       : $TRIP
  reservationId: $RESV   pin: $PIN
EOF
