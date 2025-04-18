/**
 * AquaHotkey - Class.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Classes/Class.ahk
 */
class Class {
    static __Call() {
        TestSuite.AssertThrows(() => (
            String.UnsetProperty()
        ))
    }

    static ForName() {
        Class.ForName("String").AssertEquals(String)
    }
}
