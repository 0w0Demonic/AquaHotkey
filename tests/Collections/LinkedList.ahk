#Include "%A_LineFile%\..\..\..\src\Collections\LinkedList2.ahk"

class Test_LinkedList extends TestSuite {
    static SimpleConstruction() {
        L := LinkedList(1, 2, 3)
    }

    static When_SimpleConstruction_Size_Is_Correct() {
        LinkedList(1, 2, 3).Size.AssertEquals(3)
    }

    static Simple_Get() {
        LinkedList(1, 2, 3).Get(1).AssertEquals(1)
    }

    static Get_Supports_Negative_Indexing() {
        LinkedList(1, 2, 3).Get(-2).AssertEquals(2)
    }

    static Supports_Unset() {
        L := LinkedList(1, unset, 3)
    }

    static Get_Supports_Unset_Parameter() {
        L := LinkedList(1, unset, 3).Get(2, "no value")
            .AssertEquals("no value")
    }

    static Get_Supports_Unset_Property() {
        L := LinkedList(1, unset, 3)
        L.Default := "no value"
        L.Get(2).AssertEquals("no value")
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
        L.Get(1).AssertEquals(2)
    }

    static Set_Throws_When_Invalid_Index() {
        this.AssertThrows(() => LinkedList(1, 2, 3).Set(4, 4))
    }

    static Simple_Delete() {
        L := LinkedList(1, 2, 3)
        L.Delete(3)
        L.Has(3).AssertEquals(false)
        L.Size.AssertEquals(3)
    }

    static Delete_Throws_On_Invalid_Index() {
        this.AssertThrows(() => LinkedList(1, 2, 3).Delete(4))
    }

    static Delete_Removes_Value() {
        L := LinkedList(1, 2, 3)
        L.Delete(2)
        L.Has(2).AssertEquals(false)
        L.Size.AssertEquals(3)
    }

    static Simple__Enum() {
        L := LinkedList(4, 6)

        Result := 0
        for Value in L {
            Result += Value
        }
        Result.AssertEquals(10)

        Result := 0
        for Index, Value in L {
            Result += Index
        }
        Result.AssertEquals(3)
    }

    static __Item_set_supports_unset() {
        L := LinkedList(1, 2, 3)
        L[2] := unset
        L.Has(2).AssertEquals(false)
    }

    static Shove() {
        L := LinkedList(2, 3)
        L.Shove(1)
        L.Get(1).AssertEquals(1)
        L.Get(2).AssertEquals(2)
        L.Get(3).AssertEquals(3)

        L.Size.AssertEquals(3)
    }

    static Shove_On_Empty_List() {
        L := LinkedList()
        L.Shove(1)
        L.Head.AssertEquals(L.Tail)
        L.Size.AssertEquals(1)
    }

    static Push() {
        L := LinkedList(1, 2)
        L.Push(3)

        L.Size.AssertEquals(3)
        L.Get(3).AssertEquals(3)
    }

    static Push_On_Empty_List() {
        L := LinkedList()
        L.Push(1)
        L.Head.AssertEquals(L.Tail)
        L.Size.AssertEquals(1)
    }

    static Poll() {
        L := LinkedList(1, 2)
        L.Poll().AssertEquals(1)
        L.Size.AssertEquals(1)
        L.Get(1).AssertEquals(2)
    }

    static Poll_Uses_Default_Return() {
        L := LinkedList(1, unset)
        L.Poll().AssertEquals(1)
        L.Size.AssertEquals(1)

        L.Has(1).AssertEquals(false)
    }

    static Poll_On_Empty_List() {
        this.AssertThrows(() => LinkedList().Poll())
    }

    static Pop() {
        L := LinkedList(1, 2, 3)
        L.Pop().AssertEquals(3)
        L.Size.AssertEquals(2)
        L.Get(2).AssertEquals(2)
    }

    static Simple_InsertAt() {
        L := LinkedList(2, 3)
        L.InsertAt(1, 1)
        L.Size.AssertEquals(3)
        L.Get(1).AssertEquals(1)
    }

    static Simple_InsertAt_With_More_Values() {
        L := LinkedList(3, 4)
        L.InsertAt(1, 1, 2)
        L.Size.AssertEquals(4)
        L.Get(1).AssertEquals(1)
        L.Get(2).AssertEquals(2)
    }

    static InsertAt_Throws() {
        this.AssertThrows(() => LinkedList(1, 2).InsertAt(76, 2))
    }

    static InsertAt_Appends() {
        L := LinkedList(1, 2)
        L.InsertAt(0, 3)

        L.Size.AssertEquals(3)
        L.Get(3).AssertEquals(3)

        L.InsertAt(4, 4)
        L.Size.AssertEquals(4)
        L.Get(4).AssertEquals(4)
    }

    static Simple_RemoveAt() {
        L := LinkedList(1, 2, 3)

        L.RemoveAt(1).AssertEquals(1)
        L.Size.AssertEquals(2)
        L.Get(2).AssertEquals(2)
    }

    static RemoveAt_Uses_Default_Value() {
        L := LinkedList(unset)
        L.RemoveAt(1).AssertEquals("")
    }

    static RemoveAt_Multi() {
        L := LinkedList(1, 2, 3, 4)
        L.RemoveAt(3, 2)
        L.Size.AssertEquals(2)
        L.Get(1).AssertEquals(1)
        L.Get(2).AssertEquals(2)
    }

    static RemoveAt_Throws() {
        this.AssertThrows(() => LinkedList(1, 2, 3).RemoveAt(2, -2))
        this.AssertThrows(() => LinkedList(1, 2, 3).RemoveAt(2, 3))
        this.AssertThrows(() => LinkedList(1, 2, 3).RemoveAt(0))
        this.AssertThrows(() => LinkedList(1, 2, 3).RemoveAt(6))
        this.AssertThrows(() => LinkedList(1, 2, 3).RemoveAt(-6))
    }

    static RemoveAt_Does_Nothing() {
        LinkedList(1, 2, 3).RemoveAt(2, 0).Size.AssertEquals(3)
    }


}
