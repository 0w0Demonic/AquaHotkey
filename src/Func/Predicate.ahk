#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

;@region Predicate

; TODO `.AsAssertion()` method?

/**
 * A predicate is a function that takes one input and returns a boolean
 * value (`true` or `false`) based on a condition.
 * 
 * @module  <Func/Predicate>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Predicate extends Func {
    static __New() {
        if (this != Predicate) {
            return
        }
        ; convert global functions that are most usually used as predicate
        ; functions into our `Predicate` type
        for Fn in [IsInteger, IsFloat, IsNumber, IsObject, IsLabel, IsSetRef,
                   IsDigit, IsXDigit, IsAlpha, IsUpper, IsLower, IsAlnum,
                   IsSpace, IsTime, DirExist, FileExist, ProcessExist] {
            this.Cast(Fn)
        }
    }

    /**
     * Negates a predicate.
     * 
     * @param   {Predicate}  P  a predicate function
     * @returns {Predicate}
     * @example
     * Predicate.Not(IsNumber) ; (x) => !IsNumber(x)
     */
    static Not(P) => this(P).Negate()

    /**
     * Composes a predicate that only returns `true`, if all of the specified
     * predicates evaluate to `true`.
     * 
     * @param   {Predicate*}  Fns  one or more predicates
     * @returns {Predicate}
     * @example
     * InRange := Predicate.All(
     *     InstanceOf(Numeric),
     *     Gt(5), Lt(10)
     * )
     */
    static All(Fns*) {
        if (!Fns.Length) {
            throw UnsetError("No predicates specified")
        }
        for Fn in Fns {
            GetMethod(Fn)
        }
        return this.Cast(All)

        All(Val?) {
            for Fn in Fns {
                if (!Fn(Val?)) {
                    return false
                }
            }
            return true
        }
    }

    /**
     * Composes a predicate that only returns `true`, if none of the specified
     * predicates evaluates to `true`.
     * 
     * @param   {Predicate*}  Fns  one or more predicates
     * @returns {Predicate}
     */
    static None(Fns*) {
        if (!Fns.Length) {
            throw UnsetError("No predicates specified")
        }
        for Fn in Fns {
            GetMethod(Fn)
        }
        return this.Cast(None)

        None(Val?) {
            for Fn in Fns {
                if (Fn(Val?)) {
                    return false
                }
            }
            return true
        }
    }

    /**
     * Composes a predicate that only returns `true`, if any of the specified
     * predicates evaluates to `true`.
     * 
     * @param   {Predicate*}  Fns  one or more predicates
     * @returns {Predicate}
     */
    static Any(Fns*) {
        if (!Fns.Length) {
            throw UnsetError("No predicates specified")
        }
        for Fn in Fns {
            GetMethod(Fn)
        }
        return this.Cast(Any)

        Any(Val?) {
            for Fn in Fns {
                if (Fn(Val?)) {
                    return true
                }
            }
            return false
        }
    }

    /**
     * Combines this predicate and the `Other` through AND.
     * 
     * @param   {Predicate}  Other  other predicate
     * @param   {Any*}       Args   zero or more arguments for `Other`
     * @returns {Predicate}
     * @example
     * NumericString := InstanceOf(String).And(IsNumber)
     */
    And(Other, Args*) {
        GetMethod(Other)
        return this.Cast((Val?) => (this(Val?) && Other(Val?, Args*)))
    }

    /**
     * Combines this predicate and the `Other` through NAND.
     * 
     * @param   {Predicate}  Other  other predicate
     * @param   {Any*}       Args   zero or more arguments for `Other`
     * @returns {Predicate}
     * @returns {Predicate}
     */
    AndNot(Other, Args*) {
        GetMethod(Other)
        return this.Cast((Val?) => (this(Val?) && !Other(Val?, Args*)))
    }

    /**
     * Combines this predicate and the `Other` through OR.
     * 
     * @param   {Predicate}  Other  other predicate
     * @param   {Any*}       Args   zero or more arguments for `Other`
     * @returns {Predicate}
     */
    Or(Other, Args*) {
        GetMethod(Other)
        return this.Cast((Val?) => (this(Val?) || Other(Val?, Args*)))
    }
    
    /**
     * Combines this predicate and the `Other` through NOR.
     * 
     * @param   {Predicate}  Other  other predicate
     * @param   {Any*}       Args   zero or more arguments for `Other`
     * @returns {Predicate}
     */
    OrNot(Other, Args*) {
        GetMethod(Other)
        return this.Cast((Val?) => (this(Val?) || !Other(Val?, Args*)))
    }

    /**
     * Negates the predicate.
     * 
     * @returns {Predicate}
     * @example
     * P := IsNumber.Negate()
     */
    Negate() {
        Pred := this.Cast((Val?) => (!this(Val?)))
        Pred.DefineProp("Negate", { Call: (_) => this })
        return Pred
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Type Info

/**
 * Returns a {@link Predicate} that determines whether the input is instance
 * of the given type {@link AquaHotkey_DuckTypes `.Is()`}.
 * 
 * @param   {Any}  T  type pattern
 * @returns {Predicate}
 * @see {@link AquaHotkey_DuckTypes `.Is()`}
 * @example
 * ; <34, "234.3">
 * Array("a", [1, 2], 34, "234.3").Stream().RetainIf(InstanceOf(Numeric))
 */
InstanceOf(T) => Predicate.Cast((Val?) => T.IsInstance(Val?))

/**
 * Returns a {@link Predicate} that determines whether the input is derived
 * from the prototype of a given class. This is equivalent to the `is` keyword.
 * 
 * @param   {Class}  Cls  a class object
 * @returns {Predicate}
 */
DerivesFrom(Cls) => Predicate.Cast((Val?) => IsSet(Val) && (Val is Cls))

;@endregion
;-------------------------------------------------------------------------------
;@region Ordering

; TODO let the comparison predicates (`Gt()`, etc.) be able to use some of the
;      `Comparator` functionalities?

/**
 * Returns a {@link Predicate} that determines whether the input is
 * considered greater than (`.Gt()`) the given value.
 * 
 * @param   {Any}  A  any value
 * @returns {Predicate}
 * @example
 * (15).Assert(Gt(10))
 */
Gt(A) => Predicate.Cast((B) => B.Gt(A))

/**
 * Returns a {@link Predicate} that determines whether the input is
 * considered greater than or equal to (`.Ge()`) the given value.
 * 
 * @param   {Any}  A  any value
 * @returns {Predicate}
 * @example
 * (15).Assert(Ge(15))
 */
Ge(A) => Predicate.Cast((B) => B.Ge(A))

/**
 * Returns a {@link Predicate} that determines whether the input is
 * considered less than (`.Lt()`) the given value.
 * 
 * @param   {Any}  A  any value
 * @returns {Predicate}
 * @example
 * (15).Assert(Lt(20))
 */
Lt(A) => Predicate.Cast((B) => B.Lt(A))

/**
 * Returns a {@link Predicate} that determines whether the input is
 * considered less than or equal to (`.Le()`) the given value.
 * 
 * @param   {Any}  A  any value
 * @returns {Predicate}
 * @example
 * (15).Assert(Le(15))
 */
Le(A) => Predicate.Cast((B) => B.Le(A))

/**
 * Returns a {@link Predicate} that determines whether the input has
 * the same ordering ({@link AquaHotkey_Comparable `.Compare()`}) as the given value.
 * 
 * Using this function is discouraged, because `A.Compare(B) == 0` should
 * usually imply `A.Eq(B)`, and it might be removed in later versions.
 * 
 * @deprecated
 * @param   {Any}  A  any value
 * @returns {Predicate}
 */
OrdEq(A) => Predicate.Cast((B) => (A.OrdEq(B)))

/**
 * Returns a {@link Predicate} that determines whether the input has
 * a different ordering ({@link AquaHotkey_Comparable `.Compare()`}) as the given
 * value.
 * 
 * Using this function is discouraged, because `A.Compare(B) != 0` should
 * usually imply `A.Ne(B)`, and it might be removed in later versions.
 * 
 * @deprecated
 * @param   {Any}  A  any value
 * @returns {Predicate}
 */
OrdNe(A) => Predicate.Cast((B) => (A.OrdNe(B)))

/**
 * Returns a {@link Predicate} that determines whether the input is between
 * the inclusive range of `Low` and `High`.
 * 
 * @param   {Any}  Low   lower bound
 * @param   {Any}  High  upper bound
 * @returns {Predicate}
 * @example
 * Rng := InRange(0, 10)
 * Rng(2) ; true
 * 
 * ; works with any comparable type
 * Rng := InRange([1, 2, 3], [1, 12, 2])
 * Rng([1, 5, 245]) ; true
 */
InRange(Low, High) => ( Ge(Low) ).And( Le(High) )

;@endregion
;-------------------------------------------------------------------------------
;@region Equality

/**
 * Returns a {@link Predicate} that determines whether the input is
 * considered equal to (`.Eq()`) the given value.
 * 
 * @param   {Any}  A  any value
 * @returns {Predicate}
 * @example
 * MyVar := { a: "b" }
 * MyVar.Assert(Eq({ a: "b" }))
 */
Eq(A) => Predicate.Cast((B?) => A.Eq(B?))

/**
 * Returns a {@link Predicate} that determines whether the input is
 * not equal to (`.Ne()`) the given value.
 * 
 * @param   {Any}  A  any value
 * @returns {Predicate}
 * @example
 * (5).Assert(Ne(4))
 */
Ne(A) => Predicate.Cast((B?) => A.Ne(B?))

/**
 * Returns a {@link Predicate} that determines whether the input is
 * equal in reference (`=`) to the given value. For semantic equality,
 * use {@link Eq()}.
 * 
 * @param   {Any}  A  any value
 * @returns {Predicate}
 */
RefEq(A) => (B?) => (IsSet(B)) && (A = B)

/**
 * Returns a {@link Predicate} that determines whether the input is
 * not equal in reference (`!=`) to the given value. For semantic inequality,
 * use {@link Ne()}.
 * 
 * @param   {Any}  A  any value
 * @returns {Predicate}
 */
RefNe(A) => (B?) => (IsSet(B)) && (A != B)

;@endregion
