#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * @mixin
 * Assumes:
 * - `Size => Integer`
 */
class Sizeable {
    /**
     * Determines whether a given value is sizeable.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * { Size: 0 }.Is(Sizeable)    ; true
     * Array(1, 2, 3).Is(Sizeable) ; true
     */
    static IsInstance(Val?) {
        return IsSet(Val)
            && IsObject(Val)
            && HasProp(Val, "Size")
    }

    /**
     * Determines whether this object is empty.
     * 
     * @returns {Boolean}
     */
    IsEmpty => !this.Size

    /**
     * Determines whether this object is not empty.
     * 
     * @returns {Boolean}
     */
    IsNotEmpty => !!this.Size
}

class AquaHotkey_Sizeable extends AquaHotkey {
    static __New() {
        super.__New()
        Array.IsSizedBy("Length")
        Map.IsSizedBy("Count")
    }

    class Class {
        /**
         * Declares that the given property is used to determine the size of
         * instances of this class.
         * 
         * This automatically includes `Sizeable` as mixin.
         * 
         * @param   {String}   PropName  property that determines size
         * @param   {String?}  PropType  descriptor, usually `get` or `call`
         * @example
         * Array.IsSizedBy("Length")
         */
        IsSizedBy(PropName, PropType?) {
            static Define  := {}.DefineProp
            static GetProp := {}.GetOwnPropDesc

            if (!HasProp(this.Prototype, PropName)) {
                throw PropertyError("unknown property",, PropName)
            }
            Obj := this.Prototype
            while (!ObjHasOwnProp(Obj, PropName)) {
                Obj := ObjGetBase(Obj)
            }
            PropDesc := GetProp(Obj, PropName)
            if (IsSet(PropType)) {
                if (!ObjHasOwnProp(PropDesc, PropType)) {
                    throw PropertyError("unknown property",, PropType)
                }
                PropDesc := { Get: GetProp(PropDesc, PropType).Value }
            }
            Define(this.Prototype, "Size", PropDesc)
            Sizeable.ApplyOnto(this)
            return this
        }
    }
}
