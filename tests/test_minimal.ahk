; << for quick one-off tests >>
#Requires AutoHotkey v2.0

#Include "%A_LineFile%\..\..\src\Core\AquaHotkeyX.ahk"
;#Include "%A_LineFile%\..\..\src\Core\AquaHotkey.ahk"

Range(10).Gather(WindowFixed(3)).JoinLine().MsgBox()
