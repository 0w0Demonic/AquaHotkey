class Test_Optional extends TestSuite {
    static Empty() {
        Optional.Empty().HasProp("Value").AssertEquals(false)
    }

    static Get() {
        Optional(42).Get().AssertEquals(42)
    }

    static IsPresent() {
        Optional(42).IsPresent.AssertEquals(true)
        Optional(unset).IsPresent.AssertEquals(false)
    }

    static IsAbsent() {
        Optional(42).IsAbsent.AssertEquals(false)
        Optional(unset).IsAbsent.AssertEquals(true)
    }

    static IfPresent() {
        static OutputVar := unset
        Optional(42).IfPresent(x => OutputVar := x)

        IsSet(OutputVar).AssertEquals(true)
    }

    static IfAbsent() {
        static OutputVar := unset
        
        Optional(unset).IfAbsent(() => OutputVar := true)
        IsSet(OutputVar).AssertEquals(true)
    }

    static RetainIf() {
        Optional("foo").RetainIf(InStr, "f").IsPresent.AssertEquals(true)
    }

    static RemoveIf() {
        Optional("foo").RemoveIf(InStr, "f").IsPresent.AssertEquals(false)
    }

    static Map() {
        Optional(4).Map(x => x * 2).Get().AssertEquals(8)

        Optional(unset).Map(x => x * 2).IsAbsent.AssertEquals(true)
    }

    static OrElse() {
        Optional("foo").OrElse("bar").AssertEquals("foo")

        Optional(unset).OrElse(42).AssertEquals(42)
    }

    static OrElseGet() {
        Optional("foo").OrElseGet(() => "bar").AssertEquals("foo")

        Optional(unset).OrElseGet(() => "bar").AssertEquals("bar")
    }
}