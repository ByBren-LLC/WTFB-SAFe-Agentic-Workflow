# Spec: [Feature Name]

## Linear Issue Reference
- **Ticket**: [__TICKET_PREFIX__-XXX]
- **URL**: [__TICKET_URL_PREFIX__/__TICKET_PREFIX__-XXX]

## High-Level Objective

### User Story
**As a** [user type]  
**I want to** [capability]  
**So that** [business value]

### Business Context
[Brief explanation of why this work is important and how it fits into the larger initiative]

## Acceptance Criteria

- [ ] [Testable outcome 1]
- [ ] [Testable outcome 2]
- [ ] [Testable outcome 3]
- [ ] [Performance requirement if applicable]
- [ ] [Security requirement if applicable]

## Pattern References

### Primary Patterns
- **Pattern Used**: [pattern-file-name.md]
- **Justification**: [Why this pattern was chosen]

### Secondary Patterns
- **Pattern Used**: [pattern-file-name.md]
- **Usage**: [How this pattern applies]

## Low-Level Implementation Tasks

### Backend Tasks
1. [ ] [Specific backend task 1]
2. [ ] [Specific backend task 2]
3. [ ] [Specific backend task 3]

### Frontend Tasks
1. [ ] [Specific frontend task 1]
2. [ ] [Specific frontend task 2]
3. [ ] [Specific frontend task 3]

### Database Tasks
1. [ ] [Migration or schema change]
2. [ ] [RLS policy updates if applicable]
3. [ ] [Data seeding if applicable]

## Critical Handoff Notes

### #PATH_DECISION
[Document why particular architectural or implementation paths were chosen over alternatives]

### #PLAN_UNCERTAINTY
[Flag any assumptions made during planning that require validation during execution]

### #EXPORT_CRITICAL
[Highlight non-negotiable requirements, security rules, or architectural constraints]

## Testing Strategy

### Unit Tests
- [ ] [Component/function to test]
- [ ] [Edge case to cover]

### Integration Tests
- [ ] [API endpoint to test]
- [ ] [Database interaction to verify]

### End-to-End Tests
- [ ] [User flow to test]
- [ ] [Critical path to verify]

### Manual Testing
- [ ] [Manual verification step]
- [ ] [UI/UX validation]

## Security Considerations

### Authentication/Authorization
- [ ] [Auth requirement 1]
- [ ] [Auth requirement 2]

### Data Protection
- [ ] [Data protection requirement]
- [ ] [RLS enforcement if applicable]

### Input Validation
- [ ] [Validation requirement 1]
- [ ] [Validation requirement 2]

## Performance Requirements

### Response Time
- [Endpoint]: < [X]ms
- [Page Load]: < [X]ms

### Scalability
- [Requirement 1]
- [Requirement 2]

## Dependencies

### Technical Dependencies
- [ ] [Dependency 1]
- [ ] [Dependency 2]

### Business Dependencies
- [ ] [Business approval needed]
- [ ] [External integration required]

## Definition of Done

- [ ] All acceptance criteria met
- [ ] All tests passing (`yarn ci:validate`)
- [ ] Security review completed (if applicable)
- [ ] Performance requirements met
- [ ] Documentation updated
- [ ] PR created with evidence attached
- [ ] Linear ticket updated with session ID and validation results

## Pull Request Template

```markdown
## Summary
[Brief description of changes]

## Linear Ticket
Closes [__TICKET_PREFIX__-XXX]

## Changes Made
- [Change 1]
- [Change 2]
- [Change 3]

## Testing Evidence
- [ ] Unit tests: [Link to test results]
- [ ] Integration tests: [Link to test results]
- [ ] Manual testing: [Screenshots/videos]

## Security Review
- [ ] No new security concerns
- [ ] Security review completed (if applicable)

## Session Evidence
- **Session ID**: [Claude session ID]
- **Validation Results**: [Link to ci:validate output]
```

## Notes for Execution Agent

### Before Starting
1. Read this entire spec carefully
2. Pay special attention to #EXPORT_CRITICAL items
3. Review referenced patterns in `patterns_library/`
4. Validate any #PLAN_UNCERTAINTY items with POPM if needed

### During Implementation
1. Follow the low-level tasks in order
2. Make atomic commits for each logical change
3. Run `yarn ci:validate` frequently
4. Update this spec if you discover issues

### Before Completing
1. Verify all acceptance criteria are met
2. Run full test suite
3. Attach evidence to Linear ticket
4. Create PR using the template above
