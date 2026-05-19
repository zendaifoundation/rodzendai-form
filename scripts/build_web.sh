#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/build_web.sh <customer> [extra flutter build args...]
#   ./scripts/build_web.sh <customer> --env=<env-file> [extra args...]
#
# Examples:
#   ./scripts/build_web.sh pattaya
#   ./scripts/build_web.sh samed --env=.env.staging_samed
#   ./scripts/build_web.sh default
#   ./scripts/build_web.sh pattaya --base-href=/pattaya/

CUSTOMER="${1:-}"
if [ -z "$CUSTOMER" ]; then
  echo "Usage: $0 <samed|pattaya|default> [--env=<file>] [extra flutter args...]" >&2
  exit 1
fi
shift

case "$CUSTOMER" in
  samed|pattaya)
    SPLASH_CONFIG="flutter_native_splash-${CUSTOMER}.yaml"
    DEFAULT_ENV=".env_${CUSTOMER}"
    ;;
  default)
    SPLASH_CONFIG="flutter_native_splash.yaml"
    DEFAULT_ENV=".env"
    ;;
  *)
    echo "Error: unknown customer '$CUSTOMER' (expected: samed|pattaya|default)" >&2
    exit 1
    ;;
esac

ENV_FILE=""
EXTRA_ARGS=()
for arg in "$@"; do
  case "$arg" in
    --env=*) ENV_FILE="${arg#--env=}" ;;
    *) EXTRA_ARGS+=("$arg") ;;
  esac
done
ENV_FILE="${ENV_FILE:-$DEFAULT_ENV}"

[ -f "$SPLASH_CONFIG" ] || { echo "Error: $SPLASH_CONFIG not found" >&2; exit 1; }
[ -f "$ENV_FILE" ]      || { echo "Error: $ENV_FILE not found"      >&2; exit 1; }

echo "==> Generating splash from $SPLASH_CONFIG"
dart run flutter_native_splash:create --path="$SPLASH_CONFIG"

echo "==> Building web with $ENV_FILE"
flutter build web --release --dart-define-from-file="$ENV_FILE" "${EXTRA_ARGS[@]}"

echo "==> Done. Output: build/web/"
