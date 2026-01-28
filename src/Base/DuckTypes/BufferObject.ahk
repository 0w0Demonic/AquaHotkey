; TODO merge this with IBuffer?

/**
 * A {@link AquaHotkey_DuckTypes duck type} that represents a buffer-like
 * object with `Ptr` and `Size` property.
 * 
 * @module  <Base/DuckTypes/BufferObject>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class BufferObject {
    /**
     * Determines whether the value is a buffer-like object.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * Buffer(16, 0).Is(BufferObject)        ; true
     * { Ptr: 0, Size: 16 }.Is(BufferObject) ; true
     */
    static IsInstance(Val?) => (
            IsSet(Val)
            IsObject(Val) &&
            HasProp(Val, "Ptr") &&
            HasProp(Val, "Size"))
    
    /**
     * Determines whether the given class is considered a subtype of
     * `BufferObject`.
     * 
     * @param   {Class}  T  any class
     * @returns {Boolean}
     * @example
     * ; true (every buffer is a BufferObject)
     * BufferObject.CanCastFrom(Buffer)
     */
    static CanCastFrom(T) => (super.CanCastFrom(T) || Buffer.CanCastFrom(T))
}