;@region Stream
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
 * Array("foo", "bar").DoubleStream() ; <(1, "foo"), (2, "bar")>
 * ```
 */
class Stream extends BaseStream {
    ;@region Construction
    /**
     * Creates an infinite stream of the given value.
     * 
     * @example
     * Stream.Repeat(5) ; <5, 5, 5, 5, 5, ...>
     * 
     * @param   {Any}  Value  the value to be repeated
     * @returns {Stream}
     */
    static Repeat(Value) => Stream((&Out) => ((Out := Value) || true))

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
     * @param   {Func}  Supplier  function that supplies stream elements
     * @param   {Any*}  Args      zero or more arguments passed to the supplier
     * @returns {Stream}
     */
    static Generate(Supplier, Args*) {
        GetMethod(Supplier)
        return Stream(Generate)

        Generate(&Out) {
            Out := Supplier(Args*)
            return true
        }
    }

    /**
     * Creates an infinite stream that cycles through a set of one or more
     * given values.
     * 
     * @example
     * Stream.Cycle(1, 3, 7) ; <1, 3, 7, 1, 3, 7, 1, 3, ...>
     * 
     * @param   {Any*}  Values  one or more values to be cycled through
     * @returns {Stream}
     */
    static Cycle(Values*) {
        if (!Values.Length) {
            throw UnsetError("no values given", -2)
        }
        return Stream(Cycle)

        Cycle(&Out) {
            static Enumer := Values.__Enum(1)
            while (!Enumer(&Out)) {
                Enumer := Values.__Enum(1)
            }
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

    ; TODO separate Stream.OfProps() and DoubleStream.OfProps() ?
    /**
     * (AutoHotkey v2.1-alpha.10+):
     * 
     * Returns a stream of the object's own properties.
     * 
     * (AutoHotkey v2.1-alpha.18+):
     * 
     * This method allows any value to be passed, instead of objects only.
     * 
     * @example
     * class ExampleBase {
     *     a := 1
     * }
     * 
     * class Example extends ExampleBase {
     *     b := 2
     *     c := 3
     * }
     * 
     * Stream.OfProps(Example()) ; <("a", 1), ("b", 2), ("c", 3), ...>
     * 
     * @param   {Object/Any}  Val  the value whose properties to enumerate
     * @returns {DoubleStream}
     */
    static OfProps(Val) {
        ; Choose one of the two possible implementations during the first
        ; call to this method.
        ({}.DefineProp)(Stream, "OfProps", {
            Call: (IsSet(Props) && Props.IsBuiltIn)
                    ? Post_v2_1_18
                    : Pre_v2_1_18
        })
        return Stream.OfProps(Val)

        static Post_v2_1_18(_, Val) {
            static p := (IsSet(Props) && Props)
            f := p(Val)
            return DoubleStream((&K, &V) => f(&K, &V))
        }

        static Pre_v2_1_18(_, Val) {
            if (!IsObject(Val)) {
                throw TypeError("Expected an Object", -2, Type(Val))
            }
            f := (Object.Prototype.Props)(Val)
            return DoubleStream((&K, &V) => f(&K, &V))
        }
    }

    ; TODO use separate Stream.OfOwnProps() and DoubleStream.OfOwnProps() ?
    /**
     * Returns a stream of the object's own properties.
     * 
     * @example
     * class Example {
     *     a := 1
     *     b := 2
     * }
     * 
     * Stream.OfOwnProps(Example()) ; <("a", 1), ("b", 2)>
     * 
     * @param   {Object}  Obj  the object whose properties to enumerate
     * @returns {Stream}
     */
    static OfOwnProps(Obj) {
        f := ObjOwnProps(Obj)
        return DoubleStream((&K, &V) => f(&K, &V))
    }
    ;@endregion

    ;@region Support
    /**
     * The argument size of the stream.
     * 
     * @returns {Integer}
     */
    static Size => 1

    /**
     * Static constructor that removes the `static OfProps()` on versions
     * below <v2.1-alpha.10.
     */
    static __New() {
        if (VerCompare(A_AhkVersion, "<v2.1-alpha.10")) {
            this.DeleteProp("OfProps")
        }
    }
    ;@endregion

    ;@region Filtering
    /**
     * Returns a new stream that retains elements only if they match the
     * given `Condition`.
     * 
     * @example
     * Array(1, 2, 3, 4).Stream().RetainIf(x => (x > 2)) ; <3, 4>
     * 
     * @param   {Func}  Condition  the given condition
     * @returns {Stream}
     */
    RetainIf(Condition, Args*) {
        f := this.Call
        return Stream(RetainIf)

        RetainIf(&A) {
            while (f(&A)) {
                if (Condition(A?)) {
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
     * @example
     * IsGreater(a, b) {
     *     return (a > b)
     * }
     * Array(1, 2, 3, 4).Stream().RemoveIf(IsGreater, 2) ; <3, 4>
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for condition function
     * @param   {Stream}
     */
    RemoveIf(Condition, Args*) {
        f := this.Call
        return Stream(RemoveIf)

        RemoveIf(&A) {
            while (f(&A)) {
                if (!Condition(A?, Args*)) {
                    return true
                }
            }
            return false
        }   
    }
    ;@endregion

    ;@region Transformation
    /**
     * Returns a new stream that transforms its elements by applying the given
     * `Mapper` function.
     * 
     * @example
     * Times(a, b) {
     *     return (a * b)
     * }
     * Array(1, 2, 3, 4).Stream().Map(Times(2)).ToArray() ; <2, 4, 6, 8>
     * 
     * @param   {Func}  Mapper  function that maps all elements
     * @param   {Any*}  Args    zero or more argument for mapper
     * @param   {Stream}
     */
    Map(Mapper, Args*) {
        f := this.Call
        return Stream(Map)

        Map(&Out) {
            if (f(&A)) {
                Out := Mapper(A?, Args*)
                return true
            }
            return false
        }
    }

    /**
     * Returns a new stream that transforms, and then flattens resulting
     * streams each into separate elements.
     * 
     * @example
     * ; <"f", "o", "o", "b", "a", "r">
     * Array("foo", "bar").Stream().FlatMap((Str) => Str.Stream())
     * 
     * @param   {Func?}  Mapper  function that maps and flattens elements
     * @param   {Any*}   Args    zero or more arguments for the mapper function
     * @returns {Stream}
     */
    FlatMap(Mapper := Stream, Args*) {
        f := this.Call
        return Stream(FlatMap)

        FlatMap(&Out) {
            static Enumer := (*) => false
            Loop {
                if (Enumer(&Out)) {
                    return true
                }
                if (!f(&A)) {
                    return false
                }
                A := Mapper(A?, Args*)
                if (!(A is Stream)) {
                    A := Array(A)
                }
                Enumer := A.__Enum(1)
            }
        }
    }

    /**
     * Returns a new stream that transforms, and then flattens resulting double
     * streams each into separate elements.
     * 
     * @example
     * MsgBox(Array("foo", "bar").Stream().DoubleFlatMap().Join(" "))
     * 
     * @param   {Func?}  Mapper  function to maps and flattens elements
     * @param   {Any*}   Any     zero or more arguments for the mapper function
     * @returns {DoubleStream}
     */
    DoubleFlatMap(Mapper := DoubleStream, Args*) {
        f := this.Call
        return DoubleStream(DoubleFlatMap)

        DoubleFlatMap(&Out1, &Out2) {
            static Enumer := (*) => false
            Loop {
                if (Enumer(&Out1, &Out2)) {
                    return true
                }
                if (!f(&A)) {
                    return false
                }
                A := Mapper(A?, Args*)
                if (!(A is DoubleStream)) {
                    A := Array(A)
                }
                Enumer := A.__Enum(2)
            }
        }
    }

    /**
     * Returns a new stream which mutates the current elements by reference,
     * by applying the given `Mapper` function.
     * 
     * @example
     * MutateValues(&Str) {
     *     Str .= "_"
     * }
     * 
     * Array("foo", "bar").Stream().MapByRef(MutateValues) ; <"foo_", "bar_">
     * 
     * @param   {Func}  Mapper  function that mutates elements by reference
     * @param   {Any*}  Args    zero or more arguments for the mapper function
     * @returns {Stream}
     */
    MapByRef(Mapper, Args*) {
        f := this.Call
        return Stream(MapByRef)

        MapByRef(&A) {
            if (f(&A)) {
                Mapper(&A, Args*)
                return true
            }
            return false
        }
    }

    /**
     * Returns a new stream that returns not more than `n` elements before
     * terminating.
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
        Count := 0
        f := this.Call
        return Stream(Limit)

        Limit(&A) {
            return ((Count++) < n) && f(&A)
        }
    }

    /**
     * Returns a new stream that skips the first `n` elements.
     * 
     * @example
     * Array(1, 2, 3, 4).Stream().Skip(2) ; <3, 4>
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
        return Stream(Skip)

        Skip(&A) {
            static Count := 0
            while (f(&A)) {
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
     * @example
     * Array(1, -2, 4, 6, 2, 1).Stream().TakeWhile(x => x < 5) ; <1, -2, 4>
     * 
     * @param   {Func}  Condition  the given condition
     * @returns {Stream}
     */
    TakeWhile(Condition) {
        f := this.Call
        return Stream(TakeWhile)

        TakeWhile(&A) {
            return f(&A) && Condition(A?)
        }
    }

    /**
     * Returns a new stream that skips elements as long as its elements
     * fulfill the given `Condition`.
     * 
     * @example
     * Array(1, 2, 3, 4, 2, 1).Stream().DropWhile(x => x < 3) ; <4, 2, 1>
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {Stream}
     */
    DropWhile(Condition, Args*) {
        f := this.Call
        return Stream(DropWhile)

        DropWhile(&A) {
            static NoDrop := false
            while (f(&A)) {
                if (NoDrop || (NoDrop |= !Condition(A?, Args*))) {
                    return true
                }
            }
            return false
        }
    }

    /**
     * Returns a stream of unique elements by keeping track of them in a Map.
     * 
     * A custom `KeyExtractor` can be used to specify the map key to be used.
     * 
     * You can determine the behavior of the internal Map by passing one of the
     * following as `MapParam`:
     * - the map to be used;
     * - a function that returns the map to be used;
     * - a case-sensitivity option.
     * 
     * @example
     * ; <"foo">
     * Array("foo", "Foo", "FOO").Distinct(StrLower)
     * 
     * ; <{ x: 23 }, { x: 35 }>
     * Array({ x: 23 }, { x: 35 }, { x: 23 }).Distinct(obj => obj.x)
     * 
     * @param   {Func?}  KeyExtractor    function to create map keys
     * @param   {Any?}   MapParam        internal map options
     * @returns {Stream}
     */
    Distinct(KeyExtractor?, MapParam := Map()) {
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
        if (!IsSet(KeyExtractor)) {
            return Stream(Distinct)
        }
        GetMethod(KeyExtractor)
        return Stream(DistinctBy)

        Distinct(&A) {
            while (f(&A)) {
                if (!Cache.Has(A)) {
                    Cache[A] := true
                    return true
                }
            }
            return false
        }

        DistinctBy(&A) {
            while (f(&A)) {
                Key := KeyExtractor(A?)
                if (!Cache.Has(Key)) {
                    Cache[Key] := true
                    return true
                }
            }
            return false
        }
    }
    ;@endregion

    ;@region Side Effects
    /**
     * Applies the given `Action` on each element as intermediate operation.
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
    Peek(Action, Args*) {
        f := this.Call
        return Stream(Peek)

        Peek(&A) {
            if (f(&A)) {
                Action(A?, Args*)
                return true
            }
            return false
        }
    }

    /**
     * Applies the given `Action` function on every element set as terminal
     * stream operation.
     * 
     * @example
     * Array(1, 2, 3, 4).Stream().ForEach(MsgBox)
     * 
     * @param   {Func}  Action  the function to be called
     * @param   {Any*}  Args    zero or more arguments for the function
     */
    ForEach(Action, Args*) {
        for A in this {
            Action(A?, Args*)
        }
    }
    ;@endregion

    ;@region Matching
    /**
     * Returns whether any element set satisfies the given `Condition`.
     * 
     * @example
     * Array(1, 2, 3, 8, 4).Stream().AnyMatch(&Val, x => (x > 5))
     * 
     * @param   {VarRef}   Out        (output) the first match, if any
     * @param   {Func}     Condition  the given condition
     * @returns {Boolean}
     */
    AnyMatch(&Out, Condition, Args*) {
        Out := unset
        for A in this {
            if (Condition(A?)) {
                Out := A
                return true
            }
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
    AllMatch(Condition, Args*) {
        for A in this {
            if (!Condition(A?)) {
                return false
            }
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
    NoneMatch(Condition, Args*) {
        for A in this {
            if (Condition(A?, Args*)) {
                return false
            }
        }
        return true
    }
    ;@endregion

    ;@region Aggregation
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
     * @returns {Array}
     */
    ToArray() => Array(this*)

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
    ;@endregion
}
;@endregion

;@region BaseStream
class BaseStream {
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
     * 3. `MaxParams` is between `1` and `2`.
     * 
     * ---
     * @param   {Any}  Source  the function used as stream source
     * @returns {Stream}
     */
    static Call(Source) {
        if (this == BaseStream) {
            throw TypeError("This abstract class cannot be used directly.")
        }
        switch {
            case HasMethod(Source):
                Source := GetMethod(Source)
            case HasProp(Source, "__Enum"):
                Source := Source.__Enum(this.Size)
            default:
                throw UnsetError("value is not enumerable",, Type(Source))
        }
        if (Source.IsVariadic) {
            throw ValueError("varargs parameter",, Source.Name)
        }
        if (Source.MaxParams > Stream.MaxSupportedParams) {
            throw ValueError("invalid number of parameters",, Source.MaxParams)
        }
        return super().DefineProp("Call", { Get: (_) => Source })
    }

    /**
     * Creates a new stream consisting of zero or more values `Args*`.
     * 
     * @example
     * Stream.of("Hello", "world!") ; <"Hello", "world!">
     * Stream.of() ; <>
     * 
     * @param   {Any*}  Args
     * @returns {Stream}
     */
    static Of(Args*) => Stream(Args.__Enum(this.Size))

    /**
     * The maximum parameter size currently supported.
     * @returns {Integer}
     */
    static MaxSupportedParams => 2

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
}
;@endregion

;@region DoubleStream
/**
 * A double-size stream.
 */
class DoubleStream extends BaseStream {
    ;@region Construction
    /**
     * Creates an infinite stream of the given value.
     * 
     * - first value: index, starting from 1
     * - second value: the repeated element
     * 
     * @example
     * Stream.Repeat(5) ; <(1, 5), (2, 5), (3, 5), (4, 5), (5, 5), ...>
     * 
     * @param   {Any}  Value  the value to be repeated
     * @returns {Stream}
     */
    static Repeat(Value) {
        return DoubleStream(Repeat)

        Repeat(&Out1, &Out2) {
            static Counter := 0
            Out1 := ++Counter
            Out2 := Value
            return true
        }
    }

    ; TODO Generate()

    /**
     * Creates a new stream consisting of zero or more values `Args*`.
     * 
     * - first value: index, starting from 1
     * - second value: an element
     * 
     * @example
     * Stream.of("Hello", "world!") ; <(1, "Hello"), (2, "world!")>
     * Stream.of() ; <>
     * 
     * @param   {Any*}  Args
     * @returns {Stream}
     */
    static Of(Args*) => DoubleStream(Args.__Enum(2))

    /**
     * Creates an infinite stream that cycles through a set of one or more
     * given values.
     * 
     * - first value: index, starting from 1
     * - second value: an element
     * 
     * @example
     * Stream.Cycle(1, 3, 7) ; <1, 3, 7, 1, 3, 7, 1, 3, ...>
     * 
     * @param   {Any*}  Values  one or more values to be cycled through
     * @returns {Stream}
     */
    static Cycle(Values*) {
        if (!Values.Length) {
            throw UnsetError("no values given", -2)
        }
        return DoubleStream(Cycle)

        Cycle(&Out1, &Out2) {
            static Counter := 0
            static Enumer := Values.__Enum(1)
            while (!Enumer(&Out2)) {
                Enumer := Values.__Enum(1)
            }
            Out1 := ++Counter
            return true
        }
    }
    ;@endregion

    ;@region Support
    /**
     * The argument size of the stream.
     * 
     * @returns {Integer}
     */
    static Size => 2
    ;@endregion

    ;@region Filtering

    ; TODO interop between Single / Double streams, e.g. "Narrow" or "Expand"

    /**
     * Returns a new double stream that retains elements only if they match the
     * given `Condition`.
     * 
     * @example
     * Array("foo", "bar", "baz").DoubleStream()
     *         .RetainIf((Idx, Val) => (Idx != 1)) ; <(2, "bar"), (3, "baz")>
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {DoubleStream}
     */
    RetainIf(Condition, Args*) {
        f := this.Call
        return DoubleStream(RetainIf)

        RetainIf(&A, &B) {
            while (f(&A, &B)) {
                if (Condition(A?, B?, Args*)) {
                    return true
                }
            }
            return false
        }
    }

    /**
     * Returns a new double stream that filter out elements that match the given
     * `Condition`.
     * 
     * @example
     * Array("foo", "bar", "baz").DoubleStream()
     *         .RemoveIf((i, v) => (i == 1) || (v == "bar")) ; <(1, "foo")>
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {DoubleStream}
     */
    RemoveIf(Condition) {
        f := this.Call
        return DoubleStream(RemoveIf)

        RemoveIf(&A, &B?) {
            while (f(&A, &B)) {
                if (!Condition(A?, B?)) {
                    return true
                }
            }
            return false
        }
    }
    ;@endregion

    ;@region Transformation
    /**
     * Returns a new double stream that transforms its elements by applying the
     * given `Mapper` function.
     * 
     * This method returns a stream of size 1.
     * 
     * @example
     * Times(a, b) {
     *     return (a * b)
     * }
     * ; <"1 == foo", "2 == bar">
     * Array("foo", "bar").DoubleStream().Map((i, str) => (i . " == " . str))
     * 
     * @param   {Func}  Mapper  function that maps all elements
     * @param   {Any*}  Args    zero or more argument for mapper
     * @param   {Stream}
     */
    Map(Mapper) {
        f := this.Call
        return Stream(Map)

        Map(&Out) {
            if (f(&A, &B)) {
                Out := Mapper(A?, B?)
                return true
            }
            return false
        }
    }

    /**
     * Returns a new double stream that transforms, and then flattens resulting
     * streams each into separate elements.
     * 
     * This method returns a stream of size 1.
     * 
     * @param   {Func}  Mapper  function that maps and flattens elements
     * @param   {Any*}  Args    zero or more arguments for the mapper function
     * @returns {Stream}
     */
    FlatMap(Mapper) {
        f := this.Call
        return Stream(FlatMap)

        FlatMap(&Out) {
            static Enumer := (*) => false
            Loop {
                if (Enumer(&Out)) {
                    return true
                }
                if (!f(&A, &B)) {
                    return false
                }
                A := Mapper(A?, B?)
                if (!(A is Stream)) {
                    A := Array(A)
                }
                Enumer := A.__Enum(1)
            }
        }
    }

    /**
     * Returns a new double stream that transforms, and then flattens resulting
     * double streams each into separate elements.
     * 
     * @param   {Func}  Mapper  function to maps and flattens elements
     * @param   {Any*}  Any     zero or more arguments for the mapper function
     * @returns {DoubleStream}
     */
    DoubleFlatMap(Mapper, Args*) {
        f := this.Call
        return DoubleStream(DoubleFlatMap)

        DoubleFlatMap(&Out1, &Out2) {
            static Enumer := (*) => false
            Loop {
                if (Enumer(&Out1, &Out2)) {
                    return true
                }
                if (!f(&a, &B)) {
                    return false
                }
                A := Mapper(A?, B?, Args*)
                if (!(A is Stream)) {
                    A := Array(A)
                }
                Enumer := A.__Enum(2)
            }
        }
    }

    /**
     * Returns a new double stream which mutates the current elements by
     * reference, by applying the given `Mapper` function.
     * 
     * @example
     * MutateValues(&Index, &Value) {
     *     ++Index
     *     Value .= "_"
     * }
     * 
     * ; <(2, "foo_"), (3, "bar_")>
     * Array("foo", "bar").DoubleStream().MapByRef(MutateValues)
     * 
     * @param   {Func}  Mapper  function that mutates elements by reference
     * @param   {Any*}  Args    zero or more arguments for the mapper function
     * @returns {DoubleStream}
     */
    MapByRef(Mapper) {
        f := this.Call
        return DoubleStream(MapByRef)

        MapByRef(&A, &B) {
            if (f(&A, &B)) {
                Mapper(&A, &B)
                return true
            }
            return false
        }
    }

    /**
     * Returns a new double stream that returns not more than `n` elements
     * before terminating.
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
        return DoubleStream(Limit)

        Limit(&A, &B) {
            static Count := 0
            return ((Count++) < n) && f(&A, &B)
        }
    }

    /**
     * Returns a new stream that skips the first `n` elements.
     * 
     * @example
     * Array("foo", "bar").DoubleStream().Skip(1) ; <(2, "bar")>
     * 
     * @param   {Integer}  x  amount of elements to be skipped
     * @returns {DoubleStream}
     */
    Skip(n) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        f := this.Call
        return DoubleStream(Skip)

        Skip(&A, &B) {
            static Count := 0
            while (f(&A, &B)) {
                if (++Count > n) {
                    return true
                }
            }
            return false
        }
    }

    /**
     * Returns a new double stream that terminates as soon as an element does
     * not fulfill the given `Condition`.
     * 
     * @example
     * Array(1, -2, 4, 6, 2, 1).DoubleStream().TakeWhile(
     *         (i, x) => (x < 6)) ; <(1, 1), (2, -2), (3, 4)>
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {DoubleStream}
     */
    TakeWhile(Condition) {
        f := this.Call
        return DoubleStream(TakeWhile)

        TakeWhile(&A, &B) {
            return f(&A, &B) && Condition(A?, B?)
        }
    }

    /**
     * Returns a new double stream that skips elements as long as its elements
     * fulfill the given `Condition`.
     * 
     * @example
     * ; <(4, 4), (5, 2), (6, 1)>
     * Array(1, 2, 3, 4, 2, 1).DoubleStream().DropWhile((i, x) => (x < 4))
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {DoubleStream}
     */
    DropWhile(Condition, Args*) {
        f := this.Call
        return DoubleStream(DropWhile)

        DropWhile(&A, &B) {
            static NoDrop := false
            while (f(&A, &B)) {
                if (NoDrop || (NoDrop |= !Condition(A?, B?, Args*))) {
                    return true
                }
            }
            return false
        }
    }

    /**
     * Returns a stream of unique elements by keeping track of them in a Map.
     * 
     * You can determine the behavior of the internal Map by passing one of the
     * following as `MapParam`:
     * - the map to be used;
     * - a function that returns the map to be used;
     * - a case-sensitivity option.
     * 
     * @example
     * ; <"foo">
     * Array("foo", "Foo", "FOO").DoubleStream()
     *         .Distinct((i, str) => StrLower(str))
     * 
     * ; <{ x: 23 }, { x: 35 }>
     * Array({ x: 23 }, { x: 35 }, { x: 23 }).DoubleStream()
     *         .Distinct((i, obj) => obj.x)
     * 
     * @param   {Func}  KeyExtractor    function to create map keys
     * @param   {Any?}  MapParam        internal map options
     * @returns {Stream}
     */
    Distinct(KeyExtractor, MapParam := Map()) {
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
        GetMethod(KeyExtractor)
        return DoubleStream(DistinctBy)

        DistinctBy(&A, &B) {
            while (f(&A)) {
                Key := KeyExtractor(A?, B?)
                if (!Cache.Has(Key)) {
                    Cache[Key] := true
                    return true
                }
            }
            return false
        }
    }
    ;@endregion

    ;@region Matching
    /**
     * Returns whether any element set satisfies the given `Condition`.
     * 
     * @example
     * Array(1, 2, 3, 8, 4).Stream2().AnyMatch(
     *         &Index, &Value,
     *         (Idx, Val) => ((Idx + Val) == 4)
     * )
     * 
     * @param   {VarRef}   Key        (out) value 1 of the first match, if any
     * @param   {VarRef}   Key        (out) value 2 of the first match, if any
     * @param   {Func}     Condition  the given condition
     * @param   {Any*}     Args       zero or more arguments for the condition
     * @returns {Boolean}
     */
    AnyMatch(&Out1, &Out2, Condition, Args*) {
        Out1 := unset
        Out2 := unset
        for A, B in this {
            if (Condition(A?, B?)) {
                Out1 := A
                Out2 := B
                return true
            }
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
    AllMatch(Condition, Args*) {
        for A in this {
            if (!Condition(A?)) {
                return false
            }
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
    NoneMatch(Condition, Args*) {
        for A in this {
            if (Condition(A?, Args*)) {
                return false
            }
        }
        return true
    }
    ;@endregion

    ;@region Side Effects
    /**
     * Applies the given `Action` on each element as intermediate operation.
     * 
     * @example
     * Foo(i, x) => MsgBox("Foo(" . x . ")")
     * Bar(i, x) => MsgBox("Bar(" . x . ")")
     * 
     * ; "Foo(1)", "Bar(1)"; "Foo(2)", "Bar(2)"; ...
     * Array(1, 2, 3, 4).Stream().Peek(Foo).ForEach(Bar)
     * 
     * @param   {Func}  Action  the function to be called
     * @returns {Stream}
     */
    Peek(Action, Args*) {
        f := this.Call
        return DoubleStream(Peek)

        Peek(&A, &B) {
            while (f(&A, &B)) {
                Action(A?, B?, Args*)
                return true
            }
            return false
        }
    }

    /**
     * Applies the given `Action` function on every element set as terminal
     * stream operation.
     * 
     * @example
     * Array(1, 2, 3, 4).Stream().ForEach(MsgBox)
     * 
     * @param   {Func}  Action  the function to be called
     * @param   {Any*}  Args    zero or more arguments for the function
     */
    ForEach(Action, Args*) {
        for A, B in this {
            Action(A?, B?, Args*)
        }
    }

    ;@endregion
}
;@endregion

;@region Extensions
class AquaHotkey_Stream {
static __New() {
    if (ObjGetBase(this) != Object) {
        return
    }
    if (!IsSet(AquaHotkey) || !(AquaHotkey is Class)) {
        return
    }
    (AquaHotkey.__New)(this)
}

;@region Any
class Any {
    static __New() {
        if (VerCompare(A_AhkVersion, "<v2.1-alpha.18")) {
            this.Prototype.DeleteProp("PropsStream")
        }
    }

    /**
     * Returns a stream for this value.
     * @example
     * Arr    := [1, 2, 3, 4, 5]
     * Stream := Arr.Stream() ; for Index, Value in Arr {...}
     * @returns {Stream}
     */
    Stream() => Stream(this)

    /**
     * Returns a double stream for this value.
     * @example
     * Array("foo", "bar").DoubleStream() ; <(1, "foo"), (2, "bar")>
     * 
     * @returns {DoubleStream}
     */
    DoubleStream() => DoubleStream(this)

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
    PropsStream() => Stream.OfProps(this)
} ; class Any
;@endregion

;@region Object
class Object {
    static __New() {
        if (VerCompare(A_AhkVersion, "<v2.1-alpha.10")) {
            this.Prototype.DeleteProp("PropsStream")
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
     * Example().OwnPropsStream() ; <("a", 1), ("b", 2)>
     * 
     * @returns {Stream}
     */
    OwnPropsStream() => Stream.OfOwnProps(this)

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
     * Example(16, 0).PropsStream() ; <("a", 1), ("Size", 16), ...>
     * 
     * @returns {Stream}
     */
    PropsStream() => Stream.OfProps(this)
} ; class Object
;@endregion
} ; class AquaHotkey_Stream
;@endregion