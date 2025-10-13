#!/bin/bash
# Manual Fix Helper for Remaining Issues

echo "🔧 MANUAL FIX HELPER - Fixing Remaining Issues"
echo "================================================"

# Issue 1: Check for merge conflicts
echo ""
echo "1️⃣  Checking for merge conflicts..."
CONFLICTS=$(git diff --name-only --diff-filter=U)

if [ -n "$CONFLICTS" ]; then
    echo "❌ Merge conflicts found in:"
    echo "$CONFLICTS"
    echo ""
    echo "To fix:"
    echo "  1. Open each file and look for <<<<<<<, =======, >>>>>>>"
    echo "  2. Choose which version to keep"
    echo "  3. Remove the conflict markers"
    echo "  4. Run: git add <file>"
    echo "  5. Run: git commit -m 'Fix: Resolved merge conflicts'"
    echo ""
    
    # Offer auto-resolution (keep current version)
    read -p "🤖 Auto-resolve by keeping current version? [y/N]: " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        for file in $CONFLICTS; do
            git checkout --ours "$file"
            git add "$file"
            echo "   ✓ Resolved: $file (kept current version)"
        done
        git commit -m "🤖 Auto-fix: Resolved merge conflicts"
        echo "✅ Merge conflicts auto-resolved!"
    fi
else
    echo "✅ No merge conflicts found"
fi

# Issue 2: Fix tsconfig.json syntax
echo ""
echo "2️⃣  Fixing tsconfig.json syntax error..."
TSCONFIG="modules/frontend/apps/web/diglit-quantum/tsconfig.json"

if [ -f "$TSCONFIG" ]; then
    echo "📝 Found: $TSCONFIG"
    echo ""
    echo "Checking line 28..."
    
    # Show line 28 and surrounding lines
    echo "════════════════════════════════════════"
    sed -n '25,31p' "$TSCONFIG" | nl -v 25
    echo "════════════════════════════════════════"
    echo ""
    
    # Common fixes
    echo "Common JSON errors to check:"
    echo "  ❌ Trailing comma: },  <-- Remove this comma if it's the last item"
    echo "  ❌ Missing comma: } { <-- Add comma between items"
    echo "  ❌ Comments: // comment <-- JSON doesn't support comments"
    echo "  ❌ Unclosed brackets: { without }"
    echo ""
    
    # Validate JSON
    if command -v python3 &> /dev/null; then
        echo "🔍 Validating JSON syntax..."
        python3 -c "import json, sys; json.load(open('$TSCONFIG'))" 2>&1 | head -5
        
        if [ $? -eq 0 ]; then
            echo "✅ JSON is now valid!"
        else
            echo ""
            echo "❌ JSON still has errors. Common fixes:"
            echo ""
            echo "Try this auto-fix:"
            
            # Backup
            cp "$TSCONFIG" "$TSCONFIG.backup"
            
            # Try to remove trailing commas
            python3 << 'EOF'
import json
import re

tsconfig_path = "modules/frontend/apps/web/diglit-quantum/tsconfig.json"

try:
    with open(tsconfig_path, 'r') as f:
        content = f.read()
    
    # Remove trailing commas
    content = re.sub(r',(\s*[}\]])', r'\1', content)
    
    # Try to parse
    json.loads(content)
    
    # If successful, save
    with open(tsconfig_path, 'w') as f:
        f.write(content)
    
    print("✅ Auto-fixed trailing commas!")
    
except Exception as e:
    print(f"❌ Could not auto-fix: {e}")
    print("Please manually edit the file")
EOF
        fi
    else
        echo "⚠️  Python3 not found - manual edit required"
        echo "   Run: nano $TSCONFIG"
    fi
else
    echo "❌ File not found: $TSCONFIG"
fi

# Final validation
echo ""
echo "3️⃣  Running final validation..."
echo "================================================"

# Check git status
if [ -z "$(git status --porcelain)" ]; then
    echo "✅ Git status: Clean"
else
    echo "⚠️  Git status: Uncommitted changes"
    git status --short
fi

# Check for errors
echo ""
echo "🔍 Checking for remaining issues..."

# Check merge conflicts
if git diff --name-only --diff-filter=U | grep -q .; then
    echo "❌ Merge conflicts still exist"
else
    echo "✅ No merge conflicts"
fi

# Validate JSON
if python3 -c "import json; json.load(open('$TSCONFIG'))" 2>/dev/null; then
    echo "✅ tsconfig.json is valid"
else
    echo "❌ tsconfig.json still has errors"
fi

echo ""
echo "================================================"
echo "🌌 Manual Fix Helper Complete"
echo ""
echo "Next steps:"
echo "  1. If all fixed: git add . && git commit -m 'Fix: Manual corrections'"
echo "  2. Run validation again: python fix-repo.py"
echo "================================================"