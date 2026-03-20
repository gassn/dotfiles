# ~/.bash_profile: executed by bash(1) for login shells.

# Init linuxbrew.
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# PATH settings.
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Source .bashrc for interactive settings.
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
