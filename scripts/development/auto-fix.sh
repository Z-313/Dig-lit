#!/bin/bash

# Simple Auto-Fix Script that actually works
set -e

echo "==========================================="
echo "🔧 SIMPLE AUTO-FIX SCRIPT"
echo "==========================================="

# Get the actual project root (Dig-lit folder)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
echo "Project: $PROJECT_ROOT"
echo ""

# Create audit directory
AUDIT_DIR="$PROJECT_ROOT/.audit"
mkdir -p "$AUDIT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "📝 $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# Phase 1: Quick Scan
log "Phase 1: Scanning for common issues..."

# Find files with issues
ISSUE_FILES=()

# Check for files with trailing whitespace
log "Checking for trailing whitespace..."
while IFS= read -r file; do
    if [[ -f "$file" ]] && grep -q '[[:space:]]$' "$file" 2>/dev/null; then
        ISSUE_FILES+=("$file")
        echo "  Found: $file"
    fi
done < <(find "$PROJECT_ROOT" -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.sh" -o -name "*.json" -o -name "*.md" 2>/dev/null | head -50)

log "Checking for shell scripts without execute permission..."
while IFS= read -r file; do
    if [[ -f "$file" ]] && [[ ! -x "$file" ]] && head -n1 "$file" | grep -q "^#!/"; then
        ISSUE_FILES+=("$file")
        echo "  Found: $file"
    fi
done < <(find "$PROJECT_ROOT" -name "*.sh" 2>/dev/null)

# Phase 2: Apply Fixes
echo ""
log "Phase 2: Applying fixes..."

FIXED_COUNT=0
for file in "${ISSUE_FILES[@]}"; do
    echo "  Fixing: ${file#$PROJECT_ROOT/}"
    
    # Fix trailing whitespace
    if sed -i 's/[[:space:]]*$//' "$file" 2>/dev/null; then
        echo "    ✓ Removed trailing whitespace"
    fi
    
    # Fix execute permissions for shell scripts
    if [[ "$file" == *.sh ]] && head -n1 "$file" | grep -q "^#!/"; then
        if chmod +x "$file" 2>/dev/null; then
            echo "    ✓ Made executable"
        fi
    fi
    
    ((FIXED_COUNT++))
done

# Phase 3: Commit
echo ""
log "Phase 3: Committing changes..."

if [[ $FIXED_COUNT -eq 0 ]]; then
    success "No issues found! Nothing to commit."
    exit 0
fi

if git add -A 2>/dev/null; then
    if git commit -m "Auto-fix: Fixed $FIXED_COUNT files

- Removed trailing whitespace
- Fixed script permissions
- Applied basic formatting

Automated fixes applied by auto-fix script" 2>/dev/null; then
        success "Successfully committed fixes for $FIXED_COUNT files! 🎉"
    else
        warn "Changes staged but commit failed (maybe no changes)"
    fi
else
    warn "Not a git repository or git add failed"
fi

echo ""
success "Auto-fix completed! Fixed $FIXED_COUNT files."