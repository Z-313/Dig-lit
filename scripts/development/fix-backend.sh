#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# BACKEND-SPECIFIC FIXES
# ═══════════════════════════════════════════════════════════════════════════

set -e

PROJECT_ROOT="/workspaces/Dig-lit"
BACKEND_DIR="${PROJECT_ROOT}/modules/backend"

# Colors
C_RESET='\033[0m'
C_GREEN='\033[32m'
C_RED='\033[31m'
C_YELLOW='\033[33m'

log_success() { echo -e "${C_GREEN}✅ $1${C_RESET}"; }
log_error() { echo -e "${C_RED}❌ $1${C_RESET}"; }
log_warn() { echo -e "${C_YELLOW}⚠️  $1${C_RESET}"; }

cd "$PROJECT_ROOT"

echo -e "\n🐍 Fixing Backend Issues...\n"

# Check if backend directory exists
if [ ! -d "$BACKEND_DIR" ]; then
    log_error "Backend directory not found: $BACKEND_DIR"
    exit 1
fi

# Install Python dependencies
if [ -f "${BACKEND_DIR}/requirements.txt" ]; then
    log_info "Installing Python dependencies..."
    cd "$BACKEND_DIR"
    pip install -r requirements.txt --quiet 2>/dev/null || true
    cd "$PROJECT_ROOT"
fi

# Check Python syntax
log_info "Checking Python syntax..."
find "$BACKEND_DIR" -name "*.py" -not -path "*/__pycache__/*" | while read pyfile; do
    if python -m py_compile "$pyfile" 2>/dev/null; then
        :
    else
        log_warn "Syntax error in: $pyfile"
    fi
done

# Format Python code with Black (if available)
if command -v black &> /dev/null; then
    log_info "Formatting Python with Black..."
    find "$BACKEND_DIR" -name "*.py" -not -path "*/__pycache__/*" -exec black --quiet {} + 2>/dev/null || true
    log_success "Black formatting applied"
else
    log_warn "Black not installed. Run: pip install black"
fi

# Sort imports with isort (if available)
if command -v isort &> /dev/null; then
    log_info "Sorting imports with isort..."
    find "$BACKEND_DIR" -name "*.py" -not -path "*/__pycache__/*" -exec isort --quiet {} + 2>/dev/null || true
    log_success "Import sorting applied"
else
    log_warn "isort not installed. Run: pip install isort"
fi

# Check for common Python issues
log_info "Checking for common Python issues..."
find "$BACKEND_DIR" -name "*.py" -not -path "*/__pycache__/*" | while read pyfile; do
    # Check for debug prints in non-test files
    if [[ ! "$pyfile" =~ test|debug ]] && grep -q "print(" "$pyfile"; then
        log_warn "Debug print in: $pyfile"
    fi
    
    # Check for missing imports
    if grep -q "^from \|^import " "$pyfile"; then
        # Basic import validation (simplified)
        if grep -q "ImportError" "$pyfile"; then
            log_warn "Potential import issue in: $pyfile"
        fi
    fi
done

log_success "Backend fixes completed!"
