#Include "%A_LineFile%/../../Core/AquaHotkey.ahk"

/**
 * Introduces the `Buffer.Bytes` class, which represents buffer objects
 * viewed as byte arrays.
 * 
 * @module  <Collections/ByteArray>
 */
class AquaHotkey_ByteArray extends AquaHotkey {
    class Buffer {
        /**
         * Returns a byte view of this buffer.
         * 
         * @returns {Buffer.Bytes}
         */
        Bytes => ByteArray(this)
    }
}

; TODO change to 1-based indexing in favor of Indexable mixin?

/**
 * A byte array.
 */
class ByteArray {
    static __New() {
        if (this == ByteArray) {
            this.Backup(Enumerable1, Indexable)
        }
    }

    /**
     * Creates a new buffer view.
     * 
     * @constructor
     * @param   {Buffer}  Buf  backing buffer object
     */
    __New(Buf) {
        static Define := {}.DefineProp

        ; TODO change to .Is(BufferObject) ?
        if (!(Buf is Buffer)) {
            throw TypeError("Expected a Buffer",, Type(Buf))
        }

        Define(this, "Ptr", {
            Get: (_) => Buf.Ptr,
            Set: (_, Value) => (Buf.Ptr := Value)
        })

        Define(this, "Size", {
            Get: (_) => Buf.Size,
            Set: (_, Value) => (Buf.Size := Value)
        })
    }

    /**
     * Returns an enumerator for this object.
     * 
     * @param   {Integer}  ArgSize  amount of variables in for-loop
     * @returns {Enumerator}
     * @example
     * for Byte in Buf.Bytes {
     *     ; ...
     * }
     */
    __Enum(ArgSize) {
        Offset := 0
        if (ArgSize == 1) {
            return Enumer1
        }
        return Enumer2

        Enumer1(&Val) {
            if (Offset >= this.Size) {
                return false
            }
            Val := NumGet(this, Offset, "UChar")
            ++Offset
            return true
        }

        Enumer2(&Idx, &Val) {
            if (Offset >= this.Size) {
                return false
            }
            Idx := Offset
            Val := NumGet(this, Offset, "UChar")
            ++Offset
            return true
        }
    }

    /**
     * Retrieves and sets bytes in the view.
     * 
     * @param   {Integer}  Offset  offset in bytes
     * @example
     * Arr[0] := 255
     * MsgBox(Arr[0])
     */
    __Item[Offset] {
        get => Numget(this, Offset, "UChar")
        set {
            NumPut("UChar", value, this, Offset)
        }
    }
    
    /**
     * Retrieves a byte at the specified offset.
     * 
     * @param   {Integer}  Offset  offset in bytes
     * @returns {Integer}
     */
    Get(Offset) => NumGet(this, Offset, "UChar")

    /**
     * Sets a bytes at ths specified offset.
     * 
     * @param   {Integer}  Offset  offset in bytes
     */
    Set(Offset, Value) {
        NumPut("UChar", Value, this, Offset)
    }
}
