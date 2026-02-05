class Test_Optional extends TestSuite {
    static Empty() {
        Optional.Empty().HasProp("Value").Assert(Eq(false))
    }

    static Get() {
        Optional(42).Get().Assert(Eq(42))
    }

    static IsPresent() {
        Optional(42).IsPresent.Assert(Eq(true))
        Optional(unset).IsPresent.Assert(Eq(false))
    }

    static IsAbsent() {
        Optional(42).IsAbsent.Assert(Eq(false))
        Optional(unset).IsAbsent.Assert(Eq(true))
    }

    static IfPresent() {
        static OutputVar := unset
        Optional(42).IfPresent(x => OutputVar := x)

        IsSet(OutputVar).Assert(Eq(true))
    }

    static IfAbsent() {
        static OutputVar := unset
        
        Optional(unset).IfAbsent(() => OutputVar := true)
        IsSet(OutputVar).Assert(Eq(true))
    }

    static RetainIf() {
        Optional("foo").RetainIf(InStr, "f").IsPresent.Assert(Eq(true))
    }

    static RemoveIf() {
        Optional("foo").RemoveIf(InStr, "f").IsPresent.Assert(Eq(false))
    }

    static Map() {
        Optional(4).Map(x => x * 2).Get().Assert(Eq(8))

        Optional(unset).Map(x => x * 2).IsAbsent.Assert(Eq(true))
    }

    static OrElse() {
        Optional("foo").OrElse("bar").Assert(Eq("foo"))

        Optional(unset).OrElse(42).Assert(Eq(42))
    }

    static OrElseGet() {
        Optional("foo").OrElseGet(() => "bar").Assert(Eq("foo"))

        Optional(unset).OrElseGet(() => "bar").Assert(Eq("bar"))
    }
}