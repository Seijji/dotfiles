# ~/.zshrc
# ============================================================================
# Dependencies
# ============================================================================
# Required:
#   - antidote: zsh plugin manager (https://getantidote.github.io/)
#     Install: git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
#   - ~/.zsh_plugins.txt with:
#       zsh-users/zsh-completions
#       zsh-users/zsh-syntax-highlighting
#       zsh-users/zsh-autosuggestions
#       Aloxaf/fzf-tab
#
# Optional (enhances functionality):
#   - fzf: fuzzy finder (sudo dnf install fzf)
#   - zoxide: smart directory jumping (sudo dnf install zoxide)
#   - bat: syntax highlighting for files (sudo dnf install bat)
#   - ripgrep: fast text search (sudo dnf install ripgrep)
#   - fd-find: faster file finder (sudo dnf install fd-find)
#   - starship: prompt (already configured below)

# ============================================================================
# Antidote Plugin Manager
# ============================================================================
source ~/.antidote/antidote.zsh
antidote load

# ============================================================================
# Completion System
# ============================================================================
# Note: zsh-completions must be in fpath BEFORE compinit runs
# This should be handled by antidote, but verify with: echo $fpath

autoload -Uz compinit
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
  compinit -i
else
  compinit -C -i
fi

# Completion behavior
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # case-insensitive matching
zstyle ':completion:*:approximate:*' max-errors 2 numeric

# ============================================================================
# fzf Configuration
# ============================================================================
# Keybindings provided by fzf:
#   Ctrl+R: Search command history with fuzzy matching
#   Ctrl+T: Search files in current directory tree
#   Alt+C:  Change directory with fuzzy matching
if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)"

    # fzf options
    export FZF_DEFAULT_OPTS='
        --height 40%
        --layout=reverse
        --border
        --info=inline
        --bind=ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down
    '

    # Additional bindings in preview window:
    #   Ctrl+U: Scroll preview up half page
    #   Ctrl+D: Scroll preview down half page

    # Use fd if available (faster than find)
    if command -v fd &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi

    # Preview files with bat
    if command -v bat &> /dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
    fi
fi

# zoxide (works better with fzf)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'  # optional: replace cd with z
fi

# ============================================================================
# History Configuration
# ============================================================================
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt inc_append_history
setopt share_history

# ============================================================================
# Shell Options
# ============================================================================
setopt autocd
setopt extendedglob
setopt correct              # correct commands only, not arguments
setopt always_to_end

bindkey -e  # emacs keybindings

# ============================================================================
# Prompt
# ============================================================================
eval "$(starship init zsh)"

# ============================================================================
# Aliases
# ============================================================================
alias dotfiles='/usr/bin/git --git-dir=/home/seeji/.dotfiles/ --work-tree=/home/seeji'

alias cat='bat'  # syntax highlighting for viewing files
alias rg='rg --smart-case'  # case-insensitive unless uppercase present

# Safety nets
alias rm='rm -I'  # prompt before deleting >3 files
alias cp='cp -i'  # prompt before overwrite
alias mv='mv -i'  # prompt before overwrite

# ============================================================================
# Functions
# ============================================================================
# Search in files (using ripgrep)
search() { rg -i "$1" . ; }

# Create and enter directory
mkcd() { mkdir -p "$1" && cd "$1"; }
