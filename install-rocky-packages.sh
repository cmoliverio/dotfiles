#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
nvim_version="v0.11.5"

if [[ ! -r /etc/os-release ]]; then
  printf 'Cannot identify this Linux distribution.\n' >&2
  exit 1
fi
. /etc/os-release
if [[ "${ID:-}" != "rocky" && "${ID_LIKE:-}" != *rhel* ]]; then
  printf 'This installer targets Rocky/RHEL-like systems; found %s.\n' "${PRETTY_NAME:-unknown}" >&2
  exit 1
fi

mapfile -t packages < <(sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' "$repo_dir/packages/rocky.txt")
sudo dnf install -y epel-release
sudo dnf module enable -y nodejs:20
sudo dnf install -y "${packages[@]}"

if ! command -v nvim >/dev/null 2>&1 || [[ "$(nvim --version | head -n 1)" != "NVIM ${nvim_version}" ]]; then
  temp_dir="$(mktemp -d)"
  trap 'rm -rf -- "$temp_dir"' EXIT
  archive="$temp_dir/nvim.tar.gz"
  curl --proto '=https' --tlsv1.2 -fL \
    "https://github.com/neovim/neovim/releases/download/${nvim_version}/nvim-linux-x86_64.tar.gz" \
    -o "$archive"
  tar -xzf "$archive" -C "$temp_dir"
  sudo mkdir -p "/opt/nvim-${nvim_version}"
  sudo cp -a "$temp_dir/nvim-linux-x86_64/." "/opt/nvim-${nvim_version}/"
  if [[ -e /usr/local/bin/nvim && ! -L /usr/local/bin/nvim ]]; then
    sudo mv /usr/local/bin/nvim "/usr/local/bin/nvim.before-dotfiles-$(date +%Y%m%d-%H%M%S)"
  fi
  sudo ln -sfn "/opt/nvim-${nvim_version}/bin/nvim" /usr/local/bin/nvim
fi

printf 'Packages installed. Run ./bootstrap.sh next.\n'
