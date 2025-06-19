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
     * @return  {Func}
     */
    static Self => ((x) => x)

    /**
     * Returns a function that always returns the given input `x`
     * @param   {Any}  x  the value to return
     * @return  {Func}
     */
    static Constantly(x) => ((*) => x)

    /**
     * Returns a function that always returns the given input `x`. If the value
     * is an object, a fresh copy is returned each time.
     * 
     * @param   {Any}  x  the value to return (and optionally clone)
     * @return  {Func}
     */
    static Replicate(x) {
        if (IsObject(x)) {
            x := x.Clone()
            return ((*) => x.Clone())
        }
        return ((*) => x)
    }

    ; TODO deprecate this?
    /**
     * Stores a clone of the function in `Output`.
     * @example
     * 
     * MyVariable.Store(&Copy)
     * 
     * @param   {VarRef}  Output  output variable to store current value in
     * @return  {this}
     */
    Store(&Output) {
        Output := this
        return this
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
     * @return  {Func}
     */
    AndThen(After, NextArgs*) {
        if (!HasMethod(After)) {
            throw TypeError("Expected a Function object",, Type(After))
        }
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
     * @return  {Func}
     */
    Compose(Before, NextArgs*) {
        if (!HasMethod(Before)) {
            throw TypeError("Expected a Function object",, Type(Before))
        }
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
     * @return  {Func}
     */
    And(Other) {
        if (!HasMethod(Other)) {
            throw TypeError("Expected a Function object",, Type(Other))
        }
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
     * @return  {Func}
     */
    AndNot(Other) {
        if (!HasMethod(Other)) {
            throw TypeError("Expected a Function object",, Type(Other))
        }
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
     * @return  {Func}
     */
    Or(Other) {
        if (!HasMethod(Other)) {
            throw TypeError("Expected a Function object",, Type(Other))
        }
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
     * @return  {Func}
     */
    OrNot(Other) {
        if (!HasMethod(Other)) {
            throw TypeError("Expected a Function object",, Type(Other))
        }
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
     * @return  {Predicate}
     */
    Negate() => ((Args*) => !this(Args*))

    ; TODO deprecate this?
    /**
     * Composes a function that applies its input to both `First` and `Second`,
     * optionally merging both results into a final result.
     * 
     * @example
     * Sum(Values*) {
     *     ; ...
     * }
     * Average(Values*) {
     *     ; ...
     * }
     * FormatResult(Sum, Average) {
     *     return Format("Sum: {}, Average: {}", Sum, Average)
     * }
     * Evaluate := Func.Tee(Sum, Average, FormatResult)
     * Evaluate(1, 2, 3, 4) ; "Sum: 10, Average: 2.5"
     * 
     * @param   {Func}       First     the first function to call
     * @param   {Func}       Second    the second function to call
     * @param   {Combiner?}  Combiner  function that combines two results
     * @return  {Func}
     */
    static Tee(First, Second, Combiner?) {
        if (!HasMethod(First) || !HasMethod(Second)) {
            throw TypeError("Expected a Function object",,
                            Type(First) . " " . Type(Second))
        }
        if (!IsSet(Combiner)) {
            return TeeNoMerge
        }
        if (!HasMethod(Combiner)) {
            throw TypeError("Expected a Function object",, Type(Combiner))
        }
        return Tee

        TeeNoMerge(Args*) {
            First(Args*)
            Second(Args*)
        }

        Tee(Args*) {
            return Combiner(First(Args*), Second(Args*))
        }
    }
    
    /**
     * Returns a memoized version of this function, caching previously computed
     * results in a Map to avoid redundant computation.
     * 
     * Customize key generation by passing a `Hasher` - a function
     * that takes the input arguments and returns a key (preferably a string).
     * 
     * You can also customize the internal Map behaviour by passing `MapParam`,
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
     * @return  {Func}
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
     * @return  {String}
     */
    ToString() {
        if (this.Name == "") {
            return Type(this) . " (unnamed)"
        }
        return Type(this) . " " . this.Name
    }
} ; class Func
} ; class AquaHotkey_Func extends AquaHotkey