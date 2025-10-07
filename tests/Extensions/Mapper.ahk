/**
 * AquaHotkey - Mapper.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Extensions/Mapper.ahk
 */
class Mapper {
    static Increment() {
        Array(1, 2, 3).Map(  Mapper.Increment  ).Join().AssertEquals("234")
    }

    static Decrement() {
        Array(1, 2, 3).Map(  Mapper.Decrement  ).Join().AssertEquals("012")
    }

    static Prefix() {
        Array(1, 2, 3).Map(  Mapper.Prefix("-")  ).Join().AssertEquals("-1-2-3")
    }

    static Suffix() {
        Array(1, 2, 3).Map(  Mapper.Suffix("-")  ).Join().AssertEquals("1-2-3-")
    }

    static Format() {
        Array(1, 2, 3).Map(  Mapper.Format("[{}]")  ).Join(", ")
                .AssertEquals("[1], [2], [3]")
    }

    static StrReplace() {
        Array("Hello", "world!").Map(  Mapper.StrReplace("l", "x")  )
                .Join(", ").AssertEquals("Hexxo, worxd!")
    }

    static RegExReplace() {
        Array("Hello", "world!").Map(  Mapper.RegExReplace("^.")  )
                .Join(", ").AssertEquals("ello, orld!")
    }

    static Split() {
        Array("Hello", "world!").Map(  Mapper.Split  )
            .Map(Type).Join(", ").AssertEquals("Array, Array")
    }

    static SubStr() {
        Array("Hello", "world!").Map(  Mapper.SubStr(1, 1)  )
            .Join(", ").AssertEquals("H, w")
    }

    static Index() {
        Array([1, 2, 3], [4, 5, 6], [7, 8, 9]).Map(  Mapper.Index(2)  )
            .Join(", ").AssertEquals("2, 5, 8")
    }

    static Arg() {
        Array("foo", "bar").DoubleStream().Map(  Mapper.Arg(1)  )
            .Join(", ").AssertEquals("1, 2")
    }

    static Property() {
        Array({ Val: 15 }, { Val: 16 }, { Val: 17 }).Map(
                Mapper.Property("Val"))
            .Join(", ").AssertEquals("15, 16, 17")
    }

    static Method() {
        Array([1], [2], [3]).Map(  Mapper.Method("Pop")  )
            .Join(", ").AssertEquals("1, 2, 3")
    }

    static Integration1() {
        Array("foo", "bar").DoubleStream().Collect(Collector.ToMap(
                Mapper.Arg(2).AndThen(SubStr, 1, 1),
                Mapper.Arg(2)))
            .DoubleStream()
            .Map(Mapper.Format("{}: {}"))
            .Join(", ")
            .AssertEquals("b: bar, f: foo")
    }

    static IfAbsent() {
        Array("foo", unset).Map(  Mapper.IfAbsent("bar")  )
            .Join(", ")
            .AssertEquals("foo, bar")
    }

    static IfAbsentGet() {
        Array("foo", unset).Map(  Mapper.IfAbsentGet(() => "bar")  )
            .Join(", ")
            .AssertEquals("foo, bar")
    }
}