# Export Reports

## Excel Export (xlsx)

```typescript
import * as XLSX from 'xlsx';

interface ExportOptions {
  filename: string;
  sheets: SheetData[];
}

interface SheetData {
  name: string;
  data: any[];
  columns?: ColumnDef[];
}

interface ColumnDef {
  key: string;
  header: string;
  width?: number;
  format?: 'currency' | 'number' | 'date' | 'percent';
}

function exportToExcel({ filename, sheets }: ExportOptions) {
  const wb = XLSX.utils.book_new();

  sheets.forEach(sheet => {
    // Transform data with headers
    const headers = sheet.columns?.map(c => c.header) || Object.keys(sheet.data[0] || {});
    const keys = sheet.columns?.map(c => c.key) || Object.keys(sheet.data[0] || {});

    const rows = sheet.data.map(row =>
      keys.map(key => formatCellValue(row[key], sheet.columns?.find(c => c.key === key)?.format))
    );

    const ws = XLSX.utils.aoa_to_sheet([headers, ...rows]);

    // Set column widths
    if (sheet.columns) {
      ws['!cols'] = sheet.columns.map(c => ({ wch: c.width || 15 }));
    }

    XLSX.utils.book_append_sheet(wb, ws, sheet.name);
  });

  XLSX.writeFile(wb, `${filename}.xlsx`);
}

// Usage
function exportRevenueReport(data: RevenueReport) {
  exportToExcel({
    filename: `revenue-report-${formatDate(new Date())}`,
    sheets: [
      {
        name: 'Summary',
        data: [data.summary],
        columns: [
          { key: 'totalRevenue', header: 'Total Revenue', format: 'currency', width: 20 },
          { key: 'totalOrders', header: 'Total Orders', width: 15 },
          { key: 'averageOrderValue', header: 'AOV', format: 'currency', width: 15 }
        ]
      },
      {
        name: 'Daily',
        data: data.daily,
        columns: [
          { key: 'date', header: 'Date', format: 'date', width: 15 },
          { key: 'revenue', header: 'Revenue', format: 'currency', width: 20 },
          { key: 'orders', header: 'Orders', width: 10 }
        ]
      }
    ]
  });
}
```

## PDF Export (jspdf + html2canvas)

```typescript
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';

async function exportToPDF(elementId: string, filename: string) {
  const element = document.getElementById(elementId);
  if (!element) return;

  // Capture element as canvas
  const canvas = await html2canvas(element, {
    scale: 2,
    useCORS: true,
    logging: false
  });

  const imgData = canvas.toDataURL('image/png');
  const pdf = new jsPDF({
    orientation: 'landscape',
    unit: 'mm',
    format: 'a4'
  });

  const pageWidth = pdf.internal.pageSize.getWidth();
  const pageHeight = pdf.internal.pageSize.getHeight();
  const imgWidth = pageWidth - 20;
  const imgHeight = (canvas.height * imgWidth) / canvas.width;

  // Add header
  pdf.setFontSize(18);
  pdf.text('Sales Report', 10, 15);
  pdf.setFontSize(10);
  pdf.text(`Generated: ${formatDateTime(new Date())}`, 10, 22);

  // Add image
  pdf.addImage(imgData, 'PNG', 10, 30, imgWidth, imgHeight);

  pdf.save(`${filename}.pdf`);
}

// Component
function ExportPDFButton({ reportRef, filename }: { reportRef: string, filename: string }) {
  const [loading, setLoading] = useState(false);

  const handleExport = async () => {
    setLoading(true);
    await exportToPDF(reportRef, filename);
    setLoading(false);
  };

  return (
    <Button onClick={handleExport} disabled={loading}>
      {loading ? <Loader2 className="animate-spin" /> : <FileDown />}
      Export PDF
    </Button>
  );
}
```

## CSV Export

```typescript
function exportToCSV(data: any[], filename: string, columns?: ColumnDef[]) {
  const headers = columns?.map(c => c.header) || Object.keys(data[0] || {});
  const keys = columns?.map(c => c.key) || Object.keys(data[0] || {});

  const csvContent = [
    headers.join(','),
    ...data.map(row =>
      keys.map(key => {
        const value = row[key];
        // Escape quotes and wrap in quotes if contains comma
        const escaped = String(value ?? '').replace(/"/g, '""');
        return escaped.includes(',') ? `"${escaped}"` : escaped;
      }).join(',')
    )
  ].join('\n');

  const blob = new Blob(['\ufeff' + csvContent], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `${filename}.csv`;
  link.click();
  URL.revokeObjectURL(url);
}
```

## Export Component

```tsx
function ExportButtons({ data, reportName }: { data: any, reportName: string }) {
  return (
    <div className="flex gap-2">
      <Button variant="outline" onClick={() => exportToExcel({
        filename: `${reportName}-${formatDate(new Date())}`,
        sheets: [{ name: 'Report', data }]
      })}>
        <FileSpreadsheet className="mr-2 h-4 w-4" />
        Excel
      </Button>

      <Button variant="outline" onClick={() => exportToCSV(data, reportName)}>
        <FileText className="mr-2 h-4 w-4" />
        CSV
      </Button>

      <ExportPDFButton reportRef="report-content" filename={reportName} />
    </div>
  );
}
```

## Scheduled Reports (API)

```typescript
// POST /api/reports/schedule
interface ScheduledReport {
  id: string;
  reportType: 'revenue' | 'products' | 'customers' | 'inventory';
  frequency: 'daily' | 'weekly' | 'monthly';
  format: 'excel' | 'pdf' | 'csv';
  recipients: string[];  // Email addresses
  filters?: Record<string, any>;
  nextRunAt: Date;
}

// Cron job to send scheduled reports
async function sendScheduledReports() {
  const due = await prisma.scheduledReport.findMany({
    where: { nextRunAt: { lte: new Date() } }
  });

  for (const report of due) {
    const data = await generateReport(report.reportType, report.filters);
    const file = await exportReport(data, report.format);

    await sendEmail({
      to: report.recipients,
      subject: `${report.reportType} Report - ${formatDate(new Date())}`,
      attachments: [file]
    });

    // Update next run
    await prisma.scheduledReport.update({
      where: { id: report.id },
      data: { nextRunAt: getNextRunDate(report.frequency) }
    });
  }
}
```
