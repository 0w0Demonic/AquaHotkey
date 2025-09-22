/**
 * AquaHotkey - Stream.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/Stream.ahk
 * 
 * ---
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
     * 3. `MaxParams` is between `1` and `4`.
     * 
     * ---
     * @param   {Func}  Source  the function used as stream source
     * @returns {Stream}
     */
    __New(Source) {
        if (Source.IsVariadic) {
            throw ValueError("varargs parameter",, this.Name)
        }
        if (Source.MaxParams > Stream.MaxSupportedParams) {
            throw ValueError("invalid number of parameters",, Source.MaxParams)
        }
        this.DefineProp("Call", { Get: (_) => Source })
    }

    /**
     * The maximum parameter size currently supported.
     * @returns {Integer}
     */
    static MaxSupportedParams => 4

    /**
     * Returns the minimum parameter length of the underlying stream source.
     * @returns {Integer}
     */
    MinParams => this.Call.MinParams

    /**
     * Returns the maximum parameter length of the underlying stream source.
     * @returns {Integer}
     */
    MaxParams => this.Call.MaxParams

    /**
     * Returns the name of the underlying stream source.
     * @returns {String}
     */
    Name => this.Call.Name

    /**
     * Returns the stream as enumerator object used in for-loops.
     * @returns {Enumerator}
     */
    __Enum(n) => this.Call

    /**
     * Calculates the parameter length of the new stream that is returned after
     * adding an intermediate operation such as `.RetainIf()` to the stream.
     * 
     * ---
     * 
     * Streams always takes the longest possible length they can, depending on
     * how many parameters `Function` supports. For example:
     * 
     * - A stream has 3 parameters.
     * - The function passed in an intermediate operation (such as
     *   `.RetainIf()`) accepts only 2 parameters.
     * - **Result**: The new stream has only 2 parameters.
     * 
     * ---
     * @param   {Func}  Function  function used for an intermediate operation
     * @returns {Integer}
     */
    ArgSize(Function) {
        if (!(Function is Func)) {
            Function := GetMethod(Function, "Call")
        }
        if (Function.IsVariadic) {
            return (this.MaxParams || 1)
        }
        if (!Function.MaxParams) {
            throw ValueError("invalid parameter length: 0",, Function.Name)
        }
        return (Min(this.MaxParams, Function.MaxParams) || 1)
    }

    /**
     * Returns a new stream that retains elements only if they match the
     * given `Condition`.
     * 
     * The new parameter size is decided by `.ArgSize()`.
     * 
     * @example
     * Array(1, 2, 3, 4).Stream().RetainIf(x => (x > 2)) ; <3, 4>
     * 
     * @param   {Func}  Condition  the given condition
     * @returns {Stream}
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
     * Returns a new stream that removes all elements that fulfill the
     * given `Condition`.
     * 
     * The new paremeter size is decided by `.ArgSize()`.
     * 
     * @example
     * Array(1, 2, 3, 4).Stream().RemoveIf(x => (x > 2)) ; <1, 2>
     * 
     * @param   {Func}  Condition  the given condition
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
     * Returns a new stream that transforms its elements by applying the given
     * `Mapper` function.
     * 
     * The resulting stream has a parameter size of 1.
     * 
     * @example
     * ; <2, 4, 6, 8>
     * Array(1, 2, 3, 4).Stream().Map(x => x * 2).ToArray()
     * 
     * ; <(1, "foo"), (2, "bar"), (3, "baz")>
     * Array("foo", "bar", "baz").Stream(2).Map(Array)
     * 
     * @param   {Func}  Mapper  function that maps all elements
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
     * Returns a new stream that transforms, and then flattens resulting
     * arrays each into separate elements.
     * 
     * The resulting stream has a parameter size of 1.
     * 
     * @example
     * ; <"f", "o", "o", "b", "a", "r">
     * Array("foo", "bar").Stream().FlatMap(StrSplit)
     * 
     * ; <1, "foo", 2, "bar">
     * Array("foo", "bar").Stream(2).FlatMap(Array)
     * 
     * @param   {Func?}  Mapper  function that maps and flattens elements
     * @returns {Stream}
     */
    FlatMap(Mapper) {
        Enumer := (*) => false
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
     * 
     * @example
     * MutateValues(&Index, &Value) {
     *     ++Index
     *     Value .= "_"
     * }
     * 
     * ; <(2, "foo_"), (3, "bar_")>
     * Array("foo", "bar").Stream(2).MapByRef(MutateValues)
     * 
     * @param   {Func}  Mapper  function that mutates elements by reference
     * @returns {Stream}
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
     * Returns a new stream that returns not more than `x` elements before
     * terminating.
     * 
     * The parameter length of the new stream remains the same.
     * 
     * @example
     * Array(1, 2, 3, 4, 5).Stream().Limit(2) ; <1, 2>
     * 
     * @param   {Integer}  n  maximum amount of elements to be returned
     * @returns {Stream}
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
     * 
     * @example
     * Array(1, 2, 3, 4).Stream().Skip() ; <3, 4>
     * 
     * @param   {Integer}  x  amount of elements to be skipped
     * @returns {Stream}
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
     * Returns a new stream that terminates as soon as an element does
     * not fulfill the given `Condition`.
     * 
     * The resulting parameter size is determined by `.ArgSize()`.
     * 
     * @example
     * Array(1, -2, 4, 6, 2, 1).Stream().TakeWhile(x => x < 5) ; <1, -2, 4>
     * 
     * @param   {Func}  Condition  the given condition
     * @returns {Stream}
     */
    TakeWhile(Condition) {
        n := this.ArgSize(Condition)
        f := this.Call
        switch (n) {
            case 1: return Stream(TakeWhile1)
            case 2: return Stream(TakeWhile2)
            case 3: return Stream(TakeWhile3)
            case 4: return Stream(TakeWhile4)
        }
        throw ValueError("invalid parameter length",, n)

        TakeWhile1(&A) => f(&A)
                && Condition(A?)

        TakeWhile2(&A, &B?) => f(&A, &B)
                && Condition(A?, B?)

        TakeWhile3(&A, &B?, &C?) => f(&A, &B, &C)
                && Condition(A?, B?, C?)

        TakeWhile4(&A, &B?, &C?, &D?) => f(&A, &B, &C, &D)
                && Condition(A?, B?, C?, D?)
    }

    /**
     * Returns a new stream that skips elements as long as its elements
     * fulfill the given `Condition`.
     * 
     * The resulting parameter size is determined by `.ArgSize()`.
     * 
     * @example
     * Array(1, 2, 3, 4, 2, 1).Stream().DropWhile(x => x < 3) ; <4, 2, 1>
     * 
     * @param   {Func}  Condition  the given condition
     * @returns {Stream}
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
     * Returns a stream of unique elements by keeping track of them in a Map.
     * 
     * A custom `Hasher` can be used to specify the map key to be used.
     * 
     * ```ahk
     * Hasher(Value1?, Value2?, ...)
     * ```
     * 
     * You can determine the behavior of the internal Map by passing either...
     * - the map to be used;
     * - a function that returns the map to be used;
     * - a case-sensitivity option
     * 
     * ...as value for the `MapParam` parameter.
     * 
     * @example
     * ; <"foo">
     * Array("foo", "Foo", "FOO").Distinct(StrLower)
     * 
     * ; <{ x: 23 }, { x: 35 }>
     * Array({ x: 23 }, { x: 35 }, { x: 23 }).Distinct(obj -> obj.x)
     * 
     * @param   {Func?}                  Hasher    function to create map keys
     * @param   {Map?/Func?/Primitive?}  MapParam  internal map options
     * @returns {Stream}
     */
    Distinct(Hasher?, MapParam := Map()) {
        switch {
            case (MapParam is Map):
                Cache := MapParam
            case (HasMethod(MapParam)):
                Cache := MapParam()
                if (!(Cache is Map)) {
                    throw TypeError("Expected a Map",, Type(Cache))
                }
            default:
                Cache := Map()
                Cache.CaseSense := MapParam
        }

        f := this.Call
        if (!IsSet(Hasher)) {
            return Stream(DefaultDistinct)
        }

        GetMethod(Hasher)
        switch (this.MaxParams) {
            case 1: return Stream(Distinct1)
            case 2: return Stream(Distinct2)
            case 3: return Stream(Distinct3)
            case 4: return Stream(Distinct4)
        }
        throw ValueError("invalid parameter length",, this.MaxParams)

        DefaultDistinct(&A) {
            while (f(&A)) {
                if (!Cache.Has(A)) {
                    Cache[A] := true
                    return true
                }
            }
            return false
        }

        Distinct1(&A) {
            while (f(&A)) {
                Hash := Hasher(A?)
                if (!Cache.Has(Hash)) {
                    Cache[Hash] := true
                    return true
                }
            }
            return false
        }

        Distinct2(&A, &B?) {
            while (f(&A, &B)) {
                Hash := Hasher(A?, B?)
                if (!Cache.Has(Hash)) {
                    Cache[Hash] := true
                    return true
                }
            }
            return false
        }

        Distinct3(&A, &B?, &C?) {
            while (f(&A, &B, &C)) {
                Hash := Hasher(A?, B?, C?)
                if (!Cache.Has(Hash)) {
                    Cache[Hash] := true
                    return true
                }
            }
            return false
        }

        Distinct4(&A, &B?, &C?, &D?) {
            while (f(&A, &B, &C, &D)) {
                Hash := Hasher(A?, B?, C?, D?)
                if (!Cache.Has(Hash)) {
                    Cache[Hash] := true
                    return true
                }
            }
            return false
        }
    }

    /**
     * Applies the given `Action` on each element as intermediate operation.
     * 
     * The parameter length of the new stream remains the same.
     * 
     * @example
     * Foo(x) => MsgBox("Foo(" . x . ")")
     * Bar(x) => MsgBox("Bar(" . x . ")")
     * 
     * ; "Foo(1)", "Bar(1)"; "Foo(2)", "Bar(2)"; ...
     * Array(1, 2, 3, 4).Stream().Peek(Foo).ForEach(Bar)
     * 
     * @param   {Func}  Action  the function to be called
     * @returns {Stream}
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
     * Applies the given `Action` function on every element set as terminal
     * stream operation.
     * @example
     * 
     * Array(1, 2, 3, 4).Stream().ForEach(MsgBox)
     * 
     * @param   {Func}  Action  the function to be called
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
     * Returns whether any element set satisfies the given `Condition`.
     * 
     * If a match it found, it'll be returned in the form of an array (which
     * is a truthy value).
     * 
     * @example
     * Match := Array(1, 2, 3, 8, 4).Stream().AnyMatch(x => x > 5)
     * if (Match) {
     *     MsgBox(Match[1]) ; 8
     * }
     * 
     * @param   {Func}     Condition  the given condition
     * @returns {Boolean}
     */
    AnyMatch(Condition) {
        n := this.ArgSize(Condition)
        switch (n) {
            case 1:
                for A in this {
                    if (Condition(A?)) {
                        return Array(A?)
                    }
                }
            case 2:
                for A, B in this {
                    if (Condition(A?, B?)) {
                        return Array(A?, B?)
                    }
                }
            case 3:
                for A, B, C in this {
                    if (Condition(A?, B?, C?)) {
                        return Array(A?, B?, C?)
                    }
                }
            case 4:
                for A, B, C, D in this {
                    if (Condition(A?, B?, C?)) {
                        return Array(A?, B?, C?, D?)
                    }
                }
            default:
                throw ValueError("invalid parameter length",, n)
        }
        return false
    }

    /**
     * Returns `true`, if all elements in this map satisfy the given
     * `Condition`.
     * 
     * @example
     * Array(1, 2, 3, 4).Stream().AllMatch(x => x < 10) ; true
     * 
     * @param   {Func}  Condition  the given condition
     * @returns {Boolean}
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
     * Returns `true`, if none of the element sets in the stream satisfy the
     * given `Condition`.
     * 
     * @example
     * Array(1, 2, 3, 4, 5, 92).Stream().NoneMatch(x => x > 10) ; false
     * 
     * @param   {Func}  Condition  the given condition
     * @returns {Boolean}
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
     * Returns the highest ordered element in the stream.
     * 
     * - If the stream is empty, this method throws an error.
     * - Only the *first parameter* of each element set is compared.
     * 
     * @see `Comparator`
     * @example
     * 
     * Array(1, 2, 3, 4).Stream().Max()                   ; 4
     * Array("banana", "zigzag").Stream().Max(StrCompare) ; "zigzag"
     * 
     * @param   {Func?}  Comp  the comparator to apply
     * @returns {Any}
     */
    Max(Comp := (a, b) => (a > b) - (b - a)) {
        GetMethod(Comp)
        f := this.Call
        while (f(&Result) && !IsSet(Result)) {
        } ; nop
        for Value in f {
            (IsSet(Value) && Comp(Value, Result) > 0 && Result := Value)
        }
        if (!IsSet(Result)) {
            throw UnsetError("no values present")
        }
        return Result
    }

    /**
     * Returns the lowest element in the stream.
     * 
     * - If the stream is empty, this method throws an error.
     * - Only the *first parameter* of each element set is compared.
     * 
     * @see `Comparator`
     * @example
     * 
     * Array(1, 2, 3, 4, 5, 90, -34).Stream().Min()       ; -34
     * Array("banana", "zigzag").Stream().Max(StrCompare) ; "banana"
     * 
     * @param   {Func?}  Comp  the compator to apply
     * @returns {Any}
     */
    Min(Comp := (a, b) => (a > b) - (b > a)) {
        GetMethod(Comp)
        f := this.Call
        while (f(&Result) && !IsSet(Result)) {
        } ; nop
        for Value in f {
            (IsSet(Value) && Comp(Value, Result) < 0 && Result := Value)
        }
        if (!IsSet(Result)) {
            throw UnsetError("no value present")
        }
        return Result
    }

    /**
     * Returns the total sum of numbers in the stream. Unset and non-numerical
     * values are ignored.
     *
     * - Only the first parameter of each element set is taken as argument.
     * 
     * @example
     * Array("foo", 3, "4", unset).Stream().Sum() ; 7
     * 
     * @returns {Float}
     */
    Sum() {
        Result := Float(0)
        for Value in this {
            (IsSet(Value) && IsNumber(Value) && Result += Value)
        }
        return Result
    }

    /**
     * Returns an array by collecting elements from the stream.
     * 
     * - `n` specifies the index of which parameter to collect from each
     *   element set of the stream.
     *  
     * @example
     * Array(1, 2, 3, 4).Stream().Map(x => x * 2).ToArray() ; [2, 4, 6, 8]
     * 
     * @param   {Integer?}  n  index of the parameter to push into array
     * @returns {Array}
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
     * Reduces all elements in the stream into a single value, by repeatedly
     * "merging" values with the given `Combiner` function.
     * 
     * ```ahk
     * ; 10 (1 + 2 + 3 + 4)
     * Array(1, 2, 3, 4).Stream().Reduce((a, b) => (a + b))
     * ```
     * 
     * - If there is no value present in the stream, an error is thrown.
     * - `Identity` can be used to give an initial value to merge with.
     * - `unset` is ignored.
     * - Only the *first parameter* of each element set is merged.
     * 
     * @example
     * Array(1, 2, unset, 3, unset, 4)
     *         .Stream()
     *         .Reduce((a, b) => (a * b)) ; 24
     * 
     * @param   {Combiner}  Combiner  function that combines two elements
     * @param   {Any?}      Identity  initial starting value
     * @returns {Any}
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
            throw UnsetError("no value present")
        }
        return Result
    }

    /**
     * Concatenates the elements of the stream into a single string, separated
     * by the specified `Delimiter`. The method converts objects to strings
     * using their `.ToString()` method.
     * 
     * - `InitialCap` can be used to pre-allocate enough space for concatenating
     *   large strings.
     *   
     * - Only the *first parameter* of each element set is used.
     * 
     * @example
     * Array(1, 2, 3, 4).Stream().Join() ; "1234"
     * 
     * @param   {String?}   Delimiter   separator string
     * @param   {Integer?}  InitialCap  initial string capacity
     * @returns {String}
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
     * Concatenates the elements of the stream into a single string, each
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
     * @returns {String}
     */
    JoinLine(InitialCap := 0) {
        return this.Join("`n", InitialCap)
    }

    /**
     * Converts the stream into a string.
     * 
     * @returns {String}
     */
    ToString() => this.JoinLine()

    /**
     * Creates an infinite stream where each element is produced by the
     * given `Supplier` function.
     * 
     * The stream is infinite unless filtered or limited with other methods.
     * 
     * @example
     * ; <4, 6, 1, 8, 2, 7>
     * Stream.Generate(() => Random(0, 9)).Limit(6).ToArray()
     * 
     * @param   {Func}    Supplier   function that supplies stream elements
     * @returns {Stream}
     */
    static Generate(Supplier) {
        GetMethod(Supplier)
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
     * PlusTwo(x) => (x + 2)
     * 
     * ; <0, 2, 4, 6, 8, 10>
     * Stream.Iterate(0, PlusTwo).Limit(6).ToArray()
     * 
     * @param   {Any}   Seed    the starting value
     * @param   {Func}  Mapper  a function that computes the next value
     * @returns {Stream}
     */
    static Iterate(Seed, Mapper) {
        GetMethod(Mapper)
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
         * Returns a function stream with the current element as source.
         * @see `Stream`
         * 
         * @example
         * Arr    := [1, 2, 3, 4, 5]
         * Stream := Arr.Stream(2) ; for Index, Value in Arr {...}
         * 
         * @param   {Integer?}  n  parameter length of the stream
         * @returns {Stream}
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

    class Object {
        static __New() {
            if (VerCompare(A_AhkVersion, "2.1-alpha.18") < 0) {
                this.DeleteProp("PropsStream")
            }
        }

        /**
         * Returns a stream of the object's own properties. Use this method
         * instead of `.OwnProps().Stream()` to support property values.
         * 
         * @example
         * class Example {
         *     a := 1
         *     b := 2
         * }
         * 
         * Example().OwnPropsStream() ; <("a", 1), ("b", 2)>
         * 
         * @returns {Stream}
         */
        OwnPropsStream() {
            f := this.OwnProps()
            return Stream((&K, &V) => f(&K, &V))
        }

        /**
         * - (v2.1-alpha.18+)
         * 
         * Returns a stream of an object's properties. Use this method instead
         * of `.Props().Stream()` to support property values.
         * 
         * @example
         * class Example extends Buffer {
         *     a := 1
         * }
         * 
         * Example(16, 0).PropsStream() ; <("a", 1), ("Size", 16), ...>
         * 
         * @returns {Stream}
         */
        PropsStream() {
            f := this.Props()
            return Stream((&K, &V) => f(&K, &V))
        }
    }
}