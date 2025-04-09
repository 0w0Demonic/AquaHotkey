/**
 * AquaHotkey - Stream.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Other/Stream.ahk
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
        .FlatMap(x => x)
        .Join(" ")
        .AssertEquals("1 2 3 4 5 6 7 8 9")
    }

    static FlatMap2() {
        Array("Hello, ", "world!")
            .Stream()
            .FlatMap(StrSplit)
            .Join(" ")
            .AssertEquals("H e l l o ,   w o r l d !")
    }

    static FlatMap3() {
        Array([1, 2, 3], 4, [5, 6], 7, [8])
            .Stream()
            .FlatMap()
            .Join(" ")
            .AssertEquals("1 2 3 4 5 6 7 8")
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
            .Stream(2)
            .MapByRef(MapByRef)
            .Map(Mapper)
            .Join(", ")
            .AssertEquals("2=ba, 4=aa, 6=na, 8=aa, 10=na, 12=aa")
    }

    static FindFirst() {
        Arr := Array()
        Array(1, 2, 3, 4, 5, 6, 7)
            .Stream()
            .RetainIf(Num => Num > 4)
            .FindFirst()
            .ForEach(x => Arr.Push(x))

        Arr[1].AssertEquals(5)
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
            .Distinct(false)
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

    static AnyMatch() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .AnyMatch(Num => Num == 5, &Output)
            .AssertEquals(true)

        Output.Length.AssertEquals(1)
        Output[1].AssertEquals(5)
    }

    static AllMatch() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .AllMatch(Num => Num < 10)
            .AssertEquals(true)
    }

    static NoneMatch() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .NoneMatch(Num => Num => 3)
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
            .Stream(2)
            .ToArray()
            .Join(" ")
            .AssertEquals("1 2 3 4 5")
    }

    static Collect() {
        Result := Array(2, 4, 6, 8, 10)
            .Stream(2)
            .Collect(Map, Map.Prototype.Set)
        
        Result.AssertType(Map)
        Result.Count.AssertEquals(5)
        Result[1].AssertEquals(2)
        Result[2].AssertEquals(4)
        Result[3].AssertEquals(6)
        Result[4].AssertEquals(8)
        Result[5].AssertEquals(10)
    }

    static Reduce() {
        Array(1, 2, 3, 4, 5)
            .Stream()
            .Reduce((a, b) => (a + b))
            .AssertEquals(15)
    }
}