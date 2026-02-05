# Customer Analytics

## Data Models

```typescript
interface CustomerAnalytics {
  period: DateRange;
  summary: CustomerSummary;
  newVsReturning: NewVsReturning;
  topCustomers: CustomerData[];
  rfmSegments: RFMSegment[];
  retentionCohorts: RetentionCohort[];
}

interface CustomerSummary {
  totalCustomers: number;
  newCustomers: number;
  returningCustomers: number;
  averageOrdersPerCustomer: number;
  averageLifetimeValue: number;
  retentionRate: number;
}

interface NewVsReturning {
  new: { count: number; revenue: number; percentage: number };
  returning: { count: number; revenue: number; percentage: number };
}

interface CustomerData {
  customerId: string;
  name: string;
  totalOrders: number;
  totalSpent: number;
  averageOrderValue: number;
  lastOrderDate: Date;
  segment: string;
}

// RFM: Recency, Frequency, Monetary
interface RFMSegment {
  segment: string;        // Champions, Loyal, At Risk, Lost...
  count: number;
  percentage: number;
  avgRecency: number;     // Days since last order
  avgFrequency: number;   // Orders count
  avgMonetary: number;    // Total spent
}

interface RetentionCohort {
  cohort: string;         // e.g., "2024-01"
  month0: number;         // 100%
  month1: number;         // % retained
  month2: number;
  month3: number;
}
```

## RFM Segmentation

```typescript
function calculateRFM(customers: CustomerWithOrders[]): RFMSegment[] {
  const now = new Date();

  const rfmData = customers.map(c => {
    const orders = c.orders.filter(o => o.status === 'COMPLETED');
    const lastOrder = orders[0]?.createdAt;
    const recency = lastOrder ? daysDiff(now, lastOrder) : 999;
    const frequency = orders.length;
    const monetary = orders.reduce((sum, o) => sum + Number(o.total), 0);

    return { customerId: c.id, recency, frequency, monetary };
  });

  // Score 1-5 for each dimension
  const scored = rfmData.map(r => ({
    ...r,
    rScore: scoreRecency(r.recency),
    fScore: scoreFrequency(r.frequency),
    mScore: scoreMonetary(r.monetary)
  }));

  // Assign segments
  return scored.map(s => ({
    ...s,
    segment: assignSegment(s.rScore, s.fScore, s.mScore)
  }));
}

function assignSegment(r: number, f: number, m: number): string {
  const score = r * 100 + f * 10 + m;

  if (r >= 4 && f >= 4 && m >= 4) return 'Champions';
  if (r >= 3 && f >= 3 && m >= 3) return 'Loyal Customers';
  if (r >= 4 && f <= 2) return 'New Customers';
  if (r >= 3 && f >= 3 && m <= 2) return 'Potential Loyalists';
  if (r <= 2 && f >= 3) return 'At Risk';
  if (r <= 2 && f <= 2) return 'Lost';
  return 'Others';
}
```

## Customer Segments Chart

```tsx
import { Treemap, ResponsiveContainer, Tooltip } from 'recharts';

const SEGMENT_COLORS = {
  'Champions': '#22c55e',
  'Loyal Customers': '#3b82f6',
  'Potential Loyalists': '#8b5cf6',
  'New Customers': '#06b6d4',
  'At Risk': '#f59e0b',
  'Lost': '#ef4444',
  'Others': '#6b7280'
};

function RFMTreemap({ data }: { data: RFMSegment[] }) {
  const treeData = data.map(s => ({
    name: s.segment,
    size: s.count,
    fill: SEGMENT_COLORS[s.segment]
  }));

  return (
    <ResponsiveContainer width="100%" height={300}>
      <Treemap
        data={treeData}
        dataKey="size"
        nameKey="name"
        stroke="#fff"
        fill="#8884d8"
      >
        <Tooltip
          formatter={(value: number, name: string) => [
            `${value} customers`,
            name
          ]}
        />
      </Treemap>
    </ResponsiveContainer>
  );
}
```

## Retention Cohort Table

```tsx
function RetentionTable({ data }: { data: RetentionCohort[] }) {
  const getColor = (value: number) => {
    if (value >= 50) return 'bg-green-500';
    if (value >= 30) return 'bg-green-300';
    if (value >= 15) return 'bg-yellow-300';
    return 'bg-red-300';
  };

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Cohort</TableHead>
          <TableHead>Month 0</TableHead>
          <TableHead>Month 1</TableHead>
          <TableHead>Month 2</TableHead>
          <TableHead>Month 3</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {data.map((cohort) => (
          <TableRow key={cohort.cohort}>
            <TableCell className="font-medium">{cohort.cohort}</TableCell>
            <TableCell className={cn('text-center', getColor(cohort.month0))}>
              {cohort.month0}%
            </TableCell>
            <TableCell className={cn('text-center', getColor(cohort.month1))}>
              {cohort.month1}%
            </TableCell>
            <TableCell className={cn('text-center', getColor(cohort.month2))}>
              {cohort.month2}%
            </TableCell>
            <TableCell className={cn('text-center', getColor(cohort.month3))}>
              {cohort.month3}%
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
```

## Top Customers

```tsx
function TopCustomersTable({ data }: { data: CustomerData[] }) {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Customer</TableHead>
          <TableHead className="text-right">Orders</TableHead>
          <TableHead className="text-right">Total Spent</TableHead>
          <TableHead className="text-right">AOV</TableHead>
          <TableHead>Segment</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {data.map((c) => (
          <TableRow key={c.customerId}>
            <TableCell>{c.name}</TableCell>
            <TableCell className="text-right">{c.totalOrders}</TableCell>
            <TableCell className="text-right">{formatCurrency(c.totalSpent)}</TableCell>
            <TableCell className="text-right">{formatCurrency(c.averageOrderValue)}</TableCell>
            <TableCell>
              <Badge style={{ background: SEGMENT_COLORS[c.segment] }}>
                {c.segment}
              </Badge>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
```
