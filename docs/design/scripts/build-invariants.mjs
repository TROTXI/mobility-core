import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { writeArtifact as writeFile } from './artifact-io.mjs';
import { invariants } from '../contracts/invariant-catalog.mjs';
const rows = [];
for (const [id, file, name, rule, scope] of invariants) {
  const path = `services/api/tests/${file}.test.ts`;
  const content = execFileSync(
    'git',
    ['show', `43cdae0b437e70ca146704eb4201a2325c9d9327:${path}`],
    { cwd: fileURLToPath(new URL('../../../', import.meta.url)), encoding: 'utf8' },
  );
  const matches = [...content.matchAll(/\bit\((['"])(.*?)\1/g)].filter((m) => m[2] === name);
  if (matches.length !== 1)
    throw new Error(`${id}: expected one exact test named ${name}, found ${matches.length}`);
  const line = content.slice(0, matches[0].index).split('\n').length;
  rows.push(
    `| ${id} | ${rule.replaceAll('|', '/')} | [${file}:${line}](https://github.com/TROTXI/mobility-core/blob/43cdae0/${path}#L${line}) — ${name.replaceAll('|', '/')} | ${scope} |`,
  );
}
await writeFile(
  new URL('../stage-1-invariants.md', import.meta.url),
  `# Stage 1: non-payment acceptance inventory\n\nBaseline source 43cdae0. Generated from contracts/invariant-catalog.mjs; exact test names and line references are checked by scripts/build-invariants.mjs. These ${rows.length} scenario groups complement PAY-01 through PAY-16; they are an acceptance inventory, not a claim every behavior is covered or a new Postgres test run.\n\n| ID | Domain rule to preserve | Existing evidence | Evidence limits |\n| --- | --- | --- | --- |\n${rows.join('\n')}\n\n## Target-only requirements, not proven by baseline\n\n- OWN-01: cross-rider membership/purchase/period/reservation links fail in Postgres, including direct writes.\n- VER-01: trip, schedule, stop occurrences and progress share an immutable published pattern version; edits cannot rewrite operated history. Reassignment is explicit for affected future trips.\n- VER-02: outbound/return schedules and geometry are independent of morning/evening inference. The two commute legs are opposite directions on the chosen corridor with valid stop order.\n- GPS-08: eligibility checked before cached live reads; paused/current-disputed/lapsed/pre-booking cases follow the review matrix.\n- GPS-09: receipt-time retention, bounded purge/hold/release races, replay after expiry, delayed capture and future-clock clamping have explicit outcomes.\n- GPS-10: atomic latest-position update under actual worker contention; Redis cannot regress it. Geometry and stop distances publish atomically.\n- GPS-11: loop projection follows traversal/progress context and cannot drop an upcoming repeated stop solely because coordinates match.\n- BRD-10: trip/reservation-scoped QR, capacity/charge/period-close concurrency, invalid ownership and durable rollback tested on full Postgres. KV or auxiliary audit failure is not permission to fabricate a successful charge.\n- ID-11: account erasure across retained traces/incident holds and external provider revocation has a tracked completion/recovery outcome; the memory test title is not proof of complete privacy coverage.\n- ID-12: minimum-build policy is app+platform-specific; stable bootstrap, unsupported-client refusal before mutation, and both actual apps' upgrade flows require end-to-end proof before real-user release (#40).\n- API-01: every list/query respects scope before pagination; cached/idempotent responses never bypass fresh authorization.\n- API-02: old-period dispute/refund cannot rewrite current period access; ops restriction is a separate attributable decision.\n\n## Caveats that must survive harness conversion\n\nCommute PG tests create a reduced schema plus migration 043. Payment/GPS PG tests and constraint tests have different setup; do not relabel all tests as full-migration integration coverage. Memory capacity/boarding tests do not prove concurrent database settlement. Notification test titles overclaim exactly-once delivery: reservation identity, not notification send count, is the stable invariant.\n\nStage 2 must supply a full-schema candidate observer and at least one deliberately failing negative control for each new attribution boundary. Runtime exception/compile failure is not an invariant failure. Preserve numeric payment expectations independently of rewritten fixture SQL. Stage-1 Zod/schema validation is not a replacement for those tests.\n`,
);
console.log(`Verified ${rows.length} exact non-payment test references.`);
