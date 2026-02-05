# Inventory Histories (Lịch sử xuất nhập kho)

API endpoint để truy vấn lịch sử xuất nhập kho của shop.

## Endpoint

```
GET /shops/{SHOP_ID}/inventory_histories
```

## Query Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | integer | Yes | 1 | Số trang hiện tại |
| `page_size` | integer | Yes | 30 | Số record mỗi trang |
| `warehouse_id` | string (UUID) | No | - | Lọc theo ID kho cụ thể |
| `variation_ids[]` | array | No | - | Lọc theo danh sách mã mẫu mã |
| `startDate` | integer | No | - | Unix timestamp bắt đầu |
| `endDate` | integer | No | - | Unix timestamp kết thúc |

## Response Schema

```typescript
interface InventoryHistoriesResponse {
  data: InventoryHistoryEntry[];
  meta: {
    page: number;
    page_size: number;
    total: number;
    total_pages: number;
  };
}

interface InventoryHistoryEntry {
  id: number;
  avg_price: number;              // Giá nhập trung bình
  editor_id: string;              // ID người thực hiện
  inserted_at: string;            // ISO 8601 datetime

  current_inventory: Array<{
    id: string;                   // Warehouse ID
    name: string;                 // Warehouse name
    remain_quantity: number;      // Số lượng tồn (có thể bán)
    actual_remain_quantity: number; // Số lượng tồn thực tế
    total_quantity: number;       // Tổng số lượng
    avg_price: number;            // Giá trung bình
  }>;

  warehouse: {
    id: string;
    name: string;
  };

  variation: {
    id: string;
    product_id: string;
    custom_id: string;
    barcode: string | null;
    name: string;
  };

  // Thông tin thay đổi
  quantity_change: number;        // Số lượng thay đổi (+/-)
  type: 'import' | 'export';      // Loại: nhập/xuất
  source_type: string;            // Nguồn: order, stocktake, transfer, purchase
  source_id: string;              // ID nguồn
}
```

## Examples

### Lấy lịch sử cơ bản

```bash
export POS_API_KEY="your-api-key"
export SHOP_ID="123"

bash scripts/inventory.sh histories "?page=1&page_size=30"
```

### Lọc theo kho

```bash
bash scripts/inventory.sh histories "?warehouse_id=b4cb5897-6e56-4581-96cc-2f12677c7bd8"
```

### Lọc theo mẫu mã

```bash
bash scripts/inventory.sh histories "?variation_ids[]=415040f4-ab63-465e-8699-e9ebfff4c6c7"
```

### Lọc theo khoảng thời gian

```bash
# Lấy lịch sử tháng 1/2024
# startDate: 2024-01-01 00:00:00 UTC = 1704067200
# endDate: 2024-01-31 23:59:59 UTC = 1706745599

bash scripts/inventory.sh histories "?startDate=1704067200&endDate=1706745599"
```

### Kết hợp nhiều filter

```bash
bash scripts/inventory.sh histories "?warehouse_id=abc123&startDate=1704067200&endDate=1706745599&page=1&page_size=50"
```

## cURL Example

```bash
curl -X GET "https://pos.pages.fm/api/v1/shops/${SHOP_ID}/inventory_histories?page=1&page_size=30&api_key=${POS_API_KEY}" \
  -H "Content-Type: application/json"
```

## Response Example

```json
{
  "data": [
    {
      "id": 12345,
      "avg_price": 150000,
      "editor_id": "user-uuid-here",
      "inserted_at": "2024-01-15T10:30:00Z",
      "current_inventory": [
        {
          "id": "b4cb5897-6e56-4581-96cc-2f12677c7bd8",
          "name": "Kho HN",
          "remain_quantity": 100,
          "actual_remain_quantity": 100,
          "total_quantity": 150,
          "avg_price": 150000
        }
      ],
      "warehouse": {
        "id": "b4cb5897-6e56-4581-96cc-2f12677c7bd8",
        "name": "Kho HN"
      },
      "variation": {
        "id": "415040f4-ab63-465e-8699-e9ebfff4c6c7",
        "product_id": "prod-uuid",
        "custom_id": "SKU001",
        "barcode": "8934567890123",
        "name": "Áo thun size M"
      },
      "quantity_change": 50,
      "type": "import",
      "source_type": "purchase",
      "source_id": "purchase-uuid"
    }
  ],
  "meta": {
    "page": 1,
    "page_size": 30,
    "total": 150,
    "total_pages": 5
  }
}
```

## Notes

- `remain_quantity` là số lượng có thể bán (trừ đi số đang giữ cho đơn chưa hoàn thành)
- `actual_remain_quantity` là số lượng thực tế trong kho
- `source_type` có thể là:
  - `order`: Xuất từ đơn hàng
  - `purchase`: Nhập từ phiếu nhập hàng
  - `stocktake`: Điều chỉnh từ kiểm kho
  - `transfer`: Chuyển kho
  - `return`: Trả hàng từ khách
