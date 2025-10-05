# Authenticated Page Pattern

## What It Does

Creates a server-side rendered page that requires authentication, with proper access control, data fetching, and error handling.

## When to Use

- User dashboard pages
- Admin pages
- Protected content areas
- Any page requiring authentication
- Pages with user-specific or admin-specific data

## Code Pattern

```typescript
// app/dashboard/{page}/page.tsx OR app/admin/{page}/page.tsx
import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { withUserContext, withAdminContext } from '@/lib/rls-context';
import { prisma } from '@/lib/prisma';

// IMPORTANT: Force dynamic rendering for authenticated pages
// This ensures auth context is available at runtime
export const dynamic = 'force-dynamic';

/**
 * Server component data fetching with RLS
 */
async function getData(userId: string) {
  // For user pages - use withUserContext
  return await withUserContext(prisma, userId, async (client) => {
    return client.{table_name}.findMany({
      where: { user_id: userId },
      orderBy: { created_at: 'desc' },
      take: 50
    });
  });

  // For admin pages - use withAdminContext
  // return await withAdminContext(prisma, userId, async (client) => {
  //   return client.{table_name}.findMany({
  //     orderBy: { created_at: 'desc' }
  //   });
  // });
}

/**
 * Main page component
 */
export default async function {Page}() {
  // 1. Authentication check
  const { userId } = await auth();

  if (!userId) {
    redirect('/sign-in');
  }

  // 2. Optional: Admin verification (for admin pages only)
  // const { orgId, orgRole } = await auth();
  // const ADMIN_ORG_ID = process.env.CLERK_ADMIN_ORG_ID;
  // const ADMIN_ROLE = 'org:admin';
  //
  // if (orgId !== ADMIN_ORG_ID || orgRole !== ADMIN_ROLE) {
  //   redirect('/admin-denied');
  // }

  // 3. Fetch data with RLS enforcement
  const data = await getData(userId);

  // 4. Render UI
  return (
    <div className="container mx-auto p-6">
      <h1 className="text-3xl font-bold mb-6">{Page Title}</h1>

      {/* Empty state */}
      {data.length === 0 ? (
        <EmptyState />
      ) : (
        <DataDisplay data={data} />
      )}
    </div>
  );
}

/**
 * Empty state component
 */
function EmptyState() {
  return (
    <div className="text-center p-12 border border-dashed rounded-lg">
      <p className="text-muted-foreground mb-4">
        No data found
      </p>
      <Button asChild>
        <Link href="/{create-path}">
          Create New Item
        </Link>
      </Button>
    </div>
  );
}

/**
 * Data display component
 */
function DataDisplay({ data }: { data: Awaited<ReturnType<typeof getData>> }) {
  return (
    <div className="grid gap-4">
      {data.map((item) => (
        <Card key={item.id}>
          <CardHeader>
            <CardTitle>{item.title}</CardTitle>
          </CardHeader>
          <CardContent>
            {/* Render item details */}
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
```

## Admin Page Variant

```typescript
// app/admin/{resource}/page.tsx
import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { withAdminContext } from '@/lib/rls-context';
import { prisma } from '@/lib/prisma';

export const dynamic = 'force-dynamic';

async function getAdminData(userId: string) {
  return await withAdminContext(prisma, userId, async (client) => {
    return client.{table_name}.findMany({
      orderBy: { created_at: 'desc' },
      include: {
        // Include related data
      }
    });
  });
}

export default async function AdminPage() {
  // 1. Authentication check
  const { userId, orgId, orgRole } = await auth();

  if (!userId) {
    redirect('/sign-in');
  }

  // 2. Admin verification
  const ADMIN_ORG_ID = process.env.CLERK_ADMIN_ORG_ID || 'org_33W01Dy8pptgCnFovSYNiAYFWm4';
  const ADMIN_ROLE = 'org:admin';

  if (orgId !== ADMIN_ORG_ID || orgRole !== ADMIN_ROLE) {
    redirect('/admin-denied');
  }

  // 3. Fetch admin data
  const data = await getAdminData(userId);

  // 4. Render admin UI
  return (
    <div className="container mx-auto p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold">Admin: {Resource}</h1>
        <Button asChild>
          <Link href="/admin/{resource}/new">
            <Plus className="mr-2 h-4 w-4" />
            Create New
          </Link>
        </Button>
      </div>

      <AdminTable data={data} />
    </div>
  );
}
```

## Client Component Auth Pattern

```typescript
// app/dashboard/{page}/page.tsx
"use client"

import { useUser } from '@clerk/nextjs';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

export default function ClientAuthPage() {
  const { isLoaded, isSignedIn, user } = useUser();
  const router = useRouter();
  const [data, setData] = useState(null);

  useEffect(() => {
    // Wait for Clerk to load
    if (!isLoaded) return;

    // Redirect if not signed in
    if (!isSignedIn) {
      router.push('/sign-in');
      return;
    }

    // Fetch user data
    fetchData();
  }, [isLoaded, isSignedIn]);

  async function fetchData() {
    const response = await fetch('/api/user/data');
    const result = await response.json();
    setData(result.data);
  }

  if (!isLoaded || !isSignedIn) {
    return <LoadingState />;
  }

  return (
    <div className="container mx-auto p-6">
      <h1>Welcome, {user.firstName}!</h1>
      {/* Render data */}
    </div>
  );
}
```

## Customization Guide

1. **Replace placeholders**:
   - `{Page}` → Page name (e.g., `Dashboard`, `AdminContent`)
   - `{page}` → URL segment (e.g., `dashboard`, `admin/content`)
   - `{table_name}` → Prisma model
   - `{Page Title}` → Display title
   - `{Resource}` → Resource name for admin pages

2. **Choose auth pattern**:
   - Server component (recommended) - Better performance, SEO
   - Client component - When you need hooks, state, effects

3. **Choose RLS context**:
   - `withUserContext` - User-specific pages
   - `withAdminContext` - Admin pages

4. **Add features**:
   - Search/filter functionality
   - Pagination
   - Real-time updates
   - Export capabilities

## Security Checklist

- [x] **Auth Check**: Verify `userId` exists
- [x] **Admin Verification**: Check org/role for admin pages
- [x] **RLS Context**: All data fetched with proper context
- [x] **Redirect**: Redirect unauthenticated users
- [x] **Dynamic Rendering**: Use `export const dynamic = 'force-dynamic'`

## Validation Commands

```bash
# Type checking
yarn type-check

# Linting
yarn lint

# Build check
yarn build

# E2E tests
yarn test:e2e
```

## Example: User Dashboard

```typescript
// app/dashboard/payments/page.tsx
import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { withUserContext } from '@/lib/rls-context';
import { prisma } from '@/lib/prisma';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';

export const dynamic = 'force-dynamic';

async function getUserPayments(userId: string) {
  return await withUserContext(prisma, userId, async (client) => {
    return client.payments.findMany({
      where: { user_id: userId },
      orderBy: { created_at: 'desc' },
      take: 20
    });
  });
}

export default async function PaymentsPage() {
  const { userId } = await auth();

  if (!userId) {
    redirect('/sign-in');
  }

  const payments = await getUserPayments(userId);

  return (
    <div className="container mx-auto p-6">
      <h1 className="text-3xl font-bold mb-6">Payment History</h1>

      {payments.length === 0 ? (
        <p>No payments found</p>
      ) : (
        <div className="grid gap-4">
          {payments.map((payment) => (
            <Card key={payment.id}>
              <CardHeader>
                <CardTitle>${payment.amount / 100}</CardTitle>
              </CardHeader>
              <CardContent>
                <p>Status: {payment.status}</p>
                <p>Date: {new Date(payment.created_at).toLocaleDateString()}</p>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
```

## Related Patterns

- [User Context API](../api/user-context-api.md) - API for data fetching
- [Admin Context API](../api/admin-context-api.md) - Admin APIs
- [Form with Validation](./form-with-validation.md) - Forms on auth pages
- [E2E User Flow](../testing/e2e-user-flow.md) - Testing auth flows

---

**Pattern Source**: `app/admin/mini-course/content/page.tsx`
**Last Updated**: 2025-10-03
**Validated By**: System Architect
