;@region Combiner
/**
 * AquaHotkey - Combiner.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - Extensions/Collector.ahk
 * 
 * ---
 * 
 * Utility class for functions that reduce or combine two values into one.
 * Suitable for reducers and custom stream-like logic.
 */
class Combiner {
    ;@region General
    /**
     * Returns the smaller of two values through a custom comparator.
     * @param   {Comparator}  Comp  the comparator to use
     * @returns {Func}
     */
    static Min(Comp) {
        GetMethod(Comp)
        return Min

        Min(a, b) {
            if (Comp(a, b) > 0) {
                return b
            }
            return a
        }
    }

    /**
     * Returns the larger of two values through a custom comparator.
     * @param   {Comparator}  Comp  the comparator to use
     */
    static Max(Comp) {
        GetMethod(Comp)
        return Max

        Max(a, b) {
            if (Comp(a, b) < 0) {
                return b
            }
            return a
        }
    }

    /**
     * Always returns the first value.
     * @returns {Func}
     */
    static First => (a, b) => (a)

    /**
     * Always returns the second value.
     * @returns {Func}
     */
    static Last => (a, b) => (b)
    ;@endregion

    ;@region Numeric
    /**
     * Returns the sum of two values.
     * @returns {Func}
     */
    static Sum => (a, b) => (a + b)

    /**
     * Returns the product of two values.
     * @returns {Func}
     */
    static Product => (a, b) => (a * b)
    ;@endregion

    ;@region Strings
    /**
     * Concatenates two strings.
     * @returns {Func}
     */
    static Concat => (a, b) => (a . b)

    /**
     * Concatenates two strings with a delimiter.
     * @param   {String}  Delim  separator string
     * @returns {Func}
     */
    static Concat(Delim) {
        Delim .= ""
        return (a, b) => (a . Delim . b)
    }
    ;@endregion
}