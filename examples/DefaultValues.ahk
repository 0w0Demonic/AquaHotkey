#Requires AutoHotkey >=v2.0.5
#Include "%A_LineFile%/../../AquaHotkey.ahk"

class DefaultValues extends AquaHotkey {
    class Array {
        Default := false
    }

    class Map {
        Default := "(empty)"
    }
}

ArrayObj  := Array(unset, unset, unset)
ArrayItem := ArrayObj[3]
MapObj    := Map()
MapItem   := MapObj["foo"]

MsgBox(Format("
(
ArrayObj := Array(unset, unset, unset)
MapObj := Map()

ArrayObj[3] == {1}
MapObj["foo"] == {2}
)", ArrayItem, MapItem))