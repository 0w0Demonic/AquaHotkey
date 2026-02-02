#Include <AquaHotkeyX>

class Test_ImmutableSet extends TestSuite {
    static FromSet_works_with_any_ISet() {
        S := ImmutableSet.FromSet(HashSet(1, 2, 3, 4))
    }

    static Call_uses_regular_Set() {
        ImmutableSet({ foo: "bar" }, { foo: "bar" })
            .Size
            .AssertEquals(2)
    }

    static Freeze_works_with_any_ISet() {
        S := HashSet(1, 2, 3, 4).Freeze()
    }
}