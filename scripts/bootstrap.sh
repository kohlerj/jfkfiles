#!/usr/bin/env bash
# Bootstrap a fresh machine from this repo.
#   macOS:  installs Homebrew (if needed) -> chezmoi -> applies dotfiles -> brew bundle
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
  # Linux / immutable host
  command -v chezmoi >/dev/null 2>&1 || sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
fi

# chezmoi clones to ~/.local/share/chezmoi and applies (runs brew bundle via run_onchange)
echo "==> chezmoi init --apply"
chezmoi init --apply "$REPO"

if [ "$OS" = "Darwin" ]; then
  echo
  echo "Next (optional):"
  echo "  bash \"\$(chezmoi source-path)/../scripts/macos-defaults.sh\"   # apply macOS tweaks"
fi
echo "==> Done."
