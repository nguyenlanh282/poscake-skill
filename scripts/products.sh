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
  pos_request GET "/shops/$SHOP_ID/products${qs}"
  ;;
get)
  id="${1:?PRODUCT_ID required}"
  pos_request GET "/shops/$SHOP_ID/products/$id"
  ;;
get-by-sku)
  sku="${1:?PRODUCT_SKU required}"
  pos_request GET "/shops/$SHOP_ID/products/$sku"
  ;;
create)
  confirm_write
  body="$(cat)"
  pos_request POST "/shops/$SHOP_ID/products" "$body"
  ;;
update)
  confirm_write
  id="${1:?PRODUCT_ID required}"
  body="$(cat)"
  pos_request PUT "/shops/$SHOP_ID/products/$id" "$body"
  ;;
hide)
  confirm_write
  body="$(cat)"
  pos_request POST "/shops/$SHOP_ID/products/update_hide" "$body"
  ;;
variations)
  qs="${1:-}?"; shift || true
  if [[ "$qs" == "?" ]]; then qs=""; fi
  pos_request GET "/shops/$SHOP_ID/products/variations${qs}"
  ;;
inventory-by-product)
  qs="${1:-}?"; shift || true
  if [[ "$qs" == "?" ]]; then qs=""; fi
  pos_request GET "/shops/$SHOP_ID/inventory_analytics/inventory_by_product${qs}"
  ;;
  *)
    echo "Unknown command: $cmd" >&2
    exit 1
    ;;
esac
