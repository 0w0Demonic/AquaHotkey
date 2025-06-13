class Collector {
    static __New() {
        global C := Collector
    }

    static ToArray() {
        Arr := Array(1, 2, 3, 4, 5).Stream()
                .Collect(C.ToArray)
        
        Arr.AssertType(Array)
        Arr.Join().AssertEquals("12345")
    }

    static Join() {
        Str := Array("H", "e", "l", "l", "o").Stream()
                .Collect(C.Join)
    }

    static Average() {
        Array(1, 2, 3, 4, 5).Stream().Collect(C.Average)
                .AssertEquals(3.0)
    }

    static Tee() {
        Join := C.Join()
        Sum := C.Sum()
        Merger := Format.Bind("{}, {}")

        Array(1, 2, 3, 4, 5).Stream().Collect(C.Teeing(Join, Sum, Merger))
            .AssertEquals("12345, 15")
    }

    static Map() {
        static Coll := C.Map(x => 2 * x, C.ToArray).AndThen(Arr => Arr.Join())

        Array(1, 2, 3, 4, 5).Stream().Collect(Coll).AssertEquals("246810")
    }

    static FlatMap() {
        static Coll := C.FlatMap(StrSplit, C.ToArray)

        Array("Hello").Collect(Coll).Join().AssertEquals("Hello")
    }

    static Misc() {
        ; Map{  : 1, !: 1, ,: 1, H: 1, d: 1, e: 1, l: 3, o: 2, r: 1, w: 1 }
        "Hello, world!".Collect(C.Frequency)
    }
}