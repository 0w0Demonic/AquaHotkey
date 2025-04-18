/**
 * AquaHotkey - Any.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Classes/Any.ahk
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

    static Store1() {
        ("Hello, world!").Store(&Result)

        Result.AssertEquals("Hello, world!")
    }

    static Store2() {
        Obj := Object().Store(&Copy)
        Obj.DefineProp("Age", { Value: 12 })
        HasProp(Copy, "Age").AssertEquals(false)
    }

    static Store3() {
        SubStr.Bind("Hello, world!").Store(&Copy).Call(1, 1).AssertEquals("H")
        Copy.AssertType(BoundFunc)
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

    static AssertNumber1() {
        (912.12).AssertNumber()
    }

    static AssertNumber2() {
        "912.12".AssertNumber().AssertType(Float)
    }

    static AssertInteger1() {
        (123).AssertInteger()
    }

    static AssertInteger2() {
        "123".AssertInteger().AssertType(Integer)
    }

    static AssertCallable1() {
        ({ Call: (Obj) => MsgBox("Hello world!") }).AssertCallable()
    }

    static AssertCallable2() {
        TestSuite.AssertThrows(() => (
            InStr.AssertCallable(0)
        ))
    }
}