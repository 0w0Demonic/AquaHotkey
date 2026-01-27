class Test_Buffer extends TestSuite
{
    static SizeOf_BasicTest() {
        Buffer.SizeOf("UInt64*").AssertEquals(A_PtrSize)
        Buffer.SizeOf("DoubleP").AssertEquals(A_PtrSize)

        Buffer.SizeOf("UShort").AssertEquals(2)
        Buffer.SizeOf("Double").AssertEquals(8)
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
                .AssertEquals(Str)

        Fn(Buffer)
        Fn(ClipboardAll)
    }

    static OfString() {
        static Fn(Cls) {
            Buf := Cls.OfString("AAA", "UTF-8")
            Buf.AssertType(Cls)
            Buf.HexDump().AssertEquals("41 41 41 00 ")
        }
        Fn(Buffer)
        Fn(ClipboardAll)
    }

    static OfNumber() {
        Buf := Buffer.OfNumber("UShort", 123)
        Buf.Size.AssertEquals(2)
        NumGet(Buf, "UShort").AssertEquals(123)
    }

    static OfNumber_DoesCasting() {
        ClipboardAll.OfNumber("UShort", 123).AssertType(ClipboardAll)
    }

    static FromFile() {
        Buffer.FromFile(A_LineFile).Size.AssertType(Integer).AssertGt(0)
    }

    static GetChar_PutChar() {
        Buf := Buffer(8).PutChar(45, 0)
        Buf.GetChar(0).AssertEquals(45)
    }

    static GetString() {
        Str := "example"
        Size := StrPut(Str, "UTF-16")
        Buf := Buffer(Size)
        StrPut(Str, Buf)
        Buf.GetString().AssertEquals(Str)
    }

    static PutString() {
        Str := "example"
        Size := StrPut(Str, "UTF-16")
        Buf := Buffer(Size)

        Buf.PutString(Str)
        Buf.GetString().AssertEquals(Str)
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
        NumGet(Slice, "Int").AssertEquals(123)
    }

    static Zero() {
        Buf := Buffer.OfString("example").Zero()
        NumGet(Buf, "UInt64").AssertEquals(0)
    }

    static Fill() {
        Buf := Buffer.OfString("example").Fill(42)
        NumGet(Buf, "Char").AssertEquals(42)
    }

    static HexDump() {
        Size := 4
        Buf := Buffer(Size)
        Loop Size {
            NumPut("Char", 0x41, Buf, A_Index - 1)
        }
        Buf.HexDump().AssertEquals("41 41 41 41 ")
    }

    static staticDefine() {
        Buffer.Define("Left", "Int", 0)

        Buf := Buffer(16)
        Buf.Left := 42
        NumGet(Buf, 0, "Int").AssertEquals(42)
    }

    static Define() {
        Buf := Buffer(16)

        Buf.Define("Bottom", "Int", 8)
        Buf.AssertHasOwnProp("Bottom")
        Buf.Bottom := 99

        NumGet(Buf, 8, "Int").AssertEquals(99)
        Buf.Bottom.AssertEquals(99)
    }

    static Define_OnPrototype() {
        Buffer.Prototype.Define("Top", "Int", 4)

        Buf := Buffer(16)
        Buf.Top := 22
        NumGet(Buf, 4, "Int").AssertEquals(22)
        Buf.Top.AssertEquals(22)
    }
}