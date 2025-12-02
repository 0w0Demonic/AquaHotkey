#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

class AquaHotkey_Ord extends AquaHotkey {
    class Integer {
        Compare(Other) {
            if (!(Other is Integer)) {
                throw TypeError("Expected an Integer",, Type(Other))
            }
            return (this > Other) - (Other > this)
        }
    }

    class Float {
        Compare(Other) {
            if (!(Other is Float)) {
                throw TypeError("Expected a Float",, Type(Other))
            }
            return (this > Other) - (Other > this)
        }
    }

    class String {
        Compare(Other, CaseSense?) {
            if (!(Other is String)) {
                throw TypeError("Expected a String",, Type(Other))
            }
            return StrCompare(this, Other, CaseSense?)
        }
    }

    class Array {
        Compare(Other) {
            if (!(Other is Array)) {
                throw TypeError("Expected an Arra",, Type(Other))
            }
            ThisEnumer := this.__Enum(1)
            OtherEnumer := Other.__Enum(1)

            Loop {
                AHasElements := !!ThisEnumer(&A)
                BHasElements := !!OtherEnumer(&B)
                if (AHasElements != BHasElements) {
                    return 0 + AHasElements - BHasElements
                }
            }
        }
    }

    class Class {
        Compare => this.Prototype.Compare
    }
}

Comp := Integer.Compare

MsgBox(Comp(2, 4))