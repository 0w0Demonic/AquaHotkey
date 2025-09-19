#Requires AutoHotkey >=v2.0.5
#Include "%A_LineFile%/../../AquaHotkey.ahk"

/**
 * @file
 * @name ArrayUtils
 * @description
 * Demonstrates how to add custom array utilities.
 */
class ArrayFind extends AquaHotkey {
    class Array {
        /**
         * Finds and returns the first element to match the given condition.
         * If an element was found, the method returns `true`, otherwise
         * `false`.
         * 
        * @example
        * Arr := Array(1, 2, 3, 4, 5, 6, 7, 8)
        * 
        * if (Arr.Find(x => x > 4, &Out)) {
        *     MsgBox(Out) ; 5
        * }
         * 
         * @param   {Func}    Condition  the given condition
         * @param   {VarRef}  Output     output variable
         * @returns {Boolean}
         */
        Find(Condition, &Out) {
            GetMethod(Condition)
            for Value in this {
                if (Condition(Value?)) {
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