#!/bin/bash

# Aliases
alias ll="ls -lagh"
alias wp="wp --allow-root"
alias bower="bower --allow-root"
alias rm="rm -i"
alias npmg="npm list -g --depth=0"

# PHPCS
alias phpcs_="phpcs --standard=./phpcs.xml --colors"

# aliases for Tmux
alias t='tmux -2'
alias ta='tmux attach -t'
alias td='tmux detach'
alias tnew='tmux new -s'
alias tls='tmux ls'
alias tkill='tmux kill-session -t'

# convenience aliases for editing configs
alias ev='vim ~/.config/nvim/init.vim'
alias et='vim ~/.tmux.conf'
alias ez='vim ~/.zshrc'

# make sure that if a program wants you to edit
# text, that Vim is going to be there for you
export EDITOR="vim"
export USE_EDITOR=$EDITOR
export VISUAL=$EDITOR

# NVM Load Script
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
