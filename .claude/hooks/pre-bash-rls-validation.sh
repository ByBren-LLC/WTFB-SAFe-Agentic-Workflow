#!/bin/bash
# Pre-Bash Hook: RLS Validation
#
# Validates RLS context before Prisma/SQL database operations
# Exit code 0: Allow operation
# Exit code 2: Block operation

# Get the bash command being executed
BASH_COMMAND="$1"

# Check if command involves Prisma or SQL operations
if echo "$BASH_COMMAND" | grep -E "(npx prisma|psql|DATABASE_URL)" > /dev/null; then

  # Check if RLS context is mentioned
  if echo "$BASH_COMMAND" | grep -E "(withUserContext|withAdminContext|withSystemContext)" > /dev/null; then
    # RLS context found - allow
    echo "✅ RLS context detected in command"
    exit 0
  fi

  # Check if it's a migration or schema operation (allowed)
  if echo "$BASH_COMMAND" | grep -E "(prisma migrate|prisma generate|prisma studio)" > /dev/null; then
    echo "✅ Prisma schema operation - allowed"
    exit 0
  fi

  # Database operation without RLS context - warn but don't block
  echo "⚠️  WARNING: Database operation without explicit RLS context"
  echo "   Command: $BASH_COMMAND"
  echo "   Consider using withUserContext/withAdminContext/withSystemContext"
  exit 0  # Allow but warn
fi

# Not a database operation - allow
exit 0
