/**
 * AquaHotkey - Collector.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Extensions/Collector.ahk
 */
class Collector {
    static __New() {
        global C := Collector
    }

    static ToArray() {
        Arr := Array(1, 2, 3, 4, 5).Collect(C.ToArray)
        
        Arr.AssertType(Array)
        Arr.Join().AssertEquals("12345")
    }

    static Join1() {
        Array("H", "e", "l", "l", "o").Collect(C.Join).AssertEquals("Hello")
    }

    static Join2() {
        Array("H", "e", "l", "l", "o").Collect(C.Join(", "))
            .AssertEquals("H, e, l, l, o")
    }

    static Join3() {
        Array("H", "e", "l", "l", "o").Collect(C.Join(", ", "[", "]"))
            .AssertEquals("[H, e, l, l, o]")
    }

    static Average1() {
        Array(1, 2, 3, 4, 5).Collect(C.Average).AssertEquals(3.0)
    }

    static Average2() {
        static TimesTwo(x) => (x * 2)
        
        Array(1, 2, 3, 4, 5).Collect(C.Average(TimesTwo)).AssertEquals(6.0)
    }

    static Reduce() {
        static Sum(a, b) => (a + b)

        Array(1, 2, 3, 4, 5).Collect(C.Reduce(Sum)).AssertEquals(15)

        Array(1, 2, 3, 4, 5).Collect(C.Reduce(Sum, 5)).AssertEquals(20)
    }

    static Count() {
        Array(1, 2, 3, 4).Collect(C.Count).AssertEquals(4)
    }

    static Tee() {
        Range(5).Collect(C.Tee(C.Join, C.Sum, Format.Bind("{}, {}")))
            .AssertEquals("12345, 15")
    }

    static Min1() {
        Range(40).Collect(C.Min).AssertEquals(1)
    }

    static Min2() {
        Array({ x: 15 }, { x: 16 }, { x: 12 })
            .Collect(C.Min(
                Comparator.Numeric((Obj) => Obj.x)
            ))
            .x
            .AssertEquals(12)
    }
    
    static Max1() {
        Range(40).Collect(C.Max).AssertEquals(40)
    }

    static Max2() {
        Array({ x: 15 }, { x: 16 }, { x: 12 })
            .Collect(C.Max(
                Comparator.Numeric((Obj) => Obj.x)
            ))
            .x
            .AssertEquals(16)
    }

    static Sum1() {
        Range(10).Collect(C.Sum).AssertEquals(55)
    }

    static Sum2() {
        static TimesTwo(x) => (x * 2)

        Range(10).Collect(C.Sum(TimesTwo)).AssertEquals(110)
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

    static RetainIf() {
        Range(10).Collect(C.RetainIf(
                x => (x < 5),
                C.ToArray))
            .Join(", ")
            .AssertEquals("1, 2, 3, 4")
    }

    static RemoveIf() {
        Range(10).Collect(C.RemoveIf(
                x => (x < 5),
                C.ToArray))
            .Join(", ")
            .AssertEquals("5, 6, 7, 8, 9, 10")
    }

    static AndThen() {
        TimesTwo(x) => (x * 2)

        Range(10).Collect(
                C.Map(TimesTwo, C.ToArray)
                        .AndThen(Array.Prototype.Join))
            .AssertEquals("2468101214161820")
    }

    static Frequency1() {
        "Hello, world!".Collect(C.Frequency).AssertType(Map)
                .Get("o").AssertEquals(2)
    }

    static Frequency2() {
        "Hello, world!".Collect(C.Frequency(Ord)).AssertType(Map)
                .Get(Ord("o")).AssertEquals(2)
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

    static ToMap1() {
        M := Array("Hello", "world").Stream(2)
                   .Collect(C.ToMap)
        
        M[1].AssertEquals("Hello")
        M[2].AssertEquals("world")
    }

    static ToMap2() {
        M := Array("Hello", "world").Stream(2)
                   .Collect(C.ToMap(
                        (Index, Value, *) => SubStr(Value, 1, 1),
                        (Index, Value, *) => Value,
                        unset,
                        false))
        
        M["h"].AssertEquals("Hello")
        M["w"].AssertEquals("world")
    }

    static ToMap3() {
        M := Array(1, 2).Collect(C.ToMap(
            (Num) => "foo",
            (Num) => Num,
            (Left, Right) => (Left + Right),
            unset))
        
        M["foo"].AssertEquals(3)
    }

    static Custom() {
        Range(5).Collect(TestSuite.__Collector_Average())
                .AssertEquals(3.0)
    }
}

class __Collector_Average extends Collector {
    Sum   := Float(0)
    Count := 0

    Supplier() {
    }

    Accumulator(_, Num?) {
        if (IsSet(Num) && IsNumber(Num)) {
            this.Sum += Num
            this.Count++
        }
    }

    Finisher(_) {
        if (this.Count) {
            return (this.Sum / this.Count)
        }
        return Float(0)
    }
}
