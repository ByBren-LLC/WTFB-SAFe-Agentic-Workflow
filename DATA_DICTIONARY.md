# 📊 {{PROJECT_NAME}} Database Data Dictionary

> **Single Source of Truth for AI Agents and Development Context**
>
> **Last Updated**: [DATE] ({{TICKET_PREFIX}}-XXX - [Description])
> **Schema Version**: [VERSION]
> **Database**: PostgreSQL with Prisma ORM
> **Total Tables**: [COUNT]
> **Total RLS Policies**: [COUNT]

---

## 🎯 Purpose

This document serves as the **single source of truth** for your database schema. It provides:

1. **Complete table definitions** with column types, constraints, and purposes
2. **RLS (Row Level Security) policy documentation** for data access control
3. **Relationship mapping** between tables
4. **Change history** tracking schema evolution
5. **AI agent context** for automated development

---

## 📋 How to Use This Template

### For New Projects:
1. Replace `[PLACEHOLDERS]` with your actual values
2. Document each table as you create it
3. Update RLS policies when adding user data tables
4. Track changes with {{TICKET_PREFIX}}-XXX references

### For AI Agents:
- **BSA**: Reference this for data requirements in specs
- **Data Engineer**: Update this MANDATORY after schema changes
- **System Architect**: Validate schema design against this
- **Security Engineer**: Audit RLS policies from this

---

## 🎯 Quick Reference

| Metric | Count | Notes |
|---------|-------|-------|
| **User Data Tables** | [COUNT] | Tables with user_id (RLS protected) |
| **System Tables** | [COUNT] | Global reference tables |
| **Admin Tables** | [COUNT] | Admin-only access |
| **Core Entities** | [COUNT] | [List core tables] |
| **Latest Additions** | {{TICKET_PREFIX}}-XXX | [Description] |

---

## 📋 Table Overview

| Table | Type | Columns | RLS | Purpose | Last Modified |
|-------|------|---------|-----|---------|---------------|
| **user** | Core | [COUNT] | ✅ | User profiles & authentication | {{TICKET_PREFIX}}-XXX |
| **[your_table]** | [Type] | [COUNT] | ✅/❌ | [Purpose] | {{TICKET_PREFIX}}-XXX |

**Table Types**:
- **Core**: Essential business entities (users, products, orders, etc.)
- **Financial**: Payment, billing, subscription data
- **Content**: User-generated or managed content
- **System**: Audit logs, webhooks, background jobs
- **Reference**: Global lookup tables (no RLS needed)

---

## 🔍 Detailed Schema

### Template: How to Document a Table

```markdown
### **[Icon] [table_name]** ([Category])
**Purpose**: [What this table stores and why]
**RLS**: [RLS status and policy count]
**Indexes**: [List important indexes]

**Prisma ↔ DB Column Mapping** (if different):
- Prisma: `camelCase` → DB: `snake_case`

| Column | Type | Constraints | Purpose | Added In |
|--------|------|-------------|---------|----------|
| `id` | INT/UUID | PK, AUTO_INCREMENT | Primary key | Core |
| `created_at` | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | Creation timestamp | Core |
| `user_id` | VARCHAR(255) | FK, NOT NULL | User reference | Core |
| `[column_name]` | [TYPE] | [CONSTRAINTS] | [PURPOSE] | {{TICKET_PREFIX}}-XXX |

**RLS Policies**:
- `[policy_name]` - [What it does]

**Relationships**:
- `[related_table]` → [foreign_key_column]
```

---

### **👤 user** (Core User Data)
**Purpose**: User profiles, authentication, and personal data
**RLS**: User isolation policies (required for GDPR compliance)
**Indexes**: user_id (UNIQUE), email (UNIQUE)

| Column | Type | Constraints | Purpose | Added In |
|--------|------|-------------|---------|----------|
| `id` | INT/UUID | PK, AUTO_INCREMENT | Database primary key | Core |
| `created_at` | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | Account creation timestamp | Core |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | User email address | Core |
| `user_id` | VARCHAR(255) | UNIQUE, NOT NULL | Authentication provider ID (e.g., Clerk) | Core |
| `[custom_field]` | [TYPE] | [CONSTRAINTS] | [YOUR CUSTOM FIELDS] | {{TICKET_PREFIX}}-XXX |

**RLS Policies**:
- `user_isolation` - Users can only see their own data
- `admin_access` - Admins can see all users (via role check)

**Relationships**:
- Add your relationships here

---

## 📝 Example Tables (Customize for Your Project)

### **💳 [payments/orders/transactions]** (Financial Data)
**Purpose**: [Describe your financial data]
**RLS**: User isolation required
**Indexes**: user_id, [payment_provider_id]

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `id` | INT/UUID | PK | Primary key |
| `user_id` | VARCHAR(255) | FK, NOT NULL | User reference |
| `amount` | DECIMAL(10,2) | NOT NULL | Transaction amount |
| `status` | VARCHAR(50) | NOT NULL | Payment status |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Transaction timestamp |

**RLS Policies**:
- `user_isolation` - Users see only their transactions

---

### **📄 [content/posts/items]** (User Content)
**Purpose**: [Describe your content]
**RLS**: User isolation or role-based access
**Indexes**: user_id, created_at

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `id` | INT/UUID | PK | Primary key |
| `user_id` | VARCHAR(255) | FK, NOT NULL | Content owner |
| `title` | VARCHAR(255) | NOT NULL | Content title |
| `content` | TEXT | NULL | Content body |
| `published` | BOOLEAN | DEFAULT false | Publication status |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Creation timestamp |

**RLS Policies**:
- `owner_access` - Users can manage their own content
- `public_read` - Published content is publicly readable

---
---

## 🔐 RLS (Row Level Security) Overview

### Why RLS Matters

**RLS enforces data isolation at the database level**, ensuring:
- Users can only access their own data
- Admins have controlled elevated access
- System operations (webhooks, background jobs) have appropriate context
- GDPR compliance through automatic data isolation

### RLS Policy Types

1. **User Isolation** - Users see only their own data
   ```sql
   CREATE POLICY user_isolation ON table_name
   FOR ALL
   USING (user_id = current_setting('app.current_user_id', true));
   ```

2. **Admin Access** - Admins see all data
   ```sql
   CREATE POLICY admin_access ON table_name
   FOR ALL
   USING (current_setting('app.user_role', true) = 'admin');
   ```

3. **Public Read** - Anyone can read, only owners can write
   ```sql
   CREATE POLICY public_read ON table_name
   FOR SELECT
   USING (true);

   CREATE POLICY owner_write ON table_name
   FOR INSERT, UPDATE, DELETE
   USING (user_id = current_setting('app.current_user_id', true));
   ```

### Context Helpers (Application Code)

```typescript
// User operations - automatic user isolation
await withUserContext(prisma, userId, async (client) => {
  return client.yourTable.findMany(); // Only returns user's data
});

// Admin operations - requires admin role validation
await withAdminContext(prisma, userId, async (client) => {
  return client.yourTable.findMany(); // Returns all data
});

// System operations - for webhooks/background jobs
await withSystemContext(prisma, contextType, async (client) => {
  return client.yourTable.findMany(); // System-level access
});
```

---

## 🔄 Change History Template

### **{{TICKET_PREFIX}}-XXX (YYYY-MM-DD) - [Feature Name]**
- ✅ Added `[table_name]` table for [purpose]
- ✅ Migration: `[migration_name]`
- ✅ [COUNT] columns, [COUNT] indexes
- ✅ [COUNT] RLS policies: [policy names]
- ✅ FK constraints: [relationships]
- ✅ Security pattern: [User Isolation / Admin Access / Public Read]

---

## 🛠️ Development Context

### **Database Access Patterns**:
- **RLS Context**: All user operations use `withUserContext()`
- **Admin Operations**: Use `withAdminContext()`
- **System Operations**: Use `withSystemContext()`
- **Connection Pooling**: [Your pooling strategy]

### **Migration Strategy**:
- [Your ORM] migrations for schema changes
- Manual RLS policy updates (if needed)
- Required security review for user data tables
- ARCHitect approval for schema changes (see RLS_DATABASE_MIGRATION_SOP.md)

### **Performance Considerations**:
- All RLS policy columns should be indexed
- Connection pooling configuration
- Query optimization for common access patterns

---

## 📚 Related Documentation

- [RLS Implementation Guide](./RLS_IMPLEMENTATION_GUIDE.md)
- [RLS Migration SOP](./RLS_DATABASE_MIGRATION_SOP.md)
- [Security First Architecture](./SECURITY_FIRST_ARCHITECTURE.md)
- [Contributing Guide](./CONTRIBUTING.md)

---

## 📝 Maintenance Guidelines

**MANDATORY Updates**:
- ✅ Update this file for ANY schema changes
- ✅ Document all RLS policies when adding user data tables
- ✅ Include {{TICKET_PREFIX}}-XXX reference for all changes
- ✅ Verify RLS compliance before production deployment
- ✅ Get ARCHitect approval for schema changes

**For AI Agents**:
- **Data Engineer**: Update this file IMMEDIATELY after schema changes
- **BSA**: Reference this file when defining data requirements
- **System Architect**: Validate schema design against this
- **Security Engineer**: Audit RLS policies from this

---

**🔍 AI Context:**
This document provides complete database context without external tool calls. Use this as the authoritative source for database queries, schema understanding, and development planning.

**🎯 Template Usage:**
1. Replace all `[PLACEHOLDERS]` with your actual values
2. Document tables as you create them
3. Keep RLS policies up-to-date
4. Track all changes with ticket references
5. Review quarterly for accuracy
