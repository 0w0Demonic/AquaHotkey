#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
/**
 * Buffer utilities.
 * 
 * @module  <Base/Buffer>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Buffer extends AquaHotkey
{
;-------------------------------------------------------------------------------
;@region Buffer

class Buffer {
    ;@region AHK Number Types

    ; TODO move this somewhere else?

    /**
     * Returns the size of the AHK number type in bytes.
     * 
     * @param   {String}  NumType  AHK number type
     * @returns {Integer}
     */
    static SizeOf(NumType) {
        static NumTypes := Init()
        static Init() {
            M := Map()
            M.CaseSense := false
            M.Default := false

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
        Result := NumTypes.Get(NumType)
        if (!Result) {
            throw ValueError("Invalid number type",, NumType)
        }
        return Result
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Static Constructors

    /**
     * Creates a new zero-filled buffer with the given size in bytes.
     * 
     * @param   {Integer}  Size  size in bytes
     * @returns {Buffer}
     */
    static Zero(Size) {
        ObjSetBase(Buf := Buffer(Size, 0), this.Prototype)
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
    static OfString(Str, Encoding?) {
        if (IsObject(Str)) {
            throw TypeError("Expected a String, but received an Object",,
                            Type(Str))
        }
        ; StrPut(Str, Encoding?) causes some weird issues, need to
        ; explicitly check `IsSet(Encoding)`.
        if (IsSet(Encoding)) {
            Buf := Buffer(StrPut(Str, Encoding))
            StrPut(Str, Buf, Encoding)
            return Buf
        }
        if (IsObject(Encoding)) {
            throw TypeError("Expected a String or an Integer",,
                            Type(Encoding))
        }
        Buf := Buffer(StrPut(Str))
        StrPut(Str, Buf)
        return Buf
    }

    /**
     * Returns a buffer containing the given AHK number type.
     * 
     * Relies on `Buffer.SizeOf(NumType)` to determine the byte size of the
     * AHK number type.
     * 
     * @param   {String}  NumType  AHK number type
     * @param   {Number}  Value    value of the number
     * @returns {Buffer}
     */
    static OfNumber(NumType, Value) {
        Size := Buffer.SizeOf(NumType)
        Buf := Buffer(Size)
        NumPut(NumType, Value, Buf)
        ObjSetBase(Buf, this.Prototype)
        return Buf
    }

    /**
     * Creates a new Buffer by reading from the given file.
     * 
     * @param   {String}  FilePath  file path to read from
     * @returns {Buffer}
     */
    static FromFile(FilePath) {
        if (IsObject(FilePath)) {
            throw TypeError("Expected a file path",, Type(FilePath))
        }
        if (!FileExist(FilePath)) {
            throw TargetError("File not found",, FilePath)
        }
        ObjSetBase(Buf := FileRead(FilePath, "RAW"), this.Prototype)
        return Buf
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Read/Write Methods

    ; setup for Get<NumType>/Put<NumType> methods
    static __New() {
        static Define := (Object.Prototype.DefineProp)

        Proto := this.Prototype
        for T in Array(
                "Char", "UChar", "Short", "UShort",
                "Int", "UInt", "Int64", "UInt64",
                "Float", "Double", "Ptr", "UPtr")
        {
            Define(Proto, "Get" . T, { Call: Get.Bind(unset, T) })
            Define(Proto, "Write" . T, { Call: Put.Bind(unset, T) })
        }

        static Get(Buf, NumType, Offset := 0) {
            return NumGet(Buf, Offset, NumType)
        }

        static Put(Buf, NumType, Value, Offset := 0) {
            NumPut(NumType, Value, Buf, Offset)
            return Buf
        }
    }

    /**
     * Reads a <NumType> from this Buffer.
     * 
     * @param   {Integer?}  Offset  byte offset
     * @returns {Number}
     */

    ; Get<NumType>(Offset := 0) { ... }

    /**
     * Writes a <NumType> into the Buffer.
     * 
     * @param   {Number}    Value   <NumType> value to write
     * @param   {Integer?}  Offset  byte offset
     * @returns {this}
     */

    ; Put<NumType>(Value, Offset := 0) { ... }

    /**
     * Reads a string from the buffer.
     * 
     * @param   {Integer?}    Offset    memory offset in bytes
     * @param   {Primitive?}  Encoding  string encoding
     * @returns {String}
     */
    GetString(Offset := 0, Encoding := A_FileEncoding) {
        if (!IsInteger(Offset)) {
            throw TypeError("Expected an Integer",, Type(Offset))
        }
        if (Offset >= this.Size) {
            throw TypeError("Invalid offset for buffer of size " . this.Size,,
                            Offset)
        }
        if (IsObject(Encoding)) {
            throw TypeError("Expected a String or an Integer",,
                            Type(Encoding))
        }
        return StrGet(this.Ptr + Offset, this.Size - Offset - 1, Encoding?)
    }

    /**
     * Writes a string into the buffer.
     * 
     * @param   {String}      Str       the string to write
     * @param   {Integer?}    Offset    offset in bytes
     * @param   {Primitive?}  Encoding  string encoding
     * @returns {this}
     */
    PutString(Str, Offset := 0, Encoding?) {
        if (IsObject(Str)) {
            throw TypeError("Expected a String",, Type(Str))
        }
        if (!IsInteger(Offset)) {
            throw TypeError("Expected an Integer",, Type(Str))
        }
        if (Offset >= this.Size) {
            throw ValueError("Invalid offset for buffer of size " . this.Size,,
                             Offset)
        }
        if (!IsSet(Encoding)) {
            StrPut(Str, this.Ptr + Offset, this.Size - Offset)
            return this
        }
        if (IsObject(Encoding)) {
            throw TypeError("Expected a String or an Integer",,
                            Type(Encoding))
        }
        StrPut(Str, this.Ptr + Offset, this.Size - Offset, Encoding)
        return this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Slicing and Filling

    /**
     * Returns a new buffer containing a subsection of the current buffer.
     * 
     * @param   {Integer}  Offset  offset in bytes
     * @param   {Integer}  Length  length of the subsection
     * @returns {Buffer}
     */
    Slice(Offset, Length) {
        if (!IsInteger(Offset)) {
            throw TypeError("Expected an Integer",, Type(Offset))
        }
        if (!IsInteger(Length)) {
            throw TypeError("Expected an Integer",, Type(Length))
        }
        if (Length >= 0) {
            throw ValueError("Length must be greater than zero",, Length)
        }
        if (Offset + Length > this.Size) {
            throw ValueError("Invalid offset for buffer of size " . this.Size,,
                             "offset: " . Offset . ", length: " . Length)
        }
        ObjSetBase(Buf := ClipboardAll(this.Ptr + Offset, Length),
                   ObjGetBase(this))
        return Buf
    }

    /**
     * Fills this buffer with zeros.
     * 
     * @returns {this}
     */
    Zero() {
        DllCall("RtlZeroMemory", "Ptr", this.Ptr, "Ptr", this.Size)
        return this
    }

    /**
     * Fills the buffer with the given byte value.
     * 
     * @param   {Integer}  Value
     * @returns {this}
     */
    Fill(Value) {
        DllCall("RtlFillMemory",
                "Ptr", this.Ptr,
                "Ptr", this.Size,
                "Int", Value)
        return this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Dump

    /**
     * Returns a hexadecimal representation of the buffer.
     * `LineLength` determines the amount of bytes to display per line. If zero,
     * no line breaks are made.
     * 
     * @example
     * Buffer.OfString("foo", "UTF-8").HexDump() ; "66 6F 6F 00"
     * 
     * @param   {String?}   Delimiter   separator string
     * @param   {Integer?}  LineLength  amount of bytes per line
     * @returns {String}
     */
    HexDump(Delimiter := A_Space, LineLength := 16) {
        if (IsObject(Delimiter)) {
            throw TypeError("Expected a String",, Delimiter)
        }
        if (!IsInteger(LineLength)) {
            throw TypeError("Expected an Integer",, Type(LineLength))
        }
        if (LineLength < 0) {
            throw ValueError("LineLength < 0",, LineLength)
        }

        VarSetStrCapacity(&Out,
                (this.Size                     * (StrLen(Delimiter) + 1))
              + ((this.Size - 1) // LineLength * (StrLen(Delimiter) - 1)))

        if (!LineLength) {
            Loop this.Size {
                Out .= Format("{:02X}", NumGet(this, A_Index - 1, "UChar"))
                Out .= Delimiter
            }
            return Out
        }
        
        Loop this.Size {
            Out .= Format("{:02X}", NumGet(this, A_Index - 1, "UChar"))
            if (Mod(A_Index, LineLength)) {
                Out .= Delimiter
            } else {
                Out .= "`n"
            }
        }
        return Out
    }

    ;@endregion
} ; class Buffer

;@endregion
;-------------------------------------------------------------------------------
;@region ClipboardAll

class ClipboardAll {
    /**
     * Assigns the contents of the `ClipboardAll` to the system clipboard.
     */
    ToClipboard() {
        A_Clipboard := this
        return this
    }
} ; class ClipboardAll
;@endregion

} ; class AquaHotkey_Buffer extends AquaHotkey
