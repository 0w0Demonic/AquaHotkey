#Include "%A_LineFile%\..\..\..\src\Collections\SkipListMap.ahk"

class Test_SkipListMap extends TestSuite {
    static simple_construction() {
        SL := SkipListMap(1, 2, 3, 4)
    }

    static size_is_correct_after_construction() {
        SkipListMap(1, 2, 3, 4).Size.Assert(Eq(2))
    }
    
    static count_returns_size() {
        SkipListMap(1, 2, 3, 4).Count.Assert(Eq(2))
    }

    static __delete_is_unneeded() {
        Count := 0
        ({}.DefineProp)(SkipListMap.Node.Prototype, "__Delete", {
            Call: (Instance) => ++Count
        })

        SL := SkipListMap(1, 2, 3, 4)
        SL := ""

        ({}.DeleteProp)(SkipListMap.Node.Prototype, "__Delete")
        Count.Assert(Eq(3)) ; including `Head`, which doesn't contain anything
    }

    static clear() {
        SL := SkipListMap(1, 2, 3, 4, 5, 6)
        SL.Clear()
        SL.Size.Assert(Eq(0))
    }

    static throws_when_initialized_twice() {
        SL := SkipListMap()

        this.AssertThrows(() => SL.__New())
    }

    static Has() {
        SL := SkipListMap(1, 2, 3, 4)
        SL.Has(1).Assert(Eq(true))
    }

    static Set_should_replace_value() {
        SL := SkipListMap(1, 2, 3, 4)
        Ret := SL.Set(1, 1)
        
        Ret.Assert(Eq(false))

        SL.Size.Assert(Eq(2))
        SL.Get(1).Assert(Eq(1))
    }

    static Set_should_add_value() {
        SL := SkipListMap(1, 2, 3, 4)
        Ret := SL.Set(5, 6)
        Ret.Assert(Eq(true))

        SL.Size.Assert(Eq(3))
        SL.Get(5).Assert(Eq(6))
    }

    static Get_should_return_normally() {
        SL := SkipListMap(1, 2, 3, 4).Get(1).Assert(Eq(2))
    }

    static Get_should_return_def_param() {
        SL := SkipListMap().Get(23, "no value").Assert(Eq("no value"))
    }

    static Get_should_return_def_prop() {
        SL := SkipListMap()
        SL.Default := "no value"
        SL.Get(0).Assert(Eq("no value"))
    }

    static Get_should_throw() {
        this.AssertThrows(() => SkipListMap().Get(0))
    }

    static Delete_does_nothing() {
        SL := SkipListMap(1, 2, 3, 4)
        this.AssertThrows(() => SL.Delete(0))
    }

    static Delete_removes_value() {
        SL := SkipListMap(1, 2, 3, 4)
        Ret := SL.Delete(1)
        Ret.Assert(Eq(2))
    }

    static __Enum_size_1() {
        SL := SkipListMap(1, 2, 3, 4)
        Keys := 0
        for Key in SL {
            Keys += Key
        }
        Keys.Assert(Eq(4))
    }

    static __Enum_size_2() {
        SL := SkipListMap(1, 2, 3, 4)
        Values := 0
        for Key, Value in SL {
            Values += Value
        }
        Values.Assert(Eq(6))
    }

    static Clear_removes_everything() {
        SL := SkipListMap(1, 2, 3, 4)
        SL.Clear()

        SL.Size.Assert(Eq(0))
    }

    static __Item_prop() {
        SL := SkipListMap()
        SL[1] := 2
        SL[3] := 4

        SL.Size.Assert(Eq(2))

        SL[1].Assert(Eq(2))
        SL[3].Assert(Eq(4))
    }

    static should_be_instance_of_IMap() {
        if (!(SkipListMap() is IMap)) {
            throw TypeError()
        }
    }

    static Keys() {
        Arr := SkipListMap(1, 2, 3, 4).Keys().AssertType(Array)
        Arr[1].Assert(Eq(1))
        Arr[2].Assert(Eq(3))
    }

    static Values() {
        Arr := SkipListMap(1, 2, 3, 4).Values().AssertType(Array)
        Arr[1].Assert(Eq(2))
        Arr[2].Assert(Eq(4))
    }

    static PutIfAbsent() {
        SL := SkipListMap()
        SL.PutIfAbsent(1, 2)
        SL.Size.Assert(Eq(1))

        SL.PutIfAbsent(1, 5)
        SL.Size.Assert(Eq(1))
        SL.Get(1).Assert(Eq(2))
    }

    static ComputeIfAbsent() {
        TimesTwo(x) => (x * 2)
        SL := SkipListMap()
        SL.ComputeIfAbsent(2, TimesTwo)
        SL.Size.Assert(Eq(1))

        SL.Get(2).Assert(Eq(4))
    }

    static ComputeIfPresent() {
        SL := SkipListMap(1, 1)

        SL.ComputeIfPresent(34, (a, b) => "foo")
        SL.Size.Assert(Eq(1))

        SL.ComputeIfPresent(1, (k, v) => 2)
        SL.Get(1).Assert(Eq(2))
    }

    static Merge() {
        Sum(A, B) => (A + B)

        SL := SkipListMap(1, 2)
        SL.Merge(1, 5, Sum)

        SL.Size.Assert(Eq(1))
        SL.Get(1).Assert(Eq(7))
    }
}
