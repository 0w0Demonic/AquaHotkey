/**
 * An object with `Ptr` and `Size` property.
 */
class IBuffer {
    /**
     * Determines whether the buffer is buffer-like.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * Buffer(16, 0).Is(BufferObject)        ; true
     * { Ptr: 0, Size: 16 }.Is(BufferObject) ; true
     */
    static IsInstance(Val?) {
        if (!IsSet(Val) || !IsObject(Val)) {
            return false
        }
        if ((Val is Buffer) || (Val is this)) {
            return true
        }
        return HasProp(Val, "Ptr") && HasProp(Val, "Size")
    }

    /**
     * Determines whether the given type should be considered equivalent to, or a
     * subtype of `BufferObject`.
     * 
     * @param   {Any}  T  any value
     * @returns {Boolean}
     */
    static CanCastFrom(T) {
        return super.CanCastFrom(T) || Buffer.CanCastFrom(T)
    }
}