---
layout: post
title: "Re-install Surface Pro"
date: 2014-11-22 21:43
comments: true
categories: SurfacePro
---
Just for recording the steps, later I will use it for re-installation.     
1\. Insert the FlashDisk, re-partition the harddisk, and install the system. After everything is OK, restart.    
2\. Choose start from HardDisk(ignore the caches and eject kext), Now the system will ask you for configuration, Select US-keyboard/Canada, after entering the system, simply change the language from Italian to English.    
Install Clover to the Harddisk. The default installtion will failed, then you have to manually mount the EFI partition, and copy the EFI/ folder under the "/" directory to EFI partition.   
Copy the DSDT and SSDT from the Surface downloaded folder. config.plist from [http://www.insanelymac.com/forum/topic/301884-guide-surface-pro-1st-gen-yosemite-clean-installation/page-2#entry2077531](http://www.insanelymac.com/forum/topic/301884-guide-surface-pro-1st-gen-yosemite-clean-installation/page-2#entry2077531)    
Use kdrop for dropping the kext files under Surface/ folder, don't install yosemite specified. Ignore the apple's framebuffer.      
 Then restart. This time we could remove the flashdisk to let SurfacePro start by itself.    
3\. After restarted, remove the EFI in / folder(Not the EFI folder!!!), then dropped the Yosemited specifed kext. Restart.    
4\. Install the dp kext, and replace the dp related config.plist, Restart.     
5\. Install the ethernet card, mine have the USB ethernet adapter and also USB wireless adapter, install the ethernet adapter first, mine is AX8872 usb adapter, simply download the package from webiste, install it. Then restart.         
Restart and the system becomes not stable, it seems the AX8872 harms the system.     
Re-dropped the Yosemite specified KEXT, for try. After re-dropped, restart the system.    
Seems no effect, OK,finally we remove the EFI and re-copy the EFI into the system( Go back to step 2, recover the EFI and re-dropped the kexts excpect Yosemite specified), and restart.      
Now the video seems OK, re-dropped the yosemite specified kexts, then restart.      
Now Usb Ethernet Adapter is OK. Enable the ssh and now we could remotely sent files to it.      
Install the USB Wireless adapter's driver via: `TL-WN725N_v2_USB_MacOS10.8.zip`, this one is simply downloaded for r8188eu chipset, mine is "fast" but it's actually the copy of TP-LINK WN725N.     
Since we replaced the EFI with the original EFI, we have to re-dropped the framebuffer and replace the dsdt file and replace the EFI's config.plist for supporting DP output. Now restart.     
Notice, normally if you replaced the dsdt file, the restart procedure may be pretty long, and it possibly runs into error cases.   
6\. Fortunately we runs into the correct case, so last step we install the NullEthernet driver.  This driver enables your ethernet card acts like a built-in card, thus you could visit app store.   First you dropped the kext, then you use a tool named MaciASL for editing the dsdt file, patched the "patch.txt", save to dsdt, and restart.      
6-1 Bad Luck, the system got very slow again, so go back to Step 2, remove the installed EFI, then re-dropped the kexts excepts the Yosemite and others, restart.     
6-2 The video goes OK, continue for dropping yosemite specified Kexts, then restart.    
6-3 At this moment we still could not reached App store, so installed the DisPlay Port  patches, and re-start.    
6-4 Finally we could re-install the NullEthernet Drivers.  But wait!!! Because this time I installed the fucking injector. This package causes the system un-stable again. And it seems the system is pretty slow, but we still got login window, simply go to /S/L/E, and remove the installed NUllEthernetInjector.kext. Then use disk utils for checking the volumn and repare the permission.. REstart to see the effect.    
6-5 No recover, go back to 6-1 ~ 6-3.    
6-6 Install the NullEthernet.kext, and applied the pathes, restart and wait for result.    
6-7 Failed, I doubt if it's because the wireless and ethernet adapter both OK, so remove wireless, and do the experiment again.     
6-8 This time didn't replace the dp , But installed the NullEthernet and applied the patch. Then delete all of the configuration of the network card, and also removed all of the devices and the configuration file under the /L/Preferences/Systemconfig/network.plist     OK.   
