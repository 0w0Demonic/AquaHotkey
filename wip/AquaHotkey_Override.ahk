#Requires AutoHotkey v2.0

class Override {
    class Array {
        Length[Previous] {
            set {
                MsgBox("works")
                (Previous.Set)(this, value?)
            }
        }
    }
}


GetEnumer() {
    static Called := false
    return Enumer

    Enumer(&Sup, &Rec, &Name, &PropDesc) {
        if (!Called) {
            Called := true
            Sup := Override.Array.Prototype
            Rec := Array.Prototype
            Name := "Length"
            PropDesc := ({}.GetOwnPropDesc)(Sup, Name)
            return true
        }
        return false
    }
}

for Sup, Rec, Name, PropDesc in GetEnumer() {
    if (!ObjHasOwnProp(Rec, Name)) {
        continue
    }
    if (ObjHasOwnProp(PropDesc, "Value")) {
        throw Error()
    }
    Previous := ({}.GetOwnPropDesc)(Rec, Name)

    if (ObjHasOwnProp(PropDesc, "Call")) {
        PropDesc.Call := ObjBindMethod(PropDesc.Call,,, Previous)
    }
    if (ObjHasOwnProp(PropDesc, "Get")) {
        PropDesc.Get := ObjBindMethod(PropDesc.Set,,, Previous)
    }
    if (ObjHasOwnProp(PropDesc, "Set")) {
        PropDesc.Set := ObjBindMethod(PropDesc.Set,,,, Previous)
    }

    ({}.DefineProp)(Rec, Name, PropDesc)
}