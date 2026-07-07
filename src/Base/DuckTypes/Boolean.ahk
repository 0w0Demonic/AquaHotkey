#Include "%A_LineFile%\..\..\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\Comparable.ahk"

/**
 * @duck
 * 
 * A boolean value that equals either `true`/`1` or `false`/`0`.
 * 
 * @module  <Base/DuckTypes/Boolean>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Boolean extends Integer {
    /**
     * Determines whether the input value is considered a boolean.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * (true).Is(Boolean) ; true
     * (false).Is(Boolean) ; true
     * 
     * (0).Is(Boolean) ; true
     * (1).Is(Boolean) ; true
     */
    static IsInstance(Val?) => Integer.IsInstance(Val?)
            && ((Val == true) || (Val == false))

    /**
     * Creates a boolean value from an arbitrary value.
     * 
     * @param   {Any}  Val  any value
     * @returns {Boolean?}
     * @example
     * Boolean("foo") ; true
     * Boolean(0)     ; false
     */
    static Call(Val?) => IsSet(Val) && !!Val

    /**
     * Compares two boolean values. `true` is considered greater than `false`
     * (similar to their actual values `1` and `0`).
     * 
     * @param   {Boolean}  A  first boolean
     * @param   {Boolean}  B  second boolean
     * @returns {Integer}
     */
    static Compare(A, B) {
        if (this.IsInstance(A) && this.IsInstance(B)) {
            return A.Compare(B)
        }
        throw TypeError("Expected a(n) " . this.Prototype.__Class,,
                        Type(A) . ", " . Type(B))
    }
}
