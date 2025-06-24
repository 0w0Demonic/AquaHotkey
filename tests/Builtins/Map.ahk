/**
 * AquaHotkey - Map.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/Sphinx
 * - tests/Builtins/Map.ahk
 */
class Map {
    static Default_Capacity_CaseSense() {
        M := Map().SetDefault("(empty)").SetCapacity(128).SetCaseSense(false)
        M.Default.AssertEquals("(empty)")
        M.Capacity.AssertEquals(128)
        M.CaseSense.AssertEquals("Off")
    }

    static Keys() {
        Arr := Map("hotel", "trivago", "apple", "banana").Keys()
        Arr.Length.AssertEquals(2)
        Arr[1].AssertEquals("apple")
        Arr[2].AssertEquals("hotel")
    }

    static Values() {
        Arr := Map("hotel", "trivago", "apple", "banana").Values()
        Arr.Length.AssertEquals(2)
        Arr[1].AssertEquals("banana")
        Arr[2].AssertEquals("trivago")
    }

    static IsEmpty1() {
        Map().IsEmpty.AssertEquals(true)
    }

    static IsEmpty2() {
        Map("hello", "world!").IsEmpty.AssertEquals(false)
    }

    static RetainIf() {
        static KeyAndValueAreEven(Key, Value) {
            return !(Key & 1) && !(Value & 1)
        }
        
        Map(2, 4, 1, 3, 6, 7)
            .RetainIf(KeyAndValueAreEven)
            .Count.AssertEquals(1)
    }

    static RemoveIf() {
        static KeyAndValueAreEven(Key, Value) {
            return !(Key & 1) && !(Value & 1)
        }

        Map(2, 4, 1, 3, 6, 7)
            .RemoveIf(KeyAndValueAreEven)
            .Count.AssertEquals(2)
    }

    static Map() {
        static Mapper(Key, Value) {
            return Key + Value
        }
        M := Map(2, 4, 1, 3, 6, 7).ReplaceAll(Mapper)
        M[2].AssertEquals(6)
        M[1].AssertEquals(4)
        M[6].AssertEquals(13)
    }

    static ForEach() {
        static Action(Arr, Key, Value) {
            Arr.Push(Key + Value)
        }

        Arr := Array()
        PushToArr := Action.Bind(Arr)
        Map(2, 4, 1, 3, 6, 7).ForEach(PushToArr)
        Arr.Length.AssertEquals(3)
        Arr[1].AssertEquals(4)
        Arr[2].AssertEquals(6)
        Arr[3].AssertEquals(13)
    }
    
    static PutIfAbsent1() {
        M := Map(1, 2).PutIfAbsent(1, 4)
        M[1].AssertEquals(2)
    }

    static PutIfAbsent2() {
        M := Map(1, 2).PutIfAbsent(2, 4)
        M[2].AssertEquals(4)
    }

    static ComputeIfAbsent1() {
        static Mapper(Key) => Key * 2

        M := Map(1, 23).ComputeIfAbsent(1, Mapper)
        M[1].AssertEquals(23)
    }

    static ComputeIfAbsent2() {
        static Mapper(Key) => Key * 2

        M := Map(1, 23).ComputeIfAbsent(2, Mapper)
        M[2].AssertEquals(4)
    }

    static ComputeIfPresent1() {
        static Mapper(Key, OldValue) => (Key + Oldvalue)

        M := Map(1, 23).ComputeIfPresent(2, Mapper)
        M.Count.AssertEquals(1)
    }

    static ComputeIfPresent2() {
        static Mapper(Key, OldValue) => (Key + OldValue)

        M := Map(1, 23).ComputeIfPresent(1, Mapper)
        M[1].AssertEquals(24)
    }

    static Compute1() {
        static Mapper(Key, OldValue) => (Key + OldValue)

        M := Map(1, 23).Compute(1, Mapper)
        M[1].AssertEquals(24)
    }

    static Compute2() {
        static Mapper(Key, OldValue := 0) => (Key + OldValue)

        M := Map(1, 23).Compute(2, Mapper)
        M[2].AssertEquals(2)
    }

    static Merge1() {
        static Mapper(OldValue, NewValue) => (OldValue + NewValue)

        M := Map(1, 23).Merge(1, 1, Mapper)
        M[1].AssertEquals(24)
    }

    static Merge2() {
        static Mapper(OldValue, NewValue) => (OldValue + NewValue)

        M := Map(1, 23).Merge(2, 1, Mapper)
        M[2].AssertEquals(1)
    }

    static AllMatch() {
        static ValueIsEven(Key, Value) => !(Value & 1)

        Map(1, 2, 2, 4, 4, 8).AllMatch(ValueIsEven).AssertEquals(true)
    }

    static AllMatch2() {
        static ValueIsEven(Key, Value) => !(Value & 1)

        Map(1, 2, 2, 4, 4, 7).AllMatch(ValueIsEven).AssertEquals(false)
    }

    static AnyMatch1() {
        static ValueIsEven(Key, Value) => !(Value & 1)

        Match := Map(1, 1, 3, 3, 5, 6)
            .AnyMatch(ValueIsEven)
            .AssertType(Object)

        Match.Key.AssertEquals(5)
        Match.Value.AssertEquals(6)
    }

    static AnyMatch2() {
        static ValueIsEven(Key, Value) => !(Value & 1)

        Map(1, 1, 3, 3, 5, 5, 7, 7)
            .AnyMatch(ValueIsEven)
            .AssertEquals(false)
    }

    static NoneMatch1() {
        static ValueIsEven(Key, Value) => !(Value & 1)

        Map(1, 1, 3, 3, 5, 5).NoneMatch(ValueIsEven).AssertEquals(true)
    }

    static NoneMatch2() {
        static ValueIsEven(Key, Value) => !(Value & 1)
        
        Map(1, 1, 3, 3, 5, 6).NoneMatch(ValueIsEven).AssertEquals(false)
    }
}

