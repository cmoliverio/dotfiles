#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
nvim_only=false
skip_sync=false
skip_packages=false
packages_only=false
skip_codex=false

export PATH="$HOME/.local/bin:$PATH"

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [options]

  --nvim-only      Link and synchronize only the LazyVim configuration.
  --packages-only  Install packages and command-line tools without linking config files.
  --skip-packages  Do not install system packages or command-line tools.
  --skip-sync      Do not download LazyVim plugins or Mason tools.
  --skip-codex     Do not install Codex CLI when it is missing.

Supported distributions: Ubuntu/Debian and Rocky/RHEL-like systems.
EOF
}

while (($#)); do
  case "$1" in
    --nvim-only) nvim_only=true ;;
    --packages-only) packages_only=true ;;
    --skip-packages) skip_packages=true ;;
    --skip-sync) skip_sync=true ;;
    --skip-codex) skip_codex=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [[ "$nvim_only" == true && "$packages_only" == true ]]; then
  printf '%s\n' '--nvim-only and --packages-only cannot be used together.' >&2
  exit 2
fi

version_from_manifest() {
  local tool="$1"
  awk -v tool="$tool" '$1 == tool { print $2; exit }' "$repo_dir/packages/versions.txt"
}

as_root() {
  if ((EUID == 0)); then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    printf 'This step requires root privileges, but sudo is unavailable.\n' >&2
    exit 1
  fi
}

read_package_manifest() {
  local manifest="$1"
  mapfile -t packages < <(sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' "$manifest")
}

install_distro_packages() {
  if [[ ! -r /etc/os-release ]]; then
    printf 'Cannot identify this Linux distribution.\n' >&2
    exit 1
  fi

  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}" in
    ubuntu|debian)
      read_package_manifest "$repo_dir/packages/ubuntu.txt"
      as_root apt-get update
      as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
      ;;
    rocky|rhel|almalinux|centos)
      read_package_manifest "$repo_dir/packages/rocky.txt"
      as_root dnf install -y epel-release
      as_root dnf install -y "${packages[@]}"
      ;;
    *)
      if [[ " ${ID_LIKE:-} " == *" debian "* ]]; then
        read_package_manifest "$repo_dir/packages/ubuntu.txt"
        as_root apt-get update
        as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
      elif [[ " ${ID_LIKE:-} " == *" rhel "* ]]; then
        read_package_manifest "$repo_dir/packages/rocky.txt"
        as_root dnf install -y epel-release
        as_root dnf install -y "${packages[@]}"
      else
        printf 'Unsupported Linux distribution: %s\n' "${PRETTY_NAME:-unknown}" >&2
        exit 1
      fi
      ;;
  esac
}

replace_command_link() {
  local command_name="$1"
  local target="$2"
  local link_path="/usr/local/bin/$command_name"

  if [[ -e "$link_path" && ! -L "$link_path" ]]; then
    as_root mv -- "$link_path" "${link_path}.before-dotfiles-$(date +%Y%m%d-%H%M%S)"
  fi
  as_root ln -sfn -- "$target" "$link_path"
}

install_neovim() {
  local nvim_version
  nvim_version="$(version_from_manifest neovim)"
  if [[ -z "$nvim_version" ]]; then
    printf 'Neovim version is missing from packages/versions.txt.\n' >&2
    exit 1
  fi
  if command -v nvim >/dev/null 2>&1 && [[ "$(nvim --version | head -n 1)" == "NVIM v${nvim_version}" ]]; then
    printf 'Neovim %s is already installed.\n' "$nvim_version"
    return
  fi
  if [[ "$(uname -m)" != "x86_64" ]]; then
    printf 'Pinned Neovim installation currently supports x86_64 only.\n' >&2
    exit 1
  fi

  local temp_dir archive prefix
  temp_dir="$(mktemp -d)"
  archive="$temp_dir/nvim.tar.gz"
  prefix="/opt/nvim-v${nvim_version}"
  curl --proto '=https' --tlsv1.2 -fL \
    "https://github.com/neovim/neovim/releases/download/v${nvim_version}/nvim-linux-x86_64.tar.gz" \
    -o "$archive"
  as_root install -d -m 0755 "$prefix"
  as_root tar -xzf "$archive" --strip-components=1 -C "$prefix"
  replace_command_link nvim "$prefix/bin/nvim"
  rm -rf -- "$temp_dir"
  printf 'Installed Neovim %s.\n' "$nvim_version"
}

install_node() {
  local node_version node_arch temp_dir archive prefix
  node_version="$(version_from_manifest node)"
  if [[ -z "$node_version" ]]; then
    printf 'Node.js version is missing from packages/versions.txt.\n' >&2
    exit 1
  fi
  if command -v node >/dev/null 2>&1 && [[ "$(node --version)" == "v${node_version}" ]]; then
    printf 'Node.js %s is already installed.\n' "$node_version"
    return
  fi

  case "$(uname -m)" in
    x86_64) node_arch="x64" ;;
    aarch64|arm64) node_arch="arm64" ;;
    *) printf 'Unsupported Node.js architecture: %s\n' "$(uname -m)" >&2; exit 1 ;;
  esac
  temp_dir="$(mktemp -d)"
  archive="$temp_dir/node.tar.xz"
  prefix="/opt/node-v${node_version}-linux-${node_arch}"
  curl --proto '=https' --tlsv1.2 -fL \
    "https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-${node_arch}.tar.xz" \
    -o "$archive"
  as_root install -d -m 0755 "$prefix"
  as_root tar -xJf "$archive" --strip-components=1 -C "$prefix"
  replace_command_link node "$prefix/bin/node"
  replace_command_link npm "$prefix/bin/npm"
  replace_command_link npx "$prefix/bin/npx"
  replace_command_link corepack "$prefix/bin/corepack"
  hash -r
  rm -rf -- "$temp_dir"
  printf 'Installed Node.js %s.\n' "$node_version"
}

install_uv() {
  local uv_version temp_dir archive platform
  uv_version="$(version_from_manifest uv)"
  if [[ -z "$uv_version" ]]; then
    printf 'uv version is missing from packages/versions.txt.\n' >&2
    exit 1
  fi
  if command -v uv >/dev/null 2>&1 && [[ "$(uv --version)" == "uv ${uv_version}"* ]]; then
    printf 'uv %s is already installed.\n' "$uv_version"
    return
  fi

  case "$(uname -m)" in
    x86_64) platform="x86_64-unknown-linux-gnu" ;;
    aarch64|arm64) platform="aarch64-unknown-linux-gnu" ;;
    *) printf 'Unsupported uv architecture: %s\n' "$(uname -m)" >&2; exit 1 ;;
  esac
  temp_dir="$(mktemp -d)"
  archive="$temp_dir/uv.tar.gz"
  curl --proto '=https' --tlsv1.2 -fL \
    "https://github.com/astral-sh/uv/releases/download/${uv_version}/uv-${platform}.tar.gz" \
    -o "$archive"
  tar -xzf "$archive" -C "$temp_dir"
  install -d -m 0755 "$HOME/.local/bin"
  install -m 0755 "$temp_dir/uv-${platform}/uv" "$HOME/.local/bin/uv"
  install -m 0755 "$temp_dir/uv-${platform}/uvx" "$HOME/.local/bin/uvx"
  hash -r
  rm -rf -- "$temp_dir"
  printf 'Installed uv %s.\n' "$uv_version"
}

install_codex() {
  local codex_version
  if [[ "$skip_codex" == true ]]; then
    return
  fi
  if command -v codex >/dev/null 2>&1; then
    printf 'Codex CLI is already installed.\n'
    return
  fi
  codex_version="$(version_from_manifest codex-cli)"
  if [[ -z "$codex_version" ]]; then
    printf 'Codex CLI version is missing from packages/versions.txt.\n' >&2
    exit 1
  fi
  npm install --global --prefix "$HOME/.local" "@openai/codex@${codex_version}"
  hash -r
}

ensure_fd_command() {
  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    install -d -m 0755 "$HOME/.local/bin"
    ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
}

install_nerd_font() {
  if [[ "${DOTFILES_SKIP_NERD_FONT:-false}" == true ]]; then
    return
  fi
  "${repo_dir}/install-nerdfont.sh"
}

install_packages() {
  install_distro_packages
  install_neovim
  install_node
  install_uv
  install_codex
  ensure_fd_command
  install_nerd_font
}

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

install_tmux_plugins() {
  local plugin_dir="$HOME/.tmux/plugins"
  local tpm_dir="$plugin_dir/tpm"

  if [[ ! -d "$tpm_dir/.git" ]]; then
    mkdir -p "$plugin_dir"
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
  fi
  TMUX_PLUGIN_MANAGER_PATH="$plugin_dir/" "$tpm_dir/bin/install_plugins"
}

if [[ "$skip_packages" == false ]]; then
  install_packages
fi

if [[ "$packages_only" == true ]]; then
  printf '\nPackages and command-line tools are installed.\n'
  exit 0
fi

link_config ".config/nvim"

if [[ "$nvim_only" == false ]]; then
  link_config ".tmux.conf"
  link_config ".bashrc"
  link_config ".bash_profile"
  link_config ".inputrc"
  link_config ".gitconfig"
  link_config ".codex/config.toml"
  install_tmux_plugins
fi

if [[ "$skip_sync" == false ]]; then
  if ! command -v nvim >/dev/null 2>&1; then
    printf 'Neovim is not installed. Re-run without --skip-packages.\n' >&2
    exit 1
  fi
  nvim --headless "+Lazy! sync" +qa
  mapfile -t mason_packages < <(sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' "$repo_dir/packages/mason.txt")
  if ((${#mason_packages[@]})); then
    nvim --headless -c "MasonInstall ${mason_packages[*]}" -c qall
  fi
fi

printf '\nDone. Start Neovim with: nvim\n'
