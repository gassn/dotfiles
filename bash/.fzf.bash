# Setup fzf
# ---------
FZF_PREFIX="$(brew --prefix fzf 2>/dev/null)"
if [[ -n "$FZF_PREFIX" ]]; then
  if [[ ! "$PATH" == *"$FZF_PREFIX/bin"* ]]; then
    PATH="${PATH:+${PATH}:}$FZF_PREFIX/bin"
  fi

  # Auto-completion
  [[ -f "$FZF_PREFIX/shell/completion.bash" ]] && source "$FZF_PREFIX/shell/completion.bash"

  # Key bindings
  [[ -f "$FZF_PREFIX/shell/key-bindings.bash" ]] && source "$FZF_PREFIX/shell/key-bindings.bash"
fi
