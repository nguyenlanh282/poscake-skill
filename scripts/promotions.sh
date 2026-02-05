#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$DIR/common.sh"

require_env SHOP_ID

cmd="${1:-}"
shift || true

case "$cmd" in
# ==================== PROMOTIONS ====================
list)
  qs="${1:-}"; shift || true
  if [[ -z "$qs" ]]; then qs="?page=1&page_size=10"; fi
  pos_request GET "/shops/$SHOP_ID/promotion_advance${qs}"
  ;;
create)
  confirm_write
  body="$(cat)"
  pos_request POST "/shops/$SHOP_ID/promotion_advance" "$body"
  ;;
update)
  confirm_write
  promo_id="${1:?PROMOTION_ID required}"
  shift || true
  body="$(cat)"
  pos_request PUT "/shops/$SHOP_ID/promotion_advance/$promo_id" "$body"
  ;;
bulk-action)
  confirm_write
  body="$(cat)"
  pos_request POST "/shops/$SHOP_ID/promotion_advance/delete_multi" "$body"
  ;;
create-for-customers)
  confirm_write
  body="$(cat)"
  pos_request POST "/shops/$SHOP_ID/promotion_advance/create_multi" "$body"
  ;;

# ==================== VOUCHERS ====================
vouchers)
  qs="${1:-}"; shift || true
  pos_request GET "/shops/$SHOP_ID/vouchers${qs}"
  ;;
voucher)
  voucher_id="${1:?VOUCHER_ID required}"
  shift || true
  pos_request GET "/shops/$SHOP_ID/vouchers/$voucher_id"
  ;;
create-voucher)
  confirm_write
  body="$(cat)"
  pos_request POST "/shops/$SHOP_ID/vouchers" "$body"
  ;;
create-vouchers)
  confirm_write
  body="$(cat)"
  pos_request POST "/shops/$SHOP_ID/vouchers/create_multi" "$body"
  ;;

help|--help|-h)
  cat <<EOF
Usage: promotions.sh <command> [args]

PROMOTIONS:
  list [query]              List promotions
  create                    Create a promotion (reads JSON from stdin)
  update <id>               Update a promotion (reads JSON from stdin)
  bulk-action               Activate/Deactivate/Delete promotions (reads JSON from stdin)
  create-for-customers      Create promotions for specific customers (reads JSON from stdin)

VOUCHERS:
  vouchers                  List all vouchers
  voucher <id>              Get voucher details
  create-voucher            Create a voucher (reads JSON from stdin)
  create-vouchers           Create multiple vouchers (reads JSON from stdin)

Examples:
  # List promotions
  bash promotions.sh list

  # Search promotions
  bash promotions.sh list "?textSearch=giảm 20%"

  # Create a promotion
  export CONFIRM_WRITE=YES
  cat <<'JSON' | bash promotions.sh create
  {
    "promotion_advance": {
      "name": "Giảm 10% sản phẩm A",
      "type": "discount_by_product",
      "start_time": 1704067200,
      "end_time": 1706745600,
      "is_activated": true,
      "coupon_info": {
        "discount": 10,
        "is_percent": true
      }
    }
  }
  JSON

  # Update a promotion
  export CONFIRM_WRITE=YES
  cat <<'JSON' | bash promotions.sh update "260a0d45-ba88-457b-8b31-afa3fda0ce0e"
  {
    "promotion_advance": {
      "name": "Giảm 15% sản phẩm A",
      "is_activated": true
    }
  }
  JSON

  # Activate promotions
  export CONFIRM_WRITE=YES
  cat <<'JSON' | bash promotions.sh bulk-action
  {
    "ids": ["promo-id-1", "promo-id-2"],
    "type_action": "ACTIVE_PROMOTIONS"
  }
  JSON

  # Deactivate promotions
  cat <<'JSON' | bash promotions.sh bulk-action
  {
    "ids": ["promo-id-1"],
    "type_action": "DEACTIVE_PROMOTIONS"
  }
  JSON

  # Delete promotions
  cat <<'JSON' | bash promotions.sh bulk-action
  {
    "ids": ["promo-id-1"],
    "type_action": "DELETE_PROMOTIONS"
  }
  JSON

  # Create voucher
  export CONFIRM_WRITE=YES
  cat <<'JSON' | bash promotions.sh create-voucher
  {
    "name": "SUMMER2024",
    "promo_code_info": {
      "discount": 50000,
      "is_percent": false
    },
    "is_free_shipping": false,
    "is_activated": true,
    "customer_tags": [],
    "start_time": "2024-01-01T00:00:00",
    "end_time": "2024-12-31T23:59:59"
  }
  JSON

  # Get voucher details
  bash promotions.sh voucher "9589b791-013f-4a5b-b8d1-164fad73d84e"

Bulk Action Types:
  ACTIVE_PROMOTIONS     Activate promotions
  DEACTIVE_PROMOTIONS   Deactivate promotions
  DELETE_PROMOTIONS     Delete promotions

Promotion Types:
  discount_by_product      Discount by product
  discount_by_coupon_id    Discount by coupon code
  discount_by_quantity     Discount by quantity
  discount_by_order_price  Discount by order value
  bonus_product            Bonus product gift

Environment:
  POS_API_KEY      API key (required)
  SHOP_ID          Shop ID (required)
  CONFIRM_WRITE    Set to YES for write operations
  POS_BASE_URL     API base URL (default: https://pos.pages.fm/api/v1)
EOF
  ;;
*)
  echo "Unknown command: $cmd" >&2
  echo "Run 'promotions.sh help' for usage" >&2
  exit 1
  ;;
esac
