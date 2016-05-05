---
layout: post
title: "Working Tips On ansible-cobbler"
date: 2016-05-04 15:36:55 +0800
comments: true
categories: Virtualization
---
### Source
The source are downloaded from:    
[https://github.com/signed8bit/ansible-cobbler](https://github.com/signed8bit/ansible-cobbler)    

Git clone it via:    

```
$ git clone https://github.com/signed8bit/ansible-cobbler.git
```
### Test
The test will be done via `vagrant up`, while we met the problem: the cobbler version
in ansible playbooks are too old, thus the command `cobbler get-loaders` won't acts
well. we have to changing to the newest cobbler version which is available in 

[http://cobbler.github.io/](http://cobbler.github.io/)     

### Manually Steps(Ubuntu)
Install the newest cobbler via:    

```
$ wget -qO - http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/xUbuntu_14.04/Release.key | sudo apt-key add -
$ sudo add-apt-repository "deb http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/xUbuntu_14.04/ ./"
$ sudo apt-get install -y cobbler 
$ cobbler --version
Cobbler 2.6.11
  source: ?, ?
  build time: Sat Jan 23 14:13:42 2016
```
Change Password of the `cobbler`:    

```
Change the password for the 'cobbler' username:
htdigest /etc/cobbler/users.digest "Cobbler" cobbler
```

visit the url of `http://xxx.xxx.xxx.xx/cobbler_web` and you could access the management interface of cobbler.     


### Import CentOS7.2
Import the iso via following command

```
$ sudo mount -t iso9660 -o loop ./CentOS-7-x86_64-Everything-1511.iso /mnt1
$ sudo cobbler import --name=CentOS-7.2 --arch=x86_64 --path=/mnt1
```
Examine the imported iso:    

```
root@cobbler-ubuntu:~# cobbler profile list
   CentOS-7.2-x86_64
root@cobbler-ubuntu:~# cobbler distro list
   CentOS-7.2-x86_64
```

Change the default password of root:    

```
# openssl passwd -1
# vim /etc/cobbler/settings 
- default_password_crypted: "$1$mF86/UHC$WvcIcX2t6crBz2onWxyac."
+ default_password_crypted: "$awegwaegoguoweuouoeh/"
# cobbler sync
# service cobbler restart
# service cobblerd restart

```

### Todo
How to automatically install the mate desktop via kickstart?   

First find out all of the pkgs in group, then add them into the kickstart file?  


### For Making Mate
Steps are listed as following:    

```
# curl http://mirrors.aliyun.com/repo/epel-7.repo>/etc/yum.repos.d/epel-7.repo
# curl http://mirrors.aliyun.com/repo/Centos-7.repo>CentOS-Base.repo
# yum groupinstall "X Window system"
# yum groupinstall "MATE Desktop"
```
Remain the yum cache:    

```
[root@localhost ~]# cat /etc/yum.conf 
[main]
#cachedir=/var/cache/yum/$basearch/$releasever
cachedir=/root/cache/$basearch/$releasever
keepcache=1
```
For setting mate as the default desktop envs:    

```
# systemctl isolate graphical.target
# systemctl set-default graphical.target
```

### Repo In Cobbler
We could setup the cobbler's repository via following steps:    

![/images/2016_05_05_22_48_11_536x324.jpg](/images/2016_05_05_22_48_11_536x324.jpg)    

The configuration of this repo:    

![/images/2016_05_05_22_48_58_718x444.jpg](/images/2016_05_05_22_48_58_718x444.jpg)    

Now you repo's configuration file should be like following:    

```
root@cobbler-ubuntu:/var/lib/cobbler/snippets# cat /srv/www/cobbler/repo_mirror/centos7_mate/config.repo 
[centos7_mate]
name=centos7_mate
baseurl=http://${http_server}/cobbler/repo_mirror/centos7_mate
enabled=1
priority=99
gpgcheck=0
```
Copy the rpms into `/srv/www/cobbler/repo_mirror/centos7_mate/`, and then `createrepo` for generating the package informations.    

Now edit the existing profile's repo configurations:    

```
# cobbler profile list
   CentOS-7.2-x86_64
# cobbler profile edit --name=CentOS-7.2-x86_64 --repo='centos7_mate'
```

Examine it via:    

```
# cobbler repo report --name=centos7_mate
Name                           : centos7_mate
Apt Components (apt only)      : []
Apt Dist Names (apt only)      : []
Arch                           : x86_64
Breed                          : yum
Comment                        : This Repo is for installing MATE Desktop
Createrepo Flags               : <<inherit>>
Environment Variables          : {}
Keep Updated                   : False
Mirror                         : 
Mirror locally                 : True
Owners                         : ['admin']
Priority                       : 99
External proxy URL             : 
RPM List                       : []
Yum Options                    : {}
```

### Using the repo in kickstart
First define the snippet:    

```
root@cobbler-ubuntu:/var/lib/cobbler/snippets# pwd
/var/lib/cobbler/snippets
root@cobbler-ubuntu:/var/lib/cobbler/snippets# cat mate
# Install mate
mkdir -p /etc/yum.repos.d/back
mv /etc/yum.repos.d/CentOS* /etc/yum.repos.d/back/
yum install -y abattis-cantarell-fonts abrt abrt-addon-ccpp abrt-addon-kerneloops abrt-addon-pstoreoops abrt-addon-python abrt-addon-vmcore abrt-addon-xorg abrt-dbus abrt-desktop abrt-gui abrt-gui-libs abrt-java-connector abrt-libs abrt-python abrt-retrace-client accountsservice adwaita-cursor-theme adwaita-gtk2-theme adwaita-icon-theme alsa-plugins-pulseaudio alsa-utils atk atkmm atril atril-caja atril-libs at-spi2-atk at-spi2-core audit-libs-python augeas-libs avahi-autoipd avahi-glib avahi-libs bind-libs-lite bind-license brasero brasero-libs bzip2 ca-certificates cairo cairo-gobject cairomm caja caja-extensions caja-extensions-common caja-image-converter caja-open-terminal caja-schemas caja-sendto cdparanoia cdparanoia-libs cdrdao centos-indexhtml check checkpolicy cjkuni-uming-fonts clutter clutter-gst2 clutter-gtk cogl colord-libs compat-libcogl12 compat-libcogl-pango12 compat-libcolord1 coreutils cpp crda cronie cronie-anacron cryptsetup cups-libs cyrus-sasl-lib dbus-x11 dconf dconf-editor dejavu-fonts-common dejavu-sans-fonts dejavu-sans-mono-fonts dejavu-serif-fonts desktop-file-utils device-mapper device-mapper-event device-mapper-event-libs device-mapper-libs djvulibre-libs dleyna-connector-dbus dleyna-core dleyna-server dosfstools dracut dracut-config-rescue dracut-network dvd+rw-tools elfutils emacs-filesystem enchant engrampa eom exempi fftw-libs-double filezilla firefox firewall-config flac-libs fontconfig fontpackages-filesystem fortune-mod fros fuse fuse-libs gamin GConf2 gcr gd gdb gdisk gdk-pixbuf2 genisoimage geoclue2 ghostscript ghostscript-fonts giflib glibc glibc-common glibmm24 glx-utils gmp gnome-abrt gnome-desktop3 gnome-icon-theme gnome-icon-theme-extras gnome-icon-theme-legacy gnome-keyring gnome-keyring-pam gnome-online-accounts gnome-python2 gnome-python2-canvas gnome-themes-standard gnote gnu-free-fonts-common gnu-free-mono-fonts gnu-free-sans-fonts gnu-free-serif-fonts gnutls gom google-crosextra-caladea-fonts google-crosextra-carlito-fonts gparted gpm-libs graphite2 grilo grilo-plugins grub2 grub2-tools gsm gssdp gstreamer gstreamer1 gstreamer1-plugins-bad-free gstreamer1-plugins-base gstreamer1-plugins-good gstreamer-plugins-bad-free gstreamer-plugins-base gstreamer-plugins-good gstreamer-tools gtk2 gtk2-engines gtk2-immodule-xim gtk3 gtk3-immodule-xim gtkmm24 gtkmm30 gtk-murrine-engine gtksourceview2 gtkspell3 gucharmap gupnp gupnp-av gupnp-dlna gvfs gvfs-afc gvfs-archive gvfs-fuse gvfs-gphoto2 gvfs-mtp gvfs-smb harfbuzz harfbuzz-icu hicolor-icon-theme hunspell hunspell-en-US ibus ibus-chewing ibus-gtk2 ibus-gtk3 ibus-hangul ibus-kkc ibus-libpinyin ibus-libs ibus-m17n ibus-rawcode ibus-sayura ibus-setup ibus-table ibus-table-chinese icedax ilmbase ImageMagick initscripts iso-codes iw jasper-libs jbigkit-libs jomolhari-fonts json-glib kernel kernel-tools kernel-tools-libs kexec-tools khmeros-base-fonts khmeros-fonts-common kpartx krb5-libs lcms2 libao libarchive libart_lgpl libasyncns libatasmart libavc1394 libblkid libbluray libburn libcanberra libcanberra-gtk2 libcanberra-gtk3 libcdio libcdio-paranoia libcgroup libchewing libdmapsharing libdmx libdnet libdv libdvdnav libdvdread libepoxy liberation-fonts-common liberation-mono-fonts liberation-sans-fonts liberation-serif-fonts libevdev libevent libexif libfontenc libgdata libgee06 libglade2 libgnomecanvas libgnome-keyring libgphoto2 libgpod libgsf libgtop2 libgudev1 libgusb libgxps libhangul libICE libicu libiec61883 libieee1284 libimobiledevice libiptcdata libisofs libjpeg-turbo libkkc libkkc-common libkkc-data libldb libmatekbd libmatemixer libmateweather libmateweather-data libmbim libmediaart libmount libmpc libmpcdec libmspack libmtp libmx libnatpmp libnl libnm-gtk libnotify libntlm liboauth libofa libogg libosinfo libpeas libpinyin libpinyin-data libplist libpng libqmi libraw1394 libreport libreport-centos libreport-filesystem libreport-gtk libreport-plugin-mantisbt libreport-plugin-reportuploader libreport-plugin-rhtsupport libreport-plugin-ureport libreport-python libreport-web librsvg2 libsamplerate libsecret libsemanage-python libsexy libshout libsigc++20 libSM libsmbclient libsndfile libspectre libsrtp libssh2 libtalloc libtar libtdb libteam libtevent libthai libtheora libtiff libtomcrypt libtommath libtool-ltdl libudisks2 libusal libusb libusbx libuser-python libuuid libv4l libvisual libvorbis libvpx libwbclient libwebp libwmf-lite libwnck libwnck3 libwvstreams libX11 libX11-common libXau libxcb libXcomposite libXcursor libXdamage libXdmcp libXevie libXext libXfixes libXfont libXft libXi libXinerama libxkbfile libxklavier libxml2 libxml2-python libXmu libXpm libXrandr libXrender libXres libXScrnSaver libxshmfence libxslt libXt libXtst libXv libXvMC libXxf86dga libXxf86misc libXxf86vm lightdm lightdm-gobject lightdm-gtk lightdm-gtk-common lklug-fonts lockdev logrotate lohit-assamese-fonts lohit-bengali-fonts lohit-devanagari-fonts lohit-gujarati-fonts lohit-kannada-fonts lohit-malayalam-fonts lohit-marathi-fonts lohit-nepali-fonts lohit-oriya-fonts lohit-punjabi-fonts lohit-tamil-fonts lohit-telugu-fonts lrzsz lvm2 lvm2-libs lz4 m17n-contrib m17n-db m17n-lib madan-fonts marco mariadb-libs marisa mate-applets mate-backgrounds mate-calc mate-control-center mate-control-center-filesystem mate-desktop mate-desktop-libs mate-dictionary mate-disk-usage-analyzer mate-icon-theme mate-media mate-menus mate-menus-libs mate-menus-preferences-category-menu mate-netspeed mate-notification-daemon mate-panel mate-panel-libs mate-polkit mate-power-manager mate-screensaver mate-screenshot mate-search-tool mate-session-manager mate-settings-daemon mate-system-log mate-system-monitor mate-terminal mate-themes mate-user-guide mate-utils-common mathjax mathjax-ams-fonts mathjax-caligraphic-fonts mathjax-fraktur-fonts mathjax-main-fonts mathjax-math-fonts mathjax-sansserif-fonts mathjax-script-fonts mathjax-size1-fonts mathjax-size2-fonts mathjax-size3-fonts mathjax-size4-fonts mathjax-typewriter-fonts mathjax-winchrome-fonts mathjax-winie6-fonts mdadm media-player-info mesa-dri-drivers mesa-filesystem mesa-libEGL mesa-libgbm mesa-libGL mesa-libglapi mesa-libGLU mesa-libxatracker mesa-private-llvm mobile-broadband-provider-info ModemManager ModemManager-glib mozilla-filesystem mozo mpfr mtdev net-tools NetworkManager NetworkManager-adsl network-manager-applet NetworkManager-glib NetworkManager-libnm NetworkManager-openconnect NetworkManager-openvpn NetworkManager-pptp NetworkManager-team NetworkManager-tui NetworkManager-vpnc NetworkManager-vpnc-gnome nhn-nanum-fonts-common nhn-nanum-gothic-fonts nm-connection-editor nspr nss nss-softokn nss-softokn-freebl nss-sysinit nss-tools nss-util numactl-libs oddjob oddjob-mkhomedir opencc openconnect OpenEXR-libs openjpeg-libs openldap open-sans-fonts openssh openssh-clients openssh-server openssl openssl-libs open-vm-tools open-vm-tools-desktop openvpn opus orc overpass-fonts PackageKit-glib PackageKit-gstreamer-plugin paktype-naskh-basic-fonts pango pangomm paratype-pt-sans-fonts pcsc-lite-libs perl perl-Carp perl-constant perl-Encode perl-Exporter perl-File-Path perl-File-Temp perl-Filter perl-Getopt-Long perl-HTTP-Tiny perl-libs perl-macros perl-parent perl-PathTools perl-Pod-Escapes perl-podlators perl-Pod-Perldoc perl-Pod-Simple perl-Pod-Usage perl-Scalar-List-Utils perl-Socket perl-Storable perl-Text-ParseWords perl-threads perl-threads-shared perl-Time-HiRes perl-Time-Local pexpect pinentry-gtk pixman pkcs11-helper pluma pluma-data plymouth-graphics-libs plymouth-plugin-label plymouth-plugin-two-step plymouth-system-theme plymouth-theme-charge policycoreutils-python polkit polkit-gnome poppler poppler-data poppler-glib pptp procps-ng psmisc pulseaudio pulseaudio-libs pulseaudio-libs-glib2 pulseaudio-module-x11 pulseaudio-utils pycairo pygobject2 pygobject3 pygtk2 pygtk2-libglade pygtksourceview pyOpenSSL pytalloc python-augeas python-backports python-backports-ssl_match_hostname python-beaker python-chardet python-cups python-dmidecode python-inotify python-IPy python-kitchen python-mako python-markupsafe python-paste python-perf python-pwquality python-pyudev python-setuptools python-six python-tempita pyxdg qemu-guest-agent rarian rarian-compat rdma realmd recode redhat-menus rest rhythmbox rtkit samba-client-libs samba-common samba-common-libs samba-common-tools samba-libs sane-backends-libs satyr SDL seahorse selinux-policy selinux-policy-targeted setools-libs setroubleshoot setroubleshoot-plugins setroubleshoot-server sg3_utils-libs sil-abyssinica-fonts sil-nuosu-fonts sil-padauk-fonts simple-scan skkdic smc-fonts-common smc-meera-fonts sos sound-theme-freedesktop soundtouch speex spice-vdagent startup-notification stix-fonts stoken-libs sudo system-config-date system-config-date-docs system-config-language system-config-printer system-config-printer-libs system-config-users system-config-users-docs systemd systemd-libs systemd-python systemd-sysv taglib teamd telepathy-glib texlive-kpathsea-lib thai-scalable-fonts-common thai-scalable-waree-fonts totem totem-pl-parser tracker transmission-common transmission-gtk tuned tzdata ucs-miscfixed-fonts udisks2 unique upower urw-fonts usb_modeswitch usb_modeswitch-data usbmuxd usermode usermode-gtk util-linux vim-common vim-enhanced vim-filesystem vlgothic-fonts vorbis-tools vpnc vpnc-script vte wavpack web-assets-filesystem webkitgtk webkitgtk3 webrtc-audio-processing wireless-tools wodim wqy-microhei-fonts wqy-zenhei-fonts wvdial wxBase wxGTK xcb-util xchat xdg-user-dirs xdg-user-dirs-gtk xdg-utils xkeyboard-config xml-common xmlrpc-c xmlrpc-c-client xorg-x11-drivers xorg-x11-drv-ati xorg-x11-drv-dummy xorg-x11-drv-evdev xorg-x11-drv-fbdev xorg-x11-drv-intel xorg-x11-drv-nouveau xorg-x11-drv-qxl xorg-x11-drv-synaptics xorg-x11-drv-v4l xorg-x11-drv-vesa xorg-x11-drv-vmmouse xorg-x11-drv-vmware xorg-x11-drv-void xorg-x11-drv-wacom xorg-x11-font-utils xorg-x11-server-common xorg-x11-server-utils xorg-x11-server-Xorg xorg-x11-utils xorg-x11-xauth xorg-x11-xinit xorg-x11-xkb-utils xvattr yelp yelp-libs yelp-xsl yumex zenity
systemctl isolate graphical.target
systemctl set-default graphical.target
```

Now involved this snippet in `ks_end`

```
# pwd
/var/lib/cobbler/kickstarts
# vim sample_end.ks
    # Insert a key
    $SNIPPET('publickey')
    # Instal mate
    $SNIPPET('mate')
    # End final steps
    %end
```

Now run `cobbler sync` for syncing your configurations.     

Next time you bootstrap a machine, it will automatically runs into MATE desktop.    

![/images/2016_05_05_22_56_57_672x489.jpg](/images/2016_05_05_22_56_57_672x489.jpg)    
