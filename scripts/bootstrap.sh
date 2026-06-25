#!/usr/bin/env bash
# Bootstrap a fresh machine from this repo.
#   macOS:             installs Homebrew (if needed) -> chezmoi -> applies dotfiles -> brew bundle
#   Fedora Atomic:     rebase onto custom OCI image first (image/README.md), then run this
#   Alpine:            ensures curl + bash are available, then chezmoi applies dotfiles + tools
#   Ubuntu/Debian:     ensures curl is available, then chezmoi applies dotfiles + tools
# Run on a NEW machine:
#   sh -c "$(curl -fsLS raw.githubusercontent.com/kohlerj/jfkfiles/main/scripts/bootstrap.sh)"
# or, with the repo cloned:  bash scripts/bootstrap.sh
set -euo pipefail

REPO="${JFKFILES_REPO:-https://github.com/kohlerj/jfkfiles}"
OS="$(uname)"

echo "==> Bootstrapping from $REPO on $OS"

if [ "$OS" = "Darwin" ]; then
  # Homebrew
  if ! command -v brew >/dev/null 2>&1; then
    echo "==> Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$([ -x /opt/homebrew/bin/brew ] && /opt/homebrew/bin/brew shellenv || /usr/local/bin/brew shellenv)"
  command -v chezmoi >/dev/null 2>&1 || brew install chezmoi
else
  # Detect Linux variant from /etc/os-release
  LINUX_VARIANT="linux"
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    _ID="${ID:-}"
    _ID_LIKE="${ID_LIKE:-}"
    if [ "$_ID" = "fedora" ] && [ -e /run/ostree-booted ]; then
      LINUX_VARIANT="fedora-atomic"
    elif [ "$_ID" = "alpine" ]; then
      LINUX_VARIANT="alpine"
    elif [ "$_ID" = "debian" ] || [ "$_ID" = "ubuntu" ] || echo "$_ID_LIKE" | grep -q "debian"; then
      LINUX_VARIANT="debian"
    fi
  fi
  echo "==> Detected Linux variant: $LINUX_VARIANT"

  case "$LINUX_VARIANT" in
    fedora-atomic)
      echo "==> Fedora Atomic: shell tools must be in the custom OCI image."
      echo "    Rebase onto image/Containerfile before running this script."
      echo "    See image/README.md for instructions."
      ;;
    alpine)
      echo "==> Alpine: ensuring curl and bash are available"
      command -v curl >/dev/null 2>&1 || sudo apk add --no-cache curl
      command -v bash >/dev/null 2>&1 || sudo apk add --no-cache bash
      ;;
    debian)
      echo "==> Debian/Ubuntu: ensuring curl is available"
      if ! command -v curl >/dev/null 2>&1; then
        sudo apt-get update -qq
        sudo apt-get install -y --no-install-recommends curl
      fi
      ;;
  esac

  # Install chezmoi into ~/.local/bin if not already present
  command -v chezmoi >/dev/null 2>&1 || sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
fi

# chezmoi clones to ~/.local/share/chezmoi and applies
# (runs brew bundle via run_onchange on macOS; installs tools via run_once_before on Linux)
echo "==> chezmoi init --apply"
chezmoi init --apply "$REPO"

if [ "$OS" = "Darwin" ]; then
  echo
  echo "Next (optional):"
  echo "  bash \"\$(chezmoi source-path)/../scripts/macos-defaults.sh\"   # apply macOS tweaks"
fi
echo "==> Done."
