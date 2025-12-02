;@region Condition
/**
 * AquaHotkey - Condition.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/Comparator.ahk
 * 
 * ---
 * 
 * Utility class for creating many different types of so-called
 * "predicate functions" which evaluate conditions.
 * 
 * @example
 * ; [4, 5]
 * Array(1, 2, 3, 4, 5).RetainIf(  Condition.GreaterThan(3)  )
 */
class Condition {
    ;@region General
    /**
     * Always returns true.
     * @returns {Func}
     */
    static True => (Args*) => true

    /**
     * Always returns false.
     * @returns {Func}
     */
    static False => (Args*) => false
    ;@endregion

    ;@region Unset Values
    /**
     * Determines whether the element has a value.
     * @returns {Func}
     */
    static IsNull => (Arg?) => (!IsSet(Arg))

    /**
     * Determines whether the element has no value.
     * @returns {Func}
     */
    static IsNotNull => (Arg?) => (IsSet(Arg))
    ;@endregion

    ;@region Equality
    /**
     * Returns a condition that checks equality with the given `Target`.
     * @param   {Any}  Target  value to compare with
     * @returns {Func}
     */
    static Equals(Target) => (Arg) => (Arg = Target)

    /**
     * Returns a condition that checks strict equality with the given `Target`.
     * @param   {Any}  Target  value to compare with
     * @returns {Func}
     */
    static StrictEquals(Target) => (Arg) => (Arg == Target)

    /**
     * Returns a condition that checks inequality with the given `Target`.
     * @param   {Any}  Target  value to compare with
     * @returns {Func}
     */
    static NotEquals(Target) => (Arg) => (Arg != Target)

    /**
     * Returns a condition that checks strict inequality with the given
     * `Target`.
     * @param   {Any}  Target  value to compare with
     * @returns {Func}
     */
    static StrictNotEquals(Target) => (Arg) => (Arg !== Target)
    ;@endregion

    ;@region Numeric
    /**
     * Evaluates whether the input argument is greater than `Num`.
     * @param   {Number}  Num  number to compare with
     * @returns {Func}
     */
    static Gt(Num) {
        Num += 0
        return ((Arg) => (Arg > Num))
    }

    /**
     * Evaluates whether the input argument is greater than or equal to `Num`.
     * @param   {Number}  Num  number to compare with
     * @returns {Func}
     */
    static Ge(Num) {
        Num += 0
        return ((Arg) => (Arg >= Num))
    }

    /**
     * Evaluates whether the input argument is less than `Num`.
     * @param   {Number}  Num  number to compare with
     * @returns {Func}
     */
    static Lt(Num) {
        Num += 0
        return ((Arg) => (Arg < Num))
    }

    /**
     * Evaluates whether the input argument is less than or equal to `Num`.
     * @param   {Number}  Num  number to compare with
     * @returns {Func}
     */
    static Le(Num) {
        Num += 0
        return ((Arg) => (Arg <= Num))
    }

    /**
     * Evaluates whether the input argument is `>= Low` and `<= High`.
     * @param   {Number}  Low   lower limit
     * @param   {Number}  High  upper limit
     * @returns {Func}
     */
    static Between(Low, High) {
        Low += 0
        High += 0
        L := Min(Low, High)
        H := Max(Low, High)
        return ((Arg) => (Arg >= L) && (Arg <= H))
    }

    /**
     * Returns whether a number is divisible by the given `Num`.
     * @param   {Integer}  Num  the number to divide with
     * @returns {Func}
     */
    static DivisibleBy(Num) {
        if (!IsInteger(Num)) {
            throw TypeError("Expected an Integer",, Type(Num))
        }
        Num := Integer(Num)

        return (x) => !Mod(x, Num)
    }
    ;@endregion

    ;@region String
    /**
     * Evaluates whether a string contains the given `Pattern`.
     * @param   {String}  Pattern  substring to search for
     * @returns {Func}
     */
    static Contains(Pattern) {
        Pattern .= ""
        return ((Str) => InStr(Str, Pattern))
    }

    /**
     * Evaluates whether a string matches with the given regex `Pattern`.
     * @param   {String}  Pattern  regular expression to match with
     * @returns {Func}
     */
    static Matches(Pattern) {
        Pattern .= ""
        return ((Str) => (Str ~= Pattern))
    }
    ;@endregion
}
;@endregion