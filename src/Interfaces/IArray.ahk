
#Include <AquaHotkeyX>

; TODO think about what properties exactly an IArray must have

/**
 * @interface
 * @description
 * 
 * An object that behaves like an array, implementing most of its built-in
 * methods and properties.
 * 
 * Implementing this interface also requires either a constructor of either
 * `static Call(Values*)` or `__New(Values*)`.
 * 
 * @module  <Interfaces/IArray>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class IArray {
    static __New() {
        if (this != IArray) {
            return
        }
        ObjSetBase(this,            ObjGetBase(Array))
        ObjSetBase(this.Prototype,  ObjGetBase(Array.Prototype))
        ObjSetBase(Array,           this)
        ObjSetBase(Array.Prototype, this.Prototype)
    }

    /**
     * Determines whether the given value is considered instance of
     * {@link IArray}.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     */
    static IsInstance(Val?) => super.IsInstance(Val?)
            || (this == IArray)
                && IsSet(Val)
                && IsObject(Val)
                && HasMethod(Val, "Get")
                && HasMethod(Val, "Has")
                && HasMethod(Val, "InsertAt")
                && HasMethod(Val, "Pop")
                && HasMethod(Val, "Push")
                && HasMethod(Val, "RemoveAt")
                && HasMethod(Val, "__Enum")
                && HasProp(Val, "__Item")
                && HasProp(Val, "Length")
                && HasProp(Val, "Capacity")
}
