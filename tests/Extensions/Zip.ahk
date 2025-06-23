
class Zip {
    static Constructor() {
        ZippedArray(Tuple(1, 2, 3), Tuple(4, 5, 6), Tuple(7, 8, 9))
            .Unzip((Args*) => Args.Join(", "))
            .Join("; ")
            .AssertEquals("1, 2, 3; 4, 5, 6; 7, 8, 9")
    }

    static Of() {
        ZippedArray.Of(Tuple(1, 2, 3), Tuple(4, 5, 6), Tuple(7, 8, 9))
            .Unzip((Args*) => Args.Join(", "))
            .Join("; ")
            .AssertEquals("1, 4, 7; 2, 5, 8; 3, 6, 9")
    }

    static ZipWith() {
        Array(1, 2).ZipWith(Array(3, 4)).Unzip((a, b) => (a + b))
                .Join(", ").AssertEquals("4, 6")
    }

    static Zip() {
        Array(1, 2).Zip((x) => Tuple(x, x + 1))
            .Unzip(Combiner.Sum)
            .Reduce(Combiner.Sum)
            .AssertEquals(8)
    }

    static Spread1() {
        static FirstLetter(Str) => SubStr(Str, 1, 1)
        static LastLetter(Str)  => SubStr(Str, -1, 1)

        Array("Hello", "world").Spread(FirstLetter, LastLetter)
            .Unzip(Combiner.Concat).Join(", ")
            .AssertEquals("Ho, wd")
    }

    static Spread2() {
        Array("Hello", "world").Spread(
                SubStr.Bind(unset, 1, 1),
                SubStr.Bind(unset, -1, 1))
    }

    static Map() {
        ZippedArray.Of(Array(1, 2, 3), Array(4, 5, 6))
            .Map((a, b) => Tuple(a + 1, b - 1))
            .Unzip(Combiner.Concat).Join(", ")
            .AssertEquals("23, 34, 45")
    }

    static RetainIf() {
        ZippedArray.Of(Array(1, 2, 3), Array(4, 5, 6))
            .RetainIf((a, b) => (a + b > 6))
            .Unzip(Combiner.Concat).Join(", ")
            .AssertEquals("25, 36")
    }

    static RemoveIf() {
        ZippedArray.Of(Array(1, 2, 3), Array(4, 5, 6))
            .RemoveIf((a, b) => (a + b > 6))
            .Unzip(Combiner.Concat).Join(", ")
            .AssertEquals("14")
    }

    static ForEach() {
        Results := Array()
        ZippedArray.Of(Array(1, 2, 3), Array(4, 5, 6))
            .ForEach((a, b) => Results.Push(a + b))
        
        Results.Join(", ").AssertEquals("5, 7, 9")
    }
}
