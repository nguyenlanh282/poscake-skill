# Inventory Management Module

## Data Model

```typescript
interface InventoryItem {
  id: string;
  productId: string;
  variantId?: string;
  locationId: string;
  quantity: number;
  reservedQuantity: number;   // For pending orders
  lowStockThreshold: number;
  updatedAt: Date;
}

interface StockMovement {
  id: string;
  productId: string;
  variantId?: string;
  type: MovementType;
  quantity: number;           // Positive = in, Negative = out
  referenceType: 'order' | 'import' | 'export' | 'adjustment';
  referenceId: string;
  note?: string;
  createdAt: Date;
  createdBy: string;
}

interface ImportOrder {
  id: string;
  orderNumber: string;
  supplierId: string;
  items: ImportItem[];
  status: 'pending' | 'received' | 'cancelled';
  totalCost: number;
  expectedDate?: Date;
  receivedDate?: Date;
  createdAt: Date;
}

type MovementType = 'in' | 'out' | 'adjustment' | 'transfer';
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/inventory` | List inventory levels |
| GET | `/api/inventory/low-stock` | Low stock alerts |
| POST | `/api/inventory/adjust` | Manual adjustment |
| GET | `/api/stock-movements` | Movement history |
| POST | `/api/imports` | Create import order |
| PUT | `/api/imports/:id/receive` | Receive stock |

## Components

```
components/pos/inventory/
├── StockList.tsx          # Inventory levels table
├── LowStockAlert.tsx      # Low stock warnings
├── StockAdjustment.tsx    # Manual adjustment form
├── ImportOrderForm.tsx    # Create import order
├── ReceiveStock.tsx       # Receive incoming stock
├── MovementHistory.tsx    # Stock movement log
└── StockCount.tsx         # Physical stock count
```

## Stock Operations

### Auto-deduct on Order
```typescript
async function deductStock(orderId: string, items: OrderItem[]) {
  for (const item of items) {
    await prisma.inventory.update({
      where: { productId_locationId: { productId: item.productId, locationId } },
      data: { quantity: { decrement: item.quantity } }
    });
    await createMovement({
      productId: item.productId,
      type: 'out',
      quantity: -item.quantity,
      referenceType: 'order',
      referenceId: orderId
    });
  }
}
```

### Low Stock Alert
```typescript
async function checkLowStock() {
  return prisma.inventory.findMany({
    where: {
      quantity: { lte: prisma.inventory.fields.lowStockThreshold }
    },
    include: { product: true }
  });
}
```

### Stock Import Flow
1. Create import order with supplier & items
2. Receive partial/full shipment
3. Auto-update inventory levels
4. Record cost price for FIFO/LIFO

## Batch & Expiry Tracking

```typescript
interface Batch {
  id: string;
  productId: string;
  batchNumber: string;
  quantity: number;
  costPrice: number;
  manufacturingDate?: Date;
  expiryDate?: Date;
}
```

## Inventory Reports
- Stock valuation (cost method: FIFO, LIFO, Average)
- Movement summary by period
- Expiring soon alerts
- Dead stock analysis
