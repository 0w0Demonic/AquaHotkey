
class Test_ComValue extends TestSuite {
    static BSTR_ShouldReturn_0x08() {
        ComValue.BSTR.AssertEquals(0x08)
    }

    static BSTR_Construction() {
        Val := ComValue.BSTR("foo", true)
        ComObjType(Val).AssertEquals(0x08)
    }

    static Array_BSTR_ShouldReturn_0x2008() {
        ComObjArray.BSTR.AssertEquals(0x2008)
    }

    static Array_INT64_Construction() {
        C := ComObjArray.INT64(8, 2)
    }

    static ByRef_BSTR_ShouldReturn_0x4008() {
        ComValueRef.BSTR.AssertEquals(0x4008)
    }

    static ByRef_INT64_Construction() {
        Value := 42
        Buf := Buffer(8)
        NumPut("Int64", Value, Buf)

        Ref := ComValueRef.INT64(Buf.Ptr)
        Ref.Get().AssertEquals(Value)
    }

    static ByRef_Setter() {
        Buf := Buffer(8)
        Ref := ComValueRef.INT64(Buf.Ptr).Set(42)
        Ref.Get().AssertEquals(42)
    }

    static ByRef_ShouldResolveBufferObject() {
        Value := 42
        Buf := Buffer(8)
        NumPut("Int64", Value, Buf)

        Ref := ComValueRef.INT64(Buf).Set(Value)
        Ref.Get().AssertEquals(Value)
    }
}
