# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

#export ZSH=$HOME/.oh-my-zsh
#ZSH_THEME="robbyrussell"
#ZSH_THEME="agnoster"
#ZSH_THEME="inamuu"
#ZSH_THEME="apple"
#ZSH_THEME="powerline"
# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"
# DISABLE_AUTO_UPDATE="true"
# export UPDATE_ZSH_DAYS=13
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
# ENABLE_CORRECTION="true"
# COMPLETION_WAITING_DOTS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
# User configuration

export PATH=$HOME/bin:/usr/local/bin:$HOME/.nodebrew/current/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"
#source $ZSH/oh-my-zsh.sh
# export LANG=en_US.UTF-8

# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
# export ARCHFLAGS="-arch x86_64"
# export SSH_KEY_PATH="~/.ssh/dsa_id"
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

### cutom variables
export USER=inamuu
export USERNAME=inamuu

export LANG=ja_JP.UTF-8
setopt print_eight_bit
setopt auto_cd
setopt no_beep
setopt nolistbeep
setopt auto_pushd
setopt pushd_ignore_dups

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
alias history="history 0"
setopt hist_ignore_dups                    # 前と重複する行は記録しない
setopt share_history                       # 同時に起動したzshの間でヒストリを共有する
setopt hist_reduce_blanks                  # 余分なスペースを削除してヒストリに保存する
setopt HIST_IGNORE_SPACE                   # 行頭がスペースのコマンドは記録しない
setopt HIST_IGNORE_ALL_DUPS                # 履歴中の重複行をファイル記録前に無くす
setopt HIST_FIND_NO_DUPS                   # 履歴検索中、(連続してなくとも)重複を飛ばす
setopt HIST_NO_STORE                       # histroyコマンドは記録しない
setopt inc_append_history hist_ignore_dups # すぐにhistoryに書き込む
setopt hist_ignore_all_dups                # ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
HIST_STAMPS="yyyy/mm/dd"
function history-all { history -E 1 }

function peco-history-selection() {
    #BUFFER=`history | tail -r | awk '{$1="";print $0}' | peco`
    BUFFER=`history | tail -r | awk '{$1="";print $0}' | egrep -v "ls" | uniq -u | sed 's/^ //g' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N peco-history-selection
bindkey '^R' peco-history-selection


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
  ' ~/.ssh/conf.d/*/config | sort | peco --query "$LBUFFER")
  if [ -n "$selected_host" ]; then
    BUFFER="ssh -A ${selected_host}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-ssh
bindkey '^S' peco-ssh

### iTerm
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

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
alias date='/usr/local/bin/gdate'
alias sed='/usr/local/bin/gsed'

function chpwd() { ls -GAF }

### tmux bug fix
alias ssh='TERM=xterm ssh'

### git
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gc='git checkout'
alias gcp='git checkout $(git branch | peco | awk "{ print $NF }" )'
alias gd='git diff'
alias gl='git log'
alias gn='git now'
alias gs='git status'
alias gcm='git commit'
alias gls='git ls-files --others --exclude-standard'
alias gpl='git pull'
alias gps='git push -u origin'
alias gpsf='git push -f -u origin'
alias gbrm="git branch --merged | grep -vE '^\*|master$|develop$' | xargs -I % git branch -d %"
alias github='cd ~/Github'

### tig
alias t='tig'
alias ta='tig --all'

### tmux
[[ -z "$TMUX" && ! -z "$PS1" ]] && tmux

alias tm='tmux'
alias tmk='tmux kill-server'

### bundle
alias be='bundle exec'
alias ber='bundle exec rake'

### ghq
alias gh='ghq look $(ghq list | peco)'

### Python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

### Ruby
PATH=~/.rbenv/shims:"$PATH"

### Go
export GOPATH=$HOME
export PATH=$PATH:$GOPATH/bin

### docker
alias do='docker'
alias doc='docker-compose'
alias dopsn='docker ps | awk "{print $NF}" | tail +2'

### gcloud
# The next line enables shell command completion for gcloud.
if [ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]; then source "${HOME}/google-cloud-sdk/completion.zsh.inc"; fi

### ESC Timeout
# http://lazy-dog.hatenablog.com/entry/2015/12/24/001648
KEYTIMEOUT=0

### Others
alias evc='envchain'

