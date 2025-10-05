# Review Checklist

## Purpose
Comprehensive checklist for reviewing code changes, architectural decisions, and project deliverables.

## Pre-Implementation Review

### Planning & Architecture
- [ ] Confluence planning document created and reviewed
- [ ] Project management tool issues properly decomposed with labels
- [ ] Architecture aligns with documented standards
- [ ] Impact analysis completed for affected components
- [ ] Risk assessment and mitigation strategies defined
- [ ] Success criteria clearly defined

### Technical Design
- [ ] Database schema changes reviewed and approved
- [ ] API design follows established patterns
- [ ] Security implications assessed
- [ ] Performance impact evaluated
- [ ] Scalability considerations addressed
- [ ] Integration points identified and validated

## Code Review Checklist

### General Code Quality
- [ ] Code follows established coding standards
- [ ] TypeScript types properly defined and used
- [ ] Error handling implemented appropriately
- [ ] Logging and monitoring included where needed
- [ ] Code is readable and well-documented
- [ ] No hardcoded values or secrets

### Project-Specific Standards
- [ ] Prisma ORM used for all database operations
- [ ] Prisma-generated types used for TypeScript safety
- [ ] Clerk authentication patterns followed
- [ ] Next.js 15 conventions adhered to
- [ ] Shadcn UI components used consistently
- [ ] Environment variables properly configured

### Database & ORM
- [ ] Prisma schema changes are backward compatible
- [ ] Migration scripts generated and tested
- [ ] Database queries optimized for performance
- [ ] Connection pooling properly configured
- [ ] Transaction boundaries appropriate
- [ ] Data validation implemented

### API & Integration
- [ ] API endpoints follow RESTful conventions
- [ ] Request/response validation with Zod
- [ ] Rate limiting implemented where appropriate
- [ ] Authentication and authorization checks
- [ ] Error responses consistent and informative
- [ ] API documentation updated

## Testing Review

### Test Coverage
- [ ] Unit tests for business logic
- [ ] Integration tests for API endpoints
- [ ] Database operation tests
- [ ] Authentication flow tests
- [ ] Error handling tests
- [ ] Performance tests where applicable

### Test Quality
- [ ] Tests are independent and repeatable
- [ ] Test data properly managed
- [ ] Edge cases covered
- [ ] Mocking used appropriately
- [ ] Test documentation clear

## Deployment Review

### Environment Readiness
- [ ] Local development tested thoroughly
- [ ] Environment variables configured
- [ ] Database migrations ready
- [ ] Dependencies properly managed
- [ ] Build process validated
- [ ] Deployment scripts tested

### Production Considerations
- [ ] Coolify.io deployment configuration verified
- [ ] PostgreSQL and Redis connections tested
- [ ] SSL certificates and security configured
- [ ] Monitoring and alerting in place
- [ ] Rollback procedures documented
- [ ] Performance baselines established

## Documentation Review

### Technical Documentation
- [ ] README updated with changes
- [ ] API documentation current
- [ ] Database schema documented
- [ ] Environment setup instructions clear
- [ ] Troubleshooting guides updated

### Process Documentation
- [ ] Confluence documents updated
- [ ] Project management tool issues properly tracked
- [ ] Git commit messages follow SAFe standards
- [ ] PR description complete and accurate
- [ ] Change log updated

## Final Approval Checklist

### Stakeholder Sign-off
- [ ] Technical review completed by Auggie (ARCHitect)
- [ ] Implementation review by Claude Code
- [ ] Business requirements validated
- [ ] Security review completed
- [ ] Performance benchmarks met

### Delivery Readiness
- [ ] All tests passing
- [ ] Code merged to appropriate branch
- [ ] Deployment pipeline validated
- [ ] Monitoring configured
- [ ] Team notified of changes
- [ ] Documentation published

## Post-Deployment Review

### Validation
- [ ] Functionality verified in production
- [ ] Performance metrics within acceptable range
- [ ] No errors in logs
- [ ] User experience validated
- [ ] Integration points functioning
- [ ] Monitoring alerts configured

### Follow-up Actions
- [ ] Project management tool issues updated with completion status
- [ ] Lessons learned documented
- [ ] Technical debt items identified
- [ ] Future improvements noted
- [ ] Team retrospective scheduled if needed
