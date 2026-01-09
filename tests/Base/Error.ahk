class Test_Error extends TestSuite {
    static staticThrow() {
        Str := "foo"
        try (false || TypeError.Throw(Str))
        catch as Err {
            Err.Message.AssertEquals(Str)
            return
        }
        throw Error("didn't throw")
    }

    static Throw() {
        Str := "foo"
        try {
            ValueError(Str).Throw()
        } catch as Err {
            Err.Message.AssertEquals(Str)
            return
        }
        throw Error("didn't throw")
    }

    static CausedBy() {
        try A()
        catch as Err {
            Msg := Err.Stack
            InStr(Err.Message, "high").AssertNotEquals(false)
            InStr(Err.Cause.Message, "middle").AssertNotEquals(false)
            InStr(Err.Cause.Cause.Message, "low").AssertNotEquals(false)
        }

        static A() {
            try B()
            catch as Err {
                throw UnsetError("high").CausedBy(Err)
            }
        }
        static B() {
            try C()
            catch as Err {
                throw TypeError("middle").CausedBy(Err)
            }
        }
        static C() {
            throw ValueError("low")
        }
    }

    static Cause_throws_when_called_by_prototype() {
        TestSuite.AssertThrows(() => TypeError.Prototype.Cause := Error())
    }
}