#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Provides a wide range of chainable assertion methods.
 * 
 * @module  <Base/Assertions>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Assertions extends AquaHotkey {
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

        /**
         * Asserts that the value is considered an instance of the given type.
         * 
         * @param   {Any}  T  type pattern
         * @see {@link AquaHotkey_DuckTypes `.Is()`}
         * @example
         * Str.AssertType(String)
         */
        AssertType(T) {
            if (T.IsInstance(this)) {
                return this
            }
            throw TypeError("type mismatch", -2)
        }

        ; TODO probably add back equality methods
        ;      (don't have to do my homeboy Assertions.ahk dirty like that)

    }
}

/**
 * Asserts that assumptions made in the program are true, otherwise an error is
 * thrown.
 * 
 * @param   {Boolean}  Result  result from a boolean expression
 * @example
 * Assert(4 == 4)
 */
Assert(Result) {
    if (!Result) {
        throw ValueError("failed assertion", -2)
    }
}
