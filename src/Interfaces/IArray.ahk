
#Include <AquaHotkeyX>

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
                && HasProp(Val, "Length")
                && HasProp(Val, "Capacity")
                && HasProp(Val, "Length")
}
