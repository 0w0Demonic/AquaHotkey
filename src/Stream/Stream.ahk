;@region Stream
/**
 * Streams are a powerful abstraction for processing sequences of data in a
 * declarative way.
 * 
 * They operate lazily, meaning that until the value is actually required on
 * a *terminal* operation such as `.ToArray()` or `.ForEach()`, the stream
 * is a pipeline of functions waiting to be executed.
 * 
 * ```
 * Array(1, 2, 3, 4, 5, 6).Stream() ; <1, 2, 3, 4, 5, 6>
 *     .RetainIf(IsEven)            ; <2, 4, 6>
 *     .ForEach(MsgBox)
 * ```
 * 
 * Streams being lazily evaluated means that they can be both finite and
 * infinite in size.
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
 * 
 * @author  0w0Demonic
 * @module  <Stream/Stream>
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Stream extends BaseStream
{
    ;---------------------------------------------------------------------------
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
    static Repeat(Value) {
        return Stream(Repeat)

        Repeat(&Out) {
            Out := Value
            return true
        }
    }

    /**
     * Creates an infinite stream where each element is produced by the
     * given `Supplier` function.
     * 
     * The stream is infinite unless filtered or limited with other methods.
     * 
     * @example
     * ; <4, 6, 1, 8, 2, 7>
     * Stream.Generate(Random, 0, 9).Limit(6).ToArray()
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
            static Index := 0
            if (!Values.Has(Index + 1)) {
                Out := unset
            } else {
                Out := Values.Get(Index + 1)
            }
            Index := Mod(Index + 1, Values.Length)
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
     * @param   {Any*}  Args    zero or more arguments for the mapper
     * @returns {Stream}
     */
    static Iterate(Seed, Mapper, Args*) {
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
    ;---------------------------------------------------------------------------
    ;@region Support

    /**
     * The argument size of the stream.
     * 
     * @returns {Integer}
     */
    static Size => 1

    /**
     * The argument size of the stream.
     * 
     * @returns {Integer}
     */
    Size => 1

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
     * Array(1, 2, 3, 4).Stream().RetainIf(Ge, 2) ; <3, 4>
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any?}  Args       zero or more arguments for the condition
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
     * Array(1, 2, 3, 4).Stream().RemoveIf(Ge, 2) ; <1, 2>
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for condition
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
     * Times(a, b) => (a * b)
     * 
     * Array(1, 2, 3, 4).Stream().Map(Times, 2).ToArray() ; <2, 4, 6, 8>
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
     * If the mapper returns a value other than a `Stream`, this method will
     * attempt to iterate through the 1-param enumerator (`.__Enum(1)`).
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
     * If the mapper returns a value other than a `DoubleStream`, this method
     * will attempt to iterate through the 2-param enumerator (`.__Enum(2)`).
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

        return Stream((&A) => (  (Count++ < n) && !!f(&A)  ))
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
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {Stream}
     */
    TakeWhile(Condition, Args*) {
        f := this.Call
        return Stream(TakeWhile)

        TakeWhile(&A) => (  f(&A) && !!Condition(A?, Args*)  )
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

    ; TODO integrate this into the new Eq() lib
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
    ;---------------------------------------------------------------------------
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
     * @param   {Any*}  Args    zero or more arguments for the action
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
    ;---------------------------------------------------------------------------
    ;@region Matching

    /**
     * Returns `true`, if any element in this stream satisfies the given
     * `Condition`, otherwise `false`.
     * 
     * @example
     * Array(1, 2, 3, 8, 4).Stream().Any(&Val, (x) => (x > 5))
     * 
     * @param   {VarRef}   Out        (output) the first match, if any
     * @param   {Func}     Condition  the given condition
     * @param   {Any*}     Args       zero or more arguments for the condition
     * @returns {Boolean}
     */
    Any(&Out, Condition, Args*) {
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
     * Array(1, 2, 3, 4).Stream().All(x => x < 10) ; true
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {Boolean}
     */
    All(Condition, Args*) {
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
     * Array(1, 2, 3, 4, 5, 92).Stream().None(x => x > 10) ; false
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {Boolean}
     */
    None(Condition, Args*) {
        for A in this {
            if (Condition(A?, Args*)) {
                return false
            }
        }
        return true
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Aggregation

    ; TODO integrate this into new Ord() lib

    /**
     * Returns the highest ordered element in the stream.
     * 
     * `unset` is not treated as a value. If none of the stream elements have
     * a value, an error is thrown.
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

    ; TODO integrate this into new Ord() lib

    /**
     * Returns the lowest element in the stream.
     * 
     * `unset` is not treated as a value. If none of the stream elements have
     * a value, an error is thrown.
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
     * Returns the total sum of numbers in the stream. `unset` and non-numerical
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
     * @example
     * Range(1, 4).Stream().Map(TimesTwo).ToArray() ; [2, 4, 6, 8]
     * 
     * @returns {Array}
     */
    ToArray() => Array(this*)

    /**
     * Reduces the stream by passing all its elements to the given `Collector`
     * function which returns the final result.
     * 
     * An extended version of this method is available in `<Stream/Collector>`.
     * 
     * @example
     * R() => Range(1, 1000).Stream()
     * 
     * R().Collect(Array) ; [1, 2, 3, ..., 1000]
     * R().Collect(Map)   ; Map { 1: 2, ... , 999: 1000 }
     * 
     * R().Collect((Args*) => ...)
     * 
     * @param   {Func}  Collector  function that collects values
     * @returns {Any}
     */
    Collect(Collector) {
        GetMethod(Collector)
        return Collector(this*)
    }

    /**
     * Folds all elements in the stream into a single value, by repeatedly
     * "merging" values with the given `Combiner` function.
     * 
     * `Identity` can be used to give an initial value to merge with. Otherwise,
     * an error is thrown if none of the stream elements have a value
     * (`IsSet()`).
     * 
     * @example
     * Product(a, b) => (a * b)
     * 
     * Array(1, 2, unset, 3, unset, 4).Stream().Fold(Product)
     * 
     * @param   {Combiner}  Combiner  function that combines two elements
     * @param   {Any?}      Identity  initial starting value
     * @returns {Any}
     */
    Fold(Combiner, Identity?) {
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
     * @example
     * Array(1, 2, 3, 4).Stream().Join(", ") ; "1, 2, 3, 4"
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
     * 
     * @example
     * ; 1
     * ; 2
     * ; 3
     * Array(1, 2, 3).Stream().JoinLine()
     * 
     * @param   {Integer?}  InitialCap  initial string capacity
     * @returns {String}
     */
    JoinLine(InitialCap := 0) => this.Join("`n", InitialCap)

    /**
     * Converts the stream into a string.
     * 
     * @returns {String}
     */
    ToString() => this.JoinLine()
    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region BaseStream

class BaseStream {
    /**
     * Constructs a new stream with the given `Source` used for retrieving
     * elements. When retrieving the underlying Enumerator object, `__Enum`
     * always takes precedence over `Call`, and goes down a chain of `__Enum`
     * calls if necessary.
     * 
     * For example:
     * ```ahk
     * class A { __Enum(ArgSize) => B()    }
     * class B { __Enum(ArgSize) => MyFunc }
     * 
     * (A.Stream().Call == MyFunc) ; true
     * ```
     * 
     * **Requirements for a Valid Stream Source**:
     * 
     * 1. Only ByRef parameters `&ref`.
     * 2. No variadic parameters `args*`.
     * 3. `MaxParams` is between `1` and `2`.
     * 
     * @param   {Any}  Source  the function used as stream source
     * @returns {BaseStream}
     */
    static Call(Source) {
        if (this == BaseStream) {
            throw TypeError("This abstract class cannot be used directly.")
        }

        while (HasProp(Source, "__Enum")) {
            Source := Source.__Enum(this.Size)
        }

        ; At this point, `Source` must be callable
        if (!HasMethod(Source)) {
            throw UnsetError("value is not enumerable",, Type(Source))
        }

        ; Do some assertions on the enumerator being used. If `Source` is an
        ; object, get the actual `Call` function.
        f := (Source is Func) ? Source : GetMethod(Source, "Call")
        if (f.IsVariadic) {
            throw ValueError("varargs parameter",, f.Name)
        }

        ; `BoundFunc`s are broken in terms of `MinParams`/`MaxParams`,
        ; but this doesn't affect this simple assertion.
        if (f.MaxParams > Stream.MaxSupportedParams) {
            throw ValueError("invalid number of parameters",, f.MaxParams)
        }

        ; initialize and set `Call` to return our enumerator. This is either
        ; a function or an object with a `Call` method.
        return super().DefineProp("Call", { Get: (_) => Source })
    }

    /**
     * Creates a new stream consisting of zero or more values `Args*`.
     * 
     * @example
     * Stream.of("Hello", "world!") ; <"Hello", "world!">
     * Stream.of() ; <>
     * 
     * @param   {Any*}  Args  zero or more stream elements
     * @returns {Stream}
     */
    static Of(Args*) => Stream(Args.__Enum(this.Size))

    /**
     * The maximum parameter size currently supported.
     * 
     * @returns {Integer}
     */
    static MaxSupportedParams => 2

    /**
     * Returns the minimum parameter length of the underlying stream source.
     * 
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
     * 
     * @param   {Integer}  n  parameter length of the enumerator
     * @returns {Enumerator}
     */
    __Enum(n) {
        if (n > this.Size) {
            Msg := "Unable to handle more than " . this.Size . " parameters."
        }
        return this.Call
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region DoubleStream

/**
 * A double-size stream.
 */
class DoubleStream extends BaseStream
{
    ;---------------------------------------------------------------------------
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

    /**
     * Creates an infinite double stream where the first value is the index
     * of the element, and the second value is produced by the given
     * `Supplier` function.
     * 
     * The stream is infinite unless filtered or limited with other methods.
     * 
     * @example
     * ; e.g.: <(1, 4), (2, 9), (3, 7), (4, 2), (5, 7), (6, 0)>
     * DoubleStream.Generate(Random, 0, 9).Limit(6)
     * 
     * @param   {Func}  Supplier  function that supplies stream elements
     * @param   {Any*}  Args      zero or more arguments passed to the supplier
     * @returns {Stream}
     */
    static Generate(Supplier, Args*) {
        GetMethod(Supplier)
        return DoubleStream(Generate)

        Generate(&Out, &Out2) {
            static Counter := 0
            Out1 := ++Counter
            Out2 := Supplier(Args*)
            return true
        }
    }

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
            static Index := 0

            Out1 := ++Counter

            if (!Values.Has(Index + 1)) {
                Out2 := unset
            } else {
                Out2 := Values.Get(Index + 1)
            }
            Index := Mod(Index + 1, Values.Length)
            return true
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Support

    /**
     * The argument size of the stream.
     * 
     * @returns {Integer}
     */
    static Size => 2

    /**
     * The argument size of the stream.
     */
    Size => 2

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Filtering

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
     * Returns a new double stream that filters out all elements that match the
     * given `Condition`.
     * 
     * @example
     * ; <("apple", "banana")>
     * Map("foo", "bar", "baz", "qux", "apple", "banana")
     *         .DoubleStream()
     *         .RemoveIf((Key, Value) {
     *             return (Key == "foo") || (Value == "qux")
     *         })
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {DoubleStream}
     */
    RemoveIf(Condition, Args*) {
        f := this.Call
        return DoubleStream(RemoveIf)

        RemoveIf(&A, &B?) {
            while (f(&A, &B)) {
                if (!Condition(A?, B?, Args*)) {
                    return true
                }
            }
            return false
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Transformation

    /**
     * Returns a new double stream that transforms its elements by applying the
     * given `Mapper` function.
     * 
     * @example
     * 
     * ; <"Index 1: foo", "Index 2: bar">
     * Array("foo", "bar").DoubleStream().Map((Index, Str) {
     *     return Format("Index {}: {}", Index, Str)
     * })
     * 
     * @param   {Func}  Mapper  function that maps all elements
     * @param   {Any*}  Args    zero or more argument for mapper
     * @param   {Stream}
     */
    Map(Mapper, Args*) {
        f := this.Call
        return Stream(Map)

        Map(&Out) {
            if (f(&A, &B)) {
                Out := Mapper(A?, B?, Args*)
                return true
            }
            return false
        }
    }

    /**
     * Returns a stream that transforms the elements of this stream by applying
     * the given `Mapper` function, flattening resulting streams into separate
     * elements.
     * 
     * If the mapper returns something other than a `Stream`, this method
     * will attempt to traverse the 1-param enumerator (`.__Enum(1)`).
     * 
     * @param   {Func}  Mapper  function that maps and flattens elements
     * @param   {Any*}  Args    zero or more arguments for the mapper function
     * @returns {Stream}
     */
    FlatMap(Mapper, Args*) {
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
                A := Mapper(A?, B?, Args*)
                if (!(A is Stream)) {
                    A := Array(A)
                }
                Enumer := A.__Enum(1)
            }
        }
    }

    /**
     * Returns a new double stream that transforms the elements of this stream
     * by applying the given `Mapper` function, flattening resulting double
     * stream into separate elements.
     * 
     * If the mapper returns something other than a `DoubleStream`, this method
     * will attempt to traverse the 2-param enumerator (`.__Enum(2)`).
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
    MapByRef(Mapper, Args*) {
        f := this.Call
        return DoubleStream(MapByRef)

        MapByRef(&A, &B) {
            if (f(&A, &B)) {
                Mapper(&A, &B, Args*)
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
     * Array(1, 2, 3, 4, 5).DoubleStream().Limit(2) ; <1, 2>
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
    TakeWhile(Condition, Args*) {
        f := this.Call
        return DoubleStream(TakeWhile)

        TakeWhile(&A, &B) {
            return f(&A, &B) && !!Condition(A?, B?, Args*)
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

    ; TODO integrate this into new Eq() lib?
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
    ;---------------------------------------------------------------------------
    ;@region Matching

    /**
     * Returns `true` if any element set in this stream satisfies the given
     * `Condition`.
     * 
     * @example
     * Array(1, 2, 3, 8, 4).DoubleStream().Any(
     *     &Index, &Value,
     *     (Idx, Val) => ((Idx + Val) == 4)
     * )
     * 
     * @param   {VarRef}   Key        (out) value 1 of the first match, if any
     * @param   {VarRef}   Key        (out) value 2 of the first match, if any
     * @param   {Func}     Condition  the given condition
     * @param   {Any*}     Args       zero or more arguments for the condition
     * @returns {Boolean}
     */
    Any(&Out1, &Out2, Condition, Args*) {
        GetMethod(Condition)
        Out1 := unset
        Out2 := unset
        for A, B in this {
            if (Condition(A?, B?, Args*)) {
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
     * Array(1, 2, 3, 4).DoubleStream().All(x => x < 10) ; true
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {Boolean}
     */
    All(Condition, Args*) {
        GetMethod(Condition)
        for A in this {
            if (!Condition(A?, Args*)) {
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
     * Array(1, 2, 3, 4, 5, 92).DoubleStream().NoneMatch(x => x > 10) ; false
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {Boolean}
     */
    None(Condition, Args*) {
        GetMethod(Condition)
        for A in this {
            if (Condition(A?, Args*)) {
                return false
            }
        }
        return true
    }

    ;@endregion
    ;---------------------------------------------------------------------------
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
     * @param   {Any?}  Args    zero or more arguments for the action
     * @returns {DoubleStream}
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
;-------------------------------------------------------------------------------
;@region Extensions

class AquaHotkey_Stream {
static __New() {
    if (this != AquaHotkey_Stream) {
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
     * Returns a new {@link Stream} for this value.
     * @example
     * 
     * Arr    := [1, 2, 3, 4, 5]
     * Stream := Arr.Stream() ; for Index, Value in Arr {...}
     * @returns {Stream}
     */
    Stream() => Stream(this)

    /**
     * Returns a {@link DoubleStream} for this value.
     * @example
     * Array("foo", "bar").DoubleStream() ; <(1, "foo"), (2, "bar")>
     * 
     * @returns {DoubleStream}
     */
    DoubleStream() => DoubleStream(this)

    /**
     * - (v2.1-alpha.18+)
     * 
     * Returns a {@link Stream} of an object's properties. Use this method
     * instead of `.Props().Stream()` to support property values.
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
     * Returns a {@link Stream} of the object's own properties. Use this method
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
     * @returns {DoubleStream}
     */
    PropsStream() => Stream.OfProps(this)
} ; class Object
;@endregion
} ; class AquaHotkey_Stream
;@endregion