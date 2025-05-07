/**
 * AquaHotkey - Array.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/Sphinx
 * - tests/Builtins/Array.ahk
 */
class Array {
    static PropertySetters() {
        Arr := Array().SetCapacity(256).SetLength(128).SetDefault("(empty)")
        Arr.Capacity.AssertEquals(256)
        Arr.Length.AssertEquals(128)
        Arr.Default.AssertEquals("(empty)")
    }

    static Slice1() {
        Array(1, 2, 3, 4, 5).Slice(2).Join().AssertEquals("2345")
    }

    static Slice2() {
        Array(1, 2, 3, 4, 5).Slice(-2).Join().AssertEquals("45")
    }

    static Slice3() {
        Array(1, 2, 3, 4, 5, 6, 7).Slice(, 5).Join().AssertEquals("12345")
    }

    static Slice4() {
        Array(1, 2, 3, 4, 5, 6, 7).Slice(,, 2).Join().AssertEquals("1357")
    }
    
    static Slice5() {
        Array(1, 2, 3, 4, 5, 6, 7).Slice(,, -2).Join().AssertEquals("7531")
    }

    static Slice6() {
        Array(1, 2, 3, 4, 5, 6).Slice(1, -2).Join().AssertEquals("1234")
    }

    static IsEmpty1() {
        Array().IsEmpty.AssertEquals(true)
    }

    static IsEmpty2() {
        Array(1, 2, 4).IsEmpty.AssertEquals(false)
    }

    static HasElements1() {
        Array(1, 2, 4).HasElements.AssertEquals(true)
    }

    static HasElements2() {
        Array(unset, unset, 1).HasElements.AssertEquals(true)
    }

    static HasElements3() {
        Array(unset, unset, unset).HasElements.AssertEquals(false)
    }

    static Swap1() {
        Array("1", "2").Swap(1, 2).Join().AssertEquals("21")
    }

    static Swap2() {
        Array("1", unset, "2", "3").Swap(2, 4).Join().AssertEquals("132")
    }

    static Swap3() {
        Array("1", unset, unset, "4").Swap(2, 3).Join().AssertEquals("14")
    }

    static Swap4() {
        Array(unset, unset).Swap(1, 2).Map((str?) => (str ?? "unset"))
                .Join(", ").AssertEquals("unset, unset")
    }
    
    static Swap5() {
        static Test() {
            Array(1, 2, 3, 4).Swap(3, 87)
        }
        TestSuite.AssertThrows(Test)
    }

    static Reverse1() {
        Array(1, 2, 3, 4, 5).Reverse().Join().AssertEquals("54321")
    }

    static Reverse2() {
        Arr := Array(unset, unset, 2).Reverse()
        Arr.Length.AssertEquals(3)
        Arr.Has(1).AssertEquals(true)
        Arr.Has(2).AssertEquals(false)
        Arr.Has(3).AssertEquals(false)
    }

    static Sort1() {
        Array("apple", "pineapple", "banana").Sort(StrCompare)
            .Join(" ").AssertEquals("apple banana pineapple")
    }

    static Sort2() {
        Array("apple", "pineapple", "banana")
            .Sort(StrCompare, true)
            .Join(" ")
            .AssertEquals("pineapple banana apple")
    }

    static Sort3() {
        Array(1, 3, 56, 23, 12).Sort().Join(" ")
            .AssertEquals("1 3 12 23 56")
    }

    static Sort4() {
        Array(1, 3, 56, 23, 12).Sort(, true).Join(" ")
            .AssertEquals("56 23 12 3 1")
    }
    
    static Sort5() {
        Array("FOO", "foo", "Foo").SortAlphabetically(true).Join(" ")
            .AssertEquals("FOO Foo foo")
    }

    static Sort6() {
        Array("apple", "Apple", "APPLE")
            .SortAlphabetically(true, true)
            .Join(" ")
            .AssertEquals("APPLE Apple apple")
    }

    static Sort7() {
        static Comparator(a?, b?) {
            if (!IsSet(a) && !IsSet(b)) {
                return 0
            }
            if (!IsSet(a) && IsSet(b)) {
                return -1
            }
            if (IsSet(a) && !IsSet(b)) {
                return 1
            }
            return (a > b) - (b > a)
        }
        Array(unset, 1, 2, 3, unset).Sort(Comparator).Join().AssertEquals("123")
    }

    static Sort8() {
        Array().Sort()
    }

    static Sort9() {
        static CompBuffers(A, B) {
            ASize := A.Size
            BSize := B.Size
            return (ASize > BSize) - (ASize > BSize)
        }
        vbuf := Buffer(24, 0)
        vref := ComValue(0x400C, vbuf.Ptr)
        Array(vbuf, vbuf).Sort(CompBuffers)
    }

    static SortAlphabetically() {
        Array(1, 4, 2, 3).SortAlphabetically().Join().AssertEquals("1234")
    }

    static SortAlphabetically2() {
        Array("foo", "FOO").SortAlphabetically(true)
                           .Join().AssertEquals("FOOfoo")
    }

    static Max1() {
        Array(2, 4, 12, 56, 234).Max().AssertEquals(234)
    }

    static Max2() {
        static Comparator(a, b) {
            return (a.Value > b.Value) - (b.Value > a.Value)
        }
        Array({Value: 1}, {Value: 2}, {Value: 3})
            .Max(Comparator)
            .Value
            .AssertEquals(3)
    }

    static Max3() {
        TestSuite.AssertThrows(() => (
            Array().Max()
        ))
    }

    static Max4() {
        Array(unset, unset, 1, unset).Max().AssertEquals(1)
    }

    static Max5() {
        TestSuite.AssertThrows(() => (
            Array(unset, unset, unset).Max()
        ))
    }

    static Min1() {
        Array(2, 4, 12, 56, 234).Min().AssertEquals(2)
    }

    static Min2() {
        static Comparator(a, b) {
            return (a.Value > b.Value) - (b.Value > a.Value)
        }
        Array({Value: 1}, {Value: 2}, {Value: 3})
            .Min(Comparator)
            .Value
            .AssertEquals(1)
    }

    static Min3() {
        TestSuite.AssertThrows(() => (
            Array().Min()
        ))
    }

    static Min4() {
        Array(unset, unset, 1, unset).Min().AssertEquals(1)
    }

    static Min5() {
        TestSuite.AssertThrows(() => (
            Array(unset, unset, unset).Min()
        ))
    }
    
    static Sum() {
        Array(1, 2, 3, 4, unset).Sum().AssertEquals(10)
    }

    static Average() {
        Array(1, 2, 3, 4, unset).Average().AssertEquals(2.5)
    }

    static Map1() {
        Array(1, 2, 3, 4).Map(Num => Num * 2).Join().AssertEquals("2468")
    }

    static Map2() {
        static Foo(Value?) {
            Value := Value ?? 0
            return Value * 2
        }
        Array(1, 2, unset, 4).Map(Foo).Join().AssertEquals("2408")
    }

    static Map3() {
        Array("foo", "bar").Map(SubStr, 1, 1).Join(", ").AssertEquals("f, b")
    }

    static ReplaceAll1() {
        Array(1, 2, 3, 4).Map(Num => (Num * 2)).Join().AssertEquals("2468")
    }

    static ReplaceAll2() {
        static Foo(Value?) {
            Value := Value ?? 0
            return Value * 2
        }
        Array(1, 2, unset, 4).ReplaceAll(Foo).Join().AssertEquals("2408")
    }
    
    static ReplaceAll3() {
        Array("foo", "bar").Map(SubStr, 1, 1).Join(", ").AssertEquals("f, b")
    }

    static FlatMap1() {
        Array(
            Array(1, 2, 3),
            Array(4, 5, 6),
            Array(7, 8, 9)
        ).FlatMap().Join().AssertEquals("123456789")
    }

    static FlatMap2() {
        Array("hello", "world")
            .FlatMap(StrSplit)
            .Join(" ")
            .AssertEquals("h e l l o w o r l d")
    }

    static FlatMap3() {
        Array("a,b", "c,d")
                .FlatMap(StrSplit, ",")
                .Join(" ")
                .AssertEquals("a b c d")
    }

    static RetainIf1() {
        Array(1, 2, 3, 4, 5).RetainIf(Num => Num > 3)
            .Join().AssertEquals("45")
    }

    static RetainIf2() {
        Arr := Array(1, 2, 3, 4, unset).RetainIf(Num => Num > 2)
        Arr.Length.AssertEquals(2)
        Arr.Join().AssertEquals("34")
    }

    static RetainIf3() {
        static Filter(Value?) {
            if (!IsSet(Value)) {
                return true
            }
            return (Value > 1)
        }
        Arr := Array(1, 2, 3, unset, unset).RetainIf(Filter)
        Arr.Length.AssertEquals(4)

        Arr.Join().AssertEquals("23")
    }

    static RetainIf4() {
        Array("foo", "bar").RetainIf(InStr, "o").Join().AssertEquals("foo")
    }

    static RemoveIf1() {
        Array(1, 2, 3, 4, 5).RemoveIf(Num => Num > 3)
            .Join().AssertEquals("123")
    }

    static RemoveIf2() {
        Arr := Array(1, 2, 3, 4, unset).RetainIf(Num => Num > 2)
        Arr.Length.AssertEquals(2)
        Arr.Join().AssertEquals("34")
    }

    static RemoveIf3() {
        static Filter(Value?) {
            if (!IsSet(Value)) {
                return false
            }
            return (Value > 1)
        }
        Arr := Array(1, 2, 3, unset, unset).RemoveIf(Filter)
        Arr.Length.AssertEquals(3)
        Arr.Join().AssertEquals("1")
    }

    static RemoveIf4() {
        Array("foo", "bar").RemoveIf(InStr, "f").Join().AssertEquals("bar")
    }

    static Partition1() {
        static IsEven(Num) => !(Num & 1)
        M := Array(1, 2, 3, 4, 5).Partition(IsEven)

        M[true].Join().AssertEquals("24")
        M[false].Join().AssertEquals("135")
    }

    static Partition2() {
        M := Array("foo", "bar").Partition(InStr, "f")
        M[true].Join().AssertEquals("foo")
        M[false].Join().AssertEquals("bar")
    }

    static GroupBy1() {
        M := Array(12, 23, 3, 45, 95).GroupBy((Num) => Mod(Num, 10))
        M[2].Join(" ").AssertEquals("12")
        M[3].Join(" ").AssertEquals("23 3")
        M[5].Join(" ").AssertEquals("45 95")
    }

    static GroupBy2() {
        static Classifier(Value?) {
            if (!IsSet(Value)) {
                return 0
            }
            return Mod(Value, 10)
        }
        M := Array(12, 12, unset, unset).GroupBy(Classifier)

        UnsetElements := M[0]
        UnsetElements.Length.AssertEquals(2)
        UnsetElements.Has(1).AssertEquals(false)
        UnsetElements.Has(2).AssertEquals(false)

        M[2].Join(" ").AssertEquals("12 12")
    }

    static GroupBy3() {
        static FirstLetter(Value) => SubStr(Value, 1, 1)

        M := Array("foo", "Foo", "FOO").GroupBy(FirstLetter, true)
        M["f"].Join().AssertEquals("foo")
        M["F"].Join(" ").AssertEquals("Foo FOO")
    }

    static GroupBy4() {
        M := Array("foo", "bar").GroupBy(SubStr, false, 1, 1)

        M.Count.AssertEquals(2)
        M["f"].Join().AssertEquals("foo")
        M["b"].Join().AssertEquals("bar")
    }

    static Distinct1() {
        StrSplit("aaAbBbbcCdd").Distinct().Join().AssertEquals("aAbBcCd")
    }

    static Distinct2() {
        StrSplit("aaAbBbbcCdd").Distinct(false).Join().AssertEquals("abcd")
    }

    static Distinct3() {
        Arr := Array({Value: 123}, {Value: 23}, {Value: 123})
            .Distinct(Obj => Obj.Value, true)

        Arr.Length.AssertEquals(2)
        Arr[1].Value.AssertEquals(123)
        Arr[2].Value.AssertEquals(23)
    }

    static Join() {
        Array(1, 2, 3).Join(" ", 64).AssertEquals("1 2 3")
    }

    static JoinLine() {
        Array(1, 2, 3).JoinLine(64).AssertEquals("
        (
        1
        2
        3
        )")
    }

    static Reduce1() {
        Array(1, 2, 3, 4).Reduce((a, b) => a + b).AssertEquals(10)
    }

    static Reduce2() {
        Array(1, 2, 3, unset, unset).Reduce((a, b) => a + b).AssertEquals(6)
    }

    static Reduce3() {
        TestSuite.AssertThrows(() => (
            Array(unset, unset, unset).Reduce((a, b) => a + b).MsgBox()
        ))
    }

    static Reduce4() {
        Array(unset, unset).Reduce((a, b) => a + b, 0).AssertEquals(0)
    }

    static ForEach1() {
        Arr := Array()
        Array(1, 2, 3, 4).ForEach(v => Arr.Push(v))
        Arr.Length.AssertEquals(4)
    }

    static ForEach2() {
        Arr := Array()
        DoSomething(V?) {
            if (!IsSet(V) || (V == 1)) {
                Arr.Push(V?)
            }
        }
        Array(1, 2, unset, unset).ForEach(DoSomething)

        Arr.Length.AssertEquals(3)
        Arr[1].AssertEquals(1)
        Arr.Has(2).AssertEquals(false)
        Arr.Has(3).AssertEquals(fAlse)
    }

    static ForEach3() {
        M := Map()
        DoSomething(Key, Value) {
            M[Key] := Value
        }

        Array(1, 2, 3).ForEach(DoSomething, "foo")
        M.Count.AssertEquals(3)
        M[1].AssertEquals("foo")
        M[2].AssertEquals("foo")
        M[3].AssertEquals("foo")
    }
}

