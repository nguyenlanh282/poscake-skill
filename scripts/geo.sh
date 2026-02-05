#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$DIR/common.sh"

cmd="${1:-}"
shift || true

case "$cmd" in
  provinces)
    pos_request GET "/geo/provinces"
    ;;
  districts)
    qs="${1:-}?"; shift || true
    if [[ "$qs" == "?" ]]; then qs=""; fi
    pos_request GET "/geo/districts${qs}"
    ;;
  communes)
    qs="${1:-}?"; shift || true
    if [[ "$qs" == "?" ]]; then qs=""; fi
    pos_request GET "/geo/communes${qs}"
    ;;
  *)
    echo "Usage: geo.sh provinces|districts ["?..."]|communes ["?..."]" >&2
    exit 1
    ;;
esac
