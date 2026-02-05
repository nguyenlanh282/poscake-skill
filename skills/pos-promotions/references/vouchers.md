# Vouchers (Mã giảm giá)

API endpoints để quản lý voucher/mã giảm giá.

## Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/shops/{SHOP_ID}/vouchers` | GET | Danh sách voucher |
| `/shops/{SHOP_ID}/vouchers` | POST | Tạo voucher |
| `/shops/{SHOP_ID}/vouchers/{VOUCHER_ID}` | GET | Chi tiết voucher |
| `/shops/{SHOP_ID}/vouchers/create_multi` | POST | Tạo nhiều voucher |

## GET /vouchers - Danh sách

### Response Schema

```typescript
interface VouchersResponse {
  success: boolean;
  data: Voucher[];
}

interface Voucher {
  id: string;                     // UUID
  display_id: number;
  name: string;                   // Mã voucher (code khách nhập)
  type: 'discount_by_coupon_id';

  // Thời gian
  start_time: string;             // ISO datetime
  end_time: string;

  // Giảm giá
  promo_code_info: {
    discount: number;             // Số tiền/phần trăm giảm
    is_percent: boolean;          // true = %, false = VND
    max_discount_by_percent: number; // Giảm tối đa khi là %
  };

  // Điều kiện
  customer_tags: string[];        // Tag khách hàng được dùng
  is_free_shipping: boolean;
  is_activated: boolean;
  is_used: boolean | null;

  // Metadata
  shop_id: number;
  creator_id: string;
  inserted_at: string;
  updated_at: string;
}
```

### Example

```bash
bash scripts/promotions.sh vouchers
```

### Response Example

```json
{
  "success": true,
  "data": [
    {
      "id": "9589b791-013f-4a5b-b8d1-164fad73d84e",
      "display_id": 7,
      "name": "SUMMER2024",
      "type": "discount_by_coupon_id",
      "start_time": "2024-01-01T00:00:00Z",
      "end_time": "2024-12-31T23:59:59Z",
      "promo_code_info": {
        "discount": 50000,
        "is_percent": false,
        "max_discount_by_percent": 0
      },
      "is_free_shipping": false,
      "is_activated": true,
      "is_used": null,
      "customer_tags": ["VIP", "Tiềm năng"],
      "shop_id": 3,
      "creator_id": "d6e6a545-f102-439e-9943-8ac8369f9735",
      "inserted_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

## GET /vouchers/{VOUCHER_ID} - Chi tiết

### Example

```bash
bash scripts/promotions.sh voucher "9589b791-013f-4a5b-b8d1-164fad73d84e"
```

## POST /vouchers - Tạo voucher

### Request Body

```typescript
interface CreateVoucherRequest {
  name: string;                   // Mã voucher (required)
  promo_code_info: {              // (required)
    discount: number;
    is_percent: boolean;
    max_discount_by_percent?: number;
  };
  start_time: string;             // ISO datetime (required)
  end_time: string;               // ISO datetime (required)

  // Optional
  is_free_shipping?: boolean;
  is_activated?: boolean;
  customer_tags?: string[];
}
```

### Example - Voucher giảm cố định

```bash
export CONFIRM_WRITE=YES

cat <<'JSON' | bash scripts/promotions.sh create-voucher
{
  "name": "GIAM50K",
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
```

### Example - Voucher giảm %

```bash
cat <<'JSON' | bash scripts/promotions.sh create-voucher
{
  "name": "GIAM10PCT",
  "promo_code_info": {
    "discount": 10,
    "is_percent": true,
    "max_discount_by_percent": 100000
  },
  "is_free_shipping": false,
  "is_activated": true,
  "customer_tags": ["VIP"],
  "start_time": "2024-01-01T00:00:00",
  "end_time": "2024-12-31T23:59:59"
}
JSON
```

### Example - Voucher freeship

```bash
cat <<'JSON' | bash scripts/promotions.sh create-voucher
{
  "name": "FREESHIP",
  "promo_code_info": {
    "discount": 0,
    "is_percent": false
  },
  "is_free_shipping": true,
  "is_activated": true,
  "customer_tags": [],
  "start_time": "2024-01-01T00:00:00",
  "end_time": "2024-12-31T23:59:59"
}
JSON
```

## POST /vouchers/create_multi - Tạo nhiều voucher

Tạo nhiều voucher cùng lúc với prefix chung.

### Request Body

```typescript
interface CreateMultiVouchersRequest {
  vouchers: {
    prefix: string;               // Prefix của mã (VD: "SUMMER" → SUMMER001, SUMMER002)
    quantity: number;             // Số lượng voucher tạo
    promo_code_info: {
      discount: number;
      is_percent: boolean;
      max_discount_by_percent?: number;
    };
    start_time: string;
    end_time: string;
    is_free_shipping?: boolean;
    is_activated?: boolean;
    customer_tags?: string[];
  };
}
```

### Example

```bash
export CONFIRM_WRITE=YES

cat <<'JSON' | bash scripts/promotions.sh create-vouchers
{
  "vouchers": {
    "prefix": "SUMMER",
    "quantity": 100,
    "promo_code_info": {
      "discount": 30000,
      "is_percent": false
    },
    "start_time": "2024-06-01T00:00:00",
    "end_time": "2024-08-31T23:59:59",
    "is_free_shipping": false,
    "is_activated": true,
    "customer_tags": []
  }
}
JSON
```

Kết quả: Tạo 100 voucher với mã SUMMER001, SUMMER002, ..., SUMMER100

## cURL Examples

### List vouchers

```bash
curl -X GET "https://pos.pages.fm/api/v1/shops/${SHOP_ID}/vouchers?api_key=${POS_API_KEY}" \
  -H "Content-Type: application/json"
```

### Create voucher

```bash
curl -X POST "https://pos.pages.fm/api/v1/shops/${SHOP_ID}/vouchers?api_key=${POS_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "NEWVOUCHER",
    "promo_code_info": {
      "discount": 25000,
      "is_percent": false
    },
    "start_time": "2024-01-01T00:00:00",
    "end_time": "2024-12-31T23:59:59",
    "is_activated": true
  }'
```

## Voucher vs Promotion

| Aspect | Voucher | Promotion |
|--------|---------|-----------|
| Activation | Khách nhập mã | Tự động áp dụng |
| Scope | Per-code (1 mã = 1 lần dùng) | Global (áp dụng cho tất cả) |
| Use case | Flash sale, tặng khách | Khuyến mãi dài hạn |
| Tracking | Theo dõi từng mã | Theo dõi chung |

## Best Practices

1. **Đặt tên mã dễ nhớ**: SUMMER2024, GIAM50K, FREESHIP
2. **Giới hạn thời gian**: Luôn set end_time để tránh lạm dụng
3. **Customer tags**: Giới hạn cho nhóm khách cụ thể nếu cần
4. **Max discount**: Với voucher %, luôn set max_discount_by_percent
5. **Bulk create**: Dùng create_multi cho chiến dịch lớn
