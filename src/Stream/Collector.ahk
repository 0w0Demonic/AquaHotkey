#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

; TODO refactor this into mixins?

/**
 * AquaHotkey - Collector.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - Extensions/Collector.ahk
 * 
 * ---
 * 
 * A collector is an object which accumulates elements from a data
 * container (such an array or a stream) into a final result.
 * 
 * Coming from a functional programming paradigm, multiple collector objects
 * can be composed together to form complex and extremely flexible operations.
 * 
 * ```ahk
 * ; Map {
 * ;     true:  [2, 4, 6, ..., 498],
 * ;     false: [500, 502, 504, ..., 2000]
 * ; }
 * Range(1000).Collect(C.Map(TimesTwo, C.Partition(LessThan500)))
 * ```
 * 
 * ---
 * 
 * **How They Work**:
 * 
 * - `.Supplier()`: initializes something to store the result in
 * 
 *   ```ahk
 *   Supplier() => Array()
 *   ```
 * 
 * Although the value produced by `.Supplier()` should generally be an object,
 * you can use VarRefs (e.g., `&Str`) to wrap around strings and numbers.
 * 
 * ---
 * 
 * - `.Accumulator(Obj, Val?)`: Determines how to collect the input elements.
 * 
 *   ```ahk
 *   Accumulator(Arr, Val?) => Arr.Push(Val?)
 *   ```
 * 
 * ---
 * 
 * - `.Finisher(Obj)`: Creates a final result.
 * 
 *   ```ahk
 *   Finisher(Arr) => Arr
 *   ```
 * 
 * ---
 * 
 * **Implement Your Own Collectors**:
 * 
 * Create custom collectors either by calling `.__New()` with the given
 * supplier, accumulator and finisher functions, or by extending the `Collector`
 * type.
 * 
 * - Method 1: using `.__New()` directly (not recommended)
 * 
 *   ```ahk
 *   ToArray := Collector(
 *           ()          => Array(),
 *           (Arr, Val?) => Arr.Push(Val?),
 *           (Arr)       => Arr)
 *   ```
 * 
 * ---
 * 
 * - Method 2: subclass (recommended)
 *   - By far the most straightforward and flexible approach.
 *   - Always use this approach, if you're building something non-trivial.
 *   - **If you define your own `.__New()`, you must call `super.__New()`**.
 *   
 *   ```ahk
 *   class Average extends Collector {
 *       Count := 0
 *       Sum   := Float(0)
 *       
 *       Supplier() { ; do nothing
 *       }
 *       Accumulator(_, Num?) {
 *           if (IsSet(Num) && IsNumber(Num)) {
 *               this.Count++
 *               this.Sum += Num
 *           }
 *       }
 *       Finisher(_) {
 *           if (this.Count) {
 *               return (this.Sum / this.Count)
 *           }
 *           return Float(0)
 *       }
 *   }
 *   ... Something.Collect(Average())
 *   ```
 * 
 * ---
 * 
 * - Method 3: "static collectors"
 * 
 *   - Same as method 2, but everything is defined statically.
 *   - The class itself can be used as the collector.
 *   - Works well for more trivial implementations.
 * 
 *   ```
 *   class ToArray extends Collector {
 *       static Supplier()             => Array()
 *       static Accumulator(Arr, Val?) => Arr.Push(Val?)
 *       static Finisher(Arr)          => Arr
 *   }
 * 
 *   ; use the class itself as argument.
 *   ... Something.Collect(ToArray)
 *   ```
 */
class Collector {
    /**
     * Initializes static collectors.
     */
    static __New() {
        for Name in Array("Supplier", "Accumulator", "Finisher") {
            if (!HasProp(this, Name)) {
                return
            }
            PropDesc := this.GetOwnPropDesc(Name)
            PropDesc.Get := GetterOf(this, this.%Name%)
            this.DefineProp(Name, PropDesc)
        }

        static GetterOf(this, f) => ((_) => ObjBindMethod(f,, this))
    }

    /**
     * Creates a new collector from the given supplier, accumulator and
     * finisher functions.
     * 
     * @param   {Func?}  Supplier     initializes data
     * @param   {Func?}  Accumulator  accumulates input elements
     * @param   {Func?}  Finisher     creates final result from collected values
     * @returns {Collector}
     */
    __New(Supplier?, Accumulator?, Finisher?) {
        Define("Supplier",    Supplier?)
        Define("Accumulator", Accumulator?)
        Define("Finisher",    Finisher?)

        Define(Name, Function?) {
            if (IsSet(Function)) {
                GetMethod(Function)
                this.DefineProp(Name, {
                    Get:  (Instance)        => Function,
                    Call: (Instance, Args*) => Function(Args*)
                })
                return
            }
            if (!HasProp(this, Name)) {
                throw UnsetError("Missing function:" . Name)
            }
            this.DefineProp(Name, { Get: GetterOf(this, this.%Name%) })
        }

        static GetterOf(this, f) => ((_) => ObjBindMethod(f,, this))
    }

    /**
     * Transforms each element before applying the next collector stage.
     * 
     * @example
     * ; [2, 4, 6, ..., 200]
     * Range(100).Collect(C.Map(TimesTwo, C.ToArray))
     * 
     * @param   {Func}       Mapper  function to transform elements
     * @param   {Collector}  Next    the next collector stage to apply
     * @returns {Collector}
     */
    static Map(Mapper, Next) {
        NextAcc := Next.Accumulator
        return this(Next.Supplier, Acc, Next.Finisher)
        
        Acc(Obj, Val?) {
            NextAcc(Obj, Mapper(Val?))
        }
    }

    /**
     * Transforms and flattens resulting arrays into separate elements before
     * applying the next collector stage.
     * 
     * @example
     * ; ["H", "e", "l", "l", "o"]
     * Array("Hello").Collect(C.FlatMap(StrSplit, C.ToArray))
     * 
     * @param   {Func}       Mapper  function to transform and flatten elements
     * @param   {Collector}  Next    the next collector stage to apply
     * @returns {Collector}
     */
    static FlatMap(Mapper, Next) {
        NextAcc := Next.Accumulator
        return this(Next.Supplier, FlatMapper, Next.Finisher)

        FlatMapper(Obj, Val?) {
            Result := Mapper(Val?)
            if (Result is Array) {
                for Value in Result {
                    NextAcc(Obj, Value)
                }
            } else {
                NextAcc(Obj, Result)
            }
        }
    }

    /**
     * Filters elements for the given `Condition` before applying the next
     * collector stage.
     * 
     * @example
     * ; [1, 2, 3, 4]
     * Range(10).Collect(C.RetainIf(LessThan5, C.ToArray))
     * 
     * @param   {Func}       Condition  function to filter elements with
     * @param   {Collector}  Next       the next collector stage to apply
     * @returns {Collector}
     */
    static RetainIf(Condition, Next) {
        NextAcc := Next.Accumulator
        return this(Next.Supplier, Acc, Next.Finisher)
        
        Acc(Obj, Val?) => (Condition(Val?) && NextAcc(Obj, Val?) && 0)
    }

    /**
     * Removes elements that satisfy the given `Condition` before applying the
     * next collector stage.
     * 
     * @example
     * ; [1, 2, 3, 4]
     * Range(10).Collect(C.RemoveIf(LessThan5, C.ToArray))
     * 
     * @param   {Func}       Condition  function to filter elements with
     * @param   {Collector}  Next       the next collector stage to apply
     * @returns {Collector}
     */
    static RemoveIf(Condition, Next) {
        NextAcc := Next.Accumulator
        return this(Next.Supplier, Acc, Next.Finisher)

        Acc(Obj, Val?) => (Condition(Val?) || (NextAcc(Obj, Val?)) && 0)
    }

    /**
     * Specifies a `Finisher` function to be called as last collector stage.
     * 
     * @example
     * ; "1, 2, 3, 4, 5"
     * Range(5).Collect(C.ToArray.AndThen(  (Arr) => Arr.Join(", ")  ))
     * 
     * @param   {Func}  Finisher  the function to be called
     * @returns {Collector}
     */
    AndThen(Finisher) {
        thisFin := this.Finisher
        return Collector(
            this.Supplier,
            this.Accumulator,
            (Obj) => Finisher(thisFin(Obj)))
    }

    /**
     * Collects all elements into an array.
     * 
     * @example
     * ; ["H", "e", ..., "d", "!"]
     * "Hello, world!".Collect(C.ToArray)
     * 
     * ; [72, 101, ..., 100, 33]
     * "Hello, world!".Collect(C.ToArray(Ord))
     * 
     * @param   {Func?}  Mapper  retrieves the value to be pushed to the array
     * @returns {Collector}
     */
    class ToArray extends Collector {
        static Supplier()             => Array()
        static Accumulator(Arr, Val?) => Arr.Push(Val?)
        static Finisher(Arr)          => Arr

        __New(Mapper) {
            super.__New()
            GetMethod(Mapper)
            this.DefineProp("Mapper", { Get: (_) => Mapper })
        }

        Supplier()             => Array()
        Accumulator(Arr, Val?) => Arr.Push((this.Mapper)(Val?))
        Finisher(Arr)          => Arr
    }

    /**
     * Counts elements by frequency using a Map and an optional `Classifier`
     * function.
     * 
     * @example
     * ; Map { "H": 1, "e": 1, "l": 3, ... }
     * "Hello, world!".Collect(C.Frequency)
     * 
     * ; Map { 72: 1, 101: 1, 108: 3, ... }
     * "Hello, world!".Collect(C.Frequency(Ord))
     * 
     * ; Map { "a": 34, "b": ... }
     * FileRead("foo.txt").StrSplit(" ").Collect(
     *     C.Frequency(
     *         Word => SubStr(Word, 1, 1), ; classify by first letter
     *         false))                     ; case-insensitive
     * 
     * @param   {Func?}                  Classifier  retrieves unique map keys
     * @param   {Map?/Func?/Primitive?}  MapParam    internal map options
     * @returns {Collector}
     */
    class Frequency extends Collector {
        static Supplier() => Map()

        static Accumulator(M, Val) {
            M[Val] := M.Get(Val, 0) + 1
        }

        static Finisher(M) => M

        __New(Classifier, MapParam := Map()) {
            super.__New()
            GetMethod(Classifier)

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

            this.DefineProp("Cache",      { Get: (_) => Cache      })
            this.DefineProp("Classifier", { Get: (_) => Classifier })
        }

        Supplier() => (this.Cache).Clone()

        Accumulator(M, Args*) {
            Key := (this.Classifier)(Args*)
            M[Key] := M.Get(Key, 0) + 1
        }

        Finisher(M) => M
    }

    /**
     * Counts all input elements. Unset values are still counted as elements.
     * 
     * @example
     * Range(4).Collect(C.Count) ; 4
     * 
     * @returns {Collector}
     */
    class Count extends Collector {
        static Supplier()             => &(x := 0)
        static Accumulator(&x, Args*) => ++x
        static Finisher(&x)           => x
    }

    /**
     * Concatenates elements into a string, separated with the given delimiter,
     * with the specified prefix and suffix.
     * 
     * @example
     * Range(5).Collect(C.Join)                 ; "12345"
     * Range(5).Collect(C.Join(", "))           ; "1, 2, 3, 4, 5"
     * Range(5).Collect(C.Join(", ", "[", "]")) ; "[1, 2, 3, 4, 5]"
     * 
     * @param   {String?}  Delimiter  the delimiter used between elements
     * @param   {String?}  Prefix     string at the beginning of the result
     * @param   {String?}  Suffix     string at the end of the result
     */
    class Join extends Collector {
        static Supplier() => &(Str := "")

        static Accumulator(&Str, Val?) {
            Str .= String(Val ?? "")
        }

        static Finisher(&Str) => Str

        __New(Delim, Prefix := "", Suffix := "") {
            super.__New()
            Delim  .= ""
            Prefix .= ""
            Suffix .= ""

            this.DefineProp("Delim",  { Get: (Instance) => Delim  })
            this.DefineProp("Prefix", { Get: (Instance) => Prefix })
            this.DefineProp("Suffix", { Get: (Instance) => Suffix })
        }

        Supplier() => &(Str := "")

        Accumulator(&Str, Val?) {
            if (IsSet(Val)) {
                Str .= String(Val)
                Str .= this.Delim
            }
        }

        Finisher(&Str) => (this.Delim == "")
            ? this.Prefix . Str . this.Suffix
            : this.Prefix . SubStr(Str, 1, -StrLen(this.Delim)) . this.Suffix
    }

    /**
     * Collects the lowest ordered element using numerical comparison, or with
     * the specified `Comparator` function.
     * @see {Comparator}
     * 
     * @example
     * Range(5, 10).Collect(C.Min) ; 5
     * 
     * ; "a"
     * FileRead("foo.txt").StrSplit(" ").Collect(C.Min(StrCompare))
     * 
     * @param   {Func?}  Comparator  function that orders two elements
     * @returns {Collector}
     */
    class Min extends Collector {
        static Supplier() => &x

        static Accumulator(&x, Val?) {
            if (!IsSet(Val) || !IsNumber(Val)) {
                return
            }
            if (!IsSet(x) || (Val < x)) {
                x := Val
            }
        }

        static Finisher(&x) => x

        __New(Comparator) {
            super.__New()
            GetMethod(Comparator)
            this.DefineProp("Comparator", { Get: (_) => Comparator })
        }

        Supplier() => &x

        Accumulator(&x, Val?) {
            Comp := (this.Comparator)
            if (!IsSet(x) || Comp(x, Val?) > 0) {
                x := Val
            }
        }

        Finisher(&x) => x
    }

    /**
     * Collects the highest ordered element using numerical comparison, or with
     * the specified `Comparator` function.
     * @see {Comparator}
     * 
     * @example
     * Range(5, 10).Collect(C.Max) ; 10
     * 
     * ; "zoo"
     * FileRead("foo.txt").StrSplit(" ").Collect(C.Max(StrCompare))
     * 
     * @param   {Func?}  Comparator  function that orders two elements
     * @returns {Collector}
     */
    class Max extends Collector {
        static Supplier() => &x

        static Accumulator(&x, Val?) {
            if (!IsSet(Val) || !IsNumber(Val)) {
                return
            }
            if (!IsSet(x) || (Val > x)) {
                x := Val
            }
        }

        static Finisher(&x) => x

        __New(Comparator) {
            super.__New()
            GetMethod(Comparator)
            this.DefineProp("Comparator", { Get: (_) => Comparator })
        }

        Supplier() => &x

        Accumulator(&x, Val?) {
            Comp := (this.Comparator)
            if (!IsSet(x) || Comp(x, Val?) < 0) {
                x := Val
            }
        }

        Finisher(&x) => x
    }

    /**
     * Sums all input elements, first applying the given `Mapper` function to
     * retrieve numeric values, if specified.
     * 
     * @example
     * Range(5).Collect(C.Sum) ; 15
     * 
     * ; 45
     * Array({ x: 10 }, { x: 15 }, { x: 20 }).Collect(C.Sum(
     *     Obj => Obj.x
     * ))
     * 
     * @param   {Func?}  Mapper  function to retrieve numeric values
     * @returns {Comparator}
     */
    class Sum extends Collector {
        static Supplier()                => &(x := 0)
        static Accumulator(&x, Num := 0) => (IsNumber(Num) && (x += Num))
        static Finisher(&x)              => x

        __New(Mapper) {
            super.__New()
            GetMethod(Mapper)
            this.DefineProp("Mapper", { Get: (Instance) => Mapper })
        }

        Supplier()            => &(x := 0)
        Accumulator(&x, Num?) => (x += (this.Mapper)(Num?))
        Finisher(&x)          => x
    }

    /**
     * Returns the arithmetic mean of all elements, first applying the given
     * `Mapper` function to retrieve numeric values, if specified.
     * 
     * @example
     * Range(5).Collect(C.Average) ; 3.0
     * 
     * ; 15.0
     * Array({ x: 10 }, { x: 15 }, { x: 20 }).Collect(C.Sum(Obj => Obj.x))
     * 
     * @param   {Func?}  Mapper  function to retrieve numeric values
     * @returns {Collector}
     */
    class Average extends Collector {
        static Supplier() => Array(Float(0), 0)

        static Accumulator(Arr, Val?) {
            if (IsSet(Val) && IsNumber(Val)) {
                Arr[1] += Val
                Arr[2]++
            }
        }

        static Finisher(Arr) => Float(Arr[2] && (Arr[1] / Arr[2]))

        Sum   := Float(0)
        Count := 0

        __New(Mapper) {
            super.__New()
            GetMethod(Mapper)
            this.DefineProp("Mapper", { Get: (Instance) => Mapper })
        }

        Supplier() {
        }

        Accumulator(_, Val?) {
            (++this.Count && (this.Sum += (this.Mapper)(Val?)))
        }

        Finisher(_) => Float(this.Count && (this.Sum / this.Count))
    }

    /**
     * Combines each input element by applying the given `Merger` function.
     * - `Identity` specifies an initial value, if present.
     * - If no value is present, an error is thrown.
     * 
     * @example
     * ; 15
     * Range(5).Collect(C.Reduce(  (a, b) => (a + b)  , 0))
     * 
     * @param   {Func?}  Merger    function two merger two values
     * @param   {Any?}   Identity  initial starting value
     * @returns {Collector}
     */
    static Reduce(Merger?, Identity?) {
        return this(Sup, Acc, Fin)

        Sup() {
            x := Identity ?? unset
            return &x
        }
        
        Acc(&x, Val?) {
            x := (IsSet(x)) ? Merger(x, Val?)
                            : (Val ?? unset)
        }

        Fin(&x) => x
    }

    /**
     * Groups each input element into a map, grouped by the key returned by
     * the given `Classifier` function, before applying the next collector
     * stage.
     * 
     * @example
     * ; Map { "f": ["four"], "s": ["score", "seven"], "a": ["and", "ago"] }
     * StrSplit("four score and seven years ago", " ")
     *     .Collect(C.Group(
     *         Word => SubStr(Word, 1, 1), ; classify by first letter
     *         Collector.ToArray,          ; group elements into arrays
     *         false))                     ; case-insensitive
     * 
     * @param   {Func}                  Classifier  classifies elements
     * @param   {Collector?}            Next        next collector stage
     * @param   {Map?/Func?/Primitive}  MapParam    internal map options
     */
    static Group(Classifier, Next := Collector.ToArray, MapParam := Map()) {
        NextSup := Next.Supplier
        NextAcc := Next.Accumulator
        NextFin := Next.Finisher
        
        switch {
            case (MapParam is Map):
                Sup := Replicate(MapParam)
            case (HasMethod(MapParam)):
                Sup := MapFactory(MapParam)
            default:
                Cache := Map()
                Cache.CaseSense := MapParam
                Sup := Replicate(Cache)
        }
        return this(Sup, Acc, Fin)

        Acc(M, Val?) {
            Key := Classifier(Val?)
            (M.Has(Key) || (M[Key] := NextSup()))
            NextAcc(M[Key], Val?)
        }

        Fin(M) {
            for Key, Value in M {
                M[Key] := NextFin(Value)
            }
            return M
        }

        static Replicate(MapObj) => () => MapObj.Clone()
        static MapFactory(Supplier) {
            return Factory

            Factory() {
                M := Supplier()
                if (M is Map) {
                    return M
                }
                throw TypeError("Expected a Map",, Type(M))
            }
        }
    }

    /**
     * Partitions each input element into a map with entries `true` and `false`,
     * determined by whether the element satisfies the given `Condition`,
     * before applying the next collector stage.
     * 
     * @example
     * ; Map { true: [2, 4, 6, 8, 10], false: [1, 3, 5, 7, 9] }
     * Range(10).Collect(C.Partition(IsEven))
     * 
     * @param   {Func}        Condition  the given condition to partition with
     * @param   {Collector?}  Next       next collector stage to apply
     * @returns {Collector}
     */
    static Partition(Condition, Next := Collector.ToArray) {
        NextSup := Next.Supplier
        NextAcc := Next.Accumulator
        NextFin := Next.Finisher
        return this(Sup, Acc, Fin)
        
        Sup() => Map(true, NextSup(), false, NextSup())

        Acc(M, Val?) {
            NextAcc(M[!!Condition(Val?)], Val?)
        }

        Fin(M) => Map(true, NextFin(M[true]), false, NextFin(M[false]))
    }

    /**
     * Gathers all input elements into a map by applying the key and value
     * mapping functions to each element. If no mappers are provided,
     * the first parameter is used as key and the second as value.
     * 
     * - This collector must be used inside of a stream with at least 2
     *   parameters, if the mappers aren't explicitly specified.
     * 
     * @example
     * ; Map { 1: "foo", 2: "bar"}
     * Array("foo", "bar").Stream().Collect(C.ToMap)
     * 
     * ; Map { "Apple": 1, "Banana": 2, "Kiwi": 3 }
     * Array("Apple", "Banana", "Kiwi").Stream(2).Collect(C.ToMap(
     *     (Index, Value, *) => Value,  ; use the word as key
     *     (Index, Value, *) => Index)) ; use its index as value
     * 
     * @param   {Func?}                  KeyMapper    returns map key
     * @param   {Func?}                  ValueMapper  returns value
     * @param   {Map?/Func?/Primitive?}  MapParam     internal map options
     * @returns {Collector}
     */
    class ToMap extends Collector {
        static Supplier()                  => Map()
        static Accumulator(M, Key, Val, *) => (M.Set(Key, Val) && 0)
        static Finisher(M)                 => M

        __New(KeyMapper   := ((k, *) => k),
              ValueMapper := ((k, v, *) => v),
              Merger      := ((l, r) => r),
              MapParam    := Map())
        {
            GetMethod(KeyMapper)
            GetMethod(ValueMapper)
            GetMethod(Merger)

            switch {
                case (MapParam is Map):
                    Sup := Replicate(MapParam)
                case (HasMethod(MapParam)):
                    Sup := MapFactory(MapParam)
                default:
                    Cache := Map()
                    Cache.CaseSense := MapParam
                    Sup := Replicate(Cache)
            }

            return super.__New(Sup, Acc, Fin)

            Acc(M, Args*) {
                Key   := KeyMapper(Args*)
                Value := ValueMapper(Args*)
                if (M.Has(Key)) {
                    M[Key] := Merger(M[Key], Value)
                } else {
                    M[Key] := Value
                }
            }

            Fin(M) => M

            static Replicate(MapObj) => () => MapObj.Clone()

            static MapFactory(Supplier) {
                return Factory

                Factory() {
                    M := Supplier()
                    if (M is Map) {
                        return M
                    }
                    throw TypeError("Expected a Map",, Type(M))
                }
            }
        }
    }

    /**
     * Merges two separate collectors with the given `Merger` function.
     * 
     * @example
     * DisplayResult(Sum, Average) {
     *     ...
     * }
     * Array(1, 2, 3, 4, 5).Collect(C.Sum, C.Average, DisplayResult)
     * 
     * @param   {Collector}  Left    first collector
     * @param   {Collector}  Right   second collector
     * @param   {Func}       Merger  merging function
     * @returns {Collector}
     */
    static Tee(Left, Right, Merger) {
        LeftSup  := Left.Supplier
        RightSup := Right.Supplier
        LeftAcc  := Left.Accumulator
        RightAcc := Right.Accumulator
        LeftFin  := Left.Finisher
        RightFin := Right.Finisher

        LeftObj  := unset
        RightObj := unset
        return this(Sup, Acc, Fin)

        Sup() {
            LeftObj  := LeftSup()
            RightObj := RightSup()
        }

        Acc(_, Val) {
            LeftAcc(LeftObj, Val)
            RightAcc(RightObj, Val)
        }

        Fin(_) => Merger(LeftFin(LeftObj), RightFin(RightObj))
    }
}

class AquaHotkey_Collector extends AquaHotkey {
    class Any {
        /**
         * Collects all elements through `.__Enum(1)`, passing them to the
         * given {@link Colletor} to produce a final result.
         * 
         * @example
         * C := Collector
         * 
         * ; "foo, bar, baz"
         * Array("foo", "bar", "baz").Collect(C.Join(", "))
         */
        Collect(Coll) {
            if (!(Coll is Collector) && !HasBase(Coll, Collector)) {

                throw TypeError("Expected a Collector",, Type(Coll))
            }
            if (!HasProp(this, "__Enum") && !HasProp(this, "Call")) {
                throw TypeError("Not enumerable",, Type(this))
            }
            CollSup := Coll.Supplier
            CollAcc := Coll.Accumulator
            CollFin := Coll.Finisher

            Obj := CollSup()
            for A in this {
                CollAcc(Obj, A?)
            }
            return CollFin(Obj)
        }
    }

    static __New() {
        if (IsSet(AquaHotkey_Stream) && (AquaHotkey_Stream is Class)) {
            return super.__New()
        }
        OutputDebug("[Aqua] Collector.ahk: support for stream disabled.")
        this.DeleteProp("Stream")
        Collector.DeleteProp("ToMap")
    }

    class Stream {
        /**
         * This method is an extension to {@link Stream#Collect} with custom
         * logic for {@link Collector} objects.
         * 
         * @example
         * C := Collector
         * 
         * ; "1, 2, 3, 4"
         * Array(1, 2, 3, 4).Stream().Collect(C.Join(", "))
         * 
         * @param   {Collector}  Coll  the collector to apply
         * @returns {Any}
         */
        Collect(Coll) {
            if (!(Coll is Collector) && !HasBase(Coll, Collector)) {
                GetMethod(Coll)
                return Coll(this*)
            }
            CollSup := Coll.Supplier
            CollAcc := Coll.Accumulator
            CollFin := Coll.Finisher

            Obj := CollSup()
            for A in this {
                CollAcc(Obj, A?)
            }
            return CollFin(Obj)
        }
    }

    class DoubleStream {
        /**
         * This method is an extension to {@link Stream#Collect} with custom
         * logic for {@link Collector} objects.
         * 
         * @example
         * C := Collector
         * 
         * ; Map { 1: 2, 3: 4 }
         * Array(1, 2, 3, 4).DoubleStream().Collect(C.ToMap)
         * 
         * @param   {Collector}  Coll  the collector to apply
         * @returns {Any}
         */
        Collect(Coll) {
            if (!(Coll is Collector) && !HasBase(Coll, Collector)) {
                GetMethod(Coll)
                return Coll(this*)
            }
            CollSup := Coll.Supplier
            CollAcc := Coll.Accumulator
            CollFin := Coll.Finisher

            Obj := CollSup()
            for A, B in this {
                CollAcc(Obj, A?, B?)
            }
            return CollFin(Obj)
        }
    }
}