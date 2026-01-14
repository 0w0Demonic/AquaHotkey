
class Test_Kwargs extends TestSuite {
    static __New() {
        KwargsTest.Signature := "A / A1 / A2, B, C"
        super.__New()
    }

    static With1() {
        KwargsTest.With({ A: 1, B: 2, C: 3 }).AssertEquals(6)
    }

    static With2() {
        this.AssertThrows(() => KwargsTest.With({ A: 4 }))

        this.AssertThrows(() => KwargsTest.With(
            { A: 1, A1: 2, B: 0, C: 0 }))
    }
}

KwargsTest(A, B, C) => (A + B + C)