# Click to open files in the existing nvim pane (tmux or herdr).
#
# iTerm's Semantic History runs bin/tmux-nvim-click.sh directly, so nothing is
# typed into the clicked pane any more -- this is just a shell-side shortcut for
# the same thing. The old version typed `tmux_nvim_open ...` into the focused
# pane and then scrubbed it back out of ~/.zsh_history; both are gone.
tmux_nvim_open() {
    tmux-nvim-click.sh "$1" "${2:-1}"
}
