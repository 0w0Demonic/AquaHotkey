
class Gatherer {
    static TimesTwo() {
        Array(1, 2, 3, 4, 5).Gather(Gatherer(
            () => "",
            (Arr, Downstream, Num) => Downstream(Num, Num) || true,
            (Arr, Downstream) => ""
        ))
        .Join()
        .AssertEquals("1122334455")
    }

    static Windows() {
        SlidingWindows := Gatherer(Init, Integ, Fin)
        Range(100).Stream().Gather(SlidingWindows).Map(String).JoinLine().MsgBox()

        Init() {
            return Array()
        }

        Integ(State, Downstream, Num) {
            if (State.Length == 3) {
                Downstream(State.Clone())
                State.Length := 0
            } else {
                State.Push(Num)
            }
            return true
        }

        Fin(State, Downstream) {
            Downstream(State)
        }
    }
}