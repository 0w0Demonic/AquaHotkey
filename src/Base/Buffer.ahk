#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

; TODO remove this again
#Include <AquaHotkey\src\Interfaces\IBuffer>

; TODO different buffer view types?

/**
 * Buffer utilities.
 * 
 * @module  <Base/Buffer>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Buffer extends AquaHotkey
{
    ;@region Buffer
    class Buffer {
        ;@region AHK Number Types
        /**
         * Returns the size of the AHK number type in bytes.
         * 
         * @param   {String}  NumType  AHK number type
         * @returns {Integer}
         */
        static SizeOf(NumType) {
            ; TODO move this somewhere else?
            static NumTypes := Init()
            static Init() {
                M := Map()
                M.CaseSense := false

                Int("Char",   1)
                Int("Short",  2)
                Int("Int",    4)
                Int("Int64",  8)
                Flt("Float",  4)
                Flt("Double", 8)
                Int("Ptr", A_PtrSize)

                Int(Name, Size) {
                    Fill(Name, Size)
                    Fill("U" . Name, Size)
                }
                Flt(Name, Size) => Fill(Name, Size)

                Fill(Num, Size) => M.Set(
                    Num,       Size,
                    Num . "P", A_PtrSize,
                    Num . "*", A_PtrSize)

                return M
            }

            if (IsObject(NumType)) {
                throw TypeError("Expected a String",, Type(NumType))
            }
            Result := NumTypes.Get(NumType, false)
            if (!Result) {
                throw ValueError("Invalid number type",, NumType)
            }
            return Result
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Static Constructors

        /**
         * Creates a Buffer from memory.
         * 
         * @param   {Integer}  Ptr   the address of the binary data
         * @param   {Integer}  Size  the number of bytes
         * @returns {Buffer}
         * @example
         * Buffer.FromMemory(StrPtr("foo"), StrPut("foo"))
         */
        static FromMemory(Ptr, Size) {
            if (!IsInteger(Ptr)) {
                throw TypeError("Expected an Integer",, Type(Ptr))
            }
            if (!IsInteger(Size)) {
                throw TypeError("Expected an Integer",, Type(Size))
            }

            if ((this == ClipboardAll) || HasBase(this, ClipboardAll)) {
                Buf := ClipboardAll(Ptr, Size)
            } else {
                Buf := Buffer(Size)
                DllCall("RtlCopyMemory",
                        "Ptr", Buf.Ptr,
                        "Ptr", Ptr,
                        "UPtr", Size)
            }
            ObjSetBase(Buf, this.Prototype)
            return Buf
        }

        /**
         * Returns a buffer entirely containing the given string.
         * 
         * @example
         * Buf := Buffer.OfString("foo", "UTF-8")
         * 
         * @param   {String}      Str       any string
         * @param   {Primitive?}  Encoding  string encoding
         * @returns {Buffer}
         */
        static OfString(Str, Encoding := "UTF-16") {
            Size := StrPut(Str, Encoding)
            Buf := Buffer(Size)
            StrPut(Str, Buf, Encoding)
            if ((this == ClipboardAll) || HasBase(this, ClipboardAll)) {
                Buf := ClipboardAll(Buf)
            }
            ObjSetBase(Buf, this.Prototype)
            return Buf
        }

        /**
         * Returns a buffer containing the given AHK number type.
         * 
         * Relies on `Buffer.SizeOf(NumType)` to determine the byte size of the
         * AHK number type.
         * 
         * @param   {String}   NumType  AHK number type
         * @param   {Number?}  Value    value of the number
         * @returns {Buffer}
         * @example
         * Buf := Buffer.OfNumber("Ptr", Ptr)
         * Buf := Buffer.OfNumber("Int64")
         */
        static OfNumber(NumType, Value := 0) {
            Size := Buffer.SizeOf(NumType)
            Buf := Buffer(Size)
            NumPut(NumType, Value, Buf)
            if ((this == ClipboardAll) || HasBase(this, ClipboardAll)) {
                Buf := ClipboardAll(Buf)
            }
            ObjSetBase(Buf, this.Prototype)
            return Buf
        }

        /**
         * Creates a new Buffer by reading from the given file.
         * 
         * @param   {String}      FilePath  file path to read from
         * @param   {Primitive?}  Encoding  file encoding
         * @returns {Buffer}
         */
        static FromFile(FilePath, Encoding := A_FileEncoding) {
            Buf := FileRead(FilePath, "RAW")
            if ((this == ClipboardAll) || HasBase(this, ClipboardAll)) {
                Buf := ClipboardAll(Buf)
            }
            ObjSetBase(Buf, this.Prototype)
            return Buf
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Slicing and Filling

        ; TODO move this method elsewhere?
        /**
         * Returns a new buffer containing a subsection of the current buffer.
         * 
         * @param   {Integer}  Offset  offset in bytes
         * @param   {Integer}  Size  length of the subsection
         * @returns {Buffer}
         */
        Slice(Offset, Size) {
            if (!IsInteger(Offset)) {
                throw TypeError("Expected an Integer",, Type(Offset))
            }
            if (!IsInteger(Size)) {
                throw TypeError("Expected an Integer",, Type(Size))
            }
            if (Size <= 0) {
                throw ValueError("Size must be greater than zero",, Size)
            }
            if (Offset + Size > this.Size) {
                throw ValueError("Invalid offset for size " . this.Size,,
                                 "offset: " . Offset . ", length: " . Size)
            }
            
            Ptr := (this.Ptr + Offset)
            if (this is ClipboardAll) {
                Buf := ClipboardAll(Ptr, Size)
            } else {
                Buf := Buffer(Size)
                DllCall("RtlCopyMemory",
                        "Ptr", Buf.Ptr,
                        "Ptr", Ptr,
                        "UPtr", Size)
            }
            ObjSetBase(Buf, ObjGetBase(this))
            return Buf
        }

        ;@endregion
    } ; class Buffer

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region ClipboardAll

    class ClipboardAll {
        /**
         * Assigns the contents of the `ClipboardAll` to the system clipboard.
         * 
         * @returns {this}
         */
        ToClipboard() {
            A_Clipboard := this
            return this
        }
    }
    ;@endregion
}
