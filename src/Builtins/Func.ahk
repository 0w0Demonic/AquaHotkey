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
     * Provides a shorthand for function binding, with behavior that adapts
     * depending on the type of the function it is applied to. This method
     * simplifies common binding patterns for functions in global/local scope,
     * static methods and non-static methods.
     * 
     * ---
     * 
     * **Behavior for Regular Functions and Static Methods**:
     * 
     * - The method starts binding arguments from the *second* parameter,
     *   leaving the first parameter untouched.
     * 
     *   ```
     *   ContainsLetterF := InStr.__("F") ; InStr.Bind(unset, "F")
     *   ContainsLetterF("Foo")           ; InStr("Foo", "F")
     * 
     *   class MyClass {
     *       static MyMethod(Args*) {
     *           ; ...
     *       }
     *   }
     *   
     *   Method := MyClass.MyMethod.__(Arg1, Arg2)
     *   Method("foo") ; MyClass.MyMethod("foo", Arg1, Arg2)
     *   ```
     * 
     * ---
     * 
     * **Behavior for Non-Static Methods**:
     * 
     * - The method binds arguments starting from the *first* parameter,
     *   leaving out the `this`-parameter referring to the object instance.
     *   
     *   ```
     *   class MyClass {
     *       MyMethod(Args*) {
     *           ; ...
     *       }
     *   }
     *   
     *   Method := MyClass.MyMethod.__(Arg1, Arg2)
     *   Instance := MyClass() ; create a new object
     *   Method(Instance)      ; same as Instance.Method(Arg1, Arg2)
     *   ```
     * 
     * ---
     * 
     * **Note**:
     * 
     * This method relies on the `Name` property to determine whether this
     * function is a regular function, static method or non-static method (its
     * name is being searched for strings `.` and `.Prototype.`).
     * When dynamically creating new methods, they must be named according to
     * the standard naming convention of AutoHotkey functions.
     * 
     * ```
     * MyStaticMethod.DefineConstant("Name", "MyClass.MyMethod")
     * MyNonStaticMethod.DefineConstant("Name", "MyClass.Prototype.MyMethod")
     * ```
     * @example
     * 
     * FirstCharacter := SubStr.__(1, 1)
     * FirstCharacter("foo") ; "f"
     * 
     * @param   {Any*}  Args  zero or more arguments
     * @return  {BoundFunc}
     */
    __(Args*) {
        FunctionName := this.Name
        if (InStr(FunctionName, ".")) {
            if (InStr(FunctionName, ".Prototype.")) {
                return this.Bind(unset, Args*)
            }
            IndexLastDot := InStr(FunctionName, ".", false,, -1)
            ClassName    := SubStr(FunctionName, 1, IndexLastDot - 1)
            return this.Bind(Class.ForName(ClassName), unset, Args*)
        }
        return this.Bind(unset, Args*)
    }

    /**
     * Returns a composed function that first applies this function with the
     * given input, and then forwards the result to `After` as first parameter,
     * followed by zero or more additional arguments `NextArgs*`.
     * @example
     * 
     * TimesTwo(x) {
     *     return (x * 2)
     * }
     * PlusFive(x) {
     *     return (x + 5)
     * }
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
     * by zero or more additional arguments `Args*`.
     * @example
     * 
     * TimesTwo(x) {
     *     return (x * 2)
     * }
     * PlusFive(x) {
     *     return (x + 5)
     * }
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
     * @example
     * 
     * GreaterThan5(x) {
     *     return (x > 5)
     * }
     * LessThan100(x) {
     *     return (x < 100)
     * }
     * Condition := GreaterThan5.And(LessThan100)
     * Condition(23) ; true
     * 
     * @param   {Predicate}  Other  function that evaluates a condition
     * @return  {Predicate}
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
     * @example
     * 
     * GreaterThan5(x) {
     *     return (x > 5)
     * }
     * GreaterThan100(x) {
     *     return (x > 100)
     * }
     * Condition := GreaterThan5.AndNot(GreaterThan100)
     * Condition(56) ; true
     * 
     * @param   {Predicate}  Other  function that evaluates a condition
     * @return  {Predicate}
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
     * @example
     * 
     * GreaterThan5(x) {
     *     return (x > 5)
     * }
     * EqualsOne(x) {
     *     return (x = 1)
     * }
     * Condition := GreaterThan5.Or(EqualsOne)
     * Condition(1) ; true
     * 
     * @param   {Predicate}  Other  function that evaluates a condition
     * @return  {Predicate}
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
     * @example
     * 
     * GreaterThan5(x) {
     *     return (x > 5)
     * }
     * GreaterThan0(x) {
     *     return (x > 0)
     * }
     * Condition := GreaterThan5.OrNot(GreaterThan0)
     * Condition(-3) ; true
     * 
     * @param   {Predicate}  Other  function that evaluates a condition
     * @return  {Predicate}
     */
    OrNot(Other) {
        if (!HasMethod(Other)) {
            throw TypeError("Expected a Function object",, Type(Other))
        }
        return (Args*) => this(Args*) || !Other(Args*)
    }
    
    /**
     * Returns a predicate that represents a negation of this predicate.
     * @example
     * 
     * IsAdult(Person) => (Person.Age >= 18)
     * IsNotAdult := IsAdult.Negate()
     * 
     * IsNotAdult({ Age: 17 }) ; true
     * 
     * @return  {Predicate}
     */
    Negate() => ((Args*) => !this(Args*))

    /**
     * Returns a composed function which applies its input to two
     * functions `First` and `Second`, optionally using `Combiner` to merge
     * the two return values into a final result.
     * @example
     * 
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
     * results in a `Map` object instead of calculating a result on every call.
     * 
     * The method determines behavior based on the type of the first parameter:
     * 
     * ---
     * 
     * **1. `CaseSenseOrHasher` (`Boolean`|`String`|`Func`, optional)**:
     * 
     * If a `Boolean` (`true` or `false`) or `String` (`"On"`, `"Off"` or
     * `"Locale"`) is provided, it determines the case-sensitivity of the
     * internal `Map` used for equality checks.
     * 
     * If a function object is provided, it is treated as a custom `Hasher` for
     * generating keys. This is useful for comparing objects based on their
     * values instead of their identity.
     * 
     * A custom `Hasher` is required for supporting streams with a parameter
     * length greater than 1.
     * 
     * ---
     * 
     * **2. `CaseSense` (`Boolean`|`String`, optional)**:
     * 
     * Specifies case-sensitivity of the internal `Map`.
     * 
     * ---
     * @example
     * 
     * Fibonacci(x) {
     *     if (x > 1) {
     *         ; Important:
     *         ;   Recursive calls must also call the memoized version of this
     *         ;   function, otherwise only the result for input `80` is cached!
     *         return FibonacciMemo(x - 2) + FibonacciMemo(x - 1)
     *     }
     *     return 1
     * }
     * FibonacciMemo := Fibonacci.Memoized()
     * FibonacciMemo(80) ; 23416728348467685
     * 
     * @param   {Primitive?/Func?}  CaseSenseOrHasher  case-sensitivity or
     *                                                 object hasher
     * @param   {Primitive?}        CaseSense          case-sensitivity
     * @return  {Func}
     */
    Memoized(CaseSenseOrHasher := True, CaseSense?) {
        static FunctionPool := Map()

        if (ObjHasOwnProp(this, "IsMemoized")) {
            return this
        }
        if (Function := FunctionPool.Get(this, false)) {
            return Function
        }

        if (HasMethod(CaseSenseOrHasher)) {
            Hasher    := CaseSenseOrHasher
            CaseSense := CaseSense ?? true
        } else {
            Hasher    := unset
            CaseSense := CaseSenseOrHasher
        }

        Cache           := Map()
        Cache.CaseSense := CaseSense

        if (IsSet(Hasher)) {
            Function := HashedMemoized
        } else {
            Function := DefaultMemoized
        }

        Function.DefineProp("IsMemoized", { Get: (Instance) => true })
        return FunctionPool[this] := Function

        DefaultMemoized(Arg) {
            if (!Cache.Has(Arg)) {
                Cache[Arg] := this(Arg)
            }
            return Cache[Arg]
        }

        HashedMemoized(Args*) {
            Key := Hasher(Args*)
            if (!Cache.Has(Key)) {
                Cache[Key] := this(Args*)
            }
            return Cache[Key]
        }
    }

    /**
     * Returns `true`, if this function is memoized.
     * 
     * @return  {Boolean}
     */
    IsMemoized => false

    /**
     * Returns a string representation of this function object.
     * @example
     * 
     * MsgBox.ToString() ; "Func MsgBox"
     * 
     * @return  {String}
     */
    ToString() {
        if (this.Name == "") {
            return Type(this) . " <...>"
        }
        return Type(this) . " " . this.Name
    }
} ; class Func
} ; class AquaHotkey_Func extends AquaHotkey