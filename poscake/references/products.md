# Product Management Module

## Data Model

```typescript
interface Product {
  id: string;
  name: string;
  sku: string;
  barcode?: string;
  description?: string;
  categoryId: string;
  price: number;
  costPrice?: number;
  images: string[];
  variants?: ProductVariant[];
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

interface ProductVariant {
  id: string;
  productId: string;
  name: string;           // e.g., "Size M - Red"
  sku: string;
  price: number;
  stock: number;
  attributes: Record<string, string>;  // { size: "M", color: "Red" }
}

interface Category {
  id: string;
  name: string;
  slug: string;
  parentId?: string;
  image?: string;
  order: number;
}
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/products` | List products (paginated, filterable) |
| GET | `/api/products/:id` | Get product detail |
| POST | `/api/products` | Create product |
| PUT | `/api/products/:id` | Update product |
| DELETE | `/api/products/:id` | Delete product |
| GET | `/api/categories` | List categories |
| POST | `/api/categories` | Create category |

## Components

```
components/pos/products/
├── ProductList.tsx        # Product grid/table with search & filter
├── ProductCard.tsx        # Single product display
├── ProductForm.tsx        # Create/edit form
├── ProductVariants.tsx    # Manage variants
├── CategorySelect.tsx     # Category dropdown/tree
└── ProductSearch.tsx      # Search with barcode support
```

## Key Features

### Barcode Support
- Scan barcode to find product quickly
- Generate barcode/QR for products
- Use `react-barcode` or `qrcode.react`

### Bulk Operations
- Import products from CSV/Excel
- Export product list
- Bulk price update
- Bulk category assignment

### Image Management
- Multiple images per product
- Upload to cloud storage (S3, Cloudflare R2)
- Image optimization with sharp

## Form Validation (Zod)

```typescript
const productSchema = z.object({
  name: z.string().min(1, "Required"),
  sku: z.string().min(1, "Required"),
  price: z.number().positive("Must be positive"),
  categoryId: z.string().min(1, "Select category"),
  isActive: z.boolean().default(true),
});
```

## Zustand Store

```typescript
interface ProductStore {
  products: Product[];
  selectedProduct: Product | null;
  filters: ProductFilters;
  setProducts: (products: Product[]) => void;
  selectProduct: (product: Product | null) => void;
  updateFilters: (filters: Partial<ProductFilters>) => void;
}
```
