#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

alias history="history 0"

# Customize to your needs...
# Path to your oh-my-zsh installation.
#export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="robbyrussell"
#ZSH_THEME="agnoster"
#ZSH_THEME="inamuu"
#ZSH_THEME="apple"
#ZSH_THEME="powerline"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy/mm/dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#plugins=(git ruby osx bundler brew rails emoji-clock vagrant)

# User configuration

export PATH=$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

#source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export LANG=ja_JP.UTF-8
setopt print_eight_bit
setopt auto_cd
setopt no_beep
setopt nolistbeep
setopt auto_pushd
setopt pushd_ignore_dups
setopt hist_ignore_dups     # 前と重複する行は記録しない
setopt share_history        # 同時に起動したzshの間でヒストリを共有する
setopt hist_reduce_blanks   # 余分なスペースを削除してヒストリに保存する
setopt HIST_IGNORE_SPACE    # 行頭がスペースのコマンドは記録しない
setopt HIST_IGNORE_ALL_DUPS # 履歴中の重複行をファイル記録前に無くす
setopt HIST_FIND_NO_DUPS    # 履歴検索中、(連続してなくとも)重複を飛ばす
setopt HIST_NO_STORE        # histroyコマンドは記録しない
# http://mollifier.hatenablog.com/entry/20090728/p1
zshaddhistory() {
    local line=${1%%$'\n'} #コマンドライン全体から改行を除去したもの
    local cmd=${line%% *}  # １つ目のコマンド
    # 以下の条件をすべて満たすものだけをヒストリに追加する
    [[ ${#line} -ge 5
        && ${cmd} != (l|l[sal])
        && ${cmd} != (cd)
        && ${cmd} != (m|man)
        && ${cmd} != (r[mr])
        && ${cmd} != (terraform apply)
    ]]
}

 
autoload -Uz compinit
compinit -u

### History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
function history-all { history -E 1 }
setopt hist_ignore_dups


### powerline theme
#POWERLINE_HIDE_HOST_NAME="true"
#POWERLINE_SHORT_HOST_NAME="true"
#POWERLINE_HIDE_USER_NAME="true"
#POWERLINE_HIDE_GIT_PROMPT_STATUS="true"

### brew 
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

### peco&ssh
function peco-ssh () {
  local selected_host=$(awk '
  tolower($1)=="host" {
    for (i=2; i<=NF; i++) {
      if ($i !~ "[*?]") {
        print $i
      }
    }
  }
  ' ~/.ssh/config | sort | peco --query "$LBUFFER")
  if [ -n "$selected_host" ]; then
    BUFFER="ssh -A ${selected_host}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-ssh
bindkey '^S' peco-ssh


### history
function peco-history-selection() {
    #BUFFER=`history | tail -r | awk '{$1="";print $0}' | peco`
    BUFFER=`history | tail -r | awk '{$1="";print $0}' | egrep -v "ls" | uniq -u | sed 's/^ //g' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N peco-history-selection
bindkey '^R' peco-history-selection

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

source ~/.iterm2_shell_integration.`basename $SHELL`

iterm2_print_user_vars() {
    iterm2_set_user_var gitBranch $((git branch 2> /dev/null) | grep \* | cut -c3-)
}


### direnv
eval "$(direnv hook zsh)"

### shell command
alias ls='ls -laG'
alias ll='ls -laG'
alias rm='rm -vi'
alias mv='mv -vi'
alias cp='cp -vi'
alias ..='cd ..'
alias vi='vim'
alias c='clear'

function chpwd() { ls -GAF }

### tmux bug fix
alias ssh='TERM=xterm ssh'

### git
alias g='git'
alias gs='git status'
alias gb='git branch'
alias gc='git checkout'
alias gcm='git commit'
alias gd='git diff'
alias gl='git log'
alias ga='git add'
alias gpl='git pull'
alias gps='git push -u origin'
alias gpsf='git push -f -u origin'

### Start tmux
[[ -z "$TMUX" && ! -z "$PS1" ]] && tmux

### bundle
alias be='bundle exec'
alias ber='bundle exec rake'

### hub
alias gh='cd $(ghq root)/$(ghq list | peco)'

### Python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

### Ruby
PATH=~/.rbenv/shims:"$PATH"

### Go
export GOPATH=$HOME
export PATH=$PATH:$GOPATH/bin

### vagrant
alias vag='vagrant'
alias vagg='vagrant global-status'
alias vagu='vagrant up'
alias vagh='vagrant halt'
alias vags='vagrant ssh'

### docker
alias do='docker'
alias doc='docker-compose'

### gcloud
# The next line enables shell command completion for gcloud.
if [ -f '/home/usr0600421/google-cloud-sdk/completion.zsh.inc' ]; then source '/home/usr0600421/google-cloud-sdk/completion.zsh.inc'; fi

### ESC Timeout
# http://lazy-dog.hatenablog.com/entry/2015/12/24/001648
KEYTIMEOUT=0

### Others
alias evc='envchain'

