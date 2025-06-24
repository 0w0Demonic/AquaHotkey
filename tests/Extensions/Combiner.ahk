/**
 * AquaHotkey - Combiner.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Extensions/Combiner.ahk
 */
class Combiner {
    static Sum() {
        Array(1, 2, 3, 4).Reduce(  Combiner.Sum  ).AssertEquals(10)
    }

    static Product() {
        Array(1, 2, 3, 4).Reduce(  Combiner.Product  ).AssertEquals(24)
    }

    static Concat1() {
        Array(1, 2, 3, 4).Reduce(  Combiner.Concat  ).AssertEquals("1234")
    }

    static Concat2() {
        Array(1, 2, 3, 4).Reduce(  Combiner.Concat("_")  )
                .AssertEquals("1_2_3_4")
    }

    static Min1() {
        Array(1, 2, 3, 4).Reduce(  Combiner.Min  ).AssertEquals(1)
    }

    static Min2() {
        Array(1, 2, 3, 4).Reduce(  Combiner.Min(Comparator.Numeric)  )
                .AssertEquals(1)
    }

    static Max1() {
        Array(1, 2, 3, 4).Reduce(  Combiner.Max  ).AssertEquals(4)
    }
    
    static Max2() {
        Array(1, 2, 3, 4).Reduce(  Combiner.Max(Comparator.Numeric)  )
                .AssertEquals(4)
    }

    static First() {
        Array(1, 2, 3, 4).Reduce(  Combiner.First  ).AssertEquals(1)
    }

    static Last() {
        Array(1, 2, 3, 4).Reduce(  Combiner.Last  ).AssertEquals(4)
    }
}