#!/usr/bin/env node

/**
 * Seed sample data for POS system
 * Usage: node seed-data.js
 * Requires: DATABASE_URL env variable
 */

const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

const categories = [
  { name: 'Beverages', slug: 'beverages' },
  { name: 'Food', slug: 'food' },
  { name: 'Snacks', slug: 'snacks' },
  { name: 'Desserts', slug: 'desserts' },
];

const products = [
  { name: 'Espresso', sku: 'BEV-001', price: 35000, category: 'beverages' },
  { name: 'Cappuccino', sku: 'BEV-002', price: 45000, category: 'beverages' },
  { name: 'Latte', sku: 'BEV-003', price: 50000, category: 'beverages' },
  { name: 'Americano', sku: 'BEV-004', price: 40000, category: 'beverages' },
  { name: 'Green Tea', sku: 'BEV-005', price: 35000, category: 'beverages' },
  { name: 'Sandwich', sku: 'FOOD-001', price: 55000, category: 'food' },
  { name: 'Pasta', sku: 'FOOD-002', price: 75000, category: 'food' },
  { name: 'Salad', sku: 'FOOD-003', price: 65000, category: 'food' },
  { name: 'Chips', sku: 'SNK-001', price: 25000, category: 'snacks' },
  { name: 'Cookie', sku: 'SNK-002', price: 20000, category: 'snacks' },
  { name: 'Brownie', sku: 'DES-001', price: 35000, category: 'desserts' },
  { name: 'Cheesecake', sku: 'DES-002', price: 45000, category: 'desserts' },
];

async function main() {
  console.log('Seeding database...');

  // Create admin user
  const hashedPassword = await bcrypt.hash('admin123', 10);
  const admin = await prisma.user.upsert({
    where: { email: 'admin@poscake.local' },
    update: {},
    create: {
      email: 'admin@poscake.local',
      name: 'Admin',
      password: hashedPassword,
      role: 'ADMIN',
    },
  });
  console.log('Created admin user:', admin.email);

  // Create categories
  const categoryMap = {};
  for (const cat of categories) {
    const created = await prisma.category.upsert({
      where: { slug: cat.slug },
      update: {},
      create: cat,
    });
    categoryMap[cat.slug] = created.id;
  }
  console.log('Created categories:', Object.keys(categoryMap).length);

  // Create products with inventory
  for (const prod of products) {
    const created = await prisma.product.upsert({
      where: { sku: prod.sku },
      update: {},
      create: {
        name: prod.name,
        sku: prod.sku,
        price: prod.price,
        categoryId: categoryMap[prod.category],
        images: [],
      },
    });

    await prisma.inventory.upsert({
      where: { productId: created.id },
      update: {},
      create: {
        productId: created.id,
        quantity: Math.floor(Math.random() * 100) + 20,
        lowStockThreshold: 10,
      },
    });
  }
  console.log('Created products:', products.length);

  // Create sample customer
  await prisma.customer.upsert({
    where: { phone: '0901234567' },
    update: {},
    create: {
      name: 'Sample Customer',
      phone: '0901234567',
      email: 'customer@example.com',
    },
  });
  console.log('Created sample customer');

  console.log('Seeding complete!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
