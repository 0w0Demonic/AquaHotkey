
class Test_Map extends TestSuite
{
    static Keys() {
        Arr := Map("hotel", "trivago", "apple", "banana").Keys()
        Arr.Length.Assert(Eq(2))
        Arr[1].Assert(Eq("apple"))
        Arr[2].Assert(Eq("hotel"))
    }

    static Values() {
        Arr := Map("hotel", "trivago", "apple", "banana").Values()
        Arr.Length.Assert(Eq(2))
        Arr[1].Assert(Eq("banana"))
        Arr[2].Assert(Eq("trivago"))
    }

    static IsEmpty1() {
        Map().IsEmpty.Assert(Eq(true))
    }

    static IsEmpty2() {
        Map("hello", "world!").IsEmpty.Assert(Eq(false))
    }

    static RetainIf() {
        static KeyAndValueAreEven(Key, Value) {
            return !(Key & 1) && !(Value & 1)
        }
        
        Map(2, 4, 1, 3, 6, 7)
            .RetainIf(KeyAndValueAreEven)
            .Count.Assert(Eq(1))
    }

    static RemoveIf() {
        static KeyAndValueAreEven(Key, Value) {
            return !(Key & 1) && !(Value & 1)
        }

        Map(2, 4, 1, 3, 6, 7)
            .RemoveIf(KeyAndValueAreEven)
            .Count.Assert(Eq(2))
    }

    static Map() {
        static Mapper(Key, Value) {
            return Key + Value
        }
        M := Map(2, 4, 1, 3, 6, 7).ReplaceAll(Mapper)
        M[2].Assert(Eq(6))
        M[1].Assert(Eq(4))
        M[6].Assert(Eq(13))
    }

    static ForEach() {
        static Action(Arr, Key, Value) {
            Arr.Push(Key + Value)
        }

        Arr := Array()
        PushToArr := Action.Bind(Arr)
        Map(2, 4,
            1, 3,
            6, 7).ForEach2(PushToArr)
        Arr.Length.Assert(Eq(3))
        Arr[1].Assert(Eq(4))
        Arr[2].Assert(Eq(6))
        Arr[3].Assert(Eq(13))
    }
    
    static PutIfAbsent1() {
        M := Map(1, 2)
        M.PutIfAbsent(1, 4)
        M[1].Assert(Eq(2))
    }

    static PutIfAbsent2() {
        M := Map(1, 2)
        M.PutIfAbsent(2, 4)
        M[2].Assert(Eq(4))
    }

    static ComputeIfAbsent1() {
        static Mapper(Key) => Key * 2

        M := Map(1, 23)
        M.ComputeIfAbsent(1, Mapper)
        M[1].Assert(Eq(23))
    }

    static ComputeIfAbsent2() {
        static Mapper(Key) => Key * 2

        M := Map(1, 23)
        M.ComputeIfAbsent(2, Mapper)
        M[2].Assert(Eq(4))
    }

    static ComputeIfPresent1() {
        static Mapper(Key, OldValue) => (Key + Oldvalue)

        M := Map(1, 23)
        M.ComputeIfPresent(2, Mapper)
        M.Count.Assert(Eq(1))
    }

    static ComputeIfPresent2() {
        static Mapper(Key, OldValue) => (Key + OldValue)

        M := Map(1, 23)
        M.ComputeIfPresent(1, Mapper)
        M[1].Assert(Eq(24))
    }

    static Compute1() {
        static Mapper(Key, OldValue) => (Key + OldValue)

        M := Map(1, 23)
        M.Compute(1, Mapper)

        M[1].Assert(Eq(24))
    }

    static Compute2() {
        static Mapper(Key, OldValue := 0) => (Key + OldValue)

        M := Map(1, 23)
        M.Compute(2, Mapper)
        M[2].Assert(Eq(2))
    }

    static Merge1() {
        static Mapper(OldValue, NewValue) => (OldValue + NewValue)

        M := Map(1, 23)
        M.Merge(1, 1, Mapper)
        M[1].Assert(Eq(24))
    }

    static Merge2() {
        static Mapper(OldValue, NewValue) => (OldValue + NewValue)

        M := Map(1, 23)
        M.Merge(2, 1, Mapper)
        M[2].Assert(Eq(1))
    }

    static All1() {
        static ValueIsEven(Key, Value) => !(Value & 1)

        Map(1, 2, 2, 4, 4, 8).All2(ValueIsEven).Assert(Eq(true))
    }

    static All2() {
        static ValueIsEven(Key, Value) => !(Value & 1)

        Map(1, 2, 2, 4, 4, 7).All2(ValueIsEven).Assert(Eq(false))
    }

    static Any1() {
        static ValueIsEven(Key, Value) => !(Value & 1)

        Match := Map(1, 1, 3, 3, 5, 6)
            .Any2(ValueIsEven)
            .Assert(Eq(true))
    }

    static Any2() {
        static ValueIsEven(Key, Value) => !(Value & 1)

        Map(1, 1, 3, 3, 5, 5, 7, 7)
            .Any2(ValueIsEven)
            .Assert(Eq(false))
    }

    static None1() {
        static ValueIsEven(Key, Value) => !(Value & 1)

        Map(1, 1, 3, 3, 5, 5).None2(ValueIsEven).Assert(Eq(true))
    }

    static None2() {
        static ValueIsEven(Key, Value) => !(Value & 1)
        
        Map(1, 1, 3, 3, 5, 6).None2(ValueIsEven).Assert(Eq(false))
    }

    static Create_creates_normal_map() {
        Map.Create().AssertType(Map)
    }

    static Create_uses_factory() {
        M := Map()
        Sup := () => M

        Map.Create(Sup).Assert(Eq(M))
    }

    static Create_uses_case_sense() {
        M := Map.Create(false)
        M.Set("a", 1)
        M.Set("A", 2)
        M.Get("a").Assert(Eq(2))
    }

    static Create_throws_on_bad_types() {
        this.AssertThrows(() => Map.Create(() => 34))
        this.AssertThrows(() => CustomMap.Create(Map()))
    }

    static Create_can_return_subtypes() {
        Map.Create(CustomMap)
    }
}

class CustomMap extends Map {

}