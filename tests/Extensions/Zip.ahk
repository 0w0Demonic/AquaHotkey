
class Zip {
    static Constructor() {
        ZipArray(Tuple(1, 2, 3), Tuple(4, 5, 6), Tuple(7, 8, 9))
            .Narrow((Args*) => Args.Join(", "))
            .Join("; ")
            .AssertEquals("1, 2, 3; 4, 5, 6; 7, 8, 9")
    }

    static Of() {
        ZipArray.Of(Tuple(1, 2, 3), Tuple(4, 5, 6), Tuple(7, 8, 9))
            .Narrow((Args*) => Args.Join(", "))
            .Join("; ")
            .AssertEquals("1, 4, 7; 2, 5, 8; 3, 6, 9")
    }

    static ZipWith() {
        Array(1, 2)
                .ZipWith(Array(3, 4))
                .Narrow((a, b) => (a + b))
                .Join(", ").AssertEquals("4, 6")
    }

    static Zip() {
        Array(1, 2)
            .Zip((x) => Tuple(x, x + 1))
            .Narrow(Combiner.Sum)
            .Reduce(Combiner.Sum)
            .AssertEquals(8)
    }

    static Spread1() {
        Array("Hello", "world")
            .Spread(SubStr.Bind(unset, 1, 1),
                    SubStr.Bind(unset, -1, 1))
            .Narrow(Combiner.Concat)
            .Join(", ")
            .AssertEquals("Ho, wd")
    }

    static Spread2() {
        Array("Hello", "world").Spread(
                SubStr.Bind(unset, 1, 1),
                SubStr.Bind(unset, -1, 1))
    }

    static Map() {
        ZipArray.Of(Array(1, 2, 3), Array(4, 5, 6))
            .Map((a, b) => Tuple(a + 1, b - 1))
            .Narrow(Combiner.Concat).Join(", ")
            .AssertEquals("23, 34, 45")
    }

    static RetainIf() {
        ZipArray.Of(Array(1, 2, 3), Array(4, 5, 6))
            .RetainIf((a, b) => (a + b > 6))
            .Narrow(Combiner.Concat).Join(", ")
            .AssertEquals("25, 36")
    }

    static RemoveIf() {
        ZipArray.Of(Array(1, 2, 3), Array(4, 5, 6))
            .RemoveIf((a, b) => (a + b > 6))
            .Narrow(Combiner.Concat).Join(", ")
            .AssertEquals("14")
    }

    static ForEach() {
        Results := Array()
        ZipArray.Of(Array(1, 2, 3), Array(4, 5, 6))
            .ForEach((a, b) => Results.Push(a + b))
        
        Results.Join(", ").AssertEquals("5, 7, 9")
    }

    static ZipStream() {
        ZipArray.Of(Array(1, 2, 3), Array(4, 5, 6)).Stream()
            .RetainIf((a, b) => (a + b) > 6)
    }
}
