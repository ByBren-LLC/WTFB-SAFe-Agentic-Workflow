# Database Documentation

This directory contains all database-related documentation including schema, security, and migration procedures.

## 📚 Documentation Files

### [DATA_DICTIONARY.md](./DATA_DICTIONARY.md)
**Single source of truth** for database schema:
- Table definitions and relationships
- Column specifications and constraints
- Enum types and their values
- Indexes and performance considerations

**Use this when**: You need to understand the database schema or add new tables/columns.

### [RLS_IMPLEMENTATION_GUIDE.md](./RLS_IMPLEMENTATION_GUIDE.md)
Row-Level Security (RLS) implementation patterns:
- RLS context helpers (`withUserContext`, `withAdminContext`, `withSystemContext`)
- Security patterns and best practices
- Common RLS policy patterns
- Testing RLS policies

**Use this when**: Implementing new features that require database access with proper security.

### [RLS_POLICY_CATALOG.md](./RLS_POLICY_CATALOG.md)
Comprehensive catalog of all RLS policies:
- Policy definitions by table
- Access control rules
- Policy testing procedures
- Security audit checklist

**Use this when**: You need to understand existing RLS policies or create new ones.

### [RLS_DATABASE_MIGRATION_SOP.md](./RLS_DATABASE_MIGRATION_SOP.md)
Standard Operating Procedure for database migrations:
- Migration workflow (dev → staging → production)
- Schema change procedures
- RLS policy updates
- Rollback procedures
- Validation checklist

**Use this when**: You need to create or apply database migrations.

## 🔗 Related Documentation

- [Security Architecture](../security/SECURITY_FIRST_ARCHITECTURE.md) - Overall security patterns
- [Contributing Guide](../../CONTRIBUTING.md) - Git workflow for schema changes

## ⚠️ Important Notes

1. **Always use RLS context helpers** - Never make direct Prisma calls
2. **Test RLS policies** - Verify isolation between users
3. **Follow migration SOP** - Schema changes require ARCHitect approval
4. **Update DATA_DICTIONARY.md** - Keep schema documentation current

