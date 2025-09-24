/**
 * AquaHotkey - Comparator.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/Comparator.ahk
 * 
 * ---
 * 
 * **Overview**:
 * 
 * Comparators are functions that decide a natural ordering between two
 * elements `a` and `b`. Return values are specified such that...
 * 
 * - a positive integer, if `a > b`,
 * - zero, if `a == b`, and
 * - a negative integer, if `a < b`.
 * 
 * @example
 * ; [unset, "a", "bar", "foo", "Hello, world!"]
 * Array("a", "foo", "bar", "Hello, world!", unset).Sort(
 *      Comparator.Numeric(StrLen)  ; 1. string length, ascending
 *             .AndThenAlphabetic() ; 2. alphabetical order
 *             .NullsFirst())       ; 3. `unset` at the beginning
 */
class Comparator {
    ;@region Construction
    /**
     * Creates a new comparator using the given function for comparing
     * function.
     * 
     * @example
     * Callback(a, b) {
     *     if (a > b) {
     *         return 1
     *     }
     *     if (a < b) {
     *         return -1
     *     }
     *     return 0
     * }
     * NumericalComparator := Comparator(Callback)
     * 
     * @param   {Func}  Comp  function that compares two elements
     * @returns {Comparator}
     */
    __New(Comp) {
        GetMethod(Comp)
        this.DefineProp("Call", { Call: (_, a?, b?) => Comp(a?, b?) })
    }

    /**
     * Returns a default numerical comparator.
     * 
     * @returns {Comparator}
     */
    static Numeric => this.Numeric()

    /**
     * Returns a comparator that orders numbers by natural order.
     * 
     * If present, the comparator first extracts a sort key on the element by
     * using the `Mapper` function and zero or more additional arguments.
     * 
     * @example
     * Comp := Comparator.Numeric()
     * 
     * ; [1, 2, 3, 4]
     * Array(4, 5, 2, 3, 1).Sort(Comp)
     * 
     * @param   {Func?}  Mapper  key extractor function
     * @param   {Any*}   Args    zero or more additional arguments
     * @returns {Comparator}
     */
    static Numeric(Mapper?, Args*) {
        Comp := Comparator((A, B) => (A > B) - (B > A))
        if (!IsSet(Mapper)) {
            return Comp
        }
        return Comp.Compose(Mapper, Args*)
    }

    /**
     * Returns a default lexicographical comparator.
     * 
     * @returns {Comparator}
     */
    static Alphabetic => this.Alphabetic()

    /**
     * Returns a comparator that lexicographically orders two strings using
     * `StrCompare`.
     * 
     * If present, the comparator first extracts a sort key on the element by
     * using the `Mapper` function and zero or more additional arguments.
     * 
     * @example
     * Comp := Comparator.Alphabetic()
     * 
     * ; ["apple", "banana", "kiwi"]
     * Array("kiwi", "apple", "banana").Sort(Comp)
     * 
     * @param   {Boolean/String}  CaseSense  case sensitivity
     * @param   {Func?}           Mapper     key extractor function
     * @param   {Any*}            Args       zero or more additional arguments
     * @returns {Comparator}
     */
    static Alphabetic(CaseSense := false, Mapper?, Args*) {
        Comp := Comparator(StrCompare.Bind(unset, unset, CaseSense))
        if (!IsSet(Mapper)) {
            return Comp
        }
        return Comp.Compose(Mapper, Args*)
    }
    ;@endregion

    ;@region Composition
    /**
     * Returns a new comparator which specifies a second comparator to use
     * whenever two elements as equal in value.
     * 
     * @example
     * ByStringLength := Comparator.Numeric(StrLen)
     * Alphabetic     := Comparator.Alphabetic()
     * 
     * ; ["", "bar", "foo", "hello"]
     * Array("foo", "bar", "hello", "").Sort(ByStringLength.AndThen(Alphabetic))
     * 
     * @param   {Comparator}  Other  second comparator to be used
     * @returns {Comparator}
     */
    AndThen(Other) {
        GetMethod(Other)
        Obj := Object()
        ObjSetBase(Obj, ObjGetBase(this))
        Obj.DefineProp("Call", {
            Call: (_, a?, b?) => (this(a?, b?) || Other(a?, b?))
        })
        return Obj
    }

    /**
     * Specifies a numeric comparator to be used whenever two elements are
     * equal in value.
     * 
     * @example
     * Comparator.Alphabetic(FirstLetter).AndThenNumeric()
     * 
     * @param   {Any*}  Args  arguments passed to numeric comparator
     * @returns {Func}
     */
    AndThenNumeric(Args*) => this.AndThen(Comparator.Numeric(Args*))

    /**
     * Specifies an alphabetic comparator to be used whenever two elements are
     * equal in value.
     * 
     * @example
     * ByStrLen := Comparator.Numeric(StrLen).AndThenAlphabetic()
     * 
     * @param   {Any*}  Args  arguments passed to alphabetic comparator
     * @returns {Func}
     */
    AndThenAlphabetic(Args*) => this.AndThen(Comparator.Alphabetic(Args*))

    /**
     * Returns a new comparator which first applies the given `Mapper`
     * function on elements to extract a sort key.
     * 
     * `Mapper` is called using each elements as first argument respectively,
     * followed by zero or more additional arguments `Args*`.
     * 
     * @example
     * ; easier alternative: `Comparator.Numeric(StrLen)`
     * ByStringLength := Comparator.Numeric().Compose(StrLen)
     * 
     * ; ["", "a", "l9", "foo"]
     * Array("foo", "a", "", "l9").Sort(ByStringLength)
     * 
     * @param   {Func}  Mapper  key extractor function
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {Comparator}
     */
    Compose(Mapper, Args*) {
        GetMethod(Mapper)
        Obj := Object()
        ObjSetBase(Obj, ObjGetBase(this))
        Obj.DefineProp("Call", {
            Call: (_, a?, b?) => (
                this(Mapper(a?, Args*), Mapper(b?, Args*))
            )
        })
        return Obj
    }

    /**
     * Reverses the order of the comparator.
     * 
     * @example
     * ; [4, 3, 2, 1]
     * Array(4, 2, 3, 1).Sort(Comparator.Numeric().Reversed())
     * 
     * @returns {Comparator}
     */
    Reversed() {
        Obj := Object()
        ObjSetBase(Obj, ObjGetBase(this))
        Obj.DefineProp("Call", {
            Call: (_, First?, Second?) => this(Second?, First?)
        })
        Obj.DefineProp("Reversed", { Call: ((*) => this) })
        return Obj
    }
    ;@endregion

    ;@region Unset Handling
    /**
     * Returns a new comparator that considers `unset` to be lesser than the
     * non-null elements.
     * 
     * @example
     * NullsFirst := Comparator.Numeric().NullsFirst()
     * 
     * ; [unset, unset, 1, 2, 3, 4]
     * Array(3, 2, 4, unset, 1, unset).Sort(NullsFirst)
     * 
     * @returns {Comparator}
     */
    NullsFirst() {
        Comp := Object()
        ObjSetBase(Comp, ObjGetBase(this))
        Comp.__New(Callback)
        return Comp

        Callback(First?, Second?) {
            if (IsSet(First)) {
                if (IsSet(Second)) {
                    return this(First?, Second?)
                }
                return 1
            }
            if (IsSet(Second)) {
                return -1
            }
            return 0
        }
    }

    /**
     * Returns a new comparator that consider `unset` to be greater than the
     * non-null elements.
     * 
     * @example
     * NullsLast := Comparator.Numeric().NullsLast()
     * 
     * ; [1, 2, 3, 4, unset, unset]
     * Array(3, 4, unset, 1, 2, unset).Sort(NullsLast)
     * 
     * @returns {Comparator}
     */
    NullsLast() {
        Comp := Object()
        ObjSetBase(Comp, ObjGetBase(this))
        Comp.__New(Callback)
        return Comp

        Callback(First?, Second?) {
            if (IsSet(First)) {
                if (IsSet(Second)) {
                    return this(First?, Second?)
                }
                return -1
            }
            if (IsSet(Second)) {
                return 1
            }
            return 0
        }
    }
    ;@endregion
}
