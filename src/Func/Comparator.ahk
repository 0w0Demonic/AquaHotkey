#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

; TODO introduce this as new `Comparator`

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
    /**
     * Creates a new comparator from the function to be called.
     * 
     * @param   {Func|Object}  Obj  any callable object
     * @returns {Comparator}
     * @example
     * Comp := Comparator((A, B) => (A > B) - (B > A))
     */
    static Call(Obj) {
        GetMethod(Obj)
        Fn := ObjBindMethod(Obj)
        ObjSetBase(Fn, this.Prototype)
        return Fn
    }

    /**
     * Casts a function object into a comparator.
     * 
     * @param   {Func}  Fn  function object
     * @returns {Comparator}
     * @example
     * Comparator.Cast(StrCompare)
     */
    static Cast(Fn) {
        if (!(Fn is Func)) {
            throw TypeError("Expected a Func",, Type(Fn))
        }
        ObjSetBase(Fn, this.Prototype)
        return Fn
    }

    /**
     * Like `Func#Bind()`, but the result is a comparator.
     * 
     * @param   {Any*}  Args  zero or more arguments
     * @returns {Comparator}
     */
    Bind(Args*) {
        Fn := super.Bind(Args*)
        ObjSetBase(Fn, ObjGetBase(this))
        return Fn
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
        Comp(A?, B?) => Mapper(A?, Args*).Compare(Mapper(B?, Args*))

        GetMethod(Mapper)
        ObjSetBase(Comp, ObjGetBase(this))
        return Comp
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
        Comp(A?, B?) => this(Mapper(A?, Args*), Mapper(B?, Args*))

        GetMethod(Mapper)
        ObjSetBase(Comp, ObjGetBase(this))
        return Comp
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
        Comp(A?, B?) => this(A?, B?) || Other(A?, B?)
        GetMethod(Other)
        ObjSetBase(Comp, ObjGetBase(this))
        return Comp
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
        Comp(A?, B?) => this(A?, B?)
                     || (Mapper(A?, Args*).Compare(Mapper(B?, Args*)))

        GetMethod(Mapper)
        ObjSetBase(Comp, ObjGetBase(this))
        return Comp
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
        Comp(A?, B?) => this(B?, A?)
        ObjSetBase(Comp, ObjGetBase(this))
        ({}.DefineProp)(Comp, "Rev", {
            Call: (_) => this
        })
        return Comp
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
        ObjSetBase(Comp, ObjGetBase(this))
        return Comp
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
        ObjSetBase(Comp, ObjGetBase(this))
        return Comp
    }
}

/**
 * Introduces changes related to comparators, most noteably changing the base
 * of `StrCompare` to become a comparator.
 */
class AquaHotkey_Comparator extends AquaHotkey
{
    static __New() {
        ObjSetBase(StrCompare, Comparator.Prototype)
        super.__New()
    }

    class StrCompare {
        static Locale => Comparator((A, B) => this(A, B, "Locale"))
        static Locale(A, B) => this(A, B, "Locale")

        static CS => Comparator((A, B) => this(A, B, true))
        static CS(A, B) => this(A, B, true)

        static CI => Comparator((A, B) => this(A, B, false))
        static CI(A, B) => this(A, B, false)
    }
}
