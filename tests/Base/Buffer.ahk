class Test_Buffer extends TestSuite
{
    static SizeOf_BasicTest() {
        Buffer.SizeOf("UInt64*").Assert(Eq(A_PtrSize))
        Buffer.SizeOf("DoubleP").Assert(Eq(A_PtrSize))

        Buffer.SizeOf("UShort").Assert(Eq(2))
        Buffer.SizeOf("Double").Assert(Eq(8))
    }

    static SizeOf_ThrowsOnBadType() {
        this.AssertThrows(() => Buffer.SizeOf("invalid"))
    }

    static SizeOf_NoUnsignedFloats() {
        this.AssertThrows(() => Buffer.SizeOf("UFloat"))
        this.AssertThrows(() => Buffer.SizeOf("UDouble"))
    }

    static FromMemory() {
        static Str := "foo"
        static Fn(Cls) => Cls
                .FromMemory(StrPtr(Str), StrPut(Str))
                .GetString()
                .Assert(Eq(Str))

        Fn(Buffer)
        Fn(ClipboardAll)
    }

    static OfString() {
        static Fn(Cls) {
            Buf := Cls.OfString("AAA", "UTF-8")
            Buf.AssertType(Cls)
            Buf.HexDump().Assert(Eq("41 41 41 00 "))
        }
        Fn(Buffer)
        Fn(ClipboardAll)
    }

    static OfNumber() {
        Buf := Buffer.OfNumber("UShort", 123)
        Buf.Size.Assert(Eq(2))
        NumGet(Buf, "UShort").Assert(Eq(123))
    }

    static OfNumber_DoesCasting() {
        ClipboardAll.OfNumber("UShort", 123).AssertType(ClipboardAll)
    }

    static FromFile() {
        Buffer.FromFile(A_LineFile).Size.AssertType(Integer).Assert(Gt(0))
    }

    static GetChar_PutChar() {
        Buf := Buffer(8).PutChar(45, 0)
        Buf.GetChar(0).Assert(Eq(45))
    }

    static GetString() {
        Str := "example"
        Size := StrPut(Str, "UTF-16")
        Buf := Buffer(Size)
        StrPut(Str, Buf)
        Buf.GetString().Assert(Eq(Str))
    }

    static PutString() {
        Str := "example"
        Size := StrPut(Str, "UTF-16")
        Buf := Buffer(Size)

        Buf.PutString(Str)
        Buf.GetString().Assert(Eq(Str))
    }

    static PutString_ThrowsOnBadInput() {
        this.AssertThrows(() => Buffer(4).PutString(
                "the quick brown fox jumps over the lazy dog"))

        this.AssertThrows(() => Buffer(8).PutString("foo", 6))
    }

    static Slice() {
        Buf := Buffer(8, 0)
        NumPut("Int", 123, Buf)
        NumPut("Int", 456, Buf, 4)

        Slice := Buf.Slice(0, 4)
        NumGet(Slice, "Int").Assert(Eq(123))
    }

    static Zero() {
        Buf := Buffer.OfString("example").Zero()
        NumGet(Buf, "UInt64").Assert(Eq(0))
    }

    static Fill() {
        Buf := Buffer.OfString("example").Fill(42)
        NumGet(Buf, "Char").Assert(Eq(42))
    }

    static HexDump() {
        Size := 4
        Buf := Buffer(Size)
        Loop Size {
            NumPut("Char", 0x41, Buf, A_Index - 1)
        }
        Buf.HexDump().Assert(Eq("41 41 41 41 "))
    }

    static staticDefine() {
        Buffer.Define("Left", "Int", 0)

        Buf := Buffer(16)
        Buf.Left := 42
        NumGet(Buf, 0, "Int").Assert(Eq(42))
    }

    static Define() {
        Buf := Buffer(16)

        Buf.Define("Bottom", "Int", 8)
        Buf.Assert(ObjHasOwnProp, "Bottom")
        Buf.Bottom := 99

        NumGet(Buf, 8, "Int").Assert(Eq(99))
        Buf.Bottom.Assert(Eq(99))
    }

    static Define_OnPrototype() {
        Buffer.Prototype.Define("Top", "Int", 4)

        Buf := Buffer(16)
        Buf.Top := 22
        NumGet(Buf, 4, "Int").Assert(Eq(22))
        Buf.Top.Assert(Eq(22))
    }
}