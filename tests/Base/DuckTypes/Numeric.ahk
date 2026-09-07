class Test_Numeric extends TestSuite {
    static NumericStringIsInstance() {
        Assert("-1.000000".Is(Numeric))
    }

    static Subtypes() {
        Assert(Numeric.CanCastFrom(Number))
        Assert(Numeric.CanCastFrom({ base: Numeric })) ; <-- subclass
    }
    
    static CanSubclass() {
        Cls := { base: Numeric }
        Cls.__Init()
        if (HasProp(Cls, "__New")) {
            Cls.__New()
        }
    }

    static Compare() {
        Assert(Numeric.Compare("1.0", "0.123") > 0)
    }
}