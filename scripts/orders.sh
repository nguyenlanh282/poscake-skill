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
  pos_request GET "/shops/$SHOP_ID/orders${qs}"
  ;;
get)
  id="${1:?ORDER_ID required}"
  pos_request GET "/shops/$SHOP_ID/orders/$id"
  ;;
create)
  confirm_write
  body="$(cat)"
  pos_request POST "/shops/$SHOP_ID/orders" "$body"
  ;;
arrange-shipment)
  confirm_write
  body="$(cat)"
  pos_request POST "/shops/$SHOP_ID/orders/arrange_shipment" "$body"
  ;;
tracking-url)
  qs="${1:-}?"; shift || true
  if [[ "$qs" == "?" ]]; then qs=""; fi
  pos_request GET "/shops/$SHOP_ID/orders/get_tracking_url${qs}"
  ;;
tags)
  pos_request GET "/shops/$SHOP_ID/orders/tags"
  ;;
order-source)
  pos_request GET "/shops/$SHOP_ID/order_source"
  ;;
returned)
  qs="${1:-}?"; shift || true
  if [[ "$qs" == "?" ]]; then qs=""; fi
  pos_request GET "/shops/$SHOP_ID/orders_returned${qs}"
  ;;
call-laters)
  qs="${1:-}?"; shift || true
  if [[ "$qs" == "?" ]]; then qs=""; fi
  pos_request GET "/shops/$SHOP_ID/order_call_laters${qs}"
  ;;
  *)
    echo "Unknown command: $cmd" >&2
    exit 1
    ;;
esac
