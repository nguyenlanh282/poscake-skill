---
name: pos-inventory
description: |
  Inventory management skill for Pancake POS - track inventory histories, analyze stock levels,
  generate import/export reports by variation or product, and export data. Use when working with
  stock tracking, inventory analytics, inventory history queries, or generating inventory reports.
version: 1.0.0
allowed-tools: Bash(curl *), Bash(python *), Bash(jq *)
---

# pos-inventory

Quản lý tồn kho: lịch sử xuất nhập kho, báo cáo tồn theo mẫu mã/sản phẩm, và xuất dữ liệu.

## Tính năng

### 1. Lịch sử xuất nhập kho (Inventory Histories)
Reference: [references/inventory-histories.md](references/inventory-histories.md)
- Xem lịch sử xuất nhập kho theo thời gian
- Lọc theo kho, mẫu mã, khoảng thời gian
- Thông tin chi tiết: số lượng, giá nhập, người thực hiện

### 2. Báo cáo tồn theo mẫu mã (Analytics by Variation)
Reference: [references/inventory-analytics.md](references/inventory-analytics.md)
- Báo cáo xuất nhập kho chi tiết theo từng mẫu mã (SKU)
- Tồn đầu kỳ, tồn cuối kỳ, giá trị tồn
- Phân tích nguồn nhập/xuất: phiếu nhập, trả hàng, chuyển kho, kiểm hàng

### 3. Báo cáo tồn theo sản phẩm (Analytics by Product)
Reference: [references/inventory-analytics.md](references/inventory-analytics.md)
- Tổng hợp xuất nhập kho theo sản phẩm
- Gộp tất cả mẫu mã của sản phẩm

### 4. Xuất dữ liệu (Export)
- Xuất báo cáo tồn kho ra file

## Thiết lập môi trường (bắt buộc)

```bash
export POS_API_KEY="your-api-key"   # API key (query param: api_key)
export SHOP_ID="123"                 # Shop ID
```

Tuỳ chọn:
```bash
export POS_BASE_URL="https://pos.pages.fm/api/v1"  # Mặc định
```

## Cách gọi nhanh

Script: `scripts/inventory.sh`

### Lịch sử xuất nhập kho

```bash
# Lấy lịch sử (mặc định)
bash scripts/inventory.sh histories

# Lọc theo kho
bash scripts/inventory.sh histories "?warehouse_id=b4cb5897-6e56-4581-96cc-2f12677c7bd8"

# Lọc theo mẫu mã và thời gian
bash scripts/inventory.sh histories "?variation_ids[]=abc123&startDate=1704067200&endDate=1706745600"

# Phân trang
bash scripts/inventory.sh histories "?page=1&page_size=50"
```

### Báo cáo tồn theo mẫu mã

```bash
# Báo cáo tồn kho thực tế (actual)
bash scripts/inventory.sh analytics "?startDate=1704067200&endDate=1706745600&type=actual"

# Báo cáo có thể bán (remain)
bash scripts/inventory.sh analytics "?startDate=1704067200&endDate=1706745600&type=remain"
```

### Báo cáo tồn theo sản phẩm

```bash
# Tổng hợp theo sản phẩm
bash scripts/inventory.sh analytics-product "?startDate=1704067200&endDate=1706745600&type=actual"
```

### Xuất dữ liệu

```bash
bash scripts/inventory.sh export "?type=inventory"
```

## Guardrails

- Không ghi dữ liệu khi chưa set `CONFIRM_WRITE=YES`
- Với thao tác ghi: luôn chạy 1 lệnh GET trước để xác nhận ID/shape dữ liệu
- Không lưu API key vào repo
- Sử dụng Unix timestamp (giây) cho startDate/endDate

## Data Models

### Inventory History Entry

```typescript
interface InventoryHistory {
  id: number;
  avg_price: number;
  editor_id: string;
  inserted_at: string;  // ISO datetime
  current_inventory: Array<{
    id: string;           // warehouse ID
    name: string;         // warehouse name
    remain_quantity: number;
    actual_remain_quantity: number;
    total_quantity: number;
    avg_price: number;
  }>;
  warehouse: {
    id: string;
    name: string;
  };
}
```

### Inventory Analytics (by Variation)

```typescript
interface InventoryAnalytics {
  id: string;                    // variation ID
  begin_inventory: number;       // Tồn đầu kỳ
  begin_inventory_value: number; // Giá trị tồn đầu kỳ
  end_inventory: number;         // Tồn cuối kỳ
  end_inventory_value: number;   // Giá trị tồn cuối kỳ

  // Nhập kho
  purchase_import: number;       // Từ phiếu nhập
  return_import: number;         // Từ đơn trả hàng
  stocktaking_import: number;    // Từ kiểm hàng
  transfer_import: number;       // Từ chuyển kho
  total_import: number;
  total_import_value: number;

  // Xuất kho
  purchase_export: number;       // Từ phiếu nhập (trả NCC)
  sell_export: number;           // Từ bán hàng
  stocktaking_export: number;    // Từ kiểm hàng
  transfer_export: number;       // Từ chuyển kho
  total_export: number;
  total_export_value: number;

  variation: {
    id: string;
    product_id: string;
    shop_id: number;
    custom_id: string;
    display_id: number;
    barcode: string | null;
  };
}
```

## Endpoint thuộc skill này

| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `/shops/{SHOP_ID}/inventory_histories` | GET | Lịch sử xuất nhập kho |
| `/shops/{SHOP_ID}/inventory_analytics/inventory` | GET | Báo cáo tồn theo mẫu mã |
| `/shops/{SHOP_ID}/inventory_analytics/inventory_by_product` | GET | Báo cáo tồn theo sản phẩm |
| `/shops/{SHOP_ID}/export` | GET | Xuất dữ liệu |

## Query Parameters

### inventory_histories

| Param | Type | Required | Mô tả |
|-------|------|----------|-------|
| page | integer | Yes | Số trang (default: 1) |
| page_size | integer | Yes | Kích thước trang (default: 30) |
| warehouse_id | string | No | Lọc theo ID kho |
| variation_ids[] | array | No | Lọc theo danh sách mã mẫu mã |
| startDate | integer | No | Unix timestamp bắt đầu |
| endDate | integer | No | Unix timestamp kết thúc |

### inventory_analytics

| Param | Type | Required | Mô tả |
|-------|------|----------|-------|
| page | integer | No | Số trang (default: 1) |
| page_size | integer | No | Kích thước trang (default: 30) |
| startDate | integer | Yes | Unix timestamp bắt đầu |
| endDate | integer | Yes | Unix timestamp kết thúc |
| type | enum | Yes | `actual` (tồn kho) hoặc `remain` (có thể bán) |

## Tham chiếu

- OpenAPI spec: `openapi-pos.json` (ở root bundle)
- Related skills: `pos-warehouses`, `pos-stocktake`, `pos-products`
