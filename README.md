# jfkfiles

Reproducible machine setup — **easily change my computer**. Lightweight stack
(chezmoi + Brewfile + macOS scripts), architected to keep the **host minimal** so
it ports cleanly to an immutable Linux host (Bluefin/Silverblue) later.

## Design principle
The host carries only **GUI apps + shell + container runtime**. Every dev
toolchain (embedded, python, node, …) lives in a **devcontainer**. That is what
makes this immutable-OS-friendly.

```
Host (per-OS, declarative)        home/Brewfile          + packages/packages.yaml (Linux map)
Dotfiles (chezmoi, templated)     home/dot_*             portable via {{ .chezmoi.os }} guards
Dev (devcontainers / devpod)      devcontainer/          toolchains + dotfiles injected
macOS settings (recovery)         scripts/macos-*.sh
```

## Layout
| Path | What |
|------|------|
| `home/` | chezmoi-managed `$HOME` tree (`.chezmoiroot` points here) |
| `home/Brewfile` | **your tool list** — formulae, casks, VS Code ext, npm globals |
| `home/dot_zshrc.tmpl`, `dot_gitconfig.tmpl` | templated dotfiles |
| `home/.chezmoiscripts/` | `run_onchange` → `brew bundle` on apply |
| `packages/packages.yaml` | macOS→Linux package map (immutable-OS port) |
| `scripts/bootstrap.sh` | one-command new-machine setup |
| `scripts/macos-defaults.sh` | curated, idempotent macOS settings |
| `scripts/macos-export-domains.sh` | snapshot app prefs to `packages/macos/` |
| `devcontainer/embedded/` | ARM/Pico devcontainer (USB passthrough) |
| `docs/devcontainers-usb.md` | USB-on-macOS reality + workarounds |

## First-time publish (from this dev repo)
```sh
cd ~/Sources/jfkfiles
git add -A && git commit -m "init reproducible setup"
gh repo create kohlerj/jfkfiles --private --source=. --push   # or your remote
```

## New machine
```sh
sh -c "$(curl -fsLS raw.githubusercontent.com/kohlerj/jfkfiles/main/scripts/bootstrap.sh)"
```
This installs Homebrew + chezmoi, runs `chezmoi init --apply` (clones to
`~/.local/share/chezmoi`, applies dotfiles, and runs `brew bundle`).

## Day-to-day
```sh
chezmoi edit ~/.zshrc          # edit a managed file
chezmoi apply                  # apply changes (re-runs brew bundle if Brewfile changed)
chezmoi re-add                 # pull host changes back into the repo
brew bundle dump --force --file=~/Brewfile && chezmoi re-add ~/Brewfile   # refresh tool list
bash scripts/macos-export-domains.sh   # back up macOS prefs
```

## Still TODO (recommended next)
- [ ] Bring AI config files under chezmoi (RTK.md, copilot/claude instructions, MCP) — deferred
- [ ] Add `orcaslicer` cask to Brewfile if you want it managed
- [ ] Pin a `starship.toml` if you customize the prompt
- [ ] Secrets strategy (Keychain/age) before committing anything sensitive
