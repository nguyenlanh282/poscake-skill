#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$DIR/common.sh"

require_env SHOP_ID

cmd="${1:-}"
shift || true

case "$cmd" in
list)
  qs="${1:-}?"; shift || true
  if [[ "$qs" == "?" ]]; then qs=""; fi
  pos_request GET "/shops/$SHOP_ID/stocktakings${qs}"
  ;;
get)
  id="${1:?STOCKTAKING_ID required}"
  pos_request GET "/shops/$SHOP_ID/stocktakings/$id"
  ;;
create)
  confirm_write
  body="$(cat)"
  pos_request POST "/shops/$SHOP_ID/stocktakings" "$body"
  ;;
update)
  confirm_write
  id="${1:?STOCKTAKING_ID required}"
  body="$(cat)"
  pos_request PUT "/shops/$SHOP_ID/stocktakings/$id" "$body"
  ;;
  *)
    echo "Unknown command: $cmd" >&2
    exit 1
    ;;
esac
