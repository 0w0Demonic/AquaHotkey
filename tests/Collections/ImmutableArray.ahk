#Include <AquaHotkeyX>

class Test_ImmutableArray extends TestSuite {
    static FromArray_works_with_any_IArray() {
        A := ImmutableArray.FromArray(LinkedList(1, 2, 3, 4))
    }

    static Call_uses_regular_array() {
        IA := ImmutableArray(1, 2, 3, 4)
        (IA.A).Is(Array).Assert(Eq(true))
    }

    static Freeze_works_with_any_IArray() {
        L := LinkedList(1, 2, 3, 4).Freeze()
        LinkedList(1, 2, 3, 4).Freeze()
                .Is(ImmutableArray)
                .Assert(Eq(true))
    }
}