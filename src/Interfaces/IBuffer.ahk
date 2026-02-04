/**
 * @interface
 * @description
 * 
 * An object that holds binary data. This interface requires the object to
 * implement `Ptr` and `Size` properties.
 * 
 * @module  <Interfaces/IBuffer>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class IBuffer {
    ;@region Type Info
    /**
     * Determines whether the buffer is buffer-like.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * Buffer(16, 0).Is(IBuffer)        ; true
     * { Ptr: 0, Size: 16 }.Is(IBuffer) ; true
     */
    static IsInstance(Val?) {
        ; regular `is` semantics
        if (super.IsInstance(Val?)) {
            return true
        }
        ; buffer-like objects, when using `IBuffer.IsInstance(...)`
        return (this == IBuffer)
            && IsSet(Val) && IsObject(Val)
            && HasProp(Val, "Ptr") && HasProp(Val, "Size")
        
    }
    ;@endregion
    
    static __New() {
        static Define := {}.DefineProp
        if (this != IBuffer) {
            return
        }

        ObjSetBase(this,             ObjGetBase(Buffer))
        ObjSetBase(this.Prototype,   ObjGetBase(Buffer.Prototype))
        ObjSetBase(Buffer,           this)
        ObjSetBase(Buffer.Prototype, this.Prototype)

        Proto := this.Prototype
        for T in Array(
                "Char", "UChar", "Short", "UShort",
                "Int", "UInt", "Int64", "UInt64",
                "Float", "Double", "Ptr", "UPtr")
        {
            Define(Proto, "Get" . T, { Call: ObjBindMethod(Get,,, T) })
            Define(Proto, "Put" . T, { Call: ObjBindMethod(Put,,, T) })
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
    GetString(Offset := 0, Encoding := "UTF-16") {
        if (!IsInteger(Offset)) {
            throw TypeError("Expected an Integer",, Type(Offset))
        }
        if (Offset >= this.Size) {
            throw TypeError("Invalid offset for size " . this.Size,, Offset)
        }
        return StrGet(this.Ptr + Offset, this.Size - Offset - 1, Encoding)
    }

    /**
     * Writes a string into the buffer.
     * 
     * @param   {String}      Str       the string to write
     * @param   {Integer?}    Offset    offset in bytes
     * @param   {Primitive?}  Encoding  string encoding
     * @returns {this}
     */
    PutString(Str, Offset := 0, Encoding := "UTF-16") {
        if (!IsInteger(Offset)) {
            throw TypeError("Expected an Integer",, Type(Offset))
        }
        if (Offset >= this.Size) {
            throw ValueError("Invalid offset for size " . this.Size,,
                                Offset)
        }
        StrPut(Str, this.Ptr + Offset, this.Size - Offset, Encoding)
        return this
    }

    /**
     * Fills the buffer with zeros.
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
     * @param   {Integer}  Byte  fill byte
     * @returns {this}
     */
    Fill(Byte) {
        DllCall("RtlFillMemory", "Ptr", this.Ptr, "Ptr", this.Size, "Int", Byte)
        return this
    }

    /**
     * Returns a hexadecimal representation of the buffer.
     * `LineLength` determines the amount of bytes to display per line. If
     * zero, no line breaks are made.
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
                (this.Size                    * (StrLen(Delimiter) + 1))
            + ((this.Size - 1) // LineLength * (StrLen(Delimiter) - 1)))

        if (!LineLength) {
            loop this.Size {
                Out .= Format("{:02X}", NumGet(this, A_Index - 1, "UChar"))
                Out .= Delimiter
            }
            return Out
        }
        
        loop this.Size {
            Out .= Format("{:02X}", NumGet(this, A_Index - 1, "UChar"))
            if (Mod(A_Index, LineLength)) {
                Out .= Delimiter
            } else {
                Out .= "`n"
            }
        }
        return Out
    }

    /**
     * Defines a position in the Buffer as a dynamic property.
     * 
     * @param   {String}   PropertyName  name of the property
     * @param   {String}   NumType       AHK number type
     * @param   {Integer}  Offset        memory offset
     * @returns {this}
     * @example
     * class RECT extends Buffer {
     *     static __New() => this
     *         .Define("Left",  "Int",  0)
     *         .Define("Top",   "Int",  4)
     *         .Define("Right", "Int",  8)
     *         .Define("Bottom" "Int", 12)
     * }
     */
    static Define(PropertyName, NumType, Offset) {
        (this.Prototype).Define(PropertyName, NumType, Offset)
        return this
    }

    /**
     * Defines a position in the Buffer as a dynamic property.
     * This method can also be used directly from the class prototype.
     * 
     * @param   {String}   PropertyName  name of the property
     * @param   {String}   NumType       AHK number type
     * @param   {Integer}  Offset        memory offset
     * @returns {this}
     * @example
     * Buf := Buffer(8).Define("x", "Int", 0).Define("y", "Int", 4)
     * Buf.x := 23
     * Buf.y := 98
     */
    Define(PropertyName, NumType, Offset) {
        if (IsObject(PropertyName)) {
            throw TypeError("Expected a String",, Type(PropertyName))
        }
        if (IsObject(NumType)) {
            throw TypeError("Expected a String",, Type(NumType))
        }
        if (!IsInteger(Offset)) {
            throw TypeError("Expected an Integer",, Type(Offset))
        }
        Buffer.SizeOf(NumType) ; find out whether it's a valid AHK type

        return this.DefineProp(PropertyName, {
            Get: (Buf)        => NumGet(Buf, Offset, NumType),
            Set: (Buf, Value) => NumPut(NumType, Value, Buf, Offset)
        })
    }
}
