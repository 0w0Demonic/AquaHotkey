/**
 * An object with `Ptr` and `Size` property.
 */
class IBuffer {
    static __New() {
        if (this != IBuffer) {
            return
        }
        ObjSetBase(this,             ObjGetBase(Buffer))
        ObjSetBase(this.Prototype,   ObjGetBase(Buffer.Prototype))
        ObjSetBase(Buffer,           this)
        ObjSetBase(Buffer.Prototype, this.Prototype)
    }

    /**
     * Determines whether the buffer is buffer-like.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * Buffer(16, 0).Is(IBuffer)        ; true
     * { Ptr: 0, Size: 16 }.Is(IBuffer) ; true
     */
    static IsInstance(Val?) => super.IsInstance(Val?)
            || (this == IBuffer)
                && IsSet(Val) && IsObject(Val)
                && HasProp(Val, "Ptr") && HasProp(Val, "Size")
}
