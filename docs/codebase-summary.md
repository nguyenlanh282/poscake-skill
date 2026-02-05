# POScake - Codebase Summary

## Overview

POScake is a Claude Code Skills bundle for Point of Sale (POS) system development. The codebase consists of 13 modular skills, supporting documentation, API integration scripts, and configuration files. This document provides a comprehensive summary of the entire codebase structure and contents.

## Repository Statistics

- **Total Skills**: 13 (5 Development + 8 API Integration)
- **Documentation Files**: 37 markdown files
- **Scripts**: 8 bash scripts + 2 JavaScript utilities
- **API Specification**: 1 OpenAPI JSON file (795KB)
- **Primary Language**: TypeScript/JavaScript (development), Bash (API integration)

## Core Components

### 1. Main Development Skill: poscake

**Location**: `poscake/`

**Purpose**: Core POS system development with Next.js, React, and TypeScript

**Contents**:
- `SKILL.md`: Skill definition and quick start guide
- `references/`: Detailed module documentation
  - `products.md`: Product management patterns
  - `orders.md`: Order processing and checkout
  - `inventory.md`: Stock tracking and management
  - `reports.md`: Analytics and reporting
  - `database.md`: Complete Prisma schema
- `scripts/`:
  - `generate-schema.js`: Auto-generates Prisma schema
  - `seed-data.js`: Seeds sample data for testing
- `assets/`:
  - `receipt-template.html`: Print receipt template

**Key Features**:
- Next.js 14 App Router architecture
- Zustand for state management
- shadcn/ui component library
- Prisma ORM with PostgreSQL
- React Hook Form + Zod validation

### 2. Payment Integration Skill: pos-payments

**Location**: `skills/pos-payments/`

**Payment Methods Supported**:
1. **Cash**: Change calculation, cash drawer integration
2. **QR/Bank Transfer**: VietQR, SePay integration
3. **E-Wallets**: VNPay, Momo, ZaloPay
4. **Card Payments**: Stripe (international), PayOS (domestic)

**Reference Documentation**:
- `references/cash.md`: Cash handling workflows
- `references/qr-bank.md`: QR code generation and bank transfer
- `references/e-wallets.md`: Vietnamese e-wallet integrations
- `references/card.md`: Card payment processing

**Security Features**:
- Webhook signature verification
- HTTPS-only communication
- Environment-based credentials
- Sandbox/test mode support

### 3. Reports & Analytics Skill: pos-reports

**Location**: `skills/pos-reports/`

**Report Types**:
1. **Revenue Reports**: Daily/weekly/monthly with period comparison
2. **Product Analytics**: Top sellers, category performance, margin analysis
3. **Customer Analytics**: RFM segmentation, retention, lifetime value
4. **Inventory Reports**: Stock levels, turnover rate, dead stock alerts

**Technologies**:
- Recharts for visualization
- TanStack Table for data grids
- xlsx for Excel export
- jspdf for PDF generation

**Reference Documentation**:
- `references/revenue.md`: Revenue reporting patterns
- `references/products.md`: Product performance analytics
- `references/customers.md`: Customer insights and RFM
- `references/inventory.md`: Inventory analysis
- `references/export.md`: Export strategies

### 4. Authentication Skill: pos-auth

**Location**: `skills/pos-auth/`

**Authentication Methods**:
1. Email/password with verification
2. OAuth (Google, GitHub, Facebook, Discord)
3. Two-factor authentication (TOTP, SMS)
4. Passkeys/WebAuthn (biometric)
5. Session management and RBAC

**Framework**: Better Auth (framework-agnostic, TypeScript-first)

**Reference Documentation**:
- `references/email-password.md`: Traditional auth flows
- `references/oauth.md`: Social login integration
- `references/2fa.md`: Multi-factor authentication
- `references/passkeys.md`: WebAuthn implementation
- `references/session-rbac.md`: Session and role management

**Roles Supported**:
- ADMIN: Full system access
- MANAGER: Store operations
- STAFF: Sales and inventory
- CASHIER: Point of sale only

### 5. Notification Skill: pos-notifications

**Location**: `skills/pos-notifications/`

**Channels**:
1. **In-App**: Toast, bell notifications, notification center
2. **Email**: Resend/SendGrid transactional emails
3. **SMS**: Twilio/Vonage alerts
4. **Push**: Firebase FCM, Web Push API

**Use Cases**:
- Order updates (new order, status changes, payment)
- Inventory alerts (low stock, expiring items)
- Daily reports and KPI alerts
- Marketing campaigns (promotions, birthday offers)

**Reference Documentation**:
- `references/in-app.md`: Real-time in-app notifications
- `references/email.md`: Email templates and providers
- `references/sms.md`: SMS integration
- `references/push.md`: Mobile and web push
- `references/use-cases.md`: Common notification scenarios

### 6-13. API Integration Skills

**Location**: `skills/pos-[name]/`

**API Base URL**: `https://pos.pages.fm/api/v1`

**Authentication**: API key via query parameter

#### pos-products
**Endpoints**:
- `/shops/{SHOP_ID}/products`: Product CRUD
- `/shops/{SHOP_ID}/products/variations`: Variant management
- `/shops/{SHOP_ID}/tags_products`: Product tags
- `/shops/{SHOP_ID}/combo_products`: Product combos
- `/shops/{SHOP_ID}/inventory_analytics/inventory_by_product`: Stock by product

**Script**: `scripts/products.sh`

#### pos-orders
**Endpoints**:
- `/shops/{SHOP_ID}/orders`: Order management
- `/shops/{SHOP_ID}/order_source`: Order sources
- `/shops/{SHOP_ID}/orders/tags`: Order tags
- `/shops/{SHOP_ID}/orders/get_tracking_url`: Shipment tracking
- `/shops/{SHOP_ID}/orders/arrange_shipment`: Shipping arrangement
- `/shops/{SHOP_ID}/orders_returned`: Returns processing

**Script**: `scripts/orders.sh`

#### pos-customers
**Endpoints**:
- `/shops/{SHOP_ID}/customers`: Customer CRUD
- Customer points and loyalty management
- Customer level/tier system

**Script**: `scripts/customers.sh`

#### pos-inventory
**Endpoints**:
- `/shops/{SHOP_ID}/inventory_histories`: Stock movement history
- `/shops/{SHOP_ID}/inventory_analytics`: Inventory analytics

**Script**: `scripts/inventory.sh`

#### pos-warehouses
**Endpoints**:
- `/shops/{SHOP_ID}/warehouses`: Warehouse directory

**Script**: `scripts/warehouses.sh`

#### pos-stocktake
**Endpoints**:
- `/shops/{SHOP_ID}/stocktakings`: Stocktaking operations

**Script**: `scripts/stocktake.sh`

#### pos-geo
**Endpoints**:
- `/geo/provinces`: Vietnamese provinces
- `/geo/districts`: Districts by province
- `/geo/communes`: Communes by district

**Script**: `scripts/geo.sh`

#### pos-webhooks
**Purpose**: Template and design patterns for webhook integration

**Note**: OpenAPI spec doesn't currently include webhook endpoints; this skill provides implementation guidance

## API Integration Scripts

**Location**: `scripts/`

**Common Utilities**: `common.sh`
- `pos_request()`: HTTP request wrapper with API key injection
- `require_env()`: Environment variable validation
- `confirm_write()`: Write operation safety check

**Script Pattern**:
```bash
# Read operations (no confirmation required)
bash scripts/products.sh list "?page=1&page_size=20"

# Write operations (requires CONFIRM_WRITE=YES)
export CONFIRM_WRITE=YES
cat payload.json | bash scripts/products.sh create
```

**Environment Variables**:
- `POS_API_KEY`: Required for authentication
- `SHOP_ID`: Required for multi-tenant operations
- `POS_BASE_URL`: Optional (default: https://pos.pages.fm/api/v1)
- `CONFIRM_WRITE`: Required for write operations (must be "YES")

## Database Schema

**ORM**: Prisma

**Database Support**: PostgreSQL (primary), MySQL, SQLite

**Core Models**:
- **User**: Authentication and role management
- **Category**: Hierarchical product categories
- **Product**: Product catalog with variants
- **ProductVariant**: Size, color, and other attributes
- **Inventory**: Stock levels and thresholds
- **StockMovement**: Audit trail for inventory changes
- **Customer**: Customer information and loyalty points
- **Order**: Sales orders with status tracking
- **OrderItem**: Line items with pricing
- **Notification**: Multi-channel notifications
- **NotificationPreference**: User notification settings

**Enums**:
- `Role`: ADMIN, MANAGER, STAFF, CASHIER
- `OrderStatus`: PENDING, PROCESSING, COMPLETED, CANCELLED
- `PaymentStatus`: UNPAID, PARTIAL, PAID, REFUNDED

## Configuration Files

### OpenAPI Specification
**File**: `openapi-pos.json`

**Size**: 795,236 bytes

**Version**: OpenAPI 3.1.0

**Title**: Pancake POS Open API v1.0.0

**Server**: https://pos.pages.fm/api/v1

**Contents**: Complete API specification for all Pancake POS endpoints including request/response schemas, authentication, and error codes

### Environment Template
```env
# Pancake POS API
POS_API_KEY=your_api_key
SHOP_ID=your_shop_id
POS_BASE_URL=https://pos.pages.fm/api/v1

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/pos_db

# Better Auth
BETTER_AUTH_SECRET=your-secret-key
BETTER_AUTH_URL=http://localhost:3000

# OAuth Providers
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=

# Payment Gateways
VNPAY_TMN_CODE=
VNPAY_HASH_SECRET=
MOMO_PARTNER_CODE=
MOMO_ACCESS_KEY=
ZALOPAY_APP_ID=
ZALOPAY_KEY1=
STRIPE_SECRET_KEY=
SEPAY_API_KEY=
PAYOS_CLIENT_ID=

# Notifications
RESEND_API_KEY=
SENDGRID_API_KEY=
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
FIREBASE_PROJECT_ID=
FIREBASE_PRIVATE_KEY=
```

## Skill Definition Format

Each skill follows a consistent YAML frontmatter format:

```yaml
---
name: skill-name
description: |
  Detailed description of the skill's purpose and use cases.
  Includes when to activate this skill.
version: 1.0.0
allowed-tools: Bash(curl *), Bash(python *), Bash(jq *)  # API skills only
---
```

## Security & Safety Features

### Guardrails
1. **Write Protection**: All write operations require `CONFIRM_WRITE=YES`
2. **Pre-flight Validation**: GET request before write operations
3. **Secret Management**: API keys via environment variables (never committed)
4. **Webhook Verification**: Signature validation for payment webhooks
5. **HTTPS Enforcement**: All external communications use HTTPS

### Data Protection
- SQL injection prevention via Prisma ORM
- Input validation with Zod schemas
- Rate limiting on API endpoints
- Session timeout and rotation
- Password hashing with Better Auth

## Development Workflow

### Initial Setup
```bash
# 1. Clone repository
git clone https://github.com/nguyenlanh282/poscake.git

# 2. Install dependencies
npm install

# 3. Setup environment
cp .env.example .env
# Edit .env with your credentials

# 4. Initialize database
npx prisma db push
npx prisma generate

# 5. Seed sample data (optional)
node poscake/scripts/seed-data.js

# 6. Start development server
npm run dev
```

### API Integration Setup
```bash
# Set required environment variables
export POS_API_KEY="your_api_key"
export SHOP_ID="123"

# Test read operation
bash scripts/products.sh list "?page=1&page_size=10"

# Enable write operations
export CONFIRM_WRITE=YES

# Create a product
cat product-data.json | bash scripts/products.sh create
```

## Dependencies

### Core Dependencies
- `next`: ^14.x (React framework)
- `react`: ^18.x
- `typescript`: ^5.x
- `prisma`: ^5.x
- `@prisma/client`: ^5.x
- `zustand`: ^4.x (state management)
- `react-hook-form`: ^7.x (forms)
- `zod`: ^3.x (validation)
- `@tanstack/react-query`: ^5.x (server state)
- `better-auth`: ^1.x (authentication)

### UI Components
- `@shadcn/ui`: Component library
- `tailwindcss`: ^3.x (styling)
- `recharts`: ^2.x (charts)
- `lucide-react`: Icons

### Payment Providers
- Stripe SDK
- VNPay SDK (custom)
- Momo SDK (custom)
- ZaloPay SDK (custom)
- PayOS SDK
- SePay SDK

### Notification Providers
- `resend`: Email
- `@sendgrid/mail`: Email (alternative)
- `twilio`: SMS
- `firebase-admin`: Push notifications
- `web-push`: Browser push

## File Organization Principles

### Skill Structure
```
skill-name/
├── SKILL.md              # Skill definition and overview
├── references/           # Detailed documentation
│   ├── feature-1.md
│   ├── feature-2.md
│   └── feature-n.md
├── scripts/              # Utility scripts (if applicable)
└── assets/               # Templates and static files
```

### Documentation Hierarchy
1. **SKILL.md**: Quick start, overview, key concepts
2. **references/**: Deep dive into specific features
3. **docs/**: Cross-cutting concerns, architecture, standards

### Code Organization (for generated projects)
```
src/
├── app/                  # Next.js App Router
│   ├── (auth)/          # Auth routes
│   ├── (dashboard)/     # Main app routes
│   └── api/             # API routes
├── components/
│   ├── pos/             # POS-specific
│   ├── ui/              # shadcn/ui
│   └── shared/          # Reusable
├── lib/
│   ├── db/              # Prisma client
│   ├── services/        # Business logic
│   └── utils/           # Helpers
└── types/               # TypeScript types
```

## Testing Strategy

### Recommended Testing Stack
- **Unit Tests**: Vitest
- **Integration Tests**: Playwright
- **E2E Tests**: Playwright
- **API Tests**: Supertest

### Coverage Targets
- Unit test coverage: > 80%
- Integration test coverage: > 70%
- Critical paths (checkout, payment): 100%

## Performance Considerations

### Optimization Strategies
1. **Database**: Connection pooling, indexed queries
2. **Caching**: React Query for API responses
3. **Code Splitting**: Next.js automatic code splitting
4. **Image Optimization**: next/image component
5. **API Rate Limiting**: Prevent abuse

### Monitoring Recommendations
- API response time tracking
- Database query performance
- Payment gateway latency
- Error rate monitoring
- User session metrics

## Internationalization

**Default Languages**:
- Vietnamese (primary)
- English (secondary)

**I18n Strategy**:
- next-intl for Next.js
- JSON translation files
- Date/time localization
- Currency formatting (VND, USD)

## Accessibility

**Standards**: WCAG 2.1 AA

**Features**:
- Keyboard navigation
- Screen reader support
- ARIA labels
- Color contrast compliance
- Focus management

## Version Control

**Git Strategy**:
- Feature branches
- Semantic versioning
- Conventional commits
- Pull request reviews

**Ignored Files** (`.gitignore`):
- `node_modules/`
- `.env`, `.env.local`
- `dist/`, `build/`
- `.next/`
- Database files
- API keys and secrets

## Support & Resources

- **Documentation**: `docs/` directory
- **API Reference**: `openapi-pos.json`
- **Example Code**: Skill reference files
- **Scripts**: `scripts/` directory
- **Community**: GitHub issues and discussions

## Future Roadmap

### Planned Enhancements
1. Mobile POS application (React Native)
2. Offline mode with sync
3. Multi-branch management
4. Advanced inventory forecasting
5. AI-powered recommendations
6. Advanced promotion engine
7. Employee time tracking
8. Customer self-checkout

## License

MIT License

## Last Updated

February 2026 (v1.0.0)
