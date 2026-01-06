/**
 * AquaHotkey - Stream.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Extensions/Stream.ahk
 */
class Stream {
    static RetainIf() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .RetainIf(Num => !(Num & 1))
            .Join(" ")
            .AssertEquals("2 4")
    }

    static RemoveIf() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .RemoveIf(Num => !(Num & 1))
            .Join(" ")
            .AssertEquals("1 3 5")
    }

    static Map() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .Map(Num => Num * 2)
            .Join(" ")
            .AssertEquals("2 4 6 8 10")
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
        .AssertEquals("1 2 3 4 5 6 7 8 9")
    }

    static FlatMap2() {
        Array("Hello, ", "world!")
            .Stream()
            .FlatMap((Str) => Str.Stream())
            .Join(" ")
            .AssertEquals("H e l l o ,   w o r l d !")
    }

    static FlatMap3() {
        Array(1).Stream().FlatMap((x) => Stream.Of(1, 2))
                .Join(" ").AssertEquals("1 2")
    }

    static Of() {
        Stream.Of(1, 2, 3).Join(" ").AssertEquals("1 2 3")
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
            .AssertEquals("2=ba, 4=aa, 6=na, 8=aa, 10=na, 12=aa")
    }

    static Limit() {
        Array(1, 2, 3, 4, 5, 6)
            .Stream()
            .Limit(2)
            .Join(" ")
            .AssertEquals("1 2")
    }

    static Skip() {
        Array(1, 2, 3, 4, 5, 6)
            .Stream()
            .Skip(4)
            .Join(" ")
            .AssertEquals("5 6")
    }

    static DropWhile() {
        Array(1, 2, 3, 4, 5, 1, -12)
            .Stream()
            .DropWhile(Num => Num < 5)
            .Join(" ")
            .AssertEquals("5 1 -12")
    }

    static TakeWhile() {
        Array(1, 2, 3, 4, 5, 1, -12)
            .Stream()
            .TakeWhile(Num => Num < 5)
            .Join(" ")
            .AssertEquals("1 2 3 4")
    }

    static Distinct1() {
        Array(1, 2, 3, 4, 1, 2, 3, 4, 5)
            .Stream()
            .Distinct()
            .Join(" ")
            .AssertEquals("1 2 3 4 5")
    }

    static Distinct2() {
        Array("foo", "Foo", "FOO")
            .Stream()
            .Distinct(StrLower)
            .Join()
            .AssertEquals("foo")
    }

    static Distinct3() {
        Array({ Value: 1 }, { Value: 2 }, { Value: 3 })
            .Stream()
            .Distinct(Obj => Obj.Value)
            .Map(Obj => Obj.Value)
            .Join(" ")
            .AssertEquals("1 2 3")
    }

    static Peek() {
        Arr       := Array()
        PushToArr := Arr.BindMethod("Push")

        Array(1, 2, 3, 4, 5)
            .Stream()
            .Peek(PushToArr)
            .Map(Num => Num * 2)
            .Join(" ")
            .AssertEquals("2 4 6 8 10")

        Arr.Join(" ").AssertEquals("1 2 3 4 5")
    }

    static ForEach() {
        Arr := Array()
        PushToArr := Arr.BindMethod("Push")

        Array(1, 2, 3, 4, 5)
            .Stream()
            .ForEach(PushToArr)

        Arr.Join(" ").AssertEquals("1 2 3 4 5")
    }

    static Any() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .Any(&Out, Num => Num == 5)
            .AssertNotEquals(false)
        
        IsSet(Out).AssertEquals(true)
        Out.AssertEquals(5)
    }

    static All() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .All(Num => Num < 10)
            .AssertEquals(true)
    }

    static None() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .None(Num => Num => 3)
            .AssertEquals(false)
    }

    static Max1() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .Max()
            .AssertEquals(5)
    }

    static Max2() {
        static Comp(First, Second) {
            return (First.Value - Second.Value).Signum()
        }
        
        Array({ Value: 1 }, { Value: 2 }, { Value: 3 })
            .Stream()
            .Max(Comp)
            .Value
            .AssertEquals(3)
    }

    static Min1() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .Min()
            .AssertEquals(1)
    }

    static Min2() {
        static Comp(First, Second) {
            return (First.Value - Second.Value).Signum()
        }
        
        Array({ Value: 1 }, { Value: 2 }, { Value: 3 })
            .Stream()
            .Min(Comp)
            .Value
            .AssertEquals(1)
    }

    static Sum() {
        Array(1, 2, unset, unset, 3, unset, 4)
            .Stream()
            .Sum()
            .AssertType(Float)
            .AssertEquals(10)
    }

    static ToArray1() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .ToArray()
            .Join(" ")
            .AssertEquals("1 2 3 4 5")
    }
    
    static ToArray2() {
        Array(3, 456, 23, 467, 234)
            .DoubleStream()
            .Map((Key, Value) => Key)
            .ToArray()
            .Join(" ")
            .AssertEquals("1 2 3 4 5")
    }

    static Fold() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .Fold((a, b) => (a + b))
            .AssertEquals(15)
    }

    static Generate() {
        Stream.Generate(() => 1).Limit(5).Join().AssertEquals("11111")
    }

    static Iterate() {
        Stream.Iterate(1, (x) => x + 1).Limit(5).Join().AssertEquals("12345")
    }
}