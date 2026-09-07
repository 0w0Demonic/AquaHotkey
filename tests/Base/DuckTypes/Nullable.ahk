class Test_Nullable extends TestSuite {
    static InstancesAreClasses() {
        Nullable(Integer).AssertType(Class)
    }

    static NotSubclassable() {
        this.AssertThrows(() => { base: Nullable }.__New())
    }

    static NullableNullableIsFlattened() {
        N := Nullable(Integer)
        NN := Nullable(N)
        Assert(N == NN)
    }

    static CanAccessInnerType() {
        Nullable(Integer).InnerType.Assert(Eq(Integer))
    }

    static EqualityBetweenNullables() {
        ({ foo: "bar" }).Assert(Eq({ foo: "bar" }))
        N := Nullable({ foo: "bar" })
        N.Assert(Eq(N))

        N.Assert(Eq(Nullable({ foo: "bar" })))
    }

    static NullableEquality() {
        T := Nullable(Integer)
        T.Equals(unset, unset).Assert(Eq(true))
        T.Equals(42, 42).Assert(Eq(true))
        T.Equals(unset, 42).Assert(Eq(false))
        T.Equals(42, unset).Assert(Eq(false))
    }

    static IsHashable() {
        H1 := Nullable(Integer).HashCode()
        H2 := Nullable(Integer).HashCode()

        H1.Assert(Eq(H2))
    }

    static UnsetIsInstanceOfNullable() {
        Nullable(Integer).IsInstance(unset).Assert(Eq(true))
    }

    static InnerTypeMustMatchNullable() {
        (42).Is(Integer).Assert(Eq(true))
        (42).Is(Nullable(Integer)).Assert(Eq(true))
    }

    static NothingAndUnsetAreSubtypes() {
        ; because `unset` is always instance of `Nullable`
        Assert(Nullable.CanCastFrom(Nothing))
        Assert(Nullable.CanCastFrom(unset))
    }

    static NullablesAreSubtypes() {
        Assert(Nullable.CanCastFrom(Nullable))
        Assert(Nullable.CanCastFrom(Nullable(Integer)))
    }

    static SubtypesBetweenNullables() {
        Assert(Nullable(Integer).CanCastFrom(Nothing))
        Assert(Nullable(Integer).CanCastFrom(unset))

        Assert(Nullable(Integer).CanCastFrom(Nullable(Integer)))
        Assert(Nullable(Number).CanCastFrom(Nullable(Integer)))
    }

    static T_IsSubtypeOf_NullableT() {
        ; `unset | Integer` vs `Integer`.
        Assert(Nullable(Integer).CanCastFrom(Integer))
    }

    static CastFromJson_AcceptsNull() {
        Val := "null".ParseJson()
        Nullable(Integer).CastFromJson(&Val)
        Assert(!IsSet(Val))
    }

    static CastFromJson_CastsWithInnerType() {
        "42".ParseJson(Nullable({ CastFromJson: Cast }))
            .Assert(Eq("foo"))

        Cast(_, &Val) {
            Val := "foo"
        }
    }
}