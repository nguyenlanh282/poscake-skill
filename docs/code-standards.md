# POScake - Code Standards and Codebase Structure

## Overview

This document outlines the code standards, conventions, and best practices followed in the POScake project. These standards ensure consistency, maintainability, and quality across all skills and modules.

## Codebase Structure

### Root Directory Organization

```
Pos.pancake/
├── poscake/                      # Main development skill
├── skills/                       # Additional specialized skills
├── scripts/                      # API integration bash scripts
├── docs/                         # Project documentation
├── openapi-pos.json             # API specification
├── README.md                    # Project overview
└── .gitignore                   # Git ignore rules
```

### Skill Directory Structure

Each skill follows a consistent structure:

```
skill-name/
├── SKILL.md                     # Skill definition and metadata
├── references/                  # Detailed documentation
│   ├── feature-1.md
│   ├── feature-2.md
│   └── ...
├── scripts/                     # Utility scripts (optional)
│   └── ...
└── assets/                      # Templates and resources (optional)
    └── ...
```

### Generated Project Structure

When using skills to build a POS application, follow this structure:

```
project-name/
├── src/
│   ├── app/                     # Next.js App Router
│   │   ├── (auth)/             # Authentication routes
│   │   │   ├── login/
│   │   │   ├── register/
│   │   │   └── layout.tsx
│   │   ├── (dashboard)/        # Main application routes
│   │   │   ├── products/
│   │   │   ├── orders/
│   │   │   ├── customers/
│   │   │   ├── inventory/
│   │   │   ├── reports/
│   │   │   └── layout.tsx
│   │   └── api/                # API routes
│   │       ├── products/
│   │       ├── orders/
│   │       ├── payments/
│   │       └── webhooks/
│   ├── components/
│   │   ├── pos/                # POS-specific components
│   │   │   ├── cart/
│   │   │   ├── checkout/
│   │   │   ├── products/
│   │   │   ├── payments/
│   │   │   └── reports/
│   │   ├── ui/                 # shadcn/ui components
│   │   │   ├── button.tsx
│   │   │   ├── input.tsx
│   │   │   ├── dialog.tsx
│   │   │   └── ...
│   │   └── shared/             # Shared components
│   │       ├── header.tsx
│   │       ├── sidebar.tsx
│   │       └── ...
│   ├── lib/
│   │   ├── db/                 # Database layer
│   │   │   ├── index.ts        # Prisma client
│   │   │   └── seed.ts
│   │   ├── services/           # Business logic
│   │   │   ├── product.service.ts
│   │   │   ├── order.service.ts
│   │   │   ├── payment.service.ts
│   │   │   └── ...
│   │   ├── auth/               # Authentication
│   │   │   ├── config.ts
│   │   │   └── middleware.ts
│   │   └── utils/              # Utility functions
│   │       ├── currency.ts
│   │       ├── date.ts
│   │       └── validators.ts
│   ├── types/                  # TypeScript type definitions
│   │   ├── product.ts
│   │   ├── order.ts
│   │   ├── payment.ts
│   │   └── ...
│   └── store/                  # State management
│       ├── cart.ts
│       ├── auth.ts
│       └── ...
├── prisma/
│   └── schema.prisma           # Database schema
├── public/                     # Static assets
├── .env.example               # Environment variables template
└── package.json
```

## Naming Conventions

### Files and Directories

#### TypeScript/JavaScript Files
- **Components**: PascalCase (e.g., `ProductCard.tsx`, `CheckoutForm.tsx`)
- **Utilities**: camelCase (e.g., `formatCurrency.ts`, `validateEmail.ts`)
- **Services**: camelCase with `.service.ts` suffix (e.g., `product.service.ts`)
- **Types**: camelCase with `.types.ts` or just `.ts` (e.g., `product.types.ts`, `order.ts`)
- **API Routes**: kebab-case (e.g., `get-products.ts`, `create-order.ts`)

#### Directories
- **Feature directories**: kebab-case (e.g., `product-management/`, `order-tracking/`)
- **Component groups**: kebab-case (e.g., `ui/`, `pos/`, `shared/`)

#### Bash Scripts
- **Script files**: kebab-case with `.sh` extension (e.g., `products.sh`, `common.sh`)

### Code Naming

#### Variables and Functions
- **Variables**: camelCase (e.g., `productList`, `totalAmount`, `isActive`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `API_BASE_URL`, `MAX_ITEMS`, `DEFAULT_CURRENCY`)
- **Functions**: camelCase (e.g., `calculateTotal`, `fetchProducts`, `validateOrder`)
- **React Components**: PascalCase (e.g., `ProductCard`, `OrderList`, `PaymentForm`)

#### TypeScript Types and Interfaces
- **Interfaces**: PascalCase with descriptive name (e.g., `Product`, `Order`, `PaymentMethod`)
- **Types**: PascalCase (e.g., `OrderStatus`, `PaymentStatus`, `UserRole`)
- **Enums**: PascalCase for name, UPPER_CASE for values

```typescript
enum OrderStatus {
  PENDING = 'PENDING',
  PROCESSING = 'PROCESSING',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED'
}
```

#### Database Models (Prisma)
- **Models**: PascalCase, singular (e.g., `Product`, `Order`, `Customer`)
- **Fields**: camelCase (e.g., `productName`, `orderNumber`, `createdAt`)
- **Relations**: camelCase, descriptive (e.g., `orderItems`, `customer`, `category`)

### API Naming

#### REST Endpoints
- **Resources**: plural, kebab-case (e.g., `/api/products`, `/api/order-items`)
- **Actions**: use HTTP verbs (GET, POST, PUT, PATCH, DELETE)
- **Query parameters**: snake_case (e.g., `?page=1&page_size=20&sort_by=name`)

Examples:
```
GET    /api/products                 # List products
GET    /api/products/:id             # Get product
POST   /api/products                 # Create product
PUT    /api/products/:id             # Update product
DELETE /api/products/:id             # Delete product
GET    /api/products/search          # Search products
POST   /api/webhooks/payment         # Payment webhook
```

## TypeScript Standards

### Type Safety

#### Always Use Explicit Types
```typescript
// Good
function calculateTotal(items: OrderItem[]): number {
  return items.reduce((sum, item) => sum + item.total, 0);
}

// Avoid
function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.total, 0);
}
```

#### Define Interfaces for Data Structures
```typescript
interface Product {
  id: string;
  name: string;
  sku: string;
  price: number;
  categoryId: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

interface OrderItem {
  id: string;
  orderId: string;
  productId: string;
  quantity: number;
  price: number;
  discount: number;
  total: number;
}
```

#### Use Discriminated Unions for Status Types
```typescript
type PaymentStatus =
  | { status: 'pending' }
  | { status: 'processing'; transactionId: string }
  | { status: 'completed'; transactionId: string; completedAt: Date }
  | { status: 'failed'; error: string };
```

### Null Safety

```typescript
// Use optional chaining
const customerName = order.customer?.name;

// Use nullish coalescing
const displayName = user.name ?? 'Guest';

// Type guards
function isProduct(item: unknown): item is Product {
  return typeof item === 'object' && item !== null && 'sku' in item;
}
```

## React/Next.js Standards

### Component Structure

#### Functional Components with TypeScript
```typescript
import { FC } from 'react';

interface ProductCardProps {
  product: Product;
  onAddToCart: (productId: string) => void;
  className?: string;
}

export const ProductCard: FC<ProductCardProps> = ({
  product,
  onAddToCart,
  className
}) => {
  return (
    <div className={className}>
      <h3>{product.name}</h3>
      <p>{formatCurrency(product.price)}</p>
      <button onClick={() => onAddToCart(product.id)}>
        Add to Cart
      </button>
    </div>
  );
};
```

### Hooks Standards

#### Custom Hooks Naming
- Always start with `use` prefix
- Descriptive of the functionality

```typescript
// useCart.ts
export function useCart() {
  const [items, setItems] = useState<CartItem[]>([]);

  const addItem = useCallback((product: Product, quantity: number) => {
    // Implementation
  }, []);

  return { items, addItem, removeItem, clearCart };
}
```

#### Hook Dependencies
- Always include all dependencies in dependency arrays
- Use `useCallback` and `useMemo` for performance optimization

### Server Components vs Client Components

#### Server Components (Default)
- Use for data fetching
- No interactivity
- Better performance

```typescript
// app/products/page.tsx
export default async function ProductsPage() {
  const products = await fetchProducts();

  return <ProductList products={products} />;
}
```

#### Client Components
- Mark with `'use client'` directive
- For interactivity, state, effects

```typescript
'use client';

import { useState } from 'react';

export function ProductFilter() {
  const [category, setCategory] = useState('');
  // ... interactive logic
}
```

## State Management Standards

### Zustand Store Pattern

```typescript
// store/cart.ts
import { create } from 'zustand';

interface CartItem {
  productId: string;
  name: string;
  price: number;
  quantity: number;
}

interface CartStore {
  items: CartItem[];
  addItem: (item: CartItem) => void;
  removeItem: (productId: string) => void;
  clearCart: () => void;
  total: number;
}

export const useCartStore = create<CartStore>((set, get) => ({
  items: [],

  addItem: (item) => set((state) => ({
    items: [...state.items, item]
  })),

  removeItem: (productId) => set((state) => ({
    items: state.items.filter(item => item.productId !== productId)
  })),

  clearCart: () => set({ items: [] }),

  get total() {
    return get().items.reduce((sum, item) =>
      sum + (item.price * item.quantity), 0
    );
  }
}));
```

### React Query Patterns

```typescript
// hooks/useProducts.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export function useProducts(params?: ProductQueryParams) {
  return useQuery({
    queryKey: ['products', params],
    queryFn: () => fetchProducts(params),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

export function useCreateProduct() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: createProduct,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });
}
```

## Database Standards (Prisma)

### Model Conventions

```prisma
model Product {
  id          String   @id @default(cuid())
  name        String
  sku         String   @unique
  price       Decimal  @db.Decimal(10, 2)
  isActive    Boolean  @default(true)
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  // Relations
  category    Category @relation(fields: [categoryId], references: [id])
  categoryId  String

  // Indexes for performance
  @@index([categoryId])
  @@index([sku])
  @@index([createdAt])
}
```

### Query Patterns

```typescript
// Good: Select only needed fields
const products = await prisma.product.findMany({
  select: {
    id: true,
    name: true,
    price: true,
  },
  where: { isActive: true },
  orderBy: { createdAt: 'desc' },
});

// Good: Use transactions for related operations
const result = await prisma.$transaction(async (tx) => {
  const order = await tx.order.create({ data: orderData });
  await tx.inventory.update({
    where: { productId: item.productId },
    data: { quantity: { decrement: item.quantity } }
  });
  return order;
});
```

## API Route Standards

### Standard Response Format

```typescript
// lib/api/response.ts
export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: unknown;
  };
  meta?: {
    page?: number;
    pageSize?: number;
    total?: number;
  };
}

// Success response
export function successResponse<T>(data: T, meta?: ApiResponse['meta']): ApiResponse<T> {
  return { success: true, data, meta };
}

// Error response
export function errorResponse(code: string, message: string, details?: unknown): ApiResponse {
  return { success: false, error: { code, message, details } };
}
```

### API Route Implementation

```typescript
// app/api/products/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const page = parseInt(searchParams.get('page') || '1');
    const pageSize = parseInt(searchParams.get('page_size') || '20');

    const products = await fetchProducts({ page, pageSize });

    return NextResponse.json(
      successResponse(products, { page, pageSize, total: products.length })
    );
  } catch (error) {
    return NextResponse.json(
      errorResponse('FETCH_ERROR', 'Failed to fetch products', error),
      { status: 500 }
    );
  }
}
```

## Form Validation Standards

### Zod Schema Pattern

```typescript
// lib/validators/product.ts
import { z } from 'zod';

export const productSchema = z.object({
  name: z.string().min(1, 'Name is required').max(200),
  sku: z.string().min(1, 'SKU is required').regex(/^[A-Z0-9-]+$/),
  price: z.number().positive('Price must be positive'),
  costPrice: z.number().positive().optional(),
  categoryId: z.string().cuid(),
  description: z.string().max(2000).optional(),
  isActive: z.boolean().default(true),
});

export type ProductFormData = z.infer<typeof productSchema>;
```

### React Hook Form Integration

```typescript
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

export function ProductForm() {
  const { register, handleSubmit, formState: { errors } } = useForm<ProductFormData>({
    resolver: zodResolver(productSchema),
  });

  const onSubmit = async (data: ProductFormData) => {
    // Handle form submission
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('name')} />
      {errors.name && <span>{errors.name.message}</span>}
      {/* More fields */}
    </form>
  );
}
```

## Styling Standards

### Tailwind CSS Conventions

```typescript
// Good: Use semantic class grouping
<div className="flex items-center gap-4 p-4 bg-white rounded-lg shadow-sm">
  <img className="w-12 h-12 rounded" src={product.image} />
  <div className="flex-1">
    <h3 className="text-lg font-semibold">{product.name}</h3>
    <p className="text-sm text-gray-600">{product.price}</p>
  </div>
</div>

// Use cn utility for conditional classes
import { cn } from '@/lib/utils';

<button className={cn(
  "px-4 py-2 rounded",
  isActive ? "bg-blue-500 text-white" : "bg-gray-200 text-gray-600"
)}>
  {label}
</button>
```

### Component Variants (CVA)

```typescript
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'rounded font-medium transition-colors',
  {
    variants: {
      variant: {
        primary: 'bg-blue-500 text-white hover:bg-blue-600',
        secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300',
        danger: 'bg-red-500 text-white hover:bg-red-600',
      },
      size: {
        sm: 'px-3 py-1 text-sm',
        md: 'px-4 py-2',
        lg: 'px-6 py-3 text-lg',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);
```

## Error Handling Standards

### Try-Catch Pattern

```typescript
// Service layer
export async function createProduct(data: ProductFormData): Promise<Product> {
  try {
    const product = await prisma.product.create({ data });
    return product;
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError) {
      if (error.code === 'P2002') {
        throw new Error('Product with this SKU already exists');
      }
    }
    throw new Error('Failed to create product');
  }
}

// API route
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const data = productSchema.parse(body);
    const product = await createProduct(data);
    return NextResponse.json(successResponse(product));
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        errorResponse('VALIDATION_ERROR', 'Invalid input', error.errors),
        { status: 400 }
      );
    }
    return NextResponse.json(
      errorResponse('CREATE_ERROR', error.message),
      { status: 500 }
    );
  }
}
```

## Testing Standards

### Unit Tests (Vitest)

```typescript
// lib/utils/currency.test.ts
import { describe, it, expect } from 'vitest';
import { formatCurrency } from './currency';

describe('formatCurrency', () => {
  it('should format VND currency correctly', () => {
    expect(formatCurrency(1000000, 'VND')).toBe('1,000,000 ₫');
  });

  it('should format USD currency correctly', () => {
    expect(formatCurrency(1000, 'USD')).toBe('$1,000.00');
  });
});
```

### Integration Tests

```typescript
// app/api/products/route.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { GET, POST } from './route';

describe('Products API', () => {
  beforeEach(async () => {
    // Setup test database
  });

  it('should return products list', async () => {
    const request = new Request('http://localhost/api/products');
    const response = await GET(request);
    const data = await response.json();

    expect(data.success).toBe(true);
    expect(Array.isArray(data.data)).toBe(true);
  });
});
```

## Security Standards

### Environment Variables

```typescript
// Never commit .env files
// Always use .env.example as template

// lib/config.ts
const config = {
  database: {
    url: process.env.DATABASE_URL!,
  },
  api: {
    posApiKey: process.env.POS_API_KEY!,
    baseUrl: process.env.POS_BASE_URL || 'https://pos.pages.fm/api/v1',
  },
  auth: {
    secret: process.env.BETTER_AUTH_SECRET!,
    url: process.env.BETTER_AUTH_URL!,
  },
};

// Validate required env vars at startup
function validateEnv() {
  const required = ['DATABASE_URL', 'BETTER_AUTH_SECRET'];
  const missing = required.filter(key => !process.env[key]);

  if (missing.length > 0) {
    throw new Error(`Missing required env vars: ${missing.join(', ')}`);
  }
}
```

### API Security

```typescript
// Middleware for API authentication
export function withAuth(handler: Function) {
  return async (request: NextRequest) => {
    const session = await getSession(request);

    if (!session) {
      return NextResponse.json(
        errorResponse('UNAUTHORIZED', 'Authentication required'),
        { status: 401 }
      );
    }

    return handler(request, session);
  };
}

// Webhook signature verification
export function verifyWebhookSignature(
  payload: string,
  signature: string,
  secret: string
): boolean {
  const expectedSignature = createHmac('sha256', secret)
    .update(payload)
    .digest('hex');

  return signature === expectedSignature;
}
```

## Bash Script Standards

### Script Structure

```bash
#!/usr/bin/env bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Script description and usage
# Usage: ./script.sh [arguments]

# Environment variables
REQUIRED_VAR="${REQUIRED_VAR}"
OPTIONAL_VAR="${OPTIONAL_VAR:-default_value}"

# Functions
function main() {
  # Main script logic
}

# Run main
main "$@"
```

### Common Patterns

```bash
# Require environment variable
require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "Missing env var: $name" >&2
    exit 2
  fi
}

# Write operation confirmation
confirm_write() {
  if [[ "${CONFIRM_WRITE:-}" != "YES" ]]; then
    echo "Write operation blocked. Set CONFIRM_WRITE=YES to proceed." >&2
    exit 3
  fi
}
```

## Documentation Standards

### Code Comments

```typescript
/**
 * Calculates the total price of an order including discounts and tax
 *
 * @param items - Array of order items
 * @param discountPercent - Discount percentage (0-100)
 * @param taxRate - Tax rate as decimal (e.g., 0.1 for 10%)
 * @returns Total order amount
 */
export function calculateOrderTotal(
  items: OrderItem[],
  discountPercent: number = 0,
  taxRate: number = 0
): number {
  const subtotal = items.reduce((sum, item) => sum + item.total, 0);
  const discount = subtotal * (discountPercent / 100);
  const afterDiscount = subtotal - discount;
  const tax = afterDiscount * taxRate;
  return afterDiscount + tax;
}
```

### README Pattern for Skills

```markdown
# Skill Name

## Description
Brief description of what the skill does.

## When to Use
Clear triggers for when this skill should be activated.

## Requirements
- Environment variables
- Dependencies
- Prerequisites

## Quick Start
Step-by-step guide to get started.

## Reference Documentation
Links to detailed documentation.

## Examples
Practical code examples.
```

## Git Commit Standards

### Commit Message Format

```
type(scope): subject

body (optional)

footer (optional)
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples
```
feat(products): add bulk import functionality

Implemented CSV import for products with validation
and error reporting.

feat(payments): integrate VNPay payment gateway

fix(orders): correct tax calculation for discounted items

docs(readme): update installation instructions

refactor(cart): simplify cart state management logic
```

## Performance Best Practices

### Database Optimization
- Use indexes on frequently queried fields
- Select only required fields
- Use pagination for large datasets
- Implement connection pooling
- Use transactions for related operations

### React Performance
- Use `React.memo` for expensive components
- Implement proper `key` props in lists
- Use `useCallback` and `useMemo` appropriately
- Lazy load components and routes
- Optimize images with next/image

### API Performance
- Implement caching (React Query, Redis)
- Use compression (gzip)
- Minimize payload size
- Implement rate limiting
- Use CDN for static assets

## Accessibility Standards

### Semantic HTML
```typescript
// Good
<button onClick={handleClick}>Submit</button>

// Avoid
<div onClick={handleClick}>Submit</div>
```

### ARIA Labels
```typescript
<button aria-label="Add to cart">
  <ShoppingCart />
</button>

<input
  type="search"
  aria-label="Search products"
  placeholder="Search..."
/>
```

### Keyboard Navigation
- All interactive elements must be keyboard accessible
- Implement proper focus management
- Use proper tab order
- Provide skip links

## Version Control

### Branch Strategy
- `main` or `master`: Production-ready code
- `develop`: Integration branch
- `feature/*`: Feature branches
- `fix/*`: Bug fix branches
- `hotfix/*`: Critical fixes

### .gitignore Rules

```
# Dependencies
node_modules/
.pnp/

# Environment
.env
.env.local
.env.*.local

# Build outputs
.next/
dist/
build/

# Database
*.db
*.sqlite

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
```

## Code Review Checklist

- [ ] Code follows naming conventions
- [ ] TypeScript types are properly defined
- [ ] Error handling is implemented
- [ ] Security best practices are followed
- [ ] Tests are included (if applicable)
- [ ] Documentation is updated
- [ ] No hardcoded secrets or API keys
- [ ] Performance considerations addressed
- [ ] Accessibility standards met
- [ ] Code is properly formatted

## Additional Resources

- TypeScript Handbook: https://www.typescriptlang.org/docs/
- Next.js Documentation: https://nextjs.org/docs
- Prisma Documentation: https://www.prisma.io/docs
- Tailwind CSS: https://tailwindcss.com/docs
- React Hook Form: https://react-hook-form.com/
- Zod Validation: https://zod.dev/
- Better Auth: https://better-auth.com/docs

## Enforcement

These standards are enforced through:
- ESLint configuration
- Prettier formatting
- TypeScript compiler
- Pre-commit hooks
- Code review process
- Automated CI/CD checks
