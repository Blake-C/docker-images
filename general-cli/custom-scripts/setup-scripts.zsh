#!/bin/bash

# Aliases
alias ll="ls -lagh"
alias wp="wp --allow-root"
alias bower="bower --allow-root"
alias rm="rm -i"
alias npmg="npm list -g --depth=0"

# NVM Load Script
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
