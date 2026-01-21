#Include <AquaHotkeyX>

class IMap {
    static __New() {
        if (this != IMap) {
            return
        }
        ObjSetBase(this,           ObjGetBase(Map))
        ObjSetBase(this.Prototype, ObjGetBase(Map.Prototype))
        ObjSetBase(Map,            this)
        ObjSetBase(Map.Prototype,  this.Prototype)
    }

    static IsInstance(Val?) => super.IsInstance(Val?)
            || (this == IMap)
                && IsSet(Val) && IsObject(Val)
                && HasMethod(Val, "Clear")
                && HasMethod(Val, "Delete")
                && HasMethod(Val, "Get")
                && HasMethod(Val, "Has")
                && HasMethod(Val, "Set")
                && HasMethod(Val, "__Enum")
                && HasProp(Val, "Count")
                && HasProp(Val, "__Item")
}
