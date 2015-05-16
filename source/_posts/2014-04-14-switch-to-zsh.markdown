---
layout: post
title: "Switch To ZSH"
date: 2014-04-14 14:35
comments: true
categories: Linux
---
###Installation
In ArchLinux, install zsh via:

```
	pacman -S zsh zsh-doc

```
Duplicate the .bashrc to .zshrc

```
	cp ~/.bashrc ~/.zshrc

```
But notice, when using zsh, we should use following command under zshh:

```
	rake new_post["Switch To ZSH"] 
	to 
	rake new_post\["Switch To ZSH"\]

```
Or, we can use noglob in zsh specified file .zshrc

```
	alias rake='noglob rake'

```
###Setting
More settings on .zshrc:

```sh zshrc
# Use prompt -l you will see all of the prompt. 
autoload -U promptinit
promptinit
alias rake='noglob rake'
# Customized PS1, with color. 
export PS1="[%n@%~]$ "

```
###Terminal Title
Terminal Title Setting, add following lines into ~/.zshrc:     

```sh zsh.rc
case $TERM in
  (*xterm* | rxvt)

    # Write some info to terminal title.
    # This is seen when the shell prompts for input.
    function precmd {
      print -Pn "\e]0;zsh%L %(1j,%j job%(2j|s|); ,)%~\a"
    }
    # Write command and args to terminal title.
    # This is seen while the shell waits for a command to complete.
    function preexec {
      printf "\033]0;%s\a" "$1"
    }

  ;;
esac

```
###Enable History
Add the definition of history     

```sh zsh.rc
# History File Definition
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# Share history between terminal
setopt inc_append_history
setopt share_history

```
###Chinese Encoding
Add following definition to the .zshrc:    

```
	export LC_ALL=en_US.UTF-8 
	export LANG=en_US.UTF-8

```
And in the terminal simulator, select the encoding:   

```
	Edit->Preference: Advanced->Encoding->Default Encoding(UTF-8)

```
