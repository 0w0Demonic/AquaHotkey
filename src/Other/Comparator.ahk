#Include "%A_LineFile%/../../Classes/Any.ahk"
#Include "%A_LineFile%/../../Classes/Func.ahk"
#Include "%A_LineFile%/../../Classes/Object.ahk"
/**
 * AquaHotkey - Comparator.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Other/Comparator.ahk
 * 
 * **Overview**:
 * 
 * A `Comparator` is a function object used for comparison and sorting, which
 * orders its two arguments by value and returns:
 * 
 * - a positive integer, if `a > b`,
 * - zero, if `a == b`, and
 * - a negative integer, if `a < b`.
 * 
 * @example
 * 
 * ; [unset, "a", "bar", "foo", "Hello, world!"]
 * Array("a", "foo", "bar", "Hello, world!", unset).Sort(
 *      Comparator.Numeric().Compose(StrLen)     ; 1. string length, ascending
 *             .AndThen(Comparator.Alphabetic()) ; 2. alphabetical order
 *             .NullsFirst())                    ; 3. `unset` at the beginning
 */
class Comparator {
    /**
     * Constructs a new `Comparator` from the given callback function `Comp`
     * which compares two elements.
     * @example
     * 
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
     * @return  {Comparator}
     */
    __New(Comp) {
        Comp.AssertCallable()
        this.DefineMethod("Call", (Instance, a?, b?) => Comp(a?, b?))
    }

    /**
     * Returns a new `Comparator` which specifies a second `Comparator` to use
     * whenever two elements as equal in value.
     * @example
     * 
     * ByStringLength := Comparator.Numeric().Compose(StrLen)
     * Alphabetic     := Comparator.Alphabetic()
     * 
     * ; ["", "bar", "foo", "hello"]
     * Array("foo", "bar", "hello", "").Sort(ByStringLength.AndThen(Alphabetic))
     * 
     * @param   {Comparator}  Other  second comparator to be used
     * @return  {Comparator}
     */
    AndThen(Other) {
        Other.AssertCallable()
        return Object().SetBase(ObjGetBase(this)).DefineMethod("Call", (
            (Instance, a?, b?) => (this(a?, b?) || Other(a?, b?))
        ))
    }

    /**
     * Returns a new `Comparator` which first applies the given `Mapper`
     * function on elements to extract a sort key.
     * 
     * `Mapper` is called using each elements as first argument respectively,
     * followed by zero or more additional arguments `Args*`.
     * @example
     * 
     * ByStringLength := Comparator.Numeric().Compose(StrLen)
     * 
     * ; ["", "a", "l9", "foo"]
     * Array("foo", "a", "", "l9").Sort(ByStringLength)
     * 
     * @param   {Func}  Mapper  key extractor function
     * @param   {Any*}  Args    zero or more additional arguments
     * @return  {Comparator}
     */
    Compose(Mapper, Args*) {
        Mapper.AssertCallable()
        return Object().SetBase(ObjGetBase(this)).DefineMethod("Call", (
            (Instance, a?, b?) => this(Mapper(a?, Args*), Mapper(b?, Args*))
        ))
    }

    /**
     * Reverses the order of this `Comparator`.
     * @example
     * 
     * ; [4, 3, 2, 1]
     * Array(4, 2, 3, 1).Sort(Comparator.Numeric().Reversed())
     * 
     * @return  {Comparator}
     */
    Reversed() {
        return Object().SetBase(ObjGetBase(this)).DefineMethod("Call", (
            (Instance, First?, Second?) => this(Second?, First?)
        )).DefineMethod("Reversed", (
            (Instance) => this
        ))
    }

    /**
     * Returns a new `Comparator` which considers `unset` to be lesser than
     * the non-null elements. 
     * @example
     * 
     * NullsFirst := Comparator.Numeric().NullsFirst()
     * 
     * ; [unset, unset, 1, 2, 3, 4]
     * Array(3, 2, 4, unset, 1, unset).Sort(NullsFirst)
     * 
     * @return  {Comparator}
     */
    NullsFirst() {
        return (this.Class)(Callback)

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
     * Returns a new `Comparator` which considers `unset` to be greater than
     * the non-null elements.
     * @example
     * 
     * NullsLast := Comparator.Numeric().NullsLast()
     * 
     * ; [1, 2, 3, 4, unset, unset]
     * Array(3, 4, unset, 1, 2, unset).Sort(NullsLast)
     * 
     * @return  {Comparator}
     */
    NullsLast() {
        return (this.Class)(Callback)

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

    /**
     * Returns a `Comparator` which orders numbers by natural order.
     * @example
     * 
     * Comp := Comparator.Numeric()
     * 
     * ; [1, 2, 3, 4]
     * Array(4, 5, 2, 3, 1).Sort(Comp)
     * 
     * @return  {Comparator}
     */
    static Numeric() {
        return Comparator((A, B) => (A > B) - (B > A))
    }

    /**
     * Returns a `Comparator` which lexicographically orders two strings with
     * the given case sensitivity `CaseSense`.
     * @example
     * 
     * Comp := Comparator.Alphabetic()
     * 
     * ; ["apple", "banana", "kiwi"]
     * Array("kiwi", "apple", "banana").Sort(Comp)
     * 
     * @param   {Boolean/String}  CaseSense  case sensitivity of the comparison
     * @return  {Comparator}
     */
    static Alphabetic(CaseSense := false) {
        return Comparator(StrCompare.Bind(unset, unset, CaseSense))
    }
}
