#Requires AutoHotkey >=v2.0.5
#Include "%A_LineFile%\..\..\AquaHotkey.ahk"

class MyStuff extends AquaHotkey {
    class Array {
        ForEach(Action, Args*) {
            for Value in this {
                Action(Value?, Args*)
            }
        }
    }
}

MsgBox(Array.Implements(MyStuff.Array))