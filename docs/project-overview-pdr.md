# POScake - Project Overview & Product Development Requirements

## Executive Summary

POScake is a comprehensive Claude Code Skills bundle designed for building and integrating Point of Sale (POS) systems. The bundle provides 21 specialized skills divided into two categories: 13 development skills for building POS applications and 8 API integration skills for connecting with the Pancake POS platform.

## Project Overview

### Purpose
Enable rapid development of modern, production-ready POS systems with built-in integrations for payments, reporting, authentication, notifications, and the Pancake POS API ecosystem.

### Target Users
- Developers building retail POS systems
- Restaurant management system developers
- E-commerce backend developers
- Integration developers working with Pancake POS API
- Enterprise developers requiring POS functionality

### Technology Stack
- **Frontend**: Next.js 14 (App Router), React, TypeScript, Tailwind CSS, shadcn/ui
- **Backend**: Next.js API Routes, Prisma ORM
- **Database**: PostgreSQL (primary), MySQL, SQLite
- **State Management**: Zustand (client state), TanStack Query (server state)
- **Forms**: react-hook-form with Zod validation
- **Charts**: Recharts
- **Auth**: Better Auth framework
- **Payments**: VNPay, Momo, ZaloPay, Stripe, PayOS, SePay
- **Notifications**: Resend, SendGrid, Twilio, Vonage, Firebase FCM

## Product Architecture

### Skills Catalog

#### Development Skills (1-13)

**1. poscake**
- Core POS system development
- Product management (CRUD, categories, variants, barcode, bulk import)
- Order processing (cart, checkout, payments, invoices)
- Inventory management (stock tracking, import/export, alerts)
- Reporting (revenue, sales analytics, dashboards)

**2. pos-payments**
- Cash payments (change calculation, cash drawer)
- QR/Bank transfers (VietQR, SePay)
- E-wallets (VNPay, Momo, ZaloPay)
- Card payments (Stripe, PayOS)

**3. pos-reports**
- Revenue reports (daily/weekly/monthly, period comparison)
- Product analytics (top sellers, margin analysis, slow movers)
- Customer analytics (RFM segmentation, retention, LTV)
- Inventory reports (turnover rate, dead stock, reorder suggestions)
- Export capabilities (Excel, PDF, CSV)

**4. pos-auth**
- Email/password authentication with verification
- OAuth providers (Google, GitHub, Facebook, Discord)
- Two-factor authentication (TOTP, SMS OTP)
- Passkeys/WebAuthn (fingerprint, Face ID)
- Session management and RBAC

**5. pos-notifications**
- In-app notifications (toast, bell, notification center)
- Email notifications (transactional, marketing)
- SMS alerts (order updates, OTP)
- Push notifications (mobile and web)

**6. pos-inventory**
- Inventory history tracking (import/export movements)
- Inventory analytics by variation and product
- Beginning/ending inventory reports
- Stock value calculations

**7. pos-suppliers**
- Supplier management (contact info, payment terms)
- Purchase orders (create, track, fulfill)
- Supplier debt tracking
- Purchase order splitting

**8. pos-promotions**
- Promotion campaigns (discount by product, quantity, order value)
- Voucher/coupon management
- Customer-specific offers
- Bulk promotion operations

**9. pos-employees**
- Employee/staff management
- Department organization
- Sale groups and teams

**10. pos-analytics**
- Real-time metrics (revenue, orders, conversion)
- Trend analysis (daily/weekly/monthly patterns)
- Sales forecasting and predictions
- Cohort analysis (customer behavior)
- Geographic analytics (sales by location)

**11. pos-crm**
- Customer profiles with purchase history
- RFM segmentation (Recency, Frequency, Monetary)
- Loyalty programs (points, tiers, rewards)
- Marketing automation (email/SMS campaigns)
- Feedback and support ticketing

**12. pos-debt**
- Customer credit management (credit limits, payment terms)
- Supplier payables tracking
- Debt aging reports (30/60/90 days)
- Payment collection workflows
- Credit risk scoring

**13. pos-returns**
- Return policies configuration
- Return authorization (RMA workflow)
- Refund processing (original payment, store credit, exchange)
- Inventory adjustment after returns
- Return analytics

**14. pos-transfers**
- Stock transfers between warehouses
- Approval workflow for transfers
- Shipping and receiving tracking
- Transfer costing (FIFO, average)
- Transfer analytics

#### API Integration Skills (15-21)

**15. pos-products**
- Product CRUD operations via API
- Variations management
- Tags and materials
- Combo products
- Inventory by product queries

**16. pos-orders**
- Order management (list, get, create)
- Order tracking
- Shipment arrangement
- Order tags and sources
- Returned orders

**17. pos-customers**
- Customer management via API
- Points and loyalty programs
- Customer levels/tiers

**18. pos-warehouses**
- Warehouse directory management

**19. pos-stocktake**
- Stock counting operations
- Stocktaking records

**20. pos-geo**
- Geographic data (provinces, districts, communes)
- Vietnamese location lookup

**21. pos-webhooks**
- Webhook integration templates
- Event handling patterns

### Directory Structure

```
Pos.pancake/
├── poscake/                          # Main development skill
│   ├── SKILL.md                      # Skill definition
│   ├── references/                   # Reference documentation
│   │   ├── products.md
│   │   ├── orders.md
│   │   ├── inventory.md
│   │   ├── reports.md
│   │   └── database.md
│   ├── scripts/                      # Utility scripts
│   │   ├── generate-schema.js
│   │   └── seed-data.js
│   └── assets/
│       └── receipt-template.html
│
├── skills/                           # Additional skills
│   ├── pos-payments/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── cash.md
│   │       ├── qr-bank.md
│   │       ├── e-wallets.md
│   │       └── card.md
│   │
│   ├── pos-reports/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── revenue.md
│   │       ├── products.md
│   │       ├── customers.md
│   │       ├── inventory.md
│   │       └── export.md
│   │
│   ├── pos-auth/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── email-password.md
│   │       ├── oauth.md
│   │       ├── 2fa.md
│   │       ├── passkeys.md
│   │       └── session-rbac.md
│   │
│   ├── pos-notifications/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── in-app.md
│   │       ├── email.md
│   │       ├── sms.md
│   │       ├── push.md
│   │       └── use-cases.md
│   │
│   └── [pos-products, pos-orders, pos-customers, etc.]/
│       └── SKILL.md
│
├── scripts/                          # API integration scripts
│   ├── common.sh                     # Shared utilities
│   ├── products.sh
│   ├── orders.sh
│   ├── customers.sh
│   ├── inventory.sh
│   ├── warehouses.sh
│   ├── stocktake.sh
│   └── geo.sh
│
├── docs/                             # Project documentation
│   ├── project-overview-pdr.md       # This file
│   ├── codebase-summary.md
│   ├── code-standards.md
│   └── system-architecture.md
│
├── openapi-pos.json                  # Pancake POS API specification
└── README.md
```

## Product Development Requirements

### Functional Requirements

#### FR-1: Product Management
- **FR-1.1**: Create, read, update products with SKU, barcode, pricing
- **FR-1.2**: Support product categories with hierarchical structure
- **FR-1.3**: Manage product variants with attributes (size, color, etc.)
- **FR-1.4**: Handle product images (multiple images per product)
- **FR-1.5**: Bulk import/export functionality

#### FR-2: Order Processing
- **FR-2.1**: Shopping cart functionality with real-time updates
- **FR-2.2**: Checkout flow with customer information
- **FR-2.3**: Multiple payment methods support
- **FR-2.4**: Order status tracking and history
- **FR-2.5**: Invoice/receipt generation and printing

#### FR-3: Inventory Management
- **FR-3.1**: Real-time stock tracking
- **FR-3.2**: Low stock alerts and notifications
- **FR-3.3**: Stock movement history (in/out/adjustment)
- **FR-3.4**: Multi-warehouse support
- **FR-3.5**: Stocktaking/cycle counting

#### FR-4: Payment Integration
- **FR-4.1**: Cash payment with change calculation
- **FR-4.2**: QR code payment (VietQR, bank transfer)
- **FR-4.3**: E-wallet integration (VNPay, Momo, ZaloPay)
- **FR-4.4**: Card payment processing (Stripe, PayOS)
- **FR-4.5**: Payment verification and webhook handling

#### FR-5: Reporting & Analytics
- **FR-5.1**: Revenue reports with period comparison
- **FR-5.2**: Product performance analytics
- **FR-5.3**: Customer analytics (RFM, retention, LTV)
- **FR-5.4**: Inventory reports (turnover, dead stock)
- **FR-5.5**: Export to Excel, PDF, CSV

#### FR-6: Authentication & Authorization
- **FR-6.1**: Email/password authentication
- **FR-6.2**: Social login (Google, GitHub, Facebook)
- **FR-6.3**: Two-factor authentication (TOTP, SMS)
- **FR-6.4**: Biometric login (passkeys, WebAuthn)
- **FR-6.5**: Role-based access control (Admin, Manager, Staff, Cashier)

#### FR-7: Notifications
- **FR-7.1**: In-app notifications with real-time updates
- **FR-7.2**: Transactional email notifications
- **FR-7.3**: SMS alerts for critical events
- **FR-7.4**: Push notifications for mobile/web
- **FR-7.5**: User notification preferences

#### FR-8: API Integration
- **FR-8.1**: Full CRUD operations via Pancake POS API
- **FR-8.2**: Webhook event handling
- **FR-8.3**: Rate limiting and error handling
- **FR-8.4**: API authentication and security
- **FR-8.5**: Batch operations support

### Non-Functional Requirements

#### NFR-1: Performance
- **NFR-1.1**: Page load time < 2 seconds
- **NFR-1.2**: API response time < 500ms for 95th percentile
- **NFR-1.3**: Support 100+ concurrent users
- **NFR-1.4**: Real-time updates with < 1 second latency

#### NFR-2: Security
- **NFR-2.1**: HTTPS only for all communications
- **NFR-2.2**: API key encryption and secure storage
- **NFR-2.3**: Payment webhook signature verification
- **NFR-2.4**: SQL injection protection via Prisma ORM
- **NFR-2.5**: Rate limiting on API endpoints

#### NFR-3: Scalability
- **NFR-3.1**: Database connection pooling
- **NFR-3.2**: Horizontal scaling support
- **NFR-3.3**: Caching strategy for frequently accessed data
- **NFR-3.4**: Async processing for heavy operations

#### NFR-4: Reliability
- **NFR-4.1**: 99.9% uptime target
- **NFR-4.2**: Automated error logging and monitoring
- **NFR-4.3**: Graceful degradation for external service failures
- **NFR-4.4**: Database backup and recovery procedures

#### NFR-5: Usability
- **NFR-5.1**: Responsive design (mobile, tablet, desktop)
- **NFR-5.2**: Accessibility compliance (WCAG 2.1 AA)
- **NFR-5.3**: Multi-language support (Vietnamese, English)
- **NFR-5.4**: Keyboard shortcuts for common operations

#### NFR-6: Maintainability
- **NFR-6.1**: TypeScript for type safety
- **NFR-6.2**: Comprehensive code documentation
- **NFR-6.3**: Modular architecture with clear separation
- **NFR-6.4**: Automated testing (unit, integration, E2E)

### Technical Constraints

#### TC-1: Platform Requirements
- Node.js 18+ required
- PostgreSQL 14+ (or MySQL 8+, SQLite 3.40+)
- Modern browser support (Chrome, Firefox, Safari, Edge - last 2 versions)

#### TC-2: External Dependencies
- Pancake POS API availability
- Third-party payment gateway uptime
- Email/SMS service provider reliability

#### TC-3: Data Constraints
- API key required for all Pancake POS operations
- Shop ID required for multi-tenant operations
- Write operations require explicit confirmation (CONFIRM_WRITE=YES)

### Success Metrics

#### SM-1: Development Velocity
- Time to create basic POS: < 2 hours
- Time to integrate payment: < 30 minutes per provider
- Time to setup authentication: < 1 hour

#### SM-2: Code Quality
- TypeScript coverage: > 95%
- Test coverage: > 80%
- Zero critical security vulnerabilities

#### SM-3: User Satisfaction
- System response time satisfaction: > 90%
- Feature completeness: > 85%
- Documentation clarity: > 90%

## Deployment Requirements

### Environment Variables

```env
# Pancake POS API
POS_API_KEY=your_api_key
SHOP_ID=your_shop_id
POS_BASE_URL=https://pos.pages.fm/api/v1

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/pos_db

# Authentication
BETTER_AUTH_SECRET=your-secret-key
BETTER_AUTH_URL=http://localhost:3000

# Payment Gateways
VNPAY_TMN_CODE=
VNPAY_HASH_SECRET=
MOMO_PARTNER_CODE=
MOMO_ACCESS_KEY=
STRIPE_SECRET_KEY=
SEPAY_API_KEY=

# Notifications
RESEND_API_KEY=
TWILIO_ACCOUNT_SID=
FIREBASE_PROJECT_ID=
```

### Installation Process

1. Clone repository
2. Install dependencies (`npm install`)
3. Setup environment variables
4. Initialize database (`npx prisma db push`)
5. Seed sample data (optional)
6. Run development server (`npm run dev`)

## Future Enhancements

### Phase 2 Features
- Multi-branch/multi-location support
- Advanced employee management
- Time tracking and shift management
- Customer loyalty program automation
- Advanced promotion engine

### Phase 3 Features
- Mobile POS application (React Native)
- Offline mode with sync
- AI-powered demand forecasting
- Automated reordering
- Advanced business intelligence

## References

- Pancake POS API: https://pos.pages.fm/api/v1
- Repository: https://github.com/nguyenlanh282/poscake
- OpenAPI Specification: `openapi-pos.json`
- Code Standards: `docs/code-standards.md`
- System Architecture: `docs/system-architecture.md`

## Version History

- **1.0.0** (February 2026): Initial release with 21 skills
  - 13 Development skills
  - 8 API Integration skills
  - Complete documentation
  - Production-ready templates
  - Vietnamese market payment integrations
