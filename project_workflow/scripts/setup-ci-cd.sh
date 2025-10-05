#!/bin/bash

# __PROJECT_NAME__ CI/CD Pipeline Setup Script
# This script helps configure the GitHub repository for multi-team collaboration

set -e

echo "🚀 __PROJECT_NAME__ CI/CD Pipeline Setup"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) is not installed${NC}"
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}⚠️ Not authenticated with GitHub CLI${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

# Get repository information
REPO_OWNER=$(gh repo view --json owner --jq .owner.login)
REPO_NAME=$(gh repo view --json name --jq .name)

echo -e "${BLUE}📋 Repository: ${REPO_OWNER}/${REPO_NAME}${NC}"

# Function to check if secret exists
check_secret() {
    local secret_name=$1
    if gh secret list | grep -q "^${secret_name}"; then
        echo -e "${GREEN}✅ Secret ${secret_name} exists${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️ Secret ${secret_name} not found${NC}"
        return 1
    fi
}

# Function to set secret
set_secret() {
    local secret_name=$1
    local secret_description=$2
    
    echo -e "${BLUE}🔐 Setting up secret: ${secret_name}${NC}"
    echo "Description: ${secret_description}"
    echo -n "Enter value (input will be hidden): "
    read -s secret_value
    echo
    
    if [ -n "$secret_value" ]; then
        echo "$secret_value" | gh secret set "$secret_name"
        echo -e "${GREEN}✅ Secret ${secret_name} set successfully${NC}"
    else
        echo -e "${YELLOW}⚠️ Skipping empty secret${NC}"
    fi
}

# Check and setup required secrets
echo -e "\n${BLUE}🔐 Checking GitHub Secrets${NC}"
echo "================================"

# Linear API key for ticket integration
if ! check_secret "LINEAR_API_KEY"; then
    echo -e "${YELLOW}Setting up Linear integration...${NC}"
    set_secret "LINEAR_API_KEY" "Linear API key for ticket updates"
fi

# Setup branch protection rules
echo -e "\n${BLUE}🛡️ Setting up Branch Protection${NC}"
echo "=================================="

# Check if __PRIMARY_DEV_BRANCH__ branch exists
if ! gh api repos/${REPO_OWNER}/${REPO_NAME}/branches/__PRIMARY_DEV_BRANCH__ &> /dev/null; then
    echo -e "${YELLOW}⚠️ __PRIMARY_DEV_BRANCH__ branch doesn't exist. Creating it...${NC}"
    
    # Create __PRIMARY_DEV_BRANCH__ branch from main/master
    DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)
    git checkout $DEFAULT_BRANCH
    git pull origin $DEFAULT_BRANCH
    git checkout -b __PRIMARY_DEV_BRANCH__
    git push origin __PRIMARY_DEV_BRANCH__
    
    echo -e "${GREEN}✅ __PRIMARY_DEV_BRANCH__ branch created${NC}"
fi

# Apply branch protection rules
echo -e "${BLUE}Applying branch protection rules to __PRIMARY_DEV_BRANCH__ branch...${NC}"

PROTECTION_RULES='{
  "required_status_checks": {
    "strict": true,
    "checks": [
      {"context": "🔍 Validate Branch & PR Structure"},
      {"context": "🔄 Check Rebase Status"},
      {"context": "🧪 Test Suite (unit)"},
      {"context": "🧪 Test Suite (integration)"},
      {"context": "🔍 Quality & Security"},
      {"context": "🏗️ Build Verification"}
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}'

if gh api repos/${REPO_OWNER}/${REPO_NAME}/branches/__PRIMARY_DEV_BRANCH__/protection \
   --method PUT \
   --input - <<< "$PROTECTION_RULES" &> /dev/null; then
    echo -e "${GREEN}✅ Branch protection rules applied${NC}"
else
    echo -e "${YELLOW}⚠️ Could not apply branch protection rules (may require admin access)${NC}"
fi

# Verify workflow files
echo -e "\n${BLUE}📋 Verifying Workflow Files${NC}"
echo "============================"

WORKFLOW_FILES=(
    ".github/workflows/main.yml"
    ".github/CODEOWNERS"
    ".github/pull_request_template.md"
)

for file in "${WORKFLOW_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ ${file}${NC}"
    else
        echo -e "${RED}❌ ${file} missing${NC}"
    fi
done

# Test CI scripts locally
echo -e "\n${BLUE}🧪 Testing CI Scripts${NC}"
echo "===================="

if [ -f "package.json" ]; then
    echo "Testing local CI validation..."
    
    if yarn ci:validate &> /dev/null; then
        echo -e "${GREEN}✅ CI validation scripts work${NC}"
    else
        echo -e "${YELLOW}⚠️ CI validation scripts need attention${NC}"
    fi
fi

# Summary
echo -e "\n${GREEN}🎉 Setup Complete!${NC}"
echo "=================="
echo
echo "Next steps:"
echo "1. Verify all team members are added to GitHub teams"
echo "2. Test the workflow by creating a sample PR"
echo "3. Train team members on the new workflow"
echo
echo "Documentation:"
echo "- Workflow guide: CONTRIBUTING.md"
echo "- Agent team guide: AGENTS.md"
echo
echo "Support: Check project documentation for assistance"

