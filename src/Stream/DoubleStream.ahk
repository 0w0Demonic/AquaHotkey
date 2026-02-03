#Include "%A_LineFile%\..\BaseStream.ahk"
#Include "%A_LineFile%\..\..\Interfaces\Enumerable2.ahk"

/**
 * A double-size {@link Stream}.
 * 
 * @module  <Stream/DoubleStream>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
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

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Cutting

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

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region .Distinct()

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
    Distinct(KeyExtractor, MapParam := Map()) {
        Cache := IMap.Create(MapParam)
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

;@region Extensions

class AquaHotkey_DoubleStream extends AquaHotkey {
    class Any {
        /**
         * Creates a {@link DoubleStream} for this value.
         * 
         * @returns {DoubleStream}
         * @example
         * Array(3, 5, 2, 6).DoubleStream() ; <(1, 3), (2, 5), (3, 2), ()>
         */
        DoubleStream() => DoubleStream(this)
    }
}

;@endregion
