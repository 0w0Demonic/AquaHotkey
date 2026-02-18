class Test_Comparable extends TestSuite {
    static Methods_Should_Exist() {
        HasProp(42, "Gt").Assert(Eq(true))
        HasProp(42, "Compare").Assert(Eq(true))
    }

    static basic_number_compare() {
        (42.56).Gt(23.03).Assert(Eq(true))
    }

    static string_compare_is_case_insensitive() {
        "foo".OrdEq("FOO").Assert(Eq(true))
    }

    static string_compare_throws_on_numbers() {
        this.AssertThrows(() => "foo".Compare(76))
    }

    static simple_array_compare() {
        ([1, 2]).OrdEq([1, 2]).Assert(Eq(true))
    }

    static longer_array_is_greater() {
        ([1, 2]).Lt( [1, 2, 3] ).Assert(Eq(true))
    }

    static static_compare_should_exist() {
        (Class.Prototype).Assert(ObjHasOwnProp, "Compare")
    }

    static static_compare_does_type_checking() {
        this.AssertThrows(() => String.Compare(123, "foo"))
    }

    static static_compare_returns_comparator() {
        (String.Compare).AssertType(Comparator)
    }
}