# In-App Notifications

## Toast Notifications (Sonner)

```bash
npm install sonner
```

### Setup

```tsx
// app/layout.tsx
import { Toaster } from 'sonner';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Toaster position="top-right" richColors />
      </body>
    </html>
  );
}
```

### Usage

```tsx
import { toast } from 'sonner';

// Success
toast.success('Order created successfully');

// Error
toast.error('Payment failed');

// With action
toast('New order received', {
  description: 'Order #1234 - 250,000đ',
  action: {
    label: 'View',
    onClick: () => router.push('/orders/1234')
  }
});

// Promise
toast.promise(createOrder(data), {
  loading: 'Creating order...',
  success: 'Order created!',
  error: 'Failed to create order'
});
```

## Notification Bell Component

```tsx
'use client';
import { useState, useEffect } from 'react';
import { Bell } from 'lucide-react';
import { useQuery } from '@tanstack/react-query';

export function NotificationBell() {
  const [open, setOpen] = useState(false);

  const { data: notifications } = useQuery({
    queryKey: ['notifications'],
    queryFn: fetchNotifications,
    refetchInterval: 30000  // Poll every 30s
  });

  const unreadCount = notifications?.filter(n => !n.isRead).length || 0;

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button variant="ghost" size="icon" className="relative">
          <Bell className="h-5 w-5" />
          {unreadCount > 0 && (
            <span className="absolute -top-1 -right-1 h-5 w-5 rounded-full bg-red-500 text-white text-xs flex items-center justify-center">
              {unreadCount > 99 ? '99+' : unreadCount}
            </span>
          )}
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-80 p-0">
        <NotificationCenter notifications={notifications} />
      </PopoverContent>
    </Popover>
  );
}
```

## Notification Center

```tsx
export function NotificationCenter({ notifications }: { notifications: Notification[] }) {
  const markAsRead = async (id: string) => {
    await fetch(`/api/notifications/${id}/read`, { method: 'POST' });
  };

  const markAllAsRead = async () => {
    await fetch('/api/notifications/read-all', { method: 'POST' });
  };

  return (
    <div className="flex flex-col">
      <div className="flex items-center justify-between p-4 border-b">
        <h3 className="font-semibold">Notifications</h3>
        <Button variant="ghost" size="sm" onClick={markAllAsRead}>
          Mark all read
        </Button>
      </div>

      <ScrollArea className="h-[400px]">
        {notifications?.length === 0 ? (
          <div className="p-4 text-center text-muted-foreground">
            No notifications
          </div>
        ) : (
          notifications?.map((notification) => (
            <NotificationItem
              key={notification.id}
              notification={notification}
              onRead={markAsRead}
            />
          ))
        )}
      </ScrollArea>

      <div className="p-2 border-t">
        <Link href="/notifications" className="text-sm text-primary">
          View all notifications
        </Link>
      </div>
    </div>
  );
}
```

## Notification Item

```tsx
export function NotificationItem({
  notification,
  onRead
}: {
  notification: Notification;
  onRead: (id: string) => void;
}) {
  const icons: Record<string, React.ReactNode> = {
    order_created: <ShoppingCart className="h-4 w-4" />,
    payment_received: <CreditCard className="h-4 w-4" />,
    low_stock: <AlertTriangle className="h-4 w-4" />,
    promotion: <Gift className="h-4 w-4" />
  };

  return (
    <div
      className={cn(
        'flex gap-3 p-4 hover:bg-muted cursor-pointer border-b',
        !notification.isRead && 'bg-blue-50'
      )}
      onClick={() => {
        onRead(notification.id);
        if (notification.data?.url) {
          router.push(notification.data.url);
        }
      }}
    >
      <div className="flex-shrink-0 mt-1">
        {icons[notification.type] || <Bell className="h-4 w-4" />}
      </div>
      <div className="flex-1 min-w-0">
        <p className="font-medium text-sm">{notification.title}</p>
        <p className="text-sm text-muted-foreground truncate">
          {notification.body}
        </p>
        <p className="text-xs text-muted-foreground mt-1">
          {formatRelativeTime(notification.createdAt)}
        </p>
      </div>
      {!notification.isRead && (
        <div className="w-2 h-2 rounded-full bg-blue-500 mt-2" />
      )}
    </div>
  );
}
```

## Real-time with SSE

```typescript
// app/api/notifications/stream/route.ts
export async function GET(req: Request) {
  const session = await auth.api.getSession({ headers: req.headers });
  if (!session) {
    return new Response('Unauthorized', { status: 401 });
  }

  const stream = new ReadableStream({
    async start(controller) {
      const encoder = new TextEncoder();

      // Subscribe to notifications for this user
      const unsubscribe = subscribeToNotifications(session.user.id, (notification) => {
        controller.enqueue(
          encoder.encode(`data: ${JSON.stringify(notification)}\n\n`)
        );
      });

      // Cleanup on disconnect
      req.signal.addEventListener('abort', () => {
        unsubscribe();
        controller.close();
      });
    }
  });

  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive'
    }
  });
}

// Client hook
function useRealtimeNotifications() {
  useEffect(() => {
    const eventSource = new EventSource('/api/notifications/stream');

    eventSource.onmessage = (event) => {
      const notification = JSON.parse(event.data);
      toast(notification.title, { description: notification.body });
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
    };

    return () => eventSource.close();
  }, []);
}
```

## API Endpoints

```typescript
// GET /api/notifications
// POST /api/notifications/:id/read
// POST /api/notifications/read-all
// DELETE /api/notifications/:id
```
