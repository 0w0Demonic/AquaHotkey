

class Test_Array extends TestSuite
{
    static Slice1() {
        Array(1, 2, 3, 4, 5).Slice(2).Join().Assert(Eq("2345"))
    }

    static Slice2() {
        Array(1, 2, 3, 4, 5).Slice(-2).Join().Assert(Eq("45"))
    }

    static Slice3() {
        Array(1, 2, 3, 4, 5, 6, 7).Slice(, 5).Join().Assert(Eq("12345"))
    }

    static Slice4() {
        Array(1, 2, 3, 4, 5, 6, 7).Slice(,, 2).Join().Assert(Eq("1357"))
    }
    
    static Slice5() {
        Array(1, 2, 3, 4, 5, 6, 7).Slice(,, -2).Join().Assert(Eq("7531"))
    }

    static Slice6() {
        Array(1, 2, 3, 4, 5, 6).Slice(1, -2).Join().Assert(Eq("1234"))
    }

    static IsEmpty1() {
        Array().IsEmpty.Assert(Eq(true))
    }

    static IsEmpty2() {
        Array(1, 2, 4).IsEmpty.Assert(Eq(false))
    }

    static Swap1() {
        Array("1", "2").Swap(1, 2).Join().Assert(Eq("21"))
    }

    static Swap2() {
        this.AssertThrows(() => Array(unset, unset).Swap(1, 2))
        ; Array("1", unset, "2", "3").Swap(2, 4).Join().Assert(Eq("132"))
    }

    static Swap3() {
        ; Array("1", unset, unset, "4").Swap(2, 3).Join().Assert(Eq("14"))
    }

    static Swap4() {
        ; Array(unset, unset).Swap(1, 2).Map((str?) => (str ?? "unset"))
        ;         .Join(", ").Assert(Eq("unset, unset"))
    }
    
    static Swap5() {
        static Test() {
            Array(1, 2, 3, 4).Swap(3, 87)
        }
        this.AssertThrows(Test)
    }

    static Reverse1() {
        Array(1, 2, 3, 4, 5).Reverse().Join().Assert(Eq("54321"))
    }

    static Reverse2() {
        ; Arr := Array(unset, unset, 2).Reverse()
        ; Arr.Length.Assert(Eq(3))
        ; Arr.Has(1).Assert(Eq(true))
        ; Arr.Has(2).Assert(Eq(false))
        ; Arr.Has(3).Assert(Eq(false))
    }

    static Sort1() {
        Array("apple", "pineapple", "banana").Sort(StrCompare)
            .Join(" ").Assert(Eq("apple banana pineapple"))
    }

    static Sort2() {
        Array("apple", "pineapple", "banana")
            .Sort(StrCompare, true)
            .Join(" ")
            .Assert(Eq("pineapple banana apple"))
    }

    static Sort3() {
        Array(1, 3, 56, 23, 12).Sort().Join(" ")
            .Assert(Eq("1 3 12 23 56"))
    }

    static Sort4() {
        Array(1, 3, 56, 23, 12).Sort(, true).Join(" ")
            .Assert(Eq("56 23 12 3 1"))
    }

    static Sort7() {
        Array().Sort()
    }

    static Sort8() {
        static CompBuffers(A, B) {
            ASize := A.Size
            BSize := B.Size
            return (ASize > BSize) - (ASize > BSize)
        }
        vbuf := Buffer(24, 0)
        vref := ComValue(0x400C, vbuf.Ptr)
        Array(vbuf, vbuf).Sort(CompBuffers)
    }

    static Max1() {
        Array(2, 4, 12, 56, 234).Max().Assert(Eq(234))
    }

    static Max2() {
        static Comparator(a, b) {
            return (a.Value > b.Value) - (b.Value > a.Value)
        }
        Array({Value: 1}, {Value: 2}, {Value: 3})
            .Max(Comparator)
            .Value
            .Assert(Eq(3))
    }

    static Max3() {
        this.AssertThrows(() => (Array().Max()))
    }

    static Max4() {
        this.AssertThrows(() => Array(unset, unset, 1, unset).Max())
    }

    static Min1() {
        Array(2, 4, 12, 56, 234).Min().Assert(Eq(2))
    }

    static Min2() {
        static Comparator(a, b) {
            return (a.Value > b.Value) - (b.Value > a.Value)
        }
        Array({Value: 1}, {Value: 2}, {Value: 3})
            .Min(Comparator)
            .Value
            .Assert(Eq(1))
    }

    static Min3() {
        this.AssertThrows(() => (Array().Min()))
    }

    static Min5() {
        this.AssertThrows(() => (Array(unset, unset, 3, unset).Min()))
    }
    
    static Sum() {
        Array(1, 2, 3, 4).Sum().Assert(Eq(10))
    }

    static Average() {
        Array(1, 2, 3, 4).Average().Assert(Eq(2.5))
    }

    static Map1() {
        Array(1, 2, 3, 4).Map(Num => Num * 2).Join().Assert(Eq("2468"))
    }

    static Map2() {
        static Foo(Value?) {
            Value := Value ?? 0
            return Value * 2
        }
        Array(1, 2, unset, 4).Map(Foo).Join().Assert(Eq("2408"))
    }

    static Map3() {
        Array("foo", "bar").Map(SubStr, 1, 1).Join(", ").Assert(Eq("f, b"))
    }

    static ReplaceAll1() {
        Array(1, 2, 3, 4).Map(Num => (Num * 2)).Join().Assert(Eq("2468"))
    }

    static ReplaceAll2() {
        static Foo(Value?) {
            Value := Value ?? 0
            return Value * 2
        }
        Array(1, 2, unset, 4).ReplaceAll(Foo).Join().Assert(Eq("2408"))
    }
    
    static ReplaceAll3() {
        Array("foo", "bar").Map(SubStr, 1, 1).Join(", ").Assert(Eq("f, b"))
    }

    static FlatMap1() {
        Array(
            Array(1, 2, 3),
            Array(4, 5, 6),
            Array(7, 8, 9)
        ).FlatMap().Join().Assert(Eq("123456789"))
    }

    static FlatMap2() {
        Array("hello", "world")
            .FlatMap(StrSplit)
            .Join(" ")
            .Assert(Eq("h e l l o w o r l d"))
    }

    static FlatMap3() {
        Array("a,b", "c,d")
                .FlatMap(StrSplit, ",")
                .Join(" ")
                .Assert(Eq("a b c d"))
    }

    static RetainIf1() {
        Array(1, 2, 3, 4, 5).RetainIf(Num => Num > 3)
            .Join().Assert(Eq("45"))
    }

    static RetainIf2() {
        static Filter(Value?) {
            if (!IsSet(Value)) {
                return false
            }
            return (Value > 1)
        }
        Arr := Array(1, 2, 3, unset, unset).RetainIf(Filter)
        Arr.Length.Assert(Eq(2))

        Arr.Join().Assert(Eq("23"))
    }

    static RetainIf3() {
        Array("foo", "bar").RetainIf(InStr, "o").Join().Assert(Eq("foo"))
    }

    static RemoveIf1() {
        Array(1, 2, 3, 4, 5).RemoveIf(Num => Num > 3)
            .Join().Assert(Eq("123"))
    }

    static RemoveIf2() {
        static Filter(Value?) {
            if (!IsSet(Value)) {
                return true
            }
            return (Value > 1)
        }
        Arr := Array(1, 2, 3, unset, unset).RemoveIf(Filter)
        Arr.Length.Assert(Eq(1))
        Arr.Join().Assert(Eq("1"))
    }

    static RemoveIf3() {
        Array("foo", "bar").RemoveIf(InStr, "f").Join().Assert(Eq("bar"))
    }

    static Distinct1() {
        StrSplit("aaAbBbbcCdd").Distinct().Join().Assert(Eq("aAbBcCd"))
    }

    static Distinct2() {
        StrSplit("aaAbBbbcCdd").Distinct(unset, false).Join().Assert(Eq("abcd"))
    }

    static Distinct3() {
        Arr := Array({Value: 123}, {Value: 23}, {Value: 123})
            .Distinct(Obj => Obj.Value, true)

        Arr.Length.Assert(Eq(2))
        Arr[1].Value.Assert(Eq(123))
        Arr[2].Value.Assert(Eq(23))
    }

    static Join() {
        Array(1, 2, 3).Join(" ").Assert(Eq("1 2 3"))
    }

    static JoinLine() {
        Array(1, 2, 3).JoinLine().Assert(Eq("
        (
        1
        2
        3
        )"))
    }

    static Reduce1() {
        Array(1, 2, 3, 4).Reduce((a, b) => a + b).Assert(Eq(10))
    }

    static Reduce2() {
        this.AssertThrows(() => (
            Array(unset, unset, unset).Reduce((a, b) => a + b).MsgBox()
        ))
    }

    static ForEach1() {
        Arr := Array()
        Array(1, 2, 3, 4).ForEach(v => Arr.Push(v))
        Arr.Length.Assert(Eq(4))
    }

    static ForEach2() {
        Arr := Array()
        DoSomething(V?) {
            if (!IsSet(V) || (V == 1)) {
                Arr.Push(V?)
            }
        }
        Array(1, 2, unset, unset).ForEach(DoSomething)

        Arr.Length.Assert(Eq(3))
        Arr[1].Assert(Eq(1))
        Arr.Has(2).Assert(Eq(false))
        Arr.Has(3).Assert(Eq(fAlse))
    }

    static ForEach3() {
        M := Map()
        DoSomething(Key, Value) {
            M[Key] := Value
        }

        Array(1, 2, 3).ForEach(DoSomething, "foo")
        M.Count.Assert(Eq(3))
        M[1].Assert(Eq("foo"))
        M[2].Assert(Eq("foo"))
        M[3].Assert(Eq("foo"))
    }

    static Any() {
        Val := Array(1, 2, 3, 4, 5).Any(  (x) => (x > 3)  )

        Val.Assert(Eq(true))
    }

    static All() {
        Array(1, 2, 3, 4, 5).All(  (x) => (x < 10) ).Assert(Eq(true))
    }

    static None() {
        Array(1, 2, 3, 4, 5).None(  (x) => (x > 10)  ).Assert(Eq(true))
    }
    
    static Poll1() {
        Arr := Array(1, 2, 3)
        Arr.Poll().Assert(Eq(1))
        Arr.Length.Assert(Eq(2))
    }

    static Poll2() {
        Arr := Array(unset, 2, 3)
        this.AssertThrows(() => Arr.Poll())
    }

    static Mismatch_checks_types() {
        L1 := LinkedList(1, 2, 3)
        L2 := LinkedList(1, 2, 3)

        IArray.Mismatch(L1, L2).Assert(Eq(0))

        ; these are not regular `Array`s
        this.AssertThrows(() => Array.Mismatch(L1, L2))
    }
}