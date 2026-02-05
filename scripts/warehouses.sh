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
  pos_request GET "/shops/$SHOP_ID/warehouses"
  ;;
get)
  id="${1:?WAREHOUSE_ID required}"
  pos_request GET "/shops/$SHOP_ID/warehouses/$id"
  ;;
create)
  confirm_write
  body="$(cat)"
  pos_request POST "/shops/$SHOP_ID/warehouses" "$body"
  ;;
update)
  confirm_write
  id="${1:?WAREHOUSE_ID required}"
  body="$(cat)"
  pos_request PUT "/shops/$SHOP_ID/warehouses/$id" "$body"
  ;;
  *)
    echo "Unknown command: $cmd" >&2
    exit 1
    ;;
esac
