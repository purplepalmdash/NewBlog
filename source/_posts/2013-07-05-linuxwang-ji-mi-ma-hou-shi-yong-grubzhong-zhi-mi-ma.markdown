---
layout: post
title: "Linux忘记密码后使用grub重置密码"
date: 2013-07-05 12:45
comments: true
categories: Linux
---
Linux忘记密码后，可以通过修改Grub启动参数来进行修复, 举Ubuntu13.04为例：

出现Grub菜单时，按"e"键或是其他键进入Grub的编辑方式。
{% codeblock %}
menuentry 'Ubuntu' --class ubuntu --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-simple-baec278e-2b9f-4513-a6f1-e148ac6295d7' {
recordfail
	load_video
	gfxmode $linux_gfx_mode
	insmod gzio
	insmod part_msdos
	insmod ext2
	set root='hd0,msdos2'
	if [ x$feature_platform_search_hint = xy ]; then
	  search --no-floppy --fs-uuid --set=root --hint-bios=hd0,msdos2 --hint-efi=hd0,msdos2 --hint-baremetal=ahci0,msdos2  baec278e-2b9f-4513-a6f1-e148ac6295d7
	else
	  search --no-floppy --fs-uuid --set=root baec278e-2b9f-4513-a6f1-e148ac6295d7
	fi
	linux	/boot/vmlinuz-3.8.0-19-generic root=UUID=baec278e-2b9f-4513-a6f1-e148ac6295d7 ro   
	initrd	/boot/initrd.img-3.8.0-19-generic
}
{% endcodeblock %}

改动下面这行
{% codeblock %}
linux	/boot/vmlinuz-3.8.0-19-generic root=UUID=baec278e-2b9f-4513-a6f1-e148ac6295d7 ro   
{% endcodeblock %}
为
{% codeblock %}
linux	/boot/vmlinuz-3.8.0-19-generic root=UUID=baec278e-2b9f-4513-a6f1-e148ac6295d7 rw init=/bin/bash  
{% endcodeblock %}

init=/bin/bash将把系统启动到一个没有root密码的shell, rw则允许修改密码，否则ro的情况下无法更新密码。

使用改动后的grub启动系统。在Grub2中一般是按F10, Grub中则是回车后按"b"键，具体需参考grub的帮助。

系统启动到shell后, 输入passwd username重设自己的密码后，reboot系统即可。

