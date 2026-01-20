#Requires AutoHotkey v2.0

class IArray {
    static IsInstance(Val?) {
        if (!IsSet(Val) || !IsObject(Val)) {
            return false
        }
        if ((Val is Array) || (Val is this)) {
            return true
        }
        return HasMethod(Val, "Delete")
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

    static CanCastFrom(T) {
        return super.CanCastFrom(T) || Array.CanCastFrom(T)
    }
}