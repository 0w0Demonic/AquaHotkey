#Requires AutoHotkey >=v2.0.5
#Include "%A_LineFile%/../../AquaHotkey.ahk"

class ArrayFind extends AquaHotkey {
    class Array {
        /**
         * Finds and returns the first element to match the given condition.
         * If an element was found, the method returns `true`, otherwise
         * `false`.
         * 
         * @param   {Func}    Condition  the given condition
         * @param   {VarRef}  Output     output variable
         * @return  {Boolean}
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
    }
}

Arr := Array(1, 2, 3, 4, 5, 6, 7, 8)

if (Arr.Find(x => (x > 4), &Out)) {
    MsgBox(Out)
} else {
    throw ValueError("what?")
}