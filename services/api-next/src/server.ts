import { readConfiguration } from './runtime/config.js';
import { composeBackend } from './runtime/compose.js';

/**
 * The deployable entry point.
 *
 * Configuration is read and validated before anything is built, and the whole
 * backend is composed before the listener opens, so a deployment that is
 * missing a capability never accepts a request it cannot serve: it exits with
 * the name of what is missing and the platform reports a failed deploy.
 */
const config = readConfiguration();
const backend = await composeBackend(config);
await backend.app.listen({ host: config.listen.host, port: config.listen.port });
process.stdout.write(
  `${JSON.stringify({
    service: config.build.service,
    version: config.build.version,
    commit: config.build.commit,
    listening: `${config.listen.host}:${config.listen.port}`,
    payments: config.paystack.secretKey.startsWith('sk_live_') ? 'live' : 'test',
    // What a rider can actually sign in with on this deployment, so the log
    // says it rather than leaving it to be discovered from a missing button.
    providers: config.providers,
  })}\n`,
);

let stopping = false;
async function stop(signal: string) {
  if (stopping) return;
  stopping = true;
  // The platform will kill the process anyway; this bounds how long we hold
  // an in-flight request open rather than promising a clean drain forever.
  const deadline = setTimeout(() => process.exit(1), 15000);
  deadline.unref();
  try {
    await backend.close();
    process.stdout.write(`${JSON.stringify({ stopped: signal })}\n`);
    process.exit(0);
  } catch (error) {
    process.stderr.write(`${JSON.stringify({ signal, failed: String(error) })}\n`);
    process.exit(1);
  }
}
for (const signal of ['SIGTERM', 'SIGINT'] as const) process.on(signal, () => void stop(signal));
// A process whose state we cannot vouch for must not keep serving money and
// audit writes. Exit and let the platform start a clean one.
process.on('uncaughtException', (error) => {
  process.stderr.write(`${JSON.stringify({ fatal: String(error) })}\n`);
  process.exit(1);
});
process.on('unhandledRejection', (reason) => {
  process.stderr.write(`${JSON.stringify({ fatal: String(reason) })}\n`);
  process.exit(1);
});
