#!/usr/bin/env bash
set -euo pipefail

# Pancake POS API helper
# Env:
#   POS_BASE_URL (default: https://pos.pages.fm/api/v1)
#   POS_API_KEY  (required)  -> passed as query param api_key
#   SHOP_ID      (required for /shops/{SHOP_ID} endpoints)

POS_BASE_URL="${POS_BASE_URL:-https://pos.pages.fm/api/v1}"

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "Missing env var: $name" >&2
    exit 2
  fi
}

# Usage:
#   pos_request METHOD PATH [JSON_BODY]
pos_request() {
  local method="$1"
  local path="$2"
  local body="${3:-}"

  require_env POS_API_KEY

  local connector="?"
  if [[ "$path" == *"?"* ]]; then connector="&"; fi

  local url="${POS_BASE_URL}${path}${connector}api_key=$(python - <<PY
import os, urllib.parse
print(urllib.parse.quote(os.environ["POS_API_KEY"], safe=""))
PY
)"

  if [[ -n "$body" ]]; then
    curl -sS -X "$method" "$url"       -H "Content-Type: application/json"       --data "$body"
  else
    curl -sS -X "$method" "$url"
  fi
}

# Guardrail: require CONFIRM_WRITE=YES for POST/PUT/PATCH/DELETE
confirm_write() {
  if [[ "${CONFIRM_WRITE:-}" != "YES" ]]; then
    echo "Write operation blocked. Set CONFIRM_WRITE=YES to proceed." >&2
    exit 3
  fi
}
