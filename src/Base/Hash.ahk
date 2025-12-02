#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

class AquaHotkey_Hash extends AquaHotkey {
    class String {
        Hash() {
            Result := 5381
            Loop Parse, this {
                Result := ((Result << 5) + Result) + Ord(A_LoopField)
            }
            return Result
        }
    }

    class Float {
        Hash() {
            
        }
    }

    class Integer {
        Hash() => this
    }

    class Object {
        Hash() => ObjPtr(this)
    }

    class Error {
        Hash() {
            ; TODO
        }
    }
}