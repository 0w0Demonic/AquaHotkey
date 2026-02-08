#Include <AquaHotkey>

/**
 * @mixin
 * @description
 * 
 * Mixin class for types that can be enumerated with 1 parameter.
 * 
 * In general, functions used for side effects (`.ForEach()`) or reduction
 * (`.Reduce()`, `.Any1()`, etc.) are able to access the loop variable
 * `A_Index`.
 * 
 * @example
 * MyArray.Any((Value?) {
 *     Idx := A_Index
 *     ... ; do something with the element
 * })
 */
class Enumerable1 {
    static __New() => this.ApplyOnto(IArray, IMap, Enumerator)

    ;@region Collect

    /**
     * Collects all elements into an array.
     * 
     * @returns {Array}
     * @example
     * Array(1, 2, 3).ToArray() ; [1, 2, 3]
     */
    ToArray() => Array(this*)
    
    /**
     * Reduces all elements by passing them variadically into the given
     * `Collector` function which returns the final result.
     * 
     * An extended version of this method is available in `<Stream/Collector>`
     * 
     * @param   {Func}  Collector  function that collects all values
     * @returns {Any}
     * @example
     * Sum(Args*) {
     *     Result := Float(0)
     *     for Arg in Args {
     *         Result += Arg
     *     }
     *     return Result
     * }
     * 
     * Array(1, 2, 3, 4, 5).Stream().Collect(Sum)
     */
    Collect(Collector) {
        GetMethod(Collector)
        return Collector(this*)
    }

    /**
     * Collects elements into an {@link ISet}.
     * 
     * @param   {Any?}  SetParam  internal set options
     * @see {@link ISet.Create()}
     * @returns {ISet}
     */
    ToSet(SetParam?) {
        S := ISet.Create(SetParam?)
        S.Add(this*)
        return S
    }

    /**
     * Returns a frequency map of all elements.
     * 
     * @param   {Func?}  Classifier  function that retrieves map key
     * @param   {Any?}   MapParam    internal map param
     * @returns {Map}
     * @see {@link IMap.Create()}
     * @example
     * Array(1, 2, 2, 3).Frequency() ; Map { 1: 1, 2: 2, 3: 1 }
     */
    Frequency(Classifier?, MapParam := Map()) {
        M := IMap.Create(MapParam)
        if (IsSet(Classifier)) {
            GetMethod(Classifier)
            for Value in this {
                Key := Classifier(Value?)
                M.Set(Key, M.Get(Key, 0) + 1)
            }
        } else {
            for Value in this {
                M.Set(Value, M.Get(Value, 0) + 1)
            }
        }
        return M
    }

    /**
     * Groups all elements into a map.
     * 
     * ```ahk
     * Classifier(Elem: Any?) => Any
     * Downstream(Args: Any*) => Any
     * ```
     * 
     * @param   {Func}   Classifier  function that retrieves map key
     * @param   {Func?}  Downstream  transforms groups of elements
     * @param   {Any?}   MapParam    internal map param
     * @returns {Map}
     * @see {@link IMap.Create()}
     * @example
     * ; Map { 0: [2, 4, 6], 1: [1, 3, 5] }
     * Array(1, 2, 3, 4, 5, 6).Group(x => (x & 1))
     */
    Group(Classifier, Downstream?, MapParam := Map()) {
        GetMethod(Classifier)
        if (IsSet(Downstream)) {
            GetMethod(Downstream)
        }

        M := IMap.Create(MapParam)
        for Value in this {
            Key := Classifier(Value?)
            if (!M.Has(Key)) {
                M.Set(Key, Array(Value?))
            } else {
                M.Get(Key).Push(Value?)
            }
        }
        if (!IsSet(Downstream)) {
            return M
        }
        for Key, Arr in M {
            M.Set(Key, Downstream(Arr*))
        }
        return M
    }

    /**
     * Partitions elements into a `Map` with keys `true` and `false`, based on
     * whether they fulfill the given `Condition`.
     * 
     * ```ahk
     * Classifier(Elem: Any?) => Any
     * Downstream(Args: Any*) => Any
     * ```
     * 
     * @param   {Func}   Condition   the given condition
     * @param   {Func?}  Downstream  transforms the `true` and `false` groups
     * @returns {Map}
     * @example
     * Even(X) => !(X & 1)
     * 
     * ; Map { true: [2, 4, 6, ..., 1000], false: [1, 3, 5, ..., 999] }
     * Range(1, 1000).Partition(Even)
     */
    Partition(Condition, Downstream?) {
        GetMethod(Condition)
        if (IsSet(Downstream)) {
            GetMethod(Downstream)
        }

        M := Map(true, Array(), false, Array())
        for Value in this {
            M[!!Condition(Value?)].Push(Value?)
        }

        if (!IsSet(Downstream)) {
            return M
        }

        return Map(
            true, Downstream(M.Get(true)),
            false, Downstream(M.Get(false))
        )
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Side Effects

    /**
     * Executes an action for each element.
     * 
     * ```ahk
     * Action(Value: Any?, Args: Any*) => void
     * ```
     * 
     * @param   {Func}  Action  the function to call
     * @param   {Any*}  Args    zero or more arguments for the function
     * @returns {this}
     * @example
     * Array(1, 2, 3).ForEach(MsgBox, "Listing numbers in array", 0x40)
     */
    ForEach(Action, Args*) {
        GetMethod(Action)
        for Value in this {
            Action(Value?, Args*)
        }
        return this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Find Methods

    /**
     * Returns an {@link Optional} that contains the first matching element,
     * if found. The element found is *not* allowed to be `unset`.
     * 
     * ```ahk
     * Condition(Element: Any?, Args: Any*) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Optional}
     * @see {@link Enumerable1#Any .Any()}
     * @example
     * Array(1, 2, 3, 4).Find(Gt, 2) ; Optional<3>
     */
    Find(Condition, Args*) {
        GetMethod(Condition)
        for Value in this {
            if (IsSet(Value) && Condition(Value, Args*)) {
                return Optional(Value)
            }
        }
        return Optional()
    }

    /**
     * Returns an {@link Optional}, containing the first element that equals
     * the given value ({@link AquaHotkey_Eq `.Eq()`}), if present.
     * 
     * The element found is *not* allowed to be `unset`.
     * 
     * @param   {Any}  Val  any value
     * @returns {Optional}
     * @example
     * Array(1, 2, 3, 4).FindValue(3).IfPresent(MsgBox)
     */
    FindValue(Val) {
        for Value in this {
            if (IsSet(Value) && Value.Eq(Val)) {
                return Optional(Value)
            }
        }
        return Optional()
    }

    /**
     * Determines whether any element equals ({@link AquaHotkey_Eq `.Eq()`})
     * the given value.
     * 
     * Note that some enumerables can only iterated once. For repeated
     * `.Contains()` tests, and for forward performance, consider collecting
     * elements into an {@link ISet} with {@link Enumerable1#ToSet `.ToSet()`}.
     * 
     * This also enables the use of methods such as
     * {@link ISet#ContainsAll `.ContainsAll()`} and
     * {@link ISet#ContainsAny `.ContainsAny()`}.
     * 
     * @param   {Any}  Val  value to test for equality
     * @returns {Boolean}
     * @example
     * Array(1, 2, 3, 4).Contains(4) ; true
     * 
     * ; collect to an `ISet` for better performance
     * S := BigArray.ToSet(HashSet)
     * S.ContainsAll(...)
     */
    Contains(Val) {
        for Value in this {
            if (IsSet(Value) && Val.Eq(Value)) {
                return true
            }
        }
        return false
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Any()/All()/None()

    /**
     * Determines whether any of the elements fulfill the given `Condition`.
     * 
     * ```ahk
     * Condition(Element: Any?, Args: Any*) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Boolean}
     * @see     {@link Enumerable1#Find .Find()}
     * @example
     * Array(1, 2, 3, 4).Any(x => (x > 2))
     */
    Any(Condition, Args*) {
        GetMethod(Condition)
        for Value in this {
            if (Condition(Value?, Args*)) {
                return true
            }
        }
        return false
    }

    /**
     * Returns `true` if all elements fulfill the given `Condition`, otherwise
     * `false`.
     * 
     * ```ahk
     * Condition(Element: Any?, Args: Any*) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Boolean}
     * @example
     * Array(1, 2, 3, 4).All(x => x < 10) ; true
     */
    All(Condition, Args*) {
        for Value in this {
            if (!Condition(Value?, Args*)) {
                return false
            }
        }
        return true
    }

    /**
     * Returns `true` if none of the elements fulfill the given `Condition`,
     * otherwise `false`.
     * 
     * ```ahk
     * Condition(Element: Any?, Args: Any*) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Boolean}
     * @example
     * Array(1, 2, 3, 4).None(x => x == 4) ; false
     */
    None(Condition, Args*) {
        GetMethod(Condition)
        for Value in this {
            if (Condition(Value?, Args*)) {
                return false
            }
        }
        return true
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Reduction

    /**
     * Returns the amount of elements by traversing this enumerator.
     * 
     * @returns {Integer}
     */
    Count() {
        Count := 0
        for Value in this {
            ++Count
        }
        return Count
    }

    ; TODO use Optional as return value for falling back?

    /**
     * Combines all elements into a final result by repeatedly applying
     * the given `Combiner`.
     * 
     * ```ahk
     * Combiner(Left: Any, Right: Any?) => Any
     * ```
     * 
     * @param   {Func}  Combiner  combiner function
     * @param   {Any?}  Initial   initial value
     * @returns {Any}
     * @example
     * Array(1, 2, 3, 4).Reduce((a, b) => (a + b)) ; 10
     */
    Reduce(Combiner, Initial?) {
        GetMethod(Combiner)
        if (!IsSet(Initial) && Combiner.Is(Monoid)) {
            Initial := Combiner.Identity
        }
        for Value in this {
            if ((A_Index == 1) && !IsSet(Initial)) {
                Initial := (Value?)
            } else {
                Initial := (Combiner(Initial?, Value?)?)
            }
        }
        return Initial
    }

    /**
     * Returns the sum of all elements.
     * 
     * @returns {Float}
     * @example
     * Array(1, 2, 3, 4).Sum() ; 10
     */
    Sum() {
        Sum := Float(0)
        for Value in this {
            Sum += Value
        }
        return Sum
    }

    /**
     * Returns the arithmetic mean of all elements.
     * 
     * @returns {Float}
     * @example
     * Array(1, 2, 3, 4).Average() ; 2.5
     */
    Average() {
        Sum := Float(0)
        Count := 0
        for Value in this {
            ++Count
            Sum += Value
        }
        return Sum / Count
    }

    ; TODO unset handling
    /**
     * Concatenates all elements into a string with the given delimiter.
     * 
     * Objects are converted to strings using `.ToString()`.
     * 
     * @param   {String?}  Delim   delimiter string between elements
     * @param   {String?}  Prefix  string prefix
     * @param   {String?}  Suffix  string suffix
     * @returns {String}
     * @see     {@link AquaHotkey_ToString}
     * @example
     * Array([1, 2], [3, 4], 5.6).Join() ; "[1, 2], [3, 4], 5.6"
     */
    Join(Delim := "", Prefix := "", Suffix := "") {
        if (IsObject(Delim)) {
            throw TypeError("Expected a String",, Type(Delim))
        }
        Result := Prefix
        if (Delim == "") {
            for Value in this {
                (IsSet(Value) && Result .= String(Value))
            }
            return Result . Suffix
        }

        for Value in this {
            (IsSet(Value) && Result .= String(Value))
            Result .= Delim
        }
        return SubStr(Result, 1, -StrLen(Delim)) . Suffix
    }

    /**
     * Concatenates all elements into a string, separated by a
     * new line (`\n`).
     * 
     * @param   {String?}  Prefix  string prefix
     * @param   {String?}  Suffix  string suffix
     * @returns {String}
     */
    JoinLine(Prefix?, Suffix?) => this.Join("`n", Prefix?, Suffix?)

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Max()/Min()

    ; TODO use Optional as fallback?

    /**
     * Returns the highest element according to the given comparator function.
     * 
     * @param   {Comparator?}  Comp  comparator function
     * @returns {Any}
     * @example
     * Stream.Of(1, 2, 3, 4).Max() ; 4
     */
    Max(Comp := Any.Compare) {
        Result := unset
        for Value in this {
            if (A_Index == 1 || Comp(Value?, Result?) > 0) {
                Result := (Value?)
            }
        }
        return (Result?)
    }

    /**
     * Returns the lowest element according to the given comparator function.
     * 
     * @param   {Comparator?}  Comp  comparator function
     * @returns {Any?}
     * @example
     * Stream.Of(1, 2, 3, 4).Min() ; 1
     */
    Min(Comp := Any.Compare) {
        Result := unset
        for Value in this {
            if (A_Index == 1 || Comp(Value?, Result?) < 0) {
                Result := (Value?)
            }
        }
        return (Result?)
    }

    ;@endregion
}
