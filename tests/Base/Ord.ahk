class Test_Ord extends TestSuite {
    static Methods_Should_Exist() {
        HasProp(42, "Gt").AssertEquals(true)
        HasProp(42, "Compare").AssertEquals(true)
    }

    static basic_number_compare() {
        (42.56).Gt(23.03).AssertEquals(true)
    }

    static string_compare_is_case_insensitive() {
        "foo".OrdEq("FOO").AssertEquals(true)
    }

    static string_compare_throws_on_numbers() {
        this.AssertThrows(() => "foo".Compare(76))
    }

    static simple_array_compare() {
        ([1, 2]).OrdEq([1, 2]).AssertEquals(true)
    }

    static longer_array_is_greater() {
        ([1, 2]).Lt( [1, 2, 3] ).AssertEquals(true)
    }

    static static_compare_should_exist() {
        (Class.Prototype).AssertHasOwnProp("Compare")
    }

    static static_compare_does_type_checking() {
        this.AssertThrows(() => String.Compare(123, "foo"))
    }

    static static_compare_returns_comparator() {
        (String.Compare).AssertType(Comparator)
    }
}