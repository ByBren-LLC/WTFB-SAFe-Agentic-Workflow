# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

```bash
# Start the development server
yarn dev

# Build for production
yarn build

# Start the production server
yarn start

# Run linting (ESLint CLI - migrated from 'next lint' for Next.js 16 compatibility)
yarn lint

# Run linting with auto-fix
yarn lint:fix

# Start PostgreSQL database (local development)
docker-compose up -d

# Stop PostgreSQL database
docker-compose down

# Run end-to-end tests (Playwright)
npx playwright test

# Prisma database commands
npx prisma generate          # Generate Prisma client
npx prisma migrate deploy    # Run database migrations (production)
npx prisma migrate dev       # Run database migrations (development)
npx prisma studio           # Open Prisma Studio (database GUI)
npx prisma db push          # Push schema changes (dev only)
```

## Architecture Overview

This project is a Next.js web application for WTFB with the following architecture:

### Technology Stack

- **Frontend**: Next.js with App Router, TypeScript, and Tailwind CSS
- **Database**: PostgreSQL with Prisma ORM (type-safe database operations)
- **Authentication**: Clerk (optional)
- **Payments**: Stripe (optional)
- **Analytics**: PostHog (privacy-first with feature flags)
- **Typography**: Inter font (self-hosted via next/font/google)
- **UI Components**: Radix UI, shadcn/ui, Tailwind CSS

### Directory Structure

- `/app`: Next.js App Router pages and routes
  - `/(auth)`: Authentication routes (sign-in, sign-up, etc.)
  - `/(marketing)`: Public marketing pages
  - `/api`: API routes for webhooks and server actions
  - `/dashboard`: User dashboard area (protected)
- `/components`: Reusable React components
  - `/ui`: UI components (buttons, cards, etc.)
  - `/homepage`: Marketing page components
  - `/wrapper`: Layout wrapper components
- `/lib`: Utility functions and shared libraries
  - `lib/prisma.ts`: Prisma client configuration with connection pooling
  - `lib/prisma-verify.ts`: Database connection verification utilities
- `/prisma`: Prisma schema and migrations
  - `schema.prisma`: Database schema definition
  - `/migrations`: Database migration files
- `/public`: Static assets and images
- `/utils`: Helper functions and types

### Feature Toggle System

The application uses a feature toggle system to enable/disable authentication and payments:

```typescript
// Feature flags can be configured in config/features.ts
export const FEATURES = {
  PAYMENTS_ENABLED: process.env.NEXT_PUBLIC_PAYMENTS_ENABLED === 'true',
};
```

## Authentication (Clerk)

The application uses Clerk for authentication, but it's designed to work even when authentication is disabled:

### Clerk Configuration

- Clerk v6 is used for compatibility with Next.js 15
- Environment variables needed:

  ```keys
  NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=your_publishable_key
  CLERK_SECRET_KEY=your_secret_key
  NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
  NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
  NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/
  NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/
  ```

### Auth Pattern

The codebase uses a specific pattern to conditionally use authentication:

1. Create separate components for authenticated content
2. Only import and use Clerk hooks within those components
3. Conditionally render based on `config?.auth?.enabled` or feature flags
4. Provide fallback UI when authentication is disabled

Important: Always `await auth()` calls in Next.js 15 routes.

## Payment Integration (Stripe)

The project includes Stripe integration for payments and subscriptions:

### Stripe Configuration

- Environment variables needed:

  ```keys
  STRIPE_SECRET_KEY=your_secret_key
  NEXT_PUBLIC_STRIPE_PUBLIC_KEY=your_publishable_key
  NEXT_PUBLIC_STRIPE_PRICE_ID=your_price_id
  ```

- Webhooks are configured at `/api/payments/webhook`

### Payment Features

- Checkout sessions for one-time payments
- Subscription management
- Usage-based billing with proper database models

## Analytics Integration (PostHog)

The project uses PostHog for privacy-first analytics, event tracking, and feature flags:

### PostHog Configuration

- Environment variables needed:

  ```env
  # PostHog Project API Key (required for analytics tracking)
  NEXT_PUBLIC_POSTHOG_KEY=your_posthog_api_key
  # PostHog Host URL (default: https://app.posthog.com for PostHog Cloud)
  NEXT_PUBLIC_POSTHOG_HOST=https://app.posthog.com
  
  # Feature Flags and Privacy Controls
  NEXT_PUBLIC_ANALYTICS_ENABLED=true          # Master analytics toggle
  NEXT_PUBLIC_FEATURE_FLAGS_ENABLED=true      # Enable PostHog feature flags
  NEXT_PUBLIC_SESSION_RECORDINGS_ENABLED=false # Session recording (requires user consent)
  ```

### Analytics Features

- **Privacy-first**: No tracking without explicit user consent
- **Page view tracking**: Automatic tracking of navigation
- **Custom events**: User interactions and conversions
- **Feature flags**: A/B testing and gradual rollouts
- **Error boundaries**: Analytics failures don't crash the app

### Usage Pattern

The codebase uses a specific pattern for analytics:

1. **PostHogProvider**: Wraps the entire app for initialization
2. **useAnalytics hook**: Access analytics functionality in components
3. **Server-side tracking**: For webhooks and API events
4. **Consent management**: User privacy controls (implemented in User Story 3)

Important: Always handle analytics gracefully with error boundaries.

### 🎯 PostHog Implementation Status - MIGRATION COMPLETE! 🎉

**✅ COMPLETED User Stories (ALL DONE):**
- **User Story 1**: Vercel Analytics Removal ✅
- **User Story 2**: PostHog SDK Setup (WOR-135) ✅
- **User Story 3**: Privacy & Consent Management (WOR-141) ✅
- **User Story 4**: Core Event Tracking (WOR-142) ✅
- **User Story 5**: Feature Flag System (WOR-143) ✅
- **User Story 6**: Performance Monitoring (WOR-144) ✅
- **User Story 7**: Migration Completion (WOR-145) ✅

**🚀 MIGRATION COMPLETE**: Full PostHog analytics system operational with zero Vercel dependencies!

**📋 Complete Implementation Stack:**
- ✅ PostHog client initialization (`lib/posthog/client.ts`)
- ✅ Server-side PostHog setup (`lib/posthog/server.ts`) 
- ✅ Comprehensive event tracking (`lib/posthog/events.ts`)
- ✅ Feature flag system (`lib/posthog/flags.ts`)
- ✅ Performance monitoring (`lib/posthog/performance.ts`)
- ✅ Debug utilities (`lib/posthog/debug.ts`)
- ✅ Privacy & consent management (`hooks/use-consent.ts`)
- ✅ Analytics provider (`components/analytics/analytics-provider.tsx`)
- ✅ Error boundaries (`components/analytics/posthog-provider.tsx`)
- ✅ Health check API (`app/api/health/analytics/route.ts`)

**Core Features Operational:**
1. ✅ **Privacy-First Analytics** - GDPR compliant consent system
2. ✅ **6 Core Events** - Complete user journey tracking
3. ✅ **Feature Flags** - A/B testing and gradual rollouts
4. ✅ **Performance Monitoring** - Sub-50ms impact analytics
5. ✅ **Error Tracking** - Graceful failure handling
6. ✅ **Server & Client Tracking** - Full-stack analytics coverage

**📍 Migration Complete Status:**
- **Font**: Migrated from Geist Sans to Inter font ✅
- **Dependencies**: All Vercel packages removed ✅  
- **Analytics**: PostHog fully operational ✅
- **Performance**: <50ms user impact maintained ✅

## Database Setup

**CURRENT STATUS**: Fully migrated to Prisma ORM with type-safe database operations.

### Current Implementation

- **✅ Active**: Prisma ORM for all database operations
- **✅ Active**: Database connection handled by `lib/prisma.ts`
- **✅ Active**: Generated Prisma types for TypeScript safety
- **✅ Active**: Prisma migrations for schema management
- **✅ Active**: Zod schemas with Prisma compatibility layer
- **✅ Active**: Helper functions in `@/utils/data/` for business logic

### Database Configuration

Environment variables required for Prisma:

```env
# Required for Prisma ORM
DATABASE_URL=postgresql://[user]:[password]@[host]:[port]/[database]?schema=public

# Required for migrations (bypasses connection pooling)
DIRECT_URL=postgresql://[user]:[password]@[host]:[port]/[database]?schema=public
```

### Local Development

- PostgreSQL runs in Docker via `docker-compose.yml`
- Default connection: `postgresql://wtfb_user:wtfb_password@localhost:5432/wtfb_dev`
- Start database: `docker-compose up -d`
- **Prisma commands**:
  ```bash
  # Generate Prisma client
  npx prisma generate

  # Run migrations
  npx prisma migrate dev

  # View database in Prisma Studio
  npx prisma studio
  ```

### Production Setup

- Coolify.io with separate PostgreSQL instance
- Connection details managed through Coolify.io environment variables
- Prisma ORM handles all database operations via `lib/prisma.ts`

### Development Guidelines

- **✅ USE**: Prisma ORM for all database operations
- **✅ USE**: Helper functions from `@/utils/data/` for business logic
- **✅ USE**: Zod schemas with Prisma compatibility layer for validation
- **✅ USE**: Generated Prisma types for TypeScript safety
- **❌ AVOID**: Direct SQL queries (use Prisma client methods instead)

### 🚨 **MIGRATION PREVENTION CHECKLIST** (Added after WOR-189)

**CRITICAL: To prevent database schema drift issues in the future:**

#### **Before Adding New Tables/Columns:**
1. **✅ ALWAYS** create proper Prisma migrations: `npx prisma migrate dev --name descriptive_name`
2. **✅ NEVER** use `prisma db push` for production-bound changes
3. **✅ ALWAYS** test migrations locally first
4. **✅ ALWAYS** verify migration files are committed to git

#### **Schema Change Workflow:**
```bash
# 1. Update schema.prisma
# 2. Create migration
npx prisma migrate dev --name add_new_feature_tables

# 3. Verify migration created
ls prisma/migrations/

# 4. Test migration locally
DATABASE_URL="postgresql://wtfb_user:wtfb_password@localhost:5433/wtfb_dev" npx tsx scripts/verify-all-migrations.ts

# 5. Commit migration files
git add prisma/migrations/
git commit -m "feat(db): add new feature tables migration"
```

#### **Production Deployment Verification:**
- **✅ REQUIRED**: Run `npx prisma migrate status` before deployment
- **✅ REQUIRED**: Ensure all migrations are applied: `npx prisma migrate deploy`
- **✅ REQUIRED**: Verify table count matches expected (currently 10 tables)
- **✅ REQUIRED**: Run verification script after production deployment

#### **Database Schema Status (WOR-189 Resolution):**
- **Total Tables**: 11 (verified 2025-08-28)
- **Migration Status**: Complete and synchronized
- **Last Schema Update**: WOR-189 (Fresh migration deployment)

**🎯 Key Lesson**: Schema changes MUST go through proper Prisma migration workflow to prevent drift between local, staging, and production environments.

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

## Image Assets

The project expects certain image assets in the `/public/images` directory:

- Hero images for light and dark mode
- Tier images for pricing (free, pro, founders club)
- Book images for marketing materials

## E2E Testing

The project includes Playwright tests for end-to-end testing:

- Tests for marketing pages
- Tests for authentication flows
- Helper functions for signing in users

## CI/CD Pipeline and Workflow

### ⚠️ MANDATORY CI/CD WORKFLOW - MUST FOLLOW EVERY TIME

This repository uses an **automated CI/CD pipeline** that **ENFORCES** rebase-first workflow and prevents merge conflicts between teams.

**🚨 REQUIRED READING BEFORE ANY DEVELOPMENT:**
1. **CONTRIBUTING.md** - Complete contributor guide (MUST READ FIRST)
2. **docs/CI-CD-Pipeline-Guide.md** - Detailed pipeline documentation
3. **docs/WTFB-Multi-Team-Git-Workflow-Guide.md** - Team coordination guide

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

- **Implementation Guide**: `docs/CI-CD-Pipeline-Guide.md`
- **Team Workflow**: `docs/WTFB-Multi-Team-Git-Workflow-Guide.md`
- **Setup Instructions**: `scripts/setup-ci-cd.sh`
- **Implementation Checklist**: `CI_CD_IMPLEMENTATION_CHECKLIST.md`

- @CONTRIBUTING.md means 1 PR at a time with Logical SAFe commits