import { readdirSync } from 'node:fs';
import { join, relative } from 'node:path';
import { execFileSync } from 'node:child_process';

// Read-only manifest inventory. This is not Xcode's signed-archive report and
// cannot prove runtime collection, required-reason compliance or store approval.
const apps = process.argv.slice(2);
if (!apps.length) throw new Error('Pass one or more built .app directories.');
function manifests(directory) {
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) return manifests(path);
    return entry.isFile() && entry.name === 'PrivacyInfo.xcprivacy' ? [path] : [];
  });
}
const report = apps.map((app) => ({
  app: app.includes('trotxi_driver') ? 'driver' : 'commuter',
  artifact: app.includes('iphonesimulator') ? 'iOS debug simulator' : 'iOS app',
  manifests: manifests(app)
    .sort()
    .map((path) => ({
      path: relative(app, path),
      declarations: JSON.parse(
        execFileSync('/usr/bin/plutil', ['-convert', 'json', '-o', '-', path], {
          encoding: 'utf8',
        }),
      ),
    })),
}));
console.log(JSON.stringify(report, null, 2));
