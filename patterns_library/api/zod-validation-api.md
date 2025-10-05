# Zod Validation API Pattern

## What It Does

Creates type-safe API routes with comprehensive input validation using Zod schemas. Provides automatic validation, type inference, and helpful error messages.

## When to Use

- Form submission endpoints
- Complex data validation requirements
- Type-safe API development
- When you need runtime type checking
- APIs with strict data contracts

## Code Pattern

```typescript
// app/api/{resource}/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { auth } from '@clerk/nextjs/server';
import { withUserContext } from '@/lib/rls-context';
import { prisma } from '@/lib/prisma';

// 1. Define Zod schemas for validation
const CreateResourceSchema = z.object({
  // Basic types
  name: z.string()
    .min(1, 'Name is required')
    .max(255, 'Name must be less than 255 characters'),

  email: z.string()
    .email('Invalid email address'),

  age: z.number()
    .int('Age must be an integer')
    .min(18, 'Must be at least 18')
    .max(120, 'Age must be realistic'),

  // Enums
  role: z.enum(['admin', 'user', 'guest'], {
    errorMap: () => ({ message: 'Invalid role' })
  }),

  // Optional fields
  description: z.string()
    .max(1000, 'Description too long')
    .optional(),

  // Nullable fields
  phone: z.string()
    .regex(/^\+?[1-9]\d{1,14}$/, 'Invalid phone number')
    .nullable()
    .optional(),

  // Arrays
  tags: z.array(z.string())
    .min(1, 'At least one tag required')
    .max(10, 'Maximum 10 tags'),

  // Nested objects
  address: z.object({
    street: z.string().min(1),
    city: z.string().min(1),
    zipCode: z.string().regex(/^\d{5}$/, 'Invalid ZIP code')
  }).optional(),

  // Dates
  birthdate: z.string()
    .datetime('Invalid datetime format')
    .transform((str) => new Date(str)),

  // Conditional validation
  tier: z.enum(['FREE', 'PRO', 'VIP']),
  proFeatures: z.array(z.string())
    .optional()
    .refine(
      (features) => {
        // Only PRO/VIP can have features
        return features === undefined || features.length === 0;
      },
      { message: 'Free tier cannot have features' }
    ),

  // Custom validation
  password: z.string()
    .min(8, 'Password must be at least 8 characters')
    .regex(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
      'Password must contain uppercase, lowercase, and number'
    )
});

// 2. Infer TypeScript types from schema
type CreateResourceInput = z.infer<typeof CreateResourceSchema>;

// 3. Query parameters schema
const QuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  sort: z.enum(['asc', 'desc']).default('desc'),
  filter: z.string().optional(),
  tier: z.enum(['FREE', 'PRO', 'VIP', 'ALL']).default('ALL')
});

/**
 * POST /api/{resource} - Create with validation
 */
export async function POST(request: NextRequest) {
  try {
    const { userId } = await auth();

    if (!userId) {
      return NextResponse.json(
        { error: 'Authentication required' },
        { status: 401 }
      );
    }

    // Parse and validate request body
    const body = await request.json();

    // Validate with Zod (throws ZodError if invalid)
    const validated = CreateResourceSchema.parse(body);

    // At this point, `validated` is fully type-safe!
    // TypeScript knows exact types: validated.name is string, etc.

    // Create resource with validated data
    const created = await withUserContext(prisma, userId, async (client) => {
      return client.{table_name}.create({
        data: {
          ...validated,
          user_id: userId
        }
      });
    });

    return NextResponse.json(
      { data: created },
      { status: 201 }
    );

  } catch (error) {
    // Handle Zod validation errors
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        {
          error: 'Validation failed',
          details: error.errors.map(err => ({
            field: err.path.join('.'),
            message: err.message
          }))
        },
        { status: 400 }
      );
    }

    console.error('Error creating {resource}:', error);
    return NextResponse.json(
      { error: 'Failed to create {resource}' },
      { status: 500 }
    );
  }
}

/**
 * GET /api/{resource} - List with query validation
 */
export async function GET(request: NextRequest) {
  try {
    const { userId } = await auth();

    if (!userId) {
      return NextResponse.json(
        { error: 'Authentication required' },
        { status: 401 }
      );
    }

    // Validate query parameters
    const { searchParams } = new URL(request.url);
    const query = QuerySchema.parse({
      page: searchParams.get('page'),
      limit: searchParams.get('limit'),
      sort: searchParams.get('sort'),
      filter: searchParams.get('filter'),
      tier: searchParams.get('tier')
    });

    // Calculate pagination
    const skip = (query.page - 1) * query.limit;

    // Query with validated params
    const data = await withUserContext(prisma, userId, async (client) => {
      const whereClause: any = { user_id: userId };

      if (query.filter) {
        whereClause.OR = [
          { name: { contains: query.filter, mode: 'insensitive' } },
          { description: { contains: query.filter, mode: 'insensitive' } }
        ];
      }

      if (query.tier !== 'ALL') {
        whereClause.tier = query.tier;
      }

      return client.{table_name}.findMany({
        where: whereClause,
        take: query.limit,
        skip,
        orderBy: { created_at: query.sort }
      });
    });

    return NextResponse.json({
      data,
      pagination: {
        page: query.page,
        limit: query.limit,
        total: data.length
      }
    });

  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        {
          error: 'Invalid query parameters',
          details: error.errors
        },
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
 * PUT /api/{resource}/[id] - Update with partial validation
 */
export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { userId } = await auth();

    if (!userId) {
      return NextResponse.json(
        { error: 'Authentication required' },
        { status: 401 }
      );
    }

    const body = await request.json();

    // Partial schema - all fields optional for updates
    const UpdateSchema = CreateResourceSchema.partial();
    const validated = UpdateSchema.parse(body);

    const updated = await withUserContext(prisma, userId, async (client) => {
      return client.{table_name}.update({
        where: {
          id: params.id,
          user_id: userId  // Ensure ownership
        },
        data: validated
      });
    });

    return NextResponse.json({ data: updated });

  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        {
          error: 'Validation failed',
          details: error.errors
        },
        { status: 400 }
      );
    }

    return NextResponse.json(
      { error: 'Failed to update {resource}' },
      { status: 500 }
    );
  }
}
```

## Advanced Zod Patterns

### Conditional Validation
```typescript
const ConditionalSchema = z.object({
  userType: z.enum(['individual', 'business']),
  // Conditionally require business fields
  businessName: z.string().optional(),
  taxId: z.string().optional()
}).refine(
  (data) => {
    if (data.userType === 'business') {
      return data.businessName && data.taxId;
    }
    return true;
  },
  {
    message: 'Business name and tax ID required for business accounts',
    path: ['businessName']
  }
);
```

### Transform Data
```typescript
const TransformSchema = z.object({
  price: z.string()
    .transform((val) => parseFloat(val))
    .pipe(z.number().positive()),

  tags: z.string()
    .transform((val) => val.split(',').map(t => t.trim()))
    .pipe(z.array(z.string().min(1)))
});
```

### Union Types
```typescript
const PaymentMethodSchema = z.discriminatedUnion('type', [
  z.object({
    type: z.literal('card'),
    cardNumber: z.string().length(16),
    cvv: z.string().length(3)
  }),
  z.object({
    type: z.literal('bank'),
    accountNumber: z.string(),
    routingNumber: z.string()
  })
]);
```

## Customization Guide

1. **Replace placeholders**:
   - `{resource}` → Your resource name
   - `{table_name}` → Prisma model name

2. **Define your schemas**:
   - Add fields specific to your data
   - Use appropriate Zod types
   - Add custom validation rules

3. **Handle errors**:
   - Return formatted validation errors
   - Include field paths
   - Provide helpful messages

4. **Type safety**:
   - Use `z.infer<>` for TypeScript types
   - Let Zod handle runtime validation
   - Enjoy auto-complete!

## Security Checklist

- [x] **Input Validation**: All inputs validated with Zod
- [x] **Type Safety**: TypeScript types inferred from schemas
- [x] **Error Messages**: Clear, helpful validation errors
- [x] **No SQL Injection**: Parameterized queries via Prisma
- [x] **XSS Prevention**: Sanitize string inputs if needed

## Validation Commands

```bash
# Type checking (will catch Zod type errors)
yarn type-check

# Linting
yarn lint

# Unit tests for schemas
yarn test:unit

# Integration tests
yarn test:integration
```

## Example: User Registration API

```typescript
import { z } from 'zod';

const RegisterSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  confirmPassword: z.string(),
  tier: z.enum(['FREE', 'PRO']).default('FREE')
}).refine(
  (data) => data.password === data.confirmPassword,
  {
    message: 'Passwords do not match',
    path: ['confirmPassword']
  }
);

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { email, password, tier } = RegisterSchema.parse(body);

    // Password and confirmPassword validated, but confirmPassword not needed in DB
    // Create user with validated data

    return NextResponse.json({ success: true });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation failed', details: error.errors },
        { status: 400 }
      );
    }

    return NextResponse.json(
      { error: 'Registration failed' },
      { status: 500 }
    );
  }
}
```

## Related Patterns

- [User Context API](./user-context-api.md) - Combine with RLS
- [Admin Context API](./admin-context-api.md) - Admin validation
- [API Integration Test](../testing/api-integration-test.md) - Test validation

---

**Pattern Source**: `app/api/course/content/route.ts`
**Last Updated**: 2025-10-03
**Validated By**: System Architect
