#Include "%A_LineFile%\..\..\Base\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\Collections\ByteArray.ahk"
#Include "%A_LineFile%\..\IArray.ahk"

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
    ;---------------------------------------------------------------------------
    ;@region Serialization

    /**
     * Serializes this buffer object into binary.
     * 
     * @param   {OutputStream}  Output  output stream
     * @param   {Map}           Refs    map of previously seen objects
     * @see {@link AquaHotkey_Serializer}
     */
    Serialize(Output, Refs) {
        (Object.Prototype.Serialize)(this, Output, Refs)
        Output.WriteUInt(this.Size)
        Output.RawWrite(this)
    }

    /**
     * Reconstructs this buffer object from binary. This method assumes that
     * the object can be constructed by calling the constructor with one
     * parameter, which holds the `Size` property and byte count of the
     * succeeding raw binary data.
     * 
     * @param   {InputStream}  Input  input stream
     * @param   {Refs}         Refs   map of previously seen objects
     * @see {@link AquaHotkey_Serializer}
     */
    Deserialize(Input, Refs) {
        Size := Input.ReadUInt()
        this.__Init()
        this.__New(Size)
        Input.RawRead(this)
    }

    ;@endregion 
    ;---------------------------------------------------------------------------
    ;@region Read/Write Methods

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
            Define(Proto, "Get" . T, { Call: (Proto.Get).Bind(unset, T) })
            Define(Proto, "Put" . T, { Call: (Proto.Put).Bind(unset, T) })
        }
    }

    /**
     * Retrieves a number from the buffer.
     * 
     * @param   {String}    NumType  AHK number type
     * @param   {Integer?}  Offset   byte offset
     * @returns {Number}
     */
    Get(NumType, Offset := 0) => NumGet(this, Offset, NumType)

    /**
     * Writes a number into the buffer.
     * 
     * @param   {String}    NumType  AHK number type
     * @param   {Number}    Value    value to write
     * @param   {Integer?}  Offset   byte offset
     * @returns {this}
     */
    Put(NumType, Value, Offset := 0) {
        NumPut(NumType, Value, this, Offset)
        return this
    }

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

    ;@endregion   
    ;---------------------------------------------------------------------------
    ;@region Filling

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

    ;@endregion   
    ;---------------------------------------------------------------------------
    ;@region Hex Dump

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

    ;@endregion   
    ;---------------------------------------------------------------------------
    ;@region Define()

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
    
    ;@endregion   
    ;---------------------------------------------------------------------------
    ;@region Slice()

    ; TODO negative indexing + default values, like `SubStr()`?

    /**
     * Returns a buffer view that encloses a subsection of the current buffer.
     * When using buffer views, you should generally NOT resize the buffer
     * to ensure the memory address remains the same, and that the view
     * remains valid.
     * 
     * @param   {Integer}  Offset  offset in bytes
     * @param   {Integer}  Size    length of the subsection
     * @returns {IBuffer}
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

        Result := Object()
        Result.DefineProp("Ptr", {
            Get: (_) => (this.Ptr + Offset)
        })
        Result.DefineProp("Size", {
            Get: (_) => Max(Min(this.Size - Offset, Size), 0)
        })
        Result.DefineProp("Buf", {
            Get: (_) => this
        })
        ObjSetBase(Result, IBuffer.Prototype)
        return Result
    }
}