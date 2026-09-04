# dotfiles

Personal LazyVim, tmux, shell, WSL, and Windows Terminal configuration.

## Fastest LazyVim restore

Install Git and Neovim 0.11+, then run:

```bash
git clone git@github.com:cmoliverio/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh --nvim-only
nvim
```

The bootstrap script backs up an existing `~/.config/nvim`, links the tracked
configuration, restores the plugin commits in `lazy-lock.json`, and installs
the tools listed in `packages/mason.txt`.

## Full Linux restore on Rocky 8

```bash
git clone git@github.com:cmoliverio/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install-rocky-packages.sh
./bootstrap.sh
```

Existing dotfiles are moved into `~/.dotfiles-backup/<timestamp>/` before the
repo versions are linked. The package installer pins Neovim to 0.11.5 and
Node.js to the 20.x module stream.

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
