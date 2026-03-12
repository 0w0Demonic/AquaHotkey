#Include "%A_LineFile%\..\..\Interfaces\IBuffer.ahk"
#Include "%A_LineFile%\..\..\Interfaces\ISet.ahk"
#DllLoad "BitSet.dll"

/**
 * An {@link ISet} implementation of bits in a bit vector. Indices are 0-based.
 * 
 * @module  <Collections/BitSet>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class BitSet extends ISet {
    /**
     * Creates a {@link BitSet} view from the given {@link IBuffer}.
     * 
     * @param   {IBuffer}  Buf  any buffer-like object
     * @returns {BitSet}
     */
    static FromBuffer(Buf) {
        if (!IsObject(Buf) || !HasProp(Buf, "Ptr") || !HasProp(Buf, "Size")) {
            throw ValueError("Expected a Buffer-like object")
        }
        Result := Object()
        ObjSetBase(Result, this.Prototype)
        Result.DefineProp("B", { Get: (_) => Buf })
        return Result
    }

    /**
     * The size of the bit set (number of 1-bits in the buffer).
     * 
     * @property {Integer}
     */
    Size => DllCall("BitSet\popcount", "Ptr", this.B.Ptr, "Ptr", this.B.Size)

    /**
     * Constructs a new bit set that can hold the given number of bits.
     * 
     * @constructor
     * @param   {Integer*}  Values  zero or more elements
     */
    __New(Values*) {
        Buf := Buffer()
        this.DefineProp("B", { Get: (_) => Buf })
        this.Add(Values*)
    }

    /**
     * Determines whether the bit set contains the given index.
     * 
     * @param   {Integer}  Value  bit index
     * @returns {Boolean}
     */
    Contains(Value) {
        if (!IsInteger(Value)) {
            throw TypeError("Expected an Integer",, Type(Value))
        }
        if ((Value < 0) || (Value >>> 3) >= (this.B.Size)) {
            return false
        }
        return !!(NumGet(this.B, Value >>> 3, "UChar") & (1 << (Value & 0x07)))
    }

    /**
     * Adds zero or more elements. More specifically, sets bits at the
     * specified positions to `1`.
     * 
     * @param   {Integer*}  Values  zero or more elements
     * @returns {Integer} number of elements added
     */
    Add(Values*) {
        Result := 0
        for Value in Values {
            if (Value < 0) {
                continue
            }
            
            CurSize := this.B.Size
            ReqSize := Ceil((Value + 1) / 8)
            if (CurSize < ReqSize) {
                this.B.Size := ReqSize
                DllCall("RtlZeroMemory",
                        "Ptr", this.B.Ptr + CurSize,
                        "Ptr", ReqSize - CurSize)
            }

            Byte := NumGet(this.B, Value >>> 3, "UChar")
            if (!(Byte & (1 << (Value & 0x07)))) {
                ++Result
                NumPut("UChar",
                        Byte | (1 << (Value & 0x07)),
                        this.B,
                        Value >>> 3)
            }
        }
        return Result
    }

    /**
     * Deletes zero or more elements from the bit set.
     * 
     * @param   {Integer*}  Values  elements to delete
     * @returns {Integer} number of elements removed
     */
    Delete(Values*) {
        Result := 0
        for Value in Values {
            if ((Value < 0) || (this.B.Size < (Value >>> 3))) {
                continue
            }
            Byte := NumGet(this.B, Value >>> 3, "UChar")
            if (Byte & (1 << (Value & 0x07))) {
                ++Result
                NumPut("UChar",
                        Byte & ~(1 << (Value & 0x07)),
                        this.B,
                        Value >>> 3)
            }
        }
        return Result
    }

    /**
     * Clears the bit set.
     */
    Clear() {
        DllCall("RtlZeroMemory", "Ptr", this.B.Ptr, "Ptr", this.B.Size)
    }

    /**
     * Returns an {@link Enumerator} that enumerates through the indices of
     * all 1-bits in this bit set.
     * 
     * @returns {Enumerator}
     */
    __Enum(ArgSize) {
        i := 0
        return Enumer

        Enumer(&Value) {
            loop {
                if ((i >>> 3) >= this.B.Size) {
                    return false
                }
                if (NumGet(this.B, i >>> 3, "UChar") & (1 << (i & 0x07))) {
                    Value := i++
                    return true
                }
                i++
            }
        }
    }

    /**
     * The capacity of the bit set measured in bits.
     * 
     * @property {Integer}
     */
    Capacity {
        get => (this.B.Size << 3)
        set {
            if (!IsInteger(value)) {
                throw TypeError("Expected an Integer",, Type(value))
            }
            OldSize := this.B.Size
            NewSize := Ceil(value / 8)
            this.B.Size := NewSize
            if (NewSize > OldSize) {
                DllCall("RtlZeroMemory", 
                        "Ptr", this.B.Ptr + OldSize,
                        "Ptr", NewSize - OldSize)
            }
        }
    }

    ;@region Serialization

    /**
     * Serializes this bit set into binary.
     * 
     * @param   {OutputStream}  Output  output stream
     * @param   {Map}           Refs    map of previously seen objects
     * @see {@link AquaHotkey_Serializer}
     */
    Serialize(Output, Refs) {
        (Object.Prototype.Serialize)(this, Output, Refs)
        Output.WriteObject(this.B)
    }

    /**
     * Reconstructs the bit set from binary.
     * 
     * @param   {InputStream}  Input  input stream
     * @param   {Map}          Refs   map of previously seen objects
     * @see {@link AquaHotkey_Serializer}
     */
    Deserialize(Input, Refs) {
        Input.ReadObject(&B, Refs)
        Input.DefineProp("B", { Get: (_) => B })
    }

    ;@endregion
}

/**
 * Extension methods related to {@link BitSet}.
 */
class AquaHotkey_BitSet extends AquaHotkey {
    class IBuffer {
        /**
         * Returns a {@link BitSet} view of this buffer.
         * 
         * @returns {BitSet}
         */
        AsBitSet() => BitSet.FromBuffer(this)

        /**
         * Returns a {@link BitSet} from the contents of this buffer.
         * 
         * @returns {BitSet}
         */
        ToBitSet() => BitSet.FromBuffer(this.Clone())
    }
}
