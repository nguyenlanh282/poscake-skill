---
name: poscake
description: |
  Build POS (Point of Sale) systems with Next.js, React, TypeScript, Tailwind CSS.
  Features: product management (CRUD, categories, pricing, variants), order processing
  (cart, checkout, payments, invoices), inventory management (stock tracking, import/export),
  reporting (revenue, sales analytics, dashboards). Use when building retail systems,
  restaurant POS, e-commerce backends, or any sales management application.
version: 1.0.0
---

# POScake - POS System Development

Build modern Point of Sale systems with Next.js + React + TypeScript + Tailwind CSS.

## Architecture

```
src/
├── app/                    # Next.js App Router
│   ├── (auth)/            # Auth routes
│   ├── (dashboard)/       # Main POS routes
│   └── api/               # API routes
├── components/
│   ├── pos/               # POS-specific components
│   ├── ui/                # shadcn/ui components
│   └── shared/            # Shared components
├── lib/
│   ├── db/                # Database (Prisma)
│   ├── services/          # Business logic
│   └── utils/             # Utilities
└── types/                 # TypeScript types
```

## Core Modules

### 1. Product Management
Reference: [references/products.md](references/products.md)
- CRUD operations, categories, variants, pricing, images

### 2. Order & Payment
Reference: [references/orders.md](references/orders.md)
- Cart management, checkout flow, payment processing, invoices

### 3. Inventory
Reference: [references/inventory.md](references/inventory.md)
- Stock tracking, import/export, low stock alerts, batch management

### 4. Reports & Analytics
Reference: [references/reports.md](references/reports.md)
- Revenue reports, sales analytics, dashboards, export

## Database Schema
Reference: [references/database.md](references/database.md)

## Quick Start

1. Initialize project:
```bash
npx create-next-app@latest pos-app --typescript --tailwind --app
cd pos-app
npx shadcn@latest init
npm install prisma @prisma/client zustand react-hook-form zod
```

2. Setup database: `npx prisma init`

3. Apply schema from [references/database.md](references/database.md)

## Key Patterns

- **State**: Zustand for cart/session, React Query for server state
- **Forms**: react-hook-form + zod validation
- **UI**: shadcn/ui components + Tailwind
- **API**: Next.js API routes + Prisma ORM
- **Auth**: NextAuth.js or Better Auth

## Scripts

- [scripts/generate-schema.js](scripts/generate-schema.js) - Generate Prisma schema
- [scripts/seed-data.js](scripts/seed-data.js) - Seed sample data
