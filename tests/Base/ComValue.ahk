
class Test_ComValue extends TestSuite {
    static BSTR_ShouldReturn_0x08() {
        ComValue.BSTR.Assert((Eq(0x08)))
    }

    static BSTR_Construction() {
        Val := ComValue.BSTR("foo", true)
        ComObjType(Val).Assert(Eq(0x08))
    }

    static Array_BSTR_ShouldReturn_0x2008() {
        ComObjArray.BSTR.Assert(Eq(0x2008))
    }

    static Array_INT64_Construction() {
        C := ComObjArray.INT64(8, 2)
    }

    static ByRef_BSTR_ShouldReturn_0x4008() {
        ComValueRef.BSTR.Assert(Eq(0x4008))
    }

    static ByRef_INT64_Construction() {
        Value := 42
        Buf := Buffer(8)
        NumPut("Int64", Value, Buf)

        Ref := ComValueRef.INT64(Buf.Ptr)
        Ref.Get().Assert(Eq(Value))
    }

    static ByRef_Setter() {
        Buf := Buffer(8)
        Ref := ComValueRef.INT64(Buf.Ptr).Set(42)
        Ref.Get().Assert(Eq(42))
    }

    static ByRef_ShouldResolveBufferObject() {
        Value := 42
        Buf := Buffer(8)
        NumPut("Int64", Value, Buf)

        Ref := ComValueRef.INT64(Buf).Set(Value)
        Ref.Get().Assert(Eq(Value))
    }
}