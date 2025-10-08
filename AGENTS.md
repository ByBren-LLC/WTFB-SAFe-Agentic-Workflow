# WTFB Agent Team Quick Reference

> **Philosophy**: "Search First, Reuse Always, Create Only When Necessary"
>
> Pattern discovery is MANDATORY before implementation.

## 🚀 Agent System Enhancements (WOR-310)

**New Capabilities**:

- ✅ **Tool Restrictions**: Each agent has specific tool access (see `.claude/agents/*.md` frontmatter)
- ✅ **Model Selection**: Opus for planning (BSA, ARCHitect), Sonnet for execution
- ✅ **Metacognitive Tags**: #PATH_DECISION, #PLAN_UNCERTAINTY, #EXPORT_CRITICAL in specs
- ✅ **Automation Hooks**: RLS validation, Linear updates, pattern library checks

**Documentation**:

- [Agent Configuration SOP](./docs/sop/AGENT_CONFIGURATION_SOP.md) - Tool restrictions, model selection
- [Agent Workflow SOP](./docs/sop/AGENT_WORKFLOW_SOP.md) - Invocation, orchestration, handoffs
- [Hooks Directory](./.claude/hooks/) - Automation scripts

## When to Use Which Agent

| Agent Role | Use Case | Success Criteria | Primary Tools |
|-----------|----------|------------------|---------------|
| **TDM** (Technical Delivery Manager) | Coordination, blocker escalation, Linear ticket management | Linear updated, PRs merged, blockers resolved | Linear, GitHub, Documentation |
| **BSA** (Business Systems Analyst) | Requirements decomposition, acceptance criteria, testing strategy | Clear user stories, testable ACs, QA plan defined | Linear, Documentation, Markdown |
| **System Architect** | Pattern validation, conflict prevention, architectural decisions | ADR created, patterns validated, no conflicts | Read, Grep, ADR templates |
| **FE Developer** | UI components, client-side logic, user interactions | `yarn lint && yarn build` passes | Read, Write, Edit, Bash |
| **BE Developer** | API routes, server logic, RLS enforcement | `yarn test:integration` passes | Read, Write, Edit, Bash |
| **DE** (Data Engineer) | Schema changes, migrations, database architecture | Migration applied, RLS maintained | Prisma, SQL, migration tools |
| **TW** (Technical Writer) | Documentation, guides, technical content | `yarn lint:md` passes | Read, Write, Edit, Grep, Glob, Bash |
| **DPE** (Data Provisioning Engineer) | Test data, database access, data validation | Test data available, DB accessible | SQL, Prisma Studio, scripts |
| **QAS** (Quality Assurance) | Execute BSA testing strategy, validate acceptance criteria | All ACs verified, test report complete | Playwright, Jest, test tools |
| **SecEng** (Security Engineer) | Security validation, RLS checks, vulnerability assessment | Security audit passed, RLS enforced | RLS scripts, security tools |
| **RTE** (Release Train Engineer) | PR creation, CI/CD validation, release coordination | `yarn ci:validate` passes, PR merged | Git, GitHub CLI, CI tools |

## Success Validation Commands

### Frontend Development

```bash
yarn lint && yarn build && echo "FE SUCCESS" || echo "FE FAILED"
```

### Backend Development

```bash
yarn test:integration && echo "BE SUCCESS" || echo "BE FAILED"
```

### Documentation

```bash
yarn lint:md && echo "DOCS SUCCESS" || echo "DOCS FAILED"
```

### Pre-Push Validation

```bash
yarn ci:validate && echo "CI SUCCESS" || echo "CI FAILED"
```

### Database Migration

```bash
npx prisma migrate dev --name migration_name && echo "MIGRATION SUCCESS" || echo "MIGRATION FAILED"
```

## SAFe Specs-Driven Workflow

### Planning Phase (BSA)

```bash
# Large initiative → Use planning template
cp specs/planning_template.md specs/{feature}-planning.md
# Fill with Epic → Features → Stories → Enablers

# User story → Use spec template
cp specs/spec_template.md specs/WOR-XXX-{feature}-spec.md
# Fill with implementation details
```

### Execution Phase (All Agents)

```bash
# 1. Read spec for clear goal
cat specs/WOR-XXX-{feature}-spec.md

# 2. Extract:
# - User story (goal)
# - Acceptance criteria (success)
# - Low-level tasks (steps)
# - Demo script (validation)

# 3. Implement using Simon's loop:
# - Clear goal from spec
# - Pattern discovery (codebase + specs)
# - Iterate until demo script passes
# - Escalate if blocked
```

## Pattern Discovery Protocol (MANDATORY)

### 0. Search Specs Directory (FIRST)

```bash
# Find similar implementations in specs
ls specs/WOR-*-spec.md | grep "similar_feature"

# Review SAFe user stories
grep -r "As a.*I want to" specs/

# Check patterns from past specs
cat specs/WOR-XXX-similar-spec.md
```

### 1. Search Codebase

```bash
# Search for similar functionality
grep -r "feature_name|functionality" app/

# Find existing helpers
ls lib/ && grep -r "helper_pattern" lib/

# Check components
grep -r "component_pattern" components/
```

### 2. Search Session History

```bash
# Search agent session todos
grep -r "similar_feature|pattern" ~/.claude/todos/ 2>/dev/null

# Find recent implementation patterns
ls -lt ~/.claude/todos/ | head -20
```

### 3. Consult Documentation

- CONTRIBUTING.md - Workflow and git process
- DATA_DICTIONARY.md - Database schema (SINGLE SOURCE OF TRUTH)
- RLS_IMPLEMENTATION_GUIDE.md - Row Level Security (MANDATORY for DB ops)
- SECURITY_FIRST_ARCHITECTURE.md - Security patterns

### 4. Architectural Validation

- Propose pattern to System Architect
- Get approval before implementation
- Document decision in session notes

## Agent Workflow

### Standard Agent Loop (Per Simon Willison)

1. **Clear Goal** - BSA defines with acceptance criteria
2. **Pattern Discovery** - Search codebase and sessions
3. **Iterative Problem Solving**:
   - Implement approach
   - Run validation command
   - If fails → analyze error, adjust, repeat
   - If blocked → escalate to TDM with context
4. **Evidence Attachment** - Session ID + validation results in Linear

### No Over-Engineering

- ❌ No file locks
- ❌ No circuit breakers
- ❌ No arbitrary retry limits
- ✅ Let agents iterate until success or blocked
- ✅ Agent decides when to escalate

## Session Archaeology

### Monitor Concurrent Sessions

```bash
# See active sessions
ls -lt ~/.claude/todos/*.json | head -10

# Check for concurrent work on same files
grep -l "file_path" ~/.claude/todos/*.json
```

### Cross-Agent Coordination

```bash
# Find related work by another agent
grep -r "linear_ticket_number" ~/.claude/todos/

# Discover implementation patterns
grep -r "withUserContext|withAdminContext" ~/.claude/todos/
```

## Related Documentation

### Repository Documentation

- `/CONTRIBUTING.md` - Git workflow, branch naming, commits (MANDATORY READ)
- `/docs/guides/AGENT_TEAM_GUIDE.md` - Team onboarding guide
- `/docs/database/DATA_DICTIONARY.md` - Database schema (AI Context)
- `/docs/database/RLS_DATABASE_MIGRATION_SOP.md` - Schema changes (ARCHitect approval required)
- `/docs/guides/SECURITY_FIRST_ARCHITECTURE.md` - Security patterns (NEW services)

### Agent Files (Claude Code)

- `.claude/agents/bsa.md` - Business Systems Analyst
- `.claude/agents/system-architect.md` - System Architect
- `.claude/agents/tdm.md` - Technical Delivery Manager
- `.claude/agents/fe-developer.md` - Frontend Developer
- `.claude/agents/be-developer.md` - Backend Developer
- `.claude/agents/data-engineer.md` - Data Engineer
- `.claude/agents/data-provisioning-eng.md` - Data Provisioning Engineer
- `.claude/agents/tech-writer.md` - Technical Writer
- `.claude/agents/qas.md` - Quality Assurance Specialist
- `.claude/agents/security-engineer.md` - Security Engineer
- `.claude/agents/rte.md` - Release Train Engineer

## Human-in-the-Loop (HITL) Model

**Product Owner / Product Manager**: Scott

- All work requires evidence in Linear before POPM review
- Swimlane workflow: Backlog → Ready → In Progress → Testing → Ready for Review → Done
- POPM has final approval on all deliverables

---

**Quick Start**: Read CONTRIBUTING.md, search codebase, propose to System Architect, validate with test command, attach evidence to Linear.

---

## 🎯 Agent Invocation Examples

### Simple Invocation (Direct Mention)

Use `@agent-name` for simple, single-step tasks:

```bash
# Planning
@bsa Create a spec for user profile API endpoint
@system-architect Review the RLS policy for user_profiles table

# Implementation
@be-developer Implement the GET /api/user/profile endpoint
@fe-developer Create a UserProfile component with form validation
@data-engineer Add email_verified column to users table

# Quality & Documentation
@qas Write integration tests for user profile feature
@security-engineer Audit RLS policies for user_profiles table
@tech-writer Document the user profile API in README

# Coordination
@tdm Coordinate implementation of WOR-123 user profile feature
@rte Create PR for WOR-123 and run CI validation
```

### Task Tool Invocation (Complex Tasks)

Use `Task()` for complex, multi-step tasks with detailed instructions:

```typescript
// BSA: Create comprehensive spec
Task({
  subagent_type: "bsa",
  description: "Create spec for WOR-123",
  prompt: `Create comprehensive spec for WOR-123 user profile feature.

Requirements:
- User can view and edit their profile
- Profile includes: name, email, bio, avatar
- Email verification required
- Admin can view all profiles

Please:
1. Search for existing user/profile patterns in docs/patterns/
2. Create user story with acceptance criteria
3. Define testing strategy (unit, integration, E2E)
4. Add #EXPORT_CRITICAL tags for security requirements
5. Reference relevant patterns from pattern library`
})

// Backend Developer: Implement with pattern discovery
Task({
  subagent_type: "be-developer",
  description: "Implement WOR-123 API",
  prompt: `Read spec at specs/WOR-123-user-profile-spec.md

Implement the user profile API endpoints:
1. GET /api/user/profile - Get current user's profile
2. PUT /api/user/profile - Update current user's profile
3. GET /api/admin/users/:id/profile - Admin view any profile

Requirements:
- Use withUserContext for user endpoints
- Use withAdminContext for admin endpoints
- Follow RLS patterns from docs/patterns/database/
- Validate input with Zod schemas
- Write unit tests for each endpoint

Pattern discovery is MANDATORY before implementation.`
})

// QAS: Execute comprehensive testing
Task({
  subagent_type: "qas",
  description: "Test WOR-123 feature",
  prompt: `Read spec at specs/WOR-123-user-profile-spec.md

Execute the testing strategy defined by BSA:

1. Unit Tests:
   - Test Zod validation schemas
   - Test RLS context helpers
   - Test error handling

2. Integration Tests:
   - Test GET /api/user/profile with user context
   - Test PUT /api/user/profile with valid/invalid data
   - Test admin endpoints with admin context
   - Test RLS isolation (user A cannot see user B's data)

3. E2E Tests:
   - User can view their profile
   - User can edit their profile
   - Admin can view any profile
   - Unauthorized access is blocked

Validate all acceptance criteria from the spec.`
})

// TDM: Orchestrate entire workflow
Task({
  subagent_type: "tdm",
  description: "Coordinate WOR-123 implementation",
  prompt: `Coordinate complete implementation of WOR-123 user profile feature.

Workflow:
1. Invoke BSA to create spec
2. Review spec and confirm with POPM if needed
3. Invoke Data Engineer for schema changes (if needed)
4. Invoke Backend Developer for API implementation
5. Invoke Frontend Developer for UI implementation
6. Invoke QAS for testing
7. Invoke Security Engineer for security audit
8. Update Linear ticket with progress after each step
9. Invoke RTE to create PR when all work complete

Monitor for blockers and escalate to ARCHitect or POPM as needed.`
})
```

### When to Use Which Invocation Method

| Scenario | Method | Example |
|----------|--------|---------|
| **Simple question** | Direct mention | `@bsa What patterns exist for user authentication?` |
| **Single-step task** | Direct mention | `@be-developer Add logging to the login endpoint` |
| **Multi-step task** | Task tool | BSA creating spec with pattern discovery |
| **Complex coordination** | Task tool | TDM orchestrating multiple agents |
| **Detailed requirements** | Task tool | QAS executing comprehensive test strategy |

### Pro Tips

1. **Always reference specs**: `Read spec at specs/WOR-XXX-spec.md`
2. **Mandate pattern discovery**: `Pattern discovery is MANDATORY before implementation`
3. **Check #EXPORT_CRITICAL tags**: `Review #EXPORT_CRITICAL tags in spec first`
4. **Validate with commands**: Use success validation commands from agent prompts
5. **Update Linear**: TDM can update Linear with `mcp__linear-mcp__create_comment`

---

**Quick Start**: Read CONTRIBUTING.md, search codebase, propose to System Architect, validate with test command, attach evidence to Linear.
