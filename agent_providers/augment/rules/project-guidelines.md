# Project Guidelines

## Purpose

Define project-specific guidelines for development using SAFe Essentials methodology and Augment Code integration.

## Project Context

### Technology Stack

- **Frontend**: Next.js 15 with TypeScript, Shadcn UI, React components
- **Backend**: Next.js API routes with TypeScript
- **Database**: Self-hosted PostgreSQL on Coolify.io with Prisma ORM
- **Caching**: Self-hosted Redis on Coolify.io
- **Authentication**: Clerk with custom theming
- **Deployment**: Coolify.io PaaS on Hostinger VPS KVM 4
- **Monitoring**: PostHog analytics (with PostHog MCP), self-hosted Redis rate limiting

### Development Workflow

#### 1. SAFe Methodology Integration

- All work must be planned in Confluence (`__CONFLUENCE_SPACE_KEY__` space) before implementation
- Decompose work into project management tool epics and stories
- Use labels for assignment: `Auggie` for architecture, `Claude Code` for implementation
- Follow SAFe logical commits and PR workflow

#### 2. Planning Process

1. **Confluence Planning**: Create comprehensive planning documents
2. **Project Management Tool Decomposition**: Break down into epics and stories
3. **Specification Creation**: Use `specs_templates/` planning methods
4. **Implementation**: Assign work with appropriate labels

#### 3. Branch Management

- **Format**: `__TICKET_PREFIX__-{number}-{description}` (NOT `feature/__TICKET_PREFIX__-{number}`)
- **Types**: `feature/`, `fix/`, `hotfix/`, `release/`, `chore/`, `docs/`, `test/`, `refactor/`
- **CI/CD**: Branch names validated by CI/CD pipeline
- **Cleanup**: Sync local branches after merging `__PRIMARY_DEV_BRANCH__` to `master`

### Environment Management

#### Local Development
- Use Docker Compose for PostgreSQL (`docker-compose.yml`)
- Environment variables from `.env.template`
- Clerk dev keys for authentication
- Local database: `postgresql://user:password@localhost:5432/dev_db`

#### Production (Coolify.io)
- Self-hosted PostgreSQL and Redis
- Production Clerk keys in environment variables
- Proper SSL and security configurations
- Performance monitoring and logging

### Communication Patterns

#### Tool Integration
- **Confluence**: Single source of truth for planning and architecture
- **Project Management Tool**: Work decomposition and tracking with proper labels
- **GitHub**: Code repository with PR templates and SAFe workflow
- **Slack**: Team notifications and status updates

#### Documentation Requirements
- All architectural decisions documented in Confluence
- API changes documented with examples
- Database schema changes tracked in Prisma migrations
- Deployment procedures documented in README

### Quality Assurance

#### Testing Strategy
- Test all changes locally before pushing
- Include unit tests for business logic
- Integration tests for API endpoints
- End-to-end tests for critical user flows
- Performance testing for database operations

#### Code Review Process
- Use GitHub PR templates with SAFe requirements
- Include technical details and testing checklists
- Require team consultation for architectural changes
- Document decisions and rationale

### Tool Usage Standards

#### Confluence API Patterns
```
# Document Creation
endpoint: /content
method: POST
data: {
  "type": "page",
  "title": "[Project]-[Component] [Action]: [Description]",
  "space": {"key": "__CONFLUENCE_SPACE_KEY__"},
  "body": {"storage": {"value": "[HTML Content]", "representation": "storage"}}
}

# Required Elements
- Space key: "__CONFLUENCE_SPACE_KEY__" for project
- HTML format for rich content
- Attribution footer with Augment Code link
- Proper metadata sections
```

#### Project Management Tool API Patterns

**CRITICAL**: Always use proper GraphQL mutation syntax. API requires exact GraphQL format.

```graphql
# Issue Creation - CORRECT FORMAT
mutation IssueCreate {
  issueCreate(
    input: {
      title: "Issue Title"
      description: "Detailed description in markdown"
      teamId: "__PROJECT_MANAGEMENT_TEAM_ID__"
      labelIds: ["label-uuid-1", "label-uuid-2"]
    }
  ) {
    success
    issue {
      id
      identifier
      title
      url
    }
  }
}

# Issue Update
mutation IssueUpdate {
  issueUpdate(
    id: "issue-uuid-or-identifier"
    input: {
      title: "Updated Title"
      description: "Updated description"
      stateId: "state-uuid"
    }
  ) {
    success
    issue {
      id
      identifier
      title
    }
  }
}

# Query Issues
query Issues {
  issues(filter: {team: {id: {eq: "__PROJECT_MANAGEMENT_TEAM_ID__"}}}) {
    nodes {
      id
      identifier
      title
      description
      state {
        id
        name
      }
      labels {
        nodes {
          id
          name
        }
      }
    }
  }
}
```

**Project Management Tool Team Configuration:**
- Team ID: `__PROJECT_MANAGEMENT_TEAM_ID__` (Your project team ID)
- Team Key: `__TICKET_PREFIX__`

**Essential Label IDs:**
- `Auggie-Arch`: `__AUGGIE_ARCH_LABEL_ID__` (Architecture work)
- `Feature`: `__FEATURE_LABEL_ID__` (New features)
- `Claude Code`: `__CLAUDE_CODE_LABEL_ID__` (Implementation work)
- `Auggie`: `__AUGGIE_LABEL_ID__` (Auggie assignments)
- `Improvement`: `__IMPROVEMENT_LABEL_ID__` (Enhancements)
- `Bug`: `__BUG_LABEL_ID__` (Bug fixes)

**State IDs (Your Project Team):**
- `Backlog`: `__BACKLOG_STATE_ID__`
- `Todo`: `__TODO_STATE_ID__`
- `In Progress`: `__IN_PROGRESS_STATE_ID__`
- `In Review`: `__IN_REVIEW_STATE_ID__`
- `Done`: `__DONE_STATE_ID__`
- `Canceled`: `__CANCELED_STATE_ID__`

**Usage Rules:**
1. Always use GraphQL mutation format, not natural language
2. Include proper return fields (id, identifier, title, url)
3. Use correct team ID for your project
4. Apply appropriate labels for work assignment
5. Reference parent issues in description, not parentId field
6. Use markdown formatting in descriptions
7. Include acceptance criteria and effort estimates

### Deployment Process

#### Development Flow
1. Local development and testing
2. Push to `__PRIMARY_DEV_BRANCH__` branch
3. Create PR with proper template
4. Code review and approval
5. Merge to `master` for deployment
6. Monitor deployment and performance

#### Emergency Procedures
- Hotfix branches for critical issues
- Rollback procedures documented
- Incident response protocols
- Post-incident reviews and documentation
