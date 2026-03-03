; << for quick one-off tests >>
#Requires AutoHotkey v2.0
#Include <AquaHotkeyX>
#Include "%A_LineFile%\..\..\wip\Serializer.ahk"
#Include "%A_LineFile%\..\..\wip\Serial.ahk"

Ser := Map.OfType(Integer, Integer)(1, 2, 3, 4)

FileOpen("result.txt", "w").WriteObject(Ser)
FileOpen("result.txt", "r").ReadObject(&Deser)

"
(
Type(Deser): {}
Deser.MapType: {}
Deser.KeyType: {}
Deser.ValueType: {}
)"
.Formatted(Type(Deser), Deser.MapType, Deser.KeyType, Deser.ValueType)
.MsgBox()