#!/bin/bash

cd $HOME
if [[ $1 == "" ]]; then
  rofi -show drun -theme ~/.config/rofi/dmenu.rasi
else
  rofi -show $1 -theme ~/.config/rofi/dmenu.rasi
fi
