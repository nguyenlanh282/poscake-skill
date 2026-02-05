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
  qs="${1:-}"; shift || true
  if [[ -z "$qs" ]]; then qs="?page=1&page_size=30"; fi
  pos_request GET "/shops/$SHOP_ID/inventory_histories${qs}"
  ;;
analytics)
  qs="${1:-}"; shift || true
  if [[ -z "$qs" ]]; then
    echo "Error: Query params required. Example: ?startDate=1704067200&endDate=1706745600&type=actual" >&2
    exit 1
  fi
  pos_request GET "/shops/$SHOP_ID/inventory_analytics/inventory${qs}"
  ;;
analytics-product)
  qs="${1:-}"; shift || true
  if [[ -z "$qs" ]]; then
    echo "Error: Query params required. Example: ?startDate=1704067200&endDate=1706745600&type=actual" >&2
    exit 1
  fi
  pos_request GET "/shops/$SHOP_ID/inventory_analytics/inventory_by_product${qs}"
  ;;
export)
  qs="${1:-}"; shift || true
  if [[ -z "$qs" ]]; then qs=""; fi
  pos_request GET "/shops/$SHOP_ID/export${qs}"
  ;;
help|--help|-h)
  cat <<EOF
Usage: inventory.sh <command> [query_string]

Commands:
  histories          Get inventory import/export history
  analytics          Get inventory report by variation (SKU)
  analytics-product  Get inventory report by product
  export             Export inventory data

Examples:
  # Get inventory history
  bash inventory.sh histories "?page=1&page_size=50"

  # Filter history by warehouse
  bash inventory.sh histories "?warehouse_id=abc123"

  # Get analytics by variation (required params: startDate, endDate, type)
  bash inventory.sh analytics "?startDate=1704067200&endDate=1706745600&type=actual"

  # Get analytics by product
  bash inventory.sh analytics-product "?startDate=1704067200&endDate=1706745600&type=remain"

  # Export data
  bash inventory.sh export "?type=inventory"

Query Parameters:
  histories:
    page, page_size      Pagination (default: 1, 30)
    warehouse_id         Filter by warehouse ID
    variation_ids[]      Filter by variation IDs
    startDate, endDate   Unix timestamps

  analytics / analytics-product:
    page, page_size      Pagination
    startDate            Unix timestamp (required)
    endDate              Unix timestamp (required)
    type                 "actual" (stock) or "remain" (available to sell) (required)

Environment:
  POS_API_KEY    API key (required)
  SHOP_ID        Shop ID (required)
  POS_BASE_URL   API base URL (default: https://pos.pages.fm/api/v1)
EOF
  ;;
*)
  echo "Unknown command: $cmd" >&2
  echo "Run 'inventory.sh help' for usage" >&2
  exit 1
  ;;
esac
