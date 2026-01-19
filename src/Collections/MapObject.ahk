#Requires AutoHotkey v2.0

class MapObject {
    static IsInstance(Val?) {
        if (!IsSet(Val)) {
            return false
        }
        if ((Val is Map) || (Val is this)) {
            return true
        }
        return HasMethod(Val, "Clear")
            && HasMethod(Val, "Delete")
            && HasMethod(Val, "Get")
            && HasMethod(Val, "Has")
            && HasMethod(Val, "Set")
            && HasMethod(Val, "__Enum")
            && HasProp(Val, "Count")
            && HasProp(Val, "Capacity")
            && HasProp(Val, "CaseSense")
            && HasProp(Val, "__Item")
    }
}