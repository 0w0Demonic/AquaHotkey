#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Func\Comparator.ahk"

; TODO rename to `Compare`/`Comparable`?
; TODO allow generic arrays to be sorted when they contain duck types
; ---- (although this should work because we're putting this into IArray)
; ------------

/**
 * Introduces an interface for imposing the natural order between two
 * types. This is useful for sorting arrays and other collections.
 * 
 * This feature is exposed via the `.Compare()` method, which is implemented
 * for some of the built-in types like `String`, `Number` and `Array`.
 * 
 * ---
 * 
 * Any type that defines `.Compare()` is considered *comparable*, which
 * grants the following advantages:
 * 
 * - arrays are sortable without a custom {@link Comparator};
 * - instances of that type can be used as key inside an ordered
 *   collection such as {@link SkipListMap} or {@link SkipListSet};
 * - access to ordering functions such as `.Gt()` and `.Lt()`.
 * 
 * ```ahk
 * Arr := ["pear", "banana", "apple", "dragonfruit"]
 * Arr.Sort() ; ["apple", "banana", "dragonfruit", "pear"]
 * 
 * ; --> ["bar", "baz", "foo", "qux"]
 * SkipListSet("foo", "bar", "baz", "qux").ToArray()
 * ```
 * 
 * ---
 * 
 * The `.Compare()` method must adhere to the following rules:
 * 
 * - takes one parameter `Other`, which is *strictly* the same type as `this`.
 *   this also forbids type coercion like `"123"` (string) into `123` (number);
 * - `Other` is a mandatory parameter and not allowed to be `unset`;
 * - returns...
 *    - a negative integer, if `this < Other`;
 *    - `0`, if `this == Other`;
 *    - a positive integer, if `this > Other`.
 * 
 * It is **strongly** recommended - but not mandatory - that if
 * `A.Compare(B) == 0`, then `A.Eq(B)` (see {@link AquaHotkey_Eq `.Eq()`}).
 * Otherwise, sorted sets or maps might behave "strangely", because they are
 * defined in terms of `.Eq()`.
 * 
 * ---
 * 
 * **Example**:
 * 
 * ```ahk
 * class Version {
 *     __New(Major, Minor, Patch) {
 *         this.Major := Major
 *         this.Minor := Minor
 *         this.Patch := Patch
 *     }
 * 
 *     Compare(Other) {
 *         if (!(Other is Version)) {
 *             throw TypeError("Expected a Version",, Type(Other))
 *         }
 *         ; NOTE: logical OR (`||`) works, because the method should
 *         ;       return `0` whenever both values are equal, and therefore
 *         ;       the expression is evaluated to `false`.
 *         return (this.Major).Compare(Other.Major)
 *             || (this.Minor).Compare(Other.Minor)
 *             || (this.Patch).Compare(Other.Patch)
 *     }
 * }
 * ``` 
 * 
 * ---
 * 
 * To ensure both values are instances of a type `T`, you can use
 * `T.Compare(A, B)`. This asserts that both `A` and `B` are instances of the
 * calling class `T`.
 * 
 * In the example above, the return statement can be rewritten to assert that
 * all three fields are `Integer`s:
 * 
 * ```ahk
 * return Integer.Compare(this.Major, Other.Major)
 *     || Integer.Compare(this.Minor, Other.Minor)
 *     || Integer.Compare(this.Patch, Other.Patch)
 * ```
 * 
 * Because {@link AquaHotkey_DuckTypes duck types} might not necessarily
 * inherit the proper `.Compare()` method, you must implement a custom
 * `static Compare()` for the duck type. These overrides should use
 * {@link AquaHotkey_DuckTypes.Any#Is `.Is()`} for type-checking.
 * 
 * ```ahk
 * ; duck type for numbers and numeric strings
 * class Numeric {
 *     static IsInstance(Val?) => IsSet(Val) && IsNumber(Val)
 * 
 *     static Compare(A, B) {
 *         if (A.Is(this) && B.Is(this)) {
 *             return ( Number(A) ).Compare( Number(B) )
 *         }
 *         throw TypeError("Expected a(n) " . this.Name,,
 *                         Type(A) . " " . Type(B))
 *     }
 * }
 * ```
 * 
 * Lastly, `*ClassObject*.Compare` returns a {@link Comparator} which can be
 * conveniently used as configuration inside ordered collections, or as
 * parameter for `.Sort()` methods. `Any.Compare` is type-agnostic, meaning
 * "use any natural ordering, if present".
 * 
 * ```ahk
 * Arr := ["24.2", 45, 0, "0", 22.0, "-3"]
 * 
 * ; e.g.: ("0", 0) => (true).Compare(false) => 1.Compare(0) => 1
 * NumbersFirst(A, B) => (A is String).Compare(B is String)
 * 
 * Arr.Sort( (Numeric.Compare).Then(NumbersFirst) )
 * ; -> ["-3", 0, "0", 22.0, "24.2", 45]
 * ;           ^ (number zero comes before string zero)
 * ```
 * 
 * @module  <Base/Ord>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @see {@link Comparator}
 * @see {@link SkipListMap}
 * @see {@link SkipListSet}
 * @see {@link AquaHotkey_DuckTypes duck types}
 * @see {@link AquaHotkey_Eq `.Eq()`}
 * @example
 * ; result: [1.98, 23, 123, 3455]
 * Array(123, 23, 1.98, 3455).Sort()
 * 
 * ; -1
 * Number.Compare(-1, 2)
 * 
 * ; TypeError! Expected an String.
 * "123".Compare(123)
 * 
 * ; TypeError! Expected an Array.
 * Array.Compare(1, 2)
 */
class AquaHotkey_Ord extends AquaHotkey
{
    ;@region Any
    class Any {
        /**
         * Unsupported `.Compare()` method.
         * 
         * @param   {Any}  Other  any value
         * @returns {Integer}
         */
        Compare(Other) {
            throw PropertyError("Not applicable for this type",, Type(this))
        }

        /**
         * Determines whether this value has a natural ordering greater than
         * the other value.
         * 
         * @param   {Any}  Other  other value
         * @returns {Boolean}
         * @example
         * ([1, 2]).Gt([1, 1]) ; true
         */
        Gt(Other) => (this.Compare(Other) > 0)

        /**
         * Determines whether this value has a natural ordering greater than
         * or equal to the other value.
         * 
         * @param   {Any}  Other  other value
         * @returns {Boolean}
         * @example
         * "foo".Ge("foo") ; true
         */
        Ge(Other) => (this.Compare(Other) >= 0)

        /**
         * Determines whether this value has a natural ordering equal to
         * the other value. Unlike `.Eq()`, this method does NOT check actual
         * object equality.
         * 
         * **NOTE**:
         * 
         * This method should *usually* be obsolete, because it's strongly
         * recommended that if `A.Eq(B)`, then also `A.OrdEq(B)`.
         * 
         * @param   {Any}  Other  other value
         * @returns {Boolean}
         * @example
         * (123).OrdEq(123) ; true
         */
        OrdEq(Other) => (this.Compare(Other) == 0)

        /**
         * Determines whether this value has a natural ordering that is not equal
         * to the other value, i.e. whether the value is greater or less than the
         * other.
         * 
         * **NOTE**:
         * 
         * This method should *usually* be obsolete, because it's strongly
         * recommended that if `A.Ne(B)`, then also `A.OrdNe(B)`.
         * 
         * @param   {Any}  Other  other value
         * @returns {Boolean}
         * @example
         * (123).OrdNe(42) ; true
         */
        OrdNe(Other) => (this.Compare(Other) != 0)

        /**
         * Determines whether this value has a natural ordering less than or equal
         * to the other value.
         * 
         * @param   {Any}  Other  other value
         * @returns {Boolean}
         * @example
         * (123).Le(123) ; true
         */
        Le(Other) => (this.Compare(Other) <= 0)

        /**
         * Determines whether this value has a natural ordering less than the
         * other value.
         * 
         * @param   {Any}  Other  other value
         * @returns {Boolean}
         * @example
         * (123).Lt(42) ; false
         */
        Lt(Other) => (this.Compare(Other) < 0)
    }
    ;@endregion

    ;@region Number
    class Number {
        /**
         * Compares this number with another number. Numeric strings are not
         * accepted by this method.
         * 
         * @example
         * (123).Compare(23.8723) ; 1
         * 
         * @param   {Number}  Other  any number
         * @returns {Integer}
         */
        Compare(Other) {
            if (!(Other is Number)) {
                throw TypeError("Expected a(n) " . Type(this),,
                                Type(Other))
            }
            return (this > Other) - (Other > this)
        }
    }
    ;@endregion

    ;@region String
    class String {
        /**
         * Compares this string with another string via case-insensitive
         * string comparison.
         * 
         * @example
         * "foo".Compare("bar") ; 1
         * 
         * @param   {String}  Other  any string
         * @returns {Integer}
         */
        Compare(Other) {
            if (!(Other is String)) {
                throw TypeError("Expected a String",, Type(Other))
            }
            return StrCompare(this, Other)
        }
    }
    ;@endregion

    ; TODO change to IArray?
    ;@region Array
    class Array {
        /**
         * Compares this array with another array. This is done by comparing its
         * elements.
         * 
         * @param   {Array}  Other  any array
         * @returns {Integer}
         * @example
         * ([1, 2, 3]).Compare([1, 2, 4]) ; -1
         */
        Compare(Other) {
            if (!(Other is Array)) {
                throw TypeError("Expected an Array",, Type(Other))
            }
            ThisEnumer := this.__Enum(1)
            OtherEnumer := Other.__Enum(1)

            loop {
                AHasElements := !!ThisEnumer(&A)
                BHasElements := !!OtherEnumer(&B)

                if (AHasElements) {
                    if (!BHasElements) {
                        return 1 ; this array has more elements -> (this > other)
                    }
                    Result := A.Compare(B)
                    if (Result) {
                        return Result
                    }
                } else { ; (!AHasElements)
                    if (BHasElements) {
                        return -1 ; other array has more elements -> (this < other)
                    }
                    return 0
                }
            }
        }
    }
    ;@endregion

    ;@region Class
    class Class {
        /**
         * Returns a type-checked comparison function.
         * 
         * @returns {Func}
         * @example
         * MyArray.Sort(String.Compare)
         */
        Compare => Comparator(ObjBindMethod(this, "Compare"))
        ; note: defined in <Func/Cast>

        /**
         * Compares two values by order. This method is type-checked, meaning
         * that both inputs are assured to be instances of the calling class.
         * 
         * @param   {Any}  A  first value
         * @param   {Any}  B  second value
         * @returns {Integer}
         * @example
         * String.Compare("foo", "bar")       ; 4
         * String.Compare([1, 2], Buffer(16)) ; TypeError!
         */
        Compare(A, B) {
            ; NOTE: using the same method name is fine, because `Class`
            ;       is not comparable.
            if ((A is this) && (B is this)) {
                return A.Compare(B)
            }
            throw TypeError("Expected a(n) " . this.Prototype.__Class,,
                            Type(A) . ", " . Type(B))
        }
    }
    ;@endregion
}