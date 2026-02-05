#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$DIR/common.sh"

require_env SHOP_ID

cmd="${1:-}"
shift || true

case "$cmd" in
histories)
  qs="${1:-}?"; shift || true
  if [[ "$qs" == "?" ]]; then qs=""; fi
  pos_request GET "/shops/$SHOP_ID/inventory_histories${qs}"
  ;;
analytics)
  qs="${1:-}?"; shift || true
  if [[ "$qs" == "?" ]]; then qs=""; fi
  pos_request GET "/shops/$SHOP_ID/inventory_analytics/inventory${qs}"
  ;;
export)
  qs="${1:-}?"; shift || true
  if [[ "$qs" == "?" ]]; then qs=""; fi
  pos_request GET "/shops/$SHOP_ID/export${qs}"
  ;;
  *)
    echo "Unknown command: $cmd" >&2
    exit 1
    ;;
esac
