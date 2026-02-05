# Order & Payment Module

## Data Model

```typescript
interface Order {
  id: string;
  orderNumber: string;      // e.g., "ORD-20240115-001"
  customerId?: string;
  items: OrderItem[];
  subtotal: number;
  discount: number;
  tax: number;
  total: number;
  status: OrderStatus;
  paymentStatus: PaymentStatus;
  paymentMethod?: PaymentMethod;
  note?: string;
  createdAt: Date;
  createdBy: string;        // Staff ID
}

interface OrderItem {
  id: string;
  orderId: string;
  productId: string;
  variantId?: string;
  name: string;
  price: number;
  quantity: number;
  discount: number;
  total: number;
}

type OrderStatus = 'pending' | 'processing' | 'completed' | 'cancelled';
type PaymentStatus = 'unpaid' | 'partial' | 'paid' | 'refunded';
type PaymentMethod = 'cash' | 'card' | 'transfer' | 'momo' | 'vnpay';
```

## Cart Management (Zustand)

```typescript
interface CartStore {
  items: CartItem[];
  customerId?: string;
  discount: number;

  addItem: (product: Product, qty?: number) => void;
  removeItem: (productId: string) => void;
  updateQuantity: (productId: string, qty: number) => void;
  applyDiscount: (amount: number) => void;
  clearCart: () => void;

  // Computed
  subtotal: number;
  tax: number;
  total: number;
}
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/orders` | List orders (paginated) |
| GET | `/api/orders/:id` | Get order detail |
| POST | `/api/orders` | Create order |
| PUT | `/api/orders/:id/status` | Update status |
| POST | `/api/orders/:id/payment` | Process payment |
| POST | `/api/orders/:id/refund` | Refund order |

## Components

```
components/pos/orders/
├── Cart.tsx              # Shopping cart sidebar
├── CartItem.tsx          # Single cart item
├── Checkout.tsx          # Checkout flow
├── PaymentModal.tsx      # Payment processing
├── OrderList.tsx         # Order history
├── OrderDetail.tsx       # Order detail view
├── Receipt.tsx           # Printable receipt
└── QuickSale.tsx         # Quick sale numpad
```

## Payment Integration

### Cash Payment
- Calculate change amount
- Cash drawer integration

### Card Payment
- Stripe Terminal SDK
- VNPay / Momo QR

### Receipt Printing
- Use `react-to-print`
- Thermal printer support (80mm)
- Template: [assets/receipt-template.html](../assets/receipt-template.html)

## Order Number Generation

```typescript
function generateOrderNumber(): string {
  const date = format(new Date(), 'yyyyMMdd');
  const seq = await getNextSequence('order', date);
  return `ORD-${date}-${seq.toString().padStart(4, '0')}`;
}
```
