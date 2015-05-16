---
layout: post
title: "Convert PDF from Markdown"
date: 2014-04-03 14:33
comments: true
categories: markdown
---
There are 2 ways for me to convert Markdown into PDF. <br />   
### pandoc Way
Simple way for converting:<br />   

```
pandoc a.md -o b.pdf

```
Convert with embedded font:<br />    

```
pandoc jailbreak.md -o jailbreak.pdf --latex-engine=xelatex -V mainfont="WenQuanYi Zen Hei"

```
But if you includes the images, then the format maybe wrong.<br />   
### RStudio Way
Install rstudio in archlinux via:<br />   

```
yaourt -S rstudio-desktop-bin

```
When installing you will meet curl need ssl certification problem, simply add following line into the pkg make file.<br />   

```
==> Edit PKGBUILD ? [Y/n] ("A" to abort)
==> ------------------------------------
==> y

Please add $EDITOR to your environment variables
for example:
export EDITOR="vim" (in ~/.bashrc)
(replace vim with your favorite editor)

==> Edit PKGBUILD with:  vim

Add Following:   

DLAGENTS=("https::/usr/bin/curl -k -o %o %u")

```
After you installed rstudio, open the markdown file in the browser,and you have to install following packages:<br />   

```
> install.packages("knitr")
> install.packages("devtools")
> devtools::install_github("rstudio/rmarkdown")
> library(rmarkdown)
> render('test1.Rmd', pdf_document())

```
Makesure your pandoc is the latest version before you really install the rmarkdown package.<br />   
If the markdown is written as in octopress, you have to specify the absolute position of the file:<br />   

```
>  render('/home/Trusty/code/octo/heroku/Tomcat/source/dancecrf.markdown', pdf_document())

```
Now in the same file you will get the generated pdf.<br />
