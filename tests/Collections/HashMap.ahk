#Include "%A_LineFile%\..\..\..\src\Collections\HashMap.ahk"

class Test_HashMap extends TestSuite {
    static simple_construction() {
        HM := HashMap()
    }

    static cap_is_initial() {
        HM := HashMap()
        HM.Capacity.AssertEquals(HM.InitialCap)
    }

    static size_is_zero() {
        HM := HashMap()
        HM.Size.AssertEquals(0)
        HM.Count.AssertEquals(0)
    }

    static keys_are_equal() {
        Obj1 := { foo: "bar" }
        Obj2 := { FOO: "bar" }

        if (!Obj1.Eq(Obj2)) {
            throw Error()
        }
        if (Obj1.HashCode() != Obj2.HashCode()) {
            throw Error()
        }

        HashMap(Obj1, true, Obj2, true).Size.AssertEquals(1)
    }

    static Clear() {
        Args := Array()
        loop 20 {
            Args.Push(A_Index)
        }
        HM := HashMap(Args*)
        HM.Size.AssertEquals(10)
        HM.Clear()

        HM.Size.AssertEquals(0)
        for Value in HM {
            throw Error()
        }
    }

    static Clone() {
        HM := HashMap(1, 2, 3, 4)
        Copy := HM.Clone()
        Copy.Has(1).AssertEquals(true)
        Copy.Has(3).AssertEquals(true)
    }

    static Delete() {
        HM := HashMap(1, 2, 3, 4)
        HM.Delete(1).AssertEquals(2)

        HM.Size.AssertEquals(1)
    }

    static Get_should_return_normally() {
        HM := HashMap(1, 2, 3, 4)
        HM.Get(1).AssertEquals(2)
    }

    static Get_should_return_def_param() {
        HashMap().Get("unknown", "no value")
            .AssertEquals("no value")
    }

    static Get_should_return_def_prop() {
        HM := HashMap()
        HM.Default := "no value"

        HM.Get("unknown").AssertEquals("no value")
    }

    static Get_should_throw() {
        this.AssertThrows(() => HashMap().Get("unknown"))
    }

    static Has() {
        HashMap({ foo: "bar" }, true).Has({ foo: "bar" })
            .AssertEquals(true)
    }

    static Has_with_output() {
        HashMap(1, 2).Has(1, &OutValue).AssertEquals(true)
        OutValue.AssertEquals(2)
    }

    static Set_assigns_size_correctly() {
        HM := HashMap()
        HM.Set(1, 2)
        HM.Has(1).AssertEquals(true)

        HM.Size.AssertEquals(1)

        HM.Set(1, 2)
        HM.Size.AssertEquals(1)

        HM.Set(3, 4)
        HM.Size.AssertEquals(2)
    }

    static __Enum_shows_all_elements() {
        Keys := 0
        Values := 0
        for Key, Value in HashMap(1, 2, 3, 4) {
            Keys += Key
            Values += Value
        }
        Keys.AssertEquals(4)
        Values.AssertEquals(6)
    }

    static Capacity_set_grows_hashmap() {
        HM := HashMap()
        HM.Capacity := 64
        if (HM.Capacity < 64) {
            throw Error()
        }
    }

}