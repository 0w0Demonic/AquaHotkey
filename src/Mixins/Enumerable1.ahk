#Include <AquaHotkeyX>

/**
 * Mixin class for types that can be enumerated with 1 parameter.
 * 
 * ```ahk
 * for Value in Obj { ... }
 * ```
 * 
 * @mixin
 */
class Enumerable1 {
    static __New() => this.ApplyOnto(Array, Map, Enumerator, Stream)

    /**
     * Executes an action for each element.
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
     * Combines all elements into a final result by repeatedly applying
     * the given `Combiner`.
     * 
     * ```ahk
     * Combiner(Result, Value?) => Any
     * ```
     * 
     * @param   {Func}  Combiner  combiner function
     * @param   {Any?}  Identity  initial value
     * @returns {Any}
     * @example
     * Array(1, 2, 3, 4).Reduce((a, b) => (a + b)) ; 10
     */
    Reduce(Combiner, Identity?) {
        GetMethod(Combiner)
        Result := (Identity?)
        for Value in this {
            if ((A_Index == 1) && !IsSet(Result)) {
                Result := (Value?)
            } else {
                Result := (Combiner(Result?, Value?)?)
            }
        }
        return (Result?)
    }

    /**
     * Determines whether any of the elements fulfill the given `Condition`.
     * 
     * If present, `&Out` receives the value of the first matching element.
     * 
     * ```ahk
     * Condition(Element?, Args*)
     * ```
     * 
     * @param   {VarRef<Any>}  Out        (out) first matching element
     * @param   {Func}         Condition  the given condition
     * @param   {Any*}         Args       zero or more arguments
     * @see     {@link Enumerable1#Any .Any()}
     * @example
     * Array(1, 2, 3, 4).Find(&Out, x => (x > 2)) ; true
     * MsgBox(Out)                                ; 3
     */
    Find(&Out, Condition, Args*) {
        GetMethod(Condition)
        Out := unset
        for Value in this {
            if (Condition(Value?, Args*)) {
                Out := (Value?)
                return true
            }
        }
        return false
    }

    /**
     * Determines whether any of the elements fulfill the given `Condition`.
     * 
     * ```ahk
     * Condition(Element?, Args*)
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
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
     * Returns `true` if none of the elements fulfill the given `Condition`,
     * otherwise `false`.
     * 
     * ```ahk
     * Condition(Element?, Args*)
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

    /**
     * Returns `true` if all elements fulfill the given `Condition`, otherwise
     * `false`.
     * 
     * ```ahk
     * Condition(Element?, Args*)
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
     * @returns {String}
     */
    JoinLine() => this.Join("`n")

    /**
     * Returns a frequency map of all elements.
     * 
     * @param   {Func?}  Classifier  function that retrieves map key
     * @param   {Any?}   MapParam    internal map param
     * @returns {Map}
     * @see {@link AquaHotkey_Map.Map.Create Map.Create()}
     * @example
     * Array(1, 2, 2, 3).Frequency() ; Map { 1: 1, 2: 2, 3: 1 }
     */
    Frequency(Classifier?, MapParam?) {
        M := Map.Create(MapParam?)
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

    ; TODO ToSet(SetParam?)

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
     * @see {@link AquaHotkey_Map.Map.Create Map.Create()}
     * @example
     * ; Map { 0: [2, 4, 6], 1: [1, 3, 5] }
     * Array(1, 2, 3, 4, 5, 6).Group(x => (x & 1))
     */
    Group(Classifier, Downstream?, MapParam?) {
        GetMethod(Classifier)
        if (IsSet(Downstream)) {
            GetMethod(Downstream)
        }

        M := Map.Create(MapParam?)
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
}
