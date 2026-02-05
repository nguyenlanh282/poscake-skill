---
name: pos-reports
description: |
  Build reports and analytics dashboards for POS systems: revenue reports (daily/weekly/monthly,
  period comparison), product analytics (top sellers, category performance, margin analysis),
  customer analytics (new customers, retention, RFM segmentation), inventory reports (stock
  levels, turnover rate, dead stock). Features: Recharts visualization, real-time dashboards,
  export to Excel/PDF/CSV. Use when building analytics dashboards, generating business reports,
  or implementing data visualization for retail/restaurant POS.
version: 1.0.0
---

# POS Reports & Analytics

Build comprehensive reports and analytics dashboards cho hệ thống POS.

## Report Types

### 1. Revenue Reports
Reference: [references/revenue.md](references/revenue.md)
- Daily/weekly/monthly revenue, period comparison, payment breakdown

### 2. Product Analytics
Reference: [references/products.md](references/products.md)
- Top sellers, category performance, margin analysis, slow movers

### 3. Customer Analytics
Reference: [references/customers.md](references/customers.md)
- New vs returning, retention rate, RFM segmentation, lifetime value

### 4. Inventory Reports
Reference: [references/inventory.md](references/inventory.md)
- Stock levels, turnover rate, dead stock, reorder suggestions

## Tech Stack

- **Charts**: Recharts (LineChart, BarChart, PieChart, AreaChart)
- **Tables**: TanStack Table with sorting, filtering, pagination
- **Export**: xlsx (Excel), jspdf + html2canvas (PDF), native CSV
- **Real-time**: React Query with refetch interval / WebSocket

## Components

```
components/reports/
├── Dashboard.tsx           # Main dashboard layout
├── MetricCard.tsx          # KPI cards with trend indicator
├── DateRangePicker.tsx     # Period selection
├── PeriodComparison.tsx    # Compare with previous period
├── charts/
│   ├── RevenueChart.tsx    # Line/area chart
│   ├── SalesByCategory.tsx # Pie/donut chart
│   ├── TopProducts.tsx     # Horizontal bar chart
│   └── HourlySales.tsx     # Heatmap
├── tables/
│   ├── SalesTable.tsx      # Detailed sales data
│   └── ProductTable.tsx    # Product performance
└── export/
    ├── ExportExcel.tsx     # Excel export button
    ├── ExportPDF.tsx       # PDF export button
    └── ExportCSV.tsx       # CSV export button
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/reports/dashboard` | Dashboard metrics |
| GET | `/api/reports/revenue` | Revenue report |
| GET | `/api/reports/products` | Product analytics |
| GET | `/api/reports/customers` | Customer analytics |
| GET | `/api/reports/inventory` | Inventory report |
| GET | `/api/reports/export` | Export data |

## Quick Start

```typescript
// Dashboard with real-time refresh
const { data } = useQuery({
  queryKey: ['dashboard', dateRange],
  queryFn: () => fetchDashboard(dateRange),
  refetchInterval: 30000  // 30s
});
```

## Date Periods

```typescript
const periods = [
  { label: 'Today', value: 'today' },
  { label: 'Yesterday', value: 'yesterday' },
  { label: 'Last 7 days', value: '7d' },
  { label: 'Last 30 days', value: '30d' },
  { label: 'This month', value: 'this-month' },
  { label: 'Last month', value: 'last-month' },
  { label: 'Custom', value: 'custom' }
];
```
