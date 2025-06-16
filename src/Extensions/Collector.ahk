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
 * Range(1000).Collect(_.Map(TimesTwo, _.Partition(GreaterThan500)))
 * ```
 * 
 * ---
 * 
 * **How They Work**:
 * 
 * The `.Supplier()`, `.Accumulator()` and `.Finisher()` methods
 * determine how to initialize data, collect new elements, and how to
 * generate a final result.
 * 
 * ---
 * 
 * **How to Implement**:
 * 
 * - `.Supplier()`:
 *   - The supplier initializes an object which to store the result in.
 * 
 *   ```ahk
 *   Sup() {
 *       return Array()
 *   }
 *   ```
 * 
 * - `.Accumulator(Obj, Val?)`:
 *   - Determines how to collect the input elements.
 * 
 *   ```ahk
 *   Acc(Arr, Val?) {
 *       Arr.Push(Val?)
 *   }
 *   ```
 * 
 * - `.Finisher(Obj)`:
 *   - Creates a final result from the object which was used to store
 *     elements.
 */
class Collector {
    /**
     * Class init. This is used for collectors using static methods.
     * 
     * @example
     * class ToArray extends Collector {
     *     static Supplier() => Array()
     *     static Accumulator(Arr, Val?) => Arr.Push(Val?)
     *     static Finisher(Arr) => Arr
     * }
     */
    static __New() {
        for Name in Array("Supplier", "Accumulator", "Finisher") {
            if (!HasProp(this, Name)) {
                return
            }
            PropDesc := this.GetOwnPropDesc(Name)
            PropDesc.Get := GetterOf(this, PropDesc.Call)
            this.DefineProp(Name, PropDesc)
        }

        static GetterOf(this, f) => ((_) => ObjBindMethod(f,, this))
    }

    /**
     * 
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
            PropDesc := this.GetOwnPropDesc(Name)
            PropDesc.Get := GetterOf(this, PropDesc.Call)
            this.DefineProp(Name, PropDesc)
        }

        static GetterOf(this, f) => ((_) => ObjBindMethod(f,, this))
    }

    /** Collects items into an array. */
    static ToArray => this(Array, Array.Prototype.Push, a => a)

    ; TODO just use Group(Classifier, Collector.Count)
    /**
     * 
     */
    static Frequency => this(
        Map,
        (MapObj, Val) => (MapObj[Val] := MapObj.Get(Val, 0) + 1),
        (MapObj) => MapObj)

    /** Counts the number of input elements. */
    static Count => this(
        ()     => 0,
        (x, *) => (x + 1),
        (x)    => x)

    /**
     * Concatenates input elmeents into a String.
     * 
     */
    static Join => this.Join()

    /**
     * Concatenates input elements into a String, separated by the given
     * delimiter.
     * 
     */
    static Join(Delim := "") {
        return this(Sup, Acc, Fin)

        Sup() {
            return { Val: "" }
        }
        Acc(Obj, Val?) {
            if (IsSet(Val)) {
                Obj.Val .= String(Val)
                Obj.Val .= Delim
            }
        }
        Fin(Obj) {
            if (Delim == "") {
                return Obj.Val
            }
            return SubStr(Obj.Val, 1, -StrLen(Delim))
        }
    }

    /**
     * Transforms each element before applying the next collector stage.
     * 
     * 
     */
    static Map(Mapper, Next) {
        CollAcc := Next.Accumulator
        return this(Next.Supplier, Acc, Next.Finisher)
        
        Acc(Obj, Val?) {
            CollAcc(Obj, Mapper(Val?))
        }
    }

    /**
     * Transforms and flattens resulting arrays into separate elements before
     * applying the next collector stage.
     * 
     */
    static FlatMap(Mapper, Coll) {
        CollAcc := Coll.Accumulator
        return this(Coll.Supplier, FlatMapper, Coll.Finisher)

        FlatMapper(Obj, Val?) {
            Result := Mapper(Val?)
            if (Result is Array) {
                for Value in Result {
                    CollAcc(Obj, Value)
                }
            } else {
                CollAcc(Obj, Result)
            }
        }
    }

    /**
     * Filters elements for the given `Condition` before applying the next
     * collector stage.
     */
    static RetainIf(Condition, Coll) {
        CollAcc := Coll.Acc
        return this(Coll.Supplier, Acc, Coll.Finisher)
        
        Acc(Obj, Val?) {
            if (Condition(Val?)) {
                CollAcc(Obj, Val?)
            }
        }
    }

    /**
     * Removes elements that satisfy the given `Condition` before applying the
     * next collector stage.
     */
    static RemoveIf(Condition, Coll) {
        CollAcc := Coll.Acc
        return this(Coll.Supplier, Acc, Coll.Finisher)

        Acc(Obj, Val?) {
            if (!Condition(Val?)) {
                CollAcc(Obj, Val?)
            }
        }
    }

    /**
     * 
     */
    AndThen(Finisher) {
        thisFin := this.Finisher
        return Collector(
            this.Supplier,
            this.Accumulator,
            (Obj) => Finisher(thisFin(Obj)))
    }

    /**
     * 
     */
    static Min(Comp := (a, b) => (a > b) - (b > a)) {
        if (!HasMethod(Comp)) {
            throw TypeError("Expected a comparator function",, Type(Comp))
        }
        return this(Object, Acc, Fin)
        
        Acc(Obj, Val) {
            if (!ObjHasOwnProp(Obj, "Val") || (Comp(Val, Obj.Val) < 0)) {
                Obj.Val:= Val
            }
        }
        Fin(Obj) {
            if (ObjHasOwnProp(Obj, "Val")) {
                return Obj.Val
            }
            throw UnsetError("No value present")
        }
    }

    static Max(Comp := (a, b) => (a > b) - (b > a)) {
        if (!HasMethod(Comp)) {
            throw TypeError("Expected a comparator function",, Type(Comp))
        }
        return this(Object, Acc, Fin)

        Acc(Obj, Val) {
            if (!ObjHasOwnProp(Obj, "Val") || (Comp(Val, Obj.Val) > 0)) {
                Obj.Val:= Val
            }
        }
        Fin(Obj) {
            if (ObjHasOwnProp(Obj, "Val")) {
                return Obj.Val
            }
            throw UnsetError("No value present")
        }
    }

    /** Collects the sum of all numbers.  */
    static Sum => this.Sum()

    static Sum(Mapper?) {
        if (IsSet(Mapper) && !HasMethod(Mapper)) {
            throw TypeError("Expected a Func object",, Type(Mapper))
        }
        return this(
            () => { Val: 0 },
            IsSet(Mapper) ? (Obj, Val) => (Obj.Val += Mapper(Val))
                          : (Obj, Val) => (Obj.Val += Val),
            (Obj) => Obj.Val)
    }

    static Average => this.Average()

    static Average(Mapper?) {
        if (IsSet(Mapper) && !HasMethod(Mapper)) {
            throw TypeError("Expected a Func object",, Type(Mapper))
        }
        Num := 0
        Count := 0
        return this(
            () => { Val: 0.0 },
            IsSet(Mapper) ? (Obj, Val) => (++Count && (Obj.Val += Mapper(Val)))
                          : (Obj, Val) => (++Count && (Obj.Val += Val)),
            (Obj) => Float(Count && (Obj.Val / Count)))
    }

    static Reduce(Combiner?, Identity?) {
        Nothing := Object()
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
                ? Combiner(Obj.Val, Val)
                : Obj.Val := Val
        }

        Fin(Obj) {
            if (ObjHasOwnProp(Obj, "Val")) {
                return Obj.Val
            }
            throw UnsetError("No values present.")
        }
    }

    static Group(Classifier, Coll := Collector.ToArray, CaseSense := true) {
        CollSup := Coll.Supplier
        CollAcc := Coll.Accumulator
        CollFin := Coll.Finisher
        return this(Sup, Acc, Fin)

        Sup() {
            M := Map()
            M.CaseSense := CaseSense
            return M
        }

        Acc(M, Val?) {
            Key := Classifier(Val?)
            if (!M.Has(Key)) {
                M[Key] := CollSup()
            }
            CollAcc(M[Key], Val?)
        }

        Fin(M) {
            for Key, Value in M {
                M[Key] := CollFin(Value)
            }
            return M
        }
    }

    static Partition(Condition, Coll := Collector.ToArray, CaseSense := true) {
        CollSup := Coll.Supplier
        CollAcc := Coll.Accumulator
        CollFin := Coll.Finisher
        return this(Sup, Acc, Fin)
        
        Sup() {
            M := Map()
            M.CaseSense := CaseSense
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

    static ToMap => this.ToMap()

    static ToMap(KeyMapper   := ((k, *) => k),
                 ValueMapper := ((k, v, *) => v),
                 CaseSense   := true)
    {
        return this(Sup, Acc, Fin)

        Sup() {
            M := Map()
            M.CaseSense := CaseSense
            return M
        }

        Acc(M, Args*) {
            M.Set(KeyMapper(Args*), ValueMapper(Args*))
        }

        Fin(M) => M
    }

    /**
     * Merges two separate collectors with the given `Merger` function.
     * 
     * @example
     * Array(1, 2, 3, 4, 5).Collect(
     *         Collector.Sum,
     *         Collector.Average,
     *         (Sum, Avg) => Format("Sum: {}, Average: {}"))
     */
    static Tee(Coll1, Coll2, Merger) {
        Sup1 := Coll1.Supplier
        Sup2 := Coll2.Supplier
        Acc1 := Coll1.Accumulator
        Acc2 := Coll2.Accumulator
        Fin1 := Coll1.Finisher
        Fin2 := Coll2.Finisher

        Obj1 := unset
        Obj2 := unset
        return this(Sup, Acc, Fin)

        Sup() {
            Obj1 := Sup1()
            Obj2 := Sup2()
        }
        Acc(_, Val) {
            Acc1(Obj1, Val)
            Acc2(Obj2, Val)
        }
        Fin(_) {
            return Merger(Fin1(Obj1), Fin2(Obj2))
        }
    }

}

class AquaHotkey_Collector extends AquaHotkey {
    class Any {
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
        if (!IsSet(AquaHotkey_Stream)) {
            this.DeleteProp("Stream")
        }
        super.__New()
    }

    class Stream {
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