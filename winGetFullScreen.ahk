;==============================================================
; winGetFullScreen — Detects whether a window is fullscreen, borderless-maximized, or not fullscreen
;
; GitHub: https://github.com/SevenKeyboard/win-get-full-screen
; Author: SevenKeyboard Ltd. (2026)
; License: MIT License
;
; Documentation / References:
;   GetWindowPlacement function (winuser.h)
;     https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowplacement
;   WINDOWPLACEMENT structure (winuser.h)
;     https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-windowplacement
;   ShowWindow function (winuser.h)
;     https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow
;   GetWindowLongPtrW function (winuser.h)
;     https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowlongptrw
;   GetWindowLongW function (winuser.h)
;     https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowlongw
;   Window Styles
;     https://learn.microsoft.com/en-us/windows/win32/winmsg/window-styles
;   GetWindowLong versus GetWindowLongPtr
;     https://www.autohotkey.com/boards/viewtopic.php?t=38425
;   jeeswg's DllCall and structs tutorial - 'LongPtr' functions (user32.dll)
;     https://www.autohotkey.com/boards/viewtopic.php?t=63708
;   SHQueryUserNotificationState function (shellapi.h)
;     https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shqueryusernotificationstate
;   QUERY_USER_NOTIFICATION_STATE enumeration (shellapi.h)
;     https://learn.microsoft.com/en-us/windows/win32/api/shellapi/ne-shellapi-query_user_notification_state
;==============================================================

/*
Example Usage:
    tooltip % winGetFullScreen("A")
*/

class VersionManager_winGetFullScreen
{
    static _ := VersionManager_winGetFullScreen._init()
    _init()    {
        global
        WINGETFULLSCREEN_VERSION := "1.0.0"
    }
}
winGetFullScreen(winTitle:="", winText:="", excludeTitle:="", excludeText:="")    {
    static SW_SHOWMAXIMIZED:=3, GWL_STYLE:=-16, WS_CAPTION:=0x00C00000, WS_SIZEBOX:=0x00040000
    if (winTitle!=""
        && winTitle~="D)^(?:[[:digit:]]+|(0[Xx][[:xdigit:]]+))$"
        && dllCall("User32.dll\IsWindow", "Ptr",winTitle))    {
        hWnd:=winTitle
    }  else if !(hWnd:=winExist(winTitle, winText, excludeTitle, excludeText))    {
        return 0
    }
    varSetCapacity(lpwndpl,length:=44,0)
    numPut(length,lpwndpl,0,"UInt")
    if !dllCall("User32.dll\GetWindowPlacement", "Ptr",hWnd, "Ptr",&lpwndpl)
        return false
    switch (showCmd:=numGet(lpwndpl,8,"UInt"))==SW_SHOWMAXIMIZED
    {
        default:
            return 0
        case true:
            if !(style:=dllCall("User32.dll\GetWindowLong" (A_PtrSize==8?"Ptr":""), "Ptr",hWnd, "Int",GWL_STYLE, (A_PtrSize==8?"Ptr":"Int")))
                return 1
            return (style&WS_CAPTION || style&WS_SIZEBOX)?1:2
    }
}

/*
clipboard:=format("0x{:X}",dllCall("GetWindowLong" (A_PtrSize==8?"Ptr":""), "Ptr",winExist("A"), "Int",-16, (A_PtrSize==8?"Ptr":"Int")))

    chrome.exe
        0   0x16CF0000
        1   0x17CF0000      +WS_MAXIMIZE
        2    0x170B0000     +WS_MAXIMIZE -WS_CAPTION -WS_SIZEBOX
    Code.exe
        0   0x14C70000
        1   0x15C70000      +WS_MAXIMIZE
        2   0x15030000      +WS_MAXIMIZE -WS_CAPTION -WS_SIZEBOX
    Battle.net.exe
        0   0x14CF0000
        1   0x15CF0000      +WS_MAXIMIZE
    Discord.exe
        0   0x14C70000
        1   0x15C70000      +WS_MAXIMIZE
    notepad.exe
        0   0x14CF0000
        1   0x15CF0000      +WS_MAXIMIZE
    Overwatch.exe
        [WINDOWED]
            0   0x14CF0000
            1   0x15CF0000      +WS_MAXIMIZE
        [BORDERLESS WINDOWED]           QUERY_USER_NOTIFICATION_STATE==QUNS_BUSY
            0   0x14000000      -WS_CAPTION -WS_GROUP -WS_SIZEBOX -WS_SYSMENU -WS_TABSTOP
        [FULLSCREEN]                    QUERY_USER_NOTIFICATION_STATE==QUNS_RUNNING_D3D_FULL_SCREEN
            0   0x14000000      -WS_CAPTION -WS_GROUP -WS_SIZEBOX -WS_SYSMENU -WS_TABSTOP
    steamwebhelper.exe
        0   0xFFFFFFFF94CF0000
        1   0xFFFFFFFF95CF0000      +WS_MAXIMIZE
*/
