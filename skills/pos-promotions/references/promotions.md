# Promotions (Khuyến mãi)

API endpoints để quản lý chương trình khuyến mãi.

## Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/shops/{SHOP_ID}/promotion_advance` | GET | Danh sách khuyến mãi |
| `/shops/{SHOP_ID}/promotion_advance` | POST | Tạo khuyến mãi |
| `/shops/{SHOP_ID}/promotion_advance/{PROMOTION_ID}` | PUT | Cập nhật khuyến mãi |
| `/shops/{SHOP_ID}/promotion_advance/delete_multi` | POST | Bulk action (activate/deactivate/delete) |
| `/shops/{SHOP_ID}/promotion_advance/create_multi` | POST | Tạo KM cho khách hàng cụ thể |

## GET /promotion_advance - Danh sách

### Query Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | integer | No | 1 | Số trang |
| `page_size` | integer | No | 10 | Kích thước trang |
| `textSearch` | string | No | - | Tìm kiếm theo tên |

### Response Schema

```typescript
interface PromotionsResponse {
  success: boolean;
  data: Promotion[];
  page_number: number;
  page_size: number;
  total_entries: number;
  total_pages: number;
}

interface Promotion {
  id: string;                     // UUID
  display_id: number;
  name: string;
  type: PromotionType;
  group_name: string;

  // Thời gian
  start_time: string;             // ISO datetime
  end_time: string;

  // Điều kiện
  warehouse_ids: string[];        // Kho áp dụng ([] = tất cả)
  customer_tags: string[];        // Tag khách hàng
  order_sources: object[];        // Nguồn đơn hàng
  type_employee: 'all' | string;
  post_ids: string[];             // Bài post áp dụng

  // Giảm giá
  coupon_info: {
    discount: number;
    is_percent: boolean;
  };
  promo_code_info: {
    discount: number;
    is_percent: boolean;
    max_discount_by_percent: number;
  };

  // Tùy chọn
  is_activated: boolean;
  is_variation: boolean;          // Áp dụng theo mẫu mã
  is_used: boolean | null;
  is_free_shipping: boolean;
  is_discount_in_birthday_customer: boolean;

  // Giảm theo số lượng/cấp độ
  discount_by_quantity: number;
  arr_level_promotion: LevelPromotion[];
  level_order_prices: LevelOrderPrice[];

  // Tặng kèm
  bonus_items: BonusItem[];
  total_quantity_bonus: number;

  // Ưu tiên
  priority_level: number | null;

  // Metadata
  shop_id: number;
  creator_id: string;
  inserted_at: string;
  updated_at: string;
}

type PromotionType =
  | 'discount_by_product'      // Giảm giá theo sản phẩm
  | 'discount_by_coupon_id'    // Giảm theo mã coupon
  | 'discount_by_quantity'     // Giảm theo số lượng mua
  | 'discount_by_order_price'  // Giảm theo giá trị đơn
  | 'bonus_product';           // Tặng kèm sản phẩm
```

### Example

```bash
# List all
bash scripts/promotions.sh list

# Search
bash scripts/promotions.sh list "?textSearch=giảm 20%"

# Pagination
bash scripts/promotions.sh list "?page=2&page_size=20"
```

## POST /promotion_advance - Tạo khuyến mãi

### Request Body

```typescript
interface CreatePromotionRequest {
  promotion_advance: {
    name: string;                 // Tên khuyến mãi (required)
    type: PromotionType;          // Loại (required)

    // Thời gian
    start_time?: number;          // Unix timestamp
    end_time?: number;

    // Điều kiện
    warehouse_ids?: string[];
    customer_tags?: string[];
    order_sources?: object[];
    group_name?: string;

    // Giảm giá
    is_activated?: boolean;
    is_variation?: boolean;
    is_free_shipping?: boolean;
    is_discount_in_birthday_customer?: boolean;

    coupon_info?: {
      discount: number;
      is_percent: boolean;
    };

    promo_code_info?: {
      discount: number;
      is_percent: boolean;
      max_discount_by_percent?: number;
    };

    // Giảm theo số lượng
    discount_by_quantity?: number;
    arr_level_promotion?: object[];

    // Tặng kèm
    bonus_items?: object[];
    total_quantity_bonus?: number;

    // Sản phẩm áp dụng
    items?: object[];

    // Ưu tiên
    priority_level?: number;
    type_employee?: string;
  };
}
```

### Example - Giảm giá 10% sản phẩm

```bash
export CONFIRM_WRITE=YES

cat <<'JSON' | bash scripts/promotions.sh create
{
  "promotion_advance": {
    "name": "Giảm 10% tất cả sản phẩm",
    "type": "discount_by_product",
    "start_time": 1704067200,
    "end_time": 1706745600,
    "is_activated": true,
    "is_variation": true,
    "warehouse_ids": [],
    "customer_tags": [],
    "coupon_info": {
      "discount": 10,
      "is_percent": true
    }
  }
}
JSON
```

### Example - Giảm giá theo mã coupon

```bash
cat <<'JSON' | bash scripts/promotions.sh create
{
  "promotion_advance": {
    "name": "Mã SALE50K",
    "type": "discount_by_coupon_id",
    "start_time": 1704067200,
    "end_time": 1706745600,
    "is_activated": true,
    "promo_code_info": {
      "discount": 50000,
      "is_percent": false
    }
  }
}
JSON
```

### Example - Giảm % theo giá trị đơn

```bash
cat <<'JSON' | bash scripts/promotions.sh create
{
  "promotion_advance": {
    "name": "Giảm 5% đơn từ 500K",
    "type": "discount_by_order_price",
    "start_time": 1704067200,
    "end_time": 1706745600,
    "is_activated": true,
    "promo_code_info": {
      "discount": 5,
      "is_percent": true,
      "max_discount_by_percent": 100000,
      "order_price_min": 500000
    }
  }
}
JSON
```

## PUT /promotion_advance/{PROMOTION_ID} - Cập nhật

### Example

```bash
export CONFIRM_WRITE=YES

cat <<'JSON' | bash scripts/promotions.sh update "260a0d45-ba88-457b-8b31-afa3fda0ce0e"
{
  "promotion_advance": {
    "name": "Giảm 15% tất cả sản phẩm",
    "is_activated": true,
    "end_time": 1709424000
  }
}
JSON
```

## POST /promotion_advance/delete_multi - Bulk Action

### Request Body

```typescript
interface BulkActionRequest {
  ids: string[];                  // Danh sách promotion IDs
  type_action: 'ACTIVE_PROMOTIONS' | 'DEACTIVE_PROMOTIONS' | 'DELETE_PROMOTIONS';
}
```

### Example - Kích hoạt

```bash
export CONFIRM_WRITE=YES

cat <<'JSON' | bash scripts/promotions.sh bulk-action
{
  "ids": ["260a0d45-ba88-457b-8b31-afa3fda0ce0e", "another-promo-id"],
  "type_action": "ACTIVE_PROMOTIONS"
}
JSON
```

### Example - Vô hiệu hóa

```bash
cat <<'JSON' | bash scripts/promotions.sh bulk-action
{
  "ids": ["260a0d45-ba88-457b-8b31-afa3fda0ce0e"],
  "type_action": "DEACTIVE_PROMOTIONS"
}
JSON
```

### Example - Xóa

```bash
cat <<'JSON' | bash scripts/promotions.sh bulk-action
{
  "ids": ["260a0d45-ba88-457b-8b31-afa3fda0ce0e"],
  "type_action": "DELETE_PROMOTIONS"
}
JSON
```

## POST /promotion_advance/create_multi - KM cho khách hàng cụ thể

Tạo mã khuyến mãi cho một nhóm khách hàng cụ thể.

### Request Body

```typescript
interface CreateForCustomersRequest {
  promotion_advance: {
    promotion: {
      type: 'discount_by_coupon_id';
      is_activated: boolean;
      start_time: string;         // ISO datetime
      end_time: string;
      warehouse_ids?: string[];
      customer_tags?: string[];
      promo_code_info: {
        discount: number;
        is_percent: boolean;
        max_discount_by_percent?: number;
        order_price_min?: number;
        order_price_max?: number;
      };
    };
    shop_customer_ids: string[];  // Danh sách customer IDs
  };
}
```

### Example

```bash
export CONFIRM_WRITE=YES

cat <<'JSON' | bash scripts/promotions.sh create-for-customers
{
  "promotion_advance": {
    "promotion": {
      "type": "discount_by_coupon_id",
      "is_activated": true,
      "start_time": "2024-01-01T00:00:00Z",
      "end_time": "2024-12-31T23:59:59Z",
      "promo_code_info": {
        "discount": 10,
        "is_percent": true,
        "max_discount_by_percent": 100000,
        "order_price_min": 500000
      }
    },
    "shop_customer_ids": [
      "customer-id-1",
      "customer-id-2"
    ]
  }
}
JSON
```

## Promotion Types Explained

| Type | Mô tả | Ví dụ |
|------|-------|-------|
| `discount_by_product` | Giảm giá trực tiếp trên sản phẩm | Giảm 20% áo thun |
| `discount_by_coupon_id` | Giảm khi nhập mã | Nhập "SALE50K" giảm 50K |
| `discount_by_quantity` | Giảm theo số lượng mua | Mua 3 giảm 10% |
| `discount_by_order_price` | Giảm theo giá trị đơn | Đơn từ 1M giảm 5% |
| `bonus_product` | Tặng kèm sản phẩm | Mua 2 tặng 1 |
