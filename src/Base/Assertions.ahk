#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Provides a wide range of chainable assertion methods.
 * 
 * @module  <Base/Assertions>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Assertions extends AquaHotkey
{
    class Any {
        /**
         * Asserts that the given `Condition` is true for the value. Otherwise,
         * throws an error.
         * 
         * @param   {Func}  Condition  the condition to assert
         * @param   {Any*}  Args       zero or more arguments
         * @returns {this}
         * @see {@link Predicate}
         * @example
         * Str.Assert(IsNumber.Or(IsTime))
         * Obj.Assert(ObjHasOwnProp, "Value")
         */
        Assert(Condition, Args*) {
            if (Condition(this, Args*)) {
                return this
            }
            throw ValueError("failed assertion", -2)
        }
    }
}
