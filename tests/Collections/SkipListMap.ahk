#Include "%A_LineFile%\..\..\..\src\Collections\SkipListMap.ahk"

class Test_SkipListMap extends TestSuite {
    static simple_construction() {
        SL := SkipListMap(1, 2, 3, 4)
    }

    static size_is_correct_after_construction() {
        SkipListMap(1, 2, 3, 4).Size.AssertEquals(2)
    }
    
    static count_returns_size() {
        SkipListMap(1, 2, 3, 4).Count.AssertEquals(2)
    }

    static __delete_is_unneeded() {
        Count := 0
        ({}.DefineProp)(SkipListMap.Node.Prototype, "__Delete", {
            Call: (Instance) => ++Count
        })

        SL := SkipListMap(1, 2, 3, 4)
        SL := ""

        ({}.DeleteProp)(SkipListMap.Node.Prototype, "__Delete")
        Count.AssertEquals(3) ; including `Head`, which doesn't contain anything
    }

    static clear() {
        SL := SkipListMap(1, 2, 3, 4, 5, 6)
        SL.Clear()
        SL.Size.AssertEquals(0)
    }

    static throws_when_initialized_twice() {
        SL := SkipListMap()

        this.AssertThrows(() => SL.__New())
    }

    static Has() {
        SL := SkipListMap(1, 2, 3, 4)
        SL.Has(1).AssertEquals(true)

        SL.Has(2, &Out).AssertEquals(false)
        IsSet(Out).AssertEquals(false)

        SL.Has(3, &Out).AssertEquals(true)

        Out.AssertEquals(4)
    }

    static Set_should_replace_value() {
        SL := SkipListMap(1, 2, 3, 4)
        Ret := SL.Set(1, 1)
        
        Ret.AssertEquals(false)

        SL.Size.AssertEquals(2)
        SL.Get(1).AssertEquals(1)
    }

    static Set_should_add_value() {
        SL := SkipListMap(1, 2, 3, 4)
        Ret := SL.Set(5, 6)
        Ret.AssertEquals(true)

        SL.Size.AssertEquals(3)
        SL.Get(5).AssertEquals(6)
    }

    static Get_should_return_normally() {
        SL := SkipListMap(1, 2, 3, 4).Get(1).AssertEquals(2)
    }

    static Get_should_return_def_param() {
        SL := SkipListMap().Get(23, "no value").AssertEquals("no value")
    }

    static Get_should_return_def_prop() {
        SL := SkipListMap()
        SL.Default := "no value"
        SL.Get(0).AssertEquals("no value")
    }

    static Get_should_throw() {
        this.AssertThrows(() => SkipListMap().Get(0))
    }

    static Delete_does_nothing() {
        SL := SkipListMap(1, 2, 3, 4)
        Ret := SL.Delete(0, &Out)
        Ret.AssertEquals(false)

        SL.Size.AssertEquals(2)
        IsSet(Out).AssertEquals(false)
    }

    static Delete_removes_value() {
        SL := SkipListMap(1, 2, 3, 4)
        Ret := SL.Delete(1, &Out)
        Ret.AssertEquals(true)

        SL.Size.AssertEquals(1)
        Out.AssertEquals(2)
    }

    static __Enum_size_1() {
        SL := SkipListMap(1, 2, 3, 4)
        Keys := 0
        for Key in SL {
            Keys += Key
        }
        Keys.AssertEquals(4)
    }

    static __Enum_size_2() {
        SL := SkipListMap(1, 2, 3, 4)
        Values := 0
        for Key, Value in SL {
            Values += Value
        }
        Values.AssertEquals(6)
    }

    static Clear_removes_everything() {
        SL := SkipListMap(1, 2, 3, 4)
        SL.Clear()

        SL.Size.AssertEquals(0)
    }

    static __Item_prop() {
        SL := SkipListMap()
        SL[1] := 2
        SL[3] := 4

        SL.Size.AssertEquals(2)

        SL[1].AssertEquals(2)
        SL[3].AssertEquals(4)
    }

    static should_be_instance_of_IMap() {
        if (!(SkipListMap() is IMap)) {
            throw TypeError()
        }
    }

    static Keys() {
        Arr := SkipListMap(1, 2, 3, 4).Keys().AssertType(Array)
        Arr[1].AssertEquals(1)
        Arr[2].AssertEquals(3)
    }

    static Values() {
        Arr := SkipListMap(1, 2, 3, 4).Values().AssertType(Array)
        Arr[1].AssertEquals(2)
        Arr[2].AssertEquals(4)
    }

    static PutIfAbsent() {
        SL := SkipListMap()
        SL.PutIfAbsent(1, 2)
        SL.Size.AssertEquals(1)

        SL.PutIfAbsent(1, 5)
        SL.Size.AssertEquals(1)
        SL.Get(1).AssertEquals(2)
    }

    static ComputeIfAbsent() {
        TimesTwo(x) => (x * 2)

        SL := SkipListMap()
        SL.ComputeIfAbsent(2, TimesTwo)
        SL.Size.AssertEquals(1)

        SL.Get(2).AssertEquals(4)
    }

    static ComputeIfPresent() {
        SL := SkipListMap(1, 1)

        SL.ComputeIfPresent(34, (a, b) => "foo")
        SL.Size.AssertEquals(1)

        SL.ComputeIfPresent(1, (k, v) => 2)
        SL.Get(1).AssertEquals(2)
    }

    static Merge() {
        Sum(A, B) => (A + B)

        SL := SkipListMap(1, 2)
        SL.Merge(1, 5, Sum)

        SL.Size.AssertEquals(1)
        SL.Get(1).AssertEquals(7)
    }
}
