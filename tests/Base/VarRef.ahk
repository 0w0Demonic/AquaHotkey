class Test_VarRef extends TestSuite
{
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
        this.AssertThrows(() => Ref.Ptr)
    }

    static Ptr4() {
        Ref := &(Num := 42)
        this.AssertThrows(() => Ref.Ptr)
    }
}
