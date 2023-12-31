#!/bin/sh

echo 'This script remove these files.'
echo 'If you need, backup these files before running script.'
echo '~/.bashrc'
echo '~/.bash_logout'
echo '~/.fzf.bash'
echo '~/.bash_aliases'
echo ''

read -p "ok? (y/N): " yn
case $yn in
  [yY]* )
    break;;
  * ) 
    exit 1;;
esac

rm -f ~/.bashrc
ln -sf ~/dotfiles/bash/.bashrc ~/.bashrc
echo 'link .bashrc complete.'

rm -f ~/.bash_logout
ln -sf ~/dotfiles/bash/.bash_logout ~/.bash_logout
echo 'link .bash_logout complete.'

rm -f ~/.fzf.bash
ln -sf ~/dotfiles/bash/.fzf.bash ~/.fzf.bash
echo 'link .fzf.bash complete.'

rm -f ~/.bash_aliases
ln -sf ~/dotfiles/bash/.bash_aliases ~/.bash_aliases
echo 'link .bash_aliases complete.'
