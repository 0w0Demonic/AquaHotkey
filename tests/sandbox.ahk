; << for quick one-off tests >>
#Requires AutoHotkey v2.0
#Include <AquaHotkeyX>
#Include <AquaHotkey\src\Collections\ByteArray>

A := Buffer(16, 0).AsArray().FillWith(() => A_Index)

FileOpen("result.txt", "w").WriteObject(A)
FileOpen("result.txt", "r").ReadObject().JoinLine().MsgBox()
