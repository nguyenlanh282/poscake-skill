# Revenue Reports

## Data Models

```typescript
interface RevenueReport {
  period: DateRange;
  summary: RevenueSummary;
  daily: DailyRevenue[];
  byPaymentMethod: PaymentBreakdown[];
  byHour: HourlyRevenue[];
  comparison?: PeriodComparison;
}

interface RevenueSummary {
  totalRevenue: number;
  totalOrders: number;
  averageOrderValue: number;
  totalItems: number;
  grossProfit: number;
  profitMargin: number;
}

interface DailyRevenue {
  date: string;
  revenue: number;
  orders: number;
  items: number;
  avgOrderValue: number;
}

interface PeriodComparison {
  current: RevenueSummary;
  previous: RevenueSummary;
  changes: {
    revenue: number;      // Percentage
    orders: number;
    avgOrderValue: number;
  };
}
```

## API Implementation

```typescript
// GET /api/reports/revenue
export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const startDate = searchParams.get('start');
  const endDate = searchParams.get('end');
  const compare = searchParams.get('compare') === 'true';

  const orders = await prisma.order.findMany({
    where: {
      status: 'COMPLETED',
      createdAt: { gte: new Date(startDate), lte: new Date(endDate) }
    },
    include: { items: true }
  });

  const summary = calculateSummary(orders);
  const daily = groupByDay(orders);
  const byPaymentMethod = groupByPaymentMethod(orders);
  const byHour = groupByHour(orders);

  let comparison;
  if (compare) {
    const prevPeriod = getPreviousPeriod(startDate, endDate);
    const prevOrders = await prisma.order.findMany({
      where: {
        status: 'COMPLETED',
        createdAt: { gte: prevPeriod.start, lte: prevPeriod.end }
      }
    });
    comparison = calculateComparison(summary, calculateSummary(prevOrders));
  }

  return Response.json({ summary, daily, byPaymentMethod, byHour, comparison });
}
```

## Revenue Chart Component

```tsx
import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';

function RevenueChart({ data }: { data: DailyRevenue[] }) {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <AreaChart data={data}>
        <defs>
          <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%" stopColor="#8884d8" stopOpacity={0.8}/>
            <stop offset="95%" stopColor="#8884d8" stopOpacity={0}/>
          </linearGradient>
        </defs>
        <XAxis dataKey="date" tickFormatter={formatDate} />
        <YAxis tickFormatter={formatCurrency} />
        <Tooltip
          formatter={(value: number) => formatCurrency(value)}
          labelFormatter={formatDate}
        />
        <Area
          type="monotone"
          dataKey="revenue"
          stroke="#8884d8"
          fillOpacity={1}
          fill="url(#colorRevenue)"
        />
      </AreaChart>
    </ResponsiveContainer>
  );
}
```

## Metric Card with Trend

```tsx
interface MetricCardProps {
  title: string;
  value: number;
  change?: number;  // Percentage change
  format?: 'currency' | 'number' | 'percent';
}

function MetricCard({ title, value, change, format = 'number' }: MetricCardProps) {
  const formattedValue = formatValue(value, format);
  const isPositive = change && change > 0;

  return (
    <Card>
      <CardHeader className="pb-2">
        <CardTitle className="text-sm text-muted-foreground">{title}</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">{formattedValue}</div>
        {change !== undefined && (
          <div className={cn(
            "text-sm flex items-center gap-1",
            isPositive ? "text-green-600" : "text-red-600"
          )}>
            {isPositive ? <TrendingUp size={16} /> : <TrendingDown size={16} />}
            {Math.abs(change).toFixed(1)}% vs last period
          </div>
        )}
      </CardContent>
    </Card>
  );
}
```

## Payment Method Breakdown

```tsx
import { PieChart, Pie, Cell, Legend, ResponsiveContainer } from 'recharts';

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8'];

function PaymentBreakdown({ data }: { data: PaymentBreakdown[] }) {
  return (
    <ResponsiveContainer width="100%" height={250}>
      <PieChart>
        <Pie
          data={data}
          cx="50%"
          cy="50%"
          innerRadius={60}
          outerRadius={80}
          dataKey="amount"
          nameKey="method"
          label={({ percent }) => `${(percent * 100).toFixed(0)}%`}
        >
          {data.map((_, index) => (
            <Cell key={index} fill={COLORS[index % COLORS.length]} />
          ))}
        </Pie>
        <Legend />
      </PieChart>
    </ResponsiveContainer>
  );
}
```
