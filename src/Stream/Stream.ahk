;@region Stream
#Include "%A_LineFile%\..\..\Func\Cast.ahk"
#Include "%A_LineFile%\..\..\Collections\Mixins\Enumerable1.ahk"
#Include "%A_LineFile%\..\..\Collections\Mixins\Enumerable2.ahk"

; TODO decide on `.Distinct()` behaviour
;      - default on HashMap() ?
;      - use Set instead of Map ?

/**
 * Streams are a powerful abstraction for processing sequences of data in a
 * declarative way.
 * 
 * ```
 * Array(1, 2, 3, 4, 5, 6).Stream() ; <1, 2, 3, 4, 5, 6>
 *     .RetainIf(IsEven)            ; <2, 4, 6>
 *     .ForEach(MsgBox)
 * ```
 * 
 * ---
 * 
 * They operate lazily, meaning that until the value is actually required on
 * a *terminal* operation such as `.ToArray()` or `.ForEach()`, the stream
 * is a pipeline of functions waiting to be executed.
 * 
 * Streams being lazily evaluated means that they can be both finite and
 * infinite in size.
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
 * 
 * ---
 * 
 * **How it Works - Quick Insight**:
 * 
 * Essentially, streams are layers of enumerator objects stacked on top of each
 * other, divided into different "stages" (`Map()`, `FlatMap()`, `ForEach()`,
 * etc.). Each enumerator "grabs" its elements from the previous enumerator and
 * transforms them in a predefined way.
 * 
 * ---
 * 
 * For example, `TakeWhile` is an operation which should retrieve elements only
 * as long as they all fulfill the given `Condition`, otherwise stop.
 * 
 * ```ahk
 * TakeWhile(Enumer, Condition, Args*)
 *   => (&Out)
 *      => Enumer(&Out) && Condition(Out?, Args*)
 * ```
 * 
 * ---
 * 
 * (see: return value of an enumerator)
 * https://www.autohotkey.com/docs/v2/lib/Enumerator.htm#Next_Return_Value
 * 
 * In the example above, the result of `TakeWhile` is an enumerator which
 * retrieves elements of a previous enumerator `Enumer`, only if `Enumer` has
 * more values `Out`, and `Out` satisfies the given `Condition`.
 * 
 * ---
 * 
 * At its core, this is what makes up the essence of streams - enumerators on
 * steroids. This also means that they're highly compatible with any data type
 * that is enumerable, such as `Array` and `Map`.
 * 
 * We can now use our "stream operation" like this:
 * 
 * ```ahk
 * LessThan(n)
 *   => (x)
 *      => (x < n)
 * 
 * Enumer := Array(1, 2, 3, 4, 5, 6, 7, 8, 9, 10).__Enum(1)
 * Stream := TakeWhile(Enumer, LessThan(6))
 * 
 * for Value in Stream {
 *     MsgBox(Value) ; 1, 2, 3, 4, 5
 * }
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
     * @param   {Any}  Value  the value to be repeated
     * @returns {Stream}
     * @example
     * Stream.Repeat(5) ; <5, 5, 5, 5, 5, ...>
     */
    static Repeat(Value) {
        this.Cast(Repeat)
        Repeat(&Out) {
            Out := Value
            return true
        }
    }

    /**
     * Creates an infinite stream where each element is produced by the
     * given `Supplier` function.
     * 
     * @param   {Func}  Supplier  function that supplies stream elements
     * @param   {Any*}  Args      zero or more arguments passed to the supplier
     * @returns {Stream}
     * @example
     * ; <4, 6, 1, 8, 2, 7> (random)
     * Stream.Generate(Random, 0, 9).Limit(6).ToArray()
     */
    static Generate(Supplier, Args*) {
        GetMethod(Supplier)
        return this.Cast(Generate)
        Generate(&Out) {
            Out := Supplier(Args*)
            return true
        }
    }

    /**
     * Creates an infinite stream that cycles through a set of one or more
     * given values.
     * 
     * @param   {Any*}  Values  one or more values to be cycled through
     * @returns {Stream}
     * @example
     * Stream.Cycle(1, 3, 7) ; <1, 3, 7, 1, 3, 7, 1, 3, ...>
     */
    static Cycle(Values*) {
        if (!Values.Length) {
            throw UnsetError("no values given", -2)
        }
        Index := 0
        return this.Cast(Cycle)

        Cycle(&Out) {
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
     * Creates an infinite stream where each element is the result of applying
     * `Mapper` to the previous one, starting from `Seed`.
     * 
     * @param   {Any}   Seed    the starting value
     * @param   {Func}  Mapper  a function that computes the next value
     * @param   {Any*}  Args    zero or more arguments for the mapper
     * @returns {Stream}
     * @example
     * ; <0, 2, 4, 6, 8, 10>
     * Stream.Iterate(0, (x) => (x + 2)).Limit(6).ToArray()
     */
    static Iterate(Seed, Mapper, Args*) {
        GetMethod(Mapper)
        Value := unset
        return this.Cast(Iterate)

        Iterate(&Out) {
            if (!IsSet(Value)) {
                Value := Seed
            } else {
                Value := Mapper(Value, Args*)
            }
            Out := Value
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
     * @param   {Func}  Condition  the given condition
     * @param   {Any?}  Args       zero or more arguments for the condition
     * @returns {Stream}
     * @example
     * Array(1, 2, 3, 4).Stream().RetainIf(Ge, 2) ; <3, 4>
     */
    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(RetainIf)

        RetainIf(&Out) {
            while (this(&Out)) {
                if (Condition(Out?, Args*)) {
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
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for condition
     * @param   {Stream}
     * @example
     * Array(1, 2, 3, 4).Stream().RemoveIf(Ge, 2) ; <1, 2>
     */
    RemoveIf(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(RemoveIf)
        RemoveIf(&Out) {
            while (this(&Out)) {
                if (!Condition(Out?, Args*)) {
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
     * @param   {Func}  Mapper  function that maps all elements
     * @param   {Any*}  Args    zero or more argument for mapper
     * @param   {Stream}
     * @example
     * Array(1, 2, 3, 4).Stream().Map((x) => (x * 2)).ToArray() ; <2, 4, 6, 8>
     */
    Map(Mapper, Args*) {
        GetMethod(Mapper)
        return this.Cast(Map)
        Map(&Out) {
            if (this(&Out)) {
                Out := Mapper(Out?, Args*)
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
     * @param   {Func?}  Mapper  function that maps and flattens elements
     * @param   {Any*}   Args    zero or more arguments for the mapper function
     * @returns {Stream}
     * @example
     * ; <"f", "o", "o", "b", "a", "r">
     * Array("foo", "bar").Stream().FlatMap()
     */
    FlatMap(Mapper := Stream, Args*) {
        GetMethod(Mapper)
        Enumer := (*) => false
        return this.Cast(FlatMap)

        FlatMap(&Out) {
            loop {
                if (Enumer(&Out)) {
                    return true
                }
                if (!this(&A)) {
                    return false
                }
                A := Mapper(A?, Args*)
                if (!(A is Stream)) {
                    A := Array(A).__Enum(1)
                }
                Enumer := A
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
     * @param   {Func?}  Mapper  function to maps and flattens elements
     * @param   {Any*}   Any     zero or more arguments for the mapper function
     * @returns {DoubleStream}
     * @example
     * MsgBox(Array("foo", "bar").Stream().DoubleFlatMap().Join(" "))
     */
    DoubleFlatMap(Mapper := DoubleStream, Args*) {
        GetMethod(Mapper)
        Enumer := (*) => false
        return this.Cast(DoubleFlatMap)

        DoubleFlatMap(&Out1, &Out2) {
            loop {
                if (Enumer(&Out1, &Out2)) {
                    return true
                }
                if (!this(&A)) {
                    return false
                }
                A := Mapper(A?, Args*)
                if (!(A is DoubleStream)) {
                    A := Array(A).__Enum(2)
                }
                Enumer := A
            }
        }
    }

    /**
     * Returns a new stream which mutates the current elements by reference,
     * by applying the given `Mapper` function.
     * 
     * @param   {Func}  Mapper  function that mutates elements by reference
     * @param   {Any*}  Args    zero or more arguments for the mapper function
     * @returns {Stream}
     * @example
     * ; <"foo_", "bar_">
     * Array("foo", "bar").Stream().MyByRef((&Str) {
     *     Str .= "_"
     * })
     */
    MapByRef(Mapper, Args*) {
        GetMethod(Mapper)
        return this.Cast(MapByRef)

        MapByRef(&Out) {
            if (this(&Out)) {
                Mapper(&Out, Args*)
                return true
            }
            return false
        }
    }

    /**
     * Returns a new stream that returns not more than `n` elements before
     * terminating.
     * 
     * @param   {Integer}  n  maximum amount of elements to be returned
     * @returns {Stream}
     * @example
     * Array(1, 2, 3, 4, 5).Stream().Limit(2) ; <1, 2>
     */
    Limit(n) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        Count := 0
        return this.Cast((&Out) => (  (++Count <= n) && !!this(&Out)  ))
    }

    /**
     * Returns a new stream that skips the first `n` elements.
     * 
     * @param   {Integer}  x  amount of elements to be skipped
     * @returns {Stream}
     * @example
     * Array(1, 2, 3, 4).Stream().Skip(2) ; <3, 4>
     */
    Skip(n) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        Count := 0
        return this.Cast(Skip)

        Skip(&Out) {
            while (this(&Out)) {
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
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {Stream}
     * @example
     * Array(1, -2, 4, 6, 2, 1).Stream().TakeWhile(x => x < 5) ; <1, -2, 4>
     */
    TakeWhile(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(  (&Out) => this(&Out) && !!Condition(Out?, Args*)  )
    }

    /**
     * Returns a new stream that skips elements as long as its elements
     * fulfill the given `Condition`.
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {Stream}
     * @example
     * Array(1, 2, 3, 4, 2, 1).Stream().DropWhile(x => x < 3) ; <4, 2, 1>
     */
    DropWhile(Condition, Args*) {
        GetMethod(Condition)
        NoDrop := false
        return this.Cast(DropWhile)

        DropWhile(&Out) {
            while (this(&Out)) {
                if (NoDrop || (NoDrop |= !Condition(Out?, Args*))) {
                    return true
                }
            }
            return false
        }
    }

    /**
     * Returns a stream of unique elements by keeping track of them in a `Map`.
     * 
     * If specified, `KeyExtractor` retrieves the map key to store the value
     * with. `MapParam` determines what kind of `Map` should be used for
     * internal storage (see {@link AquaHotkey_Map.Map.Create Map.Create()})
     * 
     * @param   {Func?}  KeyExtractor    function to create map keys
     * @param   {Any?}   MapParam        internal map options
     * @returns {Stream}
     * @see {@link HashMap}
     * @see {@link AquaHotkey_Map.Map.Create Map.Create()}
     * @example
     * ; <"foo">
     * Array("foo", "Foo", "FOO").Distinct(StrLower)
     * 
     * ; <{ x: 23 }, { x: 35 }>
     * Array({ x: 23 }, { x: 35 }, { x: 23 }).Distinct(obj => obj.x)
     * 
     * ; (use a HashMap for storing values. This automatically performs
     * ; equivalence checks using `.Eq()`).
     * ; 
     * ; -> <{ x: 12 }, ["2"]>
     * Array({ x: 12 }, { x: 12 }, ["2"], ["2"] ).Distinct(unset, HashMap)
     */
    Distinct(KeyExtractor?, MapParam?) {
        Cache := Map.Create(MapParam?)

        if (!IsSet(KeyExtractor)) {
            return this.Cast(Distinct)
        }
        GetMethod(KeyExtractor)
        return this.Cast(DistinctBy)

        Distinct(&Out) {
            while (this(&Out)) {
                if (!Cache.Has(Out)) {
                    Cache[Out] := true
                    return true
                }
            }
            return false
        }

        DistinctBy(&Out) {
            while (this(&Out)) {
                Key := KeyExtractor(Out?)
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
     * @param   {Func}  Action  the function to be called
     * @param   {Any*}  Args    zero or more arguments for the action
     * @returns {Stream}
     * @example
     * Foo(x) => MsgBox("Foo(" . x . ")")
     * Bar(x) => MsgBox("Bar(" . x . ")")
     * 
     * ; "Foo(1)", "Bar(1)"; "Foo(2)", "Bar(2)"; ...
     * Array(1, 2, 3, 4).Stream().Peek(Foo).ForEach(Bar)
     */
    Peek(Action, Args*) {
        GetMethod(Action)
        return this.Cast(Peek)

        Peek(&Out) {
            if (this(&Out)) {
                Action(Out?, Args*)
                return true
            }
            return false
        }
    }

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region BaseStream

class BaseStream extends Enumerator {
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

        ; `.__Enum()` always takes priority before `.Call()`
        if (HasProp(Source, "__Enum")) {
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
        if (f.MaxParams > this.Size) {
            throw ValueError("invalid number of parameters",, f.MaxParams)
        }

        return this.Cast(Source)
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
    static Of(Args*) => this.Cast(Args.__Enum(this.Size))

    /**
     * The argument size of the stream.
     * 
     * @abstract
     * @returns {Integer}
     */
    static Size {
        get {
            throw PropertyError("Unknown size")
        }
    }

    /**
     * The argument size of the stream.
     * 
     * @abstract
     * @returns {Integer}
     */
    Size {
        get {
            throw PropertyError("Unknown size")
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
     * @param   {Object/Any}  Val  the value whose properties to enumerate
     * @returns {DoubleStream}
     * @example
     * BaseObj := { a: 1 }
     * Obj := { base: BaseObj, b: 2, c: 3 }
     * 
     * Stream.OfProps(Obj) ; <("a", 1), ("b", 2), ("c", 3), ...>
     */
    static OfProps(Val) {
        static P := VerCompare(A_AhkVersion, ">=v2.1-alpha.18")
                ? (Any.Prototype.Props)
                : (Object.Prototype.Props)
        return this.Cast(P(Val))
    }

    /**
     * Returns a stream of the object's own properties.
     * 
     * @param   {Object}  Obj  the object whose properties to enumerate
     * @returns {Stream}
     * @example
     * class Example {
     *     a := 1
     *     b := 2
     * }
     * 
     * Stream.OfOwnProps(Example()) ; <("a", 1), ("b", 2)>
     */
    static OfOwnProps(Obj) => this.Cast(ObjOwnProps(Obj))
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
     * @param   {Any}  Value  the value to be repeated
     * @returns {DoubleStream}
     * @example
     * Stream.Repeat(5) ; <(1, 5), (2, 5), (3, 5), (4, 5), (5, 5), ...>
     */
    static Repeat(Value) {
        Counter := 0
        return this.Cast(Repeat)

        Repeat(&Out1, &Out2) {
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
     * @param   {Func}  Supplier  function that supplies stream elements
     * @param   {Any*}  Args      zero or more arguments passed to the supplier
     * @returns {Stream}
     * @example
     * ; e.g.: <(1, 4), (2, 9), (3, 7), (4, 2), (5, 7), (6, 0)>
     * DoubleStream.Generate(Random, 0, 9).Limit(6)
     */
    static Generate(Supplier, Args*) {
        GetMethod(Supplier)
        Counter := 0
        return this.Cast(Generate)

        Generate(&Out, &Out2) {
            Out1 := ++Counter
            Out2 := Supplier(Args*)
            return true
        }
    }

    /**
     * Creates an infinite stream that cycles through a set of one or more
     * given values.
     * 
     * - first value: index, starting from 1
     * - second value: an element
     * 
     * @param   {Any*}  Values  one or more values to be cycled through
     * @returns {Stream}
     * @example
     * Stream.Cycle(1, 3, 7) ; <1, 3, 7, 1, 3, 7, 1, 3, ...>
     */
    static Cycle(Values*) {
        if (!Values.Length) {
            throw UnsetError("no values given", -2)
        }
        Counter := 0
        Index   := 0
        return this.Cast(Cycle)

        Cycle(&Out1, &Out2) {
            Out1 := ++Counter
            Out2 := (Values.Has(Index + 1))
                    ? (Values.Get(Index + 1))
                    : unset
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
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {DoubleStream}
     * @example
     * Array("foo", "bar", "baz").DoubleStream()
     *         .RetainIf((Idx, Val) => (Idx != 1)) ; <(2, "bar"), (3, "baz")>
     */
    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(RetainIf)

        RetainIf(&A, &B) {
            while (this(&A, &B)) {
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
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {DoubleStream}
     * @example
     * ; <("apple", "banana")>
     * Map("foo", "bar", "baz", "qux", "apple", "banana")
     *         .DoubleStream()
     *         .RemoveIf((Key, Value) {
     *             return (Key == "foo") || (Value == "qux")
     *         })
     */
    RemoveIf(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(RemoveIf)

        RemoveIf(&A, &B?) {
            while (this(&A, &B)) {
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
     * @param   {Func}  Mapper  function that maps all elements
     * @param   {Any*}  Args    zero or more argument for mapper
     * @param   {Stream}
     * @example
     * ; <"Index 1: foo", "Index 2: bar">
     * Array("foo", "bar").DoubleStream().Map((Index, Str) {
     *     return Format("Index {}: {}", Index, Str)
     * })
     */
    Map(Mapper, Args*) {
        GetMethod(Mapper)
        return Stream.Cast(Map)

        Map(&Out) {
            if (this(&A, &B)) {
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
        GetMethod(Mapper)
        Enumer := (*) => false
        return Stream.Cast(FlatMap)

        FlatMap(&Out) {
            loop {
                if (Enumer(&Out)) {
                    return true
                }
                if (!this(&A, &B)) {
                    return false
                }
                A := Mapper(A?, B?, Args*)
                if (!(A is Stream)) {
                    A := Array(A).__Enum(1)
                }
                Enumer := A
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
        GetMethod(Mapper)
        Enumer := (*) => false
        return this.Cast(DoubleFlatMap)

        DoubleFlatMap(&Out1, &Out2) {
            loop {
                if (Enumer(&Out1, &Out2)) {
                    return true
                }
                if (!this(&A, &B)) {
                    return false
                }
                A := Mapper(A?, B?, Args*)
                if (!(A is DoubleStream)) {
                    A := Array(A).__Enum(2)
                }
                Enumer := A
            }
        }
    }

    /**
     * Returns a new double stream which mutates the current elements by
     * reference, by applying the given `Mapper` function.
     * 
     * @param   {Func}  Mapper  function that mutates elements by reference
     * @param   {Any*}  Args    zero or more arguments for the mapper function
     * @returns {DoubleStream}
     * @example
     * MutateValues(&Index, &Value) {
     *     ++Index
     *     Value .= "_"
     * }
     * 
     * ; <(2, "foo_"), (3, "bar_")>
     * Array("foo", "bar").DoubleStream().MapByRef(MutateValues)
     */
    MapByRef(Mapper, Args*) {
        GetMethod(Mapper)
        return this.Cast(MapByRef)

        MapByRef(&A, &B) {
            if (this(&A, &B)) {
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
     * @param   {Integer}  n  maximum amount of elements to be returned
     * @returns {DoubleStream}
     * @example
     * Array(1, 2, 3, 4, 5).DoubleStream().Limit(2) ; <1, 2>
     */
    Limit(n) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        Count := 0
        return this.Cast(  (&A, &B) => (++Count <= n) && this(&A, &B)  )
    }

    /**
     * Returns a new stream that skips the first `n` elements.
     * 
     * @param   {Integer}  x  amount of elements to be skipped
     * @returns {DoubleStream}
     * @example
     * Array("foo", "bar").DoubleStream().Skip(1) ; <(2, "bar")>
     */
    Skip(n) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        Count := 0
        return this.Cast(Skip)

        Skip(&A, &B) {
            while (this(&A, &B)) {
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
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {DoubleStream}
     * @example
     * Array(1, -2, 4, 6, 2, 1).DoubleStream().TakeWhile(
     *         (i, x) => (x < 6)) ; <(1, 1), (2, -2), (3, 4)>
     */
    TakeWhile(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast( (&A, &B) => this(&A, &B) && Condition(A?, B?, Args*) )
    }

    /**
     * Returns a new double stream that skips elements as long as its elements
     * fulfill the given `Condition`.
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {DoubleStream}
     * @example
     * ; <(4, 4), (5, 2), (6, 1)>
     * Array(1, 2, 3, 4, 2, 1).DoubleStream().DropWhile((i, x) => (x < 4))
     */
    DropWhile(Condition, Args*) {
        GetMethod(Condition)
        NoDrop := false
        return this.Cast(DropWhile)

        DropWhile(&A, &B) {
            while (this(&A, &B)) {
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
     * `KeyExtractor` retrieves the Map key that should be used to store with,
     * otherwise the value itself is used as key.
     * 
     * `MapParam` determines the type of Map to use internally. For example,
     * a `HashMap` is able to treat objects equivalent based on `.Eq()`.
     * 
     * @param   {Func}  KeyExtractor    function to create map keys
     * @param   {Any?}  MapParam        internal map options
     * @returns {DoubleStream}
     * @example
     * ; <"foo">
     * Array("foo", "Foo", "FOO").DoubleStream()
     *         .Distinct((i, str) => StrLower(str))
     * 
     * ; <{ x: 23 }, { x: 35 }>
     * Array({ x: 23 }, { x: 35 }, { x: 23 }).DoubleStream()
     *         .Distinct((i, obj) => obj.x)
     */
    Distinct(KeyExtractor, MapParam?) {
        Cache := Map.Create(MapParam?)
        GetMethod(KeyExtractor)
        return this.Cast(DistinctBy)

        DistinctBy(&A, &B) {
            while (this(&A)) {
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
    ;@region Side Effects

    /**
     * Applies the given `Action` on each element as intermediate operation.
     * 
     * @param   {Func}  Action  the function to be called
     * @param   {Any?}  Args    zero or more arguments for the action
     * @returns {DoubleStream}
     * @example
     * Foo(i, x) => MsgBox("Foo(" . x . ")")
     * Bar(i, x) => MsgBox("Bar(" . x . ")")
     * 
     * ; "Foo(1)", "Bar(1)"; "Foo(2)", "Bar(2)"; ...
     * Array(1, 2, 3, 4).Stream().Peek(Foo).ForEach(Bar)
     */
    Peek(Action, Args*) {
        GetMethod(Action)
        return this.Cast(Peek)

        Peek(&A, &B) {
            while (this(&A, &B)) {
                Action(A?, B?, Args*)
                return true
            }
            return false
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
     * @returns {Stream}
     * @example
     * class Example extends Buffer {
     *     a := 1
     * }
     * 
     * Example(16, 0).PropsStream() ; <("a", 1), ("Size", 16), ...>
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
} ; class Object
;@endregion
} ; class AquaHotkey_Stream
;@endregion