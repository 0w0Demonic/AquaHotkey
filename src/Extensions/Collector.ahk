/**
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
 * Range(1000).Collect(_.Map(TimesTwo, _.Partition(LessThan500)))
 * ```
 * 
 * ---
 * 
 * **How They Work**:
 * 
 * - `.Supplier()`: initializes an object to store the result in.
 * 
 *   ```ahk
 *   Supplier() => Array()
 *   ```
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
     * @return  {Collector}
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
     * Range(100).Collect(_.Map(TimesTwo, _.ToArray))
     * 
     * @param   {Func}       Mapper  function to transform elements
     * @param   {Collector}  Next    the next collector stage to apply
     * @return  {Collector}
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
     * Array("Hello").Collect(_.FlatMap(StrSplit, _.ToArray))
     * 
     * @param   {Func}       Mapper  function to transform and flatten elements
     * @param   {Collector}  Next    the next collector stage to apply
     * @return  {Collector}
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
     * Range(10).Collect(_.RetainIf(LessThan5, _.ToArray))
     * 
     * @param   {Func}       Condition  function to filter elements with
     * @param   {Collector}  Next       the next collector stage to apply
     * @return  {Collector}
     */
    static RetainIf(Condition, Next) {
        NextAcc := Next.Accumulator
        return this(Next.Supplier, Acc, Next.Finisher)
        
        Acc(Obj, Val?) {
            if (Condition(Val?)) {
                NextAcc(Obj, Val?)
            }
        }
    }

    /**
     * Removes elements that satisfy the given `Condition` before applying the
     * next collector stage.
     * 
     * @example
     * ; [1, 2, 3, 4]
     * Range(10).Collect(_.RemoveIf(LessThan5, _.ToArray))
     * 
     * @param   {Func}       Condition  function to filter elements with
     * @param   {Collector}  Next       the next collector stage to apply
     * @return  {Collector}
     */
    static RemoveIf(Condition, Next) {
        NextAcc := Next.Accumulator
        return this(Next.Supplier, Acc, Next.Finisher)

        Acc(Obj, Val?) {
            if (!Condition(Val?)) {
                NextAcc(Obj, Val?)
            }
        }
    }

    /**
     * Specifies a `Finisher` function to be called as last collector stage.
     * 
     * @example
     * ; "1, 2, 3, 4, 5"
     * Range(5).Collect(C.ToArray.AndThen(  (Arr) => Arr.Join(", ")  ))
     * 
     * @param   {Func}  Finisher  the function to be called
     * @return  {Collector}
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
     * @example
     * 
     * ; ["H", "e", ..., "d", "!"]
     * "Hello, world!".Collect(_.ToArray)
     * 
     * @return  {Collector}
     */
    class ToArray extends Collector {
        static Supplier() {
            return Array()
        }

        static Accumulator(Arr, Val?) {
            Arr.Push(Val?)
        }

        static Finisher(Arr) {
            return Arr
        }
    }

    /**
     * Counts elements by frequency using a Map and an optional `Classifier`
     * function.
     * 
     * @example
     * ; Map { "H": 1, "e": 1, "l": 3, ... }
     * "Hello, world!".Collect(_.Frequency)
     * 
     * ; Map { 72: 1, 101: 1, 108: 3, ... }
     * "Hello, world!".Collect(_.Frequency(Ord))
     * 
     * ; Map { "a": 34, "b": ... }
     * FileRead("foo.txt").StrSplit(" ").Collect(
     *     _.Frequency(
     *         Word => SubStr(Word, 1, 1), ; classify by first letter
     *         false))                     ; case-insensitive
     * 
     * @param   {Func?}       Classifier  function to retrieve unique map keys
     * @param   {Primitive?}  CaseSense   case sensitivity of the map object
     * @return  {Collector}
     */
    class Frequency extends Collector {
        static Supplier() {
            return Map()
        }

        static Accumulator(MapObj, Val) {
            MapObj[Val] := MapObj.Get(Val, 0) + 1
        }

        static Finisher(MapObj) {
            return MapObj
        }

        __New(Classifier, CaseSense := true) {
            super.__New()

            MapObj := Map()
            MapObj.CaseSense := CaseSense
            this.DefineProp("MapObj",     { Get: (_) => MapObj     })

            GetMethod(Classifier)
            this.DefineProp("Classifier", { Get: (_) => Classifier })
        }

        Supplier() {
            
        }

        Accumulator(_, Args*) {
            Key := (this.Classifier)(Args*)
            this.MapObj[Key] := this.MapObj.Get(Key, 0) + 1
        }

        Finisher(_) {
            return this.MapObj
        }
    }

    /**
     * Counts all input elements. Unset values are still counted as elements.
     * 
     * @example
     * Range(4).Collect(_.Count) ; 4
     * 
     * @return  {Collector}
     */
    class Count extends Collector {
        static Supplier() {
            return { Val: 0 }
        }

        static Accumulator(Obj, Val?) {
            Obj.Val++
        }

        static Finisher(Obj) {
            return Obj.Val
        }
    }

    /**
     * Concatenates elements into a string, separated with the given delimiter,
     * with the specified prefix and suffix.
     * 
     * @example
     * Range(5).Collect(_.Join)                 ; "12345"
     * Range(5).Collect(_.Join(", "))           ; "1, 2, 3, 4, 5"
     * Range(5).Collect(_.Join(", ", "[", "]")) ; "[1, 2, 3, 4, 5]"
     * 
     * @param   {String?}  Delimiter  the delimiter used between elements
     * @param   {String?}  Prefix     string at the beginning of the result
     * @param   {String?}  Suffix     string at the end of the result
     */
    class Join extends Collector {
        static Supplier() {
            return { Val: "" }
        }

        static Accumulator(Obj, Val?) {
            if (IsSet(Val)) {
                Obj.Val .= String(Val)
            }
        }

        static Finisher(Obj) {
            return Obj.Val
        }

        __New(Delimiter, Prefix := "", Suffix := "") {
            super.__New()
            Delimiter .= ""
            Prefix    .= ""
            Suffix    .= ""

            this.DefineProp("Delimiter", { Get: (Instance) => Delimiter })
            this.DefineProp("Prefix",    { Get: (Instance) => Prefix    })
            this.DefineProp("Suffix",    { Get: (Instance) => Suffix    })
        }

        Supplier() {
            return { Val: "" }
        }

        Accumulator(Obj, Val?) {
            if (IsSet(Val)) {
                Obj.Val .= String(Val)
                Obj.Val .= this.Delimiter
            }
        }

        Finisher(Obj) {
            if (this.Delimiter == "") {
                return this.Prefix
                     . Obj.Val
                     . this.Suffix
            }
            return this.Prefix
                 . SubStr(Obj.Val, 1, -StrLen(this.Delimiter))
                 . this.Suffix
        }
    }

    /**
     * Collects the lowest ordered element using numerical comparison, or with
     * the specified `Comparator` function.
     * @see {Comparator}
     * 
     * @example
     * Range(5, 10).Collect(_.Min) ; 5
     * 
     * ; "a"
     * FileRead("foo.txt").StrSplit(" ").Collect(_.Min(StrCompare))
     * 
     * @param   {Func?}  Comparator  function that orders two elements
     * @return  {Collector}
     */
    class Min extends Collector {
        static Supplier() {
            return Object()
        }

        static Accumulator(Obj, Val?) {
            if (!IsSet(Val) || !IsNumber(Val)) {
                return
            }
            if (!ObjHasOwnProp(Obj, "Val") || (Val < Obj.Val)) {
                Obj.Val := Val
            }
        }

        static Finisher(Obj) {
            if (ObjHasOwnProp(Obj, "Val")) {
                return Obj.Val
            }
            throw UnsetError("No value present")
        }

        __New(Comparator) {
            super.__New()
            GetMethod(Comparator)
            this.DefineProp("Comparator", { Get: (_) => Comparator })
        }

        Supplier() {
            return Object()
        }

        Accumulator(Obj, Val) {
            Comp := (this.Comparator)
            if (!ObjHasOwnProp(Obj, "Val") || Comp(Val, Obj.Val) < 0) {
                Obj.Val := Val
            }
        }

        Finisher(Obj) {
            if (ObjHasOwnProp(Obj, "Val")) {
                return Obj.Val
            }
            throw UnsetError("No value present")
        }
    }

    /**
     * Collects the highest ordered element using numerical comparison, or with
     * the specified `Comparator` function.
     * @see {Comparator}
     * 
     * @example
     * Range(5, 10).Collect(_.Max) ; 10
     * 
     * ; "zoo"
     * FileRead("foo.txt").StrSplit(" ").Collect(_.Max(StrCompare))
     * 
     * @param   {Func?}  Comparator  function that orders two elements
     * @return  {Collector}
     */
    class Max extends Collector {
        static Supplier() {
            return Object()
        }

        static Accumulator(Obj, Val?) {
            if (!IsSet(Val) || !IsNumber(Val)) {
                return
            }
            if (!ObjHasOwnProp(Obj, "Val") || (Val > Obj.Val)) {
                Obj.Val := Val
            }
        }

        static Finisher(Obj) {
            if (ObjHasOwnProp(Obj, "Val")) {
                return Obj.Val
            }
            throw UnsetError("No value present")
        }

        __New(Comparator) {
            super.__New()
            GetMethod(Comparator)
            this.DefineProp("Comparator", { Get: (_) => Comparator })
        }

        Supplier() {
            return Object()
        }

        Accumulator(Obj, Val) {
            Comp := (this.Comparator)
            if (!ObjHasOwnProp(Obj, "Val") || Comp(Val, Obj.Val) > 0) {
                Obj.Val := Val
            }
        }

        Finisher(Obj) {
            if (ObjHasOwnProp(Obj, "Val")) {
                return Obj.Val
            }
            throw UnsetError("No value present")
        }
    }

    /**
     * Sums all input elements, first applying the given `Mapper` function to
     * retrieve numeric values, if specified.
     * 
     * @example
     * Range(5).Collect(_.Sum) ; 15
     * 
     * ; 45
     * Array({ x: 10 }, { x: 15 }, { x: 20 }).Collect(_.Sum(
     *     Obj => Obj.x
     * ))
     * 
     * @param   {Func?}  Mapper  function to retrieve numeric values
     * @return  {Comparator}
     */
    class Sum extends Collector {
        static Supplier() {
            return { Val: 0 }
        }

        static Accumulator(Obj, Num?) {
            if (IsSet(Num) && IsNumber(Num)) {
                Obj.Val += Num
            }
        }

        static Finisher(Obj) {
            return Obj.Val
        }

        __New(Mapper) {
            super.__New()
            if (!HasMethod(Mapper)) {
                throw TypeError("Expected Func object",, Type(Mapper))
            }
            this.DefineProp("Mapper", { Get: (Instance) => Mapper })
        }

        Supplier() {
            return { Val: 0 }
        }

        Accumulator(Obj, Num?) {
            Obj.Val += (this.Mapper)(Num?)
        }

        Finisher(Obj) {
            return Obj.Val
        }
    }

    /**
     * Returns the arithmetic mean of all elements, first applying the given
     * `Mapper` function to retrieve numeric values, if specified.
     * 
     * @example
     * Range(5).Collect(_.Average) ; 3.0
     * 
     * ; 15.0
     * Array({ x: 10 }, { x: 15 }, { x: 20 }).Collect(_.Sum(
     *     Obj => Obj.x
     * ))
     * 
     * @param   {Func?}  Mapper  function to retrieve numeric values
     * @return  {Collector}
     */
    class Average extends Collector {
        static Supplier() {
            return { Sum: Float(0), Count: 0 }
        }

        static Accumulator(Obj, Val?) {
            if (IsSet(Val) && IsNumber(Val)) {
                Obj.Sum += Val
                Obj.Count++
            }
        }

        static Finisher(Obj) {
            if (Obj.Count) {
                return (Obj.Sum / Obj.Count)
            }
            return Float(0)
        }

        Sum   := Float(0)
        Count := 0

        __New(Mapper) {
            super.__New()
            if (!HasMethod(Mapper)) {
                throw TypeError("Expected a Func object",, Type(Mapper))
            }
            this.DefineProp("Mapper", { Get: (Instance) => Mapper })
        }

        Supplier() {

        }

        Accumulator(_, Val?) {
            this.Sum += (this.Mapper)(Val?)
            ++this.Count
        }

        Finisher(_) {
            if (this.Count) {
                return (this.Sum / this.Count)
            }
            return Float(0)
        }
    }

    /**
     * Combines each input element by applying the given `Merger` function.
     * - `Identity` specifies an initial value, if present.
     * - If no value is present, an error is thrown.
     * 
     * @example
     * ; 15
     * Range(5).Collect(_.Reduce(  (a, b) => (a + b)  , 0))
     * 
     * @param   {Func?}  Merger    
     * @param   {Any?}   Identity  
     * @return  {Collector}
     */
    static Reduce(Merger?, Identity?) {
        return this(Sup, Acc, Fin)

        Sup() {
            Obj := Object()
            if (IsSet(Identity)) {
                Obj.Val := Identity
            }
            return Obj
        }
        
        Acc(Obj, Val?) {
            Obj.Val := ObjHasOwnProp(Obj, "Val")
                ? Merger(Obj.Val, Val)
                : Obj.Val := Val
        }

        Fin(Obj) {
            if (ObjHasOwnProp(Obj, "Val")) {
                return Obj.Val
            }
            throw UnsetError("No values present.")
        }
    }

    /**
     * Groups each input element into a map, grouped by the key returned by
     * the given `Classifier` function, before applying the next collector
     * stage.
     * 
     * @example
     * ; Map { "f": ["four"], "s": ["score", "seven"], "a": ["and", "ago"] }
     * StrSplit("four score and seven years ago", " ")
     *     .Collect(_.Group(
     *         Word => SubStr(Word, 1, 1), ; classify by first letter
     *         Collector.ToArray,          ; group elements into arrays
     *         false))                     ; case-insensitive
     * 
     * @param   {Func}        Classifier  function to classify elements with
     * @param   {Collector?}  Next        next collector stage to apply
     * @param   {Primitive?}  CaseSense   case-sensitivity of underlying map
     */
    static Group(Classifier, Next := Collector.ToArray, CaseSense := true) {
        NextSup := Next.Supplier
        NextAcc := Next.Accumulator
        NextFin := Next.Finisher
        return this(Sup, Acc, Fin)

        Sup() {
            M := Map()
            M.CaseSense := CaseSense
            return M
        }

        Acc(M, Val?) {
            Key := Classifier(Val?)
            if (!M.Has(Key)) {
                M[Key] := NextSup()
            }
            NextAcc(M[Key], Val?)
        }

        Fin(M) {
            for Key, Value in M {
                M[Key] := NextFin(Value)
            }
            return M
        }
    }

    /**
     * Partitions each input element into a map with entries `true` and `false`,
     * determined by whether the element satisfies the given `Condition`,
     * before applying the next collector stage.
     * 
     * @example
     * ; Map { true: [2, 4, 6, 8, 10], false: [1, 3, 5, 7, 9] }
     * Range(10).Collect(_.Partition(IsEven))
     * 
     * @param   {Func}        Condition  the given condition to partition with
     * @param   {Collector?}  Next       next collector stage to apply
     * @return  {Collector}
     */
    static Partition(Condition, Coll := Collector.ToArray) {
        CollSup := Coll.Supplier
        CollAcc := Coll.Accumulator
        CollFin := Coll.Finisher
        return this(Sup, Acc, Fin)
        
        Sup() {
            M := Map()
            M.Set(true, CollSup(), false, CollSup())
            return M
        }

        Acc(M, Val?) {
            CollAcc(M[!!Condition(Val?)], Val?)
        }

        Fin(M) {
            M[true] := CollFin(M[true])
            M[false] := CollFin(M[false])
            return M
        }
    }

    /**
     * Gathers all input elements into a map by applying the key and value
     * mapping functions to each element. If no mappers are provided,
     * the first parameter is used as key and the second as value.
     * 
     * - This collector must be used inside of a stream with at least 2
     *   parameters, if the mappers aren't explicitly specified.
     * 
     * - The `CaseSense` flag controls case sensitivity.
     * 
     * @example
     * ; Map { 1: "foo", 2: "bar"}
     * Array("foo", "bar").Stream().Collect(_.ToMap)
     * 
     * ; Map { "Apple": 1, "Banana": 2, "Kiwi": 3 }
     * Array("Apple", "Banana", "Kiwi").Stream(2).Collect(_.ToMap(
     *     (Index, Value, *) => Value,  ; use the word as key
     *     (Index, Value, *) => Index)) ; use its index as value
     * 
     * @param   {Func?}       KeyMapper    function that returns map key
     * @param   {Func?}       ValueMapper  function that returns value
     * @param   {Primitive?}  CaseSense    case-sensitivity of underlying map
     * @return  {Collector}
     */
    class ToMap extends Collector {
        static Supplier() {
            return Map()
        }

        static Accumulator(M, Key, Val, *) {
            M.Set(Key, Val)
        }

        static Finisher(M) {
            return M
        }

        __New(KeyMapper   := ((k, *) => k),
              ValueMapper := ((k, v, *) => v),
              Merger      := ((l, r) => r),
              CaseSense   := true)
        {
            GetMethod(KeyMapper)
            GetMethod(ValueMapper)
            GetMethod(Merger)

            M := Map()
            M.CaseSense := CaseSense
            return super.__New(Sup, Acc, Fin)

            Sup() {
                
            }

            Acc(_, Args*) {
                Key   := KeyMapper(Args*)
                Value := ValueMapper(Args*)
                if (M.Has(Key)) {
                    M[Key] := Merger(M[Key], Value)
                } else {
                    M[Key] := Value
                }
            }

            Fin(_) {
                return M
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
     * Array(1, 2, 3, 4, 5).Collect(_.Sum, _.Average, DisplayResult)
     * 
     * @param   {Collector}  Left    first collector
     * @param   {Collector}  Right   second collector
     * @param   {Func}       Merger  merging function
     * @return  {Collector}
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
        Fin(_) {
            return Merger(LeftFin(LeftObj), RightFin(RightObj))
        }
    }
}

class AquaHotkey_Collector extends AquaHotkey {
    class Any {
        /**
         * Applies the provided collector to the input sequence (anything
         * enumerable, such as an Array or Map), which collects elements and
         * processes them into a final result.
         * 
         * Use `Stream.Prototype.Collect(Coll)`, if the sequence carries
         * multiple parameters.
         * @see {Collector}
         * 
         * @example
         * ; "1, 2, 3, 4"
         * Array(1, 2, 3, 4).Collect(_.Join(", "))
         * 
         * @param   {Collector}  Coll  the collector to apply
         * @return  {Any}
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
        ; do not overwrite `Stream`, if it doesn't exist
        if (!IsSet(AquaHotkey_Stream)) {
            this.DeleteProp("Stream")
        }
        super.__New()
    }

    class Stream {
        /**
         * Applies the provided collector to the input sequence (anything
         * enumerable, such as an Array or Map), which collects elements and
         * processes them into a final result.
         * 
         * Use stream to support enumerating multiple parameters at once.
         * @see {Collector}
         * 
         * @example
         * ; Map { 1: "Apple", 2: "Banana", 3: "Kiwi" }
         * Array("Apple", "Banana", "Kiwi").Stream(2).Collect(_.ToMap)
         */
        Collect(Coll) {
            if (!(Coll is Collector) && !HasBase(Coll, Collector)) {
                throw TypeError("Expected a Collector",, Type(Coll))
            }
            CollSup := Coll.Supplier
            CollAcc := Coll.Accumulator
            CollFin := Coll.Finisher

            Obj := CollSup()
            switch (this.MaxParams) {
                case 1:
                    for A in this {
                        CollAcc(Obj, A?)
                    }
                case 2:
                    for A, B in this {
                        CollAcc(Obj, A?, B?)
                    }
                case 3:
                    for A, B, C in this {
                        CollAcc(Obj, A?, B?, C?)
                    }
                case 4:
                    for A, B, C, D in this {
                        CollAcc(Obj, A?, B?, C?, D?)
                    }
                default: throw ValueError("invalid parameter length",
                                          this.MaxParams)
            }
            return CollFin(Obj)
        }
    }
}