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
  pos_request GET "/shops/$SHOP_ID/customers${qs}"
  ;;
get)
  id="${1:?CUSTOMER_ID required}"
  pos_request GET "/shops/$SHOP_ID/customers/$id"
  ;;
create)
  confirm_write
  body="$(cat)"
  pos_request POST "/shops/$SHOP_ID/customers" "$body"
  ;;
update)
  confirm_write
  id="${1:?CUSTOMER_ID required}"
  body="$(cat)"
  pos_request PUT "/shops/$SHOP_ID/customers/$id" "$body"
  ;;
levels)
  pos_request GET "/shops/$SHOP_ID/customer_levels"
  ;;
point-logs)
  qs="${1:-}?"; shift || true
  if [[ "$qs" == "?" ]]; then qs=""; fi
  pos_request GET "/shops/$SHOP_ID/customers/point_logs${qs}"
  ;;
notes)
  id="${1:?CUSTOMER_ID required}"
  pos_request GET "/shops/$SHOP_ID/customers/$id/load_customer_notes"
  ;;
create-note)
  confirm_write
  id="${1:?CUSTOMER_ID required}"
  body="$(cat)"
  pos_request POST "/shops/$SHOP_ID/customers/$id/create_note" "$body"
  ;;
  *)
    echo "Unknown command: $cmd" >&2
    exit 1
    ;;
esac
