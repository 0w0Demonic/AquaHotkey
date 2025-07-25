#Requires AutoHotkey >=v2.0.5
#Include "%A_LineFile%/../../AquaHotkey.ahk"

class ArrayShuffle extends AquaHotkey {
    class Array {
        /** Shuffles the Array in place. (Fisher-Yates) */
        Shuffle() {
            Loop this.Length {
                i := A_Index
                j := Random(1, this.Length)

                Temp := this[i]
                this[i] := this[j]
                this[j] := Temp
            }
            return this
        }
    }
}

Arr := Array(1, 2, 3, 4, 5, 6, 7, 8).Shuffle()

Enumer := Arr.__Enum()
Enumer(&Str)
for Value in Enumer {
    Str .= ", " . Value
}
MsgBox("[" . Str . "]")