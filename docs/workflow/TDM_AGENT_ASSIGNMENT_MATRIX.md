# TDM Agent Assignment Matrix

**Purpose**: Guide for assigning work to specialized agents in the SAFe ART team

**Version**: 1.1 (Added System Architect Review Gates)
**Last Updated**: 2025-10-06

---

## Agent Roster & Specializations

### Planning Agents (Opus Model)

#### Business Systems Analyst (BSA)
- **Primary Responsibilities**: Requirements decomposition, acceptance criteria, testing strategy
- **Tools**: Read, Write, Edit, Bash, Grep, Glob, Linear MCP
- **When to Assign**: User story creation, spec writing, requirements clarification
- **Success Validation**: `yarn lint:md`

#### System Architect
- **Primary Responsibilities**: Pattern validation, architectural review, code quality enforcement
- **Tools**: Read, Grep, Glob (read-only for review)
- **When to Assign**: 
  - Pattern approval requests
  - Architectural decision reviews
  - **MANDATORY: Complex code review (see triggers below)**
- **Success Validation**: Approval documented in Linear

### Execution Agents (Sonnet Model)

#### Backend Developer
- **Primary Responsibilities**: API routes, server logic, database operations
- **Tools**: Read, Write, Edit, Bash, Grep, Glob
- **When to Assign**: API endpoints, server-side logic, business logic
- **Success Validation**: `yarn test:integration && yarn lint`

#### Frontend Developer
- **Primary Responsibilities**: UI components, client-side logic, user interactions
- **Tools**: Read, Write, Edit, Bash, Grep, Glob
- **When to Assign**: React components, UI/UX, client-side state
- **Success Validation**: `yarn test:unit && yarn lint && yarn build`

#### Data Engineer
- **Primary Responsibilities**: Schema changes, migrations, database architecture
- **Tools**: Read, Write, Edit, Bash, Grep, Glob, Prisma
- **When to Assign**: Database migrations, schema changes, RLS policies
- **Success Validation**: Migration applied successfully, RLS maintained

### Quality & Coordination Agents (Sonnet Model)

#### Quality Assurance Specialist (QAS)
- **Primary Responsibilities**: Execute testing strategy, validate acceptance criteria
- **Tools**: Read, Bash, Playwright, Jest
- **When to Assign**: Test execution, acceptance criteria validation
- **Success Validation**: All tests passing, evidence collected

#### Security Engineer
- **Primary Responsibilities**: Security validation, RLS enforcement, vulnerability assessment
- **Tools**: Read, Bash, RLS validation scripts
- **When to Assign**: Security reviews, RLS validation, vulnerability scans
- **Success Validation**: Security audit passed, RLS enforced

#### Technical Delivery Manager (TDM)
- **Primary Responsibilities**: Coordination, blocker escalation, Linear ticket management
- **Tools**: Linear MCP, GitHub, Confluence
- **When to Assign**: Cross-team coordination, blocker resolution
- **Success Validation**: Linear updated, blockers resolved

#### Release Train Engineer (RTE)
- **Primary Responsibilities**: PR creation, CI/CD validation, release coordination
- **Tools**: Git, GitHub CLI, CI tools
- **When to Assign**: PR creation, release coordination, CI/CD setup
- **Success Validation**: `yarn ci:validate` passes, PR created

---

## System Architect Review Triggers (MANDATORY)

**Critical Update (v1.1)**: Based on WOR-321 gap discovery, System Architect review is **MANDATORY** before PR creation for the following:

### Infrastructure & Automation

- [ ] **Bash scripts >100 lines**
  - Example: Deployment scripts, automation tools, setup scripts
  - WOR-321 Gap: 710-line `deploy-migration-prod.sh` delivered without review

- [ ] **CI/CD workflow creation or modification**
  - Example: GitHub Actions workflows, pipeline changes
  - WOR-321 Gap: 641-line `migration-validation.yml` delivered without review

- [ ] **Infrastructure-as-code**
  - Example: Terraform, CloudFormation, Docker Compose
  - Impact: Production infrastructure changes

- [ ] **Deployment automation scripts**
  - Example: Production deployment, rollback scripts
  - Impact: Security-critical operations (SSH, Docker, credentials)

- [ ] **Container orchestration changes**
  - Example: Kubernetes manifests, Docker configurations
  - Impact: Production environment changes

### Security-Critical Code

- [ ] **Database migration automation**
  - Example: Migration deployment scripts, RLS automation
  - Impact: Data integrity, security policies

- [ ] **Authentication/authorization logic**
  - Example: Auth middleware, permission checks
  - Impact: Security boundaries

- [ ] **SSH/remote execution scripts**
  - Example: Remote deployment, server management
  - Impact: Production access, credential handling

- [ ] **Secret management code**
  - Example: Credential rotation, secret injection
  - Impact: Security posture

- [ ] **RLS policy automation**
  - Example: Automated policy generation, validation
  - Impact: Data security enforcement

### Complex TypeScript/JavaScript

- [ ] **Validation/verification scripts >200 lines**
  - Example: Pre-commit hooks, data validation
  - WOR-321 Gap: 3 TypeScript scripts delivered without review

- [ ] **Custom build tools**
  - Example: Build scripts, code generation
  - Impact: Development workflow

- [ ] **Database query builders**
  - Example: Dynamic query construction
  - Impact: SQL injection risk, performance

- [ ] **Pre-commit hooks**
  - Example: Linting automation, validation
  - Impact: Developer workflow

### When in Doubt

**Rule of Thumb**: If deliverable includes ANY executable code that could impact production, invoke System Architect.

**Example Gap (WOR-321)**: 
- Created: 710-line deployment script + 641-line CI/CD workflow + 3 TypeScript scripts
- System Architect Review: ❌ NOT invoked
- Result: Unreviewed security-critical code in production path

**Lesson**: Always invoke System Architect for complex automation BEFORE PR creation

---

## Assignment Decision Tree

### Step 1: Identify Work Type

```
What type of work is this?
├─ Requirements/Planning → BSA
├─ Database/Schema → Data Engineer
├─ API/Backend → Backend Developer
├─ UI/Frontend → Frontend Developer
├─ Testing → QAS
├─ Security → Security Engineer
├─ CI/CD → RTE
├─ Coordination → TDM
└─ Architectural Review → System Architect
```

### Step 2: Check Complexity

```
Does work include complex code/automation?
├─ YES → Check System Architect review triggers
│   ├─ Bash script >100 lines? → MANDATORY System Architect review
│   ├─ CI/CD workflow? → MANDATORY System Architect review
│   ├─ Infrastructure automation? → MANDATORY System Architect review
│   ├─ TypeScript/JavaScript >200 lines? → MANDATORY System Architect review
│   └─ Security-critical code? → MANDATORY System Architect review
└─ NO (documentation only) → Proceed with specialist assignment
```

### Step 3: Assign Specialist

Based on work type, assign to appropriate specialist agent.

### Step 4: System Architect Review (if triggered)

If any complexity trigger matched:
1. Specialist completes work
2. **MANDATORY**: Invoke System Architect for review
3. System Architect approves OR requires fixes
4. Only after approval: Proceed to PR

---

## Common Assignment Patterns

### Pattern 1: Simple Feature Implementation

```
BSA (Spec) → BE Developer (Implementation) → QAS (Testing) → RTE (PR)
```

### Pattern 2: Database Migration

```
BSA (Spec) → Data Engineer (Migration) → Security Engineer (RLS) → System Architect (Review) → RTE (PR)
```

### Pattern 3: Complex Automation (WOR-321 Pattern)

```
Investigation → Data Engineer (Scripts) → System Architect (Review) → RTE (CI/CD) → System Architect (Final Review) → PR
```

**Note**: Pattern 3 is the CORRECT workflow. WOR-321 skipped both System Architect reviews.

### Pattern 4: UI Feature

```
BSA (Spec) → FE Developer (Component) → QAS (E2E Tests) → RTE (PR)
```

---

## Quality Gates

### Before PR Creation

**MANDATORY Checklist**:

- [ ] All acceptance criteria met
- [ ] Tests passing (`yarn ci:validate`)
- [ ] Evidence attached to Linear
- [ ] **System Architect approval (if complex code)**
- [ ] Security review (if security-sensitive)
- [ ] Documentation updated

**If ANY System Architect trigger matched: BLOCK PR until review approved**

---

## Escalation Paths

### Technical Blockers
- **First**: System Architect (architectural guidance)
- **Second**: TDM (cross-team coordination)
- **Third**: Product Owner (business decision)

### Process Issues
- **First**: TDM (workflow clarification)
- **Second**: RTE (CI/CD issues)
- **Third**: Team retrospective

### Security Concerns
- **First**: Security Engineer (immediate review)
- **Second**: System Architect (architectural impact)
- **Third**: Security team escalation

---

## Success Metrics

### Individual Agent Performance
- Deliverables meet acceptance criteria
- Evidence consistently provided
- Pattern reuse over new code
- Quality gates passed

### System Architect Review Effectiveness
- 100% of complex automation reviewed
- 0% unreviewed scripts >100 lines
- Architectural governance enforced
- Quality standards maintained

### Team Velocity
- Velocity maintained with quality gates
- Reduced production incidents
- Faster reviews (clear triggers)
- Higher confidence in deliverables

---

## Version History

### v1.1 (2025-10-06)
- **Added**: System Architect Review Triggers (MANDATORY)
- **Rationale**: WOR-321 gap discovery (unreviewed complex automation)
- **Impact**: Prevents future governance gaps

### v1.0 (2025-10-05)
- Initial agent assignment matrix
- Basic role definitions
- Assignment patterns

---

**Related Documentation**:
- `ARCHITECT_IN_CLI_ROLE.md` - When to invoke System Architect
- `AGENT_WORKFLOW_SOP.md` - Detailed workflow processes
- `PRE_PR_VALIDATION_CHECKLIST.md` - Quality gates before PR
- `WORKFLOW_QUALITY_CHECKLIST.md` - ARCHitect-in-CLI self-validation

**Reference**: WOR-321 Migration Automation Workflow Report (gap analysis)

