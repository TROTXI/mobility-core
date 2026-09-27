#!/usr/bin/env bash
# Trigger a Render deploy and block until it is live (or fails).
# Requires: RENDER_API_KEY (secret), SERVICE_ID (the srv-… id of the service).
set -euo pipefail

api="https://api.render.com/v1"
if [[ ! "${COMMIT_ID:-}" =~ ^[0-9a-f]{40}$ ]]; then
  echo 'COMMIT_ID must be the reviewed full commit SHA' >&2
  exit 1
fi

create_response=$(
  curl -fsS -X POST "${api}/services/${SERVICE_ID}/deploys" \
    -H "Authorization: Bearer ${RENDER_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$(jq -cn --arg commit "$COMMIT_ID" '{commitId:$commit}')"
)
deploy_id=$(echo "${create_response}" | jq -r '.id // empty')

# Guard: without a deploy id the poll URL would fall back to the *list* endpoint
# (which returns an array), so fail loudly with the actual response instead.
if [ -z "${deploy_id}" ]; then
  echo "Failed to trigger deploy — unexpected Render API response:" >&2
  echo "${create_response}" >&2
  exit 1
fi
echo "Triggered deploy ${deploy_id} for ${SERVICE_ID}"

# Free-tier Docker builds can take a while; poll for up to 20 minutes.
for _ in $(seq 1 120); do
  status=$(
    curl -fsS "${api}/services/${SERVICE_ID}/deploys/${deploy_id}" \
      -H "Authorization: Bearer ${RENDER_API_KEY}" | jq -r '.status // empty'
  )
  if [ -z "${status}" ]; then
    echo "  (no status yet — retrying)"
    sleep 10
    continue
  fi
  echo "  status: ${status}"
  case "${status}" in
    live)
      echo "Deploy is live."
      exit 0
      ;;
    build_failed | update_failed | pre_deploy_failed | canceled | deactivated)
      echo "Deploy failed with status: ${status}" >&2
      exit 1
      ;;
  esac
  sleep 10
done

echo "Timed out waiting for the deploy to go live." >&2
exit 1
