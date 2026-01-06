/**
 * AquaHotkey - Gatherer.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Extensions/Gatherer.ahk
 */
class Gatherer {
    static __New() {
        global G := Gatherer
    }

    static TimesTwo() {
        Array(1, 2, 3, 4, 5).Gather(TestSuite.__Gatherer_Times_Two)
                .Join()
                .AssertEquals("1122334455")
    }

    static WindowFixed() {
        Range(100).Stream()
                  .Gather(G.WindowFixed(2))
                  .Map(String)
                  .JoinLine()
    }

    static WindowSliding() {
        Range(8).Stream()
                .Gather(G.WindowSliding(6))
                .Map(Array.Prototype.Join)
                .Join(", ")
                .AssertEquals("123456, 234567, 345678")
    }

    static Scan() {
        Range(4).Gather(G.Scan(() => "", (a, b) => (a . b)))
                .Join(", ")
                .AssertEquals("1, 12, 123, 1234")
    }
}

class __Gatherer_Times_Two extends Gatherer {
    static Initializer() {
        return ""
    }

    static Integrator(_, Downstream, Val) {
        Downstream(Val, Val)
        return true
    }

    static Finisher(*) {

    }
}