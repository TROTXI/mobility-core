#!/usr/bin/env bash
set -euo pipefail
# Official release digest. Do not silently consume a different tool version.
target="${RUNNER_TEMP:?}/bundletool-all-1.18.3.jar"
curl --fail --location --silent --show-error \
  https://github.com/google/bundletool/releases/download/1.18.3/bundletool-all-1.18.3.jar \
  --output "$target"
python3 - "$target" <<'PY'
import hashlib
import pathlib
import sys
actual = hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).hexdigest()
if actual != 'a099cfa1543f55593bc2ed16a70a7c67fe54b1747bb7301f37fdfd6d91028e29':
    raise SystemExit('Bundletool checksum mismatch.')
PY
echo "BUNDLETOOL_JAR=$target" >> "$GITHUB_ENV"
