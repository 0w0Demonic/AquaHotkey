#Include "%A_LineFile%\..\..\..\src\Collections\LinkedList.ahk"

; TODO Indexable tests

class Test_LinkedList extends TestSuite {
    static Slurp() {
        L := LinkedList(1, 2, 3)
        L.Slurp().Join(", ").Assert(Eq("1, 2, 3"))
        L.Size.Assert(Eq(0))
    }

    static Slice() {
        L := LinkedList(1, 2, 3)
        L.Slice(1, 2).Eq([1, 2]).Assert(Eq(true))
    }

    static Swap() {
        L := LinkedList(1, 2, 3)
        L.Swap(1, 2)
        L.Get(1).Assert(Eq(2))
        L.Get(2).Assert(Eq(1))
    }

    static Drain() {
        L := LinkedList(1, 2, 3)
        L.Drain().Join(", ").Assert(Eq("3, 2, 1"))
        L.Size.Assert(Eq(0))
    }

    static Enumerable2_exists() {
        LinkedList(1, 2, 3).Any(x => x > 2)
    }

    static SimpleConstruction() {
        L := LinkedList(1, 2, 3)
    }

    static When_SimpleConstruction_Size_Is_Correct() {
        LinkedList(1, 2, 3).Size.Assert(Eq(3))
    }

    static Simple_Get() {
        LinkedList(1, 2, 3).Get(1).Assert(Eq(1))
    }

    static Get_Supports_Negative_Indexing() {
        LinkedList(1, 2, 3).Get(-2).Assert(Eq(2))
    }

    static Supports_Unset() {
        L := LinkedList(1, unset, 3)
    }

    static Get_Supports_Unset_Parameter() {
        L := LinkedList(1, unset, 3).Get(2, "no value")
            .Assert(Eq("no value"))
    }

    static Get_Supports_Unset_Property() {
        L := LinkedList(1, unset, 3)
        L.Default := "no value"
        L.Get(2).Assert(Eq("no value"))
    }

    static Get_Throws_When_Invalid_Index() {
        L := LinkedList(1, 2, 3)
        this.AssertThrows(() => L.Get(0))
        this.AssertThrows(() => L.Get(76))
    }

    static Get_Throws_When_Unset() {
        this.AssertThrows(() => LinkedList(1, unset, 3).Get(2))
    }

    static Simple_Set() {
        L := LinkedList(1, 2, 3)

        L.Set(1, 2)
        L.Get(1).Assert(Eq(2))
    }

    static Set_Throws_When_Invalid_Index() {
        this.AssertThrows(() => LinkedList(1, 2, 3).Set(4, 4))
    }

    static Simple_Delete() {
        L := LinkedList(1, 2, 3)
        L.Delete(3)
        L.Has(3).Assert(Eq(false))
        L.Size.Assert(Eq(3))
    }

    static Delete_Throws_On_Invalid_Index() {
        this.AssertThrows(() => LinkedList(1, 2, 3).Delete(4))
    }

    static Delete_Removes_Value() {
        L := LinkedList(1, 2, 3)
        L.Delete(2)
        L.Has(2).Assert(Eq(false))
        L.Size.Assert(Eq(3))
    }

    static Simple__Enum() {
        L := LinkedList(4, 6)

        Result := 0
        for Value in L {
            Result += Value
        }
        Result.Assert(Eq(10))

        Result := 0
        for Index, Value in L {
            Result += Index
        }
        Result.Assert(Eq(3))
    }

    static __Item_set_supports_unset() {
        L := LinkedList(1, 2, 3)
        L[2] := unset
        L.Has(2).Assert(Eq(false))
    }

    static Shove() {
        L := LinkedList(2, 3)
        L.Shove(1)
        L.Get(1).Assert(Eq(1))
        L.Get(2).Assert(Eq(2))
        L.Get(3).Assert(Eq(3))

        L.Size.Assert(Eq(3))
    }

    static Shove_On_Empty_List() {
        L := LinkedList()
        L.Shove(1)
        L.Head.Assert(Eq(L.Tail))
        L.Size.Assert(Eq(1))
    }

    static Push() {
        L := LinkedList(1, 2)
        L.Push(3)

        L.Size.Assert(Eq(3))
        L.Get(3).Assert(Eq(3))
    }

    static Push_On_Empty_List() {
        L := LinkedList()
        L.Push(1)
        L.Head.Assert(Eq(L.Tail))
        L.Size.Assert(Eq(1))
    }

    static Poll() {
        L := LinkedList(1, 2)
        L.Poll().Assert(Eq(1))
        L.Size.Assert(Eq(1))
        L.Get(1).Assert(Eq(2))
    }

    static Poll_Uses_Default_Return() {
        L := LinkedList(1, unset)
        L.Poll().Assert(Eq(1))
        L.Size.Assert(Eq(1))

        L.Has(1).Assert(Eq(false))
    }

    static Poll_On_Empty_List() {
        this.AssertThrows(() => LinkedList().Poll())
    }

    static Pop() {
        L := LinkedList(1, 2, 3)
        L.Pop().Assert(Eq(3))
        L.Size.Assert(Eq(2))
        L.Get(2).Assert(Eq(2))
    }

    static Simple_InsertAt() {
        L := LinkedList(2, 3)
        L.InsertAt(1, 1)
        L.Size.Assert(Eq(3))
        L.Get(1).Assert(Eq(1))
    }

    static Simple_InsertAt_With_More_Values() {
        L := LinkedList(3, 4)
        L.InsertAt(1, 1, 2)
        L.Size.Assert(Eq(4))
        L.Get(1).Assert(Eq(1))
        L.Get(2).Assert(Eq(2))
    }

    static InsertAt_Throws() {
        this.AssertThrows(() => LinkedList(1, 2).InsertAt(76, 2))
    }

    static InsertAt_Appends() {
        L := LinkedList(1, 2)
        L.InsertAt(0, 3)

        L.Size.Assert(Eq(3))
        L.Get(3).Assert(Eq(3))

        L.InsertAt(4, 4)
        L.Size.Assert(Eq(4))
        L.Get(4).Assert(Eq(4))
    }

    static Simple_RemoveAt() {
        L := LinkedList(1, 2, 3)

        L.RemoveAt(1).Assert(Eq(1))
        L.Size.Assert(Eq(2))
        L.Get(2).Assert(Eq(3))
    }

    static RemoveAt_Uses_Default_Value() {
        L := LinkedList(unset)
        L.RemoveAt(1).Assert(Eq(""))
    }

    static RemoveAt_Multi() {
        L := LinkedList(1, 2, 3, 4)
        L.RemoveAt(3, 2)
        L.Size.Assert(Eq(2))
        L.Get(1).Assert(Eq(1))
        L.Get(2).Assert(Eq(2))
    }

    static RemoveAt_Throws() {
        this.AssertThrows(() => LinkedList(1, 2, 3).RemoveAt(2, -2))
        this.AssertThrows(() => LinkedList(1, 2, 3).RemoveAt(2, 3))
        this.AssertThrows(() => LinkedList(1, 2, 3).RemoveAt(0))
        this.AssertThrows(() => LinkedList(1, 2, 3).RemoveAt(6))
        this.AssertThrows(() => LinkedList(1, 2, 3).RemoveAt(-6))
    }

    static RemoveAt_Does_Nothing() {
        L := LinkedList(1, 2, 3)
        L.RemoveAt(2, 0)
        L.Size.Assert(Eq(3))
    }

    static __Delete_Works() {
        L := LinkedList(1, 2, 3)

        Value := 0
        ({}.DefineProp)(LinkedList.Node.Prototype, "__Delete", {
            Call: (Instance) => ++Value
        })

        L := ""
        Value.Assert(Eq(3))
    }

    static Sizeable_Properties() {
        L := LinkedList(1, 2, 3)
        L.IsEmpty.Assert(Eq(false))
        L.IsNotEmpty.Assert(Eq(true))
    }

    static ForEach() {
        Arr := Array()
        LinkedList(1, 2, 3).ForEach(x => Arr.Push(x))

        Arr.Eq([1, 2, 3]).Assert(Eq(true))
    }

    static ToArray() {
        LinkedList(1, 2, 3).ToArray().Eq([1, 2, 3]).Assert(Eq(true))
    }

    static Collect() {
        static Sum(Values*) {
            Result := Float(0)
            for Value in Values {
                Result += Value
            }
            return Result
        }

        LinkedList(1, 2, 3).Collect(Sum).Assert(Eq(6))
    }

    static Reduce() {
        static Sum(A, B) => (A + B)

        LinkedList(1, 2, 3).Reduce(Sum).Assert(Eq(6))
    }

    static Find() {
        Equals(x) => (y) => (x == y)

        Out := LinkedList(1, 2, 3).Find(Equals(3))
        Out.Get().Assert(Eq(3))
    }

    static Any() {
        LinkedList(1, 2, 3).Any((x) => (x == 3)).Assert(Eq(true))

        LinkedList(1, 2, 3).Any((x) => (x == 10)).Assert(Eq(false))
    }

    static None() {
        LinkedList(1, 2, 3).None((x) => (x == 7)).Assert(Eq(true))

        LinkedList(1, 2, 3).None((x) => (x == 2)).Assert(Eq(false))
    }

    static All() {
        LinkedList(1, 2, 3).All((x) => (x < 10)).Assert(Eq(true))

        LinkedList(1, 2, 3).All((x) => (x < 1)).Assert(Eq(false))
    }

    static Max() {
        LinkedList(3, 2, 5, 3).Max().Assert(Eq(5))
    }

    static Min() {
        LinkedList(3, 2, 5, 1).Min().Assert(Eq(1))
    }

    static Sum() {
        LinkedList(1, 2, 3, 4).Sum().Assert(Eq(10))
    }

    static Average() {
        LinkedList(1, 2, 3, 4).Average().Assert(Eq(2.5))
    }

    static Join() {
        LinkedList(1, 2, 3).Join(", ").Assert(Eq("1, 2, 3"))
    }

    static Frequency() {
        M := LinkedList(1, 1, 2, 2).Frequency(x => x)

        M[1].Assert(Eq(2))
        M[2].Assert(Eq(2))
    }

    static Count() {
        LinkedList(1, 2, 3).Count().Assert(Eq(3))
    }

    static Group() {
        M := LinkedList(1, 2, 2).Group(x => x)
        M[1].Eq([1]).Assert(Eq(true))
        M[2].Eq([2, 2]).Assert(Eq(true))
    }

    static Partition() {
        M := LinkedList("foo", 123).Partition(IsNumber)

        M[true].Eq([123]).Assert(Eq(true))
        M[false].Eq(["foo"]).Assert(Eq(true))
    }
}