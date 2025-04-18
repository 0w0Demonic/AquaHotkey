/**
 * AquaHotkey - Func.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Classes/Func.ahk
 */
class Func {
    static __() {
        ((x, y) => x + (2 * y))
            .__(2)
            .AssertType(BoundFunc)
            .Call(1)
            .AssertEquals(5)
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

    static Tee() {
        Person := {
            FirstName: "John",
            LastName:  "Knee",
            Age:       23
        }
        
        static GetName(Person) {
            return Person.FirstName . " " . Person.LastName
        }

        static IsAdult(Person) {
            return Person.Age >= 18
        }

        static Evaluate(Name, Is18) {
            if (Is18) {
                return Name . " is an adult"
            }
            return Name . " is not an adult"
        }

        f := Func.Tee(GetName, IsAdult, Evaluate)
        f(Person).AssertEquals("John Knee is an adult")
    }

    static Memoized() {
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
}
