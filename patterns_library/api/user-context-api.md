# User Context API Pattern

## What It Does

Creates an authenticated API route with Row Level Security (RLS) enforcement for user-specific data operations. Ensures users can only access their own data.

## When to Use

- User dashboard data (payments, subscriptions, profile)
- User-specific CRUD operations
- Protected endpoints requiring user authentication
- Any API that reads/writes user-owned data

## Code Pattern

```typescript
// app/api/{resource}/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs/server';
import { withUserContext } from '@/lib/rls-context';
import { prisma } from '@/lib/prisma';
import { z } from 'zod';

// Optional: Zod validation schema
const QuerySchema = z.object({
  limit: z.coerce.number().min(1).max(100).default(20),
  offset: z.coerce.number().min(0).default(0),
});

/**
 * GET /api/{resource} - Get user-specific data
 */
export async function GET(request: NextRequest) {
  try {
    // 1. Authentication check
    const { userId } = await auth();

    if (!userId) {
      return NextResponse.json(
        { error: 'Authentication required' },
        { status: 401 }
      );
    }

    // 2. Optional: Parse query parameters
    const { searchParams } = new URL(request.url);
    const query = QuerySchema.parse({
      limit: searchParams.get('limit'),
      offset: searchParams.get('offset'),
    });

    // 3. Database operations within RLS context
    const data = await withUserContext(prisma, userId, async (client) => {
      return client.{table_name}.findMany({
        where: {
          user_id: userId,  // REQUIRED: Filter by user
          // Add other conditions...
        },
        take: query.limit,
        skip: query.offset,
        orderBy: {
          created_at: 'desc'
        }
      });
    });

    // 4. Success response
    return NextResponse.json({
      data,
      total: data.length,
      user_id: userId
    });

  } catch (error) {
    console.error('Error fetching {resource}:', error);

    // Handle Zod validation errors
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Invalid parameters', details: error.errors },
        { status: 400 }
      );
    }

    return NextResponse.json(
      { error: 'Failed to fetch {resource}' },
      { status: 500 }
    );
  }
}

/**
 * POST /api/{resource} - Create user data
 */
export async function POST(request: NextRequest) {
  try {
    // 1. Authentication check
    const { userId } = await auth();

    if (!userId) {
      return NextResponse.json(
        { error: 'Authentication required' },
        { status: 401 }
      );
    }

    // 2. Parse and validate request body
    const body = await request.json();
    const CreateSchema = z.object({
      // Define your schema
      name: z.string().min(1),
      // ... other fields
    });

    const validated = CreateSchema.parse(body);

    // 3. Create data within RLS context
    const created = await withUserContext(prisma, userId, async (client) => {
      return client.{table_name}.create({
        data: {
          ...validated,
          user_id: userId,  // REQUIRED: Set user ownership
        }
      });
    });

    // 4. Success response
    return NextResponse.json(
      { data: created },
      { status: 201 }
    );

  } catch (error) {
    console.error('Error creating {resource}:', error);

    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation failed', details: error.errors },
        { status: 400 }
      );
    }

    return NextResponse.json(
      { error: 'Failed to create {resource}' },
      { status: 500 }
    );
  }
}
```

## Customization Guide

1. **Replace placeholders**:
   - `{resource}` → Your resource name (e.g., `payments`, `subscriptions`)
   - `{table_name}` → Prisma model name (e.g., `payments`, `user_subscriptions`)

2. **Update Zod schemas**:
   - Define validation for query parameters (QuerySchema)
   - Define validation for request body (CreateSchema, UpdateSchema)

3. **Adjust database queries**:
   - Add WHERE conditions as needed
   - Include related data with `include: {}`
   - Add sorting, pagination, filtering

4. **Add business logic**:
   - Enrollment checks
   - Tier validation
   - Access control rules

## Security Checklist

- [x] **RLS Context**: All database operations use `withUserContext()`
- [x] **Authentication**: Check `userId` exists before operations
- [x] **User Ownership**: Always filter/set `user_id` in queries
- [x] **Input Validation**: Use Zod schemas for all inputs
- [x] **Error Handling**: Catch and log errors, return safe messages
- [x] **No Direct Prisma**: Never use `prisma.model.operation()` directly

## Validation Commands

```bash
# Type checking
yarn type-check

# Linting (will catch direct Prisma calls)
yarn lint

# Integration tests
yarn test:integration

# Full validation
yarn ci:validate
```

## Example: User Payments API

```typescript
// app/api/user/payments/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs/server';
import { withUserContext } from '@/lib/rls-context';
import { prisma } from '@/lib/prisma';

export async function GET(request: NextRequest) {
  try {
    const { userId } = await auth();

    if (!userId) {
      return NextResponse.json(
        { error: 'Authentication required' },
        { status: 401 }
      );
    }

    const payments = await withUserContext(prisma, userId, async (client) => {
      return client.payments.findMany({
        where: { user_id: userId },
        orderBy: { created_at: 'desc' },
        take: 50
      });
    });

    return NextResponse.json({ data: payments });

  } catch (error) {
    console.error('Error fetching payments:', error);
    return NextResponse.json(
      { error: 'Failed to fetch payments' },
      { status: 500 }
    );
  }
}
```

## Related Patterns

- [Admin Context API](./admin-context-api.md) - For admin-only operations
- [Zod Validation API](./zod-validation-api.md) - Complex input validation
- [API Integration Test](../testing/api-integration-test.md) - Testing this pattern

---

**Pattern Source**: `app/api/course/content/student/route.ts`
**Last Updated**: 2025-10-03
**Validated By**: System Architect
