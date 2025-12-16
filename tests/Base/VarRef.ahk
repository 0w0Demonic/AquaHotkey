/**
 * AquaHotkey - VarRef.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Builtins/VarRef.ahk
 */
class VarRef {
    static Ptr1() {
        Obj := Object()
        Ref := &Obj

        Ref.Ptr.AssertEquals(ObjPtr(Obj))
    }

    static Ptr2() {
        Str := "Hello, world!"
        Ref := &Str

        Ref.Ptr.AssertEquals(StrPtr(Str))
    }

    static Ptr3() {
        Obj := unset
        Ref := &Obj
        TestSuite.AssertThrows(() => Ref.Ptr)
    }

    static Ptr4() {
        Ref := &(Num := 42)
        TestSuite.AssertThrows(() => Ref.Ptr)
    }
}
