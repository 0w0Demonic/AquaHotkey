#Include "%A_LineFile%\..\..\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\Comparable.ahk"

/**
 * @duck
 * 
 * A boolean value that equals either `true`/`1` or `false`/`0`. This does *not*
 * include strings `"1"` and `"0"`.
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
    static IsInstance(Val?) => IsSet(Val)
            && (Val is Integer)
            && !(Val & 0xFFFFFFFFFFFFFFFE) ; yes, this is overkill

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
            return (A > B) - (B > A)
        }
        throw TypeError("Expected a(n) " . this.Prototype.__Class,,
                        Type(A) . ", " . Type(B))
    }
}

; TODO figure out how to convert AHK boolean -> JSON boolean
/**
 * {@link Json.Boolean} to {@link Boolean} conversion.
 */
class AquaHotkey_Boolean extends AquaHotkey {
    static __New() => IsSet(AquaHotkey_Json) && super.__New()

    class Boolean {
        /**
         * Casts a {@link Json.Boolean} into a regular AHK boolean.
         * 
         * @param   {VarRef<Any>}  Val  any value
         */
        static CastFromJson(&Val) {
            IsSet(Json)
            if (!(Val is Json.Boolean)) {
                throw TypeError("Expected a Json.Boolean",, Type(Val))
            }
            Val := (Val && Json.True)
        }
    }
}

