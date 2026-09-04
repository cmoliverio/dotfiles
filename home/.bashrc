# Show the current Git branch, if inside a Git repository
git_branch() {
  git branch --show-current 2>/dev/null | sed 's/^/ (/; s/$/)/'
}

# Full path, colors, and optional Git branch
PS1='\[\e[1;32m\]\u@rocky8\[\e[0m\]:\[\e[1;34m\]$(pwd)\[\e[1;33m\]$(git_branch)\[\e[0m\]\n\[\e[1;36m\]\$ \[\e[0m\]'

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
