#!/usr/bin/env bash
# A commit deploy does not apply render.yaml headers. Refuse to report staging
# healthy until the live Ops document serves the policy in this Blueprint.
set -euo pipefail

expected=$(
  awk '
    /name: Content-Security-Policy/ { found = 1; next }
    found && /^[[:space:]]*value: "/ {
      sub(/^[[:space:]]*value: "/, "")
      sub(/"$/, "")
      print
      exit
    }
  ' render.yaml
)
if [[ -z "${expected}" ]]; then
  echo 'Ops Content-Security-Policy is missing from render.yaml.' >&2
  exit 1
fi

ops_url="${OPS_CSP_URL:-https://trotxi-ops-staging.onrender.com}"
headers=$(curl -fsSI --retry 5 --retry-delay 5 --max-time 20 "${ops_url%/}/")
actual=$(
  printf '%s\n' "${headers}" | tr -d '\r' |
    awk 'tolower($1) == "content-security-policy:" { $1 = ""; sub(/^ /, ""); print; exit }'
)
if [[ "${actual}" != "${expected}" ]]; then
  echo 'The live Ops CSP does not match render.yaml.' >&2
  echo 'Apply the reviewed Blueprint change (or update only the Ops static-site header), then rerun deployment.' >&2
  exit 1
fi
echo 'Live Ops CSP matches render.yaml.'
