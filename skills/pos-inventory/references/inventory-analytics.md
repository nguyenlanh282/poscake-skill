# Inventory Analytics (Báo cáo xuất nhập kho)

API endpoints để lấy báo cáo phân tích xuất nhập kho theo mẫu mã hoặc sản phẩm.

## Endpoints

| Endpoint | Description |
|----------|-------------|
| `/shops/{SHOP_ID}/inventory_analytics/inventory` | Báo cáo theo mẫu mã (variation/SKU) |
| `/shops/{SHOP_ID}/inventory_analytics/inventory_by_product` | Báo cáo theo sản phẩm |

## Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | integer | No | Số trang (default: 1) |
| `page_size` | integer | No | Kích thước trang (default: 30) |
| `startDate` | integer | **Yes** | Unix timestamp bắt đầu kỳ |
| `endDate` | integer | **Yes** | Unix timestamp kết thúc kỳ |
| `type` | enum | **Yes** | `actual` (tồn kho thực tế) hoặc `remain` (có thể bán) |

## Response Schema

### By Variation

```typescript
interface InventoryAnalyticsResponse {
  data: InventoryAnalyticsByVariation[];
  meta: {
    page: number;
    page_size: number;
    total: number;
  };
}

interface InventoryAnalyticsByVariation {
  id: string;                      // Variation ID

  // Tồn kho
  begin_inventory: number;         // Tồn đầu kỳ (số lượng)
  begin_inventory_value: number;   // Giá trị tồn đầu kỳ (VND)
  end_inventory: number;           // Tồn cuối kỳ (số lượng)
  end_inventory_value: number;     // Giá trị tồn cuối kỳ (VND)

  // Nhập kho
  purchase_import: number;         // Nhập từ phiếu nhập hàng
  return_import: number;           // Nhập từ đơn trả hàng
  stocktaking_import: number;      // Nhập từ điều chỉnh kiểm kho
  transfer_import: number;         // Nhập từ chuyển kho
  total_import: number;            // Tổng nhập
  total_import_value: number;      // Giá trị tổng nhập

  // Xuất kho
  purchase_export: number;         // Xuất trả nhà cung cấp
  sell_export: number;             // Xuất bán hàng
  stocktaking_export: number;      // Xuất từ điều chỉnh kiểm kho
  transfer_export: number;         // Xuất chuyển kho
  total_export: number;            // Tổng xuất
  total_export_value: number;      // Giá trị tổng xuất

  // Thông tin mẫu mã
  variation: {
    id: string;
    product_id: string;
    shop_id: number;
    custom_id: string;             // SKU
    display_id: number;
    barcode: string | null;
    name: string;
    product_name: string;
  };
}
```

### By Product

```typescript
interface InventoryAnalyticsByProduct {
  id: string;                      // Product ID
  product_id: string;

  // Cùng structure với ByVariation nhưng tổng hợp tất cả variations
  begin_inventory: number;
  begin_inventory_value: number;
  end_inventory: number;
  end_inventory_value: number;

  // Import/Export totals
  purchase_import: number;
  return_import: number;
  stocktaking_import: number;
  transfer_import: number;
  total_import: number;
  total_import_value: number;

  purchase_export: number;
  sell_export: number;
  stocktaking_export: number;
  transfer_export: number;
  total_export: number;
  total_export_value: number;

  // Thông tin sản phẩm
  product: {
    id: string;
    name: string;
    custom_id: string;
  };
}
```

## Examples

### Báo cáo tồn kho thực tế theo mẫu mã

```bash
export POS_API_KEY="your-api-key"
export SHOP_ID="123"

# Báo cáo tháng 1/2024
# startDate: 2024-01-01 00:00:00 UTC = 1704067200
# endDate: 2024-01-31 23:59:59 UTC = 1706745599

bash scripts/inventory.sh analytics "?startDate=1704067200&endDate=1706745599&type=actual"
```

### Báo cáo có thể bán theo mẫu mã

```bash
bash scripts/inventory.sh analytics "?startDate=1704067200&endDate=1706745599&type=remain"
```

### Báo cáo theo sản phẩm

```bash
bash scripts/inventory.sh analytics-product "?startDate=1704067200&endDate=1706745599&type=actual"
```

### Phân trang

```bash
bash scripts/inventory.sh analytics "?startDate=1704067200&endDate=1706745599&type=actual&page=2&page_size=50"
```

## cURL Examples

### By Variation

```bash
curl -X GET "https://pos.pages.fm/api/v1/shops/${SHOP_ID}/inventory_analytics/inventory?startDate=1704067200&endDate=1706745599&type=actual&api_key=${POS_API_KEY}" \
  -H "Content-Type: application/json"
```

### By Product

```bash
curl -X GET "https://pos.pages.fm/api/v1/shops/${SHOP_ID}/inventory_analytics/inventory_by_product?startDate=1704067200&endDate=1706745599&type=actual&api_key=${POS_API_KEY}" \
  -H "Content-Type: application/json"
```

## Response Example (By Variation)

```json
{
  "data": [
    {
      "id": "415040f4-ab63-465e-8699-e9ebfff4c6c7",
      "begin_inventory": 100,
      "begin_inventory_value": 15000000,
      "end_inventory": 80,
      "end_inventory_value": 12000000,
      "purchase_import": 50,
      "return_import": 5,
      "stocktaking_import": 0,
      "transfer_import": 10,
      "total_import": 65,
      "total_import_value": 9750000,
      "purchase_export": 0,
      "sell_export": 80,
      "stocktaking_export": 5,
      "transfer_export": 0,
      "total_export": 85,
      "total_export_value": 12750000,
      "variation": {
        "id": "415040f4-ab63-465e-8699-e9ebfff4c6c7",
        "product_id": "prod-uuid",
        "shop_id": 123,
        "custom_id": "SKU001",
        "display_id": 1,
        "barcode": "8934567890123",
        "name": "Áo thun size M",
        "product_name": "Áo thun basic"
      }
    }
  ],
  "meta": {
    "page": 1,
    "page_size": 30,
    "total": 150
  }
}
```

## Understanding Report Types

### `type=actual` (Tồn kho thực tế)
- Số lượng hàng thực tế có trong kho
- Bao gồm cả hàng đang giữ cho đơn chưa hoàn thành

### `type=remain` (Có thể bán)
- Số lượng hàng có thể bán được
- Đã trừ đi số lượng đang giữ cho đơn pending

## Import/Export Sources Explained

| Field | Vietnamese | Description |
|-------|------------|-------------|
| `purchase_import` | Phiếu nhập | Nhập hàng từ nhà cung cấp |
| `return_import` | Trả hàng | Khách trả hàng |
| `stocktaking_import` | Kiểm kho (+) | Điều chỉnh tăng từ kiểm kho |
| `transfer_import` | Chuyển kho (vào) | Nhận hàng từ kho khác |
| `purchase_export` | Trả NCC | Trả hàng cho nhà cung cấp |
| `sell_export` | Bán hàng | Xuất cho đơn hàng |
| `stocktaking_export` | Kiểm kho (-) | Điều chỉnh giảm từ kiểm kho |
| `transfer_export` | Chuyển kho (ra) | Chuyển hàng sang kho khác |

## Formula

```
end_inventory = begin_inventory + total_import - total_export
```

Tương tự cho giá trị:
```
end_inventory_value = begin_inventory_value + total_import_value - total_export_value
```
