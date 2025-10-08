#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# FRONTEND-SPECIFIC FIXES
# ═══════════════════════════════════════════════════════════════════════════

set -e

PROJECT_ROOT="/workspaces/Dig-lit"
FRONTEND_DIR="${PROJECT_ROOT}/modules/frontend"

# Colors
C_RESET='\033[0m'
C_GREEN='\033[32m'
C_RED='\033[31m'
C_YELLOW='\033[33m'

log_success() { echo -e "${C_GREEN}✅ $1${C_RESET}"; }
log_error() { echo -e "${C_RED}❌ $1${C_RESET}"; }
log_warn() { echo -e "${C_YELLOW}⚠️  $1${C_RESET}"; }

cd "$PROJECT_ROOT"

echo -e "\n🎨 Fixing Frontend Issues...\n"

# Check if frontend directory exists
if [ ! -d "$FRONTEND_DIR" ]; then
    log_error "Frontend directory not found: $FRONTEND_DIR"
    exit 1
fi

# Fix package.json files in frontend
find "$FRONTEND_DIR" -name "package.json" -not -path "*/node_modules/*" | while read pkg; do
    log_info "Validating: $(basename $(dirname "$pkg"))/package.json"
    
    if jq empty "$pkg" 2>/dev/null; then
        # Ensure basic structure
        jq '. | {name, version, description, scripts, dependencies, devDependencies}' "$pkg" > "${pkg}.tmp" 2>/dev/null && mv "${pkg}.tmp" "$pkg" || true
    else
        log_warn "Invalid package.json: $pkg"
    fi
done

# Install dependencies in each package
find "$FRONTEND_DIR" -name "package.json" -not -path "*/node_modules/*" | while read pkg; do
    pkg_dir=$(dirname "$pkg")
    log_info "Installing dependencies in: $(basename "$pkg_dir")"
    
    cd "$pkg_dir"
    npm install --silent 2>/dev/null || true
    cd "$PROJECT_ROOT"
done

# Run TypeScript compiler to find issues
log_info "Checking TypeScript compilation..."
cd "$FRONTEND_DIR"
if npx tsc --noEmit 2>/dev/null; then
    log_success "TypeScript compilation successful"
else
    log_warn "TypeScript compilation issues found"
fi

# Run ESLint auto-fix
log_info "Running ESLint auto-fix..."
if npx eslint "**/*.{ts,tsx,js,jsx}" --fix --quiet 2>/dev/null; then
    log_success "ESLint fixes applied"
else
    log_warn "Some ESLint issues may remain"
fi

# Run Prettier
log_info "Formatting code with Prettier..."
if npx prettier --write "**/*.{ts,tsx,js,jsx,json,md}" --ignore-path .gitignore --loglevel error 2>/dev/null; then
    log_success "Prettier formatting applied"
else
    log_warn "Some files may not be formatted"
fi

cd "$PROJECT_ROOT"

log_success "Frontend fixes completed!"
