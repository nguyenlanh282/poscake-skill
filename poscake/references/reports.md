# Reports & Analytics Module

## Data Models

```typescript
interface SalesReport {
  period: { start: Date; end: Date };
  totalRevenue: number;
  totalOrders: number;
  averageOrderValue: number;
  totalItems: number;
  topProducts: ProductSales[];
  salesByCategory: CategorySales[];
  salesByPaymentMethod: PaymentMethodSales[];
  salesByHour: HourlySales[];
}

interface DashboardMetrics {
  today: DailyMetrics;
  yesterday: DailyMetrics;
  thisWeek: WeeklyMetrics;
  thisMonth: MonthlyMetrics;
}

interface DailyMetrics {
  revenue: number;
  orders: number;
  customers: number;
  averageOrderValue: number;
  comparedToYesterday: number;  // Percentage change
}
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/reports/dashboard` | Dashboard metrics |
| GET | `/api/reports/sales` | Sales report |
| GET | `/api/reports/products` | Product performance |
| GET | `/api/reports/inventory` | Inventory report |
| GET | `/api/reports/staff` | Staff performance |
| GET | `/api/reports/export` | Export to Excel/PDF |

## Components

```
components/pos/reports/
├── Dashboard.tsx          # Main dashboard
├── MetricCard.tsx         # Single metric display
├── SalesChart.tsx         # Revenue/orders chart
├── TopProducts.tsx        # Best selling products
├── SalesByCategory.tsx    # Category breakdown
├── DateRangePicker.tsx    # Report period selector
├── ReportTable.tsx        # Tabular data
└── ExportButton.tsx       # Export functionality
```

## Charts (Recharts)

```tsx
import { LineChart, BarChart, PieChart } from 'recharts';

// Revenue trend
<LineChart data={dailyRevenue}>
  <XAxis dataKey="date" />
  <YAxis />
  <Line dataKey="revenue" stroke="#8884d8" />
</LineChart>

// Sales by category
<PieChart>
  <Pie data={categoryData} dataKey="value" nameKey="name" />
</PieChart>
```

## Key Reports

### Daily Sales Summary
- Total revenue, orders, items sold
- Payment method breakdown
- Hourly sales distribution
- Compare to previous day

### Product Performance
- Top selling products (by quantity, revenue)
- Slow-moving products
- Margin analysis
- Category performance

### Inventory Reports
- Current stock value
- Low stock items
- Stock turnover rate
- Dead stock (no sales > 30 days)

### Staff Performance
- Sales by staff member
- Orders processed
- Average transaction value

## Export Options

### Excel Export
```typescript
import * as XLSX from 'xlsx';

function exportToExcel(data: any[], filename: string) {
  const ws = XLSX.utils.json_to_sheet(data);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Report');
  XLSX.writeFile(wb, `${filename}.xlsx`);
}
```

### PDF Export
- Use `react-pdf` or `jspdf`
- Include charts as images
- Company branding/header

## Real-time Dashboard

```typescript
// Use React Query with refetch interval
const { data: metrics } = useQuery({
  queryKey: ['dashboard'],
  queryFn: fetchDashboard,
  refetchInterval: 30000,  // Refresh every 30s
});
```

## Date Filtering

```typescript
const periods = [
  { label: 'Today', value: 'today' },
  { label: 'Yesterday', value: 'yesterday' },
  { label: 'This Week', value: 'this-week' },
  { label: 'This Month', value: 'this-month' },
  { label: 'Custom', value: 'custom' },
];
```
