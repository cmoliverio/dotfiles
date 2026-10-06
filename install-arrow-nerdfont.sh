#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
font_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/fonts/JetBrainsMonoNerdFont"
build_dir=$(mktemp -d)
trap 'rm -rf -- "$build_dir"' EXIT

styles=(Regular Bold Italic BoldItalic)
missing_source=false
for style in "${styles[@]}"; do
  source_font="${font_dir}/JetBrainsMonoNerdFont-${style}.ttf"
  if [[ ! -f "$source_font" ]]; then
    missing_source=true
    break
  fi
done

if [[ "$missing_source" == true ]]; then
  "${repo_dir}/install-nerdfont.sh"
fi

for style in "${styles[@]}"; do
  source_font="${font_dir}/JetBrainsMonoNerdFont-${style}.ttf"
  uv run --with fonttools==4.66.1 python \
    "${repo_dir}/customize-arrow-ligatures.py" "$source_font" "$build_dir"
done

windows_build_dir=$(wslpath -w "$build_dir")
windows_installer=$(wslpath -w "${repo_dir}/install-arrow-nerdfont.ps1")
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$windows_installer" \
  -SourceDirectory "$windows_build_dir"

windows_settings_installer=$(wslpath -w \
  "${repo_dir}/restore-windows-terminal.ps1")
powershell.exe -NoProfile -ExecutionPolicy Bypass \
  -File "$windows_settings_installer"
