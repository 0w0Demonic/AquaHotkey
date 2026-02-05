class Test_Gatherer extends TestSuite {
    static TimesTwo() {
        Array(1, 2, 3, 4, 5)
                .Stream()
                .Gather(TimesTwo)
                .Join()
                .Assert(Eq("1122334455"))
    }

    static WindowFixed() {
        Range(100).Stream()
                  .Gather(WindowFixed(2))
                  .Map(String)
                  .JoinLine()
    }

    static WindowSliding() {
        Range(8).Stream()
                .Gather(WindowSliding(6))
                .Map(Array.Prototype.Join)
                .Join(", ")
                .Assert(Eq("123456, 234567, 345678"))
    }

    static Scan() {
        Range(4).Gather(Scan("", (a, b) => (a . b)))
                .Join(", ")
                .Assert(Eq("1, 12, 123, 1234"))
    }
}

TimesTwo(Upstream, Downstream) {
    if (!Upstream(&Value)) {
        return false
    }
    Downstream(Value?, Value?)
    return true
}