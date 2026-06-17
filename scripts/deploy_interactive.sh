#!/usr/bin/env bash
# Interactive deploy wizard: choose env → confirm → choose customer → build → deploy
set -euo pipefail

# ─── Colours ──────────────────────────────────────────────────────────────────
BOLD='\033[1m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

header()  { echo -e "\n${BOLD}${CYAN}$*${RESET}"; }
success() { echo -e "${GREEN}✓ $*${RESET}"; }
warn()    { echo -e "${YELLOW}⚠ $*${RESET}"; }
error()   { echo -e "${RED}✗ $*${RESET}" >&2; exit 1; }
info()    { echo -e "  $*"; }

# ─── Generic menu picker ──────────────────────────────────────────────────────
# Usage: pick_option "Prompt" "opt1" "opt2" ...
# Sets PICKED to the chosen value.
pick_option() {
  local prompt="$1"; shift
  local options=("$@")
  local i

  echo -e "\n${BOLD}${prompt}${RESET}"
  for i in "${!options[@]}"; do
    printf "  ${CYAN}%2d)${RESET} %s\n" "$((i+1))" "${options[$i]}"
  done
  echo ""

  while true; do
    read -rp "  Enter number [1-${#options[@]}]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
      PICKED="${options[$((choice-1))]}"
      return 0
    fi
    warn "Invalid choice, try again."
  done
}

# ─── Step 1: choose environment ───────────────────────────────────────────────
header "Step 1 — Select environment"
pick_option "Which environment?" "production" "staging" "sandbox"
ENV_TIER="$PICKED"

# ─── Step 2: choose customer ──────────────────────────────────────────────────
header "Step 2 — Select customer"
pick_option "Which customer?" \
  "bangkok" \
  "samed" \
  "pattaya" \
  "tessaban_angsila" \
  "tessaban_saensuk"
CUSTOMER="$PICKED"

# ─── Resolve env file and firebase site ───────────────────────────────────────
case "${ENV_TIER}:${CUSTOMER}" in
  # ── production ──────────────────────────────────────────────────────────────
  production:bangkok)
    ENV_FILE=".env"
    SPLASH_CONFIG="flutter_native_splash.yaml"
    FIREBASE_SITE="rodzendai-form"
    ;;
  production:samed)
    ENV_FILE=".env_samed"
    SPLASH_CONFIG="flutter_native_splash_samed.yaml"
    FIREBASE_SITE="rodzendai-form-samed"
    ;;
  production:pattaya)
    ENV_FILE=".env_pattaya"
    SPLASH_CONFIG="flutter_native_splash_pattaya.yaml"
    FIREBASE_SITE="rodzendai-form-pattaya"
    ;;
  production:tessaban_angsila)
    ENV_FILE=".env_tessaban_angsila"
    SPLASH_CONFIG="flutter_native_splash_tessaban_angsila.yaml"
    FIREBASE_SITE="rodzendai-form-tessaban-angsila"
    ;;
  production:tessaban_saensuk)
    ENV_FILE=".env_tessaban_saensuk"
    SPLASH_CONFIG="flutter_native_splash_tessaban_saensuk.yaml"
    FIREBASE_SITE="rodzendai-form-tessaban-saensuk"
    ;;
  # ── staging ─────────────────────────────────────────────────────────────────
  staging:bangkok)
    ENV_FILE=".env.staging"
    SPLASH_CONFIG="flutter_native_splash.yaml"
    FIREBASE_SITE="rodzendai-form"
    ;;
  staging:samed)
    ENV_FILE=".env.staging_samed"
    SPLASH_CONFIG="flutter_native_splash_samed.yaml"
    FIREBASE_SITE="rodzendai-form-samed-staging"
    ;;
  staging:pattaya)
    ENV_FILE=".env.staging_pattaya"
    SPLASH_CONFIG="flutter_native_splash_pattaya.yaml"
    FIREBASE_SITE="rodzendai-form-pattaya-staging"
    ;;
  staging:tessaban_angsila)
    ENV_FILE=".env.staging_angsila"
    SPLASH_CONFIG="flutter_native_splash_tessaban_angsila.yaml"
    FIREBASE_SITE="rodzendai-form-tessaban-angsila-staging"
    ;;
  staging:tessaban_saensuk)
    ENV_FILE=".env.staging_saensuk"
    SPLASH_CONFIG="flutter_native_splash_tessaban_saensuk.yaml"
    FIREBASE_SITE="rodzendai-form-saensuk-staging"
    ;;
  # ── sandbox ─────────────────────────────────────────────────────────────────
  sandbox:bangkok)
    ENV_FILE=".env.sandbox"
    SPLASH_CONFIG="flutter_native_splash.yaml"
    FIREBASE_SITE="rodzendai-form-sandbox"
    ;;
  sandbox:samed)
    ENV_FILE=".env.sandbox_samed"
    SPLASH_CONFIG="flutter_native_splash_samed.yaml"
    FIREBASE_SITE="rodzendai-form-samed-sandbox"
    ;;
  sandbox:pattaya)
    ENV_FILE=".env.sandbox_pattaya"
    SPLASH_CONFIG="flutter_native_splash_pattaya.yaml"
    FIREBASE_SITE="rodzendai-form-pattaya-sandbox"
    ;;
  sandbox:tessaban_angsila)
    ENV_FILE=".env.sandbox_tessaban_angsila"
    SPLASH_CONFIG="flutter_native_splash_tessaban_angsila.yaml"
    FIREBASE_SITE="rodzendai-form-tessaban-angsila-sandbox"
    ;;
  sandbox:tessaban_saensuk)
    ENV_FILE=".env.sandbox_tessaban_saensuk"
    SPLASH_CONFIG="flutter_native_splash_tessaban_saensuk.yaml"
    FIREBASE_SITE="rodzendai-form-saensuk-sandbox"
    ;;
  *)
    error "Unhandled combination: ${ENV_TIER}:${CUSTOMER}"
    ;;
esac

# ─── Validate files exist ─────────────────────────────────────────────────────
[ -f "$ENV_FILE" ]       || error "Env file not found: $ENV_FILE"
[ -f "$SPLASH_CONFIG" ]  || error "Splash config not found: $SPLASH_CONFIG"

# ─── Step 3: confirm ──────────────────────────────────────────────────────────
header "Step 3 — Confirm deploy"
echo ""
printf "  %-18s ${BOLD}%s${RESET}\n" "Environment:"   "$ENV_TIER"
printf "  %-18s ${BOLD}%s${RESET}\n" "Customer:"      "$CUSTOMER"
printf "  %-18s ${BOLD}%s${RESET}\n" "Env file:"      "$ENV_FILE"
printf "  %-18s ${BOLD}%s${RESET}\n" "Splash config:" "$SPLASH_CONFIG"
printf "  %-18s ${BOLD}%s${RESET}\n" "Firebase site:" "$FIREBASE_SITE"
echo ""

read -rp "  Proceed? [y/N] " confirm
case "$confirm" in
  [yY]|[yY][eE][sS]) ;;
  *) warn "Aborted."; exit 0 ;;
esac

# ─── Build & Deploy ───────────────────────────────────────────────────────────
header "Building & deploying…"
echo ""

info "→ Generating splash from ${SPLASH_CONFIG}"
dart run flutter_native_splash:create --path="$SPLASH_CONFIG"

info "→ flutter clean"
fvm flutter clean

info "→ Building web with ${ENV_FILE}"
fvm flutter build web --release --dart-define-from-file="$ENV_FILE"

info "→ Deploying to Firebase hosting: ${FIREBASE_SITE}"
firebase deploy --only "hosting:${FIREBASE_SITE}"

echo ""
success "Deploy complete → https://${FIREBASE_SITE}.web.app"
