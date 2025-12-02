#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * 
 */
class AquaHotkey_Eq extends AquaHotkey {
    class Array {
        Eq(Other?) {
            if (!IsSet(Other)) {
                return false
            }
            if (this == Other) {
                return true
            }
            if (!(Other is Array)) {
                return false
            }
            if (this.Length != Other.Length) {
                return false
            }

            ThisEnumer := this.__Enum(1)
            OtherEnumer := Other.__Enum(1)

            while (ThisEnumer(&A) && OtherEnumer(&B)) {
                if (!Object.Eq(A?, B?)) {
                    return false
                }
            }
            return true
        }
    }

    class Map {
        Eq(Other) {
            if (this == Other) {
                return true
            }
            if (!(Other is Map)) {
                return false
            }
            if (this.Count != Other.Count) {
                return false
            }

            ThisEnumer := this.__Enum(2)
            OtherEnumer := Other.__Enum(2)

            while (ThisEnumer(&K1, &V1) && OtherEnumer(&K2, &V2)) {
                if (!Object.Eq(K1?, K2?) || !Object.Eq(V1?, V2?)) {
                    return false
                }
            }
            return true
        }
    }

    class Buffer {
        ; TODO how to write eq check?
    }

    class Error {
        ; TODO
    }

    class Object {
        static Eq(A?, B?) {
            if (IsSet(A)) {
                return IsSet(B) && A.Eq(B)
            }
            return !IsSet(B)
        }

        ; TODO
    }

    class VarRef {
        
    }

    class Func {
        ; TODO probably find out pointer or something
    }

    class Any {
        Eq(Other?) => (IsSet(Other) && this = Other)
    }
}