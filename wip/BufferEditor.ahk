#Include "%A_LineFile%\..\..\src\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\src\Base\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\src\Base\Buffer.ahk"
#Include "%A_LineFile%\..\..\src\Interfaces\IBuffer.ahk"

; TODO `.Read()` and `.Write()`
; TODO `.RawRead()` and `.RawWrite()`

;@region BufferEditor

/**
 * Class for objects that reads from, and writes numbers into buffers.
 * 
 * @module  <IO/BufferEditor>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class BufferEditor {
    ;@region Fields

    /**
     * The current position in the buffer.
     * 
     * @property {Integer}
     */
    Pos := 0

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Construction

    /**
     * Creates a new buffer writer that wraps over the given {@link IBuffer}.
     * 
     * @constructor
     * @param   {IBuffer?}  Buf  the buffer to wrap over
     * @example
     */
    __New(Buf := Buffer(16, 0)) {
        if (!Buf.Is(IBuffer)) {
            throw TypeError("Expected an IBuffer",, Type(Buf))
        }

        this.DefineProp("Buffer", {
            Get: (_)        => Buf })
        this.DefineProp("Ptr", {
            Get: (_)        => Buf.Ptr,
            Set: (_, Value) => (Buf.Ptr := Value) })
        this.DefineProp("Size", {
            Get: (_)        => Buf.Size,
            Set: (_, Value) => (Buf.Size := Value) })
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Alignment

    /**
     * Moves the current position to the next byte alignment.
     * Only values `2`, `4`, `8` or `16` are allowed.
     * 
     * @param   {Integer}  Boundary  the next byte boundary to align with
     * @example
     * W := Buffer(16, 0).Editor()
     * 
     * W.Align(8)
     * MsgBox(W.Pos) ; 0
     * W.WriteUChar(42)
     * MsgBox(W.Pos) ; 1
     * W.Align(8)
     * MsgBox(W.Pos) ; 8
     */
    Align(Boundary) {
        if (!IsInteger(Boundary)) {
            throw TypeError("Expected an Integer",, Type(Boundary))
        }
        switch (Boundary) {
            case 2, 4, 8, 16:
                this.Pos := (this.Pos + Boundary - 1) & ~(Boundary - 1)
            default:
                throw ValueError("Expected 2, 4, 8, or 16",, Boundary)
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Read/Write Methods

    static __New() {
        if (this != BufferEditor) {
            return
        }
        for Name, Size in Map(
                "Char", 1, "UChar", 1,
                "Short", 2, "UShort", 2,
                "Int", 4, "UInt", 4, "Float", 4,
                "Int64", 8, "UInt64", 8, "Double", 8,
                "Ptr", A_PtrSize, "UPtr", A_PtrSize)
        {
            this.Prototype.DefineProp("Write" . Name, WriteMethod(Name, Size))
            this.Prototype.DefineProp("Read" . Name, ReadMethod(Name, Size))
        }

        static WriteMethod(Name, Size) {
            return { Call: Write }

            Write(this, Value) {
                if (this.Pos + Size > this.Size) {
                    this.Size := Max(this.Size * 2, 16)
                }
                NumPut(Name, Value, this, this.Pos)
                this.Pos += Size
            }
        }

        static ReadMethod(Name, Size) {
            return { Call: Read }

            Read(this) {
                if (this.Pos + Size > this.Size) {
                    return ""
                }
                Value := NumGet(this, this.Pos, Name)
                this.Pos += Size
                return Value
            }
        }
    }
    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

/**
 * Extensions related to {@link BufferEditor}.
 */
class AquaHotkey_BufferEditor extends AquaHotkey {
    class IBuffer {
        /**
         * Creates a {@link BufferEditor} for this buffer.
         * 
         * @returns {BufferEditor}
         */
        Editor() => BufferEditor(this)
    }
}
