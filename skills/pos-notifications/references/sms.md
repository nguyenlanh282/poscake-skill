# SMS Notifications

## Twilio

```bash
npm install twilio
```

### Setup

```typescript
// lib/sms.ts
import twilio from 'twilio';

const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

export async function sendSMS({
  to,
  body
}: {
  to: string;
  body: string;
}) {
  const message = await client.messages.create({
    to,
    from: process.env.TWILIO_PHONE_NUMBER,
    body
  });

  return message.sid;
}
```

### Format Phone Number (Vietnam)

```typescript
function formatPhoneVN(phone: string): string {
  // Remove spaces and dashes
  let cleaned = phone.replace(/[\s-]/g, '');

  // Convert 0xxx to +84xxx
  if (cleaned.startsWith('0')) {
    cleaned = '+84' + cleaned.slice(1);
  }

  // Add +84 if missing
  if (!cleaned.startsWith('+')) {
    cleaned = '+84' + cleaned;
  }

  return cleaned;
}

// Usage
await sendSMS({
  to: formatPhoneVN('0901234567'),  // +84901234567
  body: 'Your order #1234 has been confirmed'
});
```

### SMS Templates

```typescript
const SMS_TEMPLATES = {
  orderConfirmed: (orderNumber: string, total: number) =>
    `[MyPOS] Order #${orderNumber} confirmed. Total: ${formatCurrency(total)}. Thank you!`,

  orderShipped: (orderNumber: string, trackingCode: string) =>
    `[MyPOS] Order #${orderNumber} shipped. Tracking: ${trackingCode}`,

  orderDelivered: (orderNumber: string) =>
    `[MyPOS] Order #${orderNumber} delivered. Rate us: mypos.com/rate`,

  otpCode: (code: string) =>
    `[MyPOS] Your verification code is: ${code}. Valid for 5 minutes.`,

  lowStock: (productName: string, quantity: number) =>
    `[MyPOS] Alert: ${productName} is low (${quantity} left). Reorder soon.`,

  dailySummary: (revenue: number, orders: number) =>
    `[MyPOS] Daily summary: ${formatCurrency(revenue)} revenue, ${orders} orders.`
};

// Usage
await sendSMS({
  to: customer.phone,
  body: SMS_TEMPLATES.orderConfirmed(order.orderNumber, order.total)
});
```

## Vonage (Alternative)

```bash
npm install @vonage/server-sdk
```

```typescript
// lib/vonage.ts
import { Vonage } from '@vonage/server-sdk';

const vonage = new Vonage({
  apiKey: process.env.VONAGE_API_KEY!,
  apiSecret: process.env.VONAGE_API_SECRET!
});

export async function sendSMSVonage({
  to,
  text
}: {
  to: string;
  text: string;
}) {
  const response = await vonage.sms.send({
    to,
    from: process.env.VONAGE_BRAND_NAME || 'MyPOS',
    text
  });

  return response.messages[0]['message-id'];
}
```

## Bulk SMS

```typescript
async function sendBulkSMS(
  recipients: { phone: string; message: string }[]
) {
  const results = await Promise.allSettled(
    recipients.map(({ phone, message }) =>
      sendSMS({ to: formatPhoneVN(phone), body: message })
    )
  );

  const sent = results.filter(r => r.status === 'fulfilled').length;
  const failed = results.filter(r => r.status === 'rejected').length;

  return { sent, failed, total: recipients.length };
}

// Usage - Send promotion to all customers
const customers = await prisma.customer.findMany({
  where: {
    phone: { not: null },
    preferences: { marketing: true }
  }
});

await sendBulkSMS(
  customers.map(c => ({
    phone: c.phone!,
    message: '[MyPOS] 20% off this weekend! Use code WEEKEND20'
  }))
);
```

## SMS with Short URLs

```typescript
// Shorten tracking URLs for SMS
async function shortenUrl(url: string): Promise<string> {
  // Use a URL shortener service or your own
  const response = await fetch('https://api.short.io/links', {
    method: 'POST',
    headers: {
      'Authorization': process.env.SHORTIO_API_KEY!,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      domain: 'link.mypos.com',
      originalURL: url
    })
  });

  const data = await response.json();
  return data.shortURL;
}

// Usage
const trackingUrl = await shortenUrl(`https://mypos.com/track/${order.trackingCode}`);
await sendSMS({
  to: customer.phone,
  body: `[MyPOS] Order shipped! Track: ${trackingUrl}`
});
```

## Rate Limiting

```typescript
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(5, '1 h'),  // 5 SMS per hour per user
  prefix: 'sms-ratelimit'
});

async function sendSMSWithLimit(userId: string, to: string, body: string) {
  const { success, remaining } = await ratelimit.limit(userId);

  if (!success) {
    throw new Error('SMS rate limit exceeded');
  }

  return sendSMS({ to, body });
}
```

## Delivery Status Webhook

```typescript
// Twilio webhook for delivery status
// POST /api/webhooks/twilio/sms
export async function POST(req: Request) {
  const body = await req.formData();

  const messageSid = body.get('MessageSid');
  const status = body.get('MessageStatus');  // sent, delivered, failed, undelivered

  await prisma.smsLog.update({
    where: { messageSid: messageSid as string },
    data: {
      status: status as string,
      updatedAt: new Date()
    }
  });

  return new Response('OK');
}
```

## Cost Optimization

```typescript
// Check user SMS preference before sending
async function sendOrderSMS(order: Order) {
  const prefs = await prisma.notificationPreference.findUnique({
    where: { userId: order.customerId }
  });

  if (!prefs?.sms) {
    console.log('User opted out of SMS');
    return;
  }

  // Only send for orders above threshold
  if (order.total < 100000) {
    console.log('Order too small for SMS');
    return;
  }

  await sendSMS({
    to: order.customer.phone,
    body: SMS_TEMPLATES.orderConfirmed(order.orderNumber, order.total)
  });
}
```
