#Requires AutoHotkey v2.0

#Include <AquaHotkey>

LazyInit(Target, PropName, PropDesc) {
    if (ObjOwnPropCount(PropDesc) != 1) {
        throw Error()
    }
    if (!ObjHasOwnProp(PropDesc, "Get")) {
        throw Error()
    }
    
    DefineProp(Target, PropName, { Get: Getter })
    Getter(this) {
        if (ObjHasOwnProp(this, "__Class")) {
            throw PropertyError("cannot be called by a prototype")
        }
        Value := (PropDesc.Get)(this)
        DefineProp(this, PropName, { Get: (_) => Value })
        return Value
    }
}

class Annotation {
    static __New(Target?) {
        if (this == Annotation) {
            return
        }
        if (!IsSet(Target)) {
            throw UnsetError()
        }
        if (!(Target is Class)) {
            throw TypeError()
        }
        for PropName in ObjOwnProps(this) {
            if (PropName = "__Init" || PropName = "Prototype" || PropName = "__New") {
                continue
            }
            if (!ObjHasOwnProp(Target, PropName)) {
                continue
            }
            Value := GetValueOfOwnProp(this, PropName)
            if (!(Value is Array)) {
                throw TypeError()
            }
            for Annot in Value {
                Annot(Target, PropName)
            }
        }

        for PropName in ObjOwnProps(this.Prototype) {
            MsgBox(PropName)
            if (PropName = "__Init" || PropName = "__Class") {
                continue
            }
            if (!ObjHasOwnProp(Target.Prototype, PropName)) {
                MsgBox("does not have")
                continue
            }
            Value := GetValueOfOwnProp(this.Prototype, PropName)
            if (!(Value is Array)) {
                throw TypeError()
            }
            for Annot in Value {
                Annot(Target.Prototype, PropName, GetOwnPropDesc(Target.Prototype, PropName))
            }
        }
    }
}


class Person {
    FirstName {
        get {
            MsgBox("get...")
            return "Name"
        }
    }
}

class Person_LazyInit extends Annotation {
    static __New() => super.__New(Person)

    FirstName => [LazyInit]
}

P := Person()
MsgBox(P.FirstName)
MsgBox(P.FirstName)