# E2E User Flow Pattern

## What It Does

Tests complete user workflows end-to-end using Playwright. Validates entire user journeys from authentication to feature completion.

## When to Use

- Testing critical user paths
- Validating multi-step workflows
- UI/UX validation
- Cross-browser testing
- Regression testing

## Code Pattern

```typescript
// e2e/{feature}-workflow.spec.ts
import { test, expect, Page } from '@playwright/test';

// 1. Test suite with setup
test.describe('{Feature} Workflow', () => {
  let page: Page;

  // 2. Setup: Login before each test
  test.beforeEach(async ({ page: testPage }) => {
    page = testPage;

    // Navigate to login
    await page.goto('/sign-in');

    // Fill login form
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', process.env.TEST_USER_PASSWORD!);
    await page.click('button[type="submit"]');

    // Wait for redirect to dashboard
    await page.waitForURL('/dashboard');
  });

  // 3. Test: Complete user workflow
  test('complete {feature} creation flow', async () => {
    // Step 1: Navigate to feature page
    await page.goto('/dashboard/{feature}');
    await expect(page).toHaveURL('/dashboard/{feature}');

    // Step 2: Click create button
    await page.click('button:has-text("Create {Feature}")');

    // Wait for form to appear
    await expect(page.locator('form')).toBeVisible();

    // Step 3: Fill out form
    await page.fill('input[name="name"]', 'E2E Test {Feature}');
    await page.fill('textarea[name="description"]', 'Created via E2E test');

    // Select from dropdown
    await page.click('[role="combobox"]');
    await page.click('text=Option 1');

    // Step 4: Submit form
    await page.click('button[type="submit"]:has-text("Create")');

    // Step 5: Verify success
    await expect(page.locator('text={Feature} created successfully')).toBeVisible();

    // Step 6: Verify item appears in list
    await expect(page.locator('text=E2E Test {Feature}')).toBeVisible();
  });

  // 4. Test: Error handling
  test('shows validation errors for invalid input', async () => {
    await page.goto('/dashboard/{feature}');
    await page.click('button:has-text("Create {Feature}")');

    // Submit empty form
    await page.click('button[type="submit"]:has-text("Create")');

    // Verify error messages
    await expect(page.locator('text=Name is required')).toBeVisible();
    await expect(page.locator('text=Description is required')).toBeVisible();
  });

  // 5. Test: Delete flow
  test('deletes {feature} successfully', async () => {
    await page.goto('/dashboard/{feature}');

    // Click delete on first item
    await page.click('[aria-label="Actions"]').first();
    await page.click('text=Delete');

    // Confirm deletion
    page.on('dialog', dialog => dialog.accept());
    await page.click('button:has-text("Delete")');

    // Verify item removed
    await expect(page.locator('text=Deleted successfully')).toBeVisible();
  });
});
```

## Advanced Patterns

### With Test Data Cleanup
```typescript
import { test as base } from '@playwright/test';

const test = base.extend({
  // Create test data before each test
  testData: async ({ page }, use) => {
    // Setup: Create test data via API
    const response = await page.request.post('/api/test/setup', {
      data: { userId: 'test_user' }
    });
    const data = await response.json();

    // Provide data to test
    await use(data);

    // Cleanup: Delete test data
    await page.request.post('/api/test/cleanup', {
      data: { testId: data.id }
    });
  },
});

test('uses test data', async ({ page, testData }) => {
  await page.goto(`/dashboard/item/${testData.id}`);
  // Test...
});
```

### Multi-Step User Journey
```typescript
test('complete purchase flow', async ({ page }) => {
  // Step 1: Browse products
  await page.goto('/dashboard/products');
  await page.click('text=Premium Plan');

  // Step 2: Add to cart
  await page.click('button:has-text("Add to Cart")');
  await expect(page.locator('text=Added to cart')).toBeVisible();

  // Step 3: Go to checkout
  await page.click('a:has-text("Cart")');
  await expect(page.locator('text=Premium Plan')).toBeVisible();
  await page.click('button:has-text("Checkout")');

  // Step 4: Fill payment details
  await page.fill('input[name="cardNumber"]', '4242424242424242');
  await page.fill('input[name="expiry"]', '12/25');
  await page.fill('input[name="cvc"]', '123');

  // Step 5: Complete purchase
  await page.click('button:has-text("Pay Now")');

  // Step 6: Verify success
  await expect(page.locator('text=Payment successful')).toBeVisible();
  await expect(page).toHaveURL('/dashboard/success');

  // Step 7: Verify subscription activated
  await page.goto('/dashboard/settings');
  await expect(page.locator('text=Premium')).toBeVisible();
});
```

### Authentication Flow Testing
```typescript
test.describe('Authentication Flow', () => {
  test('sign up new user', async ({ page }) => {
    await page.goto('/sign-up');

    await page.fill('input[name="email"]', 'newuser@example.com');
    await page.fill('input[name="password"]', 'TestPassword123!');
    await page.fill('input[name="confirmPassword"]', 'TestPassword123!');
    await page.click('button[type="submit"]');

    // Verify redirect to dashboard
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('text=Welcome')).toBeVisible();
  });

  test('logout flow', async ({ page }) => {
    // Login first
    await page.goto('/sign-in');
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', process.env.TEST_USER_PASSWORD!);
    await page.click('button[type="submit"]');

    // Logout
    await page.click('button:has-text("Logout")');

    // Verify redirected to home
    await expect(page).toHaveURL('/');

    // Verify cannot access protected route
    await page.goto('/dashboard');
    await expect(page).toHaveURL(/.*sign-in/);
  });
});
```

### Mobile Responsive Testing
```typescript
test.describe('Mobile View', () => {
  test.use({ viewport: { width: 375, height: 667 } });  // iPhone size

  test('mobile menu works', async ({ page }) => {
    await page.goto('/dashboard');

    // Click hamburger menu
    await page.click('[aria-label="Open menu"]');

    // Menu should be visible
    await expect(page.locator('nav')).toBeVisible();

    // Click link
    await page.click('a:has-text("Settings")');

    // Should navigate
    await expect(page).toHaveURL('/dashboard/settings');
  });
});
```

### Cross-Browser Testing
```typescript
import { chromium, firefox, webkit } from '@playwright/test';

test.describe('Cross-Browser Tests', () => {
  for (const browserType of [chromium, firefox, webkit]) {
    test(`works in ${browserType.name()}`, async () => {
      const browser = await browserType.launch();
      const page = await browser.newPage();

      await page.goto('/dashboard');
      await expect(page.locator('h1')).toBeVisible();

      await browser.close();
    });
  }
});
```

## Customization Guide

1. **Replace placeholders**:
   - `{Feature}` → Feature name (e.g., `Payment`, `Content`)
   - `{feature}` → URL segment

2. **Setup authentication**:
   - Use test credentials
   - Store in env vars
   - Handle different auth providers

3. **Add assertions**:
   - Verify URLs
   - Check visibility
   - Validate content
   - Test error states

4. **Handle async operations**:
   - Use `waitFor` methods
   - Handle loading states
   - Deal with animations

## Security Checklist

- [x] **Test Credentials**: Use separate test accounts
- [x] **Data Isolation**: Clean up test data
- [x] **Auth Testing**: Test protected routes
- [x] **Error Scenarios**: Test unauthorized access
- [x] **Sensitive Data**: Don't expose real credentials

## Validation Commands

```bash
# Run all E2E tests
npx playwright test

# Run specific test file
npx playwright test e2e/{feature}-workflow.spec.ts

# Run with UI mode (visual debugging)
npx playwright test --ui

# Run headed (see browser)
npx playwright test --headed

# Generate test report
npx playwright show-report
```

## Example: Content Creation Flow

```typescript
import { test, expect } from '@playwright/test';

test.describe('Content Creation Workflow', () => {
  test.beforeEach(async ({ page }) => {
    // Login as admin
    await page.goto('/sign-in');
    await page.fill('input[name="email"]', process.env.ADMIN_EMAIL!);
    await page.fill('input[name="password"]', process.env.ADMIN_PASSWORD!);
    await page.click('button[type="submit"]');
    await page.waitForURL('/admin');
  });

  test('create and publish content', async ({ page }) => {
    // Navigate to content
    await page.goto('/admin/content');

    // Create new
    await page.click('text=Create Content');

    // Fill form
    await page.fill('input[name="title"]', 'Test Content');
    await page.selectOption('select[name="tier"]', 'PRO');
    await page.fill('textarea[name="body"]', 'Test content body');

    // Save as draft
    await page.click('button:has-text("Save Draft")');
    await expect(page.locator('text=Draft saved')).toBeVisible();

    // Publish
    await page.click('button:has-text("Publish")');
    await expect(page.locator('text=Published successfully')).toBeVisible();

    // Verify in list
    await page.goto('/admin/content');
    await expect(page.locator('text=Test Content')).toBeVisible();
    await expect(page.locator('text=Published')).toBeVisible();
  });
});
```

## Related Patterns

- [Authenticated Page](../ui/authenticated-page.md) - Pages to test
- [Form with Validation](../ui/form-with-validation.md) - Forms to test
- [API Integration Test](./api-integration-test.md) - API testing

---

**Pattern Source**: Playwright best practices
**Last Updated**: 2025-10-03
**Validated By**: System Architect
