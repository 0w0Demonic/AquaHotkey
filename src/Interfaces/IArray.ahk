
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

    ;@region Type Info

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
    
    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Unimplemented

    /**
     * Unsupported `.Clone()` method.
     * @see {@link Array#Clone}
     */
    Clone() {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Delete()` method.
     * @see {@link Array#Delete}
     */
    Delete(Index) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Get()` method.
     * @see {@link Array#Get}
     */
    Get(Index, *) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Has()` method.
     * @see {@link Array#Has}
     */
    Has(Index) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.InsertAt()` method.
     * @see {@link Array#InsertAt}
     */
    InsertAt(Index, *) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Pop()` method.
     * @see {@link Array#Pop}
     */
    Pop() {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Push()` method.
     * @see {@link Array#Push}
     */
    Push(Values*) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.RemoveAt()` method.
     * @see {@link Array#RemoveAt}
     */
    RemoveAt(Index, Length?) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.__Enum()` method.
     * @see {@link Array#_Enum}
     */
    __Enum(ArgSize) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Length` property.
     * @see {@link Array#Length}
     */
    Length {
        get {
            throw PropertyError("not implemented")
        }
        set {
            throw PropertyError("not implemented")
        }
    }

    /**
     * Unsupported `.Capacity` property.
     * @see {@link Array#Capacity}
     */
    Capacity {
        get {
            throw PropertyError("not implemented")
        }
        set {
            throw PropertyError("not implemented")
        }
    }

    /**
     * Unsupported `.__Item[]` property.
     * @see {@link Array#__Item}
     */
    __Item[Index] {
        get {
            throw PropertyError("not implemented")
        }
        set {
            throw PropertyError("not implemented")
        }
    }

    ;@endregion
}
