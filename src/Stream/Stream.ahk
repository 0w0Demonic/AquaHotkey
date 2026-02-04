#Include "%A_LineFile%\..\..\Interfaces\Enumerable1.ahk"
#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\BaseStream.ahk"
#Include "%A_LineFile%\..\DoubleStream.ahk"

;@region Stream
/**
 * Streams are a powerful abstraction for processing sequences of data in a
 * declarative way.
 * 
 * ```ahk
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
 * ```ahk
 * Array(1, 2, 3, 4, 5).Stream() ; <1, 2, 3, 4, 5>
 * ```
 * 
 * - `(` and `)`: denotes a single element in the stream when it has multiple
 *                parameters. For example:
 * 
 * ```ahk
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
    Size => 1

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

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region .Limit(), .Skip()

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

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region .TakeWhile(), .DropWhile()

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
     * Returns a new stream that terminates as soon as an element fulfills
     * the given `Condition`.
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {Stream}
     * @example
     * Array(1, -2, 4, 6, 2, 1).Stream().TakeUntil(x => x > 5) ; <1, -2, 4>
     */
    TakeUntil(Condition, Args*) {
        GetMethod(Condition)
        return this.Cast(  (&Out) => this(&Out) && !Condition(Out?, Args*)  )
    }

    /**
     * Returns a new stream that skips the first elements as long as its
     * elements fulfill the given `Condition`.
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
     * Returns a new stream that skips the first elements as long as its
     * elements do not fulfill the given `Condition`.
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments for the condition
     * @returns {Stream}
     * @example
     * Array(1, 2, 3, 4, 2, 1).Stream().DropUntil(x => x >= 3) ; <4, 2, 1>
     */
    DropUntil(Condition, Args*) {
        GetMethod(Condition)
        NoDrop := false
        return this.Cast(DropUntil)

        DropUntil(&Out) {
            while (this(&Out)) {
                if (NoDrop || (NoDrop |= !!Condition(Out?, Args*))) {
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
     * Returns a stream of unique elements by keeping track of them in an
     * `ISet`.
     * 
     * If specified, `KeyExtractor` retrieves the key with which the value
     * should be stored. `SetParam` determines what kind of `Set` should
     * be used for storage.
     * 
     * @param   {Func?}  KeyExtractor    function to create map keys
     * @param   {Any?}   SetParam        internal map options
     * @returns {Stream}
     * @see {@link HashMap}
     * @see {@link ISet.Create()}
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
     * Array({ x: 12 }, { x: 12 }, ["2"], ["2"] ).Distinct(unset, HashSet)
     */
    Distinct(KeyExtractor?, SetParam := Set()) {
        Cache := ISet.Create(SetParam)

        if (!IsSet(KeyExtractor)) {
            return this.Cast(Distinct)
        }
        GetMethod(KeyExtractor)
        return this.Cast(DistinctBy)

        Distinct(&Out) {
            while (this(&Out)) {
                if (Cache.Add(Out)) {
                    return true
                }
            }
            return false
        }

        DistinctBy(&Out) {
            while (this(&Out)) {
                Key := KeyExtractor(Out?)
                if (Cache.Add(Key)) {
                    return true
                }
            }
            return false
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region .Peek()

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
;@region Extensions

class AquaHotkey_Stream extends AquaHotkey {
    class Any {
        /**
         * Returns a new {@link Stream} for this value.
         * 
         * @returns {Stream}
         * @example
         * Arr    := [1, 2, 3, 4, 5]
         * Stream := Arr.Stream() ; for Index, Value in Arr {...}
         */
        Stream() => Stream(this)
    }
}

;@endregion