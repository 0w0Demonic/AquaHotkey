#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

#Include <AquaHotkey\src\Func\Cast>

/**
 * A comparator is a function that determines a natural ordering between its
 * two input values. This is mainly used for creating custom sorting logic.
 * 
 * @module  <Func/Comparator>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * 
 * ; 1. string length, 2. alphabetical order, 3. `unset` in the front
 * Comp := Comparator.Num(StrLen).ThenAlpha().NullsFirst()
 * 
 * ; [unset, "a", "b", "example"]
 * Array("example", "b", "a", unset).Sort(Comp)
 */
class Comparator extends Func {
    static __New() {
        if (this == Comparator) {
            ObjSetBase(StrCompare, Comparator.Prototype)
        }
    }

    /**
     * Returns a numeric comparator.
     * 
     * @returns {Comparator}
     * @example
     * (Comparator.Num)(2, 4) ; -1
     */
    static Num => this.Num()

    /**
     * Returns a numeric comparator.
     * 
     * @param   {Func?}  Mapper  function retrieving sort key
     * @param   {Any*}   Args    zero or more arguments
     * @returns {Comparator}
     * @example
     * ByStrLen := Comparator.Num(StrLen)
     */
    static Num(Mapper?, Args*) {
        static Comp := this((A, B) => (A > B) - (B > A))
        if (!IsSet(Mapper)) {
            return Comp
        }
        return Comp.By(Mapper, Args*)
    }

    /**
     * Returns an alphabetical comparator.
     * 
     * @returns {Comparator}
     */
    static Alpha => this.Alpha()

    /**
     * Returns an alphabetical comparator.
     * 
     * @param   {Primitive?}  CaseSense  case sensitivity
     * @param   {Func?}       Mapper     function retrieving sort key
     * @param   {Any*}        Args       zero or more arguments
     */
    static Alpha(CaseSense := false, Mapper?, Args*) {
        StrComp(A, B) => StrCompare(A, B, CaseSense)

        if (IsObject(CaseSense)) {
            throw TypeError("Expected a String or an Integer",, Type(CaseSense))
        }
        this.Cast(StrComp)
        if (!IsSet(Mapper)) {
            return StrComp
        }
        return StrComp.By(Mapper, Args*)
    }

    /**
     * Returns a comparator that first retrieves a sort key using the given
     * `Mapper` function, then performs natural comparison (`.Compare()`).
     * 
     * @param   {Func}  Mapper  function retrieving sort key
     * @param   {Any*}  Args    zero or more arguments
     * @returns {Comparator}
     * @example
     * Comparator.By(StrLen).ThenAlpha()
     */
    static By(Mapper, Args*) {
        return this.Cast(Comp)
        Comp(A?, B?) => Mapper(A?, Args*).Compare(Mapper(B?, Args*))
    }

    /**
     * Returns a comparator that first uses the given `Mapper` to extract a
     * sort key from both input values to be compared.
     * 
     * @param   {Func}  Mapper  function retrieving sort key
     * @returns {Comparator}
     * @example
     * Comp := Comparator.Num().By(StrLen)
     */
    By(Mapper, Args*) {
        return this.Cast(Comp)
        Comp(A?, B?) => this(Mapper(A?, Args*), Mapper(B?, Args*))
    }

    /**
     * Returns a comparator that first uses the current, and then the other
     * specified comparator if both values are considered equal.
     * 
     * @param   {Comparator}  Other  the other comparator
     * @returns {Comparator}
     * @example
     * Comp := Comparator.Num(StrLen).Then(Comparator.Alpha)
     */
    Then(Other) {
        return this.Cast(Comp)
        Comp(A?, B?) => this(A?, B?) || Other(A?, B?)
    }

    /**
     * Returns a comparator that first uses the current comparator, and then
     * natural comparison (`.Compare()`) by using a `Mapper` to retrieve sort
     * keys.
     * 
     * @param   {Func}  Mapper  function retrieving sort key
     * @param   {Any*}  Args    zero or more arguments
     * @returns {Comparator}
     * @example
     * Comparator.By(StrLen).ThenAlpha()
     */
    ThenBy(Mapper, Args*) {
        return this.Cast(Comp)
        Comp(A?, B?) => this(A?, B?)
                     || (Mapper(A?, Args*).Compare(Mapper(B?, Args*)))
    }

    /**
     * Shorthand for `.AndThen(Comparator.Num())`.
     * 
     * @param   {Func?}  Mapper  function retrieving sort key
     * @param   {Any*}   Args    zero or more arguments
     * @returns {Comparator}
     */
    ThenNum(Mapper?, Args*) => this.Then(Comparator.Num(Mapper?, Args*))

    /**
     * Shorthand for `.AndThen(Comparator.Alpha())`.
     * 
     * @param   {Func?}  Mapper  function retrieving sort key
     * @param   {Any*}   Args    zero or more arguments
     * @returns {Comparator}
     */
    ThenAlpha(Mapper?, Args*) => this.Then(Comparator.Alpha(Mapper?, Args*))

    /**
     * Returns the current comparator in reverse order.
     * 
     * @returns {Comparator}
     * @example
     * ByStrLen_Desc := Comparator.Num(StrLen).Rev()
     */
    Rev() {
        return this.Cast(Comp)
        Comp(A?, B?) => this(B?, A?)
    }

    /**
     * Returns a comparator that considers `unset` to be lesser than any other
     * value.
     * 
     * This method should be called last when creating a comparator.
     * 
     * @returns {Comparator}
     */
    NullsFirst() {
        return this.Cast(Comp)
        Comp(A?, B?) {
            if (IsSet(A)) {
                if (IsSet(B)) {
                    return this(A?, B?)
                }
                return 1
            }
            if (IsSet(B)) {
                return -1
            }
            return 0
        }
    }

    /**
     * Returns a comparator that considers `unset` to be greater than any
     * other value.
     * 
     * This method should be called last when creating a comparator.
     * 
     * @returns {Comparator}
     */
    NullsLast() {
        return this.Cast(Comp)
        Comp(A?, B?) {
            if (IsSet(A)) {
                if (IsSet(B)) {
                    return this(A?, B?)
                }
                return -1
            }
            if (IsSet(B)) {
                return 1
            }
            return 0
        }
    }
}
