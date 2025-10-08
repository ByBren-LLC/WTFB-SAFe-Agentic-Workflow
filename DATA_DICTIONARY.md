# 📊 {{PROJECT_NAME}} Database Data Dictionary

> **Single Source of Truth for AI Agents and Development Context**
>
> **Last Updated**: 2025-10-06 ({{TICKET_PREFIX}}-321 - Free Tools Bonus Download Tracking)
> **Schema Version**: 2.4
> **Database**: PostgreSQL with Prisma ORM
> **Total Tables**: 17
> **Total RLS Policies**: 28

---

## 🎯 Quick Reference

| Metric | Count | Notes |
|---------|-------|-------|
| **User Data Tables** | 12 | Tables with user_id (RLS protected) |
| **System Tables** | 2 | Global reference tables |
| **Admin Tables** | 1 | Admin-only access |
| **Core Entities** | 5 | user, payments, subscriptions, invoices, courses |
| **Latest Additions** | {{TICKET_PREFIX}}-319, {{TICKET_PREFIX}}-315 | Newsletter leads, Course run scheduling |

---

## 📋 Table Overview

| Table | Type | Columns | RLS | Purpose | Last Modified |
|-------|------|---------|-----|---------|---------------|
| **user** | Core | 12 | ✅ | User profiles & authentication | {{TICKET_PREFIX}}-259 |
| **payments** | Financial | 11 | ✅ | Payment processing records | Core |
| **subscriptions** | Financial | 11 | ✅ | Subscription management | Core |
| **invoices** | Financial | 10 | ✅ | Billing and invoices | Core |
| **newsletter_leads** | Marketing | 19 | ✅ | Newsletter signup tracking | {{TICKET_PREFIX}}-321 |
| **courses** | Content | 9 | ✅ | Course definitions | {{TICKET_PREFIX}}-222 |
| **course_runs** | Content | 13 | ✅ | Course run scheduling | {{TICKET_PREFIX}}-315 |
| **course_content** | Content | 21 | ✅ | Course content management | {{TICKET_PREFIX}}-222 |
| **course_enrollment** | Content | 12 | ✅ | User enrollments | {{TICKET_PREFIX}}-189 |
| **content_files** | Content | 12 | ✅ | File attachments | {{TICKET_PREFIX}}-222 |
| **content_audit** | System | 10 | ✅ | Content change audit | {{TICKET_PREFIX}}-222 |
| **user_roles** | Access | 8 | ✅ | Role-based access control | {{TICKET_PREFIX}}-214/236 |
| **disputes** | Financial | 12 | ✅ | Payment disputes | Core |
| **payment_failures** | System | 10 | ✅ | Failed payment tracking | Core |
| **trial_notifications** | System | 8 | ✅ | Trial notifications | Core |
| **webhook_events** | System | 13 | ✅ | External webhook logging | Core |
| **subscriptions_plans** | Reference | 8 | ❌ | Plan definitions (global) | Core |

---

## 🔍 Detailed Schema

### **👤 user** (Core User Data)
**Purpose**: User profiles, authentication, and personal data
**RLS**: User isolation policies (4 policies)
**Indexes**: user_id (UNIQUE), email (UNIQUE)

**Prisma ↔ DB Column Mapping**:
- Prisma: `imdbProfileUrl` → DB: `imdb_profile_url`
- Prisma: `imdbVerified` → DB: `imdb_verified`
- All other fields use snake_case in both Prisma and DB

| Column | Type | Constraints | Purpose | Added In |
|--------|------|-------------|---------|----------|
| `id` | INT | PK, AUTO_INCREMENT | Database primary key | Core |
| `created_time` | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | Account creation timestamp | Core |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | User email address | Core |
| `first_name` | VARCHAR(100) | NULL | User first name | Core |
| `last_name` | VARCHAR(100) | NULL | User last name | Core |
| `gender` | VARCHAR(50) | NULL | User gender (optional) | Core |
| `profile_image_url` | VARCHAR(500) | NULL | Profile image URL | Core |
| `user_id` | VARCHAR(255) | UNIQUE, NOT NULL | Clerk authentication ID | Core |
| `subscription` | VARCHAR(255) | NULL | Current subscription ID | Core |
| `imdbProfileUrl` | TEXT | NULL | **NEW: IMDb profile URL** | **{{TICKET_PREFIX}}-259** |
| `imdbVerified` | BOOLEAN | DEFAULT false | **NEW: Admin verification status** | **{{TICKET_PREFIX}}-259** |

**RLS Policies**:
- `user_isolation` - Users can only see their own data
- `user_app_isolation` - Application-level user isolation

**Relationships**:
- `course_enrollments` → course_enrollment.user_id
- `invoices` → invoices.user_id
- `payments` → payments.user_id
- `subscriptions` → subscriptions.user_id

---

### **💳 payments** (Payment Processing)
**Purpose**: Track all payment transactions
**RLS**: User isolation policies (3 policies)
**Indexes**: user_id, stripe_id

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `id` | INT | PK, AUTO_INCREMENT | Database primary key |
| `created_time` | TIMESTAMPTZ | DEFAULT NOW() | Payment timestamp |
| `stripe_id` | VARCHAR(255) | NOT NULL | Stripe payment ID |
| `email` | VARCHAR(255) | NOT NULL | User email |
| `amount` | VARCHAR(50) | NOT NULL | Payment amount |
| `payment_time` | VARCHAR(100) | NOT NULL | Payment time string |
| `payment_date` | VARCHAR(100) | NOT NULL | Payment date string |
| `currency` | VARCHAR(10) | NOT NULL | Currency code |
| `user_id` | VARCHAR(255) | NOT NULL, FK | User reference |
| `customer_details` | TEXT | NOT NULL | Customer information |
| `payment_intent` | VARCHAR(255) | NOT NULL | Stripe payment intent |

**RLS**: User can only see their own payments

---

### **📧 newsletter_leads** (Newsletter Signup Tracking)
**Purpose**: Newsletter signup lead tracking with bonus delivery status
**RLS**: Strict user isolation (2 policies) - {{TICKET_PREFIX}}-321 Iteration 4
**Indexes**: email (UNIQUE), user_id (UNIQUE), email, user_id, bonus_delivered, created_at

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `id` | TEXT | PK | Unique lead identifier (cuid) |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | Newsletter signup email |
| `first_name` | VARCHAR(100) | NOT NULL | Subscriber first name |
| `bonus_delivered` | BOOLEAN | DEFAULT false | Bonus PDF delivery status |
| `user_id` | VARCHAR(255) | UNIQUE, NULL, FK | Optional user account reference |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Signup timestamp |
| `updated_at` | TIMESTAMPTZ | NOT NULL | Last update timestamp |

#### Tool Download Tracking ({{TICKET_PREFIX}}-321) - 6 Tools × 2 Fields Each

| Column Name | Type | Nullable | Default | Description |
|------------|------|----------|---------|-------------|
| `tool_character_conflict_downloads` | `integer` | No | `0` | Number of times user downloaded Character Conflict Worksheet |
| `tool_character_conflict_last_download` | `timestamp with time zone` | Yes | `null` | Last download timestamp for Character Conflict Worksheet (used for 24h rate limiting) |
| `tool_screenplay_format_downloads` | `integer` | No | `0` | Number of times user downloaded Screenplay Format Template |
| `tool_screenplay_format_last_download` | `timestamp with time zone` | Yes | `null` | Last download timestamp for Screenplay Format Template (used for 24h rate limiting) |
| `tool_12_step_structure_downloads` | `integer` | No | `0` | Number of times user downloaded 12-Step Structure PDF |
| `tool_12_step_structure_last_download` | `timestamp with time zone` | Yes | `null` | Last download timestamp for 12-Step Structure PDF (used for 24h rate limiting) |
| `tool_scene_breakdown_downloads` | `integer` | No | `0` | Number of times user downloaded Scene Breakdown Guide |
| `tool_scene_breakdown_last_download` | `timestamp with time zone` | Yes | `null` | Last download timestamp for Scene Breakdown Guide (used for 24h rate limiting) |
| `tool_dialogue_polish_downloads` | `integer` | No | `0` | Number of times user downloaded Dialogue Polish Checklist |
| `tool_dialogue_polish_last_download` | `timestamp with time zone` | Yes | `null` | Last download timestamp for Dialogue Polish Checklist (used for 24h rate limiting) |
| `tool_one_page_pitch_downloads` | `integer` | No | `0` | Number of times user downloaded One-Page Pitch Generator |
| `tool_one_page_pitch_last_download` | `timestamp with time zone` | Yes | `null` | Last download timestamp for One-Page Pitch Generator (used for 24h rate limiting) |

**Rate Limiting Logic**:
- **Window**: 24-hour rolling window per tool per user
- **Limit**: 5 downloads per tool per user per 24h window
- **Implementation**: Each tool has `_downloads` counter and `_last_download` timestamp
- **Reset**: Counter resets to 1 when 24h window expires (not before)
- **Enforcement**: API routes check `last_download` timestamp and current `downloads` count before allowing download

**RLS Policies** ({{TICKET_PREFIX}}-321 Iteration 4 - ARCHitect Approved):
- `newsletter_leads_user_isolation` (wtfb_user) - Strict user isolation (no NULL clause)
  - Policy: `user_id = current_setting('app.current_user_id', true)`
  - Migration: `20251006103605_fix_newsletter_leads_rls_policy_wor321_iteration4`
  - Enforcement: Users can ONLY access records where user_id matches their session context
- `newsletter_leads_app_isolation` (wtfb_app_user) - Strict user isolation (no NULL clause)
  - Policy: `user_id = current_setting('app.current_user_id', true)`
  - Migration: `20251006103605_fix_newsletter_leads_rls_policy_wor321_iteration4`
  - Enforcement: Application-level isolation with same strict user matching

**Relationships**:
- FK: `user_id` → user.user_id (ON DELETE SET NULL)

**Security Model** (ARCHitect-approved Option 1):
- **Strict RLS enforcement**: Users can only access their own lead records
- **No NULL clause**: Previous `OR user_id IS NULL` removed in Iteration 4
- **Cross-user access**: Completely blocked by RLS policies
- **Admin access**: Requires `withAdminContext()` for full lead access
- **Context required**: All operations require `app.current_user_id` session variable set

---

### **📺 courses** (Course Management)
**Purpose**: Course definitions and metadata
**RLS**: Content creator policies (2 policies)
**Indexes**: slug (UNIQUE), created_by

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `id` | TEXT | PK | Unique course identifier |
| `slug` | VARCHAR(255) | UNIQUE, NOT NULL | URL-friendly identifier |
| `title` | VARCHAR(255) | NOT NULL | Course display title |
| `description` | TEXT | NULL | Course description |
| `status` | VARCHAR(50) | DEFAULT 'draft' | Publish status |
| `created_by` | VARCHAR(255) | NOT NULL | Creator user ID |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | NOT NULL | Last update timestamp |
| `metadata` | JSON | NULL | Flexible course metadata |

**RLS**: Course creators can manage their courses

---

### **📅 course_runs** (Course Run Scheduling)

**Purpose**: Scheduled course run instances with enrollment windows
**RLS**: Admin Write + Public Read (3 policies)
**Indexes**: slug (UNIQUE), course_id, status, start_at, enrollment_window (composite)

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `id` | TEXT | PK | Unique course run identifier (cuid) |
| `course_id` | TEXT | NOT NULL, FK | Parent course reference |
| `slug` | VARCHAR(255) | UNIQUE, NOT NULL | URL-friendly identifier |
| `title` | VARCHAR(255) | NOT NULL | Course run display title |
| `timezone` | VARCHAR(100) | NOT NULL | IANA timezone (e.g., "America/New_York") |
| `start_at` | TIMESTAMPTZ | NOT NULL | Course run start date/time |
| `end_at` | TIMESTAMPTZ | NOT NULL | Course run end date/time |
| `enrollment_open_at` | TIMESTAMPTZ | NULL | When enrollment opens |
| `enrollment_close_at` | TIMESTAMPTZ | NULL | When enrollment closes |
| `status` | VARCHAR(50) | DEFAULT 'scheduled' | Run status (scheduled, active, completed, cancelled) |
| `metadata` | JSON | NULL | Flexible course run metadata |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | NOT NULL | Last update timestamp |

**RLS Policies**:
- `public_read_course_runs` - Anyone can view course runs
- `admin_full_access_course_runs` - Admins can manage all course runs
- `system_access_course_runs` - System contexts can update course runs

**Relationships**:
- FK: `course_id` → courses.id (ON DELETE RESTRICT)

**Business Rules**:
- `start_at` must be before `end_at`
- `enrollment_open_at` must be before `enrollment_close_at` (if both set)
- Enrollment window should close before or at course start
- Status transitions: scheduled → active → completed (or cancelled)

---

### **📄 course_content** (Course Content)
**Purpose**: Individual content items within courses
**RLS**: Content access policies (2 policies)
**Indexes**: course_id, tier, status, visible_from+visible_to, (Unique: course_id+slug)

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `id` | TEXT | PK | Content item ID (cuid) |
| `course_id` | TEXT | NOT NULL, FK | Parent course |
| `tier` | VARCHAR(50) | NOT NULL | Access tier (FREE, PRO, VIP) |
| `content_type` | VARCHAR(50) | NOT NULL | Type (video, document, file, text) |
| `title` | VARCHAR(255) | NOT NULL | Content title |
| `slug` | VARCHAR(255) | NOT NULL | URL-friendly identifier (unique per course) |
| `description` | TEXT | NULL | Content description |
| `body` | TEXT | NULL | Rich text content |
| `wistia_video_id` | VARCHAR(255) | NULL | Video reference |
| `file_url` | VARCHAR(500) | NULL | R2 URL or key |
| `file_metadata` | JSON | NULL | File metadata (size, mime_type, etc.) |
| `sort_order` | INT | DEFAULT 0 | Display order |
| `visible_from` | TIMESTAMPTZ | NULL | Start visibility window |
| `visible_to` | TIMESTAMPTZ | NULL | End visibility window |
| `status` | VARCHAR(50) | DEFAULT 'draft' | Publish status (draft, published) |
| `version` | INT | DEFAULT 1 | Content version |
| `created_by` | VARCHAR(255) | NOT NULL | Creator user ID |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Creation timestamp |
| `updated_by` | VARCHAR(255) | NULL | Last editor user ID |
| `updated_at` | TIMESTAMPTZ | NOT NULL | Last update timestamp |
| `metadata` | JSON | NULL | Additional metadata |

**RLS**: Access based on enrollment and content creator permissions

---

### **🔑 user_roles** (Role-Based Access Control)
**Purpose**: Manage user roles and permissions with audit trail
**RLS**: Role management policies (1 policy)
**Indexes**: user_id (PRIMARY KEY)
**Added**: {{TICKET_PREFIX}}-214, Enhanced: {{TICKET_PREFIX}}-236

| Column | Type | Constraints | Purpose | Added In |
|--------|------|-------------|---------|----------|
| `user_id` | VARCHAR(255) | PK, NOT NULL | User identifier | {{TICKET_PREFIX}}-214 |
| `role` | VARCHAR(50) | DEFAULT 'user' | User role (user, admin, etc) | {{TICKET_PREFIX}}-214 |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Role creation timestamp | {{TICKET_PREFIX}}-214 |
| `updated_at` | TIMESTAMPTZ | DEFAULT NOW() | Last update timestamp | {{TICKET_PREFIX}}-214 |
| `granted_by` | VARCHAR(255) | NULL | Admin who granted the role | {{TICKET_PREFIX}}-236 |
| `granted_at` | TIMESTAMPTZ | NULL | When role was granted | {{TICKET_PREFIX}}-236 |
| `revoked_at` | TIMESTAMPTZ | NULL | When role was revoked | {{TICKET_PREFIX}}-236 |
| `sync_source` | VARCHAR(50) | DEFAULT 'manual' | Role assignment source | {{TICKET_PREFIX}}-236 |

**RLS**: Admin-only access for role management

---

### **🔐 RLS Security Overview**

#### **Policy Types**:
1. **User Isolation** - Users see only their own data
2. **Content Access** - Enrollment-based content access
3. **Admin Override** - Full access for administrators
4. **System Context** - Webhook and system operations

#### **Protected Tables** (28 total policies):
- `user` (4 policies) - User data isolation
- `payments` (3 policies) - Payment privacy
- `subscriptions` (3 policies) - Subscription privacy
- `course_enrollment` (3 policies) - Enrollment access
- `course_runs` (3 policies) - Course run scheduling (Admin Write + Public Read)
- `newsletter_leads` (2 policies) - Newsletter signup isolation
- `courses` (2 policies) - Content creator access
- `course_content` (2 policies) - Student/creator access
- `content_files` (2 policies) - File access control
- `content_audit` (2 policies) - Audit trail protection
- `user_roles` (1 policy) - Role management
- `webhook_events` (1 policy) - System event logging

#### **Unprotected Tables**:
- `subscriptions_plans` - Global reference data

---

## 🔄 Recent Changes

### **{{TICKET_PREFIX}}-319 (2025-10-05) - Newsletter Lead Tracking**
- ✅ Added `newsletter_leads` table for newsletter signup tracking
- ✅ Migration: `20251005081733_add_newsletter_leads_table`
- ✅ 7 columns, 6 indexes (email and user_id are UNIQUE)
- ✅ 2 RLS policies: user_isolation, app_isolation
- ✅ FK constraint to user (ON DELETE SET NULL)
- ✅ User isolation pattern with NULL user_id support for pre-registration leads
- ✅ Bonus delivery tracking for automated PDF distribution

### **{{TICKET_PREFIX}}-315 (2025-10-04) - Course Run Scheduling**
- ✅ Added `course_runs` table for scheduled course instances
- ✅ Migration: `20251004173406_add_course_runs_with_rls`
- ✅ 13 columns, 6 indexes (including enrollment_window composite index)
- ✅ 3 RLS policies: public_read, admin_full_access, system_access
- ✅ FK constraint to courses (ON DELETE RESTRICT)
- ✅ Admin Write + Public Read security pattern
- ✅ Timezone-aware scheduling with IANA timezone support

### **{{TICKET_PREFIX}}-259 (2025-09-28) - IMDb Profile Fields**
- ✅ Added `imdbProfileUrl` to `user` table
- ✅ Added `imdbVerified` to `user` table
- ✅ Migration: `20250925234400_add_imdb_fields`
- ✅ No new RLS policies needed (inherited from user table)
- ✅ Validation implemented via shared utility
- ✅ API security hardened (server-side email derivation)

### **{{TICKET_PREFIX}}-236 (2025-09-20) - User Roles Audit Fields**
- ✅ Added `granted_by` to `user_roles` table
- ✅ Added `granted_at` to `user_roles` table
- ✅ Added `revoked_at` to `user_roles` table
- ✅ Added `sync_source` to `user_roles` table
- ✅ Migration: `20250919234416_add_user_roles_audit_fields`
- ✅ Enables role audit trail and tracking

### **{{TICKET_PREFIX}}-222 (2025-09-18) - Course Content Platform**
- Added 4 new tables: courses, course_content, content_files, content_audit
- Added 8 new RLS policies for content protection
- Enhanced course enrollment system

---

## 🛠️ Development Context

### **Database Access Patterns**:
- **RLS Context**: All user operations use `withUserContext()`
- **Admin Operations**: Use `withAdminContext()`
- **System Operations**: Use `withSystemContext()`
- **Connection Pooling**: PgBouncer for production

### **Migration Strategy**:
- Prisma migrations for schema changes
- Manual RLS policy updates
- Required security review for user data tables

### **Performance Considerations**:
- All RLS policy columns are indexed
- Connection pooling via PgBouncer
- Query optimization for enrollment checks

---

## 📚 Related Documentation

- [RLS Implementation Guide](./RLS_IMPLEMENTATION_GUIDE.md)
- [RLS Migration SOP](./RLS_DATABASE_MIGRATION_SOP.md)
- [Prisma Integration](./PRISMA_INTEGRATION.md)
- [Database Migration Guide](./database-migration-guide.md)

---

**📝 Maintenance Notes:**
- Update this file for ANY schema changes
- Verify RLS compliance before production deployment
- Sync with external documentation quarterly
- Test data isolation after policy changes

**🔍 AI Context:**
This document provides complete database context without external tool calls. Use this as the authoritative source for database queries, schema understanding, and development planning.