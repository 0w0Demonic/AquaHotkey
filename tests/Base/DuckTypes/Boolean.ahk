class Test_Boolean extends TestSuite {
    static Ints_0_1_Are_Booleans() {
        (1).Is(Boolean).Assert(Eq(true))
        (0).Is(Boolean).Assert(Eq(true))
    }

    static Booleans_Are_Booleans() {
        (true).Is(Boolean).Assert(Eq(true))
        (false).Is(Boolean).Assert(Eq(true))
    }

    static Non_Boolean_Int_Is_Not_A_Boolean() {
        (2).Is(Boolean).Assert(Eq(false))
        (-1).Is(Boolean).Assert(Eq(False))
    }

    static Numeric_String_Is_Never_A_Boolean() {
        "1".Is(Boolean).Assert(Eq(false))
        "0".Is(Boolean).Assert(Eq(false))
    }

    static Floats_Are_Never_Booleans() {
        (1.0).Is(Boolean).Assert(Eq(false))
        (0.0).Is(Boolean).Assert(Eq(false))
    }

    static True_Is_Greater_Than_False() {
        Boolean.Compare(true, false).Assert(Eq(1))
    }

    static Boolean_Natural_Ordering() {
        Boolean.Compare(false, false).Assert(Eq(0))
        Boolean.Compare(true, true).Assert(Eq(0))

        Boolean.Compare(true, false).Assert(Eq(1))
        Boolean.Compare(false, true).Assert(Eq(-1))
    }

    static Boolean_Compare_Throws_On_Bad_Input() {
        this.AssertThrows(() => Boolean.Compare(2, false))
    }

    static CastFromJson_ConvertsToAHKBoolean() {
        "true".ParseJson(Boolean).Assert(Eq(true))
        "false".ParseJson(Boolean).Assert(Eq(false))
    }

    static CastFromJson_ThrowsOnBadInput() {
        this.AssertThrows(() => "{}".ParseJson(Boolean))
        this.AssertThrows(() => "[]".ParseJson(Boolean))
        this.AssertThrows(() => "null".ParseJson(Boolean))
        this.AssertThrows(() => "1".ParseJson(Boolean))
        this.AssertThrows(() => "1.0".ParseJson(Boolean))
    }
}