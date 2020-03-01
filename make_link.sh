#!/bin/sh

mv ~/.bashrc ~/.bashrc.bk
ln -sf ~/dotfiles/bash/.bashrc ~/.bashrc
mv ~/.profile ~/.profile.bk
ln -sf ~/dotfiles/bash/.profile ~/.profile
mv ~/.bash_logout ~/.bash_logout.bk
ln -sf ~/dotfiles/bash/.bash_logout ~/.bash_logout
mv ~/.zshrc ~/.zshrc.bk
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
mv ~/.config/Code/User/keybindings.json ~/.config/Code/User/keybindings.json.bk
ln -sf ~/dotfiles/vscode/keybindings.json ~/.config/Code/User/keybindings.json
mv ~/.config/Code/User/settings.json ~/.config/Code/User/settings.json.bk
ln -sf ~/dotfiles/vscode/settings.json ~/.config/Code/User/settings.json
mv ~/.config/libinput-gestures.conf ~/.config/libinput-gestures.conf.bk
ln -sf ~/dotfiles/linux/libinput-gestures.conf ~/.config/libinput-gestures.conf
mv ~/.config/starship.toml ~/.config/starship.toml.bk
ln -sf ~/dotfiles/other/starship.toml ~/.config/starship.toml

