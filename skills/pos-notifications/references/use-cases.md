# Notification Use Cases

## Order Updates

### New Order (Staff)

```typescript
async function notifyNewOrder(order: Order) {
  // In-app notification to all staff
  const staff = await prisma.user.findMany({
    where: { role: { in: ['ADMIN', 'MANAGER', 'STAFF'] } }
  });

  await createNotifications(
    staff.map(s => ({
      userId: s.id,
      type: 'order_created',
      title: 'New Order',
      body: `Order #${order.orderNumber} - ${formatCurrency(order.total)}`,
      data: { orderId: order.id, url: `/orders/${order.id}` },
      channels: ['in_app', 'push']
    }))
  );

  // Play sound on POS terminal
  // toast with sound
}
```

### Order Status (Customer)

```typescript
async function notifyOrderStatus(order: Order, newStatus: OrderStatus) {
  const customer = order.customer;
  if (!customer) return;

  const messages = {
    processing: { title: 'Order Processing', body: 'We are preparing your order' },
    shipped: { title: 'Order Shipped', body: `Tracking: ${order.trackingCode}` },
    delivered: { title: 'Order Delivered', body: 'Enjoy your purchase!' },
    cancelled: { title: 'Order Cancelled', body: 'Your order has been cancelled' }
  };

  const msg = messages[newStatus];
  const channels: Channel[] = ['in_app'];

  // Add email for important statuses
  if (['shipped', 'delivered', 'cancelled'].includes(newStatus)) {
    channels.push('email');
  }

  // SMS for shipped orders with high value
  if (newStatus === 'shipped' && order.total > 500000) {
    channels.push('sms');
  }

  await sendNotification({
    userId: customer.id,
    type: 'order_status',
    ...msg,
    data: { orderId: order.id, status: newStatus },
    channels
  });
}
```

### Payment Received

```typescript
async function notifyPaymentReceived(order: Order, payment: Payment) {
  // Notify customer
  await sendNotification({
    userId: order.customerId,
    type: 'payment_received',
    title: 'Payment Received',
    body: `${formatCurrency(payment.amount)} for order #${order.orderNumber}`,
    channels: ['in_app', 'email']
  });

  // Notify staff
  await notifyStaff({
    type: 'payment_received',
    title: 'Payment Received',
    body: `Order #${order.orderNumber} - ${payment.method}`,
    channels: ['in_app']
  });
}
```

## Inventory Alerts

### Low Stock

```typescript
// Run as scheduled job (e.g., every hour)
async function checkLowStock() {
  const lowStockItems = await prisma.inventory.findMany({
    where: {
      quantity: { lte: prisma.inventory.fields.lowStockThreshold }
    },
    include: { product: true }
  });

  if (lowStockItems.length === 0) return;

  // Notify managers
  const managers = await prisma.user.findMany({
    where: { role: { in: ['ADMIN', 'MANAGER'] } }
  });

  const productList = lowStockItems
    .map(i => `${i.product.name}: ${i.quantity} left`)
    .join('\n');

  await createNotifications(
    managers.map(m => ({
      userId: m.id,
      type: 'low_stock',
      title: `Low Stock Alert (${lowStockItems.length} items)`,
      body: productList,
      data: { url: '/inventory?filter=low-stock' },
      channels: ['in_app', 'email']
    }))
  );
}
```

### Expiring Products

```typescript
async function checkExpiringProducts() {
  const sevenDaysFromNow = new Date();
  sevenDaysFromNow.setDate(sevenDaysFromNow.getDate() + 7);

  const expiring = await prisma.batch.findMany({
    where: {
      expiryDate: { lte: sevenDaysFromNow },
      quantity: { gt: 0 }
    },
    include: { product: true }
  });

  if (expiring.length > 0) {
    await notifyManagers({
      type: 'stock_expiring',
      title: `${expiring.length} products expiring soon`,
      body: 'Review and take action',
      channels: ['in_app', 'email']
    });
  }
}
```

## Reports

### Daily Summary

```typescript
// Run at end of day (e.g., 11 PM)
async function sendDailySummary() {
  const today = new Date();
  const metrics = await getDailyMetrics(today);

  const managers = await prisma.user.findMany({
    where: {
      role: { in: ['ADMIN', 'MANAGER'] },
      notificationPreferences: { dailyReport: true }
    }
  });

  for (const manager of managers) {
    await sendNotification({
      userId: manager.id,
      type: 'daily_report',
      title: `Daily Report - ${formatDate(today)}`,
      body: `Revenue: ${formatCurrency(metrics.revenue)} | Orders: ${metrics.orders}`,
      channels: ['email']
    });
  }
}
```

### KPI Alert

```typescript
async function checkKPIAlerts() {
  const today = await getDailyMetrics(new Date());
  const yesterday = await getDailyMetrics(subDays(new Date(), 1));

  // Alert if revenue dropped > 20%
  const revenueChange = (today.revenue - yesterday.revenue) / yesterday.revenue;

  if (revenueChange < -0.2) {
    await notifyAdmins({
      type: 'kpi_alert',
      title: 'Revenue Alert',
      body: `Revenue dropped ${Math.abs(revenueChange * 100).toFixed(0)}% vs yesterday`,
      channels: ['in_app', 'push', 'sms']
    });
  }
}
```

## Marketing

### Promotion

```typescript
async function sendPromotionNotification(promotion: Promotion) {
  const customers = await prisma.customer.findMany({
    where: {
      notificationPreferences: { marketing: true }
    }
  });

  // Batch send
  for (const batch of chunk(customers, 100)) {
    await Promise.all(
      batch.map(customer =>
        sendNotification({
          userId: customer.id,
          type: 'promotion',
          title: promotion.title,
          body: promotion.description,
          data: { promoCode: promotion.code, url: '/promotions' },
          channels: ['push', 'email']
        })
      )
    );
  }
}
```

### Loyalty Points

```typescript
async function notifyPointsEarned(customer: Customer, points: number, orderId: string) {
  await sendNotification({
    userId: customer.id,
    type: 'loyalty_points',
    title: `You earned ${points} points!`,
    body: `Total: ${customer.points + points} points`,
    data: { orderId },
    channels: ['in_app', 'push']
  });
}
```

### Birthday

```typescript
// Run daily at 9 AM
async function sendBirthdayWishes() {
  const today = format(new Date(), 'MM-dd');

  const birthdayCustomers = await prisma.customer.findMany({
    where: {
      birthday: { endsWith: today },
      notificationPreferences: { marketing: true }
    }
  });

  for (const customer of birthdayCustomers) {
    await sendNotification({
      userId: customer.id,
      type: 'birthday',
      title: `Happy Birthday, ${customer.name}! 🎂`,
      body: 'Enjoy 20% off on your special day!',
      data: { promoCode: `BDAY${customer.id.slice(-6)}` },
      channels: ['email', 'sms', 'push']
    });
  }
}
```

## Unified Notification Service

```typescript
// lib/notification-service.ts
export async function sendNotification(notification: NotificationInput) {
  const { userId, type, title, body, data, channels } = notification;

  // Check user preferences
  const prefs = await prisma.notificationPreference.findUnique({
    where: { userId }
  });

  const enabledChannels = channels.filter(ch => {
    if (ch === 'in_app') return prefs?.inApp !== false;
    if (ch === 'email') return prefs?.email !== false;
    if (ch === 'sms') return prefs?.sms === true;
    if (ch === 'push') return prefs?.push !== false;
    return false;
  });

  // Save in-app notification
  if (enabledChannels.includes('in_app')) {
    await prisma.notification.create({
      data: { userId, type, title, body, data, channels: enabledChannels }
    });
  }

  // Send to other channels
  const user = await prisma.user.findUnique({ where: { id: userId } });

  if (enabledChannels.includes('email') && user?.email) {
    await sendEmail({ to: user.email, subject: title, html: renderEmailTemplate(type, { title, body, data }) });
  }

  if (enabledChannels.includes('sms') && user?.phone) {
    await sendSMS({ to: user.phone, body: `${title}: ${body}` });
  }

  if (enabledChannels.includes('push')) {
    await sendPushToUser(userId, { title, body, data });
  }
}
```
