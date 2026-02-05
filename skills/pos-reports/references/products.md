# Product Analytics

## Data Models

```typescript
interface ProductAnalytics {
  period: DateRange;
  topSellers: ProductPerformance[];
  byCategory: CategoryPerformance[];
  slowMovers: ProductPerformance[];
  marginAnalysis: MarginData[];
}

interface ProductPerformance {
  productId: string;
  name: string;
  sku: string;
  category: string;
  quantitySold: number;
  revenue: number;
  profit: number;
  margin: number;        // Percentage
  avgSellingPrice: number;
  trend: 'up' | 'down' | 'stable';
}

interface CategoryPerformance {
  categoryId: string;
  name: string;
  revenue: number;
  quantity: number;
  percentage: number;    // Of total revenue
  productCount: number;
}

interface MarginData {
  productId: string;
  name: string;
  costPrice: number;
  sellingPrice: number;
  margin: number;
  marginPercent: number;
}
```

## API Implementation

```typescript
// GET /api/reports/products
export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const { start, end, limit = 10 } = Object.fromEntries(searchParams);

  // Top sellers by revenue
  const topSellers = await prisma.orderItem.groupBy({
    by: ['productId'],
    where: {
      order: {
        status: 'COMPLETED',
        createdAt: { gte: new Date(start), lte: new Date(end) }
      }
    },
    _sum: { quantity: true, total: true },
    orderBy: { _sum: { total: 'desc' } },
    take: Number(limit)
  });

  // Enrich with product details
  const enriched = await enrichProductData(topSellers);

  // Category breakdown
  const byCategory = await getCategoryBreakdown(start, end);

  // Slow movers (low sales)
  const slowMovers = await getSlowMovers(start, end, limit);

  return Response.json({ topSellers: enriched, byCategory, slowMovers });
}
```

## Top Products Chart

```tsx
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';

function TopProductsChart({ data }: { data: ProductPerformance[] }) {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <BarChart data={data} layout="vertical">
        <XAxis type="number" tickFormatter={formatCurrency} />
        <YAxis
          type="category"
          dataKey="name"
          width={150}
          tick={{ fontSize: 12 }}
        />
        <Tooltip formatter={(value: number) => formatCurrency(value)} />
        <Bar dataKey="revenue" fill="#8884d8" radius={[0, 4, 4, 0]} />
      </BarChart>
    </ResponsiveContainer>
  );
}
```

## Category Performance

```tsx
function CategoryTable({ data }: { data: CategoryPerformance[] }) {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Category</TableHead>
          <TableHead className="text-right">Revenue</TableHead>
          <TableHead className="text-right">Quantity</TableHead>
          <TableHead className="text-right">% of Total</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {data.map((cat) => (
          <TableRow key={cat.categoryId}>
            <TableCell>{cat.name}</TableCell>
            <TableCell className="text-right">{formatCurrency(cat.revenue)}</TableCell>
            <TableCell className="text-right">{cat.quantity}</TableCell>
            <TableCell className="text-right">
              <div className="flex items-center justify-end gap-2">
                <Progress value={cat.percentage} className="w-16 h-2" />
                {cat.percentage.toFixed(1)}%
              </div>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
```

## Margin Analysis

```tsx
function MarginTable({ data }: { data: MarginData[] }) {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Product</TableHead>
          <TableHead className="text-right">Cost</TableHead>
          <TableHead className="text-right">Price</TableHead>
          <TableHead className="text-right">Margin</TableHead>
          <TableHead className="text-right">Margin %</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {data.map((item) => (
          <TableRow key={item.productId}>
            <TableCell>{item.name}</TableCell>
            <TableCell className="text-right">{formatCurrency(item.costPrice)}</TableCell>
            <TableCell className="text-right">{formatCurrency(item.sellingPrice)}</TableCell>
            <TableCell className="text-right">{formatCurrency(item.margin)}</TableCell>
            <TableCell className="text-right">
              <Badge variant={item.marginPercent > 30 ? 'default' : 'destructive'}>
                {item.marginPercent.toFixed(1)}%
              </Badge>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
```

## Slow Movers Alert

```typescript
async function getSlowMovers(start: string, end: string, limit: number) {
  // Products with stock but low/no sales
  const products = await prisma.product.findMany({
    where: {
      isActive: true,
      inventory: { quantity: { gt: 0 } }
    },
    include: {
      inventory: true,
      orderItems: {
        where: {
          order: {
            createdAt: { gte: new Date(start), lte: new Date(end) }
          }
        }
      }
    }
  });

  return products
    .map(p => ({
      ...p,
      salesQty: p.orderItems.reduce((sum, i) => sum + i.quantity, 0),
      stockValue: p.inventory?.quantity * Number(p.costPrice || p.price)
    }))
    .filter(p => p.salesQty < 5)  // Less than 5 sold
    .sort((a, b) => b.stockValue - a.stockValue)
    .slice(0, limit);
}
```
