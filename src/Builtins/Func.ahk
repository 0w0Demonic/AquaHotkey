class AquaHotkey_Func extends AquaHotkey {
/**
 * AquaHotkey - Func.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/Func.ahk
 */
class Func {
    /**
     * Returns a function that always returns its input argument.
     * @returns {Func}
     */
    static Self => ((x) => x)

    /**
     * Returns a function that always returns the given input `x`
     * @param   {Any}  x  the value to return
     * @returns {Func}
     */
    static Constantly(x) => ((*) => x)

    /**
     * Returns a function that always returns the given input `x`. If the value
     * is an object, a fresh copy is returned each time.
     * 
     * @param   {Any}  x  the value to return (and optionally clone)
     * @returns {Func}
     */
    static Replicate(x) {
        if (IsObject(x)) {
            x := x.Clone()
            return ((*) => x.Clone())
        }
        return ((*) => x)
    }

    /**
     * Returns a composed function that first applies this function with the
     * given input, and then forwards the result to `After` as first parameter,
     * followed by zero or more additional arguments `NextArgs*`.
     * 
     * @example
     * TimesTwo(x) => (x * 2)
     * PlusFive(x) => (x + 5)
     * 
     * TimesTwoPlusFive := TimesTwo.AndThen(PlusFive)
     * TimesTwoPlusFive(3) ; 11
     * 
     * @param   {Func}  After     function to apply after this function
     * @param   {Any*}  NextArgs  zero or more additional arguments
     * @returns {Func}
     */
    AndThen(After, NextArgs*) {
        GetMethod(After)
        return (Args*) => After( this(Args*), NextArgs* )
    }

    /**
     * Returns a composed function that first applies `Before` with the
     * given input, and then forwards the result to this function, followed
     * by zero or more additional arguments `NextArgs*`.
     * 
     * @example
     * TimesTwo(x) => (x * 2)
     * PlusFive(x) => (x + 5)
     * 
     * PlusFiveTimesTwo := TimesTwo.Compose(PlusFive)
     * PlusFiveTimesTwo(3) ; 16
     * 
     * @param   {Func}  Before    function to apply before this function
     * @param   {Any*}  NextArgs  zero or more additional arguments
     * @returns {Func}
     */
    Compose(Before, NextArgs*) {
        GetMethod(Before)
        return (Args*) => this( Before(Args*), NextArgs* )
    }

    /**
     * Returns a predicate function that represents a logical AND of this
     * predicate and `Other`. The resulting predicate short-circuits, if the
     * first expression evaluates to `false`.
     * 
     * @example
     * GreaterThan5(x) => (x > 5)
     * LessThan100(x) => (x < 100)
     * 
     * Condition := GreaterThan5.And(LessThan100)
     * Condition(23) ; true
     * 
     * @param   {Func}  Other  function that evaluates a condition
     * @returns {Func}
     */
    And(Other) {
        GetMethod(Other)
        return (Args*) => this(Args*) && Other(Args*)
    }

    /**
     * Returns a predicate function that presents a logical AND NOT of this
     * predicate and `Other`. The resulting predicate short-circuits, if the
     * first expression evaluates to `false`.
     * 
     * @example
     * GreaterThan5(x) => (x > 5)
     * GreaterThan100(x) => (x > 100)
     * 
     * Condition := GreaterThan5.AndNot(GreaterThan100)
     * Condition(56) ; true
     * 
     * @param   {Func}  Other  function that evaluates a condition
     * @returns {Func}
     */
    AndNot(Other) {
        GetMethod(Other)
        return (Args*) => this(Args*) && !Other(Args*)
    }

    /**
     * Returns a predicate function that represents a logical OR of this
     * predicate and `Other`. The resulting predicate short-circuits, if the
     * first expression evaluates to `true`
     * 
     * @example
     * GreaterThan5(x) => (x > 5)
     * EqualsOne(x) => (x == 1)
     * 
     * Condition := GreaterThan5.Or(EqualsOne)
     * Condition(1) ; true
     * 
     * @param   {Func}  Other  function that evaluates a condition
     * @returns {Func}
     */
    Or(Other) {
        GetMethod(Other)
        return (Args*) => this(Args*) || Other(Args*)
    }

    /**
     * Returns a predicate function that represents a logical OR NOT of this
     * predicate and `Other`. The resulting predicate short-circuits, if the
     * first expression evaluates to `true`.
     * 
     * @example
     * GreaterThan5(x) => (x > 5)
     * GreaterThan0(x) => (x > 0)
     * 
     * Condition := GreaterThan5.OrNot(GreaterThan0)
     * Condition(-3) ; true
     * 
     * @param   {Func}  Other  function that evaluates a condition
     * @returns {Func}
     */
    OrNot(Other) {
        GetMethod(Other)
        return (Args*) => this(Args*) || !Other(Args*)
    }
    
    /**
     * Returns a predicate that represents a negation of this predicate.
     * 
     * @example
     * IsAdult(Person) => (Person.Age >= 18)
     * IsNotAdult := IsAdult.Negate()
     * 
     * IsNotAdult({ Age: 17 }) ; true
     * 
     * @returns {Predicate}
     */
    Negate() => ((Args*) => !this(Args*))

    /**
     * Returns a memoized version of this function, caching previously computed
     * results in a Map to avoid redundant computation.
     * 
     * Customize key generation by passing a `Hasher` - a function
     * that takes the input arguments and returns a key (preferably a string).
     * 
     * You can also customize the internal Map behavior by passing `MapParam`,
     * which can be:
     * - a map (used directly),
     * - function returning a map,
     * - or a case-sensitivity option.
     * 
     * @example
     * Fibonacci(x) {
     *     if (x > 1) {
     *         ; If you recurse, you need to call the memoized version.
     *         return FibonacciMemo(x - 2) + FibonacciMemo(x - 1)
     *     }
     *     return 1
     * }
     * FibonacciMemo := Fibonacci.Memoized()
     * FibonacciMemo(80) ; 23416728348467685
     * 
     * @param   {Func?}                  Hasher    function creating map keys
     * @param   {Map?/Func?/Primitive?}  MapParam  specifies map options
     * @returns {Func}
     */
    Memoized(Hasher?, MapParam := Map()) {
        switch {
            case (MapParam is Map):
                Cache := MapParam
            case (HasMethod(MapParam)):
                Cache := MapParam()
                if (!(Cache is Map)) {
                    throw ValueError("Expected a Map",, Type(Cache))
                }
            default:
                Cache := Map()
                Cache.CaseSense := MapParam
        }

        Result := IsSet(Hasher) ? HashedMemoized : Memoized
        (Object.Prototype.DefineProp)(Result, "Memoized", { Call: x => x })
        return Result

        Memoized(Arg) {
            return Cache.Has(Arg) ? Cache[Arg]
                                  : Cache[Arg] := this(Arg)
        }

        HashedMemoized(Args*) {
            Key := Hasher(Args*)
            return Cache.Has(Key) ? Cache[Key]
                                  : Cache[Key] := this(Args*)
        }
    }

    /**
     * Returns the string representation of the function.
     * 
     * @example
     * MsgBox.ToString() ; "Func MsgBox"
     * 
     * @returns {String}
     */
    ToString() {
        if (this.Name == "") {
            return Type(this) . " (unnamed)"
        }
        return Type(this) . " " . this.Name
    }
} ; class Func
} ; class AquaHotkey_Func extends AquaHotkey