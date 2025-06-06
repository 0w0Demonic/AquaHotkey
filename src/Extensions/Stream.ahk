/**
 * AquaHotkey - Stream.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/Stream.ahk
 * 
 * **Overview**:
 * 
 * Streams are a powerful abstraction for processing sequences of data in a
 * declarative way. The primary purpose of streams is to enable cleaner and more
 * readable code by removing boilerplate iteration logic.
 * 
 * ```
 * Array(1, 2, 3, 4, 5, 6).Stream().RetainIf(IsEven).ForEach(MsgBox) ; <2, 4, 6>
 * ```
 * 
 * ---
 * 
 * **Lazy evaluation**:
 * 
 * They operate lazily, meaning intermediate operations (like `.Map()`) are not
 * executed until a terminal operation (like `.ForEach()` or `.ToArray()`)
 * triggers the pipeline and returns a final result. This architecture allows
 * streams to efficiently handle both finite and infinite data sequences.
 * 
 * ---
 * 
 * **Notation Used in Examples**:
 * 
 * - `<` and `>`: denotes an instance of a stream, For example:
 * 
 * ```
 * Array(1, 2, 3, 4, 5).Stream() ; <1, 2, 3, 4, 5>
 * ```
 * 
 * - `(` and `)`: denotes a single element in the stream when it has multiple
 *                parameters. For example:
 * 
 * ```
 * Array("foo", "bar", "baz").Stream(2) ; <(1, "foo"), (2, "bar"), (3, "baz")>
 * ```
 */
class Stream {
    /**
     * Constructs a new stream with the given `Source` used for retrieving
     * elements.
     * 
     * ---
     * 
     * **Requirements for a Valid Stream Source**:
     * 
     * 1. Only ByRef parameters `&ref`.
     * 2. No variadic parameters `args*`.
     * 3. A `MaxParams` property with a value between `1` and `4`.
     * 
     * ---
     * @param   {Func}  Source  the function used as stream source
     * @return  {Stream}
     */
    __New(Source) {
        if (Source.IsVariadic) {
            throw ValueError("varargs parameter",, this.Name)
        }
        if (Source.MaxParams > Stream.MaxSupportedParams) {
            throw ValueError("invalid number of parameters",, Source.MaxParams)
        }
        this.DefineProp("Call", { Get: (Instance) => Source })
    }

    /**
     * Returns the maximum parameter length supported by streams (`4`).
     * @return  {Integer}
     */
    static MaxSupportedParams => 4

    /**
     * Returns the minimum parameter length of the underlying stream source.
     * @return  {Integer}
     */
    MinParams => this.Call.MinParams

    /**
     * Returns the maximum parameter length of the underlying stream source.
     * @return  {Integer}
     */
    MaxParams => this.Call.MaxParams

    /**
     * Returns the name of the underlying stream source.
     * @return  {String}
     */
    Name => this.Call.Name

    /**
     * Returns the stream as enumerator object used in for-loops.
     * 
     * @return  {Enumerator}
     */
    __Enum(n) => this.Call

    /**
     * Calculates the parameter length of the new stream that is returned after
     * adding an intermediate operation such as `.RetainIf()` to this stream.
     * 
     * ---
     * 
     * Streams always takes the longest possible length they can, depending on how
     * many parameters `Function` supports. For example:
     * 
     * - A stream has 3 parameters.
     * - The function passed in an intermediate operation (such as
     *   `.RetainIf()`) accepts only 2 parameters.
     * - **Result**: The new stream has only 2 parameters.
     * 
     * ---
     * @param   {Func}  Function  function used for an intermediate operation
     * @return  {Integer}
     */
    ArgSize(Function) {
        Function := GetMethod(Function, "Call")
        if (Function.IsVariadic) {
            return (this.MaxParams || 1)
        }
        if (!Function.MaxParams) {
            throw ValueError("invalid parameter length: 0",, Function.Name)
        }
        return Min(this.MaxParams, Function.MaxParams)
    }

    /**
     * Returns a new stream that retains elements only if they match the given
     * predicate function `Condition`.
     * 
     * The parameter length of the new stream is decided by `.ArgSize()`.
     * @example
     * 
     * Array(1, 2, 3, 4).Stream().RetainIf(x => x > 2) ; <3, 4>
     * 
     * @param   {Predicate}  Condition  function that evaluates a condition
     * @return  {Stream}
     */
    RetainIf(Condition) {
        n := this.ArgSize(Condition)
        f := this.Call
        switch (n) {
            case 1: return Stream(RetainIf1)
            case 2: return Stream(RetainIf2)
            case 3: return Stream(RetainIf3)
            case 4: return Stream(RetainIf4)
        }
        throw ValueError("invalid parameter length",, n)

        RetainIf1(&A) {
            while (f(&A)) {
                if (Condition(A?)) {
                    return true
                }
            }
            return false
        }
        
        RetainIf2(&A, &B?) {
            while (f(&A, &B)) {
                if (Condition(A?, B?)) {
                    return true
                }
            }
            return false
        }

        RetainIf3(&A, &B?, &C?) {
            while (f(&A, &B, &C)) {
                if (Condition(A?, B?, C?)) {
                    return true
                }
            }
            return false
        }

        RetainIf4(&A, &B?, &C?, &D?) {
            while (f(&A, &B, &C)) {
                if (Condition(A?, B?)) {
                    return true
                }
            }
            return false
        }
    }

    /**
     * Returns a new stream that removes all elements which match the given
     * predicate function `Condition`.
     * 
     * The parameter length of the new stream is decided by `.ArgSize()`.
     * @example
     * 
     * Array(1, 2, 3, 4).Stream().RemoveIf(x => x > 2) ; <1, 2>
     * 
     * @param   {Predicate}  Condition  function that evaluates a condition
     * @param   {Stream}
     */
    RemoveIf(Condition) {
        n := this.ArgSize(Condition)
        f := this.Call
        switch (n) {
            case 1: return Stream(RemoveIf1)
            case 2: return Stream(RemoveIf2)
            case 3: return Stream(RemoveIf3)
            case 4: return Stream(RemoveIf4)
        }
        throw ValueError("invalid parameter length",, n)

        RemoveIf1(&A) {
            while (f(&A)) {
                if (!Condition(A?)) {
                    return true
                }
            }
            return false
        }
        
        RemoveIf2(&A, &B?) {
            while (f(&A, &B)) {
                if (!Condition(A?, B?)) {
                    return true
                }
            }
            return false
        }
        
        RemoveIf3(&A, &B?, &C?) {
            while (f(&A, &B, &C)) {
                if (!Condition(A?, B?, C?)) {
                    return true
                }
            }
            return false
        }

        RemoveIf4(&A, &B?, &C?, &D?) {
            while (f(&A, &B, &C, &D)) {
                if (!Condition(A?, B?, C?, D?)) {
                    return true
                }
            }
            return false
        }
    }

    /**
     * Returns a new stream which transforms its elements by applying the given
     * `Mapper` function.
     * 
     * The parameter length of the new stream returned by this method equals 1.
     * @example
     * 
     * ; <2, 4, 6, 8>
     * Array(1, 2, 3, 4).Stream().Map(x => x * 2).ToArray()
     * 
     * ; <(1, "foo"), (2, "bar"), (3, "baz")>
     * Array("foo", "bar", "baz").Stream(2).Map(Array)
     * 
     * @param   {Func}  Mapper  function that returns a new element
     * @param   {Stream}
     */
    Map(Mapper) {
        n := this.ArgSize(Mapper)
        f := this.Call
        switch (n) {       
            case 1: return Stream(Map1)
            case 2: return Stream(Map2)
            case 3: return Stream(Map3)
            case 4: return Stream(Map4)
        }
        throw ValueError("invalid parameter length",, n)

        Map1(&Out) {
            if (f(&A)) {
                Out := Mapper(A?)
                return true
            }
            return false
        }

        Map2(&Out) {
            if (f(&A, &B)) {
                Out := Mapper(A?, B?)
                return true
            }
            return false
        }

        Map3(&Out) {
            if (f(&A, &B, &C)) {
                Out := Mapper(A?, B?, C?) 
                return true
            }
            return false
        }

        Map4(&Out) {
            if (f(&A, &B, &C, &D)) {
                Out := Mapper(A?, B?, C?, D?)
                return true
            }
            return false
        }
    }

    /**
     * Returns a new stream which transforms its elements by optionally applying
     * the given `Mapper` function, and then flattening resulting arrays into
     * separate elements. Non-`Array` elements are not flattened.
     * 
     * Streams returned by this method have a parameter length of 1.
     * @example
     * 
     * ; <"f", "o", "o", "b", "a", "r">
     * Array("foo", "bar").Stream().FlatMap(StrSplit)
     * 
     * ; <1, "foo", 2, "bar">
     * Array("foo", "bar").Stream(2).FlatMap(Array)
     * 
     * ; <1, 2, 3, 4, 5, 6, 7, 8>
     * Array([1, 2, 3], 4, [5, 6], 7, [8]).Stream().FlatMap()
     * 
     * @param   {Func?}  Mapper  function that returns zero or more new elements
     * @return  {Stream}
     */
    FlatMap(Mapper?) {
        Enumer := (*) => false
        if (!IsSet(Mapper)) {
            switch (this.MaxParams) {
                case 1: Mapper := (A) => A
                case 2: Mapper := (A, B) => A
                case 3: Mapper := (A, B, C) => A
                case 4: Mapper := (A, B, C, D) => A
            }
        }

        n := this.ArgSize(Mapper)
        f := this.Call
        switch (n) {
            case 1: return Stream(FlatMap1)
            case 2: return Stream(FlatMap2)
            case 3: return Stream(FlatMap3)
            case 4: return Stream(FlatMap4)
        }
        throw ValueError("invalid parameter length",, n)

        FlatMap1(&Out) {
            Loop {
                if (Enumer(&Out)) {
                    return true
                }
                if (!f(&A)) {
                    return false
                }
                A := Mapper(A?)
                if (!(A is Array)) {
                    A := Array(A)
                }
                Enumer := A.__Enum(1)
            }
        }

        FlatMap2(&Out) {
            Loop {
                if (Enumer(&Out)) {
                    return true
                }
                if (!f(&A, &B)) {
                    return false
                }
                A := Mapper(A?, B?)
                if (!(A is Array)) {
                    A := Array(A)
                }
                Enumer := A.__Enum(1)
            }
        }

        FlatMap3(&Out) {
            Loop {
                if (Enumer(&Out)) {
                    return true
                }
                if (!f(&A, &B, &C)) {
                    return false
                }
                A := Mapper(A?, B?, C?)
                if (!(A is Array)) {
                    A := Array(A)
                }
                Enumer := A.__Enum(1)
            }
        }

        FlatMap4(&Out) {
            Loop {
                if (Enumer(&Out)) {
                    return true
                }
                if (!f(&A, &B, &C, &D)) {
                    return false
                }
                A := Mapper(A?, B?, C?, D?)
                if (!(A is Array)) {
                    A := Array(A)
                }
                Enumer := A.__Enum(1)
            }
        }
    }

    /**
     * Returns a new stream which mutates the current elements by reference,
     * by applying the given `Mapper` function.
     * 
     * The parameter length of the new stream remains the same.
     * @example
     * 
     * MutateValues(&Index, &Value) {
     *     ++Index
     *     Value .= "_"
     * }
     * 
     * ; <(2, "foo_"), (3, "bar_")>
     * Array("foo", "bar").Stream(2).MapByRef(MutateValues)
     * 
     * @param   {Func}  Mapper  function that mutates elements by reference
     * @return  {Stream}
     */
    MapByRef(Mapper) {
        f := this.Call
        switch (this.MaxParams) {
            case 1: return Stream(MapByRef1)
            case 2: return Stream(MapByRef2)
            case 3: return Stream(MapByRef3)
            case 4: return Stream(MapByRef4)
        }
        throw ValueError("invalid parameter length",, this.MaxParams)

        MapByRef1(&A) {
            while (f(&A)) {
                Mapper(&A)
                return true
            }
            return false
        }

        MapByRef2(&A, &B?) {
            while (f(&A, &B)) {
                Mapper(&A, &B)
                return true
            }
            return false
        }

        MapByRef3(&A, &B?, &C?) {
            while (f(&A, &B, &C)) {
                Mapper(&A, &B, &C)
                return true
            }
            return false
        }

        MapByRef4(&A, &B?, &C?, &D?) {
            while (f(&A, &B, &C, &D)) {
                Mapper(&A, &B, &C, &D)
                return true
            }
            return false
        }
    }

    /**
     * Returns a new stream which is limited to its first element set. Note that
     * this operation is intermediate, meaning that variables must be accessed
     * by using a for-loop or a terminal stream operation such as `.ForEach()`.
     * 
     * The parameter length of the new stream remains the same.
     * @example
     * 
     * Array(1, 2, 3, 4).Stream().RetainIf(x => x > 2).FindFirst() ; <3>
     * 
     * @return  {Stream}
     */
    FindFirst() {
        return this.Limit(1)
    }

    /**
     * Returns a new stream that returns not more than `x` elements before
     * terminating.
     * 
     * The parameter length of the new stream remains the same.
     * @example
     * 
     * Array(1, 2, 3, 4, 5).Stream().Limit(2) ; <1, 2>
     * 
     * @param   {Integer}  n  maximum amount of elements to be returned
     * @return  {Stream}
     */
    Limit(n) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        f := this.Call
        Count := 0
        switch (this.MaxParams) {
            case 1: return Stream(Limit1)
            case 2: return Stream(Limit2)
            case 3: return Stream(Limit3)
            case 4: return Stream(Limit4)
        }
        throw ValueError("invalid parameter length",, this.MaxParams)

        Limit1(&A) {
            return ((Count++) < n) && f(&A)
        }
        Limit2(&A, &B?) {
            return ((Count++) < n) && f(&A, &B)
        }
        Limit3(&A, &B?, &C?) {
            return ((Count++) < n) && f(&A, &B, &C)
        }
        Limit4(&A, &B?, &C?, &D?) {
            return ((Count++) < n) && f(&A, &B, &C, &D)
        }
    }

    /**
     * Returns a new stream that skips the first `x` elements.
     * 
     * The parameter length of the new stream remains the same.
     * @example
     * 
     * Array(1, 2, 3, 4).Stream().Skip() ; <3, 4>
     * 
     * @param   {Integer}  x  amount of elements to be skipped
     * @return  {Stream}
     */
    Skip(n) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        f := this.Call
        Count := 0
        switch (this.MaxParams) {
            case 1: return Stream(Skip1)
            case 2: return Stream(Skip2)
            case 3: return Stream(Skip3)
            case 4: return Stream(Skip4)
        }
        throw ValueError("invalid parameter length",, this.MaxParams)

        Skip1(&A) {
            while (f(&A)) {
                if (++Count > n) {
                    return true
                }
            }
            return false
        }

        Skip2(&A, &B?) {
            while (f(&A, &B)) {
                if (++Count > n) {
                    return true
                }
            }
            return false
        }

        Skip3(&A, &B?, &C?) {
            while (f(&A, &B, &C)) {
                if (++Count > n) {
                    return true
                }
            }
            return false
        }

        Skip4(&A, &B?, &C?, &D?) {
            while (f(&A, &B, &C, &D)) {
                if (++Count > n) {
                    return true
                }
            }
            return false
        }
    }

    /**
     * Returns a new stream which closes as soon as the given predicate
     * function `Condition` evaluates to `false`.
     * 
     * The parameter length of the new stream is determined by `.ArgSize()`.
     * @example
     * 
     * Array(1, -2, 4, 6, 2, 1).Stream().TakeWhile(x => x < 5) ; <1, -2, 4>
     * 
     * @param   {Predicate}  Condition  function that evaluates a condition
     * @return  {Stream}
     */
    TakeWhile(Condition) {
        NoDrop := true
        n := this.ArgSize(Condition)
        f := this.Call
        switch (n) {
            case 1: return Stream(TakeWhile1)
            case 2: return Stream(TakeWhile2)
            case 3: return Stream(TakeWhile3)
            case 4: return Stream(TakeWhile4)
        }
        throw ValueError("invalid parameter length",, n)

        TakeWhile1(&A) {
            if (!NoDrop) {
                return false
            }
            while (f(&A)) {
                if (NoDrop && (NoDrop &= Condition(A?))) {
                    return true
                }
            }
            return false
        }

        TakeWhile2(&A, &B?) {
            if (!NoDrop) {
                return false
            }
            while (f(&A, &B)) {
                if (NoDrop && (NoDrop &= Condition(A?, B?))) {
                    return true
                }
            }
            return false
        }

        TakeWhile3(&A, &B?, &C?) {
            if (!NoDrop) {
                return false
            }
            while (f(&A, &B, &C)) {
                if (NoDrop && (NoDrop &= Condition(A?, B?, C?))) {
                    return true
                }
            }
            return false
        }

        TakeWhile4(&A, &B?, &C?, &D?) {
            if (!NoDrop) {
                return false
            }
            while (f(&A, &B, &C, &D)) {
                if (NoDrop && (NoDrop &= Condition(A?, B?, C?, D?))) {
                    return true
                }
            }
            return false
        }
    }

    /**
     * Returns a new stream which skips the first set of elements as long as
     * the given predicate function `Condition` evaluates to `true`.
     * 
     * The parameter length of the new stream is determined by `.ArgSize()`.
     * @example
     * 
     * Array(1, 2, 3, 4, 2, 1).Stream().DropWhile(x => x < 3) ; <4, 2, 1>
     * 
     * @param   {Predicate}  Condition  function that evaluates a condition
     * @return  {Stream}
     */
    DropWhile(Condition) {
        NoDrop := false
        n := this.ArgSize(Condition)
        f := this.Call
        switch (n) {
            case 1: return Stream(DropWhile1)
            case 2: return Stream(DropWhile2)
            case 3: return Stream(DropWhile3)
            case 4: return Stream(DropWhile4)
        }
        throw ValueError("invalid parameter length",, n)

        DropWhile1(&A) {
            while (f(&A)) {
                if (NoDrop || (NoDrop |= !Condition(A?))) {
                    return true
                }
            }
            return false
        }
        
        DropWhile2(&A, &B?) {
            while (f(&A, &B)) {
                if (NoDrop || (NoDrop |= !Condition(A?, B?))) {
                    return true
                }
            }
            return false
        }

        DropWhile3(&A, &B?, &C?) {
            while (f(&A, &B, &C)) {
                if (NoDrop || (NoDrop |= !Condition(A?, B?, C?))) {
                    return true
                }
            }
            return false
        }

        DropWhile4(&A, &B?, &C?, &D?) {
            while (f(&A, &B, &C, &D)) {
                if (NoDrop || (NoDrop |= !Condition(A?, B?, C?, D?))) {
                    return true
                }
            }
            return false
        }
    }

    /**
     * Removes duplicate elements from the stream by using a `Map` object
     * to track previously seen keys. This method ensures that only unique
     * elements remain in the resulting stream.
     * 
     * The parameter length of the new stream remains the same.
     * 
     * The method determines behavior based on the type of the first parameter:
     * 
     * ---
     * 
     * **1. `CaseSenseOrHasher` (`Boolean`|`String`|`Func`, optional)**:
     * 
     * If a `Boolean` (`true` or `false`) or `String` (`"On"`, `"Off" or
     * `"Locale"``) is provided, it determines the case-sensitivity of the
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
     * Array(1, 2, 3, 1, 2, 3).Stream().Distinct()        ; <1, 2, 3>
     * Array("foo", "FOO", "Foo").Stream().Distinct(true) ; <"foo">
     * 
     * ; <{ Value: 2 }, { Value: 3 }>
     * Array({ Value: 2 }, { Value: 2 }, { Value: 3 })
     *         .Stream().Distinct(Obj => Obj.Value)
     * 
     * @param   {Primitive?/Func?}  CaseSenseOrHasher  case-sensitivity or
     *                                                 object hasher
     * @param   {Primitive?}        CaseSense          case-sensitivity
     * @return  {Stream}
     */
    Distinct(CaseSenseOrHasher := true, CaseSense?) {
        if (HasMethod(CaseSenseOrHasher)) {
            Hasher    := CaseSenseOrHasher
            CaseSense := CaseSense ?? true
        } else {
            Hasher    := unset
            CaseSense := CaseSenseOrHasher
        }

        Values := Map()
        Values.CaseSense := CaseSense
        f := this.Call

        if (!IsSet(Hasher)) {
            return Stream(DefaultDistinct)
        }
        DefaultDistinct(&A) {
            while (f(&A)) {
                if (!Values.Has(A)) {
                    Values[A] := true
                    return true
                }
            }
            return false
        }

        if (!HasMethod(Hasher)) {
            throw TypeError("Expected a Function object",, Type(Hasher))
        }

        switch (this.MaxParams) {
            case 1: return Stream(Distinct1)
            case 2: return Stream(Distinct2)
            case 3: return Stream(Distinct3)
            case 4: return Stream(Distinct4)
        }
        throw ValueError("invalid parameter length",, this.MaxParams)

        Distinct1(&A) {
            while (f(&A)) {
                Hash := Hasher(A?)
                if (!Values.Has(Hash)) {
                    Values[Hash] := true
                    return true
                }
            }
            return false
        }

        Distinct2(&A, &B?) {
            while (f(&A, &B)) {
                Hash := Hasher(A?, B?)
                if (!Values.Has(Hash)) {
                    Values[Hash] := true
                    return true
                }
            }
            return false
        }

        Distinct3(&A, &B?, &C?) {
            while (f(&A, &B, &C)) {
                Hash := Hasher(A?, B?, C?)
                if (!Values.Has(Hash)) {
                    Values[Hash] := true
                    return true
                }
            }
            return false
        }

        Distinct4(&A, &B?, &C?, &D?) {
            while (f(&A, &B, &C, &D)) {
                Hash := Hasher(A?, B?, C?, D?)
                if (!Values.Has(Hash)) {
                    Values[Hash] := true
                    return true
                }
            }
            return false
        }
    }

    /**
     * Returns a new stream which applies the given function `Action` on every
     * element set as intermediate stream operation.
     * 
     * The parameter length of the new stream remains the same.
     * @example
     * 
     * Foo(Value) {
     *     MsgBox("Intermediate stream operation: " . Value)
     * }
     * 
     * Bar(Value) {
     *     MsgBox("Terminal stream operation: " . Value)
     * }
     * 
     * Array(1, 2, 3, 4).Stream().Peek(Foo).ForEach(Bar)
     * 
     * @param   {Func}  Action  the function to call on each element set
     * @return  {Stream}
     */
    Peek(Action) {
        n := this.ArgSize(Action)
        f := this.Call
        switch (n) {
            case 1: return Stream(Peek1)
            case 2: return Stream(Peek2)
            case 3: return Stream(Peek3)
            case 4: return Stream(Peek4)
        }
        throw ValueError("invalid parameter length",, n)

        Peek1(&A) {
            while (f(&A)) {
                Action(A?)
                return true
            }
            return false
        }

        Peek2(&A, &B?) {
            while (f(&A, &B)) {
                Action(A?, B?)
                return true
            }
            return false
        }

        Peek3(&A, &B?, &C?) {
            while (f(&A, &B, &C)) {
                Action(A?, B?, C?)
                return true
            }
            return false
        }

        Peek4(&A, &B?, &C?, &D?) {
            while (f(&A, &B, &C, &D)) {
                Action(A?, B?, C?, D?)
                return true
            }
            return false
        }
    }

    /**
     * Applies a given `Action` function on every element set as terminal
     * stream operation.
     * @example
     * 
     * Array(1, 2, 3, 4).Stream().ForEach(MsgBox)
     * 
     * @param   {Func}  Action  the function to call on each set of elements
     * @return  (none)
     */
    ForEach(Action) {
        n := this.ArgSize(Action)
        f := this.Call
        switch (n) {
            case 1:
                for A in this {
                    Action(A?)
                }
            case 2:
                for A, B in this {
                    Action(A?, B?)
                }
            case 3:
                for A, B, C in this {
                    Action(A?, B?, C?)
                }
            case 4:
                for A, B, C, D in this {
                    Action(A?, B?, C?, D?)
                }
            default:
                throw ValueError("invalid parameter length",, n)
        }
    }

    /**
     * Determines if any element in this stream satisfies the given predicate
     * function `Condition`.
     * 
     * An an element satisfies `Condition`, it is outputted into `&Match`
     * in the form of an array.
     * @example
     * 
     * Array(1, 2, 3, 8, 4).Stream().AnyMatch(x => x < 5, &Output) ; true
     * Output.ToString() ; "[8]"
     * 
     * 
     * @param   {Predicate}  Condition  function that evaluates a condition
     * @param   {VarRef?}    Match      first matching element set
     * @return  {Boolean}
     */
    AnyMatch(Condition, &Match?) {
        n := this.ArgSize(Condition)
        switch (n) {
            case 1:
                for A in this {
                    if (Condition(A?)) {
                        Match := Array(A)
                        return true
                    }
                }
            case 2:
                for A, B in this {
                    if (Condition(A?, B?)) {
                        Match := Array(A, B)
                        return true
                    }
                }
            case 3:
                for A, B, C in this {
                    if (Condition(A?, B?, C?)) {
                        Match := Array(A, B, C)
                        return true
                    }
                }
            case 4:
                for A, B, C, D in this {
                    if (Condition(A?, B?, C?)) {
                        Match := Array(A, B, C, D)
                        return true
                    }
                }
            default:
                throw ValueError("invalid parameter length",, n)
        }
        return false
    }

    /**
     * Returns `true`, if all elements in this map satisfy the given predicate
     * function `Condition`.
     * @example
     * 
     * Array(1, 2, 3, 4).Stream().AllMatch(x => x < 10) ; true
     * 
     * @param   {Predicate}  Condition  function that evaluates a condition
     * @return  {Boolean}
     */
    AllMatch(Condition) {
        n := this.ArgSize(Condition)
        switch (n) {
            case 1:
                for A in this {
                    if (!Condition(A?)) {
                        return false
                    }
                }
            case 2:
                for A, B in this {
                    if (!Condition(A?, B?)) {
                        return false
                    }
                }
            case 3:
                for A, B, C in this {
                    if (!Condition(A?, B?, C?)) {
                        return false
                    }
                }
            case 4:
                for A, B, C, D in this {
                    if (!Condition(A?, B?, C?, D?)) {
                        return false
                    }
                }
            default:
                throw ValueError("invalid parameter length",, n)
        }
        return true
    }

    /**
     * Returns `true`, if none of the element sets in this stream satisfy the
     * given predicate function `Condition`.
     * @example
     * 
     * Array(1, 2, 3, 4, 5, 92).Stream().NoneMatch(x => x > 10) ; false
     * 
     * @param   {Predicate}  Condition  function that evaluates a condition
     * @return  {Boolean}
     */
    NoneMatch(Condition) {
        n := this.ArgSize(Condition)
        switch (n) {
            case 1:
                for A in this {
                    if (Condition(A?)) {
                        return false
                    }
                }
            case 2:
                for A, B in this {
                    if (Condition(A?, B?)) {
                        return false
                    }
                }
            case 3:
                for A, B, C in this {
                    if (Condition(A?, B?, C?)) {
                        return false
                    }
                }
            case 4:
                for A, B, C, D in this {
                    if (Condition(A?, B?, C?, D?)) {
                        return false
                    }
                }
            default:
                throw ValueError("invalid parameter length",, n)
        }
        return true
    }

    /**
     * Returns the highest element in this stream.
     * 
     * If a custom comparator function `Comp` is specified, it's used to
     * determine the ordering of elements; otherwise, numerical ordering is
     * used.
     * 
     * If the stream is empty, this method throws an error.
     * 
     * ---
     * 
     * Only the *first parameter* of each element set is considered for
     * comparison. If comparing beyond the first parameter is required, use
     * `.Map()` to preprocess the stream, or use methods such as `.Reduce()` or
     * `.ToArray().Max()` instead.
     * @see `Comparator`
     * @example
     * 
     * Array(1, 2, 3, 4).Stream().Max()                   ; 4
     * Array("banana", "zigzag").Stream().Max(StrCompare) ; "zigzag"
     * 
     * @param   {Comparator}  Comp  function that compares two elements
     * @return  {Any}
     */
    Max(Comp?) {
        if (!IsSet(Comp)) {
            Comp := (a, b) => (a > b) - (b - a)
        }
        if (!HasMethod(Comp)) {
            throw TypeError("Expected a Function object",, Type(Comp))
        }
        f := this.Call
        while (f(&Result) && !IsSet(Result)) {
        } ; nop
        for Value in f {
            (IsSet(Value) && Comp(Value, Result) > 0 && Result := Value)
        }
        if (!IsSet(Result)) {
            throw UnsetError("every element in this stream is unset")
        }
        return Result
    }

    /**
     * Returns the lowest element in this stream.
     * 
     * If a custom comparator function `Comp` is specified, it is used to
     * determine the ordering of elements; otherwise, numerical ordering is
     * used.
     * 
     * If the stream is empty, this method throws an error.
     * 
     * ---
     * 
     * Only the *first parameter* of each element set is considered for
     * comparison. If comparing beyond the first parameter is required, use
     * `.Map()` to preprocess the stream, or use methods such as `.Reduce()` or
     * `.ToArray().Min()` instead.
     * @see `Comparator`
     * @example
     * 
     * Array(1, 2, 3, 4, 5, 90, -34).Stream().Min()       ; -34
     * Array("banana", "zigzag").Stream().Max(StrCompare) ; "banana"
     * 
     * @param   {Comparator}  Comp  function that compares two elements
     * @return  {Any}
     */
    Min(Comp?) {
        if (!IsSet(Comp)) {
            Comp := (a, b) => (a > b) - (b > a)
        }
        if (!HasMethod(Comp)) {
            throw TypeError("Expected a Function object",, Type(Comp))
        }
        f := this.Call
        while (f(&Result) && !IsSet(Result)) {
        } ; nop
        for Value in f {
            (IsSet(Value) && Comp(Value, Result) < 0 && Result := Value)
        }
        if (!IsSet(Result)) {
            throw UnsetError("every element in this stream is unset")
        }
        return Result
    }

    /**
     * Returns the total sum of numbers in this stream. Unset and non-numerical
     * values are ignored.
     *
     * Only the first parameter of each element set is taken as argument.
     * @example
     * 
     * Array("foo", 3, "4", unset).Stream().Sum() ; 7
     * 
     * @return  {Float}
     */
    Sum() {
        Result := Float(0)
        for Value in this {
            (IsSet(Value) && IsNumber(Value) && Result += Value)
        }
        return Result
    }

    /**
     * Returns an array by collecting elements from this stream. The `n`
     * parameter specifies which parameter to extract from each element set
     * in the stream.
     * @example
     * 
     * Array(1, 2, 3, 4).Stream().Map(x => x * 2).ToArray() ; [2, 4, 6, 8]
     * 
     * @param   {Integer?}  n  index of the parameter to push into array
     * @return  {Array}
     */
    ToArray(n := 1) {
        if (!IsInteger(n)) {
            throw ValueError("Expected an Integer",, n)
        }
        if (n <= 0) {
            throw ValueError("n <= 0",, n)
        }
        if (n == 1) {
            return Array(this*)
        }
        DiscardedVars := []
        Loop (n - 1) {
            DiscardedVars.Push(CreateVarRef())
        }
        return Array(this.Call.Bind(DiscardedVars*)*)

        static CreateVarRef() {
            Ref := unset
            return &Ref
        }
    }

    /**
     * Performs a mutable reduction on the elements of this stream, using the
     * given `Supplier`, `Accumulator`, and optionally a `Finisher` function.
     * This method allows for highly customizable data collection into various
     * types of containers or final structures.
     * 
     * ---
     * 
     * **`Supplier` (`Func`|`Class`)**:
     * 
     * A function or class that provides a new, empty result container.
     * 
     * - For instance, `Array` creates a new array instance.
     * - A custom function can be used to initialize more complex containers.
     * 
     * **`Accumulator` (`Func`)**:
     * 
     * A function that adds an element to the result container.
     * 
     * - The function is called with two arguments: the container and the
     *   current element set of the stream.
     * - The container is mutated as the stream is processed.
     * 
     * **`Finisher` (`Func`, optional)**:
     * 
     * A function that transforms the final result container.
     * 
     * ---
     * @example
     * 
     * ; Map {
     * ;     1 ==> "foo",
     * ;     2 ==> "bar"
     * ; }
     * MapObj := Array("foo", "bar").Stream(2).Collect(Map, Map.Prototype.Set)
     * 
     * @param   {Func}   Supplier     supplies a container (e.g., `Array`)
     * @param   {Func}   Accumulator  adds element to container
     * @param   {Func?}  Finisher     transforms container to final value
     * @return  {Any}
     */
    Collect(Supplier, Accumulator, Finisher?) {
        if (!HasMethod(Supplier)) {
            throw TypeError("Expected a Function object",, Type(Supplier))
        }
        if (!HasMethod(Accumulator)) {
            throw TypeError("Expected a Function object",, Type(Accumulator))
        }
        if (IsSet(Finisher) && !HasMethod(Finisher)) {
            throw TypeError("Expected a Function object",, Type(Finisher))
        }
        
        Container := Supplier()
        switch (this.MaxParams) {
            case 1:
                for A in this {
                    Accumulator(Container, A?)
                }
            case 2:
                for A, B in this {
                    Accumulator(Container, A?, B?)
                }
            case 3:
                for A, B, C in this {
                    Accumulator(Container, A?, B?, C?)
                }
            case 4:
                for A, B, C in this {
                    Accumulator(Container, A?, B?, C?, D?)
                }
            default:
                throw ValueError("invalid parameter length",, this.MaxParams)
        }
        
        if (IsSet(Finisher)) {
            return Finisher(Container)
        }
        return Container
    }

    /**
     * Performs a reduction on the elements of the stream, using the given
     * `Combiner` function. This method iteratively combines elements to produce
     * a single result, optionally starting with an `Identity` value.
     * 
     * ---
     * 
     * **`Combiner` (`Func`)**:
     * 
     * A function that combines two elements into a single result.
     * 
     * - The `Combiner` function is called repeatedly with the current result
     *   and the next element in the stream.
     * - The final result is the accumulated value after processing all of the
     *   elements.
     * 
     * **`Identity` (`Any`, optional)**:
     * 
     * An initial value for the reduction.
     * 
     * - If specified, this value is used as the starting value of the
     *   reduction.
     * - If omitted, the first element of the stream is used as the initial
     *   value, and reduction starts with the second element. An error is
     *   thrown, if the stream has no elements.
     * 
     * ---
     * 
     * This method only operates on the *first parameter* of each element set
     * of the stream. To reduce over multiple parameters, preprocess the stream
     * using `.Map()`.
     * 
     * A particularly flexible way of capturing multiple parameters is by using
     * `.Map(Array)`:
     * 
     * @example
     * 
     * ; <[1, "foo"], [2, "bar"], [3, "baz"]>
     * Array("foo", "bar", "baz").Stream(2).Map(Array)
     * 
     * @example
     * 
     * Product(a, b) {
     *     return a * b
     * }
     * Array(1, 2, unset, 3, unset, 4).Stream().Reduce(Product) ; 24
     * 
     * @param   {Combiner}  Combiner  function that combines two elements
     * @param   {Any?}      Identity  Initial starting value
     * @return  {Any}
     */
    Reduce(Combiner, Identity?) {
        Result := Identity ?? unset
        f := this.Call

        while (!IsSet(Result) && f(&Result)) {
        } ; nop

        for Value in f {
            (IsSet(Value) && Result := Combiner(Result, Value))
        }
        if (!IsSet(Result)) {
            throw UnsetError("every element in this stream is unset")
        }
        return Result
    }

    /**
     * Concatenates the elements of this stream into a single string, separated
     * by the specified `Delimiter`. The method converts objects to strings
     * using their `.ToString()` method.
     * 
     * ---
     * 
     * **`Delimiter` (`String`, optional)**:
     * 
     * Specifies the string used to separate elements in the resulting string
     * (default `""`).
     * 
     * **`InitialCap` (`Integer`, optional)**:
     * 
     * Specifies the initial capacity of the resulting string (default `0`).
     * This can improve performance when working with large strings by
     * pre-allocating the necessary memory.
     * 
     * ---
     * 
     * Only the *first parameter* of each element set is used. To customize this
     * behavior, preprocess this stream with `.Map()`.
     * 
     * ---
     * @example
     * 
     * Array(1, 2, 3, 4).Stream().Join() ; "1234"
     * 
     * @param   {String?}   Delimiter   separator string
     * @param   {Integer?}  InitialCap  initial string capacity
     * @return  {String}
     */
    Join(Delimiter := "", InitialCap := 0) {
        if (IsObject(Delimiter)) {
            throw TypeError("Expected a String",, Type(Delimiter))
        }
        InitialCap := Max(0, InitialCap)
        try VarSetStrCapacity(&Result, InitialCap)

        if (Delimiter == "") {
            for Value in this {
                (IsSet(Value) && Result .= String(Value))
            }
            return Result
        }
        for Value in this {
            (IsSet(Value) && Result .= String(Value))
            Result .= Delimiter
        }
        return SubStr(Result, 1, -StrLen(Delimiter))
    }

    /**
     * Concatenates the elements of this stream into a single string, each
     * element separated by `\n`.
     * @see `Func.Join()`
     * @example
     * 
     * ; 1
     * ; 2
     * ; 3
     * Array(1, 2, 3).Stream().JoinLine()
     * 
     * @param   {Integer?}  InitialCap  initial string capacity
     * @return  {String}
     */
    JoinLine(InitialCap := 0) {
        return this.Join("`n", InitialCap)
    }

    /**
     * Creates an infinite stream where each element is produced by the
     * given supplier function.
     * 
     * The stream is infinite unless filtered or limited with other methods.
     * 
     * @example
     * ; <4, 6, 1, 8, 2, 7>
     * Stream.Generate(() => Random(0, 9)).Limit(6).ToArray()
     * 
     * @param   {Func}    Supplier   function that supplies stream elements
     * @return  {Stream}
     */
    static Generate(Supplier) {
        if (!HasMethod(Supplier)) {
            throw TypeError("Expected a Function object",, Type(Supplier))
        }
        return Stream(Generate)

        Generate(&Out) {
            Out := Supplier()
            return true
        }
    }

    /**
     * Creates a stream where each element is the result of applying `Mapper`
     * to the previous one, starting from `Seed`.
     * 
     * The stream is infinite unless filtered or limited with other methods.
     * 
     * @example
     * ; <0, 2, 4, 6, 8, 10>
     * Stream.Iterate(0, x => (x + 2)).Take(6).ToArray()
     * 
     * @param   {Any}   Seed    the starting value
     * @param   {Func}  Mapper  a function that computes the next value
     * @return  {Stream}
     */
    static Iterate(Seed, Mapper) {
        if (!HasMethod(Mapper)) {
            throw TypeError("Expected a Function object",, Type(Mapper))
        }
        First := true
        Value := unset
        return Stream(Iterate)

        Iterate(&Out) {
            if (First) {
                Value := Seed
                First := false
            } else {
                Value := Mapper(Value)
            }
            Out := Value
            return true
        }
    }
}

class AquaHotkey_Stream extends AquaHotkey {
    class Any {
        /**
         * Returns a function stream with this variable as source.
         * @see `Stream`
         * @example
         * 
         * Arr    := [1, 2, 3, 4, 5]
         * Stream := Arr.Stream(2) ; for Index, Value in Arr {...}
         * 
         * @param   {Integer?}  n  parameter length of the stream
         * @return  {Stream}
         */
        Stream(n := 1) {
            if (!IsInteger(n)) {
                throw TypeError("Expected an Integer",, Type(n))
            }
            if (n < 1) {
                throw ValueError("n < 1",, n)
            }
            if (HasProp(this, "__Enum")) {
                return Stream(this.__Enum(n))
            }
            if (HasMethod(this)) {
                return Stream(GetMethod(this))
            }
            throw UnsetError("this variable is not enumerable",, Type(this))
        }
    }
}