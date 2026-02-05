---
name: pos-inventory
description: Lịch sử tồn và báo cáo tồn: inventory histories + inventory analytics + export.
allowed-tools: Bash(curl *), Bash(python *), Bash(jq *)
---

# pos-inventory

## Mục tiêu
Lịch sử tồn và báo cáo tồn: inventory histories + inventory analytics + export.

## Thiết lập môi trường (bắt buộc)
- `POS_API_KEY`: API key (được truyền qua query param `api_key`)
- `SHOP_ID`: Shop ID (bắt buộc cho endpoint dạng `/shops/{SHOP_ID}/...`)

Tuỳ chọn:
- `POS_BASE_URL`: mặc định `https://pos.pages.fm/api/v1`

## Cách gọi nhanh
Script gợi ý: `scripts/inventory.sh`

Ví dụ (GET):
```bash
export POS_API_KEY="***"
export SHOP_ID="123"
bash scripts/inventory.sh list "?page=1&page_size=20"
```

Ví dụ (WRITE):
```bash
export CONFIRM_WRITE=YES
cat payload.json | bash scripts/inventory.sh create
```

## Guardrails
- Không ghi dữ liệu khi chưa set `CONFIRM_WRITE=YES`.
- Với thao tác ghi: luôn chạy 1 lệnh GET trước để xác nhận ID/shape dữ liệu.
- Không lưu API key vào repo.

## Endpoint thuộc skill này
- `/shops/{SHOP_ID}/inventory_histories`
- `/shops/{SHOP_ID}/inventory_analytics/inventory`
- `/shops/{SHOP_ID}/export`

## Tham chiếu
- OpenAPI spec: `openapi-pos.json` (ở root bundle)
