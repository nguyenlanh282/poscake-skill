---
name: pos-products
description: Làm việc với sản phẩm (tạo/đọc/cập nhật), variations, tags/materials, combo và tra cứu tồn theo sản phẩm.
allowed-tools: Bash(curl *), Bash(python *), Bash(jq *)
---

# pos-products

## Mục tiêu
Làm việc với sản phẩm (tạo/đọc/cập nhật), variations, tags/materials, combo và tra cứu tồn theo sản phẩm.

## Thiết lập môi trường (bắt buộc)
- `POS_API_KEY`: API key (được truyền qua query param `api_key`)
- `SHOP_ID`: Shop ID (bắt buộc cho endpoint dạng `/shops/{SHOP_ID}/...`)

Tuỳ chọn:
- `POS_BASE_URL`: mặc định `https://pos.pages.fm/api/v1`

## Cách gọi nhanh
Script gợi ý: `scripts/products.sh`

Ví dụ (GET):
```bash
export POS_API_KEY="***"
export SHOP_ID="123"
bash scripts/products.sh list "?page=1&page_size=20"
```

Ví dụ (WRITE):
```bash
export CONFIRM_WRITE=YES
cat payload.json | bash scripts/products.sh create
```

## Guardrails
- Không ghi dữ liệu khi chưa set `CONFIRM_WRITE=YES`.
- Với thao tác ghi: luôn chạy 1 lệnh GET trước để xác nhận ID/shape dữ liệu.
- Không lưu API key vào repo.

## Endpoint thuộc skill này
- `/shops/{SHOP_ID}/products/get_logistics_shipping_document`
- `/shops/{SHOP_ID}/marketplace/products`
- `/shops/{SHOP_ID}/products`
- `/shops/{SHOP_ID}/products/{PRODUCT_ID}`
- `/shops/{SHOP_ID}/products/variations`
- `/shops/{SHOP_ID}/products/{PRODUCT_SKU}`
- `/shops/{SHOP_ID}/products/update_hide`
- `/shops/{SHOP_ID}/tags_products`
- `/shops/{SHOP_ID}/materials_products`
- `/shops/{SHOP_ID}/product_measurements/get_measure`
- `/shops/{SHOP_ID}/combo_products`
- `/shops/{SHOP_ID}/variations/update_composite_product`
- `/shops/{SHOP_ID}/inventory_analytics/inventory_by_product`

## Tham chiếu
- OpenAPI spec: `openapi-pos.json` (ở root bundle)
