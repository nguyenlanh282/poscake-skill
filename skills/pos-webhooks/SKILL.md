---
name: pos-webhooks
description: Template & hướng dẫn thiết kế webhook integration cho POS (OpenAPI hiện tại không có endpoint webhook).
allowed-tools: Bash(curl *), Bash(python *), Bash(jq *)
---

# pos-webhooks

## Mục tiêu
Template & hướng dẫn thiết kế webhook integration cho POS (OpenAPI hiện tại không có endpoint webhook).

## Thiết lập môi trường (bắt buộc)
- `POS_API_KEY`: API key (được truyền qua query param `api_key`)
- `SHOP_ID`: Shop ID (bắt buộc cho endpoint dạng `/shops/{SHOP_ID}/...`)

Tuỳ chọn:
- `POS_BASE_URL`: mặc định `https://pos.pages.fm/api/v1`

## Cách gọi nhanh
Script gợi ý: `(không có script gọi API trong spec)`

Ví dụ (GET):
```bash
export POS_API_KEY="***"
export SHOP_ID="123"
bash (không có script gọi API trong spec) list "?page=1&page_size=20"
```

Ví dụ (WRITE):
```bash
export CONFIRM_WRITE=YES
cat payload.json | bash (không có script gọi API trong spec) create
```

## Guardrails
- Không ghi dữ liệu khi chưa set `CONFIRM_WRITE=YES`.
- Với thao tác ghi: luôn chạy 1 lệnh GET trước để xác nhận ID/shape dữ liệu.
- Không lưu API key vào repo.

## Endpoint thuộc skill này
_(Không có endpoint webhook trong OpenAPI hiện tại — skill này là template & hướng dẫn.)_

## Tham chiếu
- OpenAPI spec: `openapi-pos.json` (ở root bundle)
