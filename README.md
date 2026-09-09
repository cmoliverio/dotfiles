# dotfiles

Personal LazyVim, tmux, shell, Codex, WSL, and Windows Terminal configuration.

## Linux bootstrap

After installing Git and cloning the repository, one command provisions a
machine running Ubuntu/Debian or Rocky/RHEL-like Linux:

```bash
git clone git@github.com:cmoliverio/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

The bootstrap detects the distribution, installs the packages in
`packages/<distro>.txt`, and installs the pinned Neovim, Node.js, uv, and Codex
CLI versions from `packages/versions.txt`. It does not replace an existing
Codex CLI installation, links the tracked configuration, installs TPM with
`tmux-resurrect` and `tmux-continuum`, restores LazyVim's lockfile, and installs
the Mason tools in `packages/mason.txt`. It requires `sudo` and network access.

Existing dotfiles are moved into `~/.dotfiles-backup/<timestamp>/` before repo
versions are linked. Codex authentication is never tracked or replaced; only
`~/.codex/config.toml`, including the personal keymaps, is managed.

Useful modes:

```bash
./bootstrap.sh --nvim-only       # Link and synchronize only LazyVim
./bootstrap.sh --packages-only   # Provision tools, but do not link configuration
./bootstrap.sh --skip-packages   # Link/sync when the machine is already provisioned
./bootstrap.sh --skip-sync       # Do not download LazyVim or Mason dependencies
```

## Windows Terminal

Install and open Windows Terminal once, close it, then run this from the repo
inside WSL:

```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w "$PWD/restore-windows-terminal.ps1")"
```

The script backs up the current Windows Terminal settings before restoring the
tracked keybindings, profiles, and appearance.

## WSL settings

`wsl/wsl.conf` is intentionally not installed automatically because changing
`/etc/wsl.conf` requires administrator access. Restore it explicitly with:

```bash
sudo install -m 0644 wsl/wsl.conf /etc/wsl.conf
```

Then run `wsl --shutdown` from PowerShell before reopening the distribution.

## What is intentionally excluded

Neovim's downloaded plugin/cache directories, SSH keys, tokens, shell history,
Codex credentials, and other machine-local secrets are not stored here.
