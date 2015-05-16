---
layout: post
title: "Converting Markdown into PDF under ArchLinux"
date: 2014-02-26 15:08
comments: true
categories: Markdown
---
Today I want to convert the webpages which wrote from markdown into PDF format file. Following is the steps for how to convert. <br />
Just one command is OK:<br />

```
	pandoc jailbreak.md -o jailbreak.pdf --latex-engine=xelatex -V mainfont="WenQuanYi Zen Hei"

```
But the link will cause the format ugly, then we have to use a template for fixing this, download the template from following URL:<br/>
[https://raw.github.com/tzengyuxio/pages/gh-pages/pandoc/pm-template.latex](https://raw.github.com/tzengyuxio/pages/gh-pages/pandoc/pm-template.latex)<br />
Then put it into the same directory, replace the following lines with the fonts which you have installed on your system:<br />

```
	# Following will be deleted
	\setCJKmainfont{LiHei Pro} 	% 設定中文字型
	\setCJKmainfont{WenQuanYi Zen Hei} 	% 設定中文字型

```
Now you lock of Microsoft fonts, simply copy it from your own windows machine, and setup a link<br />

```
	ln -s /windows/Windows/Fonts /usr/share/fonts/WindowsFonts
	# Update font cache
	fc-cache

```
Generate the pdf file with the following command:<br />

```
	pandoc jailbreak.md -o jailbreak1.pdf --latex-engine=xelatex -V mainfont="WenQuanYi Zen Hei" --template=pm-template.latex

```
Now you will see the well-formated PDF file has been generated from the Markdown file. <br />

![/images/wellpdf.jpg](/images/wellpdf.jpg)
