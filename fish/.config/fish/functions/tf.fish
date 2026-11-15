function tf --description "Fuzzy search tldr pages with fzf"
    set -l cmd (tldr --list 2>/dev/null | fzf \
        --prompt='tldr> ' \
        --height=90% \
        --layout=reverse \
        --border \
        --preview='tldr --color {} 2>&1' \
        --preview-window='right:65%:wrap' \
        --bind='ctrl-/:toggle-preview' \
        --bind='ctrl-y:execute-silent(printf "%s" {} | wl-copy 2>/dev/null)+accept')
    or return 0

    test -z "$cmd"; and return 0
    tldr $cmd
end
