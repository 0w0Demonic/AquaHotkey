class Test_Stream extends TestSuite {
    static RetainIf() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .RetainIf(Num => !(Num & 1))
            .Join(" ")
            .Assert(Eq("2 4"))
    }

    static RemoveIf() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .RemoveIf(Num => !(Num & 1))
            .Join(" ")
            .Assert(Eq("1 3 5"))
    }

    static Map() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .Map(Num => Num * 2)
            .Join(" ")
            .Assert(Eq("2 4 6 8 10"))
    }

    static FlatMap1() {
        Array(
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9]
        )
        .Stream()
        .FlatMap(x => x.Stream())
        .Join(" ")
        .Assert(Eq("1 2 3 4 5 6 7 8 9"))
    }

    static FlatMap2() {
        Array("Hello, ", "world!")
            .Stream()
            .FlatMap((Str) => Str.Stream())
            .Join(" ")
            .Assert(Eq("H e l l o ,   w o r l d !"))
    }

    static FlatMap3() {
        Array(1).Stream().FlatMap((x) => Stream.Of(1, 2))
                .Join(" ").Assert(Eq("1 2"))
    }

    static Of() {
        Stream.Of(1, 2, 3).Join(" ").Assert(Eq("1 2 3"))
    }

    static MapByRef() {
        static MapByRef(&Index, &Value) {
            Index *= 2
            Value .= "a"
        }
        static Mapper(Index, Value) {
            return Index . "=" . Value
        }
        StrSplit("banana")
            .DoubleStream()
            .MapByRef(MapByRef)
            .Map(Mapper)
            .Join(", ")
            .Assert(Eq("2=ba, 4=aa, 6=na, 8=aa, 10=na, 12=aa"))
    }

    static Limit() {
        Array(1, 2, 3, 4, 5, 6)
            .Stream()
            .Limit(2)
            .Join(" ")
            .Assert(Eq("1 2"))
    }

    static Skip() {
        Array(1, 2, 3, 4, 5, 6)
            .Stream()
            .Skip(4)
            .Join(" ")
            .Assert(Eq("5 6"))
    }

    static DropWhile() {
        Array(1, 2, 3, 4, 5, 1, -12)
            .Stream()
            .DropWhile(Num => Num < 5)
            .Join(" ")
            .Assert(Eq("5 1 -12"))
    }

    static TakeWhile() {
        Array(1, 2, 3, 4, 5, 1, -12)
            .Stream()
            .TakeWhile(Num => Num < 5)
            .Join(" ")
            .Assert(Eq("1 2 3 4"))
    }

    static Distinct1() {
        Array(1, 2, 3, 4, 1, 2, 3, 4, 5)
            .Stream()
            .Distinct()
            .Join(" ")
            .Assert(Eq("1 2 3 4 5"))
    }

    static Distinct2() {
        Array("foo", "Foo", "FOO")
            .Stream()
            .Distinct(StrLower)
            .Join()
            .Assert(Eq("foo"))
    }

    static Distinct3() {
        Array({ Value: 1 }, { Value: 2 }, { Value: 3 })
            .Stream()
            .Distinct(Obj => Obj.Value)
            .Map(Obj => Obj.Value)
            .Join(" ")
            .Assert(Eq("1 2 3"))
    }

    static Peek() {
        Arr       := Array()

        Array(1, 2, 3, 4, 5)
            .Stream()
            .Peek(x => Arr.Push(x))
            .Map(Num => Num * 2)
            .Join(" ")
            .Assert(Eq("2 4 6 8 10"))

        Arr.Join(" ").Assert(Eq("1 2 3 4 5"))
    }

    static ForEach() {
        Arr := Array()
        Array(1, 2, 3, 4, 5)
            .Stream()
            .ForEach(x => Arr.Push(x))

        Arr.Join(" ").Assert(Eq("1 2 3 4 5"))
    }

    static Any() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .Any(Num => Num == 5)
            .Assert(Eq(true))
    }

    static Find() {
        Equals(A) => (B) => (A == B)

        Out := Array(1, 2, 3, 4, 5).Stream().Find(Equals(5))

        Out.IsPresent.Assert(Eq(true))
        Out.Get().Assert(Eq(5))
    }

    static All() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .All(Num => Num < 10)
            .Assert(Eq(true))
    }

    static None() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .None(Num => Num => 3)
            .Assert(Eq(false))
    }

    static Max1() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .Max()
            .Assert(Eq(5))
    }

    static Max2() {
        static Comp(First, Second) {
            return (First.Value - Second.Value).Signum()
        }
        
        Array({ Value: 1 }, { Value: 2 }, { Value: 3 })
            .Stream()
            .Max(Comp)
            .Value
            .Assert(Eq(3))
    }

    static Min1() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .Min()
            .Assert(Eq(1))
    }

    static Min2() {
        static Comp(First, Second) {
            return (First.Value - Second.Value).Signum()
        }
        
        Array({ Value: 1 }, { Value: 2 }, { Value: 3 })
            .Stream()
            .Min(Comp)
            .Value
            .Assert(Eq(1))
    }

    static Sum() {
        Array(1, 2, 3, 4).Stream().Sum().AssertType(Float).Assert(Eq(10))
    }

    static ToArray1() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .ToArray()
            .Join(" ")
            .Assert(Eq("1 2 3 4 5"))
    }
    
    static ToArray2() {
        Array(3, 456, 23, 467, 234)
            .DoubleStream()
            .Map((Key, Value) => Key)
            .ToArray()
            .Join(" ")
            .Assert(Eq("1 2 3 4 5"))
    }

    static Fold() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .Reduce((a, b) => (a + b))
            .Assert(Eq(15))
    }

    static Generate() {
        Stream.Generate(() => 1).Limit(5).Join().Assert(Eq("11111"))
    }

    static Iterate() {
        Stream.Iterate(1, (x) => x + 1).Limit(5).Join().Assert(Eq("12345"))
    }
}