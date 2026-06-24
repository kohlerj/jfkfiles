# Custom Fedora Sway Atomic image

Bakes the **host shell tools** (zsh, eza, fzf, zoxide, tmux, bat, fd, gh, neovim,
starship, …) and the devcontainer runner (devpod; podman already ships) into a
custom base image. This is the declarative, immutable, "based on config" way —
the host stays reproducible and you never `rpm-ostree install` by hand.

Dev toolchains are **not** here — those live in devcontainers (see `../devcontainer`).

## What's where
| Layer | Source of truth |
|-------|-----------------|
| Host base image (Fedora Atomic) | `image/Containerfile` |
| Host shell config | chezmoi (`home/dot_zshrc.tmpl`, …) |
| Dev toolchains | devcontainers (`devcontainer/`) |

## Build & publish
```sh
# 1. Pin FROM tag in Containerfile to your Fedora version (e.g. :41)
podman build --build-arg ARCH="$(uname -m)" -t ghcr.io/kohlerj/sway-atomic:latest image/
podman push ghcr.io/kohlerj/sway-atomic:latest
```
(Automate later with a GitHub Action that rebuilds weekly on the upstream image.)

## Rebase the host onto it
```sh
# bootc (current Atomic) ...
sudo bootc switch ghcr.io/kohlerj/sway-atomic:latest
# ... or rpm-ostree on older images
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/kohlerj/sway-atomic:latest
systemctl reboot
```

After reboot the tools are present on the host. chezmoi then only applies your
dotfiles and sets zsh as the login shell (`home/.chezmoiscripts/…linux-shell…`).

## Local test without rebasing
```sh
podman run --rm -it ghcr.io/kohlerj/sway-atomic:latest /usr/bin/zsh
```
