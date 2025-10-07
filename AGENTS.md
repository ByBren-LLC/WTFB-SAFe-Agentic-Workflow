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
