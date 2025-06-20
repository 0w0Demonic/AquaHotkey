/**
 * AquaHotkey - Func.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Builtins/Func.ahk
 */
class Func {
    static Constantly() {
        Range(5).Stream().Map(  Func.Constantly(15)  ).Join(", ")
                .AssertEquals("15, 15, 15, 15, 15")
    }

    static AndThen() {
        ((x, y) => (x + y))
            .AndThen(Result => Result * 2)
            .Call(2, 3)
            .AssertEquals(10)
    }

    static Compose() {
        ((Result => Result * 2))
            .Compose((x, y) => (x + y))
            .Call(2, 3)
            .AssertEquals(10)
    }

    static Memoized1() {
        FibonacciSequence(N) {
            if (N > 1) {
                return Memo(N - 1) + Memo(N - 2)
            }
            return 1
        }
        Memo := FibonacciSequence.Memoized()

        ; 100ms max time for calculation, which is not enough if this function
        ; runs at O(2^n)
        SetTimer(() => (IsSet(Result) || Timeout()))
        Result := FibonacciSequence(80)

        Timeout() {
            if (!IsSet(Result)) {
                throw TimeoutError("timeout")
            }
        }
    }

    static Memoized2() {
        static Identity(x) => x

        Cache1 := TestSuite.CustomMap()
        Cache2 := TestSuite.CustomMap() 

        Cache1.CaseSense := true
        Cache2.CaseSense := false

        Memoized1 := Identity.Memoized(unset, Cache1)
        Memoized2 := Identity.Memoized(unset, Cache2)

        Memoized1("a")
        Memoized1("A")

        Memoized2("a")
        Memoized2("A")

        Cache1.Hits.AssertEquals(0)
        Cache2.Hits.AssertEquals(1)
    }
}

class CustomMap extends Map {
    Hits := 0

    Get(Key, DefaultValue?) {
        this.Hits++
        return super.Get(Key, DefaultValue?)
    }
    
    __Item[Key] {
        get {
            ++this.Hits
            return super[Key]
        }
    }
}
