# Security Documentation

This directory contains security architecture and implementation guidelines.

## 📚 Documentation Files

### [SECURITY_FIRST_ARCHITECTURE.md](./SECURITY_FIRST_ARCHITECTURE.md)
Comprehensive security architecture guide:
- Security-first design principles
- Authentication and authorization patterns
- Data protection strategies
- Security testing procedures
- Threat modeling

**Use this when**: Designing new features or reviewing security implications.

## 🔗 Related Documentation

- [RLS Implementation Guide](../database/RLS_IMPLEMENTATION_GUIDE.md) - Database security
- [RLS Policy Catalog](../database/RLS_POLICY_CATALOG.md) - Access control policies
- [CI/CD Pipeline](../ci-cd/CI-CD-Pipeline-Guide.md) - Security in deployment

## 🎯 Security Agents

- **Security Engineer** (`.claude/agents/security-engineer.md`) - Security audits and validation
- **System Architect** (`.claude/agents/system-architect.md`) - Architectural security review

## ⚠️ Security Principles

1. **Defense in Depth** - Multiple layers of security
2. **Least Privilege** - Minimal access by default
3. **Fail Secure** - Errors should deny access
4. **Security by Design** - Not an afterthought

