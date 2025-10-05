# Admin Context API Pattern

## What It Does

Creates an admin-only API route with elevated permissions and RLS enforcement. Used for administrative operations that require higher access levels than regular users.

## When to Use

- Admin dashboard CRUD operations
- Content management systems
- User management endpoints
- System configuration APIs
- Reports and analytics for admins

## Code Pattern

```typescript
// app/api/admin/{resource}/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { verifyAdminAndGetUserId } from '@/lib/auth-admin';
import { withAdminContext } from '@/lib/rls-context';
import { prisma } from '@/lib/prisma';

// Validation schemas
const QuerySchema = z.object({
  status: z.enum(['draft', 'published', 'ALL']).default('ALL'),
  limit: z.coerce.number().min(1).max(100).default(50),
  offset: z.coerce.number().min(0).default(0),
});

const CreateSchema = z.object({
  title: z.string().min(1).max(255),
  status: z.enum(['draft', 'published']).default('draft'),
  // ... other fields
});

/**
 * GET /api/admin/{resource} - List resources (admin only)
 */
export async function GET(request: NextRequest) {
  try {
    // 1. Admin verification (checks auth + admin role)
    const adminId = await verifyAdminAndGetUserId();

    // 2. Parse and validate query parameters
    const { searchParams } = new URL(request.url);
    const query = QuerySchema.parse({
      status: searchParams.get('status') || 'ALL',
      limit: searchParams.get('limit'),
      offset: searchParams.get('offset'),
    });

    // 3. Database operations within admin RLS context
    const data = await withAdminContext(prisma, adminId, async (client) => {
      const whereClause: any = {};

      // Build filter conditions
      if (query.status !== 'ALL') {
        whereClause.status = query.status;
      }

      return client.{table_name}.findMany({
        where: whereClause,
        take: query.limit,
        skip: query.offset,
        orderBy: {
          created_at: 'desc'
        },
        // Include related data if needed
        include: {
          // ... relations
        }
      });
    });

    // 4. Success response
    return NextResponse.json({
      success: true,
      data,
      total: data.length,
      admin_id: adminId
    });

  } catch (error) {
    console.error('Error fetching admin {resource}:', error);

    // Handle admin verification failure
    if (error instanceof Error && error.message === 'Admin access required') {
      return NextResponse.json(
        { error: 'Admin access required' },
        { status: 403 }
      );
    }

    // Handle validation errors
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
 * POST /api/admin/{resource} - Create resource (admin only)
 */
export async function POST(request: NextRequest) {
  try {
    // 1. Admin verification
    const adminId = await verifyAdminAndGetUserId();

    // 2. Parse and validate request body
    const body = await request.json();
    const validated = CreateSchema.parse(body);

    // 3. Create resource within admin RLS context
    const created = await withAdminContext(prisma, adminId, async (client) => {
      return client.{table_name}.create({
        data: {
          ...validated,
          created_by: adminId,  // Track who created it
        }
      });
    });

    // 4. Optional: Audit logging
    await withAdminContext(prisma, adminId, async (client) => {
      await client.audit_log.create({
        data: {
          user_id: adminId,
          action: 'CREATE',
          resource_type: '{resource}',
          resource_id: created.id,
          details: { title: created.title }
        }
      });
    });

    // 5. Success response
    return NextResponse.json(
      { success: true, data: created },
      { status: 201 }
    );

  } catch (error) {
    console.error('Error creating admin {resource}:', error);

    if (error instanceof Error && error.message === 'Admin access required') {
      return NextResponse.json(
        { error: 'Admin access required' },
        { status: 403 }
      );
    }

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

/**
 * PUT /api/admin/{resource}/[id] - Update resource (admin only)
 */
export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const adminId = await verifyAdminAndGetUserId();
    const body = await request.json();

    const UpdateSchema = CreateSchema.partial();  // All fields optional
    const validated = UpdateSchema.parse(body);

    const updated = await withAdminContext(prisma, adminId, async (client) => {
      return client.{table_name}.update({
        where: { id: params.id },
        data: {
          ...validated,
          updated_by: adminId,
          updated_at: new Date()
        }
      });
    });

    return NextResponse.json({ success: true, data: updated });

  } catch (error) {
    console.error('Error updating admin {resource}:', error);

    if (error instanceof Error && error.message === 'Admin access required') {
      return NextResponse.json(
        { error: 'Admin access required' },
        { status: 403 }
      );
    }

    return NextResponse.json(
      { error: 'Failed to update {resource}' },
      { status: 500 }
    );
  }
}

/**
 * DELETE /api/admin/{resource}/[id] - Delete resource (admin only)
 */
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const adminId = await verifyAdminAndGetUserId();

    await withAdminContext(prisma, adminId, async (client) => {
      await client.{table_name}.delete({
        where: { id: params.id }
      });
    });

    return NextResponse.json(
      { success: true, message: '{Resource} deleted successfully' }
    );

  } catch (error) {
    console.error('Error deleting admin {resource}:', error);

    if (error instanceof Error && error.message === 'Admin access required') {
      return NextResponse.json(
        { error: 'Admin access required' },
        { status: 403 }
      );
    }

    return NextResponse.json(
      { error: 'Failed to delete {resource}' },
      { status: 500 }
    );
  }
}
```

## Customization Guide

1. **Replace placeholders**:
   - `{resource}` → Resource name (e.g., `content`, `users`)
   - `{table_name}` → Prisma model name (e.g., `course_content`, `users`)
   - `{Resource}` → Capitalized for messages

2. **Update Zod schemas**:
   - Define fields specific to your resource
   - Add business validation rules
   - Handle optional vs required fields

3. **Adjust database queries**:
   - Add filtering logic
   - Include relations as needed
   - Implement pagination/sorting

4. **Add audit logging** (optional but recommended):
   - Track who made changes
   - Log sensitive operations
   - Include before/after values

## Security Checklist

- [x] **Admin Verification**: Use `verifyAdminAndGetUserId()` first
- [x] **RLS Context**: All operations use `withAdminContext()`
- [x] **Input Validation**: Zod schemas for all inputs
- [x] **Error Handling**: Safe error messages (no sensitive data)
- [x] **Audit Logging**: Track admin actions (recommended)
- [x] **No Direct Prisma**: Never bypass RLS context

## Validation Commands

```bash
# Type checking
yarn type-check

# Linting
yarn lint

# Integration tests (admin routes)
yarn test:integration

# Full validation
yarn ci:validate
```

## Example: Admin Content Management

```typescript
// app/api/admin/content/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { verifyAdminAndGetUserId } from '@/lib/auth-admin';
import { withAdminContext } from '@/lib/rls-context';
import { prisma } from '@/lib/prisma';

const CreateContentSchema = z.object({
  title: z.string().min(1).max(255),
  tier: z.enum(['FREE', 'PRO', 'VIP']),
  status: z.enum(['draft', 'published']).default('draft'),
});

export async function POST(request: NextRequest) {
  try {
    const adminId = await verifyAdminAndGetUserId();
    const body = await request.json();
    const validated = CreateContentSchema.parse(body);

    const content = await withAdminContext(prisma, adminId, async (client) => {
      return client.course_content.create({
        data: {
          ...validated,
          course_id: 'default-course',
          created_by: adminId
        }
      });
    });

    return NextResponse.json(
      { success: true, data: content },
      { status: 201 }
    );
  } catch (error) {
    console.error('Error creating content:', error);

    if (error instanceof Error && error.message === 'Admin access required') {
      return NextResponse.json(
        { error: 'Admin access required' },
        { status: 403 }
      );
    }

    return NextResponse.json(
      { error: 'Failed to create content' },
      { status: 500 }
    );
  }
}
```

## Related Patterns

- [User Context API](./user-context-api.md) - For user-specific operations
- [Webhook Handler](./webhook-handler.md) - For system operations
- [API Integration Test](../testing/api-integration-test.md) - Testing admin routes

---

**Pattern Source**: `app/api/course/content/route.ts`
**Last Updated**: 2025-10-03
**Validated By**: System Architect
