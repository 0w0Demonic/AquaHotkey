#Requires AutoHotkey v2
#Include <AquaHotkey\src\Core\AquaHotkey>
#Include <AquaHotkey\src\Core\Utils>

/**
 * @file
 * @name ArrayUtils
 * @description
 * This extension class adds custom array utilities for finding values and
 * shuffling.
 */
class ArrayUtils extends AquaHotkey {
    class Array {
        /**
         * Finds and returns the first element to match the given condition.
         * If an element was found, the method returns `true`, otherwise
         * `false`.
         * 
         * @param   {VarRef<Any?>}            Output     output value
         * @param   {(Any, Any*) => Boolean}  Condition  the given condition
         * @param   {Any*}                    Args       additional args
         * @returns {Boolean}
         * @example
         * Arr := Array(1, 2, 3, 4, 5, 6, 7, 8)
         * 
         * if (Arr.Find(x => x > 4, &Out)) {
         *     MsgBox(Out) ; 5
         * }
         */
        Find(&Out, Condition, Args*) {
            GetMethod(Condition)
            for Value in this {
                if (Condition(Value?, Args*)) {
                    Out := Value
                    return true
                }
            }
            return false
        }

        /**
         * Shuffles the Array in place using Fisher-Yates.
         * 
         * @example
         * Arr := Array(1, 2, 3, 4, 5, 6, 7, 8)
         * Arr.Shuffle() ; e.g. [4, 3, 6, 2, 8, 7, 1, 5]
         * 
         * @returns {this}
         */
        Shuffle() {
            loop this.Length {
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

Arr := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

; "given an array element x, for which x > 2"
Condition := (x) => (x > 2)

; alternatively, use closures to your advantage:
; Gt(n) => (x) => (x > n)
; Condition := Gt(2)

if (Arr.Find(&Value, Condition)) {
    MsgBox("found: " . Value)
} else {
    MsgBox("unable to find value.")
}

Arr.Shuffle() ; shuffles in place
Str := "["
if (FirstItem(Arr, &Value, &More)) {
    Str .= Value
    while (More(&Value)) {
        Str .= ", "
        Str .= Value
    }
}
Str .= "]"
MsgBox("shuffled array: " . Str)