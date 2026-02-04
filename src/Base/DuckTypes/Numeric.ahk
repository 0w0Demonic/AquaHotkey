/**
 * @duck
 * 
 * A number or numeric string (as determined by `IsNumber()`).
 * 
 * @module  <Base/DuckTypes/Numeric>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * "42".Is(Numeric) ; true
 * 
 * ; true (every `Integer` is also `Numeric`)
 * Numeric.CanCastFrom(Integer)
 * 
 * ; --> ["-23", 1, 23, "43"]
 * Arr(1, 23, "43", "-23").Sort(Numeric.Compare)
 */
class Numeric {
    /**
     * Determines whether the value is numeric.
     * 
     * @param   {Any}  Val  any value
     * @returns {Boolean}
     * @example
     * "example".Is(Numeric)     ; false
     * Numeric.IsInstance("123") ; true
     */
    static IsInstance(Val?) => IsSet(Val) && IsNumber(Val)

    /**
     * Determines whether the given value is equal to this class,
     * or its subclass.
     * 
     * @param   {Class}  T  any class
     * @returns {Boolean}
     * @example
     * Numeric.CanCastFrom(Numeric) ; true
     * Numeric.CanCastFrom(Integer) ; true (every integer is numeric)
     */
    static CanCastFrom(T) {
        return super.CanCastFrom(T) || Number.CanCastFrom(T)
    }

    /**
     * Compares two numeric values by order.
     * 
     * @param   {Numeric}  A  value 1
     * @param   {Numeric}  B  value 2
     * @returns {Integer}
     * @see {@link Comparator}
     * @see {@link AquaHotkey_Ord}
     * @example
     * Numeric.Compare("42", 42) ; 0 (same value)
     */
    static Compare(A, B) {
        if (IsNumber(A) && IsNumber(B)) {
            return (A > B) - (B > A)
        }
        throw TypeError("Expected a " . this.Name,, Type(A) . ", " . Type(B))
    }
}