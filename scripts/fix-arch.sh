#!/usr/bin/env bash
# fix-arch.sh - Automated remediation orchestrator for audit-report.sh findings
#
# This script bootstraps the local environment, re-runs the audit, applies
# automated fixes, validates the project, and exports summary metrics.
# It is intended to be idempotent and resilient so that repeated executions
# can iteratively drive the repository toward compliance with best practices.

set -Eeuo pipefail
trap 'handle_error $? $LINENO' ERR

VERSION="3.0.1-ultimate"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
START_TIME=$(date +%s)

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
ARTIFACTS="${ROOT_DIR}/.quantum"
LOGS="${ARTIFACTS}/logs"
AUDIT="${ARTIFACTS}/audit"
GRAPHS="${ARTIFACTS}/graphs"
METRICS="${ARTIFACTS}/metrics"
BACKUPS="${ARTIFACTS}/backups"
CACHE="${ARTIFACTS}/cache"

APPLY=${APPLY:-0}
AUTO_YES=${AUTO_YES:-0}
SKIP_BACKUP=${SKIP_BACKUP:-0}
VERBOSE=${VERBOSE:-0}
MAX_PARALLEL=${MAX_PARALLEL:-4}
DRY_RUN=$((1 - APPLY))

R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' B='\033[0;34m'
M='\033[0;35m' C='\033[0;36m' BOLD='\033[1m' DIM='\033[2m' RESET='\033[0m'

ts() { date +%s; }
ts_iso() { date -Iseconds; }
fmt_duration() {
  local s=$1 h=$((s/3600)) m=$(((s%3600)/60)) sec=$((s%60))
  if (( h > 0 )); then
    printf "%dh %02dm %02ds" "$h" "$m" "$sec"
  elif (( m > 0 )); then
    printf "%dm %02ds" "$m" "$sec"
  else
    printf "%ds" "$sec"
  fi
}
log()     { printf "${DIM}[%s]${RESET} %s\n" "$(date +%H:%M:%S)" "$*"; }
info()    { printf "${C}ℹ${RESET} %s\n" "$*"; }
success() { printf "${G}✓${RESET} %s\n" "$*"; }
warn()    { printf "${Y}⚠${RESET} %s\n" "$*" >&2; }
error()   { printf "${R}✗${RESET} %s\n" "$*" >&2; }
fatal()   { error "$*"; exit 1; }

handle_error() {
  local code=$1 line=$2
  error "Fatal error at line $line (exit code: $code)"
  [[ $SKIP_BACKUP -eq 0 ]] && rollback_if_exists
  cleanup
  exit "$code"
}

cleanup() {
  log "Cleaning up temporary files..."
  rm -rf "${CACHE:?}"/*.tmp 2>/dev/null || true
}

ensure_root_cwd() {
  [[ "$(pwd)" != "$ROOT_DIR" ]] && cd "$ROOT_DIR"
}

# ---------------------- Bootstrap ----------------------
INSTALLED_TOOLS=()
install_if_missing() {
  local tool=$1 install_cmd=$2 check_cmd=${3:-"command -v $tool"}
  if eval "$check_cmd" >/dev/null 2>&1; then
    return 0
  fi
  info "Installing $tool..."
  if [[ $AUTO_YES -eq 0 ]]; then
    read -rp "Install $tool? [Y/n] " r
    if [[ ${r,,} =~ ^n ]]; then
      warn "Skipping $tool"
      return 0
    fi
  fi
  if ! eval "$install_cmd"; then
    warn "Failed to install $tool (continuing)"
    return 0
  fi
  INSTALLED_TOOLS+=("$tool")
  success "$tool installed"
}

bootstrap_environment() {
  ensure_root_cwd
  log "Bootstrapping environment..."
  mkdir -p "$LOGS" "$AUDIT" "$GRAPHS" "$METRICS" "$BACKUPS" "$CACHE"

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PKG_UPDATE="sudo apt-get update && "
    PKG_INSTALL="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y"
    [[ -f /etc/redhat-release ]] && { PKG_UPDATE=""; PKG_INSTALL="sudo yum install -y"; }
    [[ -f /etc/arch-release  ]] && { PKG_UPDATE=""; PKG_INSTALL="sudo pacman -S --noconfirm"; }
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    PKG_UPDATE=""
    PKG_INSTALL="brew install"
    command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    warn "Unsupported OS: $OSTYPE"
    PKG_UPDATE=""
    PKG_INSTALL="echo 'Cannot auto-install on this OS:'"
  fi

  install_if_missing "curl" "${PKG_UPDATE}${PKG_INSTALL} curl"
  install_if_missing "git"  "${PKG_UPDATE}${PKG_INSTALL} git"
  install_if_missing "jq"   "${PKG_UPDATE}${PKG_INSTALL} jq"
  install_if_missing "bc"   "${PKG_UPDATE}${PKG_INSTALL} bc"

  if ! command -v node >/dev/null 2>&1; then
    info "Installing Node.js..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
      sudo apt-get install -y nodejs
    else
      brew install node
    fi
    INSTALLED_TOOLS+=("node" "npm" "npx")
  fi

  if npm -v >/dev/null 2>&1; then
    npm install -g --silent eslint prettier typescript madge license-checker depcheck sort-package-json >/dev/null 2>&1 || true
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 -m pip install --user --upgrade pip   >/dev/null 2>&1 || true
    python3 -m pip install --user --quiet ruff black isort bandit pip-audit >/dev/null 2>&1 || true
  fi

  install_if_missing "parallel" "${PKG_INSTALL} parallel" || true
  install_if_missing "graphviz" "${PKG_INSTALL} graphviz" || true

  if ! command -v gitleaks >/dev/null 2>&1; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      brew install gitleaks || true
    else
      curl -sSL https://github.com/gitleaks/gitleaks/releases/download/v8.18.2/gitleaks_8.18.2_linux_x64.tar.gz \
        | tar xz -C /tmp
      sudo mv /tmp/gitleaks /usr/local/bin/ 2>/dev/null || true
    fi
  fi

  success "Environment ready (installed: ${INSTALLED_TOOLS[*]:-none})"
}

# ---------------------- Progress ----------------------
declare -A PHASE_TIMINGS
draw_progress() {
  local current=$1 total=$2 label=$3 eta=${4:--1}
  local width=60 perc=$(( total == 0 ? 100 : current * 100 / total ))
  local filled=$(( perc * width / 100 ))
  local empty=$(( width - filled ))
  local color=$C
  (( perc >= 100 )) && color=$G
  (( perc < 30 )) && color=$R
  (( perc >= 30 && perc < 70 )) && color=$Y
  printf "\r${color}▐"
  printf "█%.0s" $(seq 1 $filled)
  printf "░%.0s" $(seq 1 $empty)
  printf "▌${RESET} ${BOLD}%3d%%%${RESET} ${DIM}(%d/%d)${RESET} %s" "$perc" "$current" "$total" "$label"
  if [[ $eta -gt 0 ]]; then
    printf " ${DIM}│ ETA: %s${RESET}" "$(fmt_duration $eta)"
  fi
  (( current == total )) && echo ""
}

track_phase_timing() {
  PHASE_TIMINGS[$1]=$2
}

estimate_remaining() {
  local completed=$1 total=$2 avg=${3:-5}
  echo $(( (total - completed) * avg ))
}

# ---------------------- Backup/Rollback ----------------------
BACKUP_ID=""
create_backup() {
  [[ $SKIP_BACKUP -eq 1 ]] && return 0
  ensure_root_cwd
  BACKUP_ID="quantum-backup-$(date +%Y%m%d_%H%M%S)"
  info "Creating safety backup: $BACKUP_ID"
  if git rev-parse --git-dir >/dev/null 2>&1; then
    git stash push -u -m "$BACKUP_ID" >/dev/null 2>&1 || true
    echo "$BACKUP_ID" > "$BACKUPS/.last_stash"
  fi
  tar -czf "$BACKUPS/${BACKUP_ID}.tar.gz" \
    --exclude='node_modules' --exclude='.git' --exclude='.quantum' \
    --exclude='*.log' --exclude='venv' --exclude='__pycache__' . 2>/dev/null || \
    warn "Tar backup failed (git stash still active)"
  success "Backup created: $BACKUP_ID"
}

rollback_if_exists() {
  [[ -z "$BACKUP_ID" ]] && return 0
  warn "ROLLBACK INITIATED: Restoring $BACKUP_ID"
  if git rev-parse --git-dir >/dev/null 2>&1; then
    local s=$(git stash list | grep "$BACKUP_ID" | head -1 | cut -d: -f1)
    [[ -n "$s" ]] && git stash pop "$s" >/dev/null 2>&1
  else
    [[ -f "$BACKUPS/${BACKUP_ID}.tar.gz" ]] && tar -xzf "$BACKUPS/${BACKUP_ID}.tar.gz" -C "$ROOT_DIR" 2>/dev/null
  fi
  success "Rollback complete"
}

# ---------------------- Detection ----------------------
detect_stack() {
  ensure_root_cwd
  jq -n \
    --arg has_node "$([[ -f package.json ]] && echo 1 || echo 0)" \
    --arg has_ts "$([[ -f tsconfig.json ]] && echo 1 || echo 0)" \
    --arg has_py "$([[ -f requirements.txt || -f pyproject.toml ]] && echo 1 || echo 0)" \
    --arg has_go "$([[ -f go.mod ]] && echo 1 || echo 0)" \
    --arg has_rust "$([[ -f Cargo.toml ]] && echo 1 || echo 0)" \
    --arg has_web "$(ls *.html 2>/dev/null | wc -l)" \
    '{ node:($has_node=="1"), typescript:($has_ts=="1"), python:($has_py=="1"), go:($has_go=="1"), rust:($has_rust=="1"), web:(($has_web|tonumber)>0) }'
}

# ---------------------- Exec helper ----------------------
run_sequential() {
  local phase=$1 label=$2 cmd=$3 modifies=${4:-0}
  local logfile="$LOGS/${phase,,}.log"
  ensure_root_cwd
  if [[ $modifies -eq 1 && $DRY_RUN -eq 1 ]]; then
    echo "[DRY-RUN] $cmd" | tee -a "$logfile"
    return 0
  fi
  if [[ $VERBOSE -eq 1 ]]; then
    eval "$cmd" 2>&1 | tee -a "$logfile"
  else
    eval "$cmd" >>"$logfile" 2>&1
  fi
}

# ---------------------- Phase 1: Audit ----------------------
phase_audit() {
  ensure_root_cwd
  local phase_start=$(ts)
  echo -e "\n${M}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${M}${BOLD}║${RESET}  🔍  ${BOLD}PHASE 1: QUANTUM AUDIT${RESET}"
  echo -e "${M}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}\n"

  local stack=$(detect_stack)
  local has_node=$(jq -r '.node' <<<"$stack")
  local has_ts=$(jq -r '.typescript' <<<"$stack")
  local has_py=$(jq -r '.python' <<<"$stack")

  local tasks=()

  if [[ $has_node == "true" ]]; then
    [[ ! -d node_modules ]] && npm ci --silent 2>/dev/null || npm install --silent 2>/dev/null || true
    if [[ $has_ts == "true" || $(git ls-files '*.ts' '*.tsx' 2>/dev/null | wc -l) -gt 0 ]]; then
      tasks+=("npx tsc --noEmit --pretty false > \"$AUDIT/typescript.log\" 2>&1 || true")
    else
      : > "$AUDIT/typescript.log"
    fi
    tasks+=(
      "npx eslint . --ext .ts,.tsx,.js,.jsx -f json -o \"$AUDIT/eslint.json\" --no-error-on-unmatched-pattern 2>/dev/null || true"
      "npm audit --json > \"$AUDIT/npm-audit.json\" 2>&1 || true"
      "npx madge --circular --extensions ts,tsx,js,jsx . > \"$AUDIT/circular-deps.txt\" 2>&1 || true"
      "npx depcheck --json > \"$AUDIT/unused-deps.json\" 2>&1 || true"
      "npx license-checker --json --out \"$AUDIT/licenses.json\" 2>/dev/null || true"
    )
  else
    echo "[]" > "$AUDIT/eslint.json"
    echo "{}" > "$AUDIT/npm-audit.json"
    : > "$AUDIT/circular-deps.txt"
    echo "{}" > "$AUDIT/licenses.json"
    echo "{}" > "$AUDIT/unused-deps.json"
    : > "$AUDIT/typescript.log"
  fi

  if [[ $has_py == "true" ]]; then
    tasks+=(
      "ruff check . --output-format json > \"$AUDIT/ruff.json\" 2>/dev/null || echo '[]' > \"$AUDIT/ruff.json\""
      "bandit -r . -f json -o \"$AUDIT/bandit.json\" 2>/dev/null || echo '[]' > \"$AUDIT/bandit.json\""
      "[[ -f requirements.txt ]] && pip-audit -r requirements.txt -f json -o \"$AUDIT/pip-audit.json\" 2>/dev/null || echo '{}' > \"$AUDIT/pip-audit.json\""
    )
  else
    echo "[]" > "$AUDIT/ruff.json"
    echo "[]" > "$AUDIT/bandit.json"
    echo "{}" > "$AUDIT/pip-audit.json"
  fi

  tasks+=("command -v gitleaks >/dev/null && gitleaks detect --no-git --report-path \"$AUDIT/secrets.json\" 2>/dev/null || echo '[]' > \"$AUDIT/secrets.json\"")

  local total=${#tasks[@]}
  for i in "${!tasks[@]}"; do
    draw_progress $(( i + 1 )) "$total" "Auditing..." "$(estimate_remaining $(( i + 1 )) $total 3)"
    run_sequential "audit" "Task $(( i + 1 ))" "${tasks[$i]}" 0
  done

  local phase_end=$(ts)
  track_phase_timing "audit" $(( phase_end - phase_start ))
  success "Audit complete in $(fmt_duration $(( phase_end - phase_start )))"
}

# ---------------------- Phase 2: Analysis ----------------------
phase_analysis() {
  ensure_root_cwd
  local phase_start=$(ts)
  echo -e "\n${M}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${M}${BOLD}║${RESET}  🧠  ${BOLD}PHASE 2: INTELLIGENT ANALYSIS${RESET}"
  echo -e "${M}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}\n"

  local ts_errors=$(grep -c "error TS" "$AUDIT/typescript.log" 2>/dev/null || echo 0)
  local eslint_errors=$(jq '[.[]|.errorCount]|add//0' "$AUDIT/eslint.json" 2>/dev/null || echo 0)
  local eslint_warnings=$(jq '[.[]|.warningCount]|add//0' "$AUDIT/eslint.json" 2>/dev/null || echo 0)
  local secrets=$(jq 'length' "$AUDIT/secrets.json" 2>/dev/null || echo 0)
  local npm_vulns=$(jq '.metadata.vulnerabilities.total//0' "$AUDIT/npm-audit.json" 2>/dev/null || echo 0)
  local circular_deps=$(grep -c "Circular" "$AUDIT/circular-deps.txt" 2>/dev/null || echo 0)

  jq -n --arg ts "$ts_errors" --arg eslint_e "$eslint_errors" --arg eslint_w "$eslint_warnings" \
        --arg secrets "$secrets" --arg vulns "$npm_vulns" --arg circular "$circular_deps" --arg timestamp "$(ts_iso)" \
      '{
        timestamp: $timestamp,
        critical: {
          typescript_errors: ($ts|tonumber),
          secrets_found: ($secrets|tonumber),
          npm_vulnerabilities: ($vulns|tonumber),
          circular_dependencies: ($circular|tonumber)
        },
        warnings: {
          eslint_errors: ($eslint_e|tonumber),
          eslint_warnings: ($eslint_w|tonumber)
        },
        score: (100 - ([($ts|tonumber), ($secrets|tonumber), ($vulns|tonumber)] | add)),
        recommendation: (
          if ($secrets|tonumber) > 0 then "BLOCK: Secrets detected"
          elif ($ts|tonumber) > 10 then "FIX: Major TypeScript errors"
          elif ($vulns|tonumber) > 0 then "REVIEW: Security vulnerabilities"
          else "PASS: Ready for fixes" end)
      }' > "$AUDIT/summary.json"

  local phase_end=$(ts)
  track_phase_timing "analysis" $(( phase_end - phase_start ))
  local score=$(jq -r '.score' "$AUDIT/summary.json")
  local rec=$(jq -r '.recommendation' "$AUDIT/summary.json")
  echo -e "${BOLD}Health Score: ${score}/100${RESET}"
  echo -e "${BOLD}Recommendation: ${rec}${RESET}\n"
}

# ---------------------- Phase 3: Fix ----------------------
phase_fix() {
  ensure_root_cwd
  local phase_start=$(ts)
  echo -e "\n${M}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${M}${BOLD}║${RESET}  🔧  ${BOLD}PHASE 3: SURGICAL FIXES${RESET}"
  echo -e "${M}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}\n"

  [[ $DRY_RUN -eq 1 ]] && warn "DRY-RUN MODE: No changes will be written"

  local stack=$(detect_stack)
  local has_node=$(jq -r '.node' <<<"$stack")
  local has_py=$(jq -r '.python' <<<"$stack")
  local fixes=()

  if [[ $has_node == "true" ]]; then
    fixes+=(
      "prettier" "npx prettier --write . --log-level silent 2>/dev/null || true"
      "eslint-fix" "npx eslint . --ext .ts,.tsx,.js,.jsx --fix --quiet 2>/dev/null || true"
      "package-sort" "npx sort-package-json 2>/dev/null || true"
      "npm-update" "npm update --silent 2>/dev/null || true"
      "npm-audit-fix" "npm audit fix --force --silent 2>/dev/null || true"
    )
  fi
  if [[ $has_py == "true" ]]; then
    fixes+=(
      "ruff-fix" "ruff check . --fix --silent 2>/dev/null || true"
      "black" "black . --quiet 2>/dev/null || true"
      "isort" "isort . --quiet 2>/dev/null || true"
    )
  fi

  local total=$(( ${#fixes[@]} / 2 ))
  local current=0
  for (( i = 0; i < ${#fixes[@]}; i += 2 )); do
    (( current++ ))
    draw_progress "$current" "$total" "Fixing: ${fixes[$i]}" "$(estimate_remaining "$current" "$total" 2)"
    run_sequential "fix" "${fixes[$i]}" "${fixes[$(( i + 1 ))]}" 1
  done

  local phase_end=$(ts)
  track_phase_timing "fix" $(( phase_end - phase_start ))
  success "Fixes applied in $(fmt_duration $(( phase_end - phase_start )))"
}

# ---------------------- Phase 4: Validate ----------------------
phase_validate() {
  ensure_root_cwd
  local phase_start=$(ts)
  echo -e "\n${M}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${M}${BOLD}║${RESET}  ✅  ${BOLD}PHASE 4: VALIDATION${RESET}"
  echo -e "${M}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}\n"

  local stack=$(detect_stack)
  local passed=0 total=0
  if [[ $(jq -r '.typescript' <<<"$stack") == "true" || $(git ls-files '*.ts' '*.tsx' 2>/dev/null | wc -l) -gt 0 ]]; then
    (( total++ ))
    info "Validating TypeScript..."
    if npx tsc --noEmit --skipLibCheck >/dev/null 2>&1; then
      success "TypeScript compiles cleanly"
      (( passed++ ))
    else
      warn "TypeScript has errors"
    fi
  fi
  if [[ $(jq -r '.node' <<<"$stack") == "true" ]]; then
    (( total++ ))
    info "Validating ESLint..."
    if npx eslint . --ext .ts,.tsx,.js,.jsx --max-warnings 0 >/dev/null 2>&1; then
      success "ESLint passed"
      (( passed++ ))
    else
      warn "ESLint has warnings/errors"
    fi
  fi
  if [[ $(jq -r '.python' <<<"$stack") == "true" ]]; then
    (( total++ ))
    info "Validating Python syntax..."
    if find . -name "*.py" -not -path "./.quantum/*" -exec python3 -m py_compile {} + 2>/dev/null; then
      success "Python syntax valid"
      (( passed++ ))
    else
      warn "Python syntax errors"
    fi
  fi
  if [[ -f package.json ]] && jq -e '.scripts.build' package.json >/dev/null 2>&1; then
    (( total++ ))
    info "Testing build..."
    if npm run build --silent >/dev/null 2>&1; then
      success "Build successful"
      (( passed++ ))
    else
      warn "Build failed"
    fi
  fi

  local score=$(( total > 0 ? passed * 100 / total : 100 ))
  echo -e "\n${BOLD}Validation Score: $score% ($passed/$total passed)${RESET}\n"
  if [[ $score -lt 80 ]]; then
    warn "Validation score below threshold"
    [[ $APPLY -eq 1 ]] && rollback_if_exists
    return 1
  fi
  local phase_end=$(ts)
  track_phase_timing "validate" $(( phase_end - phase_start ))
  success "Validation complete in $(fmt_duration $(( phase_end - phase_start )))"
}

# ---------------------- Metrics & Graphs ----------------------
export_metrics() {
  ensure_root_cwd
  local end_time=$(ts)
  local total_duration=$(( end_time - START_TIME ))
  cat > "$METRICS/metrics.prom" << EOF
# HELP quantum_architect_duration_seconds Total execution time
# TYPE quantum_architect_duration_seconds gauge
quantum_architect_duration_seconds{version="$VERSION"} $total_duration
# HELP quantum_architect_phase_duration_seconds Phase execution time
# TYPE quantum_architect_phase_duration_seconds gauge
EOF
  for phase in "${!PHASE_TIMINGS[@]}"; do
    echo "quantum_architect_phase_duration_seconds{phase=\"$phase\"} ${PHASE_TIMINGS[$phase]}" >> "$METRICS/metrics.prom"
  done
  local timings_json="{"
  for k in "${!PHASE_TIMINGS[@]}"; do
    timings_json+="\"$k\":${PHASE_TIMINGS[$k]},"
  done
  timings_json="${timings_json%,}}"
  local summary_content='{}'
  [[ -s "$AUDIT/summary.json" ]] && summary_content="$(cat "$AUDIT/summary.json")"
  jq -n --arg version "$VERSION" --arg duration "$total_duration" --argjson summary "$summary_content" --argjson timings "$timings_json" \
    '{version:$version,timestamp:(now|todate),duration_seconds:($duration|tonumber),phase_timings:$timings,summary:$summary}' > "$METRICS/report.json"
  info "Metrics exported to $METRICS/"
}

generate_dependency_graph() {
  ensure_root_cwd
  info "Generating dependency graphs..."
  if [[ -f package.json ]]; then
    npx madge --image "$GRAPHS/dependencies.svg" . 2>/dev/null || true
    npx madge --dot . > "$GRAPHS/dependencies.dot" 2>/dev/null || true
    npx madge --circular --extensions ts,tsx,js,jsx . > "$GRAPHS/circular.txt" 2>/dev/null || true
    local circular_count=$(grep -c "Circular" "$GRAPHS/circular.txt" 2>/dev/null || echo 0)
    if [[ $circular_count -gt 0 ]]; then
      warn "Found $circular_count circular dependencies"
    else
      success "No circular dependencies detected"
    fi
  fi
  if [[ -f requirements.txt ]] && command -v pipdeptree >/dev/null 2>&1; then
    pipdeptree --json > "$GRAPHS/python-deps.json" 2>/dev/null || true
  fi
}

show_banner() {
  clear
  cat << 'BANNER'
╔═══════════════════════════════════════════════════════════════════╗
║   ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗████████╗██╗   ██╗███╗   ███╗║
║  ██╔═══██╗██║   ██║██╔══██╗████╗  ██║╚══██╔══╝██║   ██║████╗ ████║
║  ██║   ██║██║   ██║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║
║  ██║▄▄ ██║██║   ██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║
║  ╚██████╔╝╚██████╔╝██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║
║   ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝
╚═══════════════════════════════════════════════════════════════════╝
BANNER
  echo -e "${DIM}Version: $VERSION${RESET}\n"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --apply)
        APPLY=1
        DRY_RUN=0
        ;;
      --auto-yes|-y)
        AUTO_YES=1
        ;;
      --skip-backup)
        SKIP_BACKUP=1
        ;;
      --verbose|-v)
        VERBOSE=1
        set -x
        ;;
      --parallel|-j)
        shift
        MAX_PARALLEL=$1
        ;;
      --help|-h)
        cat << 'HELP'
Usage: fix-arch.sh [--apply] [-y] [--skip-backup] [-v] [-j N]
HELP
        exit 0
        ;;
      *)
        error "Unknown option: $1"
        echo "Use --help"
        exit 1
        ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"
  cd "$ROOT_DIR"
  show_banner
  if [[ $DRY_RUN -eq 1 ]]; then
    echo -e "${Y}${BOLD}MODE: DRY-RUN${RESET}"
  else
    echo -e "${G}${BOLD}MODE: APPLY${RESET}"
  fi
  echo -e "${DIM}Root: $ROOT_DIR${RESET}\n"
  if [[ $APPLY -eq 1 && $AUTO_YES -eq 0 ]]; then
    read -rp "This will modify your codebase. Continue? [y/N] " c
    if [[ ! ${c,,} =~ ^y ]]; then
      warn "Aborted"
      exit 0
    fi
  fi
  info "Bootstrapping environment..."
  bootstrap_environment
  [[ $APPLY -eq 1 ]] && create_backup
  phase_audit
  draw_progress 1 4 "Overall Progress" -1
  phase_analysis
  draw_progress 2 4 "Overall Progress" -1
  phase_fix
  draw_progress 3 4 "Overall Progress" -1
  phase_validate
  draw_progress 4 4 "Overall Progress" -1
  generate_dependency_graph
  export_metrics
  local end_time=$(ts)
  local total=$(( end_time - START_TIME ))
  local score=$(jq -r '.score // 100' "$AUDIT/summary.json")
  echo -e "\n${M}${BOLD}═══════════════════════════════════════════════════${RESET}"
  echo -e "${G}${BOLD}  ✓  QUANTUM ARCHITECT COMPLETE  ✓${RESET}"
  echo -e "${M}${BOLD}═══════════════════════════════════════════════════${RESET}\n"
  echo -e "${BOLD}📊 FINAL REPORT${RESET}\n  ${C}•${RESET} Total Duration: $(fmt_duration $total)\n  ${C}•${RESET} Health Score: ${score}/100\n  ${C}•${RESET} Phases Completed: 4/4\n  ${C}•${RESET} Mode: $([[ $DRY_RUN -eq 1 ]] && echo DRY-RUN || echo APPLIED)"
  echo -e "\n${BOLD}📁 ARTIFACTS${RESET}\n  ${C}•${RESET} Logs:    $LOGS/\n  ${C}•${RESET} Audit:   $AUDIT/\n  ${C}•${RESET} Graphs:  $GRAPHS/\n  ${C}•${RESET} Metrics: $METRICS/"
  [[ -n "$BACKUP_ID" ]] && echo -e "  ${C}•${RESET} Backup:  $BACKUPS/$BACKUP_ID"
  [[ $DRY_RUN -eq 1 ]] && echo -e "\n${Y}${BOLD}TIP:${RESET} run again with --apply"
  cleanup
}

main "$@"
