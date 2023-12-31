# Setup fzf
# ---------
if [[ ! "$PATH" == */home/linuxbrew/.linuxbrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/linuxbrew/.linuxbrew/opt/fzf/bin"
fi

# Auto-completion
# ---------------
source "/home/linuxbrew/.linuxbrew/opt/fzf/shell/completion.bash"

# Key bindings
# ------------
source "/home/linuxbrew/.linuxbrew/opt/fzf/shell/key-bindings.bash"
