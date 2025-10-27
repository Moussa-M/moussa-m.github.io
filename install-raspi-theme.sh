#!/usr/bin/env bash
# ------------------------------------------------------------------
# Install Raspi Zsh Theme — clean, always-commented-output version
# ------------------------------------------------------------------

set -e

THEME_DIR="$HOME/.oh-my-zsh/custom/themes"
THEME_FILE="$THEME_DIR/raspi.zsh-theme"

echo "📦 Installing Raspi Zsh Theme..."
mkdir -p "$THEME_DIR"

cat > "$THEME_FILE" <<"EOF"
# raspi.zsh-theme — permanent commented-output prompt

export VIRTUAL_ENV_DISABLE_PROMPT=1
export CONDA_CHANGEPS1=false
setopt PROMPT_SUBST

conda_info() { [ -n "$CONDA_DEFAULT_ENV" ] && echo "($CONDA_DEFAULT_ENV)"; }
virtualenv_info() { [ -n "$VIRTUAL_ENV" ] && echo "($(basename "$VIRTUAL_ENV"))"; }
box_name() { echo "${SHORT_HOST:-$HOST}"; }
local_ip() { ip route get 1.1.1.1 2>/dev/null | awk '/src/ {print $7; exit}'; }

# clear screen once on startup
if [ -z "$__RASPI_PROMPT_INIT" ]; then
  clear
  export __RASPI_PROMPT_INIT=1
fi

# two-line prompt - first line commented, second line clean for commands
# Cursor: blinking block in raspberry pink
echo -ne '\e[1 q\e]12;#ff0087\a'
PROMPT=$'# %F{198}%n%f@%F{39}$(box_name)%f %F{48}[$(local_ip)]%f %F{39}%~%f %F{244}$(conda_info)%f %F{244}$(virtualenv_info)%f\n'

# Prefix all command output with "# "
preexec() {
  if [ -z "$SSH_TTY" ]; then
    # Local interactive session — enable commented output
    exec 3>&1 4>&2
    exec > >(sed 's/^/# /') 2>&1
  else
    # SSH session — keep normal stdout/stderr
    :
  fi
}

precmd() {
  { true >&3; } 2>/dev/null && exec 1>&3 3>&- || true
  { true >&4; } 2>/dev/null && exec 2>&4 4>&- || true
}

RPROMPT=""
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
EOF

echo "✅ Theme written to $THEME_FILE"

# Update .zshrc to use raspi theme
if ! grep -q 'ZSH_THEME="raspi"' "$HOME/.zshrc" 2>/dev/null; then
  echo 'Updating ~/.zshrc to use raspi theme...'
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="raspi"/' "$HOME/.zshrc" 2>/dev/null \
    || echo 'ZSH_THEME="raspi"' >> "$HOME/.zshrc"
fi

echo "✨ Installation complete."
echo "➡️  Run:  source ~/.zshrc"
