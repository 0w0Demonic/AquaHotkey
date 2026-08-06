#Requires AutoHotkey v2.0
#Include <AquaHotkey\src\Core\Utils>
#Include <AquaHotkey\src\Core\AquaHotkey>

class Annotation extends Any {
    static __New() {
        if (this == Annotation) {
            return
        }
        for PropName in ObjOwnProps(this) {
            if (!TryGetNestedClass(this, PropName, &Supplier)) {
                continue
            }
            Receiver := Deref(PropName)
            if (!(Receiver is Class)) {
                throw TypeError("Expected a Class",, Type(Receiver))
            }

            Apply(Supplier, Receiver)
        }

        static Apply(Supplier, Receiver) {
            if (ObjHasOwnProp(Supplier, "__New")) {
                Annotate(Supplier.__New(), Receiver)
            }
            for PropName, Annots in Iterate(Supplier, "Prototype", "__New", "__Init") {
                if (TryGetNestedClass(Supplier, PropName, &NestedSupplier)) {
                    if (!TryGetNestedClass(Receiver, PropName, &NestedReceiver)) {
                        throw PropertyError("Nested class not found",,
                                            NestedSupplier.Prototype.__Class)
                    }
                    Apply(NestedSupplier, NestedReceiver)
                } else {
                    Annotate(Annots, Receiver, PropName)
                }
            }
            for PropName, Annots in Iterate(Supplier.Prototype, "__Class", "__Init") {
                Annotate(Annots, Receiver.Prototype, PropName)
            }
        }

        static Iterate(Obj, Skip*) {
            M := Map()
            M.CaseSense := false
            for S in Skip {
                M.Set(S, true)
            }
            Enumer := ObjOwnProps(Obj)
            return Iterate

            Iterate(&PropName, &Annots) {
                while (Enumer(&PropName)) {
                    if (M.Has(PropName)) {
                        continue
                    }
                    ; TODO check for nested classes
                    Annots := GetValueOfOwnProp(Obj, PropName)
                    return true
                }
                return false
            }
        }

        static Annotate(Annots, Obj, PropName?) {
            if (!(Annots is Array)) {
                throw TypeError("Expected an Array",, Type(Annots))
            }
            for Annot in Annots {
                GetMethod(Annot)
                Annot(Obj, PropName?)
            }
        }
    }
}

#Include <AquaHotkey\src\Base\ToString>

LazyProp(Getter?) {
    return CreateLazyProp

    CreateLazyProp(Obj, PropName) {
        if (!IsSet(Getter)) {
            if (!TryGetOwnPropDesc(Obj, PropName, &PropDesc)) {
                throw PropertyError(
                        "target does not have own property: " . PropName)
            }
            if (!ObjHasOwnProp(PropDesc, "Get")) {
                throw PropertyError("not a 'get' property")
            }
            Getter := PropDesc.Get
        }
        GetMethod(Getter)
        DefineProp(Obj, PropName, { Get: LazyPropImpl })

        LazyPropImpl(this) {
            if (ObjHasOwnProp(this, "__Class")) {
                throw PropertyError("cannot be called directly by a prototype")
            }
            Value := Getter(this)
            DefineProp(this, PropName, { Get: (_) => Value })
            return Value
        }
    }
}

class User {
    
}

class User_Annot extends Annotation {
    class User {
        FirstName => [ LazyProp(Enter) ]
    }
}

MsgBox()

Enter(Obj) {
    Answer := InputBox("First name doesn't exist yet. Create now")
    return Answer.Value
}

U := User()
MsgBox(U.FirstName)
MsgBox(U.FirstName)