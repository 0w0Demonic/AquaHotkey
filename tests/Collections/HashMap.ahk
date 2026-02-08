#Include "%A_LineFile%\..\..\..\src\Collections\HashMap.ahk"

class Test_HashMap extends TestSuite {
    static simple_construction() {
        HM := HashMap()
    }

    static cap_is_initial() {
        HM := HashMap()
        HM.Capacity.Assert(Eq(HM.InitialCap))
    }

    static size_is_zero() {
        HM := HashMap()
        HM.Size.Assert(Eq(0))
        HM.Count.Assert(Eq(0))
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

        HashMap(Obj1, true, Obj2, true).Size.Assert(Eq(1))
    }

    static Clear() {
        Args := Array()
        loop 20 {
            Args.Push(A_Index)
        }
        HM := HashMap(Args*)
        HM.Size.Assert(Eq(10))
        HM.Clear()

        HM.Size.Assert(Eq(0))
        for Value in HM {
            throw Error()
        }
    }

    static Clone() {
        HM := HashMap(1, 2, 3, 4)
        HM.Has(1).Assert(Eq(true))
        HM.Has(3).Assert(Eq(true))

        Copy := HM.Clone()
        Copy.Has(1).Assert(Eq(true))
        Copy.Has(3).Assert(Eq(true))

    }

    static Delete() {
        HM := HashMap(1, 2, 3, 4)
        HM.Delete(1).Assert(Eq(2))

        HM.Size.Assert(Eq(1))
    }

    static Get_should_return_normally() {
        HM := HashMap(1, 2, 3, 4)
        HM.Get(1).Assert(Eq(2))
    }

    static Get_should_return_def_param() {
        HashMap().Get("unknown", "no value")
            .Assert(Eq("no value"))
    }

    static Get_should_return_def_prop() {
        HM := HashMap()
        HM.Default := "no value"

        HM.Get("unknown").Assert(Eq("no value"))
    }

    static Get_should_throw() {
        this.AssertThrows(() => HashMap().Get("unknown"))
    }

    static Has() {
        HashMap({ foo: "bar" }, true).Has({ foo: "bar" })
            .Assert(Eq(true))
    }

    static Has_with_output() {
        HashMap(1, 2).Has(1, &OutValue).Assert(Eq(true))
        OutValue.Assert(Eq(2))
    }

    static Set_assigns_size_correctly() {
        HM := HashMap()
        HM.Set(1, 2)
        HM.Has(1).Assert(Eq(true))

        HM.Size.Assert(Eq(1))

        HM.Set(1, 2)
        HM.Size.Assert(Eq(1))

        HM.Set(3, 4)
        HM.Size.Assert(Eq(2))
    }

    static __Enum_shows_all_elements() {
        Keys := 0
        Values := 0
        for Key, Value in HashMap(1, 2, 3, 4) {
            Keys += Key
            Values += Value
        }
        Keys.Assert(Eq(4))
        Values.Assert(Eq(6))
    }

    static Capacity_set_grows_hashmap() {
        HM := HashMap()
        HM.Capacity := 64
        if (HM.Capacity < 64) {
            throw Error()
        }
    }

}