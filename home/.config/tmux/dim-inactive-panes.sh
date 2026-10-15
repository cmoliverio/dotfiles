#!/usr/bin/env bash

# Give inactive panes a gently subdued ANSI palette. tmux 3.7c only lets
# window-style replace the default foreground, so explicitly coloured shell
# output needs a pane palette as well.

target_window=${1:-}

if [[ -n $target_window ]]; then
  list_panes=(tmux list-panes -t "$target_window")
else
  list_panes=(tmux list-panes)
fi

while IFS=' ' read -r pane_id pane_active; do
  [[ -n $pane_id ]] || continue

  if [[ $pane_active == 1 ]]; then
    # Restore the normal palette, then map the prompt's indexed colours back
    # to its exact Rosé Pine Moon RGB values.
    tmux set-option -p -u -t "$pane_id" pane-colours 2>/dev/null || true
    tmux \
      set-option -p -t "$pane_id" 'pane-colours[183]' '#c4a7e7' \; \
      set-option -p -t "$pane_id" 'pane-colours[189]' '#e0def4' \; \
      set-option -p -t "$pane_id" 'pane-colours[103]' '#908caa' \; \
      set-option -p -t "$pane_id" 'pane-colours[152]' '#9ccfd8' \; \
      set-option -p -t "$pane_id" 'pane-colours[31]'  '#3e8fb0' \; \
      set-option -p -t "$pane_id" 'pane-colours[221]' '#f6c177' \; \
      set-option -p -t "$pane_id" 'pane-colours[204]' '#eb6f92'
    continue
  fi

  # Rosé Pine Moon colours, lifted 30% from the old cool-slate dim palette
  # toward their normal values. The focus distinction remains, but inactive
  # pane content is easier to read.
  tmux \
    set-option -p -t "$pane_id" 'pane-colours[0]'  '#2b2e3d' \; \
    set-option -p -t "$pane_id" 'pane-colours[1]'  '#ad5c77' \; \
    set-option -p -t "$pane_id" 'pane-colours[2]'  '#6b8a86' \; \
    set-option -p -t "$pane_id" 'pane-colours[3]'  '#9c8662' \; \
    set-option -p -t "$pane_id" 'pane-colours[4]'  '#4c738c' \; \
    set-option -p -t "$pane_id" 'pane-colours[5]'  '#867296' \; \
    set-option -p -t "$pane_id" 'pane-colours[6]'  '#688c91' \; \
    set-option -p -t "$pane_id" 'pane-colours[7]'  '#aca8c7' \; \
    set-option -p -t "$pane_id" 'pane-colours[8]'  '#52596b' \; \
    set-option -p -t "$pane_id" 'pane-colours[9]'  '#be6685' \; \
    set-option -p -t "$pane_id" 'pane-colours[10]' '#7ea498' \; \
    set-option -p -t "$pane_id" 'pane-colours[11]' '#a38d68' \; \
    set-option -p -t "$pane_id" 'pane-colours[12]' '#537b95' \; \
    set-option -p -t "$pane_id" 'pane-colours[13]' '#8e789e' \; \
    set-option -p -t "$pane_id" 'pane-colours[14]' '#6f949a' \; \
    set-option -p -t "$pane_id" 'pane-colours[15]' '#aca8c7' \; \
    set-option -p -t "$pane_id" 'pane-colours[183]' '#8e789e' \; \
    set-option -p -t "$pane_id" 'pane-colours[189]' '#aca8c7' \; \
    set-option -p -t "$pane_id" 'pane-colours[103]' '#52596b' \; \
    set-option -p -t "$pane_id" 'pane-colours[152]' '#6f949a' \; \
    set-option -p -t "$pane_id" 'pane-colours[31]'  '#4c738c' \; \
    set-option -p -t "$pane_id" 'pane-colours[221]' '#a38d68' \; \
    set-option -p -t "$pane_id" 'pane-colours[204]' '#be6685'
done < <("${list_panes[@]}" -F '#{pane_id} #{pane_active}' 2>/dev/null)
