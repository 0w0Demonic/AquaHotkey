#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IArray.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IBuffer.ahk"
#Include "%A_LineFile%\..\..\IO\Serializer.ahk"

; TODO refactor this to support different AHK number types / other structs
; TODO allow resizing the array with just `.Push()`, etc.

;@region ByteArray

/**
 * Represents an {@link IArray} view of {@link IBuffer} objects.
 * 
 * Insertion methods like `.Push()`, `.InsertAt()`, or `.RemoveAt()` are
 * not supported.
 * 
 * You can resize the array with either `.Capacity` or `.Length`, this requires
 * the buffer to be resizable by setting `.Size`.
 * 
 * @example
 * Buffer(8, 0).AsArray() ; [0, 0, 0, 0, 0, 0, 0, 0]
 * 
 * A := ByteArray() ; [] (backing Buffer is empty)
 * A.Length := 32   ; resize backing Buffer with `Buf.Size := 32`
 * 
 * ; you can use any of the `IArray` methods:
 * A.FillWith(() => A_Index) ; [1, 2, 3, 4, ..., 32]
 * 
 * ; use as buffer
 * A.AsBuffer().HexDump().MsgBox() ; 01 02 03 ... 20
 */
class ByteArray extends IArray
{
    ;@region Array Impl

    /**
     * Creates a new instance from the given {@link IBuffer}.
     * 
     * @constructor
     * @param   {IBuffer?}  Buf  the buffer to wrap around
     */
    __New(Buf := Buffer()) {
        if (!Buf.Is(IBuffer)) {
            throw TypeError("Expected an IBuffer",, Type(Buf))
        }
        this.DefineProp("B", {
            Get: (_)        => Buf })
        this.DefineProp("Ptr", {
            Get: (_)        => Buf.Ptr,
            Set: (_, Value) => (Buf.Ptr := Value) })
        this.DefineProp("Size", {
            Get: (_)        => Buf.Size,
            Set: (_, Value) => (Buf.Size := Value) })
    }

    /**
     * Clones the array by creating a new array from a copy of the backing
     * buffer.
     * 
     * @returns {IBuffer.Array}
     */
    Clone() => IBuffer.Array( (this.B).Clone() )

    /**
     * Retrieves a byte from the buffer. The index is 1-based.
     * 
     * Because a byte array always has a value if the index is valid,
     * param #2 (`Default`) is ignored.
     * 
     * @param   {Integer}  Index  1-based array index
     * @returns {Integer}
     */
    Get(Index, *) => NumGet(this, Index - 1, "UChar")

    /**
     * Determines whether the given array index is valid. The index is
     * 1-based.
     * 
     * @param   {Integer}  Index  1-based array index
     * @returns {Integer}
     */
    Has(Index) => Index && (Abs(Index) < this.Size)

    /**
     * Length of the array.
     * 
     * @property {Integer}
     */
    Length {
        get => (this.Size)
        set => (this.Size := value)
    }

    /**
     * Capacity of the array.
     * 
     * @property {Integer}
     */
    Capacity {
        get => (this.Size)
        set => (this.Size := value)
    }

    /**
     * Sets or retrieves an element (byte) in the buffer.
     * 
     * @param    {Integer}  Index  1-based array index
     * @property {Integer}
     */
    __Item[Index] {
        get => NumGet(this, Index - 1, "UChar")
        set => NumPut("UChar", value, this, Index - 1)
    }

    /**
     * Returns an {@link Enumerator} that enumerates all array elements
     * (bytes in the buffer). Both 1- and 2-parameter for-loops are
     * supported.
     * 
     * @param   {Integer}  ArgSize  for-loop parameter size
     * @returns {Enumerator}
     * @example
     * for Value in Arr ...
     * for Index, Value in Arr ...
     */
    __Enum(ArgSize) {
        Offset := 0
        return (ArgSize <= 1) ? Enumer1 : Enumer2
        
        Enumer1(&Value) {
            if (Offset < this.Size) {
                Value := NumGet(this, Offset++, "UChar")
                return true
            }
            return false
        }

        Enumer2(&Index, &Value) {
            if (Offset < this.Size) {
                Value := NumGet(this, Offset++, "UChar")
                Index := Offset
                return true
            }
            return false
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Conversion

    /**
     * Returns the backing buffer.
     * 
     * @returns {IBuffer}
     */
    AsBuffer() => (this.B)

    /**
     * Returns a clone of the backing buffer.
     * 
     * @returns {IBuffer}
     */
    ToBuffer() => (this.B).Clone()

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Serialization

    /**
     * Serializes this byte array into binary.
     * 
     * @param   {OutputStream}  Output  output stream
     * @param   {Map}           Refs    map of previously seen objects
     * @see {@link AquaHotkey_Serializer}
     */
    Serialize(Output, Refs) {
        (Object.Prototype.Serialize)(this, Output, Refs)
        Output.WriteObject(this.B, Refs)
    }

    /**
     * Constructs this byte array from binary.
     * 
     * @param   {InputStream}  Input  input stream
     * @param   {Map}          Refs   map of previously seen objects
     * @see {@link AquaHotkey_Serializer}
     */
    Deserialize(Input, Refs) {
        Input.ReadObject(&B, Refs)
        this.__New(B)
    }

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

/**
 * Extension methods related to {@link ByteArray}.
 */
class AquaHotkey_ByteArray extends AquaHotkey {
    class IBuffer {
        /**
         * Returns this buffer viewed as a {@link ByteArray}.
         * 
         * @returns {ByteArray}
         */
        AsByteArray() => ByteArray(this)

        /**
         * Creates a {@link ByteArray} out of a clone of this buffer.
         * 
         * @returns {ByteArray}
         */
        ToByteArray() => ByteArray(this.Clone())
    }
}
