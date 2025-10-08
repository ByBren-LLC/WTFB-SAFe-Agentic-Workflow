# Row Level Security (RLS) Policy Catalog

## 📋 Overview

This document provides a comprehensive, human-readable catalog of all Row Level Security (RLS) policies in the {{PROJECT_NAME}} application database. It serves as the definitive reference for understanding data access controls at the database level.

**Purpose**: Document all RLS policies to ensure data governance compliance, security audits, and GDPR adherence.

**Last Updated**: [DATE]
**Ticket**: {{TICKET_PREFIX}}-XXX
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

- **`{{DB_SUPERUSER_ROLE}}`**: Superuser for migrations and admin operations (no RLS enforcement)
- **`{{DB_APP_USER_ROLE}}`**: Application user with RLS enforcement (PRODUCTION ROLE)

---

## 📊 RLS Status Summary

### Tables with RLS Enabled: ✅ [COUNT] of [TOTAL]

| Table | RLS Status | Policy Type | Test Coverage |
|-------|------------|-------------|---------------|
| user | ✅ Enabled | User Isolation | ✅ Tested |
| [your_table] | ✅ Enabled | [Policy Type] | ✅/⚠️ Tested/Needed |

**Policy Types**:
- **User Isolation**: Users can only access their own data
- **Role-Based**: Access based on user role (admin, user, etc.)
- **Public Read**: Anyone can read, only owners can write
- **Admin-Only**: Only admins can access
- **System-Only**: Only system contexts can access

---

## 🔐 Table-by-Table Policy Catalog

### Template: How to Document RLS Policies

```markdown
### [N]. [table_name] ([Purpose])

**RLS Status**: ✅ Enabled  
**Data Classification**: [USER/ADMIN/SYSTEM/PUBLIC] - [Description]  
**GDPR Implications**: [Contains PII / No PII / Audit trail]

#### Access Rules

**Regular Users**:
- ✅ Can [action] their own [resource]
- ❌ Cannot [action] other users' [resource]

**Admins**:
- ✅ Can [action] all [resource]

**System**:
- ✅ Can [action] for [purpose]

#### RLS Policies

\`\`\`sql
-- Policy 1: User Isolation
CREATE POLICY [policy_name] ON "[table_name]"
FOR ALL
USING (user_id = current_setting('app.current_user_id', true));

-- Policy 2: Admin Access
CREATE POLICY [policy_name]_admin ON "[table_name]"
FOR ALL
USING (current_setting('app.user_role', true) = 'admin');
\`\`\`

#### Testing

**Test Coverage**: ✅ Tested / ⚠️ Test needed

**Test Cases**:
1. User can access own data
2. User cannot access other users' data
3. Admin can access all data
4. System context works correctly

#### Migration History

- **Created**: {{TICKET_PREFIX}}-XXX ([migration_name])
- **Modified**: {{TICKET_PREFIX}}-YYY ([description])
```

---

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
- ✅ Can view all user records
- ✅ Can modify all user records

**System**:
- ✅ Can access for background processing

#### RLS Policies

```sql
-- User Isolation Policy
CREATE POLICY user_isolation ON "user"
FOR ALL
USING (user_id = current_setting('app.current_user_id', true));

-- Admin Access Policy
CREATE POLICY user_admin_access ON "user"
FOR ALL
USING (current_setting('app.user_role', true) = 'admin');
```

#### Testing

**Test Coverage**: ✅ Tested

**Test Cases**:
1. ✅ User can read own profile
2. ✅ User cannot read other profiles
3. ✅ Admin can read all profiles
4. ✅ System context works for webhooks

#### Migration History

- **Created**: {{TICKET_PREFIX}}-001 (initial_rls_setup)

---

### 2. [your_table] ([Purpose])

**RLS Status**: ✅ Enabled  
**Data Classification**: [USER/ADMIN/SYSTEM] - [Description]  
**GDPR Implications**: [PII status]

#### Access Rules

[Document your access rules]

#### RLS Policies

```sql
-- Add your policies here
```

#### Testing

**Test Coverage**: ⚠️ Test needed

**Test Cases**:
[List your test cases]

#### Migration History

- **Created**: {{TICKET_PREFIX}}-XXX ([migration_name])

---

## 🧪 RLS Testing Guidelines

### Required Tests for Each Table

1. **User Isolation Test**:
   ```typescript
   // User A creates data
   const dataA = await withUserContext(prisma, userA, async (client) => {
     return client.table.create({ data: {...} });
   });
   
   // User B cannot see User A's data
   const dataB = await withUserContext(prisma, userB, async (client) => {
     return client.table.findMany();
   });
   expect(dataB).not.toContainEqual(dataA);
   ```

2. **Admin Access Test**:
   ```typescript
   // Admin can see all data
   const allData = await withAdminContext(prisma, adminId, async (client) => {
     return client.table.findMany();
   });
   expect(allData.length).toBeGreaterThan(0);
   ```

3. **System Context Test**:
   ```typescript
   // System can access for background jobs
   const systemData = await withSystemContext(prisma, 'webhook', async (client) => {
     return client.table.findMany();
   });
   ```

---

## 📊 RLS Compliance Checklist

### For New Tables

- [ ] RLS enabled on table: `ALTER TABLE "table_name" ENABLE ROW LEVEL SECURITY;`
- [ ] RLS forced: `ALTER TABLE "table_name" FORCE ROW LEVEL SECURITY;`
- [ ] User isolation policy created (if user data)
- [ ] Admin access policy created
- [ ] System context policy created (if needed)
- [ ] Policies tested with all three contexts
- [ ] Migration documented in this catalog
- [ ] Security review completed
- [ ] ARCHitect approval obtained

### For Policy Changes

- [ ] Change reason documented
- [ ] Security implications reviewed
- [ ] Test coverage updated
- [ ] Migration created
- [ ] This catalog updated
- [ ] ARCHitect approval obtained

---

## 🔍 Security Audit Queries

### Check RLS Status

```sql
-- List all tables without RLS
SELECT schemaname, tablename
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename NOT LIKE '_prisma%'
  AND tablename NOT IN (
    SELECT tablename
    FROM pg_tables t
    WHERE rowsecurity = true
  );
```

### List All Policies

```sql
-- Show all RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

### Test User Isolation

```sql
-- Set user context
SET app.current_user_id = 'test_user_123';
SET app.user_role = 'user';

-- Query should only return user's data
SELECT * FROM your_table;
```

---

## 📚 Related Documentation

- [DATA_DICTIONARY.md](./DATA_DICTIONARY.md) - Complete schema reference
- [RLS_IMPLEMENTATION_GUIDE.md](./RLS_IMPLEMENTATION_GUIDE.md) - Implementation patterns
- [RLS_DATABASE_MIGRATION_SOP.md](./RLS_DATABASE_MIGRATION_SOP.md) - Migration procedures
- [SECURITY_FIRST_ARCHITECTURE.md](./SECURITY_FIRST_ARCHITECTURE.md) - Security principles

---

## 📝 Maintenance Guidelines

**MANDATORY Updates**:
- ✅ Update this catalog when adding new RLS policies
- ✅ Document all policy changes with ticket references
- ✅ Test all policies before production deployment
- ✅ Get ARCHitect approval for policy changes
- ✅ Review quarterly for accuracy

**For AI Agents**:
- **Security Engineer**: Audit policies from this catalog
- **Data Engineer**: Update after schema changes
- **System Architect**: Validate security model
- **QAS**: Use for security testing

---

**🔍 AI Context:**
This catalog provides complete RLS policy documentation for security audits, compliance verification, and development context. Use this as the authoritative source for understanding data access controls.

**🎯 Template Usage:**
1. Replace all `[PLACEHOLDERS]` with your actual values
2. Document each table's RLS policies
3. Keep test coverage up-to-date
4. Track all changes with ticket references
5. Review quarterly for security compliance

