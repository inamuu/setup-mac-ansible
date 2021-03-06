
### Theme
# Source Prezto.
#if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
#  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
#fi

POWERLEVEL9K_MODE='nerdfont-complete'
source ~/.ghq/github.com/bhilburn/powerlevel9k/powerlevel9k.zsh-theme
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ssh dir vcs newline status)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

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

eval "$(nodenv init -)"
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

### custom variables
export USER=kazuma
export USERNAME=kazuma
export LANG=ja_JP.UTF-8

### ref: http://oomatomo.hatenablog.com/entry/36401841
setopt print_eight_bit   # 日本語ファイル名を表示可能にする
setopt correct           # コマンドのスペルを訂正する
setopt auto_cd           # ディレクトリ名のみ入力時、cdを適応させる
setopt no_beep           # ビープ音を鳴らさない
setopt nolistbeep        # 補完候補表示時にビープ音を鳴らさない
setopt auto_pushd        # cd実行時、ディレクトリスタックにpushされる
setopt pushd_ignore_dups # ディレクトリスタックに重複する物は古い方を削除
setopt list_packed       # 補完結果をできるだけ詰める

### flow_controlが効いているとpecosshが効かない
setopt no_flow_control

### 補完機能を有効にする
autoload -Uz compinit
compinit -u

### ref:http://mollifier.hatenablog.com/entry/20090728/p1
zshaddhistory() {
    local line=${1%%$'\n'} #コマンドライン全体から改行を除去したもの
    local cmd=${line%% *}  # １つ目のコマンド
    # 以下の条件をすべて満たすものだけをヒストリに追加する
    [[ ${#line} -ge 5
        && ${cmd} != (l|l[sal])
        && ${cmd} != (cd)
        && ${cmd} != (m|man)
        #&& ${cmd} != (r[mr])
        && ${cmd} != (terraform apply)
    ]]
}

### History
alias history="history 0"
setopt hist_reduce_blanks                  # 余分なスペースを削除してヒストリに保存する
setopt hist_find_no_dups                   # 履歴検索中、(連続してなくとも)重複を飛ばす
setopt hist_ignore_space                   # 行頭がスペースのコマンドは記録しない
setopt hist_ignore_all_dups                # ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_dups                    # 直前と同じコマンドは履歴に追加しない
setopt hist_no_store                       # histroyコマンドは記録しない
setopt share_history                       # 同時に起動したzshの間でヒストリを共有する
setopt inc_append_history                  # すぐにhistoryに書き込む

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
HIST_STAMPS="yyyy/mm/dd"
function history-all { history -E 1 }

function peco-history-selection() {
    #BUFFER=$(history | tail -r | awk '{$1="";print $0}' | egrep -v "ls" | uniq -u | sed 's/^ //g' | peco)
    BUFFER=`history | tail -r | awk '{$1="";print $0}' | egrep -v "ls" | uniq -u | sed 's/^ //g' | peco --layout bottom-up`
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
function pecossh () {
  local selected_host=$(awk '
  tolower($1)=="host" {
    for (i=2; i<=NF; i++) {
      if ($i !~ "[*?]") {
        print $i
      }
    }
  }
  # ~/.ssh/conf.d/*/config | sort | peco --query "$LBUFFER")
  ' ~/.ssh/conf.d/*/config | sort | peco --layout bottom-up --query "$LBUFFER")
  if [ -n "$selected_host" ]; then
    BUFFER="ssh ${selected_host}"
    zle accept-line
  fi
  zle clear-screen
}

zle -N pecossh
bindkey '^S' pecossh

### ctrl-wをスラッシュ区切り
# https://ikm.hatenablog.jp/entry/2014/07/31/213052

tcsh-backward-delete-word() {
  local WORDCHARS="${WORDCHARS:s#/#}"
    zle backward-delete-word
  }
zle -N tcsh-backward-delete-word
bindkey "^W" tcsh-backward-delete-word


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
alias c='clear'
alias date='/usr/local/bin/gdate'
alias sed='/usr/local/bin/gsed'

function chpwd() { ls -GAF }

### vim(brew install vim)
alias vi='/usr/local/bin/vim'
alias vim='/usr/local/bin/vim'

### tmux bug fix
alias ssh='TERM=xterm-256color ssh'

### git
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gc='git checkout'
alias gcp='git checkout $(git branch | peco | awk "{ print $NF }" )'
alias gcpeco='git branch | awk "{print \$(NF -0)}" | peco --layout bottom-up | xargs git checkout'
alias gd='git diff'
alias gl='git log -n 10 --oneline'
alias glog='git log'
alias gn='git now'
alias gr='git restore'
alias gs='git status'
alias gsw='git switch'
alias gcm='git commit'
alias gls='git ls-files --others --exclude-standard'
alias gpl='git pull'
alias gps='git push -u origin'
alias gpsf='git push -f -u origin'
alias gbrm="git branch | grep -v master | xargs -I % git branch -D % && git fetch --prune"
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
alias gh='ghq look $(ghq list | peco --layout bottom-up)'

#### Python
#alias py='python'
#alias pe='pyenv'
#export PATH="$PYENV_ROOT/bin:$PATH"
#eval "$(pyenv init -)"
#
#### Ruby
#PATH=~/.rbenv/shims:"$PATH"
#
#### Go
#export GOPATH=$HOME/.go
#export PATH=$PATH:$HOME/.go/bin

### docker
alias doc='docker'
alias docc='docker-compose'
alias dormi='do rmi -f $(do images | grep none | awk "{print $3}")'
alias -g P='$(docker ps | tail -n +2 | peco --layout bottom-up | cut -d" " -f1)'
alias -g PA='$(docker ps -a | tail -n +2 | peco --layout bottom-up | cut -d" " -f1)'
alias -g PI='$(docker images | tail -n +2 | peco --layout bottom-up | awk '\''{print $3}'\'')'

### gcloud
# The next line enables shell command completion for gcloud.
if [ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]; then source "${HOME}/google-cloud-sdk/completion.zsh.inc"; fi

### ESC Timeout
# http://lazy-dog.hatenablog.com/entry/2015/12/24/001648
KEYTIMEOUT=0

### Others
alias evc='envchain'

export PATH="/usr/local/sbin:$PATH"

### node
eval "$(anyenv init -)"

