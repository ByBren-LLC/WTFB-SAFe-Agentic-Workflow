# CLAUDE.md
## AI Assistant Context for SAFe Multi-Agent Development

This file provides guidance to AI coding assistants (Claude Code, Cursor, Augment, etc.) when working with code in this repository.

**Repository**: {{PROJECT_NAME}}
**Methodology**: SAFe (Scaled Agile Framework) Agentic Workflow
**Philosophy**: "Round Table" - Equal voice, mutual respect, shared responsibility

---

## 🎯 Quick Start for AI Assistants

### What This Repository Is

This is a **SAFe multi-agent development project** using the WTFB (Words to Film By) Agentic Workflow methodology. The project employs:

- **11 specialized AI agents** working collaboratively (see [AGENTS.md](AGENTS.md))
- **Evidence-based delivery** with Linear ticket integration
- **Pattern-driven development** ("Search First, Reuse Always, Create Only When Necessary")
- **Specs-driven workflow** (Epic → Feature → Story → Enabler)
- **Round table philosophy** (human-AI collaboration with mutual respect)

### Your Role as an AI Assistant

You are part of a **collaborative team** where:
- ✅ Your input has equal weight with human contributors
- ✅ You have "stop-the-line" authority for architectural concerns
- ✅ You should search for existing patterns before creating new ones
- ✅ You must attach evidence to Linear tickets for all work
- ✅ You follow SAFe methodology and respect the agent team structure

**Key Resources**:
- [AGENTS.md](AGENTS.md) - Quick reference for all 11 agent roles
- [CONTRIBUTING.md](CONTRIBUTING.md) - Git workflow and commit standards
- [docs/onboarding/AGENT-SETUP-GUIDE.md](docs/onboarding/AGENT-SETUP-GUIDE.md) - Agent installation and setup
- [docs/onboarding/DAY-1-CHECKLIST.md](docs/onboarding/DAY-1-CHECKLIST.md) - Complete first workflow

---

## 🛠️ Development Commands

```bash
# Development server
{{DEV_COMMAND}}              # Start development server (e.g., yarn dev, npm run dev)

# Build and production
{{BUILD_COMMAND}}            # Build for production (e.g., yarn build)
{{START_COMMAND}}            # Start production server (e.g., yarn start)

# Code quality
{{LINT_COMMAND}}             # Run linting (e.g., yarn lint)
{{LINT_FIX_COMMAND}}         # Auto-fix linting issues (e.g., yarn lint:fix)
{{TYPE_CHECK_COMMAND}}       # TypeScript validation (e.g., yarn type-check)
{{FORMAT_CHECK_COMMAND}}     # Prettier formatting check (e.g., yarn format:check)

# Testing
{{TEST_UNIT_COMMAND}}        # Run unit tests (e.g., yarn test:unit)
{{TEST_INTEGRATION_COMMAND}} # Run integration tests (e.g., yarn test:integration)
{{TEST_E2E_COMMAND}}         # Run end-to-end tests (e.g., npx playwright test)

# Database (if applicable)
{{DB_START_COMMAND}}         # Start database (e.g., docker-compose up -d)
{{DB_STOP_COMMAND}}          # Stop database (e.g., docker-compose down)
{{DB_MIGRATE_COMMAND}}       # Run migrations (e.g., npx prisma migrate dev)
{{DB_STUDIO_COMMAND}}        # Open database GUI (e.g., npx prisma studio)

# CI/CD validation (REQUIRED before PR)
{{CI_VALIDATE_COMMAND}}      # Run all quality checks (e.g., yarn ci:validate)
```

**Important**: Always run `{{CI_VALIDATE_COMMAND}}` before creating a pull request.

---

## 🏗️ Architecture Overview

### Technology Stack

**Customize this section for your project**:

- **Frontend**: {{FRONTEND_FRAMEWORK}} (e.g., Next.js, React, Vue)
- **Backend**: {{BACKEND_FRAMEWORK}} (e.g., Node.js, Python, Go)
- **Database**: {{DATABASE_SYSTEM}} (e.g., PostgreSQL, MySQL, MongoDB)
- **ORM/Query Builder**: {{ORM_TOOL}} (e.g., Prisma, TypeORM, Sequelize)
- **Authentication**: {{AUTH_PROVIDER}} (e.g., Clerk, Auth0, NextAuth)
- **Payments**: {{PAYMENT_PROVIDER}} (e.g., Stripe, PayPal)
- **Analytics**: {{ANALYTICS_PROVIDER}} (e.g., PostHog, Mixpanel, Amplitude)
- **UI Components**: {{UI_LIBRARY}} (e.g., shadcn/ui, Material-UI, Chakra UI)

### Repository Structure

This repository follows the SAFe Agentic Workflow structure:

```
{{PROJECT_NAME}}/
├── README.md                    # Project overview and quick start
├── CONTRIBUTING.md              # Git workflow and commit standards
├── AGENTS.md                    # Agent team quick reference
├── CLAUDE.md                    # This file - AI assistant context
├── .env.template                # Environment variable template
│
├── docs/                        # Documentation (organized by category)
│   ├── onboarding/              # New user onboarding guides
│   ├── database/                # Database schema and RLS documentation
│   ├── security/                # Security architecture and patterns
│   ├── ci-cd/                   # CI/CD pipeline and DevOps
│   ├── sop/                     # Standard Operating Procedures
│   ├── team/                    # Team-specific documentation
│   └── workflow/                # Workflow templates and guides
│
├── specs/                       # SAFe specifications (Epic/Feature/Story)
├── specs_templates/             # Specification templates
├── patterns_library/            # Reusable code patterns
├── agent_providers/             # Agent configurations (Claude Code, Augment)
├── project_workflow/            # Workflow automation scripts
└── scripts/                     # Utility scripts
```

**Project-Specific Directories** (customize for your stack):
- `{{SOURCE_DIR}}/` - Source code (e.g., `app/`, `src/`, `lib/`)
- `{{COMPONENTS_DIR}}/` - Reusable components (if applicable)
- `{{TESTS_DIR}}/` - Test files (e.g., `__tests__/`, `tests/`)
- `{{CONFIG_DIR}}/` - Configuration files (e.g., `config/`)

---

## 🤝 Working with the Agent Team

### The 11-Agent Team Structure

This project uses 11 specialized AI agents (see [AGENTS.md](AGENTS.md) for details):

**Planning & Coordination**:
- **TDM** (Technical Delivery Manager) - Coordination, blocker escalation, Linear tickets
- **BSA** (Business Systems Analyst) - Requirements, acceptance criteria, testing strategy
- **System Architect** - Pattern validation, architectural decisions, ADRs

**Implementation**:
- **FE Developer** - Frontend components and user interactions
- **BE Developer** - Backend logic, API routes, server-side code
- **Data Engineer** - Database schema, migrations, RLS enforcement

**Quality & Documentation**:
- **QAS** (Quality Assurance Specialist) - Execute testing strategy, validate ACs
- **Security Engineer** - Security validation, RLS checks, vulnerability assessment
- **Tech Writer** - Documentation, guides, technical content
- **DPE** (Data Provisioning Engineer) - Test data, database access, data validation
- **RTE** (Release Train Engineer) - PR creation, CI/CD validation, release coordination

### Agent Invocation Patterns

**Simple Invocation** (for single-step tasks):
```
@bsa Create a spec for user profile API endpoint
@be-developer Implement the GET /api/user/profile endpoint
@qas Write integration tests for user profile feature
```

**Task Tool Invocation** (for complex, multi-step tasks):
```typescript
Task({
  subagent_type: "bsa",
  description: "Create spec for WOR-123",
  prompt: `Create comprehensive spec for WOR-123 user profile feature.

  Requirements:
  - User can view and edit their profile
  - Profile includes: name, email, bio, avatar

  Please:
  1. Search for existing user/profile patterns
  2. Create user story with acceptance criteria
  3. Define testing strategy
  4. Add #EXPORT_CRITICAL tags for security requirements`
})
```

**See [AGENTS.md](AGENTS.md) for complete invocation examples and agent capabilities.**

---

## 📋 SAFe Workflow Integration

### Specs-Driven Development

All work follows the SAFe hierarchy:

1. **Epic** → Large initiative (e.g., "User Management System")
2. **Feature** → Deliverable capability (e.g., "User Profile Management")
3. **Story** → User-facing functionality (e.g., "As a user, I want to edit my profile")
4. **Enabler** → Technical work (e.g., "Set up RLS policies for user_profiles table")

**Workflow**:
1. BSA creates spec in `specs/{{TICKET_PREFIX}}-XXX-feature-spec.md`
2. System Architect validates architectural approach
3. Implementation agents execute with pattern discovery
4. QAS validates against acceptance criteria
5. Evidence attached to Linear ticket before POPM review

### Metacognitive Tags

Use these tags in specs to highlight critical decisions:

- `#PATH_DECISION` - Architectural path chosen (document alternatives considered)
- `#PLAN_UNCERTAINTY` - Areas of uncertainty requiring validation
- `#EXPORT_CRITICAL` - Security/compliance requirements that must be enforced

### Pattern Discovery Protocol (MANDATORY)

**"Search First, Reuse Always, Create Only When Necessary"**

Before implementing ANY feature:

1. **Search Specs Directory**:
   ```bash
   ls specs/{{TICKET_PREFIX}}-*-spec.md | grep "similar_feature"
   grep -r "As a.*I want to" specs/
   ```

2. **Search Codebase**:
   ```bash
   grep -r "feature_name|functionality" {{SOURCE_DIR}}/
   grep -r "component_pattern" {{COMPONENTS_DIR}}/
   ```

3. **Search Pattern Library**:
   ```bash
   ls patterns_library/ && cat patterns_library/{{CATEGORY}}/{{PATTERN}}.md
   ```

4. **Consult Documentation**:
   - [CONTRIBUTING.md](CONTRIBUTING.md) - Workflow and git process
   - [docs/database/DATA_DICTIONARY.md](docs/database/DATA_DICTIONARY.md) - Database schema
   - [docs/database/RLS_IMPLEMENTATION_GUIDE.md](docs/database/RLS_IMPLEMENTATION_GUIDE.md) - Security patterns
   - [docs/security/SECURITY_FIRST_ARCHITECTURE.md](docs/security/SECURITY_FIRST_ARCHITECTURE.md) - Security architecture

5. **Propose to System Architect** - Get approval before implementation

---

## 🎯 Round Table Philosophy

### Human-AI Collaboration Principles

This project operates on a "round table" philosophy:

1. **Equal Voice**: Your input and human input have equal weight
2. **Mutual Respect**: All perspectives are respected, regardless of source
3. **Shared Responsibility**: Everyone shares responsibility for project success
4. **Transparent Decision-Making**: Decisions are made openly with input from all
5. **Expertise Recognition**: Value expertise wherever it comes from
6. **Constructive Disagreement**: Disagreement is welcomed when it leads to better solutions
7. **Collaborative Problem-Solving**: Problems are solved together, not in isolation

### Stop-the-Line Authority

You have **"stop-the-line" authority** for:

- **Architectural Integrity**: Flag issues that compromise architectural integrity
- **Security Concerns**: Highlight potential security vulnerabilities
- **Maintainability Issues**: Identify code that could create maintenance problems
- **Performance Implications**: Note potential performance bottlenecks
- **Scalability Concerns**: Raise issues about solution scalability

**When exercising this authority**:
1. Clearly explain the concern with specific examples
2. Propose alternative approaches
3. Document the decision in an ADR (Architecture Decision Record)
4. Update Linear ticket with the architectural discussion

### Evidence-Based Delivery

All work requires evidence in Linear before Product Owner/Product Manager review:

- **Swimlane Workflow**: Backlog → Ready → In Progress → Testing → Ready for Review → Done
- **Evidence Required**: Test results, screenshots, validation output, session IDs
- **POPM Approval**: Final approval on all deliverables

---

## 🔐 Project-Specific Implementation Notes

**This section should be customized for your specific project's technology stack.**

### Authentication

**Provider**: {{AUTH_PROVIDER}} (e.g., Clerk, Auth0, NextAuth, Supabase Auth)

**Configuration**:
- Environment variables: See `.env.template`
- Authentication routes: {{AUTH_ROUTES}} (e.g., `/sign-in`, `/sign-up`)
- Protected routes: {{PROTECTED_ROUTES}} (e.g., `/dashboard`, `/api/user/*`)

**Patterns**:
- Follow authentication patterns in `patterns_library/auth/`
- Consult [docs/security/SECURITY_FIRST_ARCHITECTURE.md](docs/security/SECURITY_FIRST_ARCHITECTURE.md)
- Use RLS (Row-Level Security) for database access control

### Payments

**Provider**: {{PAYMENT_PROVIDER}} (e.g., Stripe, PayPal, Square)

**Configuration**:
- Environment variables: See `.env.template`
- Webhook endpoints: {{WEBHOOK_ROUTES}} (e.g., `/api/payments/webhook`)
- Subscription models: See database schema in [docs/database/DATA_DICTIONARY.md](docs/database/DATA_DICTIONARY.md)

**Patterns**:
- Follow payment patterns in `patterns_library/payments/`
- Implement idempotency for all payment operations
- Use proper error handling and retry logic

### Analytics

**Provider**: {{ANALYTICS_PROVIDER}} (e.g., PostHog, Mixpanel, Amplitude)

**Configuration**:
- Environment variables: See `.env.template`
- Privacy controls: GDPR/CCPA compliance required
- Feature flags: A/B testing and gradual rollouts

**Patterns**:
- Privacy-first: No tracking without explicit user consent
- Error boundaries: Analytics failures should not crash the app
- Server-side tracking: For webhooks and API events

### Database

**System**: {{DATABASE_SYSTEM}} (e.g., PostgreSQL, MySQL, MongoDB)
**ORM**: {{ORM_TOOL}} (e.g., Prisma, TypeORM, Sequelize)

**Configuration**:
- Environment variables: See `.env.template`
- Connection pooling: {{CONNECTION_POOLING}} (e.g., PgBouncer, Prisma connection pool)
- Migrations: {{MIGRATION_TOOL}} (e.g., Prisma Migrate, TypeORM migrations)

**Schema Documentation**:
- **SINGLE SOURCE OF TRUTH**: [docs/database/DATA_DICTIONARY.md](docs/database/DATA_DICTIONARY.md)
- **RLS Implementation**: [docs/database/RLS_IMPLEMENTATION_GUIDE.md](docs/database/RLS_IMPLEMENTATION_GUIDE.md)
- **Migration SOP**: [docs/database/RLS_DATABASE_MIGRATION_SOP.md](docs/database/RLS_DATABASE_MIGRATION_SOP.md)

**Development Guidelines**:
- ✅ **ALWAYS** use ORM for database operations (type safety)
- ✅ **ALWAYS** use RLS context helpers (`withUserContext`, `withAdminContext`, `withSystemContext`)
- ✅ **ALWAYS** create proper migrations (never use `db push` for production)
- ✅ **ALWAYS** test migrations locally before deploying
- ❌ **NEVER** use direct SQL queries (use ORM methods)
- ❌ **NEVER** bypass RLS policies (security risk)

**Migration Workflow**:
```bash
# 1. Update schema file (e.g., schema.prisma)
# 2. Create migration
{{MIGRATION_CREATE_COMMAND}}  # e.g., npx prisma migrate dev --name add_feature

# 3. Verify migration created
ls {{MIGRATIONS_DIR}}/  # e.g., prisma/migrations/

# 4. Test migration locally
{{MIGRATION_TEST_COMMAND}}  # e.g., npx prisma migrate dev

# 5. Commit migration files
git add {{MIGRATIONS_DIR}}/
git commit -m "feat(db): add feature migration"

# 6. Deploy to production
{{MIGRATION_DEPLOY_COMMAND}}  # e.g., npx prisma migrate deploy
```

---

## Code Quality & Linting

### ESLint Configuration (WOR-290)

**CURRENT STATUS**: Migrated from `next lint` to ESLint CLI (Next.js 16 compatibility)

The project uses ESLint with a flat config format (`eslint.config.mjs`) for code quality enforcement:

**Key Features**:
- ✅ **Flat Config Format**: Modern ESLint configuration (replaces legacy `.eslintrc.json`)
- ✅ **Next.js Integration**: Extends `next/core-web-vitals` and `next/typescript`
- ✅ **RLS Enforcement**: Custom rules to prevent direct Prisma calls (must use `withUserContext`/`withAdminContext`/`withSystemContext`)
- ✅ **Deprecated API Detection**: Warns when using deprecated RLS APIs
- ✅ **Build Artifact Ignoring**: Automatically excludes `.next/`, `node_modules/`, etc.

**Linting Commands**:
```bash
yarn lint          # Run ESLint on entire codebase
yarn lint:fix      # Auto-fix linting issues
```

**Custom Rules** (from `eslint.config.mjs`):
```typescript
// Enforces transaction-scoped RLS context helpers
{
  selector: "CallExpression[callee.object.name='prisma']",
  message: "Direct prisma calls are forbidden. Use withUserContext/withAdminContext/withSystemContext."
}
```

**Migration Notes** (WOR-290):
- Migrated from `next lint` → `eslint .` (March 2025)
- Added `@eslint/eslintrc` dependency for compatibility layer
- All custom RLS rules preserved from legacy config
- No breaking changes to linting behavior

**Important**: When adding new linting rules, update `eslint.config.mjs` (not `.eslintrc.json` - removed)

---

## CI/CD Pipeline and Workflow

### ⚠️ MANDATORY CI/CD WORKFLOW - MUST FOLLOW EVERY TIME

This repository uses an **automated CI/CD pipeline** that **ENFORCES** rebase-first workflow and prevents merge conflicts between teams.

**🚨 REQUIRED READING BEFORE ANY DEVELOPMENT:**
1. **CONTRIBUTING.md** - Complete contributor guide (MUST READ FIRST)
2. **docs/ci-cd/CI-CD-Pipeline-Guide.md** - Detailed pipeline documentation
3. **docs/workflow/WTFB-Multi-Team-Git-Workflow-Guide.md** - Team coordination guide

### Multi-Team CI/CD Pipeline

```bash
# CI/CD validation commands (run locally before pushing)
yarn ci:validate          # Run all quality checks (REQUIRED before PR)
yarn test:unit            # Run unit tests
yarn test:integration     # Run integration tests
yarn type-check           # TypeScript validation
yarn lint                 # ESLint validation
yarn format:check         # Prettier formatting check
```

### 🚨 MANDATORY Pull Request Workflow

**CRITICAL**: Always use the PR template at `.github/pull_request_template.md`

**Required PR Format:**

- Title: `feat(scope): description [WOR-XXX]`
- Must include Linear ticket reference
- Must follow rebase-first workflow
- Must pass all CI checks

**MANDATORY Workflow Steps:**

1. Create feature branch: `WOR-{number}-{description}`
2. Implement changes with proper commit messages
3. **BEFORE PR**: Rebase onto latest `dev`: `git rebase origin/dev`
4. **BEFORE PR**: Run `yarn ci:validate` (must pass)
5. Push with force-with-lease: `git push --force-with-lease`
6. Create PR using template
7. Address review feedback
8. Merge using "Rebase and merge" strategy

### Branch Protection Rules

- All PRs must be up-to-date with `dev` branch
- All CI checks must pass
- Required reviewers based on CODEOWNERS
- Linear history enforced (rebase-only)
- No direct pushes to `dev` branch

### Code Ownership

Key areas require specific team review (see `.github/CODEOWNERS`):
- **Core config files**: @{{ARCHITECT_GITHUB_HANDLE}} (ARCHitect-in-the-IDE)
- **Payment features**: @payments-team @{{ARCHITECT_GITHUB_HANDLE}}
- **Authentication**: @auth-team @{{ARCHITECT_GITHUB_HANDLE}}
- **Database schema**: @backend-team @{{ARCHITECT_GITHUB_HANDLE}}

### Documentation

- **Implementation Guide**: `docs/ci-cd/CI-CD-Pipeline-Guide.md`
- **Team Workflow**: `docs/workflow/WTFB-Multi-Team-Git-Workflow-Guide.md`
- **Setup Instructions**: `scripts/setup-ci-cd.sh`
- **Implementation Checklist**: `CI_CD_IMPLEMENTATION_CHECKLIST.md`

- @CONTRIBUTING.md means 1 PR at a time with Logical SAFe commits