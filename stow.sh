#!/bin/bash

cd $(pwd)/dotfiles
stow -t $HOME --dotfiles .
