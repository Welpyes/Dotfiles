## ░▀▀█░█▀▀░█░█░█▀▄░█▀▀
## ░▄▀░░▀▀█░█▀█░█▀▄░█░░
## ░▀▀▀░▀▀▀░▀░▀░▀░▀░▀▀▀
##
## rxyhn's Z-Shell configuration
## https://github.com/rxyhn

TARGET_DIR="/data/data/com.termux/files/home"

if [[ $(pwd) == $TARGET_DIR ]]; then
    cd $HOME
fi


while read file
do 
  source "$ZDOTDIR/$file.zsh"
done <<-EOF
theme
env
aliases
keybinds
options
plugins
utils
prompt
gowall
EOF

# perms
# vim:ft=zsh:nowrap
