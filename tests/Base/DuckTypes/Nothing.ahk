class Test_Nothing extends TestSuite {
    static NothingCannotBeSubclassed() {
        this.AssertThrows(() => { base: Nothing }.__New())
    }

    static UnsetIsInstanceOfNothing() {
        Nothing.IsInstance(unset).Assert(Eq(true))
        Nothing.IsInstance(42).Assert(Eq(false))
    }

    static NothingAndUnsetAreSubtypes() {
        Nothing.CanCastFrom(Nothing).Assert(Eq(true))
        Nothing.CanCastFrom(unset).Assert(Eq(true))
        Nothing.CanCastFrom(Integer).Assert(Eq(false))
    }

    static CastFromJsonConvertsToUnset() {
        Val := "null".ParseJson()
        Nothing.CastFromJson(&Val)

        IsSet(Val).Assert(Eq(false))
    }

    static CastFromJsonThrowsOnNonNull() {
        this.AssertThrows(() => "42".ParseJson(Nothing))
    }
}