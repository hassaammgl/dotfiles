###########
# EZA (better ls)
###########

alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias la='eza -a --icons'
alias lt='eza --tree --level=2 --icons'
alias l='eza -1'

###########
# BAT (better cat)
###########

alias cat='bat'

###########
# FZF
###########

alias f='fzf'
alias ff='fzf --preview "bat --color=always {}"'

###########
# FZF + TLDR (fuzzy cheatsheets)
###########

# tf            -> pick a command, preview its tldr page, Enter prints it
# tldr (no arg) -> same as tf; tldr <cmd> still works as usual
tf() {
    local cmd
    cmd=$(tldr --list 2>/dev/null | fzf \
        --prompt='tldr> ' \
        --height=90% \
        --layout=reverse \
        --border \
        --preview='tldr --color {} 2>&1' \
        --preview-window='right:65%:wrap' \
        --bind='ctrl-/:toggle-preview' \
        --bind='ctrl-y:execute-silent(printf "%s" {} | wl-copy 2>/dev/null)+accept') \
        || return 0
    [ -n "$cmd" ] && tldr "$cmd"
}

tldr() {
    if [ "$#" -eq 0 ]; then
        tf
    else
        command tldr "$@"
    fi
}

###########
# TMUX
###########

alias t='tmux'
alias tn='tmux new -s'
alias ta='tmux attach -t'
alias tl='tmux ls'

###########
# ZOXIDE (smart cd)
###########

alias cd='z'
alias cdi='z -i'

###########
# FD + RIPGREP
###########

alias find='fd'
alias grep='rg'

###########
# GIT POWER ALIASES
###########

alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gsw='git switch'

###########
# C / C++ FORMATTING (clang-format)
###########

# cppstyle [preset]  -> create .clang-format from a clang preset (default: LLVM)
# cppstyle-global     -> copy ~/.clang-format (dotfiles style) into this project
# clangfmt            -> format every C/C++ file in the project
# clangfmt-check      -> dry-run, lists files that are not formatted
cppstyle() {
    local preset="${1:-LLVM}"
    if [ -e .clang-format ]; then
        echo ".clang-format already exists here ($(pwd))"
        return 1
    fi
    clang-format --style="$preset" --dump-config > .clang-format || return 1
    echo "created .clang-format (style: $preset)"
}

cppstyle-global() {
    if [ ! -f "$HOME/.clang-format" ]; then
        echo "no $HOME/.clang-format (stow the clang-format package in ~/dotfiles)"
        return 1
    fi
    if [ -e .clang-format ]; then
        echo ".clang-format already exists here ($(pwd))"
        return 1
    fi
    cp "$HOME/.clang-format" .clang-format
    echo "created .clang-format from $HOME/.clang-format"
}

# `command find`: the `find` alias (fd) with these arguments.
_clang_sources() {
    command find . \( -name '*.c' -o -name '*.cc' -o -name '*.cpp' -o -name '*.cxx' \
        -o -name '*.h' -o -name '*.hh' -o -name '*.hpp' -o -name '*.hxx' \
        -o -name '*.ixx' -o -name '*.cppm' -o -name '*.mpp' \) \
        -not -path './build/*' -not -path './.git/*' -not -path './.cache/*' -print0
}

clangfmt() {
    _clang_sources | xargs -0 -r clang-format -i
}

clangfmt-check() {
    _clang_sources | xargs -0 -r clang-format --dry-run --Werror
}

###########
# DOCKER SHORTCUTS
###########

alias d='docker'
alias dps='docker ps'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dcu='docker compose up -d'
alias dcd='docker compose down'

###########
# SYSTEM
###########

alias update='sudo pacman -Syu'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias neofetch='fastfetch'


source /usr/share/fzf/key-bindings.bash
source /usr/share/fzf/completion.bash
