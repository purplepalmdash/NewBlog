---
layout: post
title: "Moving From Working PC to Own USB-Disk Based 5"
date: 2014-05-24 10:25
comments: true
categories: linux
---
### Font Customization
Install following fonts:    

```
$ sudo pacman -S wqy-bitmapfont  wqy-zenhei ttf-arphic-ukai ttf-arphic-uming ttf-fireflysung

```
And then for more beautiful font, refer to:    
[http://kkkttt.github.io/blog/2013/12/25/archlinuxzhong-wen-hua-wen-ti/](http://kkkttt.github.io/blog/2013/12/25/archlinuxzhong-wen-hua-wen-ti/)    

### VIM Customization
Vim is my favorite editor, so maintain a configuration file is necessary for deploying it on various machines.    

```
$ sudo pacman -S ctags

```
Then copy the default vimrc file from /usr/share/vim74/vimrc_example to your own directory, named it into .vimrc. 
Add folllowing lines into .vimrc file: 

```
" Customization Start
set nu
set cursorline 
set cursorcolumn
"Enable syntax
syntax enable
syntax on
" colorscheme solarized
autocmd BufNewFile,BufReadPost *.ino,*.pde set filetype=cpp
"进行Tlist的设置
""TlistUpdate可以更新tags
map <F3> :silent! Tlist<CR> 
"按下F3就可以呼出了
let Tlist_Ctags_Cmd='ctags' "因为我们放在环境变量里，所以可以直接执行
let Tlist_Use_Right_Window=1 "让窗口显示在右边，0的话就是显示在左边
let Tlist_Show_One_File=0 "让taglist可以同时展示多个文件的函数列表，如果想只有1个，设置为1
let Tlist_File_Fold_Auto_Close=1 "非当前文件，函数列表折叠隐藏
let Tlist_Exit_OnlyWindow=1 "当taglist是最后一个分割窗口时，自动推出vim
let Tlist_Process_File_Always=0 "是否一直处理tags.1:处理;0:不处理。不是一直实时更新tags，因为没有必要
let Tlist_Inc_Winwidth=0
set fileencodings=utf8,cp936,gb18030,big5
"In visual mode, you can simply press ,x and Vim will filter your content
"through tidy.
:vmap ,x :%!tidy -q -i --show-errors 0<CR> "Auto command for clear the html files
:command Thtml :%!tidy -q -i --show-errors 0
:command Txml  :%!tidy -q -i --show-errors 0 -xml


" Setting up Vundle - the vim plugin bundler
    let iCanHazVundle=1
    let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
    if !filereadable(vundle_readme)
        echo "Installing Vundle.."
        echo ""
        silent !mkdir -p ~/.vim/bundle
        silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
        let iCanHazVundle=0
    endif
    set rtp+=~/.vim/bundle/vundle/
    call vundle#rc()
    Bundle 'gmarik/vundle'
    Bundle 'tpope/vim-fugitive'
    Bundle 'taglist.vim'
    " Bundle 'molokai'
    "Add your bundles here
    "Bundle 'Syntastic' "uber awesome syntax and errors highlighter
    Bundle 'altercation/vim-colors-solarized' 
    Bundle 'https://github.com/tomasr/molokai.git'
    "T-H-E colorscheme
    "Bundle 'https://github.com/tpope/vim-fugitive' "So awesome, it should be illegal 
    "...All your other bundles...
    if iCanHazVundle == 0
        echo "Installing Bundles, please ignore key map error messages"
        echo ""
        :BundleInstall
    endif
" Setting up Vundle - the vim plugin bundler end

colorscheme molokai
set guifont=YaHei\ Consolas\ Hybrid\ 11.5

```
Then everything I want is OK.    
Command for configurating vbundle:     

```
BundleInstall
BundleSearch

```
Tree tool has been installed, for view the complex directory structure :   

```
$ sudo pacman -S tree

```
### Arduino Related
Install arduino from yaourt. 

```
$ yaourt -S arduino

```
This will also  install avr-gcc.     
### NodeJS
Install via yaourt:    

```
$ yaourt -S nodejs

```
Basic Tutorial:    
[http://localhost2/blog/2014/05/14/node-dot-js-quick-start/](http://localhost2/blog/2014/05/14/node-dot-js-quick-start/)    
Later I will add the "Chat-like" Terminal-emulator series, so this part could be enhanced.    
### Editor tools
Tools which used for writing articles.    

```
$ sudo pacman -S blender dia inkscape scribus
$ yaourt yed
$ yaourt sublime
$ sudo pacman -S gedit
$ sudo pacman -S imagemagick

```
### Awesome Configuration
Dmenu which used for run applications:    

```
$ sudo pacman -S dmenu

```
Screen shot:    

```
$ sudo pacman -S scrot

```
Edit the /usr/bin/mycapscr

```
[Trusty@~]$ cat /usr/bin/mycapscr 
 scrot -s '%Y_%m_%d_%H_%M_%S_$wx$h.jpg' -e 'mv $f ~/capscr/'

```

### Other Tools
Tcpdump for capturing packets.     

```
$ sudo pacman -S tcpdump

```
Whatpulse for recording key click times:

```
$ sudo yaourt -S whatpulse
$ sudo gpasswd -a Trusty input

```
Remote Desktop:    

```
$ pacman -S rdesktop

```
Conky and Conky configuration file.    

```
$ pacman -S conky

```
hex tool:   

```
$ pacman -S ghex

```
Calculator:   

```
$ pacman -S bc
$ pacman -S gnome-calculator

```
Nautlus:   

```
$ pacman -S nautilus

```
rar:    

```
$ pacman -S rar

```
autossh:   

```
$ pacman -S autossh

```
cmake:    

```
$ pacman -S cmake

```
cronie:    

```
$ pacman -S connie

```
elinks:   

```
$ pacman -S elinks

```
eog:   

```
$ pacman -S eog

```
ethtool

```
$ pacman -S ethtool

```
expect:    

```
$ pacman -S expect

```
feh:    

```
$ pacman -S feh

```
gparted:    

```
$ pacman -S gparted

```
ipython2:    

```
$ pacman -S ipython2

```
ntfs-3g:    

```
$ pacman -S ntfs-3g

```
sakura lilyterm:    

```
$ pacman -S sakura lilyterm

```
tmux:    

```
$ pacman -S tmux

```
w3m,lynx:    

```
$ pacman -S w3m lynx

```
xclip:

```
$ pacman -S xclip

```
xlockmore:    

```
$ pacman -S xlockmore

```

### E-Book Tools
XPdf:    

```
$ pacman -S xpdf

```
calibre:    

```
$ pacman -S calibre

```
Rstudio:

```
$ yaourt rstudio-desktop-bin

```
pandoc(Problem!):    

```
$ yaourt pandoc
# Notice, you have to add curl -k in /etc/makepkg.conf

```
briss(For cutting pdf into 6 inch):    

```
$ yaourt briss

```
coolreader(For reading epub):    

```
$ yaourt -S coolreader

```


