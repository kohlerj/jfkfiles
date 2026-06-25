# jfkfiles

Reproducible machine setup — **easily change my computer**. Lightweight stack
(chezmoi + Brewfile + distro-aware scripts), architected to keep the **host minimal**
so it ports cleanly to any OS.

## Design principle
The host carries only **GUI apps + shell + container runtime**. Every dev
toolchain (embedded, python, node, …) lives in a **devcontainer**. That is what
makes this immutable-OS-friendly.

```
Host (macOS)              home/Brewfile            + scripts/macos-*.sh
Host (Fedora Atomic)      image/Containerfile      shell tools baked into a custom base image
Host (Alpine/Deb/Ubuntu)  chezmoi run_once_before  tools installed automatically at apply time
Dotfiles (chezmoi)        home/dot_*               portable via .data.linuxVariant guards
Dev (devcontainers)       (planned)                toolchains + dotfiles injected
```

## Layout
| Path | What |
|------|------|
| `home/` | chezmoi-managed `$HOME` tree (`.chezmoiroot` points here) |
| `home/Brewfile` | **your tool list** — formulae, casks, VS Code ext, npm globals |
| `home/dot_zshrc.tmpl`, `dot_gitconfig.tmpl` | templated dotfiles |
| `home/.chezmoi.toml.tmpl` | `chezmoi init` prompts + `linuxVariant` detection |
| `home/.chezmoiignore` | repo/dev artifacts chezmoi must not apply to `$HOME` |
| `home/.chezmoiscripts/run_once_before_05` | install oh-my-zsh (all platforms) |
| `home/.chezmoiscripts/run_once_before_10` | install shell tools (Alpine / Debian / Ubuntu only) |
| `home/.chezmoiscripts/run_onchange_after_20` | `brew bundle` on Brewfile change (macOS) |
| `home/.chezmoiscripts/run_onchange_after_30` | set zsh login shell (Linux) |
| `image/Containerfile` | custom Fedora Sway Atomic image — host shell tools baked in |
| `image/README.md` | how to build, publish, and rebase onto the custom image |
| `.github/workflows/build-image.yml` | CI: rebuild + push the image (push to `image/**`, manual, weekly) |
| `scripts/bootstrap.sh` | one-command new-machine setup |
| `install.sh` | devpod entry point — delegates to `scripts/bootstrap.sh` |
| `scripts/macos-defaults.sh` | curated, idempotent macOS settings |
| `scripts/macos-export-domains.sh` | snapshot app prefs to `packages/macos/` (gitignored) |

## Linux variants

| Variant | Tool install strategy | Command |
|---------|----------------------|---------|
| **Fedora Sway Atomic** | Tools baked into custom OCI image (immutable root) | Rebase first — see `image/README.md`; then run bootstrap |
| **Alpine** | `apk` + static binaries (starship) via `run_once_before_10` | `bash scripts/bootstrap.sh` |
| **Debian / Ubuntu** | `apt-get` + upstream repos (eza, starship) via `run_once_before_10` | `bash scripts/bootstrap.sh` |

The `linuxVariant` template variable (set in `.chezmoi.toml.tmpl`) flows through
all chezmoi scripts so each distro path is handled explicitly.

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
This installs the required package manager / chezmoi, then runs `chezmoi init --apply`
(clones to `~/.local/share/chezmoi`, applies dotfiles, installs shell tools for your distro,
and runs `brew bundle` on macOS).

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
