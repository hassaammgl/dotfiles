if status is-interactive
    # Starship custom prompt
    starship init fish | source

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source

    # Better ls
    alias ls='eza --icons --group-directories-first -1'

    # Abbrs
    abbr lg 'lazygit'
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'

    abbr l 'ls'
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'

    # tmux
    abbr t 'tmux'
    abbr tn 'tmux new -s'
    abbr ta 'tmux attach -t'
    abbr tl 'tmux ls'

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/ratx86/miniconda3/bin/conda
    eval /home/ratx86/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/home/ratx86/miniconda3/etc/fish/conf.d/conda.fish"
        . "/home/ratx86/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/home/ratx86/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

