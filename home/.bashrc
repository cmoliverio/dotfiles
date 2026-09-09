# Rosé Pine Moon prompt.  These are RGB escape sequences, so they work both
# directly in Windows Terminal and through tmux with true-color enabled.
# Show the current Git branch, if inside a Git repository.
git_branch() {
  local branch
  branch="$(git branch --show-current 2>/dev/null)" || return
  [[ -n "$branch" ]] && printf ' (%s)' "$branch"
}

# Rosé Pine Moon: iris, text, muted, foam, pine, gold, love.
PS1='\[\e[38;2;196;167;231m\]╭─\[\e[38;2;224;222;244m\]\u\[\e[38;2;144;140;170m\]@\[\e[38;2;156;207;216m\]\h \[\e[38;2;62;143;176m\]\w\[\e[38;2;246;193;119m\]$(git_branch)\[\e[0m\]\n\[\e[38;2;196;167;231m\]╰─\[\e[38;2;235;111;146m\]\$\[\e[0m\] '

alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'

# >>> Codex installer >>>
export PATH="$HOME/.local/bin:$PATH"
# <<< Codex installer <<<
#
#
