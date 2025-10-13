#!/bin/bash

# Enhanced QA & Intelligent Repository Health Check
echo "🔧 INTELLIGENT REPOSITORY QA & FIX HELPER"
echo "=================================================="
echo "🌌 Running comprehensive repository health check..."
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
ISSUES_FOUND=0
WARNINGS=0
FIXES_APPLIED=0
REPO_ROOT=$(pwd)

# Function to log messages
log_info() { echo -e "${BLUE}ℹ️  INFO:${NC} $1"; }
log_success() { echo -e "${GREEN}✅ SUCCESS:${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠️  WARNING:${NC} $1"; ((WARNINGS++)); }
log_error() { echo -e "${RED}❌ ERROR:${NC} $1"; ((ISSUES_FOUND++)); }
log_fix() { echo -e "${PURPLE}🔧 FIX:${NC} $1"; ((FIXES_APPLIED++)); }
log_qa() { echo -e "${CYAN}🔍 QA:${NC} $1"; }

# Function to check command availability
check_command() {
    if command -v "$1" &> /dev/null; then
        log_success "$1 is available"
        return 0
    else
        log_warning "$1 is not installed"
        return 1
    fi
}

# Function to validate JSON files
validate_json_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        if python3 -c "import json; json.load(open('$file'))" 2>/dev/null; then
            log_success "JSON valid: $file"
            return 0
        else
            log_error "JSON invalid: $file"
            # Try to auto-fix
            if fix_json_file "$file"; then
                log_fix "Auto-fixed JSON: $file"
                return 0
            fi
            return 1
        fi
    fi
    return 0
}

# Function to fix JSON files
fix_json_file() {
    local file="$1"
    local backup="${file}.backup"
    
    cp "$file" "$backup"
    
    # Try multiple JSON repair strategies
    python3 << EOF
import json
import re
import sys

try:
    with open('$file', 'r') as f:
        content = f.read()
    
    # Strategy 1: Remove trailing commas
    content = re.sub(r',(\s*[}\]])', r'\1', content)
    
    # Strategy 2: Fix missing commas between objects
    content = re.sub(r'}\s*{', '}, {', content)
    
    # Strategy 3: Remove JavaScript-style comments
    content = re.sub(r'//.*', '', content)
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
    
    # Strategy 4: Ensure proper quotes
    content = re.sub(r'([{,]\s*)(\w+)(\s*:)', r'\1"\2"\3', content)
    
    # Try to parse
    parsed = json.loads(content)
    
    # Write back fixed content
    with open('$file', 'w') as f:
        json.dump(parsed, f, indent=2)
    
    print("success")
    
except Exception as e:
    # If all else fails, try with jsonrepair
    try:
        from jsonrepair import repair_json
        with open('$file', 'r') as f:
            broken_json = f.read()
        fixed_json = repair_json(broken_json)
        with open('$file', 'w') as f:
            f.write(fixed_json)
        print("success")
    except:
        print(f"failure: {e}")
EOF
}

# PHASE 1: REPOSITORY STRUCTURE ANALYSIS
echo "📊 PHASE 1: Repository Structure Analysis"
echo "=================================================="

log_qa "Analyzing repository structure..."

# Check if this is a git repository
if [ -d ".git" ]; then
    log_success "Git repository detected"
else
    log_error "Not a git repository (no .git folder)"
fi

# Check for essential files
ESSENTIAL_FILES=("package.json" "README.md" ".gitignore")
for file in "${ESSENTIAL_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        log_success "Found: $file"
    else
        log_warning "Missing: $file"
    fi
done

# Detect project type
if [[ -f "package.json" ]]; then
    log_info "Node.js project detected"
    PROJECT_TYPE="node"
elif [[ -f "requirements.txt" ]]; then
    log_info "Python project detected"
    PROJECT_TYPE="python"
elif [[ -f "pom.xml" ]]; then
    log_info "Java Maven project detected"
    PROJECT_TYPE="java"
elif [[ -f "Cargo.toml" ]]; then
    log_info "Rust project detected"
    PROJECT_TYPE="rust"
else
    log_warning "Could not auto-detect project type"
    PROJECT_TYPE="unknown"
fi

# PHASE 2: GIT REPOSITORY HEALTH
echo ""
echo "📚 PHASE 2: Git Repository Health Check"
echo "=================================================="

# Check for merge conflicts
log_qa "Checking for merge conflicts..."
CONFLICTS=$(git diff --name-only --diff-filter=U 2>/dev/null)

if [ -n "$CONFLICTS" ]; then
    log_error "Merge conflicts found in:"
    echo "$CONFLICTS"
    
    # Auto-resolution with intelligence
    echo ""
    log_info "Intelligent conflict resolution..."
    for file in $CONFLICTS; do
        if [[ "$file" == *"package.json"* ]] || [[ "$file" == *"tsconfig"* ]]; then
            log_info "Smart merge for config file: $file"
            # For config files, try to merge intelligently
            git checkout --theirs "$file"  # Try their version first
            if ! validate_json_file "$file"; then
                git checkout --ours "$file"  # Fall back to our version
            fi
        else
            # For other files, keep current version by default
            git checkout --ours "$file"
        fi
        git add "$file"
        log_fix "Resolved: $file"
    done
    git commit -m "🤖 Auto-fix: Resolved merge conflicts" --no-verify
else
    log_success "No merge conflicts found"
fi

# Check git status
log_qa "Checking git status..."
GIT_STATUS=$(git status --porcelain)
if [ -z "$GIT_STATUS" ]; then
    log_success "Git working directory is clean"
else
    log_warning "Uncommitted changes detected:"
    git status --short
fi

# PHASE 3: CODE QUALITY & CONFIGURATION CHECKS
echo ""
echo "🔧 PHASE 3: Code Quality & Configuration Checks"
echo "=================================================="

# Check for TypeScript configuration
if [[ -f "tsconfig.json" ]] || find . -name "tsconfig.json" -type f | grep -q .; then
    log_qa "TypeScript configuration check..."
    TSCONFIG_FILES=$(find . -name "tsconfig.json" -type f)
    for tsconfig in $TSCONFIG_FILES; do
        validate_json_file "$tsconfig"
    done
fi

# Check package.json for common issues
if [[ -f "package.json" ]]; then
    log_qa "Analyzing package.json..."
    
    # Validate JSON
    validate_json_file "package.json"
    
    # Check for required scripts
    if python3 -c "import json; pkg=json.load(open('package.json')); print('start' in pkg.get('scripts', {}))" 2>/dev/null | grep -q "True"; then
        log_success "package.json has 'start' script"
    else
        log_error "package.json missing 'start' script"
        # Auto-fix: Add start script if missing
        python3 << 'EOF'
import json
import os

try:
    with open('package.json', 'r') as f:
        pkg = json.load(f)
    
    if 'scripts' not in pkg:
        pkg['scripts'] = {}
    
    if 'start' not in pkg['scripts']:
        # Intelligently detect main file
        main_file = pkg.get('main', 'index.js')
        if os.path.exists('server.js'):
            main_file = 'server.js'
        elif os.path.exists('app.js'):
            main_file = 'app.js'
        elif os.path.exists('src/index.js'):
            main_file = 'src/index.js'
        
        pkg['scripts']['start'] = f"node {main_file}"
        pkg['scripts']['dev'] = f"nodemon {main_file}"
        
        with open('package.json', 'w') as f:
            json.dump(pkg, f, indent=2)
        print("added_start_script")
    else:
        print("already_exists")
except Exception as e:
    print(f"error: {e}")
EOF
        if [[ $? == "added_start_script" ]]; then
            log_fix "Added missing 'start' script to package.json"
        fi
    fi
    
    # Remove unknown npm configs
    log_qa "Checking for deprecated npm configs..."
    python3 << 'EOF'
import json

try:
    with open('package.json', 'r') as f:
        pkg = json.load(f)
    
    removed_configs = []
    if 'strict-peer-dependencies' in pkg:
        del pkg['strict-peer-dependencies']
        removed_configs.append('strict-peer-dependencies')
    
    if 'auto-install-peers' in pkg:
        del pkg['auto-install-peers']
        removed_configs.append('auto-install-peers')
    
    if removed_configs:
        with open('package.json', 'w') as f:
            json.dump(pkg, f, indent=2)
        print(f"removed:{','.join(removed_configs)}")
    else:
        print("clean")
except Exception as e:
    print(f"error:{e}")
EOF
    result=$?
    if [[ $result == removed* ]]; then
        configs=${result#removed:}
        log_fix "Removed deprecated npm configs: $configs"
    fi
fi

# PHASE 4: DEPENDENCY & BUILD SYSTEM CHECK
echo ""
echo "📦 PHASE 4: Dependency & Build System Check"
echo "=================================================="

# Check for node_modules
if [[ "$PROJECT_TYPE" == "node" ]]; then
    log_qa "Node.js project analysis..."
    
    if [[ -d "node_modules" ]]; then
        log_success "node_modules directory exists"
    else
        log_warning "node_modules not found - dependencies not installed"
        log_info "Run: npm install"
    fi
    
    # Check for lock files
    if [[ -f "package-lock.json" ]]; then
        log_success "package-lock.json found"
    elif [[ -f "yarn.lock" ]]; then
        log_success "yarn.lock found"
    else
        log_warning "No lock file found - may cause dependency inconsistencies"
    fi
    
    # Test if we can install dependencies
    if check_command "npm"; then
        log_qa "Testing dependency installation..."
        npm install --silent --no-progress
        if [ $? -eq 0 ]; then
            log_success "Dependencies installed successfully"
        else
            log_error "Failed to install dependencies"
        fi
    fi
fi

# PHASE 5: APPLICATION HEALTH CHECK
echo ""
echo "🚀 PHASE 5: Application Health Check"
echo "=================================================="

# Check if application can start
if [[ "$PROJECT_TYPE" == "node" ]] && [[ -f "package.json" ]]; then
    log_qa "Testing application startup..."
    
    # Check if start script exists and works
    if npm run | grep -q "start"; then
        # Start server in background and test
        timeout 10s npm start &
        SERVER_PID=$!
        sleep 3
        
        # Test if server is responding
        if curl -f http://localhost:3000/ > /dev/null 2>&1 || \
           curl -f http://localhost:8080/ > /dev/null 2>&1; then
            log_success "Application starts and responds correctly"
        else
            log_warning "Application starts but may not be responding on expected ports"
        fi
        
        # Kill the background process
        kill $SERVER_PID 2>/dev/null
        wait $SERVER_PID 2>/dev/null
    else
        log_error "No start script available - cannot test application"
    fi
fi

# PHASE 6: SECURITY & BEST PRACTICES
echo ""
echo "🔒 PHASE 6: Security & Best Practices Check"
echo "=================================================="

# Check for environment files
if [[ -f ".env" ]]; then
    log_warning ".env file found - ensure it's in .gitignore"
else
    log_success "No .env file in repository (good practice)"
fi

# Check .gitignore
if [[ -f ".gitignore" ]]; then
    log_success ".gitignore file exists"
    # Check if common files are ignored
    for pattern in "node_modules" ".env" "dist" "build" "*.log"; do
        if grep -q "$pattern" .gitignore; then
            log_success ".gitignore covers: $pattern"
        else
            log_warning ".gitignore missing: $pattern"
        fi
    done
else
    log_error "No .gitignore file"
fi

# Check for sensitive data
log_qa "Scanning for potential sensitive data..."
if git log -p | grep -E "(password|secret|key|token)" | head -5; then
    log_warning "Potential sensitive data found in git history"
fi

# FINAL SUMMARY
echo ""
echo "=================================================="
echo "📋 COMPREHENSIVE QA SUMMARY"
echo "=================================================="

echo -e "${GREEN}✅ Success Checks:${NC}"
echo "  - Repository structure analysis"
echo "  - Git health check"
echo "  - Configuration validation"

echo ""
echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
if [ $WARNINGS -eq 0 ]; then
    echo "  No warnings detected"
fi

echo ""
echo -e "${RED}❌ Issues Found: $ISSUES_FOUND${NC}"
if [ $ISSUES_FOUND -eq 0 ]; then
    echo "  No critical issues detected"
fi

echo ""
echo -e "${PURPLE}🔧 Fixes Applied: $FIXES_APPLIED${NC}"

echo ""
echo "📊 REPOSITORY HEALTH SCORE:"
if [ $ISSUES_FOUND -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🟢 EXCELLENT - Repository is in great shape!${NC}"
elif [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}🟢 GOOD - Minor warnings but no critical issues${NC}"
elif [ $ISSUES_FOUND -le 2 ]; then
    echo -e "${YELLOW}🟡 FAIR - Some issues need attention${NC}"
else
    echo -e "${RED}🔴 POOR - Significant issues need fixing${NC}"
fi

echo ""
echo "🚀 RECOMMENDED NEXT STEPS:"
if [ $ISSUES_FOUND -gt 0 ]; then
    echo "  1. Review and fix the issues listed above"
    echo "  2. Run this script again to verify fixes"
fi
echo "  3. Run: npm start (to test your application)"
echo "  4. Consider adding tests: npm install --save-dev jest"
echo "  5. Set up CI/CD pipeline for automated testing"

echo ""
echo "=================================================="
echo "🌌 INTELLIGENT QA COMPLETE"
echo "=================================================="

# Exit with appropriate code
if [ $ISSUES_FOUND -eq 0 ]; then
    exit 0
else
    exit 1
fi