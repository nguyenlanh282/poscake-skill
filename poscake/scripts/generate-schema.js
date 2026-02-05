#!/usr/bin/env node

/**
 * Generate Prisma schema for POS system
 * Usage: node generate-schema.js [output-path]
 */

const fs = require('fs');
const path = require('path');

const schema = `generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ============ USERS & AUTH ============
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String
  password  String
  role      Role     @default(STAFF)
  isActive  Boolean  @default(true)
  createdAt DateTime @default(now())
  orders    Order[]
}

enum Role {
  ADMIN
  MANAGER
  STAFF
}

// ============ PRODUCTS ============
model Category {
  id       String     @id @default(cuid())
  name     String
  slug     String     @unique
  parentId String?
  parent   Category?  @relation("CategoryTree", fields: [parentId], references: [id])
  children Category[] @relation("CategoryTree")
  products Product[]
  order    Int        @default(0)
}

model Product {
  id          String    @id @default(cuid())
  name        String
  sku         String    @unique
  barcode     String?   @unique
  description String?
  categoryId  String
  category    Category  @relation(fields: [categoryId], references: [id])
  price       Decimal   @db.Decimal(10, 2)
  costPrice   Decimal?  @db.Decimal(10, 2)
  images      String[]
  isActive    Boolean   @default(true)
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  variants    ProductVariant[]
  inventory   Inventory?
  orderItems  OrderItem[]
}

model ProductVariant {
  id         String   @id @default(cuid())
  productId  String
  product    Product  @relation(fields: [productId], references: [id], onDelete: Cascade)
  name       String
  sku        String   @unique
  price      Decimal  @db.Decimal(10, 2)
  attributes Json
  isActive   Boolean  @default(true)
}

// ============ INVENTORY ============
model Inventory {
  id                String   @id @default(cuid())
  productId         String   @unique
  product           Product  @relation(fields: [productId], references: [id])
  quantity          Int      @default(0)
  reservedQty       Int      @default(0)
  lowStockThreshold Int      @default(10)
  updatedAt         DateTime @updatedAt
}

model StockMovement {
  id            String   @id @default(cuid())
  productId     String
  type          String
  quantity      Int
  referenceType String
  referenceId   String
  note          String?
  createdAt     DateTime @default(now())
  createdBy     String

  @@index([productId])
  @@index([createdAt])
}

// ============ ORDERS ============
model Customer {
  id        String   @id @default(cuid())
  name      String
  phone     String?  @unique
  email     String?
  address   String?
  points    Int      @default(0)
  createdAt DateTime @default(now())
  orders    Order[]
}

model Order {
  id            String        @id @default(cuid())
  orderNumber   String        @unique
  customerId    String?
  customer      Customer?     @relation(fields: [customerId], references: [id])
  items         OrderItem[]
  subtotal      Decimal       @db.Decimal(10, 2)
  discount      Decimal       @default(0) @db.Decimal(10, 2)
  tax           Decimal       @default(0) @db.Decimal(10, 2)
  total         Decimal       @db.Decimal(10, 2)
  status        OrderStatus   @default(PENDING)
  paymentStatus PaymentStatus @default(UNPAID)
  paymentMethod String?
  note          String?
  createdAt     DateTime      @default(now())
  createdBy     String
  user          User          @relation(fields: [createdBy], references: [id])

  @@index([createdAt])
  @@index([status, paymentStatus])
}

model OrderItem {
  id        String  @id @default(cuid())
  orderId   String
  order     Order   @relation(fields: [orderId], references: [id], onDelete: Cascade)
  productId String
  product   Product @relation(fields: [productId], references: [id])
  name      String
  price     Decimal @db.Decimal(10, 2)
  quantity  Int
  discount  Decimal @default(0) @db.Decimal(10, 2)
  total     Decimal @db.Decimal(10, 2)
}

enum OrderStatus {
  PENDING
  PROCESSING
  COMPLETED
  CANCELLED
}

enum PaymentStatus {
  UNPAID
  PARTIAL
  PAID
  REFUNDED
}
`;

const outputPath = process.argv[2] || 'prisma/schema.prisma';
const dir = path.dirname(outputPath);

if (!fs.existsSync(dir)) {
  fs.mkdirSync(dir, { recursive: true });
}

fs.writeFileSync(outputPath, schema);
console.log(`Prisma schema generated at: ${outputPath}`);
console.log('Run: npx prisma generate && npx prisma db push');
