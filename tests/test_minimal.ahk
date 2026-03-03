; << for quick one-off tests >>
#Requires AutoHotkey v2.0
#Include <AquaHotkeyX>
#Include "%A_LineFile%\..\..\src\IO\Serializer.ahk"
#Include "%A_LineFile%\..\..\src\IO\Serial.ahk"

; Ser := Map.OfType(Integer, Integer)(1, 2, 3, 4)

A := Object()
B := Object()
A.V := B
B.V := A

Ser := A

B := Buffer(16, 0).Fill(42)

FileOpen("result.txt", "w").WriteObject(B)
FileOpen("result.txt", "r").ReadObject(&Output)

MsgBox(Type(Output))
MsgBox(Output.Size)
MsgBox(Output.HexDump())