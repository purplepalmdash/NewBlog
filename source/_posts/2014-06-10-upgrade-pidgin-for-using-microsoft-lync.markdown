---
layout: post
title: "Upgrade Pidgin For Using Microsoft Lync"
date: 2014-06-10 09:27
comments: true
categories: linux
---
Since company has upgrade the IM tools from office communicator into Lync, thus I have to upgrade the pidgin's plugins for using lynx. Folloing is the tips:     
### Upgrade SIPE
Sipe is installed via yaourt:     

```
# yaourt -S pidgin-sipe

```
### Configure Pidgin
Edit the existing account via: Edit->Preference->Advanced.     
The connection type is `auto`, the authentication scheme is `TLS-DSK`.     
In the "User Agent", insert following:     

```
UCCAPI/15.0.4481.1000 OC/15.0.4481.1000

```
The detailed "User Agent" descriptions could be refered to following links:     
[http://sourceforge.net/p/sipe/wiki/Frequently%20Asked%20Questions/#connection-refused-with-error-messagewzxhzdk10you-are-currently-not-using-the-recommended-version-of-the-clientwzxhzdk11you-have-been-rejected-by-the-server-httpsportalmicrosoftonlinecomdownloadlyncaspx](http://sourceforge.net/p/sipe/wiki/Frequently%20Asked%20Questions/#connection-refused-with-error-messagewzxhzdk10you-are-currently-not-using-the-recommended-version-of-the-clientwzxhzdk11you-have-been-rejected-by-the-server-httpsportalmicrosoftonlinecomdownloadlyncaspx)

Re-enable the account then you can use lync now.     

