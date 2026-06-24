#!/usr/bin/env bash
# Curated, declarative macOS settings for fast recovery on a new machine.
# Idempotent: safe to re-run. Edit here, commit, re-run after a reinstall.
# Run: bash scripts/macos-defaults.sh   (then log out/in or restart affected apps)
set -euo pipefail
[[ "$(uname)" == "Darwin" ]] || { echo "macOS only"; exit 0; }

echo "==> Applying curated macOS defaults"

# --- Keyboard ---
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false   # key repeat over accents
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain KeyRepeat -int 2

# --- Finder ---
defaults write com.apple.finder AppleShowAllFiles -bool true          # show hidden files
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"   # search current folder
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# --- Screenshots ---
mkdir -p "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# --- Dock ---
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 48

# --- Misc dev quality-of-life ---
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true   # no .DS_Store on network
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "==> Restarting affected apps"
for app in Finder Dock SystemUIServer; do killall "$app" >/dev/null 2>&1 || true; done
echo "Done. Some settings need a log out / restart."
