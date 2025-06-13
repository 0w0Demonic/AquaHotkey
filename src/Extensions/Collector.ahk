
class Collector {
    __New(Supplier, Accumulator, Finisher) {
        if (!HasMethod(Supplier) || !HasMethod(Accumulator)
                || !HasMethod(Finisher))
        {
            throw TypeError("Expected a Func object")
        }
        this.DefineProp("Supplier",    { Get: (Instance) => Supplier    })
        this.DefineProp("Accumulator", { Get: (Instance) => Accumulator })
        this.DefineProp("Finisher",    { Get: (Instance) => Finisher    })
    }

    static ToArray => this(Array, Array.Prototype.Push, a => a)

    static ToSet => this(
        Map,
        (MapObj, Val) => (MapObj[Val] := true),
        (MapObj) => MapObj)

    static Frequency => this(
        Map,
        (MapObj, Val) => (MapObj[Val] := MapObj.Get(Val, 0) + 1),
        (MapObj) => MapObj)

    static Count => this(
        ()     => 0,
        (x, *) => (x + 1),
        (x)    => x)

    static Join => this.Join()

    static Join(Delim := "") {
        return this(Sup, Acc, Fin)

        Sup() {
            return { Val: "" }
        }
        Acc(Obj, Str?) {
            if (IsSet(Str)) {
                Obj.Val .= Str
                Obj.Val .= Delim
            }
        }
        Fin(Obj) {
            return (Delim == "") ? Obj.Val
                                 : SubStr(Obj.Val, 1, -StrLen(Delim))
        }
    }

    static Map(Mapper, Coll) {
        Acc := Coll.Accumulator
        return this(
            Coll.Supplier,
            (Obj, Val?) => Acc(Obj, Mapper(Val?)),
            Coll.Finisher)
    }

    static FlatMap(Mapper, Coll) {
        CollAcc := Coll.Accumulator
        return this(
            Coll.Supplier,
            FlatMapper,
            Coll.Finisher)

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

    static Filtering(Condition, Coll) {
        CollAcc := Coll.Acc
        return this(
            Coll.Supplier,
            (Obj, Val?) => (Condition(Val?) && CollAcc(Obj, Val?)),
            Coll.Finisher)
    }

    AndThen(Finisher) {
        thisFin := this.Finisher
        return Collector(
            this.Supplier,
            this.Accumulator,
            (Obj) => Finisher(thisFin(Obj)))
    }

    ; TODO
    static MinBy(Comp) {
        if (!HasMethod(Comp)) {
            throw TypeError("Expected a Comparator or Func object",, Type(Comp))
        }
        return this(Object, Acc, Fin)
        
        Acc(Obj, Val) {
            if (!ObjHasOwnProp(Obj, "Value") || (Comp(Val, Obj.Value) < 0)) {
                Obj.Value := Val
            }
        }
        Fin(Obj) {
            if (ObjHasOwnProp(Obj, "Value")) {
                return Obj.Value
            }
            throw UnsetError("No value present")
        }
    }

    static MaxBy(Comp) {
        if (!HasMethod(Comp)) {
            throw TypeError("Expected a Comparator or Func object",, Type(Comp))
        }
        return this(Object, Acc, Fin)

        Acc(Obj, Val) {
            if (!ObjHasOwnProp(Obj, "Value") || (Comp(Val, Obj.Value) > 0)) {
                Obj.Value := Val
            }
        }
        Fin(Obj) {
            if (ObjHasOwnProp(Obj, "Value")) {
                return Obj.Value
            }
            throw UnsetError("No value present")
        }
    }

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

    static Reduce(Arg1, Arg2?, Arg3?) {

    }

    static Group(Arg1, Arg2?, Arg3?) {

    }

    static Partition(Predicate, Downstream?) {

    }

    static ToMap => this.ToMap()

    static ToMap(KeyMapper?, ValueMapper?, Merger?, MapSupplier?) {
        MapSupplier := MapSupplier ?? Map
        ; TODO
        
    }


    static Teeing(Coll1, Coll2, Merger) {
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
        if (!(Coll is Collector)) {
            throw TypeError("Expected a Collector",, Type(Coll))
        }

        Sup := Coll.Supplier
        Acc := Coll.Accumulator
        Fin := Coll.Finisher

        Obj := Sup()
        for A in this {
            Acc(Obj, A)
        }
        return Fin(Obj)
    }
}
}