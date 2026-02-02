class Test_Collector extends TestSuite {
    static ToArray() {
        Arr := Array(1, 2, 3, 4, 5).ToArray()
        Arr.AssertType(Array)
        Arr.Join().AssertEquals("12345")
    }

    static Join1() {
        Array("H", "e", "l", "l", "o")
            .Join()
            .AssertEquals("Hello")
    }

    static Join2() {
        Array("H", "e", "l", "l", "o")
            .Join(", ")
            .AssertEquals("H, e, l, l, o")
    }

    static Join3() {
        Array("H", "e", "l", "l", "o")
            .Join(", ", "[", "]")
            .AssertEquals("[H, e, l, l, o]")
    }

    static Average1() {
        Array(1, 2, 3, 4, 5)
            .Average()
            .AssertEquals(3.0)
    }

    static Average2() {
        static TimesTwo(x) => (x * 2)
        
        Array(1, 2, 3, 4, 5).Stream().Map(x => x * 2).Average()
                .AssertEquals(6.0)
    }

    static Reduce() {
        static Sum(a, b) => (a + b)

        Array(1, 2, 3, 4, 5).Reduce(Sum).AssertEquals(15)
        Array(1, 2, 3, 4, 5).Reduce(Sum, 5).AssertEquals(20)
    }

    static Count() {
        Array(1, 2, 3, 4).Count().AssertEquals(4)
    }

    static Min1() {
        Range(40).Collect(Min).AssertEquals(1)
    }

    static Max1() {
        Range(40).Collect(Max).AssertEquals(40)
    }

    static Sum1() {
        static Sum(A, B) => (A + B)

        Range(10).Reduce(Sum).AssertEquals(55)
    }

    static Sum2() {
        static Sum(A, B) => (A + B)
        static TimesTwo(x) => (x * 2)

        Range(10).Map(TimesTwo).Reduce(Sum).AssertEquals(110)
    }

    static Map() {
        static TimesTwo(x) => (x * 2)

        Array(1, 2, 3, 4, 5).Stream().Map(TimesTwo).ToArray()
                .Join().AssertEquals("246810")
    }

    static FlatMap() {
        Array("Hello").Stream().FlatMap(Str => StrSplit(Str).Stream())
                .Join().AssertEquals("Hello")
    }

    static RetainIf() {
        Range(10).RetainIf(x => (x < 5)).ToArray().Join(", ")
                .AssertEquals("1, 2, 3, 4")
    }

    static RemoveIf() {
        Range(10).RemoveIf(x => (x < 5))
            .ToArray()
            .Join(", ")
            .AssertEquals("5, 6, 7, 8, 9, 10")
    }

    static Frequency1() {
        "Hello, world!".Stream().Frequency().AssertType(Map)
                .Get("o").AssertEquals(2)
    }

    static Frequency2() {
        "Hello, world!".Stream().Frequency(Ord).AssertType(Map)
                .Get(Ord("o")).AssertEquals(2)
    }

    static Partition() {
        IsEven(x) => !(x & 1)

        M := Array(1, 2, 3, 4, 5).Stream().Partition(IsEven)
        M[true].Join(", ").AssertEquals("2, 4")
        M[false].Join(", ").AssertEquals("1, 3, 5")
    }

    static Group() {
        FirstLetter(Str) {
            return SubStr(Str, 1, 1)
        }
        
        M := StrSplit("Hello world!", " ")
            .Stream()
            .Group(FirstLetter, (Args*) => Args.Stream().Group(StrLen))
        
        M["H"][5][1].AssertEquals("Hello")
        M["w"][6][1].AssertEquals("world!")
    }

    static ToMap1() {
        M := Array("Hello", "world").DoubleStream().ToMap()
        
        M[1].AssertEquals("Hello")
        M[2].AssertEquals("world")
    }
}
