# POScake - POS System Skills Bundle

A comprehensive Claude Code Skills bundle for building modern Point of Sale (POS) systems with Next.js, React, and TypeScript.

## Overview

POScake provides 21 specialized skills for rapid development of production-ready POS applications:
- **13 Development Skills**: Build comprehensive POS features
- **8 API Integration Skills**: Connect to Pancake POS platform

**Use Cases**: Retail POS, restaurant systems, e-commerce backends, inventory management, multi-payment checkout, CRM, debt tracking, analytics dashboards.

## Quick Links

- [Project Overview & PDR](docs/project-overview-pdr.md) - Project goals, requirements, specifications
- [Codebase Summary](docs/codebase-summary.md) - Detailed overview of all skills
- [Code Standards](docs/code-standards.md) - Coding conventions and best practices
- [System Architecture](docs/system-architecture.md) - Architecture patterns and deployment

## Skills Catalog

### Development Skills (13)

| Skill | Description |
|-------|-------------|
| **poscake** | Core POS system (products, orders, inventory, reports) |
| **pos-payments** | Multi-payment integration (Cash, QR, VNPay, Momo, Stripe, etc.) |
| **pos-reports** | Analytics & reporting (revenue, RFM, export Excel/PDF/CSV) |
| **pos-auth** | Authentication (email, OAuth, 2FA, passkeys, RBAC) |
| **pos-notifications** | Multi-channel notifications (in-app, email, SMS, push) |
| **pos-inventory** | Inventory tracking (history, analytics, stock value) |
| **pos-suppliers** | Supplier management & purchase orders |
| **pos-promotions** | Promotions & vouchers (discounts, campaigns, bulk ops) |
| **pos-employees** | Employee management (staff, departments, sale groups) |
| **pos-analytics** | Business intelligence (real-time, trends, forecasting, cohorts) |
| **pos-crm** | Customer relationship management & loyalty programs |
| **pos-debt** | Credit management (customer AR, supplier AP, aging) |
| **pos-returns** | Returns & refunds (RMA workflow, inventory adjustment) |
| **pos-transfers** | Stock transfers between warehouses |

### API Integration Skills (8)

| Skill | Description |
|-------|-------------|
| **pos-products** | Product management API (CRUD, variations, tags, combos) |
| **pos-orders** | Order management API (orders, tracking, shipments, returns) |
| **pos-customers** | Customer management API (CRUD, loyalty points, levels) |
| **pos-inventory** | Inventory tracking API (history, analytics) |
| **pos-warehouses** | Warehouse management API |
| **pos-stocktake** | Stock counting API |
| **pos-geo** | Geographic data API (Vietnam provinces, districts, communes) |
| **pos-webhooks** | Webhook integration templates |

## Technology Stack

**Frontend**: Next.js 14, React 18, TypeScript, Tailwind CSS, shadcn/ui, Zustand, React Hook Form + Zod

**Backend**: Next.js API Routes, Prisma ORM, Better Auth, PostgreSQL/MySQL/SQLite

**Integrations**: VNPay, Momo, ZaloPay, Stripe, PayOS, SePay, Resend, SendGrid, Twilio, Firebase FCM

## Quick Start

### 1. Installation

```bash
git clone https://github.com/nguyenlanh282/poscake.git
cd poscake

# Install skills
cp -r skills/* ~/.claude/skills/
cp -r poscake ~/.claude/skills/
```

### 2. Create POS Application

```bash
# Initialize Next.js
npx create-next-app@latest my-pos --typescript --tailwind --app
cd my-pos

# Install dependencies
npm install prisma @prisma/client zustand react-hook-form zod @tanstack/react-query recharts xlsx better-auth
npx shadcn@latest init

# Setup database
npx prisma init
node ~/.claude/skills/poscake/scripts/generate-schema.js prisma/schema.prisma
npx prisma generate && npx prisma db push

# Start development
npm run dev
```

### 3. Environment Variables

```env
DATABASE_URL="postgresql://user:password@localhost:5432/pos_db"
POS_API_KEY="your_api_key"
SHOP_ID="your_shop_id"
BETTER_AUTH_SECRET="your-secret-key"
BETTER_AUTH_URL="http://localhost:3000"
```

## Using API Integration Skills

### Read Operations

```bash
export POS_API_KEY="your_api_key"
export SHOP_ID="123"

bash scripts/products.sh list "?page=1&page_size=20"
bash scripts/orders.sh get "ORDER_ID"
bash scripts/customers.sh list
```

### Write Operations

```bash
export CONFIRM_WRITE=YES
cat product-data.json | bash scripts/products.sh create
```

## Directory Structure

```
poscake/
├── poscake/                      # Main development skill
│   ├── SKILL.md
│   ├── references/               # Feature documentation
│   ├── scripts/                  # Schema generator, seeder
│   └── assets/
├── skills/                       # Additional skills (13 total)
│   ├── pos-payments/
│   ├── pos-reports/
│   ├── pos-auth/
│   └── ...
├── scripts/                      # API integration scripts
│   ├── common.sh
│   ├── products.sh
│   └── ...
├── docs/                         # Project documentation
│   ├── project-overview-pdr.md
│   ├── codebase-summary.md
│   ├── code-standards.md
│   └── system-architecture.md
├── openapi-pos.json              # Pancake POS API spec
└── README.md
```

## Key Features

### Product Management
CRUD operations, category hierarchy, variants, barcode, bulk import/export, stock tracking

### Order Processing
Shopping cart, checkout, multiple payments, status tracking, invoices, receipts

### Inventory Management
Real-time tracking, low stock alerts, movement history, multi-warehouse, stocktaking

### Payment Integration
Cash, QR/Bank, e-wallets (VNPay, Momo, ZaloPay), cards (Stripe, PayOS), webhooks

### Reports & Analytics
Revenue reports, product analytics, RFM segmentation, inventory reports, Excel/PDF/CSV export

### Authentication
Email/password, OAuth (Google, GitHub, Facebook), 2FA (TOTP, SMS), passkeys, RBAC

### Notifications
In-app (real-time), email, SMS, push (mobile & web), user preferences

## Example Usage

### Product Management Page

```typescript
// app/products/page.tsx
import { ProductService } from '@/lib/services/product.service';

export default async function ProductsPage() {
  const products = await ProductService.findAll({ isActive: true });
  return <ProductList products={products} />;
}
```

### Payment Processing

```typescript
// app/api/payments/route.ts
import { PaymentService } from '@/lib/services/payment.service';

export async function POST(request: Request) {
  const { orderId, method, amount } = await request.json();
  const payment = await PaymentService.process({ orderId, method, amount });
  return Response.json({ success: true, data: payment });
}
```

## Security & Safety

**Guardrails:**
- Write operations require `CONFIRM_WRITE=YES`
- API keys via environment variables only
- HTTPS required for all external communications

**Features:**
- Webhook signature verification
- SQL injection prevention (Prisma ORM)
- Input validation (Zod schemas)
- Rate limiting, session management, password hashing

## Documentation

**For Users:**
- [Quick Start Guide](docs/project-overview-pdr.md)
- [Skills Reference](docs/codebase-summary.md)
- [API Documentation](openapi-pos.json)

**For Developers:**
- [Code Standards](docs/code-standards.md)
- [System Architecture](docs/system-architecture.md)
- [Database Schema](poscake/references/database.md)

**Each Skill:**
- `SKILL.md` for overview
- `references/` for detailed documentation

## Production Deployment

**Vercel (Recommended):**
```bash
npm i -g vercel
vercel --prod
```

**Docker:**
```bash
docker build -t pos-app .
docker run -p 3000:3000 --env-file .env pos-app
```

**Self-Hosted:**
```bash
npm run build
npm start
```

## Contributing

Contributions welcome! See [Code Standards](docs/code-standards.md) before submitting PRs.

## Support

- Documentation: `docs/` directory
- Issues: [GitHub Issues](https://github.com/nguyenlanh282/poscake/issues)
- API Reference: `openapi-pos.json`
- Examples: Each skill's `references/` directory

## Links

- Repository: https://github.com/nguyenlanh282/poscake
- Pancake POS API: https://pos.pages.fm/api/v1
- Next.js: https://nextjs.org
- Prisma: https://www.prisma.io
- Better Auth: https://better-auth.com

## License

MIT License

## Version

**1.0.0** (February 2026)

**Includes:**
- 21 Skills (13 Development + 8 API Integration)
- Complete documentation (4 core docs + 80+ skill references)
- Production-ready templates and patterns
- Database schema generator
- Sample data seeder
- API integration scripts with guardrails
- OpenAPI specification (21K+ lines)
