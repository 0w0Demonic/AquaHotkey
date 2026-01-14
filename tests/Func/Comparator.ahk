class Test_Comparator extends TestSuite {
    static Num() {
        Array(5, 3, 4, 2, 1).Sort(Comparator.Num())
                            .Join(", ").AssertEquals("1, 2, 3, 4, 5")

        Array("90", "869", "i", "Hello").Sort(Comparator.Num(StrLen))
            .Join(", ")
            .AssertEquals("i, 90, 869, Hello")
    }
    
    static Alpha() {
        Array("foo", "bar", "baz").Sort(Comparator.Alpha())
                                  .Join(", ").AssertEquals("bar, baz, foo")
        Array("foo", "FOO").Sort(Comparator.Alpha(true))
                           .Join(", ").AssertEquals("FOO, foo")

        Array("apple", "banana", "kiwi")
            ; sort alphabetically by `SubStr(Str, 2, 1)`
            .Sort(Comparator.Alpha(false, SubStr, 2, 1))
            .Join(", ")
            .AssertEquals("banana, kiwi, apple")
    }

    static Then() {
        IntegersFirst(a, b) {
            a := (a is Float)
            b := (b is Float)
            return (a > b) - (b > a)
        }
        Array(10.0, 10).Sort(Comparator.Num().Then(IntegersFirst))
                       .Join(", ")
                       .AssertEquals("10, 10.0")
    }

    static By1() {
        Array({Value: 1}, {Value: 2}, {Value: -1})
                .Sort(Comparator.Num().By(Obj => Obj.Value))
                .Map(Obj => Obj.Value)
                .Join(", ")
                .AssertEquals("-1, 1, 2")
    }

    static Rev() {
        Array(3, 2, 4, 1).Sort(Comparator.Num().Rev())
            .Join(", ")
            .AssertEquals("4, 3, 2, 1")
    }

    static NullsFirst() {
        Array(2, 4, 1, 3, unset, unset).Sort(Comparator.Num().NullsFirst())
            .ToString()
            .AssertEquals("[unset, unset, 1, 2, 3, 4]")
    }

    static NullsLast() {
        Array(5, 3, 4, unset, unset, 2, 1).Sort(Comparator.Num().NullsLast())
            .ToString()
            .AssertEquals("[1, 2, 3, 4, 5, unset, unset]")
    }

    static Test1() {
        Array("a", "foo", "bar", "hello", unset).Sort(
                Comparator.Num().By(StrLen)
                          .Then(Comparator.Alpha())
                          .NullsFirst())
        .Map((v?) => (v ?? "unset")).Join(", ")
        .AssertEquals("unset, a, bar, foo, hello")
    }
}