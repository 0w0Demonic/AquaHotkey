class Test_ImmutableMap extends TestSuite {
    static Freeze_works_on_any_IMap() {
        S := HashSet(1, 2, 3, 4).Freeze()
    }

    static ImmutableMap_throws_on_changes() {
        S := HashSet(1, 2, 3, 4).Freeze()

        ; ... good enough
        this.AssertThrows(() => S.Pop())
        this.AssertThrows(() => S[2] := 2343)
    }

    static ImmutableMap_Call_uses_normal_Map() {
        ImmutableMap(1, 2, 3, 4).Is(Map).Assert(Eq(true))
    }
}