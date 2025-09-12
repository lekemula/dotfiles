# Click to open files in existing nvim tmux window
# https://gist.github.com/chrismccord/5b67b6a70c21582c01b0f00a669b50d3
clean_nvim_open_history() {
    # Write current history to file
    fc -W
    
    # Check if last line contains tmux_nvim_open
    if tail -1 ~/.zsh_history | grep -q "tmux_nvim_open "; then
        # Remove last line
        sed -i '' '$d' ~/.zsh_history
        
        # Check for 'q' - zsh history format includes timestamp like ": 1234567890:0;q"
        if tail -1 ~/.zsh_history | grep -qE "(^|;)q$"; then
            # Remove that too
            sed -i '' '$d' ~/.zsh_history
        fi
    fi
    
    # Reload history
    fc -R
}

# Updated tmux_nvim_open function
tmux_nvim_open() {
    clean_nvim_open_history
    local file="$1"
    local line="${2:-1}"

    # First try to find nvim panes in the current window
    local current_window=$(tmux display-message -p '#I')
    local nvim_pane=$(tmux list-panes -F '#{window_index}.#{pane_index}:#{pane_current_command}' | grep -i "^${current_window}\." | grep -i ':nvim$' | head -1 | cut -d: -f1)

    # Find any window running nvim if no pane found
    local nvim_window=$(tmux list-windows -F '#{window_index}: #{window_name}' | grep -i 'nvim' | head -1 | cut -d: -f1)

    if [ -n "$nvim_pane" ]; then
        # Extract window and pane indices
        local window_idx=$(echo $nvim_pane | cut -d. -f1)
        local pane_idx=$(echo $nvim_pane | cut -d. -f2)

        # Select the window and pane containing nvim
        tmux select-window -t "$window_idx"
        tmux select-pane -t "$pane_idx"

        # Send commands to nvim
        tmux send-keys -t "$nvim_pane" Escape ":e $file" C-m "${line}G"
    elif [ -n "$nvim_window" ]; then
        tmux select-window -t "$nvim_window"
        tmux send-keys -t "${nvim_window}.0" Escape ":e $file" C-m "${line}G"
    else
        # No nvim instance found, create a new window with nvim
        tmux new-window "nvim '$file' +$line"
    fi
    clean_nvim_open_history
}
