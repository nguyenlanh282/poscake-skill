---
name: pos-notifications
description: |
  Implement multi-channel notifications for POS systems: in-app notifications (toast, bell,
  notification center), email (Resend, SendGrid transactional), SMS (Twilio, Vonage alerts),
  push notifications (Firebase FCM, Web Push). Use cases: order updates (new order, status
  change, payment), inventory alerts (low stock, expiring), reports (daily summary, KPI),
  marketing (promotions, loyalty points, birthday). Use when building notification systems,
  sending transactional emails, implementing real-time alerts, or customer communication.
version: 1.0.0
---

# POS Notifications

Implement multi-channel notifications cho hệ thống POS.

## Notification Channels

### 1. In-App Notifications
Reference: [references/in-app.md](references/in-app.md)
- Toast notifications, bell icon, notification center, real-time updates

### 2. Email Notifications
Reference: [references/email.md](references/email.md)
- Resend, SendGrid transactional emails, templates

### 3. SMS Notifications
Reference: [references/sms.md](references/sms.md)
- Twilio, Vonage SMS alerts

### 4. Push Notifications
Reference: [references/push.md](references/push.md)
- Firebase Cloud Messaging, Web Push API

## Use Cases

Reference: [references/use-cases.md](references/use-cases.md)
- Order updates, inventory alerts, reports, marketing

## Architecture

```typescript
// Unified notification service
interface NotificationService {
  send(notification: Notification): Promise<void>;
  sendBatch(notifications: Notification[]): Promise<void>;
  schedule(notification: Notification, sendAt: Date): Promise<void>;
}

interface Notification {
  type: NotificationType;
  channels: Channel[];
  recipient: Recipient;
  content: NotificationContent;
  metadata?: Record<string, any>;
}

type Channel = 'in_app' | 'email' | 'sms' | 'push';
type NotificationType =
  | 'order_created' | 'order_status' | 'payment_received'
  | 'low_stock' | 'stock_expiring'
  | 'daily_report' | 'kpi_alert'
  | 'promotion' | 'loyalty_points' | 'birthday';
```

## Database Schema

```prisma
model Notification {
  id          String   @id @default(cuid())
  userId      String
  type        String
  title       String
  body        String
  data        Json?
  channels    String[] // ['in_app', 'email']
  isRead      Boolean  @default(false)
  readAt      DateTime?
  createdAt   DateTime @default(now())

  @@index([userId, isRead])
  @@index([createdAt])
}

model NotificationPreference {
  id        String   @id @default(cuid())
  userId    String   @unique
  email     Boolean  @default(true)
  sms       Boolean  @default(false)
  push      Boolean  @default(true)
  inApp     Boolean  @default(true)
  // Per-type preferences
  orderUpdates    Boolean @default(true)
  inventoryAlerts Boolean @default(true)
  marketing       Boolean @default(false)
}
```

## Environment Variables

```env
# Email - Resend
RESEND_API_KEY=re_xxx
EMAIL_FROM=noreply@yourpos.com

# Email - SendGrid (alternative)
SENDGRID_API_KEY=SG.xxx

# SMS - Twilio
TWILIO_ACCOUNT_SID=ACxxx
TWILIO_AUTH_TOKEN=xxx
TWILIO_PHONE_NUMBER=+1234567890

# Push - Firebase
FIREBASE_PROJECT_ID=your-project
FIREBASE_PRIVATE_KEY=xxx
FIREBASE_CLIENT_EMAIL=xxx

# Push - Web Push (VAPID)
NEXT_PUBLIC_VAPID_PUBLIC_KEY=xxx
VAPID_PRIVATE_KEY=xxx
```

## Components

```
components/notifications/
├── NotificationBell.tsx       # Bell icon with badge
├── NotificationCenter.tsx     # Dropdown list
├── NotificationItem.tsx       # Single notification
├── NotificationToast.tsx      # Toast popup
├── NotificationSettings.tsx   # User preferences
└── PushPermission.tsx         # Request push permission
```
