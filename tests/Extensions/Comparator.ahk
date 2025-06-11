/**
 * AquaHotkey - Comparator.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Extensions/Comparator.ahk
 */
class Comparator {
    static Numeric() {
        Array(5, 3, 4, 2, 1).Sort(Comparator.Numeric())
                            .Join(", ").AssertEquals("1, 2, 3, 4, 5")

        Array("90", "869", "i", "Hello").Sort(Comparator.Numeric(StrLen))
            .Join(", ")
            .AssertEquals("i, 90, 869, Hello")
    }
    
    static Alphabetic() {
        Array("foo", "bar", "baz").Sort(Comparator.Alphabetic())
                                  .Join(", ").AssertEquals("bar, baz, foo")
        Array("foo", "FOO").Sort(Comparator.Alphabetic(true))
                           .Join(", ").AssertEquals("FOO, foo")

        Array("apple", "banana", "kiwi")
            ; sort alphabetically by `SubStr(Str, 2, 1)`
            .Sort(Comparator.Alphabetic(false, SubStr, 2, 1))
            .Join(", ")
            .AssertEquals("banana, kiwi, apple")
    }

    static AndThen() {
        IntegersFirst(a, b) {
            a := (a is Float)
            b := (b is Float)
            return (a > b) - (b > a)
        }
        Array(10.0, 10).Sort(Comparator.Numeric().AndThen(IntegersFirst))
                       .Join(", ")
                       .AssertEquals("10, 10.0")
    }

    static Compose1() {
        Array({Value: 1}, {Value: 2}, {Value: -1})
                .Sort(Comparator.Numeric().Compose(Obj => Obj.Value))
                .Map(Obj => Obj.Value)
                .Join(", ")
                .AssertEquals("-1, 1, 2")
    }

    static Reversed() {
        Array(3, 2, 4, 1).Sort(Comparator.Numeric().Reversed())
            .Join(", ")
            .AssertEquals("4, 3, 2, 1")
    }

    static NullsFirst() {
        Array(2, 4, 1, 3, unset, unset).Sort(Comparator.Numeric().NullsFirst())
            .ToString()
            .AssertEquals("[unset, unset, 1, 2, 3, 4]")
    }

    static NullsLast() {
        Array(5, 3, 4, unset, unset, 2, 1).Sort(Comparator.Numeric().NullsLast())
            .ToString()
            .AssertEquals("[1, 2, 3, 4, 5, unset, unset]")
    }

    static Test1() {
        Array("a", "foo", "bar", "hello", unset).Sort(
                Comparator.Numeric().Compose(StrLen)
                          .AndThen(Comparator.Alphabetic())
                          .NullsFirst())
        .Map((v?) => (v ?? "unset")).Join(", ")
        .AssertEquals("unset, a, bar, foo, hello")
    }
}