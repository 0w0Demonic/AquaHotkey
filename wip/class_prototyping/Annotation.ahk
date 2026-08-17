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

LazyInitOnPrototype(Target, PropName, PropDesc) {
    if (ObjOwnPropCount(PropDesc) != 1) {
        throw Error()
    }
    if (!ObjHasOwnProp(PropDesc, "Get")) {
        throw Error()
    }
    DefineProp(Target, PropName, { Get: Getter })
    Getter(this) {
        Value := (PropDesc.Get)(this)
        DefineProp(
            OwnerOfProp(this, "__Class"),
            PropName,
            { Get: (_) => Value })
        return Value
    }
}

class Person {
}

class Annotation {
    static __New() {
        for PropName in ObjOwnProps(this) {
            if (!TryGetNestedClass(this, PropName, &Nested)) {
                continue
            }
            Target := (AquaHotkey.Deref)(PropName)
            if (ObjHasOwnProp(Nested, "__New")) {
                Value := Nested.__New()
                for Annot in Value {
                    Annot(Nested)
                }
            }

            for PropName in ObjOwnProps(Nested) {
                if (PropName = "__Init" || PropName = "Prototype" || PropName = "__New") {
                    continue
                }
                if (!ObjHasOwnProp(Target, PropName)) {
                    continue
                }
                Value := GetValueOfOwnProp(Nested, PropName)
                if (!(Value is Array)) {
                    throw TypeError()
                }
                for Annot in Value {
                    Annot(Target, PropName, GetOwnPropDesc(Target, PropName))
                }
            }

            for PropName in ObjOwnProps(Nested.Prototype) {
                if (PropName = "__Init" || PropName = "__Class") {
                    continue
                }
                if (!ObjHasOwnProp(Target.Prototype, PropName)) {
                    continue
                }
                Value := GetValueOfOwnProp(Nested.Prototype, PropName)
                if (!(Value is Array)) {
                    throw TypeError()
                }
                for Annot in Value {
                    Annot(Target.Prototype, PropName, GetOwnPropDesc(Target.Prototype, PropName))
                }
            }
        }
    }
}

class Deprecated {
    __New(Reason) {
    }
    Call(Cls) {
        MsgBox("deprecated class " . Cls.Prototype.__Class)
    }
}

class Serializable {
    static Call(Cls) {
        MsgBox("serializable class " . Cls.Prototype.__Class)
    }
}
class DataClass {
    __New(Args*) {
    }
    Call(Cls) {
        MsgBox("data class " . Cls.Prototype.__Class)
    }
}
class Checked {
    __New(T) {
    }
    Call(Obj, PropName, PropDesc) {
        MsgBox("checked property " . PropName)
    }
}

class Person {
    static __New() => this.Annotate({
        this: [Deprecated("Reason"),
               Serializable,
               DataClass("FirstName", "LastName")],

        %"static Call"%: [OnAccess(DoSomething)],

        FirstName: [Checked()]
    })
}

class Person {
}

class Person_Annotations extends Annotation {
    class Person {
        ; annotations for `Person` itself
        static __New() => [
            Deprecated("Reason"),
            Serializable,
            DataClass("FirstName", "LastName")]

        ; annotation for instance property `FirstName`
        FirstName => [Checked(String)]

        ; annotation for static property `Create`
        static Create() => [OnAccess(SomeFunction)]
    }
}


