---
layout: post
title: "Use AutoHotKey Together With Synergy"
date: 2015-10-29 09:07:18 +0800
comments: true
categories: Windows
---
Recently I am using Surface Pro as my second screen, my main screen runs Linux, whose
Copy/Paste could be done via mouse(mouse left key for selecting and copy to clipboard,
middle key for pasting). While the Windows doesn't have the same configuration for
Copy/Paste(You could only use Ctrl+c/Ctrl+v), which makes me feels so low-efficiency.
That's why I use AutoHotKey.     
### Installation
Download the AutoHotKey from    
[http://www.autohotkey.com/](http://www.autohotkey.com/)    

Install it on Windows 8.1.   

### Configuration
Create a directory named `AutoHotKey` on `C:\`, then create a file named
`CopyPaste.ahk`, then right-click it and select `Edit Script`, fill in following
content, which is copied from
[http://autohotkey.com/board/topic/44064-copy-on-select-implementation/](http://autohotkey.com/board/topic/44064-copy-on-select-implementation/):    

```
mousedrag_treshold := 20 ; pixels
middleclick_available := 15 ; seconds

Hotkey mbutton, paste_selection
Hotkey mbutton, off
Hotkey rbutton, cancel_paste
Hotkey rbutton, off
    
    
#IfWinNotActive ahk_class ConsoleWindowClass
~lButton::
  MouseGetPos, mousedrag_x, mousedrag_y
  keywait lbutton
  mousegetpos, mousedrag_x2, mousedrag_y2
  if (abs(mousedrag_x2 - mousedrag_x) > mousedrag_treshold
    or abs(mousedrag_y2 - mousedrag_y) > mousedrag_treshold)
  {
    wingetclass class, A
    if (class == "Emacs")
      sendinput !w
    else
      sendinput ^c
    settimer follow_mouse, 100
    settimer cleanup, % middleclick_available * 1000
    hotkey mbutton, on
    hotkey rbutton, on
  }
  return
#IfWinNotActive
  
  
follow_mouse:
  tooltip copy
  return
  
paste_selection:
  sendinput {lbutton}
  WinGetClass class, A
  if (class == "Emacs")
    SendInput ^y
  else
    SendInput ^v
  gosub cleanup
  return
  
cancel_paste:
  sendinput {rbutton}
  gosub cleanup
  return  
  
cleanup:
  Hotkey mbutton, off
  Hotkey rbutton, off
  SetTimer cleanup, off
  settimer follow_mouse, off
  tooltip
  Return
  
  
;; clipx
^mbutton::
  sendinput ^+{insert}
  return
```

Now double click it, test its functionality. On Windows, using the real mouse, you will
find the activity are the same as in Linux/Unix X.   

But failed integration with Synergy!    

### True X-Mouse Gizmo
Since the AutoHotKey failed with synergy, I have to swith to another method.     

Download it from:    

[http://fy.chalmers.se/~appro/nt/TXMouse/](http://fy.chalmers.se/~appro/nt/TXMouse/)    

Add it into the startup file in Windows 8.  

Add the shortlink into `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp`
,then restart the computer, verify the modification.    
