/**
 * AquaHotkey - Any.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Builtins/Any.ahk
 */
class Any {
    static __Call() {
        ; good enough - trust me bro.
        65.Chr().AssertEquals("A")
    }

    static o0() {
        65.o0(Chr).AssertEquals("A")
    }

    static BindMethod() {
        Arr      := Array()
        ArrPush1 := Arr.BindMethod("Push", 1)

        Loop 5 {
            ArrPush1()
        }

        Arr.Join(" ").AssertEquals("1 1 1 1 1")
    }

    static Type() {
        "Hello world!".Type.AssertEquals("String")
    }

    static Class() {
        "Hello world!".Class.AssertEquals(String)
    }

    static Class2() {
        (String.Prototype).Class.AssertEquals(String)
    }

    static Stream1() {
        Array(1, 2, 3, 4, 5).Stream().AssertType(Stream)
    }

    static Stream2() {
        Array(1, 2, 3, 4, 5).Stream(2).AssertType(Stream)
    }
    
    static Optional() {
        "Hello world!".Optional().AssertType(Optional)
    }
}