---
layout: post
title: "Hightlight Jade File"
date: 2014-07-12 14:36
comments: true
categories: vim
---
Install `vim-jade` via:    

```
    Bundle 'digitaltoad/vim-jade'

```
Then in vim type `:BundleInstall` this will automatically install the plugin of vim-jade.     
Enable the Highlight of jade file via:    

```
au BufNewFile,BufRead,BufReadPost *.jade set filetype=jade

```
Now everytime you open jade file, it will be automatically be highlighted.    
