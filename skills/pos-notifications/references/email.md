# Email Notifications

## Resend (Recommended)

```bash
npm install resend
```

### Setup

```typescript
// lib/email.ts
import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);

export async function sendEmail({
  to,
  subject,
  html,
  text
}: {
  to: string | string[];
  subject: string;
  html?: string;
  text?: string;
}) {
  const { data, error } = await resend.emails.send({
    from: process.env.EMAIL_FROM || 'noreply@yourpos.com',
    to,
    subject,
    html,
    text
  });

  if (error) {
    console.error('Email error:', error);
    throw error;
  }

  return data;
}
```

### React Email Templates

```bash
npm install @react-email/components
```

```tsx
// emails/order-confirmation.tsx
import {
  Body, Container, Head, Heading, Html,
  Preview, Section, Text, Button, Hr
} from '@react-email/components';

interface OrderConfirmationProps {
  orderNumber: string;
  customerName: string;
  items: { name: string; quantity: number; price: number }[];
  total: number;
  orderUrl: string;
}

export function OrderConfirmationEmail({
  orderNumber,
  customerName,
  items,
  total,
  orderUrl
}: OrderConfirmationProps) {
  return (
    <Html>
      <Head />
      <Preview>Order #{orderNumber} confirmed</Preview>
      <Body style={main}>
        <Container style={container}>
          <Heading style={h1}>Order Confirmed!</Heading>

          <Text style={text}>
            Hi {customerName}, thank you for your order.
          </Text>

          <Section style={orderBox}>
            <Text style={orderTitle}>Order #{orderNumber}</Text>
            {items.map((item, i) => (
              <Text key={i} style={itemText}>
                {item.name} x{item.quantity} - {formatCurrency(item.price)}
              </Text>
            ))}
            <Hr />
            <Text style={totalText}>Total: {formatCurrency(total)}</Text>
          </Section>

          <Button href={orderUrl} style={button}>
            View Order
          </Button>
        </Container>
      </Body>
    </Html>
  );
}

const main = { backgroundColor: '#f6f9fc', fontFamily: 'sans-serif' };
const container = { margin: '0 auto', padding: '40px 20px' };
const h1 = { color: '#333', fontSize: '24px' };
const text = { color: '#666', fontSize: '16px' };
const orderBox = { backgroundColor: '#fff', padding: '20px', borderRadius: '8px' };
const button = { backgroundColor: '#000', color: '#fff', padding: '12px 24px', borderRadius: '4px' };
```

### Send with React Email

```typescript
import { render } from '@react-email/render';
import { OrderConfirmationEmail } from '@/emails/order-confirmation';

async function sendOrderConfirmation(order: Order) {
  const html = await render(
    <OrderConfirmationEmail
      orderNumber={order.orderNumber}
      customerName={order.customer.name}
      items={order.items}
      total={order.total}
      orderUrl={`${process.env.APP_URL}/orders/${order.id}`}
    />
  );

  await sendEmail({
    to: order.customer.email,
    subject: `Order #${order.orderNumber} Confirmed`,
    html
  });
}
```

## SendGrid (Alternative)

```bash
npm install @sendgrid/mail
```

```typescript
// lib/sendgrid.ts
import sgMail from '@sendgrid/mail';

sgMail.setApiKey(process.env.SENDGRID_API_KEY!);

export async function sendEmailSendGrid({
  to,
  subject,
  html,
  templateId,
  dynamicData
}: {
  to: string;
  subject?: string;
  html?: string;
  templateId?: string;
  dynamicData?: Record<string, any>;
}) {
  const msg: any = {
    to,
    from: process.env.EMAIL_FROM
  };

  if (templateId) {
    // Use SendGrid dynamic template
    msg.templateId = templateId;
    msg.dynamicTemplateData = dynamicData;
  } else {
    msg.subject = subject;
    msg.html = html;
  }

  await sgMail.send(msg);
}
```

## Email Templates

### Order Status Update

```tsx
export function OrderStatusEmail({ order, newStatus }: { order: Order; newStatus: string }) {
  const statusMessages = {
    processing: 'Your order is being prepared',
    shipped: 'Your order has been shipped',
    delivered: 'Your order has been delivered',
    cancelled: 'Your order has been cancelled'
  };

  return (
    <Html>
      <Body>
        <Container>
          <Heading>Order Update</Heading>
          <Text>{statusMessages[newStatus]}</Text>
          <Text>Order: #{order.orderNumber}</Text>
          {newStatus === 'shipped' && order.trackingUrl && (
            <Button href={order.trackingUrl}>Track Shipment</Button>
          )}
        </Container>
      </Body>
    </Html>
  );
}
```

### Low Stock Alert

```tsx
export function LowStockAlertEmail({ products }: { products: LowStockProduct[] }) {
  return (
    <Html>
      <Body>
        <Container>
          <Heading>Low Stock Alert</Heading>
          <Text>The following products are running low:</Text>
          <Section>
            {products.map((p) => (
              <Text key={p.id}>
                {p.name} - {p.quantity} remaining (threshold: {p.threshold})
              </Text>
            ))}
          </Section>
          <Button href={`${process.env.APP_URL}/inventory`}>
            View Inventory
          </Button>
        </Container>
      </Body>
    </Html>
  );
}
```

### Daily Report

```tsx
export function DailyReportEmail({ date, metrics }: { date: string; metrics: DailyMetrics }) {
  return (
    <Html>
      <Body>
        <Container>
          <Heading>Daily Report - {date}</Heading>
          <Section style={metricsBox}>
            <Text>Revenue: {formatCurrency(metrics.revenue)}</Text>
            <Text>Orders: {metrics.orders}</Text>
            <Text>Avg Order Value: {formatCurrency(metrics.avgOrderValue)}</Text>
            <Text>New Customers: {metrics.newCustomers}</Text>
          </Section>
          <Button href={`${process.env.APP_URL}/reports`}>
            View Full Report
          </Button>
        </Container>
      </Body>
    </Html>
  );
}
```

## Email Queue (Background Jobs)

```typescript
// Using Inngest or similar
import { inngest } from '@/lib/inngest';

export const sendEmailJob = inngest.createFunction(
  { id: 'send-email' },
  { event: 'email/send' },
  async ({ event }) => {
    await sendEmail(event.data);
  }
);

// Trigger
await inngest.send({
  name: 'email/send',
  data: {
    to: 'user@example.com',
    subject: 'Your order',
    html: '<p>Order confirmed</p>'
  }
});
```
