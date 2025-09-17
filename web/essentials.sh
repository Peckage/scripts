#!/usr/bin/env bash
set -Ee -o pipefail   # no -u, nvm incompatible with nounset

# -------------------------------------
# Logging
# -------------------------------------
GREEN="\033[0;32m"; YELLOW="\033[1;33m"; RED="\033[0;31m"; NC="\033[0m"
log()  { echo -e "${GREEN}[*]${NC} $*"; }
err()  { echo -e "${RED}[x]${NC} $*"; }
trap 'err "Failed at line $LINENO"' ERR

# -------------------------------------
# Base deps
# -------------------------------------
log "Updating system..."
sudo apt-get update -y && sudo apt-get upgrade -y

log "Installing base packages..."
sudo apt-get install -y curl wget git build-essential ca-certificates jq unzip htop

# -------------------------------------
# NVM + Node (LTS) + npm
# -------------------------------------
NVM_VERSION="v0.39.7"
if [ ! -d "$HOME/.nvm" ]; then
  log "Installing NVM $NVM_VERSION ..."
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
fi

export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1090
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

log "Installing latest LTS Node.js..."
nvm install --lts
nvm alias default 'lts/*'
nvm use default

log "Updating npm..."
npm install -g npm

# -------------------------------------
# pnpm (via corepack or fallback)
# -------------------------------------
if command -v corepack >/dev/null 2>&1; then
  log "Enabling pnpm via corepack..."
  corepack enable
  corepack prepare pnpm@latest --activate || true
else
  log "Installing pnpm via npm..."
  npm install -g pnpm
fi

# Fallback if still missing
if ! command -v pnpm >/dev/null 2>&1; then
  npm install -g pnpm
fi

# -------------------------------------
# Final checks
# -------------------------------------
echo
log "Verifying installs..."
echo "node:  $(command -v node) -> $(node -v)"
echo "npm:   $(command -v npm)  -> $(npm -v)"
echo "pnpm:  $(command -v pnpm || echo 'not found') $(pnpm -v 2>/dev/null || true)"
echo
log "✅ Done. Open a new shell or run: source \"$HOME/.bashrc\""
