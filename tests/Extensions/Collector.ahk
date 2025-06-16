class Collector {
    static __New() {
        global C := Collector
    }

    static ToArray() {
        Arr := Array(1, 2, 3, 4, 5).Collect(C.ToArray)
        
        Arr.AssertType(Array)
        Arr.Join().AssertEquals("12345")
    }

    static Join() {
        Str := Array("H", "e", "l", "l", "o").Collect(C.Join)
    }

    static Average() {
        Array(1, 2, 3, 4, 5).Collect(C.Average).AssertEquals(3.0)
    }

    static Reduce() {
        Sum(a, b) => (a + b)
        Array(1, 2, 3, 4, 5).Collect(C.Reduce(Sum)).AssertEquals(15)

        Array(1, 2, 3, 4, 5).Collect(C.Reduce(Sum, 5)).AssertEquals(20)
    }

    static Tee() {
        Join := C.Join()
        Sum := C.Sum()
        Merger := Format.Bind("{}, {}")

        Array(1, 2, 3, 4, 5).Collect(C.Tee(Join, Sum, Merger))
            .AssertEquals("12345, 15")
    }

    static Map() {
        static TimesTwo(x) => (x * 2)
        static Coll := C.Map(TimesTwo, C.ToArray)

        Array(1, 2, 3, 4, 5).Collect(Coll)
            .Join().AssertEquals("246810")
    }

    static FlatMap() {
        static Coll := C.FlatMap(StrSplit, C.ToArray)

        Array("Hello").Collect(Coll).Join().AssertEquals("Hello")
    }

    static Frequency() {
        "Hello, world!".Collect(C.Frequency).AssertType(Map)
                .Get("o").AssertEquals(2)
    }

    static Partition() {
        IsEven(x) => !(x & 1)

        M := Array(1, 2, 3, 4, 5).Collect(C.Partition(IsEven))

        M[true].Join(", ").AssertEquals("2, 4")
        M[false].Join(", ").AssertEquals("1, 3, 5")
    }

    static Group() {
        FirstLetter(Str) {
            return SubStr(Str, 1, 1)
        }
        
        M := "Hello world!".StrSplit(" ")
            .Collect(C.Group(FirstLetter, C.Group(StrLen)))
        
        M["H"][5][1].AssertEquals("Hello")
        M["w"][6][1].AssertEquals("world!")
    }
}

