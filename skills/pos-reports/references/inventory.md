# Inventory Reports

## Data Models

```typescript
interface InventoryReport {
  summary: InventorySummary;
  stockLevels: StockLevel[];
  turnoverAnalysis: TurnoverData[];
  deadStock: DeadStockItem[];
  reorderSuggestions: ReorderItem[];
  expiringItems?: ExpiringItem[];
}

interface InventorySummary {
  totalSKUs: number;
  totalStockValue: number;
  lowStockItems: number;
  outOfStockItems: number;
  averageTurnoverRate: number;
  deadStockValue: number;
}

interface StockLevel {
  productId: string;
  name: string;
  sku: string;
  category: string;
  quantity: number;
  reservedQty: number;
  availableQty: number;
  lowStockThreshold: number;
  stockValue: number;
  status: 'in_stock' | 'low_stock' | 'out_of_stock';
}

interface TurnoverData {
  productId: string;
  name: string;
  avgStock: number;
  totalSold: number;
  turnoverRate: number;    // Times per period
  daysOfSupply: number;    // Current stock / avg daily sales
}

interface DeadStockItem {
  productId: string;
  name: string;
  quantity: number;
  stockValue: number;
  lastSoldDate: Date | null;
  daysSinceLastSale: number;
}

interface ReorderItem {
  productId: string;
  name: string;
  currentStock: number;
  avgDailySales: number;
  reorderPoint: number;
  suggestedQty: number;
  leadTimeDays: number;
}
```

## API Implementation

```typescript
// GET /api/reports/inventory
export async function GET(req: Request) {
  const inventory = await prisma.inventory.findMany({
    include: { product: { include: { category: true } } }
  });

  // Calculate stock levels
  const stockLevels = inventory.map(inv => ({
    productId: inv.productId,
    name: inv.product.name,
    sku: inv.product.sku,
    category: inv.product.category.name,
    quantity: inv.quantity,
    reservedQty: inv.reservedQty,
    availableQty: inv.quantity - inv.reservedQty,
    lowStockThreshold: inv.lowStockThreshold,
    stockValue: inv.quantity * Number(inv.product.costPrice || inv.product.price),
    status: getStockStatus(inv)
  }));

  // Summary
  const summary = {
    totalSKUs: stockLevels.length,
    totalStockValue: stockLevels.reduce((sum, s) => sum + s.stockValue, 0),
    lowStockItems: stockLevels.filter(s => s.status === 'low_stock').length,
    outOfStockItems: stockLevels.filter(s => s.status === 'out_of_stock').length
  };

  // Turnover analysis (last 30 days)
  const turnover = await calculateTurnover(30);

  // Dead stock (no sales > 30 days)
  const deadStock = await getDeadStock(30);

  // Reorder suggestions
  const reorder = getReorderSuggestions(stockLevels, turnover);

  return Response.json({ summary, stockLevels, turnover, deadStock, reorder });
}
```

## Stock Status Chart

```tsx
import { PieChart, Pie, Cell, ResponsiveContainer, Legend } from 'recharts';

function StockStatusChart({ data }: { data: InventorySummary }) {
  const chartData = [
    { name: 'In Stock', value: data.totalSKUs - data.lowStockItems - data.outOfStockItems, color: '#22c55e' },
    { name: 'Low Stock', value: data.lowStockItems, color: '#f59e0b' },
    { name: 'Out of Stock', value: data.outOfStockItems, color: '#ef4444' }
  ];

  return (
    <ResponsiveContainer width="100%" height={200}>
      <PieChart>
        <Pie
          data={chartData}
          cx="50%"
          cy="50%"
          innerRadius={50}
          outerRadius={70}
          dataKey="value"
        >
          {chartData.map((entry, index) => (
            <Cell key={index} fill={entry.color} />
          ))}
        </Pie>
        <Legend />
      </PieChart>
    </ResponsiveContainer>
  );
}
```

## Turnover Rate Table

```tsx
function TurnoverTable({ data }: { data: TurnoverData[] }) {
  const getTurnoverColor = (rate: number) => {
    if (rate >= 4) return 'text-green-600';  // Excellent
    if (rate >= 2) return 'text-blue-600';   // Good
    if (rate >= 1) return 'text-yellow-600'; // Average
    return 'text-red-600';                    // Poor
  };

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Product</TableHead>
          <TableHead className="text-right">Avg Stock</TableHead>
          <TableHead className="text-right">Sold</TableHead>
          <TableHead className="text-right">Turnover</TableHead>
          <TableHead className="text-right">Days of Supply</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {data.map((item) => (
          <TableRow key={item.productId}>
            <TableCell>{item.name}</TableCell>
            <TableCell className="text-right">{item.avgStock}</TableCell>
            <TableCell className="text-right">{item.totalSold}</TableCell>
            <TableCell className={cn('text-right font-medium', getTurnoverColor(item.turnoverRate))}>
              {item.turnoverRate.toFixed(2)}x
            </TableCell>
            <TableCell className="text-right">
              {item.daysOfSupply === Infinity ? '∞' : `${item.daysOfSupply} days`}
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
```

## Dead Stock Alert

```tsx
function DeadStockTable({ data }: { data: DeadStockItem[] }) {
  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2 text-amber-600">
        <AlertTriangle size={20} />
        <span className="font-medium">
          {data.length} items with no sales in 30+ days
        </span>
      </div>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Product</TableHead>
            <TableHead className="text-right">Quantity</TableHead>
            <TableHead className="text-right">Stock Value</TableHead>
            <TableHead className="text-right">Days Since Sale</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {data.map((item) => (
            <TableRow key={item.productId}>
              <TableCell>{item.name}</TableCell>
              <TableCell className="text-right">{item.quantity}</TableCell>
              <TableCell className="text-right">{formatCurrency(item.stockValue)}</TableCell>
              <TableCell className="text-right">
                <Badge variant="destructive">{item.daysSinceLastSale} days</Badge>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
```

## Reorder Suggestions

```typescript
function getReorderSuggestions(
  stockLevels: StockLevel[],
  turnover: TurnoverData[]
): ReorderItem[] {
  const LEAD_TIME_DAYS = 7;
  const SAFETY_STOCK_DAYS = 3;

  return stockLevels
    .map(stock => {
      const turn = turnover.find(t => t.productId === stock.productId);
      const avgDailySales = turn ? turn.totalSold / 30 : 0;
      const reorderPoint = avgDailySales * (LEAD_TIME_DAYS + SAFETY_STOCK_DAYS);
      const suggestedQty = Math.ceil(avgDailySales * 30);  // 30 days supply

      return {
        productId: stock.productId,
        name: stock.name,
        currentStock: stock.availableQty,
        avgDailySales,
        reorderPoint: Math.ceil(reorderPoint),
        suggestedQty,
        leadTimeDays: LEAD_TIME_DAYS,
        shouldReorder: stock.availableQty <= reorderPoint
      };
    })
    .filter(item => item.shouldReorder)
    .sort((a, b) => a.currentStock / a.reorderPoint - b.currentStock / b.reorderPoint);
}
```
