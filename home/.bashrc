# Rosé Pine Moon prompt. These indexed ANSI colours are mapped to the exact
# Rosé Pine RGB values by tmux, which can then mute them in inactive panes.
# Show the current Git branch, if inside a Git repository.
git_branch() {
  local branch
  branch="$(git branch --show-current 2>/dev/null)" || return
  [[ -n "$branch" ]] && printf ' (%s)' "$branch"
}

# Rosé Pine Moon: iris, text, muted, foam, pine, gold, love.
PS1='\[\e[38;5;183m\]╭─\[\e[38;5;189m\]\u\[\e[38;5;103m\]@\[\e[38;5;152m\]\h \[\e[38;5;31m\]\w\[\e[38;5;221m\]$(git_branch)\[\e[0m\]\n\[\e[38;5;183m\]╰─\[\e[38;5;204m\]\$\[\e[0m\] '

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
