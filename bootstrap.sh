#!/usr/bin/env bash
# Fresh-Mac bootstrap for dotfiles-new (nix-darwin + home-manager + homebrew).
#
# Usage (fresh macOS, Setup Assistant done, user `malinruwanpathirana`):
#   export DOTFILES_PAT=<github-fine-grained-PAT-with-contents-read>
#   curl -fsSL -H "Authorization: Bearer $DOTFILES_PAT" \
#     https://raw.githubusercontent.com/MalinrRuwan/dotfiles-new/main/bootstrap.sh -o /tmp/bootstrap.sh
#   bash /tmp/bootstrap.sh
#
# Idempotent: every step checks first and skips when already done.
set -euo pipefail

REPO_URL="github.com/MalinrRuwan/dotfiles-new.git"
TARGET_DIR="/private/etc/nix-darwin"
FLAKE_REF=".#Malins-MacBook-Pro"
EXPECTED_USER="malinruwanpathirana"

log()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

have_clt()   { xcode-select -p >/dev/null 2>&1; }
have_nix()   { [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; }
have_brew()  { [ -x /opt/homebrew/bin/brew ] || [ -x /usr/local/bin/brew ]; }
have_repo()  { [ -d "$TARGET_DIR/.git" ]; }

step_clt() {
  if have_clt; then log "Xcode CLT already installed"; return; fi
  log "Installing Xcode Command Line Tools (approve the GUI dialog)..."
  xcode-select --install 2>/dev/null || true
  until have_clt; do sleep 10; done
  log "Xcode CLT installed"
}

step_nix() {
  if have_nix; then log "Nix (Determinate) already installed"; return; fi
  log "Installing Determinate Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  log "Nix installed: $(nix --version)"
}

step_brew() {
  if have_brew; then log "Homebrew already installed"; return; fi
  log "Installing Homebrew (nix-darwin only runs 'brew bundle' — it never installs brew itself)..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
  log "Homebrew installed: $(brew --version | head -1)"
}

step_clone() {
  if have_repo; then log "Repo already cloned at $TARGET_DIR"; return; fi
  if [ -e "$TARGET_DIR" ]; then
    die "$TARGET_DIR exists but is not a git repo — move it aside first"
  fi
  local pat="${DOTFILES_PAT:-}"
  if [ -z "$pat" ]; then
    printf "GitHub PAT (contents:read on dotfiles-new): "
    IFS= read -rs pat; echo
    [ -n "$pat" ] || die "PAT is required to clone the private repo"
  fi
  log "Cloning into $TARGET_DIR ..."
  sudo git clone "https://x-access-token:${pat}@${REPO_URL}" "$TARGET_DIR"
  sudo chown -R "$(whoami):staff" "$TARGET_DIR"
  unset pat
}

step_switch() {
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
  log "First nix-darwin switch (downloads GBs — stay on power + wifi)..."
  nix run nix-darwin -- switch --flake "$TARGET_DIR$FLAKE_REF"
  log "Bootstrap switch complete. Future updates: darwin-rebuild switch --flake $TARGET_DIR$FLAKE_REF"
}

main() {
  [ "$(uname -s)" = "Darwin" ] || die "macOS only"
  [ "$(whoami)" = "$EXPECTED_USER" ] || die "run as $EXPECTED_USER (current: $(whoami))"
  sudo -v || die "sudo required"
  step_clt
  step_nix
  step_brew
  step_clone
  step_switch
  cat <<'NEXT'

Done. Still manual (see RESTORE.md Part 3-4):
  1. Decrypt ~/identity-backup and restore ~/.ssh + GPG keys
  2. gh auth login, Raycast/UTM imports, brew services as needed
NEXT
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
