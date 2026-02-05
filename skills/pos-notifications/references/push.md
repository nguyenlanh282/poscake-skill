# Push Notifications

## Firebase Cloud Messaging (FCM)

### Setup

```bash
npm install firebase-admin
```

```typescript
// lib/firebase-admin.ts
import admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL
    })
  });
}

export const messaging = admin.messaging();
```

### Send Push Notification

```typescript
// lib/push.ts
import { messaging } from './firebase-admin';

export async function sendPushNotification({
  token,
  title,
  body,
  data,
  imageUrl
}: {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
  imageUrl?: string;
}) {
  const message = {
    token,
    notification: {
      title,
      body,
      imageUrl
    },
    data,
    android: {
      priority: 'high' as const,
      notification: {
        sound: 'default',
        clickAction: 'OPEN_APP'
      }
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1
        }
      }
    }
  };

  return messaging.send(message);
}

// Send to multiple devices
export async function sendPushToMultiple({
  tokens,
  title,
  body,
  data
}: {
  tokens: string[];
  title: string;
  body: string;
  data?: Record<string, string>;
}) {
  const message = {
    tokens,
    notification: { title, body },
    data
  };

  const response = await messaging.sendEachForMulticast(message);

  // Handle failed tokens
  const failedTokens: string[] = [];
  response.responses.forEach((resp, idx) => {
    if (!resp.success) {
      failedTokens.push(tokens[idx]);
    }
  });

  return { successCount: response.successCount, failedTokens };
}
```

### Store FCM Token

```typescript
// API to save device token
// POST /api/push/register
export async function POST(req: Request) {
  const session = await auth.api.getSession({ headers: req.headers });
  if (!session) return Response.json({ error: 'Unauthorized' }, { status: 401 });

  const { token, deviceType } = await req.json();

  await prisma.pushToken.upsert({
    where: { token },
    update: { userId: session.user.id, updatedAt: new Date() },
    create: {
      userId: session.user.id,
      token,
      deviceType  // 'web', 'android', 'ios'
    }
  });

  return Response.json({ success: true });
}
```

## Web Push API

### Generate VAPID Keys

```bash
npx web-push generate-vapid-keys
```

### Service Worker

```javascript
// public/sw.js
self.addEventListener('push', function(event) {
  const data = event.data?.json() || {};

  const options = {
    body: data.body,
    icon: '/icon-192.png',
    badge: '/badge-72.png',
    image: data.image,
    data: data.url ? { url: data.url } : undefined,
    actions: data.actions || []
  };

  event.waitUntil(
    self.registration.showNotification(data.title || 'Notification', options)
  );
});

self.addEventListener('notificationclick', function(event) {
  event.notification.close();

  if (event.notification.data?.url) {
    event.waitUntil(
      clients.openWindow(event.notification.data.url)
    );
  }
});
```

### Request Permission Component

```tsx
'use client';
import { useState, useEffect } from 'react';

export function PushPermission() {
  const [permission, setPermission] = useState<NotificationPermission>('default');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if ('Notification' in window) {
      setPermission(Notification.permission);
    }
  }, []);

  const requestPermission = async () => {
    setLoading(true);

    try {
      const result = await Notification.requestPermission();
      setPermission(result);

      if (result === 'granted') {
        await registerServiceWorker();
        await subscribeToPush();
      }
    } finally {
      setLoading(false);
    }
  };

  if (permission === 'granted') {
    return <p className="text-green-600">Push notifications enabled</p>;
  }

  if (permission === 'denied') {
    return <p className="text-red-600">Push notifications blocked</p>;
  }

  return (
    <Button onClick={requestPermission} disabled={loading}>
      {loading ? 'Enabling...' : 'Enable Push Notifications'}
    </Button>
  );
}

async function registerServiceWorker() {
  if ('serviceWorker' in navigator) {
    await navigator.serviceWorker.register('/sw.js');
  }
}

async function subscribeToPush() {
  const registration = await navigator.serviceWorker.ready;

  const subscription = await registration.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY
  });

  // Send subscription to server
  await fetch('/api/push/subscribe', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(subscription)
  });
}
```

### Send Web Push

```typescript
// lib/web-push.ts
import webpush from 'web-push';

webpush.setVapidDetails(
  'mailto:admin@mypos.com',
  process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY!,
  process.env.VAPID_PRIVATE_KEY!
);

export async function sendWebPush({
  subscription,
  title,
  body,
  url,
  image
}: {
  subscription: PushSubscription;
  title: string;
  body: string;
  url?: string;
  image?: string;
}) {
  const payload = JSON.stringify({ title, body, url, image });

  await webpush.sendNotification(subscription, payload);
}
```

## Send to User (All Devices)

```typescript
async function sendPushToUser(userId: string, notification: PushPayload) {
  const tokens = await prisma.pushToken.findMany({
    where: { userId }
  });

  if (tokens.length === 0) return;

  // FCM tokens
  const fcmTokens = tokens.filter(t => t.deviceType !== 'web').map(t => t.token);
  if (fcmTokens.length > 0) {
    await sendPushToMultiple({
      tokens: fcmTokens,
      ...notification
    });
  }

  // Web push subscriptions
  const webSubs = tokens.filter(t => t.deviceType === 'web');
  for (const sub of webSubs) {
    await sendWebPush({
      subscription: JSON.parse(sub.token),
      ...notification
    });
  }
}
```

## Topic Subscriptions

```typescript
// Subscribe user to topic
await messaging.subscribeToTopic(userToken, 'order-updates');
await messaging.subscribeToTopic(userToken, 'promotions');

// Send to topic
await messaging.send({
  topic: 'order-updates',
  notification: {
    title: 'New Feature!',
    body: 'Check out our new dashboard'
  }
});

// Unsubscribe
await messaging.unsubscribeFromTopic(userToken, 'promotions');
```
