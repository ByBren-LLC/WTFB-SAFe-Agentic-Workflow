# Repository Reorganization Plan - Update Summary

**Date**: 2025-10-08  
**Update Reason**: Keep AGENTS.md and CLAUDE.md in root (AI assistant convention)  
**Impact**: Reduced scope from 10 files → 8 files moved

---

## 🎯 Critical Change

**AGENTS.md and CLAUDE.md will remain in the repository root.**

**Rationale**: These files follow standard conventions set by Anthropic and OpenAI for AI coding assistants (Claude Code, Cursor, Augment, etc.). Moving them would:
- Break established conventions
- Require updating ~30-40 references throughout the codebase
- Confuse AI assistants looking for these files in the standard location

---

## 📊 Updated File Counts

### Before Update
- **Root files after reorganization**: 7
- **Files to move**: 10
- **New directories**: 5 (including docs/agents/)
- **Reference updates needed**: ~50+

### After Update
- **Root files after reorganization**: 9
- **Files to move**: 8
- **New directories**: 4 (docs/agents/ removed)
- **Reference updates needed**: ~25

---

## 📝 Files Updated

### 1. `docs/REPOSITORY-REORGANIZATION-PLAN.md`

**Changes**:
- ✅ Moved AGENTS.md from "Move to /docs/agents/" to "Keep in Root" section
- ✅ Moved CLAUDE.md from "Move to /docs/agents/" to "Keep in Root" section
- ✅ Added rationale: "AI assistant convention"
- ✅ Updated proposed directory structure (removed docs/agents/)
- ✅ Updated file move count: 10 → 8
- ✅ Updated root file count: 7 → 9
- ✅ Removed AGENTS.md and CLAUDE.md from "Reference Update Plan"
- ✅ Updated Phase 1: Removed `mkdir -p docs/agents`
- ✅ Updated Phase 2: Removed git mv commands for AGENTS.md and CLAUDE.md
- ✅ Updated Phase 3: Removed docs/agents/README.md creation
- ✅ Updated commit message template
- ✅ Updated impact analysis (17 → 9 files instead of 17 → 7)
- ✅ Updated verification checklist
- ✅ Updated success criteria

**Lines Changed**: ~15 sections updated

### 2. `scripts/reorganize-docs.sh`

**Changes**:
- ✅ Updated script description: 10 files → 8 files
- ✅ Added note about keeping AGENTS.md and CLAUDE.md in root
- ✅ Removed `mkdir -p docs/agents` command
- ✅ Removed `git mv AGENTS.md docs/agents/` command
- ✅ Removed `git mv CLAUDE.md docs/agents/` command
- ✅ Removed docs/agents/README.md creation (entire section)
- ✅ Updated summary: Files moved 10 → 8
- ✅ Updated summary: Directories created 5 → 4
- ✅ Updated summary: README.md files created 5 → 4

**Lines Changed**: ~60 lines removed/updated

### 3. `scripts/update-doc-references.sh`

**Changes**:
- ✅ Added comment: "AGENTS.md and CLAUDE.md stay in root (AI assistant convention)"
- ✅ Removed sed command for AGENTS.md references
- ✅ Removed sed command for CLAUDE.md references
- ✅ Updated agent prompt section comment

**Lines Changed**: ~4 lines removed, 2 comments added

### 4. `docs/REORGANIZATION-SUMMARY.md`

**Changes**:
- ✅ Updated "Files to Keep in Root": 7 → 9 files
- ✅ Added AGENTS.md and CLAUDE.md to "Keep in Root" section
- ✅ Added rationale for keeping these files
- ✅ Removed AGENTS.md and CLAUDE.md from "To docs/agents/" section
- ✅ Updated file counts: 10 → 8 files moved
- ✅ Updated impact metrics: 17 → 9 files (was 17 → 7)
- ✅ Updated reduction percentage: 59% → 47%
- ✅ Updated commit message template
- ✅ Updated success criteria

**Lines Changed**: ~10 sections updated

---

## ✅ Verification Checklist

All updates completed and verified:

- [x] AGENTS.md listed in "Keep in Root" section of plan
- [x] CLAUDE.md listed in "Keep in Root" section of plan
- [x] No references to moving these files in reorganization script
- [x] No sed commands for updating these file references in update script
- [x] All file counts updated correctly throughout all documents
- [x] docs/agents/ directory is NOT created
- [x] Root directory will have exactly 9 files after reorganization
- [x] Commit message templates updated
- [x] Impact analysis updated (17 → 9 files, 47% reduction)
- [x] Success criteria updated

---

## 📊 Final Summary

### Files Remaining in Root (9 total)

**Essential Files** (7):
1. README.md
2. LICENSE
3. CODE_OF_CONDUCT.md
4. CONTRIBUTING.md
5. CITATION.bib
6. CITATION.cff
7. .env.template

**AI Assistant Convention Files** (2):
8. AGENTS.md
9. CLAUDE.md

### Files Being Moved (8 total)

**To docs/database/** (4 files):
- DATA_DICTIONARY.md
- RLS_IMPLEMENTATION_GUIDE.md
- RLS_POLICY_CATALOG.md
- RLS_DATABASE_MIGRATION_SOP.md

**To docs/security/** (1 file):
- SECURITY_FIRST_ARCHITECTURE.md

**To docs/ci-cd/** (1 file):
- CI-CD-Pipeline-Guide.md

**To docs/archive/** (1 file):
- README-TEMPLATE.md

**To scripts/** (1 file):
- apply-workflow.sh

---

## 📈 Impact Comparison

### Original Plan
- Root files: 17 → 7 (59% reduction)
- Files moved: 10
- Directories created: 5
- Reference updates: ~50+

### Updated Plan
- Root files: 17 → 9 (47% reduction)
- Files moved: 8
- Directories created: 4
- Reference updates: ~25

**Benefit**: Still achieves significant clutter reduction while respecting AI assistant conventions.

---

## 🎯 Next Steps

1. **Review Updated Plan**: Read `docs/REPOSITORY-REORGANIZATION-PLAN.md`
2. **Verify Scripts**: Check `scripts/reorganize-docs.sh` and `scripts/update-doc-references.sh`
3. **Create Linear Ticket**: e.g., WOR-327
4. **Execute**: Run `./scripts/reorganize-docs.sh`
5. **Verify**: Follow verification checklist
6. **Commit**: Use updated commit message template

---

## ✅ Status

**All documentation and scripts updated to reflect the decision to keep AGENTS.md and CLAUDE.md in the repository root.**

**The reorganization plan is ready for execution.**

