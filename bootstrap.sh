#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
nvim_only=false
skip_sync=false

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [--nvim-only] [--skip-sync]

  --nvim-only  Restore only the LazyVim configuration.
  --skip-sync  Do not download LazyVim plugins and Mason tools.
EOF
}

while (($#)); do
  case "$1" in
    --nvim-only) nvim_only=true ;;
    --skip-sync) skip_sync=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

link_config() {
  local relative="$1"
  local source="$repo_dir/home/$relative"
  local target="$HOME/$relative"

  mkdir -p "$(dirname -- "$target")"
  if [[ -L "$target" && "$(readlink -f -- "$target")" == "$(readlink -f -- "$source")" ]]; then
    printf 'Already linked: %s\n' "$target"
    return
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    local saved="$backup_dir/$relative"
    mkdir -p "$(dirname -- "$saved")"
    mv -- "$target" "$saved"
    printf 'Backed up: %s -> %s\n' "$target" "$saved"
  fi
  ln -s -- "$source" "$target"
  printf 'Linked: %s -> %s\n' "$target" "$source"
}

link_config ".config/nvim"

if [[ "$nvim_only" == false ]]; then
  link_config ".tmux.conf"
  link_config ".bashrc"
  link_config ".bash_profile"
  link_config ".gitconfig"
fi

if [[ "$skip_sync" == false ]]; then
  if ! command -v nvim >/dev/null 2>&1; then
    printf 'Neovim is not installed. Run ./install-rocky-packages.sh first.\n' >&2
    exit 1
  fi
  nvim --headless "+Lazy! sync" +qa
  mapfile -t mason_packages < <(sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' "$repo_dir/packages/mason.txt")
  if ((${#mason_packages[@]})); then
    nvim --headless -c "MasonInstall ${mason_packages[*]}" -c qall
  fi
fi

printf '\nDone. Start Neovim with: nvim\n'
