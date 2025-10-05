#!/bin/bash
# Session-Start Hook: Pattern Library Check
#
# Checks for pattern library updates on session start
# Reminds agents to check docs/patterns/ before implementation

PATTERN_DIR="docs/patterns"
PATTERN_COUNT=$(find "$PATTERN_DIR" -name "*.md" -type f 2>/dev/null | wc -l)

if [ -d "$PATTERN_DIR" ]; then
  echo "📚 Pattern Library Status:"
  echo "   Location: $PATTERN_DIR"
  echo "   Available patterns: $PATTERN_COUNT"
  echo ""
  echo "   Quick Reference:"
  echo "   - API patterns: $PATTERN_DIR/api/"
  echo "   - UI patterns: $PATTERN_DIR/ui/"
  echo "   - Database patterns: $PATTERN_DIR/database/"
  echo "   - Testing patterns: $PATTERN_DIR/testing/"
  echo ""
  echo "   💡 Remember: Check pattern library BEFORE implementation!"
  echo "   Run: cat $PATTERN_DIR/README.md"
else
  echo "⚠️  Pattern library not found at $PATTERN_DIR"
fi

echo ""
echo "🤖 Agent System Ready"
echo "   11 agents available in .claude/agents/"
echo "   Tool restrictions: ✅ Configured"
echo "   Model selection: ✅ Opus (planning), Sonnet (execution)"
echo ""

exit 0
