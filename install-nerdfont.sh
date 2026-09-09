#!/usr/bin/env bash
set -euo pipefail

font_name="JetBrainsMono"
font_version="v3.4.0"
font_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/fonts/${font_name}NerdFont"
download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${font_version}/${font_name}.zip"
temp_dir="$(mktemp -d)"
trap 'rm -rf -- "$temp_dir"' EXIT

if find "$font_dir" -type f \( -iname '*.ttf' -o -iname '*.otf' \) -print -quit 2>/dev/null | grep -q .; then
  printf 'Already installed: %s Nerd Font (%s)\n' "$font_name" "$font_version"
  exit 0
fi

printf 'Installing %s Nerd Font (%s)\n' "$font_name" "$font_version"
mkdir -p "$font_dir"
curl --proto '=https' --tlsv1.2 -fL "$download_url" -o "$temp_dir/font.zip"
unzip -q -o "$temp_dir/font.zip" -d "$font_dir"
find "$font_dir" -type f ! \( -iname '*.ttf' -o -iname '*.otf' \) -delete

if command -v fc-cache >/dev/null 2>&1; then
  fc-cache -f "$font_dir"
fi
printf 'Installed fonts in %s\n' "$font_dir"
