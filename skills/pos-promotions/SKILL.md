---
name: pos-promotions
description: |
  Promotion and voucher management for Pancake POS. Create and manage promotions
  (discounts, bonus items, tiered pricing), vouchers/coupons, customer-specific offers,
  and bulk promotion operations. Use when working with discounts, promotions, vouchers,
  coupons, sales campaigns, or customer loyalty rewards.
version: 1.0.0
allowed-tools: Bash(curl *), Bash(python *), Bash(jq *)
---

# pos-promotions

Quản lý khuyến mãi và mã giảm giá: chương trình KM, voucher, coupon, ưu đãi theo khách hàng.

## Tính năng

### 1. Chương trình khuyến mãi (Promotions)
Reference: [references/promotions.md](references/promotions.md)
- Danh sách khuyến mãi
- Tạo, cập nhật, xóa khuyến mãi
- Các loại: giảm giá theo sản phẩm, theo số lượng, tặng kèm, miễn phí ship
- Điều kiện: theo kho, theo tag khách hàng, theo nguồn đơn

### 2. Mã giảm giá / Voucher
Reference: [references/vouchers.md](references/vouchers.md)
- Danh sách voucher
- Tạo voucher đơn lẻ hoặc hàng loạt
- Giảm giá cố định hoặc theo phần trăm
- Điều kiện theo tag khách hàng

### 3. Khuyến mãi theo khách hàng
- Tạo ưu đãi cho nhóm khách hàng cụ thể
- Áp dụng cho sinh nhật khách hàng

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

Script: `scripts/promotions.sh`

### Khuyến mãi

```bash
# Danh sách khuyến mãi
bash scripts/promotions.sh list

# Tìm kiếm
bash scripts/promotions.sh list "?textSearch=giảm 20%"

# Tạo khuyến mãi (cần CONFIRM_WRITE=YES)
export CONFIRM_WRITE=YES
cat promotion.json | bash scripts/promotions.sh create

# Cập nhật khuyến mãi
cat update.json | bash scripts/promotions.sh update "PROMOTION_ID"

# Kích hoạt/Vô hiệu hóa/Xóa nhiều khuyến mãi
cat <<'JSON' | bash scripts/promotions.sh bulk-action
{
  "ids": ["promo-id-1", "promo-id-2"],
  "type_action": "ACTIVE_PROMOTIONS"
}
JSON
```

### Voucher

```bash
# Danh sách voucher
bash scripts/promotions.sh vouchers

# Chi tiết voucher
bash scripts/promotions.sh voucher "VOUCHER_ID"

# Tạo voucher
export CONFIRM_WRITE=YES
cat voucher.json | bash scripts/promotions.sh create-voucher

# Tạo nhiều voucher
cat vouchers.json | bash scripts/promotions.sh create-vouchers
```

## Guardrails

- Không ghi dữ liệu khi chưa set `CONFIRM_WRITE=YES`
- Với thao tác ghi: luôn chạy 1 lệnh GET trước để xác nhận ID/shape dữ liệu
- Không lưu API key vào repo
- Kiểm tra thời gian start_time/end_time trước khi tạo

## Data Models

### Promotion (Khuyến mãi)

```typescript
interface Promotion {
  id: string;                     // UUID
  display_id: number;             // Mã hiển thị
  name: string;                   // Tên khuyến mãi
  type: PromotionType;            // Loại khuyến mãi
  group_name: string;             // Nhóm khuyến mãi

  // Thời gian
  start_time: string;             // ISO datetime
  end_time: string;               // ISO datetime

  // Điều kiện áp dụng
  warehouse_ids: string[];        // Kho áp dụng (rỗng = tất cả)
  customer_tags: string[];        // Tag khách hàng
  order_sources: object[];        // Nguồn đơn hàng
  type_employee: 'all' | string;  // Nhân viên áp dụng

  // Cấu hình giảm giá
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
  is_activated: boolean;          // Đang kích hoạt
  is_variation: boolean;          // Áp dụng theo mẫu mã
  is_free_shipping: boolean;      // Miễn phí ship
  is_discount_in_birthday_customer: boolean;

  // Giảm theo số lượng
  discount_by_quantity: number;
  arr_level_promotion: object[];  // Các mức giảm giá

  // Tặng kèm
  bonus_items: object[];
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
  | 'discount_by_coupon_id'    // Giảm giá theo mã coupon
  | 'discount_by_quantity'     // Giảm giá theo số lượng
  | 'discount_by_order_price'  // Giảm giá theo giá trị đơn
  | 'bonus_product';           // Tặng kèm sản phẩm
```

### Voucher (Mã giảm giá)

```typescript
interface Voucher {
  id: string;                     // UUID
  display_id: number;
  name: string;                   // Mã voucher (code)
  type: 'discount_by_coupon_id';

  // Thời gian
  start_time: string;             // ISO datetime
  end_time: string;               // ISO datetime

  // Giảm giá
  promo_code_info: {
    discount: number;
    is_percent: boolean;
    max_discount_by_percent: number;
  };

  // Điều kiện
  customer_tags: string[];        // Tag khách hàng áp dụng
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

## Endpoint thuộc skill này

| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `/shops/{SHOP_ID}/promotion_advance` | GET | Danh sách khuyến mãi |
| `/shops/{SHOP_ID}/promotion_advance` | POST | Tạo khuyến mãi |
| `/shops/{SHOP_ID}/promotion_advance/{PROMOTION_ID}` | PUT | Cập nhật khuyến mãi |
| `/shops/{SHOP_ID}/promotion_advance/delete_multi` | POST | Kích hoạt/Vô hiệu hóa/Xóa nhiều |
| `/shops/{SHOP_ID}/promotion_advance/create_multi` | POST | Tạo KM cho khách hàng cụ thể |
| `/shops/{SHOP_ID}/vouchers` | GET | Danh sách voucher |
| `/shops/{SHOP_ID}/vouchers` | POST | Tạo voucher |
| `/shops/{SHOP_ID}/vouchers/{VOUCHER_ID}` | GET | Chi tiết voucher |
| `/shops/{SHOP_ID}/vouchers/create_multi` | POST | Tạo nhiều voucher |

## Query Parameters

### promotion_advance (GET)

| Param | Type | Required | Mô tả |
|-------|------|----------|-------|
| page | integer | No | Số trang (default: 1) |
| page_size | integer | No | Kích thước trang (default: 10) |
| textSearch | string | No | Tìm kiếm theo tên |

## Bulk Action Types

| Action | Mô tả |
|--------|-------|
| `ACTIVE_PROMOTIONS` | Kích hoạt khuyến mãi |
| `DEACTIVE_PROMOTIONS` | Vô hiệu hóa khuyến mãi |
| `DELETE_PROMOTIONS` | Xóa khuyến mãi |

## Tham chiếu

- OpenAPI spec: `openapi-pos.json` (ở root bundle)
- Related skills: `pos-products`, `pos-customers`, `pos-orders`
