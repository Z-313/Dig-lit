#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# DIRECTORY STRUCTURE OPTIMIZER
# ═══════════════════════════════════════════════════════════════════════════
# Intelligently manages project structure: removes empty dirs, creates needed ones
# ═══════════════════════════════════════════════════════════════════════════

set -e

PROJECT_ROOT="/workspaces/Dig-lit"

# Colors
C_RESET='\033[0m'
C_GREEN='\033[32m'
C_RED='\033[31m'
C_YELLOW='\033[33m'
C_CYAN='\033[36m'
C_BLUE='\033[34m'

log_success() { echo -e "${C_GREEN}✅ $1${C_RESET}"; }
log_error() { echo -e "${C_RED}❌ $1${C_RESET}"; }
log_warn() { echo -e "${C_YELLOW}⚠️  $1${C_RESET}"; }
log_info() { echo -e "${C_CYAN}ℹ️  $1${C_RESET}"; }
log_debug() { echo -e "${C_BLUE}🔍 $1${C_RESET}"; }

cd "$PROJECT_ROOT"

echo -e "\n🏗️  Optimizing Project Structure...\n"

# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURATION - Define what should exist and what should be removed
# ═══════════════════════════════════════════════════════════════════════════

# Directories that SHOULD exist (will be created if missing)
REQUIRED_DIRS=(
    "modules/frontend/apps/web/diglit-web/src"
    "modules/frontend/apps/web/diglit-web/public"
    "modules/frontend/apps/web/diglit-web/components"
    "modules/frontend/apps/web/diglit-web/hooks"
    "modules/frontend/apps/web/diglit-web/pages"
    "modules/frontend/apps/web/diglit-quantum/app"
    "modules/frontend/apps/web/diglit-quantum/components"
    "modules/frontend/apps/web/diglit-quantum/hooks"
    "modules/frontend/apps/admin/src"
    "modules/frontend/apps/admin/components"
    "modules/frontend/packages/api-client/src"
    "modules/frontend/packages/design-system/src"
    "modules/frontend/packages/design-system/components"
    "modules/frontend/packages/ui/src"
    "modules/frontend/packages/ui/components"
    "modules/backend/apps/api"
    "modules/backend/packages/database"
    "modules/backend/packages/auth"
    "modules/ai-engine/core"
    "modules/ai-engine/models/audio"
    "modules/ai-engine/models/llm"
    "modules/ai-engine/models/vision"
    "modules/ai-engine/inference"
    "modules/visual_engine/effects"
    "modules/visual_engine/generators"
    "modules/business_intelligence/analytics"
    "modules/business_intelligence/data_pipeline"
    "modules/business_intelligence/reporting"
    "scripts/development"
    "scripts/deployment"
    "scripts/qa"
    ".claude/context/patches"
    ".claude/audit"
    ".husky"
)

# Directories that should be REMOVED if empty (potential duplicates or unused)
POTENTIAL_EMPTY_DIRS=(
    "modules/ai_engine"  # Duplicate of ai-engine
    "modules/automation" # Not defined in structure
    "modules/frontend/apps/web/diglit-web" # If it's a submodule or empty
    "modules/visual_engine" # If empty
    "modules/business_intelligence" # If empty
)

# Files that SHOULD exist in specific directories
REQUIRED_FILES=(
    "modules/frontend/apps/web/diglit-web/package.json"
    "modules/frontend/apps/web/diglit-quantum/package.json"
    "modules/frontend/apps/admin/package.json"
    "modules/frontend/packages/api-client/package.json"
    "modules/frontend/packages/design-system/package.json"
    "modules/frontend/packages/ui/package.json"
    "modules/backend/requirements.txt"
    "modules/ai-engine/requirements.txt"
    "modules/visual_engine/requirements.txt"
    "modules/business_intelligence/requirements.txt"
    "package.json"
    "tsconfig.json"
    "docker-compose.yml"
    "docker-compose.dev.yml"
    ".gitignore"
    ".eslintrc.cjs"
    ".prettierrc"
    "README.md"
)

# ═══════════════════════════════════════════════════════════════════════════
# ANALYSIS FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

analyze_directory() {
    local dir="$1"
    local depth="${2:-0}"
    local indent=$(printf '%*s' $((depth * 2)) "")
    
    if [ ! -d "$dir" ]; then
        echo "${indent}📁 $dir - ${C_RED}MISSING${C_RESET}"
        return 1
    fi
    
    local file_count=$(find "$dir" -maxdepth 1 -type f | wc -l)
    local dir_count=$(find "$dir" -maxdepth 1 -type d | tail -n +2 | wc -l)
    local total_size=$(du -s "$dir" 2>/dev/null | cut -f1 || echo "0")
    
    if [ "$file_count" -eq 0 ] && [ "$dir_count" -eq 0 ]; then
        echo "${indent}📁 $dir - ${C_YELLOW}EMPTY${C_RESET}"
        return 2
    elif [ "$file_count" -eq 0 ] && [ "$dir_count" -gt 0 ]; then
        echo "${indent}📁 $dir - ${C_CYAN}ONLY SUBDIRS${C_RESET} ($dir_count subdirs)"
        return 3
    else
        echo "${indent}📁 $dir - ${C_GREEN}ACTIVE${C_RESET} ($file_count files, $dir_count subdirs, ${total_size}KB)"
        return 0
    fi
}

is_directory_empty() {
    local dir="$1"
    [ ! -d "$dir" ] && return 1
    [ -z "$(find "$dir" -mindepth 1 -maxdepth 1)" ] && return 0
    return 1
}

should_remove_directory() {
    local dir="$1"
    
    # Never remove these critical directories
    case "$dir" in
        "."|".."|"/"|"$PROJECT_ROOT"|"modules"|"scripts"|".claude"|".git"|".husky")
            return 1
            ;;
    esac
    
    # Check if directory is empty
    if is_directory_empty "$dir"; then
        # Check if it's in our potential empty list
        for potential_dir in "${POTENTIAL_EMPTY_DIRS[@]}"; do
            if [ "$dir" = "$potential_dir" ]; then
                return 0
            fi
        done
        
        # Check if it's a node_modules or cache directory
        if [[ "$dir" =~ node_modules|__pycache__|\.next|dist|build|\.turbo ]]; then
            return 0
        fi
    fi
    
    return 1
}

# ═══════════════════════════════════════════════════════════════════════════
# CLEANUP FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

create_required_directories() {
    log_section "Creating Required Directories"
    local created_count=0
    
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ ! -d "$dir" ]; then
            log_info "Creating: $dir"
            mkdir -p "$dir"
            ((created_count++))
        fi
    done
    
    log_success "Created $created_count required directories"
}

create_required_files() {
    log_section "Creating Required Files"
    local created_count=0
    
    for file in "${REQUIRED_FILES[@]}"; do
        local dir=$(dirname "$file")
        local filename=$(basename "$file")
        
        # Create directory if needed
        mkdir -p "$dir"
        
        # Create file if it doesn't exist
        if [ ! -f "$file" ]; then
            case "$filename" in
                "package.json")
                    create_minimal_package_json "$file" "$dir"
                    ;;
                "requirements.txt")
                    create_minimal_requirements_txt "$file" "$dir"
                    ;;
                *)
                    touch "$file"
                    ;;
            esac
            log_info "Created: $file"
            ((created_count++))
        fi
    done
    
    log_success "Created $created_count required files"
}

create_minimal_package_json() {
    local file="$1"
    local dir="$2"
    local name=$(basename "$dir")
    
    # Determine package type based on directory structure
    if [[ "$dir" =~ "apps" ]]; then
        local type="application"
    elif [[ "$dir" =~ "packages" ]]; then
        local type="package"
    else
        local type="library"
    fi
    
    cat > "$file" <<EOF
{
  "name": "@diglit/${name}",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "echo 'Add dev script'",
    "build": "echo 'Add build script'",
    "lint": "echo 'Add lint script'"
  },
  "dependencies": {},
  "devDependencies": {}
}