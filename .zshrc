# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi
export EDITOR="nvim"

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias ls='eza'
alias l='eza -lbF --git'
alias ll='eza -lbGF --git'
alias la='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale'
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale'

alias f='fuck'
alias v='nvim'
alias lg='lazygit'
alias y='yazi'

# React Native — full clean (node_modules + pods + xcode env + watchman + metro)
alias rnfullclean='rm -rf node_modules ios/Pods && yarn && watchman watch-del-all && z ios && pod install --repo-update && rm -rf .xcode.env.local && z ..'

eval $(thefuck --alias)
eval "$(zoxide init zsh)"

export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

export PATH="/opt/homebrew/opt/dotnet@8/bin:$PATH"

source <(fzf --zsh)
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--color=border:#313244,label:#cdd6f4"
source /Users/gennadiyfurduy/.config/op/plugins.sh

# ─── Runtime manager (mise) ───────────────────────────────
# Handles Node + Python + Ruby + Java. Reads .tool-versions, .nvmrc,
# .ruby-version, .python-version automatically on cd.
eval "$(mise activate zsh)"

# End of Docker CLI completions
export PATH="$HOME/.local/bin:$HOME/worldbanc/private/bin:$PATH"


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/gennadiyfurduy/.opam/opam-init/init.zsh' ]] || source '/Users/gennadiyfurduy/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration
#

# Claude Code launcher
ccd() {
  local env_vars=(
    GH_TOKEN="$(op read 'op://Personal/GitHub Personal Access Token DominusDeMachina/token')"
  )

  unalias gh 2>/dev/null
  env "${env_vars[@]}" command claude --dangerously-skip-permissions "$@"
}

brew() {
  command brew "$@"
  if [[ "$1" == "install" || "$1" == "uninstall" || "$1" == "tap" ]]; then
    brew bundle dump --force --file=~/Brewfile
  fi
}

# ─── Completion ───────────────────────────────────────────
autoload -Uz compinit && compinit

# Стиль меню при Tab
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case-insensitive

# ─── History ──────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY          # история между сессиями
setopt HIST_IGNORE_SPACE      # не сохранять команды с пробелом в начале

# ─── Plugins ──────────────────────────────────────────────
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Цвет подсказки autosuggestions (серый)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

eval "$(starship init zsh)"
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
