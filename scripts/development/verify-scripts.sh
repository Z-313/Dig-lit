#!/bin/bash
echo "🔍 Verifying all scripts are working..."

SCRIPTS=(
    "deep-audit.sh"
    "auto-fix.sh" 
    "claude-fix-apply.sh"
    "fix-frontend.sh"
    "fix-backend.sh"
    "cleanup-structure.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        echo "✅ $script - exists and executable"
    else
        echo "❌ $script - missing or not executable"
    fi
done

echo ""
echo "📋 Available npm commands:"
cd /workspaces/Dig-lit
npm run | grep -E "(fix|audit|validate|structure)"
