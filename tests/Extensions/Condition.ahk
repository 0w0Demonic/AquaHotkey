/**
 * AquaHotkey - Condition.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Extensions/Condition.ahk
 */
class Condition {
    static True() {
        Array(1, 2, 3, 4, 5).RetainIf(  Condition.True  ).Join(", ")
                .AssertEquals("1, 2, 3, 4, 5")
    }
    
    static False() {
        Array(1, 2, 3, 4, 5).RemoveIf(  Condition.False  ).Join(", ")
                .AssertEquals("1, 2, 3, 4, 5")
    }

    static IsNull() {
        Array(1, 2, 3, unset, unset, 4).RetainIf(  Condition.IsNull  )
                .Length.AssertEquals(2)
    }

    static IsNotNull() {
        Array(1, 2, 3, unset, unset, 4).RetainIf(  Condition.IsNotNull  )
                .Length.AssertEquals(4)
    }

    static Equals() {
        Array(1, 2, 3, 4).RetainIf(  Condition.Equals(1)  ).Join()
                .AssertEquals("1")
    }

    static NotEquals() {
        Array("H", "e").RetainIf(  Condition.NotEquals("h")  )
            .Join().AssertEquals("e")
    }

    static StrictEquals() {
        Array("a", "A").RetainIf(  Condition.StrictEquals("a")  )
            .Join().AssertEquals("a")
    }

    static StrictNotEquals() {
        Array("a", "A").RetainIf(  Condition.StrictNotEquals("a")  )
            .Join().AssertEquals("A")
    }

    static Greater() {
        Array(1, 2, 3, 4).RetainIf(  Condition.Gt(2)  )
            .Join().AssertEquals("34")
    }

    static GreaterOrEqual() {
        Array(1, 2, 3, 4).RetainIf(  Condition.Ge(2)  )
            .Join().AssertEquals("234")
    }

    static Less() {
        Array(1, 2, 3, 4).RetainIf(  Condition.Lt(3)  )
            .Join().AssertEquals("12")
    }

    static LessOrEqual() {
        Array(1, 2, 3, 4).RetainIf(  Condition.Le(2)  )
            .Join().AssertEquals("12")
    }

    static Between() {
        Array(1, 2, 3, 4, 5, 6).RetainIf(  Condition.Between(2, 4)  )
            .Join().AssertEquals("234")
    }

    static InStr() {
        Array("Hello", "world!").RetainIf(  Condition.Contains("e")  )
            .Join().AssertEquals("Hello")
    }

    static Matches() {
        Array("Hello", "world!").RetainIf(  Condition.Matches("^\w++$")  )
            .Join().AssertEquals("Hello")
    }

    static DivisibleBy() {
        Range(5).Stream().RetainIf(  Condition.DivisibleBy(2)  )
            .Join().AssertEquals("24")
    }
}