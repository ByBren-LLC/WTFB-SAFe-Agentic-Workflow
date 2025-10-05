# API Integration Test Pattern

## What It Does

Tests API routes end-to-end with mocked auth and database operations. Validates business logic, RLS enforcement, and error handling.

## When to Use

- Testing API route handlers
- Validating RLS enforcement
- Testing auth/authorization logic
- End-to-end API validation
- CI/CD automated testing

## Code Pattern

```typescript
// __tests__/integration/{resource}.test.ts
import { describe, it, expect, jest, beforeEach, afterEach } from '@jest/globals';
import { NextRequest } from 'next/server';

// 1. Mock dependencies
jest.mock('@clerk/nextjs/server', () => ({
  auth: jest.fn(),
}));

jest.mock('@/lib/rls-context', () => ({
  withUserContext: jest.fn((prisma, userId, callback) => callback(prisma)),
  withAdminContext: jest.fn((prisma, userId, callback) => callback(prisma)),
}));

// 2. Import after mocks
import { auth } from '@clerk/nextjs/server';
import { GET, POST } from '@/app/api/{resource}/route';

const mockAuth = auth as jest.MockedFunction<typeof auth>;

describe('API Integration: /api/{resource}', () => {
  const testUserId = 'user_test123';

  beforeEach(() => {
    jest.clearAllMocks();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('GET /api/{resource}', () => {
    it('should return user data successfully', async () => {
      // Mock authentication
      mockAuth.mockResolvedValue({
        userId: testUserId,
        orgId: null,
        orgRole: null,
      } as any);

      // Create request
      const request = new NextRequest('http://localhost:3000/api/{resource}');

      // Execute handler
      const response = await GET(request);
      const data = await response.json();

      // Assertions
      expect(response.status).toBe(200);
      expect(data).toHaveProperty('data');
      expect(Array.isArray(data.data)).toBe(true);
    });

    it('should return 401 for unauthenticated request', async () => {
      // Mock no auth
      mockAuth.mockResolvedValue({
        userId: null,
      } as any);

      const request = new NextRequest('http://localhost:3000/api/{resource}');
      const response = await GET(request);

      expect(response.status).toBe(401);
      const data = await response.json();
      expect(data.error).toBe('Authentication required');
    });
  });

  describe('POST /api/{resource}', () => {
    it('should create resource successfully', async () => {
      // Mock auth
      mockAuth.mockResolvedValue({
        userId: testUserId,
      } as any);

      // Create request with body
      const requestBody = {
        name: 'Test Resource',
        description: 'Test description',
      };

      const request = new NextRequest('http://localhost:3000/api/{resource}', {
        method: 'POST',
        body: JSON.stringify(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      });

      const response = await POST(request);
      const data = await response.json();

      expect(response.status).toBe(201);
      expect(data).toHaveProperty('data');
      expect(data.data.name).toBe('Test Resource');
    });

    it('should return 400 for invalid input', async () => {
      mockAuth.mockResolvedValue({
        userId: testUserId,
      } as any);

      // Invalid body (missing required fields)
      const request = new NextRequest('http://localhost:3000/api/{resource}', {
        method: 'POST',
        body: JSON.stringify({}),
        headers: {
          'Content-Type': 'application/json',
        },
      });

      const response = await POST(request);
      const data = await response.json();

      expect(response.status).toBe(400);
      expect(data.error).toBeDefined();
    });
  });
});
```

## Advanced Patterns

### Admin Route Testing
```typescript
import { verifyAdminAndGetUserId } from '@/lib/auth-admin';

jest.mock('@/lib/auth-admin', () => ({
  verifyAdminAndGetUserId: jest.fn(),
}));

const mockVerifyAdmin = verifyAdminAndGetUserId as jest.MockedFunction<typeof verifyAdminAndGetUserId>;

describe('Admin API Tests', () => {
  it('should allow admin access', async () => {
    mockVerifyAdmin.mockResolvedValue('admin_user_123');

    const request = new NextRequest('http://localhost/api/admin/{resource}');
    const response = await GET(request);

    expect(response.status).toBe(200);
  });

  it('should deny non-admin access', async () => {
    mockVerifyAdmin.mockRejectedValue(new Error('Admin access required'));

    const request = new NextRequest('http://localhost/api/admin/{resource}');
    const response = await GET(request);

    expect(response.status).toBe(403);
  });
});
```

### Database Mocking with Prisma
```typescript
import { prisma } from '@/lib/prisma';

jest.mock('@/lib/prisma', () => ({
  prisma: {
    {table}: {
      findMany: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
  },
}));

it('should query database correctly', async () => {
  const mockData = [{ id: '1', name: 'Test', user_id: testUserId }];

  (prisma.{table}.findMany as jest.Mock).mockResolvedValue(mockData);

  const request = new NextRequest('http://localhost/api/{resource}');
  const response = await GET(request);
  const data = await response.json();

  expect(prisma.{table}.findMany).toHaveBeenCalledWith({
    where: { user_id: testUserId },
    // ... other params
  });

  expect(data.data).toEqual(mockData);
});
```

### RLS Enforcement Testing
```typescript
import { withUserContext } from '@/lib/rls-context';

jest.mock('@/lib/rls-context');
const mockWithUserContext = withUserContext as jest.MockedFunction<typeof withUserContext>;

it('should enforce RLS context', async () => {
  mockAuth.mockResolvedValue({ userId: testUserId } as any);

  // Spy on withUserContext
  mockWithUserContext.mockImplementation(async (prisma, userId, callback) => {
    expect(userId).toBe(testUserId);
    return callback(prisma);
  });

  const request = new NextRequest('http://localhost/api/{resource}');
  await GET(request);

  expect(mockWithUserContext).toHaveBeenCalledWith(
    expect.anything(),
    testUserId,
    expect.any(Function)
  );
});
```

## Customization Guide

1. **Replace placeholders**:
   - `{resource}` → API resource name
   - `{table}` → Database table/model

2. **Mock dependencies**:
   - Always mock `@clerk/nextjs/server`
   - Mock RLS helpers if testing isolation
   - Mock Prisma for unit-style tests

3. **Test scenarios**:
   - Happy path (200/201)
   - Authentication (401)
   - Authorization (403)
   - Validation (400)
   - Server errors (500)

4. **Assertions**:
   - Status codes
   - Response structure
   - Data correctness
   - Function calls

## Security Checklist

- [x] **Auth Testing**: Test authenticated and unauthenticated
- [x] **RLS Validation**: Verify RLS context is used
- [x] **Error Cases**: Test all error scenarios
- [x] **Input Validation**: Test with invalid inputs
- [x] **Mock Security**: Ensure mocks don't bypass security

## Validation Commands

```bash
# Run integration tests
yarn test:integration

# Run specific test file
yarn jest __tests__/integration/{resource}.test.ts

# Run with coverage
yarn jest --coverage __tests__/integration/
```

## Example: Payment API Test

```typescript
import { describe, it, expect, jest } from '@jest/globals';
import { NextRequest } from 'next/server';

jest.mock('@clerk/nextjs/server');
jest.mock('@/lib/rls-context');

import { auth } from '@clerk/nextjs/server';
import { GET } from '@/app/api/user/payments/route';

const mockAuth = auth as jest.MockedFunction<typeof auth>;

describe('GET /api/user/payments', () => {
  it('returns user payments', async () => {
    mockAuth.mockResolvedValue({
      userId: 'user_123',
    } as any);

    const request = new NextRequest('http://localhost/api/user/payments');
    const response = await GET(request);
    const data = await response.json();

    expect(response.status).toBe(200);
    expect(data).toHaveProperty('data');
    expect(Array.isArray(data.data)).toBe(true);
  });

  it('returns 401 without auth', async () => {
    mockAuth.mockResolvedValue({ userId: null } as any);

    const request = new NextRequest('http://localhost/api/user/payments');
    const response = await GET(request);

    expect(response.status).toBe(401);
  });
});
```

## Related Patterns

- [User Context API](../api/user-context-api.md) - APIs to test
- [Admin Context API](../api/admin-context-api.md) - Admin APIs to test
- [E2E User Flow](./e2e-user-flow.md) - Full UI testing

---

**Pattern Source**: `__tests__/integration/admin/admin-api.test.ts`
**Last Updated**: 2025-10-03
**Validated By**: System Architect
