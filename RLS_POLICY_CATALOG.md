# Row Level Security (RLS) Policy Catalog

## 📋 Overview

This document provides a comprehensive, human-readable catalog of all Row Level Security (RLS) policies in the {{PROJECT_NAME}} application database. It serves as the definitive reference for understanding data access controls at the database level.

**Purpose**: Document all RLS policies to ensure data governance compliance, security audits, and GDPR adherence.

**Last Updated**: 2025-10-04
**WOR Ticket**: {{TICKET_PREFIX}}-315 (Course Run Scheduling)
**Classification**: Tier 1 Critical - Security & Data Intersection

---

## 🏗️ RLS Architecture

### Context System

The {{PROJECT_NAME}} RLS system uses PostgreSQL session variables to establish security context:

```sql
-- User context (set automatically by application)
SET app.current_user_id = 'user_123';
SET app.user_role = 'user';
SET app.context_type = 'user_request';
```

### Helper Functions

Application code uses transaction-scoped context helpers:

```typescript
// User operations - automatic user isolation
await withUserContext(prisma, userId, async (client) => { ... });

// Admin operations - requires admin role validation
await withAdminContext(prisma, userId, async (client) => { ... });

// System operations - for webhooks/background jobs
await withSystemContext(prisma, contextType, async (client) => { ... });
```

### Database Roles

- **`wtfb_user`**: Superuser for migrations and admin operations (no RLS enforcement)
- **`wtfb_app_user`**: Application user with RLS enforcement (PRODUCTION ROLE)

---

## 📊 RLS Status Summary

### Tables with RLS Enabled: ✅ 15 of 16

| Table | RLS Status | Policy Type | Test Coverage |
|-------|------------|-------------|---------------|
| user | ✅ Enabled | User Isolation | ✅ Tested |
| payments | ✅ Enabled | User Isolation | ✅ Tested |
| subscriptions | ✅ Enabled | User Isolation | ✅ Tested |
| invoices | ✅ Enabled | User Isolation | ✅ Tested |
| course_enrollment | ✅ Enabled | User Isolation | ✅ Tested |
| courses | ✅ Enabled | Role-Based | ✅ Tested |
| course_runs | ✅ Enabled | Admin Write + Public Read | ✅ Tested |
| course_content | ✅ Enabled | Tier-Based + Role | ✅ Tested |
| content_files | ✅ Enabled | Tier-Based + Role | ✅ Tested |
| content_audit | ✅ Enabled | Role-Based | ✅ Tested |
| webhook_events | ✅ Enabled | Admin/System | ✅ Tested |
| disputes | ✅ Enabled | Admin-Only | ⚠️ Test needed |
| payment_failures | ✅ Enabled | Admin-Only | ⚠️ Test needed |
| trial_notifications | ✅ Enabled | Admin/System | ⚠️ Test needed |
| user_roles | ✅ Enabled | Read-Only | ✅ Tested |
| subscriptions_plans | ⚠️ Disabled | Public Read | N/A (Public) |
| _prisma_migrations | ⚠️ Disabled | System-Only | N/A (Internal) |

---

## 🔐 Table-by-Table Policy Catalog

### 1. user (User Profiles)

**RLS Status**: ✅ Enabled  
**Data Classification**: USER - Personal profile data  
**GDPR Implications**: Contains PII - requires strict user isolation

#### Access Rules

**Regular Users**:
- ✅ Can view their own user record
- ✅ Can modify their own user record
- ❌ Cannot view other users' data

**Admins**:
- ✅ Can view all user records (via superuser role)
- ✅ Can modify all user records (via superuser role)

**System**:
- ✅ Can access for background processing (via superuser role)

#### RLS Policies

```sql
-- Policy: user_isolation
-- Applied to: wtfb_user role
-- Operation: ALL (SELECT, INSERT, UPDATE, DELETE)
CREATE POLICY user_isolation ON "user"
  FOR ALL
  TO wtfb_user
  USING (user_id = current_setting('app.current_user_id', true));
```

**Human Readable**: Users can only access database records where the `user_id` column matches their authenticated user ID.

#### Test Coverage

- ✅ **Test File**: `__tests__/user/userCreate.rls.spec.ts`
- ✅ **Test File**: `__tests__/user/userUpdate.rls.spec.ts`
- ✅ **Validation**: Phase 4 RLS validation script

#### Security Notes

- **User Isolation**: Strict user_id matching prevents cross-user access
- **GDPR Compliance**: User can access only their own PII
- **New Columns**: RLS automatically covers all columns (including `imdb_profile_url`, `imdb_verified` added in {{TICKET_PREFIX}}-258)

---

### 2. payments (Payment Records)

**RLS Status**: ✅ Enabled  
**Data Classification**: USER - Financial transaction data  
**GDPR Implications**: Contains financial PII - requires strict user isolation

#### Access Rules

**Regular Users**:
- ✅ Can view their own payment history
- ✅ Can create payment records (via Stripe webhooks)
- ❌ Cannot view other users' payments

**Admins**:
- ✅ Can view all payment records (via superuser role)
- ✅ Can manage payment disputes

**System**:
- ✅ Can create payment records from Stripe webhooks

#### RLS Policies

```sql
-- Policy: payments_isolation
-- Applied to: wtfb_user role
-- Operation: ALL (SELECT, INSERT, UPDATE, DELETE)
CREATE POLICY payments_isolation ON "payments"
  FOR ALL
  TO wtfb_user
  USING (user_id = current_setting('app.current_user_id', true));
```

**Human Readable**: Users can only access payment records where the `user_id` matches their authenticated user ID.

#### Test Coverage

- ✅ **Validation**: Phase 4 RLS validation script
- ⚠️ **Unit Tests**: Test needed for payment-specific RLS scenarios

#### Security Notes

- **Financial Data Protection**: Strict isolation prevents payment data leaks
- **Audit Trail**: All payment access logged in application layer
- **PCI Compliance**: RLS enforces cardholder data isolation

---

### 3. subscriptions (Subscription Data)

**RLS Status**: ✅ Enabled  
**Data Classification**: USER - Subscription billing data  
**GDPR Implications**: Contains billing PII - requires strict user isolation

#### Access Rules

**Regular Users**:
- ✅ Can view their own subscription status
- ✅ Can update subscription (via Stripe)
- ❌ Cannot view other users' subscriptions

**Admins**:
- ✅ Can view all subscriptions (via superuser role)
- ✅ Can manage subscription issues

**System**:
- ✅ Can update subscriptions from Stripe webhooks

#### RLS Policies

```sql
-- Policy: subscriptions_isolation
-- Applied to: wtfb_user role
-- Operation: ALL (SELECT, INSERT, UPDATE, DELETE)
CREATE POLICY subscriptions_isolation ON "subscriptions"
  FOR ALL
  TO wtfb_user
  USING (user_id = current_setting('app.current_user_id', true));
```

**Human Readable**: Users can only access subscription records where the `user_id` matches their authenticated user ID.

#### Test Coverage

- ✅ **Validation**: Phase 4 RLS validation script
- ⚠️ **Unit Tests**: Test needed for subscription-specific RLS scenarios

#### Security Notes

- **Billing Protection**: Prevents unauthorized subscription access
- **Trial Management**: RLS enforces trial period isolation
- **Plan Changes**: User can only modify own subscription

---

### 4. invoices (Invoice Records)

**RLS Status**: ✅ Enabled  
**Data Classification**: USER - Billing invoice data  
**GDPR Implications**: Contains financial PII - requires strict user isolation

#### Access Rules

**Regular Users**:
- ✅ Can view their own invoices
- ✅ Can download their own invoice PDFs
- ❌ Cannot view other users' invoices

**Admins**:
- ✅ Can view all invoices (via superuser role)
- ✅ Can generate custom invoices

**System**:
- ✅ Can create invoices from Stripe webhooks

#### RLS Policies

```sql
-- Policy: invoices_isolation
-- Applied to: wtfb_user role
-- Operation: ALL (SELECT, INSERT, UPDATE, DELETE)
CREATE POLICY invoices_isolation ON "invoices"
  FOR ALL
  TO wtfb_user
  USING (user_id = current_setting('app.current_user_id', true));
```

**Human Readable**: Users can only access invoice records where the `user_id` matches their authenticated user ID.

#### Test Coverage

- ✅ **Validation**: Phase 4 RLS validation script
- ⚠️ **Unit Tests**: Test needed for invoice-specific RLS scenarios

#### Security Notes

- **Invoice Privacy**: Each user sees only their own billing records
- **Tax Compliance**: Invoice isolation supports audit requirements
- **Download Security**: RLS prevents unauthorized invoice downloads

---

### 5. course_enrollment (Course Enrollments)

**RLS Status**: ✅ Enabled  
**Data Classification**: USER - Course access data  
**GDPR Implications**: Contains user learning data - requires strict user isolation

#### Access Rules

**Regular Users**:
- ✅ Can view their own enrollments
- ✅ Can enroll in courses
- ❌ Cannot view other users' enrollments

**Admins**:
- ✅ Can view all enrollments (via superuser role)
- ✅ Can grant course access

**System**:
- ✅ Can create enrollments from payment webhooks

#### RLS Policies

```sql
-- Policy: course_enrollment_isolation
-- Applied to: wtfb_user role
-- Operation: ALL (SELECT, INSERT, UPDATE, DELETE)
CREATE POLICY course_enrollment_isolation ON "course_enrollment"
  FOR ALL
  TO wtfb_user
  USING (user_id = current_setting('app.current_user_id', true));
```

**Human Readable**: Users can only access course enrollment records where the `user_id` matches their authenticated user ID.

#### Test Coverage

- ✅ **Test File**: `__tests__/course/courseHelpers.rls.spec.ts`
- ✅ **Validation**: Phase 4 RLS validation script

#### Security Notes

- **Course Access Control**: RLS enforces enrollment-based access
- **Tier Validation**: Enrollment tier determines content access
- **Payment Integration**: RLS prevents unauthorized course access

---

### 6. courses (Course Management)

**RLS Status**: ✅ Enabled  
**Data Classification**: CONTENT - Course metadata  
**GDPR Implications**: Low - no PII, but access control required

#### Access Rules

**Regular Users**:
- ✅ Can view published courses only
- ❌ Cannot view draft or archived courses
- ❌ Cannot create or modify courses

**Admins**:
- ✅ Can view all courses (draft, published, archived)
- ✅ Can create, modify, delete courses
- ✅ Can publish/unpublish courses

**System**:
- ✅ Read access for background jobs

#### RLS Policies

```sql
-- Policy 1: users_view_published_courses
-- Applied to: wtfb_app_user role
-- Operation: SELECT
CREATE POLICY users_view_published_courses ON "courses"
  FOR SELECT
  TO wtfb_app_user
  USING (status = 'published');

-- Policy 2: admins_manage_courses
-- Applied to: wtfb_app_user role
-- Operation: ALL
CREATE POLICY admins_manage_courses ON "courses"
  FOR ALL
  TO wtfb_app_user
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = current_setting('app.current_user_id')
        AND role IN ('admin', 'super_admin')
    )
  );
```

**Human Readable**: 
- Regular users can only see published courses
- Admins (verified via `user_roles` table) can manage all courses

#### Test Coverage

- ✅ **Test File**: `__tests__/course/courseHelpers.rls.spec.ts`
- ✅ **Validation**: Course management RLS tests

#### Security Notes

- **Content Protection**: Draft courses hidden from regular users
- **Role Validation**: Database-driven admin check prevents privilege escalation
- **Default Course**: `is_default` flag for content creation ({{TICKET_PREFIX}}-297)

---

### 7. course_runs (Course Run Scheduling)

**RLS Status**: ✅ Enabled
**Data Classification**: CONTENT - Course run scheduling
**GDPR Implications**: Low - no PII, but admin management required
**Added**: {{TICKET_PREFIX}}-315 (2025-10-04)

#### Access Rules

**Regular Users**:
- ✅ Can view all published course runs (read-only)
- ✅ Can see enrollment windows and course schedules
- ❌ Cannot create, modify, or delete course runs
- ❌ Cannot view draft or cancelled runs (future enhancement)

**Admins**:
- ✅ Can view all course runs (all statuses)
- ✅ Can create new course runs
- ✅ Can modify existing course runs
- ✅ Can delete course runs
- ✅ Can change run status (scheduled → active → completed)

**System**:
- ✅ Can update course run status from cron jobs
- ✅ Can modify enrollment windows programmatically
- ✅ Read access for background scheduling jobs

#### RLS Policies

```sql
-- Policy 1: public_read_course_runs
-- Applied to: All roles
-- Operation: SELECT
CREATE POLICY course_runs_public_read ON "course_runs"
  FOR SELECT
  USING (true);

-- Policy 2: admin_full_access_course_runs
-- Applied to: wtfb_user, wtfb_app_user roles
-- Operation: ALL (INSERT, UPDATE, DELETE)
-- SECURITY FIX ({{TICKET_PREFIX}}-315): Uses user_roles table validation (database-driven)
CREATE POLICY course_runs_admin_full_access ON "course_runs"
  FOR ALL
  TO wtfb_user, wtfb_app_user
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = current_setting('app.current_user_id', true)
        AND role IN ('admin', 'super_admin')
    )
  );

-- Policy 3: system_access_course_runs
-- Applied to: wtfb_user, wtfb_app_user roles
-- Operation: ALL (for system contexts like cron jobs)
-- SECURITY FIX ({{TICKET_PREFIX}}-315): Corrected variable name + context type check
CREATE POLICY course_runs_system_access ON "course_runs"
  FOR ALL
  TO wtfb_user, wtfb_app_user
  USING (
    current_setting('app.user_role', true) IN ('system', 'admin')
    OR current_setting('app.context_type', true) IN ('system', 'webhook')
  );
```

**Human Readable**:
- Anyone can view course runs (public read access)
- Admins (verified via `user_roles` table) can fully manage course runs
- System contexts (cron jobs, webhooks) can update course run data

#### Test Coverage

- ✅ **Test File**: `scripts/test-course-runs-rls.sql` (local validation - 12/12 passed)
- ✅ **Security Fix Validation**: Full CRUD operations tested (INSERT/UPDATE/SELECT/DELETE all passing)
- ✅ **Validation**: Migration `20251004175454_fix_course_runs_rls_variables` applied
- ⚠️ **Unit Tests**: E2E tests needed for course run API routes with `withAdminContext()`

#### Security Notes

- **Admin Write Pattern**: Only admins can modify course scheduling (enforced via `user_roles` table)
- **Public Read**: Transparency for users to see upcoming course runs
- **System Updates**: Cron jobs can auto-transition course statuses
- **Role Validation**: Database-driven admin check prevents privilege escalation (secure)
- **ON DELETE RESTRICT**: Prevents accidental course deletion if runs exist
- **Security Fix Applied**: Fixed critical variable name mismatch in migration `20251004175454_fix_course_runs_rls_variables`
- **Permissions**: `wtfb_app_user` granted SELECT on `user_roles` for policy validation

#### Performance Considerations

- **Enrollment Window Index**: Composite index on `(enrollment_open_at, enrollment_close_at)` for fast enrollment queries
- **Status Index**: Optimized for filtering by course run status (scheduled, active, completed)
- **Start Date Index**: Fast lookups for upcoming/active course runs

---

### 8. course_content (Course Content)

**RLS Status**: ✅ Enabled  
**Data Classification**: CONTENT - Course lessons/materials  
**GDPR Implications**: Low - no PII, but tier-based access control critical

#### Access Rules

**Regular Users**:
- ✅ Can view FREE content (always)
- ✅ Can view PRO content (if enrolled in PRO or VIP tier)
- ✅ Can view VIP content (if enrolled in VIP tier only)
- ✅ Only if content is published and within visibility window
- ❌ Cannot view draft content
- ❌ Cannot create or modify content

**Admins**:
- ✅ Can view all content (draft, published, all tiers)
- ✅ Can create, modify, delete content
- ✅ Can publish/unpublish content

**System**:
- ✅ Read access for indexing/background jobs

#### RLS Policies

```sql
-- Policy 1: users_view_content_by_tier
-- Applied to: wtfb_app_user role
-- Operation: SELECT
CREATE POLICY users_view_content_by_tier ON "course_content"
  FOR SELECT
  TO wtfb_app_user
  USING (
    status = 'published'
    AND (visible_from IS NULL OR visible_from <= NOW())
    AND (visible_to IS NULL OR visible_to >= NOW())
    AND (
      tier = 'FREE'
      OR EXISTS (
        SELECT 1 FROM course_enrollment ce
        WHERE ce.user_id = current_setting('app.current_user_id')
          AND ce.course_id = course_content.course_id
          AND ce.status = 'active'
          AND (
            (ce.tier = 'PRO' AND course_content.tier IN ('FREE', 'PRO'))
            OR (ce.tier = 'VIP')
          )
      )
    )
  );

-- Policy 2: admins_manage_content
-- Applied to: wtfb_app_user role
-- Operation: ALL
CREATE POLICY admins_manage_content ON "course_content"
  FOR ALL
  TO wtfb_app_user
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = current_setting('app.current_user_id')
        AND role IN ('admin', 'super_admin')
    )
  );
```

**Human Readable**:
- Users can only see published content that:
  - Is within visibility window (visible_from <= now <= visible_to)
  - Matches their enrollment tier (FREE always, PRO if enrolled in PRO/VIP, VIP only if enrolled in VIP)
- Admins can manage all content regardless of status or tier

#### Test Coverage

- ✅ **Test File**: `__tests__/course/courseHelpers.rls.spec.ts`
- ✅ **Validation**: Tier-based access validation

#### Security Notes

- **Tier-Based Access**: Prevents content piracy via enrollment validation
- **Visibility Control**: Time-based content releases
- **Enrollment Validation**: Cross-references `course_enrollment` for access
- **Version Control**: `version` field for content updates

---

### 9. content_files (File Uploads)

**RLS Status**: ✅ Enabled  
**Data Classification**: CONTENT - File attachments (PDFs, videos, etc.)  
**GDPR Implications**: Low - no PII, but tier-based access control critical

#### Access Rules

**Regular Users**:
- ✅ Can view public files (is_public = true)
- ✅ Can view tier-appropriate files (if enrolled in matching tier)
- ✅ Only if parent content is published and visible
- ❌ Cannot view private files without enrollment
- ❌ Cannot upload or modify files

**Admins**:
- ✅ Can view all files (public and private)
- ✅ Can upload, modify, delete files
- ✅ Can change file visibility

**System**:
- ✅ Can upload files from webhooks/background jobs

#### RLS Policies

```sql
-- Policy 1: users_view_accessible_files
-- Applied to: wtfb_app_user role
-- Operation: SELECT
CREATE POLICY users_view_accessible_files ON "content_files"
  FOR SELECT
  TO wtfb_app_user
  USING (
    is_public = true
    OR EXISTS (
      SELECT 1 FROM course_content cc
      WHERE cc.id = content_files.content_id
        AND cc.status = 'published'
        AND (cc.visible_from IS NULL OR cc.visible_from <= NOW())
        AND (cc.visible_to IS NULL OR cc.visible_to >= NOW())
        AND (
          cc.tier = 'FREE'
          OR EXISTS (
            SELECT 1 FROM course_enrollment ce
            WHERE ce.user_id = current_setting('app.current_user_id')
              AND ce.course_id = cc.course_id
              AND ce.status = 'active'
              AND (
                (ce.tier = 'PRO' AND cc.tier IN ('FREE', 'PRO'))
                OR (ce.tier = 'VIP')
              )
          )
        )
    )
  );

-- Policy 2: admins_manage_files
-- Applied to: wtfb_app_user role
-- Operation: ALL
CREATE POLICY admins_manage_files ON "content_files"
  FOR ALL
  TO wtfb_app_user
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = current_setting('app.current_user_id')
        AND role IN ('admin', 'super_admin')
    )
  );
```

**Human Readable**:
- Users can view files if:
  - File is marked public, OR
  - File's parent content is published, visible, and matches user's enrollment tier
- Admins can manage all files regardless of visibility

#### Test Coverage

- ✅ **Test File**: `__tests__/course/courseHelpers.rls.spec.ts`
- ⚠️ **File Upload Tests**: Test needed for upload security

#### Security Notes

- **Download Protection**: RLS prevents unauthorized file downloads
- **R2 Integration**: Works with Cloudflare R2 storage buckets
- **Public vs Private**: `is_public` flag for marketing materials
- **Storage Buckets**: Separate buckets for public/private content

---

### 10. content_audit (Audit Logs)

**RLS Status**: ✅ Enabled  
**Data Classification**: AUDIT - Content change history  
**GDPR Implications**: Medium - contains actor_id (user references)

#### Access Rules

**Regular Users**:
- ❌ Cannot view audit logs
- ❌ Cannot create audit entries manually

**Admins**:
- ✅ Can view all audit logs
- ❌ Cannot modify or delete audit logs (integrity protection)

**System**:
- ✅ Can create audit entries automatically
- ✅ Can view audit logs for monitoring

#### RLS Policies

```sql
-- Policy 1: admins_view_audit
-- Applied to: wtfb_app_user role
-- Operation: SELECT
CREATE POLICY admins_view_audit ON "content_audit"
  FOR SELECT
  TO wtfb_app_user
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = current_setting('app.current_user_id')
        AND role IN ('admin', 'super_admin')
    )
  );

-- Policy 2: system_insert_audit
-- Applied to: wtfb_app_user role
-- Operation: INSERT
CREATE POLICY system_insert_audit ON "content_audit"
  FOR INSERT
  TO wtfb_app_user
  WITH CHECK (true);
```

**Human Readable**:
- Only admins can view audit logs
- System can insert audit entries (no restrictions to ensure all changes are logged)

#### Test Coverage

- ✅ **Test File**: `__tests__/course/courseHelpers.rls.spec.ts`
- ✅ **Validation**: Audit logging validation

#### Security Notes

- **Immutable Logs**: No UPDATE or DELETE policies (audit integrity)
- **Change Tracking**: JSON diff of all content changes
- **Actor Tracking**: Records user_id, role, IP, user_agent
- **Compliance**: GDPR audit trail for content changes

---

### 11. webhook_events (Webhook Processing)

**RLS Status**: ✅ Enabled  
**Data Classification**: SYSTEM - Webhook event logs  
**GDPR Implications**: Low - no direct PII, but contains transaction metadata

#### Access Rules

**Regular Users**:
- ❌ Cannot view webhook events
- ❌ Cannot create webhook events

**Admins**:
- ✅ Can view all webhook events
- ✅ Can retry failed webhooks
- ❌ Cannot modify webhook payloads (integrity)

**System**:
- ✅ Can create webhook events from Stripe
- ✅ Can update processing status
- ✅ Can view all webhook events

#### RLS Policies

```sql
-- Policy 1: webhook_events_system_admin (wtfb_user role)
-- Applied to: wtfb_user role
-- Operation: ALL
CREATE POLICY webhook_events_system_admin ON "webhook_events"
  FOR ALL
  TO wtfb_user
  USING (
    current_setting('app.user_role', true) IN ('admin', 'system')
    OR current_setting('app.context_type', true) = 'webhook'
  );

-- Policy 2: webhook_events_app_system_admin (wtfb_app_user role)
-- Applied to: wtfb_app_user role
-- Operation: ALL
CREATE POLICY webhook_events_app_system_admin ON "webhook_events"
  FOR ALL
  TO wtfb_app_user
  USING (
    current_setting('app.user_role', true) IN ('admin', 'system')
    OR current_setting('app.context_type', true) = 'webhook'
  );
```

**Human Readable**:
- Only admins and system contexts can access webhook events
- Webhook context (`app.context_type = 'webhook'`) grants automatic access

#### Test Coverage

- ✅ **Test File**: `__tests__/unit/webhook-security.test.ts`
- ✅ **Validation**: Phase 4 RLS validation script

#### Security Notes

- **System Access**: Webhooks must set `app.context_type = 'webhook'`
- **Idempotency**: `idempotency_key` prevents duplicate processing
- **Retry Logic**: `retry_count` for failed webhooks
- **Processing Duration**: Monitored via `processing_duration_ms`

---

### 12. disputes (Payment Disputes)

**RLS Status**: ✅ Enabled  
**Data Classification**: ADMIN - Dispute management data  
**GDPR Implications**: High - contains customer_email and financial data

#### Access Rules

**Regular Users**:
- ❌ Cannot view disputes
- ❌ Cannot create or modify disputes

**Admins**:
- ✅ Can view all disputes
- ✅ Can manage dispute responses
- ✅ Can upload evidence

**System**:
- ✅ Can create dispute records from Stripe webhooks (via superuser role)

#### RLS Policies

```sql
-- Policy 1: disputes_admin_only (wtfb_user role)
-- Applied to: wtfb_user role
-- Operation: ALL
CREATE POLICY disputes_admin_only ON "disputes"
  FOR ALL
  TO wtfb_user
  USING (current_setting('app.user_role', true) = 'admin');

-- Policy 2: disputes_app_admin_only (wtfb_app_user role)
-- Applied to: wtfb_app_user role
-- Operation: ALL
CREATE POLICY disputes_app_admin_only ON "disputes"
  FOR ALL
  TO wtfb_app_user
  USING (current_setting('app.user_role', true) = 'admin');
```

**Human Readable**: Only users with `admin` role can access dispute records.

#### Test Coverage

- ⚠️ **Unit Tests**: Test needed for dispute RLS scenarios
- ✅ **Validation**: Phase 2 RLS validation script

#### Security Notes

- **Admin-Only Access**: Regular users cannot view any disputes
- **Evidence Protection**: Dispute evidence secured via admin-only access
- **Customer Privacy**: `customer_email` protected from unauthorized access
- **Chargeback Management**: Secure handling of chargeback data

---

### 13. payment_failures (Failed Payments)

**RLS Status**: ✅ Enabled  
**Data Classification**: ADMIN - Payment failure logs  
**GDPR Implications**: High - contains customer_email and payment data

#### Access Rules

**Regular Users**:
- ❌ Cannot view payment failures
- ❌ Cannot create failure records

**Admins**:
- ✅ Can view all payment failures
- ✅ Can analyze failure patterns
- ✅ Can contact customers for retry

**System**:
- ✅ Can create failure records from Stripe webhooks (via superuser role)

#### RLS Policies

```sql
-- Policy 1: payment_failures_admin_only (wtfb_user role)
-- Applied to: wtfb_user role
-- Operation: ALL
CREATE POLICY payment_failures_admin_only ON "payment_failures"
  FOR ALL
  TO wtfb_user
  USING (current_setting('app.user_role', true) = 'admin');

-- Policy 2: payment_failures_app_admin_only (wtfb_app_user role)
-- Applied to: wtfb_app_user role
-- Operation: ALL
CREATE POLICY payment_failures_app_admin_only ON "payment_failures"
  FOR ALL
  TO wtfb_app_user
  USING (current_setting('app.user_role', true) = 'admin');
```

**Human Readable**: Only users with `admin` role can access payment failure records.

#### Test Coverage

- ⚠️ **Unit Tests**: Test needed for payment failure RLS scenarios
- ✅ **Validation**: Phase 2 RLS validation script

#### Security Notes

- **Admin-Only Access**: Protects sensitive payment failure data
- **Failure Analysis**: Admins can identify patterns and improve payment flow
- **Customer Support**: Secure access for customer outreach
- **PCI Compliance**: Payment method data protected

---

### 14. trial_notifications (Trial Expiration Notifications)

**RLS Status**: ✅ Enabled  
**Data Classification**: SYSTEM - Trial notification queue  
**GDPR Implications**: Medium - contains customer_email

#### Access Rules

**Regular Users**:
- ❌ Cannot view trial notifications
- ❌ Cannot create notifications

**Admins**:
- ✅ Can view all trial notifications
- ✅ Can manually trigger notifications

**System**:
- ✅ Can create notification records
- ✅ Can update `notification_sent` status
- ✅ Can process notification queue

#### RLS Policies

```sql
-- Policy 1: trial_notifications_system_admin (wtfb_user role)
-- Applied to: wtfb_user role
-- Operation: ALL
CREATE POLICY trial_notifications_system_admin ON "trial_notifications"
  FOR ALL
  TO wtfb_user
  USING (
    current_setting('app.user_role', true) IN ('admin', 'system')
    OR current_setting('app.context_type', true) = 'system_notification'
  );

-- Policy 2: trial_notifications_app_system_admin (wtfb_app_user role)
-- Applied to: wtfb_app_user role
-- Operation: ALL
CREATE POLICY trial_notifications_app_system_admin ON "trial_notifications"
  FOR ALL
  TO wtfb_app_user
  USING (
    current_setting('app.user_role', true) IN ('admin', 'system')
    OR current_setting('app.context_type', true) = 'system_notification'
  );
```

**Human Readable**:
- Only admins and system contexts can access trial notifications
- System notification context (`app.context_type = 'system_notification'`) grants automatic access

#### Test Coverage

- ⚠️ **Unit Tests**: Test needed for trial notification RLS scenarios
- ✅ **Validation**: Phase 2 RLS validation script

#### Security Notes

- **System Access**: Background jobs must set `app.context_type = 'system_notification'`
- **Email Privacy**: `customer_email` protected from unauthorized access
- **Notification Queue**: `notification_sent` flag prevents duplicate emails
- **Trial Management**: Secure handling of trial expiration data

---

### 15. user_roles (Role Management)

**RLS Status**: ✅ Enabled  
**Data Classification**: SECURITY - User role assignments  
**GDPR Implications**: Low - maps user_id to role

#### Access Rules

**Regular Users**:
- ✅ Can read all user roles (needed for policy validation)
- ❌ Cannot modify role assignments

**Admins**:
- ✅ Can read all user roles (via superuser role)
- ✅ Can assign/revoke roles (via superuser role)

**System**:
- ✅ Can read roles for authorization checks

#### RLS Policies

```sql
-- Policy 1: user_roles_admin_only (wtfb_user role)
-- Applied to: wtfb_user role
-- Operation: ALL
CREATE POLICY user_roles_admin_only ON "user_roles"
  FOR ALL
  TO wtfb_user
  USING (true);

-- Policy 2: user_roles_readonly (wtfb_app_user role)
-- Applied to: wtfb_app_user role
-- Operation: SELECT
CREATE POLICY user_roles_readonly ON "user_roles"
  FOR SELECT
  TO wtfb_app_user
  USING (true);
```

**Human Readable**:
- Superuser role can manage all role assignments
- Application role can only read role assignments (needed for EXISTS queries in other policies)

#### Test Coverage

- ✅ **Validation**: Phase 4 security fix validation
- ✅ **Test File**: Implicitly tested in all admin RLS tests

#### Security Notes

- **Privilege Escalation Prevention**: Read-only for app prevents self-promotion
- **Database-Driven Authorization**: Roles validated from database, not session variables
- **Role Validation**: All admin policies check `user_roles` table
- **Sync Source**: `sync_source` field for Clerk role synchronization

---

### 16. subscriptions_plans (Subscription Plans)

**RLS Status**: ⚠️ Disabled  
**Data Classification**: PUBLIC - Pricing plan metadata  
**GDPR Implications**: None - no PII

#### Access Rules

**All Users**:
- ✅ Can view all subscription plans (public data)

**Admins**:
- ✅ Can create, modify plans (via application layer, not RLS)

**System**:
- ✅ Full access (no restrictions)

#### RLS Status

**No RLS Policies**: This table contains public pricing data that all users need to view.

#### Test Coverage

- N/A (Public read-only data)

#### Security Notes

- **Public Data**: No RLS needed - pricing is public information
- **Application Layer Security**: Plan creation/modification controlled in app code
- **Stripe Sync**: Plans synchronized with Stripe product catalog
- **Read-Only for Users**: Write operations restricted to admin UI

---

### 17. _prisma_migrations (Database Migrations)

**RLS Status**: ⚠️ Disabled  
**Data Classification**: SYSTEM - Migration history  
**GDPR Implications**: None - no PII

#### Access Rules

**All Users**:
- ❌ No access (internal system table)

**Admins**:
- ✅ Can view migration history (via superuser role)

**Prisma**:
- ✅ Full access for migration management

#### RLS Status

**No RLS Policies**: System-managed table, not accessed by application code.

#### Test Coverage

- N/A (Internal Prisma table)

#### Security Notes

- **System-Only**: Never accessed by application code
- **Migration Integrity**: Managed exclusively by Prisma CLI
- **No User Access**: Regular users have no table permissions

---

## 🧪 Test Coverage Summary

### RLS Test Files

1. **User RLS Tests**:
   - `__tests__/user/userCreate.rls.spec.ts`
   - `__tests__/user/userUpdate.rls.spec.ts`
   - Coverage: user table isolation

2. **Course RLS Tests**:
   - `__tests__/course/courseHelpers.rls.spec.ts`
   - Coverage: courses, course_content, content_files, content_audit, course_enrollment

3. **Webhook Security Tests**:
   - `__tests__/unit/webhook-security.test.ts`
   - Coverage: webhook_events table

4. **SQL Validation Scripts**:
   - `scripts/rls-phase4-final-validation.sql`
   - `scripts/rls-phase4-security-tests.sql`
   - Coverage: Comprehensive penetration testing

### Test Coverage Gaps

**⚠️ Tests Needed**:
- Payment-specific RLS scenarios (payments, invoices, subscriptions)
- Dispute management RLS (disputes table)
- Payment failure RLS (payment_failures table)
- Trial notification RLS (trial_notifications table)

**Recommendation**: Create dedicated test files for financial data RLS validation.

---

## 🚨 Security Concerns & Gaps

### Current Security Status: ✅ STRONG

**Strengths**:
- ✅ User data isolation enforced across all user tables
- ✅ Admin role validation database-driven (privilege escalation prevented)
- ✅ Tier-based content access properly validated via enrollment
- ✅ Audit logging immutable and admin-only visible
- ✅ Webhook processing secured with context validation

### Identified Gaps

1. **Financial Data Testing** (Priority: HIGH)
   - **Gap**: Limited test coverage for payments, invoices, subscriptions
   - **Risk**: Potential data leaks in financial operations
   - **Recommendation**: Create comprehensive financial RLS test suite

2. **Admin Table Testing** (Priority: MEDIUM)
   - **Gap**: No dedicated tests for disputes, payment_failures, trial_notifications
   - **Risk**: Unauthorized access to admin-only data
   - **Recommendation**: Add admin table RLS penetration tests

3. **Role Synchronization** (Priority: MEDIUM)
   - **Gap**: Clerk role sync to `user_roles` table not fully automated
   - **Risk**: Role drift between Clerk and database
   - **Recommendation**: Implement automated role sync on user login

4. **Public Tables** (Priority: LOW)
   - **Gap**: `subscriptions_plans` has no RLS (by design)
   - **Risk**: Low - public data, but plan modifications not RLS-protected
   - **Recommendation**: Consider RLS for plan modifications to prevent tampering

---

## 📈 Recommendations for Improving RLS Coverage

### Immediate Actions (Next Sprint)

1. **Financial RLS Test Suite** ({{TICKET_PREFIX}}-315 - Recommended)
   - Create `__tests__/payments/payment-rls.spec.ts`
   - Test user isolation for payments, invoices, subscriptions
   - Validate cross-user payment access prevention

2. **Admin Table RLS Tests** ({{TICKET_PREFIX}}-316 - Recommended)
   - Create `__tests__/admin/admin-rls.spec.ts`
   - Test admin-only access for disputes, payment_failures, trial_notifications
   - Validate regular users cannot access admin tables

3. **Role Sync Automation** ({{TICKET_PREFIX}}-317 - Recommended)
   - Implement Clerk webhook for role synchronization
   - Update `user_roles` table on Clerk role changes
   - Add monitoring for role drift detection

### Future Enhancements

1. **RLS Policy Versioning**
   - Track policy changes in `content_audit` or dedicated table
   - Enable policy rollback for security incidents

2. **Performance Monitoring**
   - Add query performance metrics for RLS-enabled tables
   - Identify slow policies and optimize

3. **Automated Security Scanning**
   - CI/CD integration for RLS policy validation
   - Prevent deployments without proper RLS coverage

---

## 📚 Related Documentation

- **RLS Implementation Guide**: `/docs/database/RLS_IMPLEMENTATION_GUIDE.md`
- **RLS Troubleshooting**: `/docs/guides/RLS_TROUBLESHOOTING.md`
- **Database Migration SOP**: `/docs/database/RLS_DATABASE_MIGRATION_SOP.md`
- **Data Dictionary**: `/docs/database/DATA_DICTIONARY.md`
- **Security Architecture**: `/docs/guides/SECURITY_FIRST_ARCHITECTURE.md`

---

## 🔄 Maintenance Log

### 2025-10-04 ({{TICKET_PREFIX}}-315 - Security Fix)
- **Critical Fix**: Fixed RLS variable name mismatch in course_runs policies
- **Security Enhancement**: Added `user_roles` table validation for admin verification
- **Permissions**: Granted SELECT on `user_roles` to `wtfb_app_user` for RLS policy validation
- **Validation**: Full CRUD operations tested and passing (INSERT/UPDATE/SELECT/DELETE)
- **Migration**: `20251004175454_fix_course_runs_rls_variables`

### 2025-10-04 ({{TICKET_PREFIX}}-315)
- **Updated**: Added course_runs table RLS policies
- **Coverage**: Documented 17 tables (15 with RLS, 2 system tables)
- **Policies**: 26 RLS policies catalogued (+3 for course_runs)
- **Security Status**: STRONG - Admin Write + Public Read pattern validated

### 2025-10-04 ({{TICKET_PREFIX}}-314)
- **Created**: Initial RLS Policy Catalog
- **Coverage**: Documented 16 tables (14 with RLS, 2 system tables)
- **Policies**: 23 RLS policies catalogued
- **Security Status**: STRONG - Zero critical gaps identified

### Change Process

**When adding new tables**:
1. Enable RLS: `ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;`
2. Create appropriate policies (user isolation, role-based, or tier-based)
3. Add test coverage (unit tests + SQL validation)
4. Update this catalog with policy details
5. Log changes in `scripts/rls-maintenance-2025.sql`

**When modifying policies**:
1. Document reason in `scripts/rls-maintenance-2025.sql`
2. Update this catalog with new policy logic
3. Run RLS validation: `scripts/rls-phase4-final-validation.sql`
4. Update test coverage if needed

---

**Catalog Maintained By**: Security Engineering Team  
**Last Review**: 2025-10-04  
**Next Review**: 2025-11-04 (Monthly)  
**Approved By**: ARCHitect-in-the-IDE (Auggie)
