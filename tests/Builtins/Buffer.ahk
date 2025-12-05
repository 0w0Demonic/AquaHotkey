/**
 * AquaHotkey - Buffer.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Builtins/Buffer.ahk
 */
class Buffer {
    static GetChar_PutChar() {
        Buf := Buffer(8).PutChar(45, 0)
        Buf.GetChar(0).AssertEquals(45)
    }

    static HexDump() {
        Size := 4
        Buf := Buffer(Size)
        Loop Size {
            NumPut("Char", 0x41, Buf, A_Index - 1)
        }
        Buf.HexDump().AssertEquals("41 41 41 41 ")
    }

    static OfString() {
        Buffer.OfString("AAA", "UTF-8").HexDump().AssertEquals("41 41 41 00 ")
    }
}
