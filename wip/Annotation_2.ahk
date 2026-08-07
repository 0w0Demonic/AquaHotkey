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
                    TryGetOwnPropDesc(Receiver, PropName, &PropDesc)
                    Annotate(Annots, Receiver, PropName, PropDesc?)
                }
            }
            for PropName, Annots in Iterate(Supplier.Prototype, "__Class", "__Init") {
                TryGetOwnPropDesc(Receiver.Prototype, PropName, &PropDesc)
                Annotate(Annots, Receiver.Prototype, PropName, PropDesc?)
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

        static Annotate(Annots, Obj, PropName?, PropDesc?) {
            if (!(Annots is Array)) {
                throw TypeError("Expected an Array",, Type(Annots))
            }
            for Annot in Annots {
                GetMethod(Annot)
                Annot(Obj, PropName?, PropDesc?)
            }
        }
    }
}

#Include <AquaHotkey\src\Base\ToString>

Lazy(Getter?, Target := DefaultTarget) {
    static DefaultTarget(this, PropName) => this

    GetMethod(Target)
    if (IsSet(Getter)) {
        GetMethod(Getter)
    }
    return CreateLazyProp

    CreateLazyProp(Obj, PropName, PropDesc?) {
        if (!IsSet(Getter)) {
            if (!IsSet(PropDesc)) {
                throw PropertyError(
                        "target does not have own property: " . PropName)
            }
            if (!ObjHasOwnProp(PropDesc, "Get")) {
                throw PropertyError("not a 'get' property")
            }
            Getter := PropDesc.Get
        }
        GetMethod(Getter)
        DefineProp(Obj, PropName, { Get: LazyImpl })

        LazyImpl(this) {
            if (ObjHasOwnProp(this, "__Class")) {
                throw PropertyError("cannot be called directly by a prototype")
            }
            Value := Getter(this)
            DefineProp(Target(this, PropName), PropName, { Get: (_) => Value })
            return Value
        }
    }
}

Entity(Props*) {
    
}

AllParamConstructor(Params*) {
}

ParamsFromObjectLiteral(Params*) {
}

Before(Fns*) {
    if (!Fns.Length) {
        return (Obj, *) => Obj
    }
    for Fn in Fns {
        GetMethod(Fn)
    }
    return CreateBefore

    CreateBefore(Obj, PropName, PropDesc?) {
        if (!IsSet(PropDesc)) {
            throw UnsetError("property does not exist",, PropName)
        }
        if (ObjHasOwnProp(PropDesc, "Value")) {
            throw PropertyError("not a field")
        }
        DefineProp(Obj, PropName, TransformDynamicProp(PropDesc, WrapFn))
        WrapFn(Prev, Args*) {
            for Fn in Fns {
                Fn(Args*)
            }
            return Prev(Args*)
        }
    }
}

After(Fns*) {
    if (!Fns.Length) {
        return (Obj, *) => Obj
    }
    for Fn in Fns {
        GetMethod(Fn)
    }
    return CreateAfter

    CreateAfter(Obj, PropName, PropDesc?) {
        if (ObjHasOwnProp(PropDesc, "Value")) {
            throw PropertyError("not a field")
        }
        DefineProp(Obj, PropName, TransformDynamicProp(PropDesc, WrapFn))
        WrapFn(Prev, Args*) {
            Result := Prev(Args*)
            for Fn in Fns {
                Fn(Args*)
            }
            return Result
        }
    }
}

TransformDynamicProp(PropDesc, Mapper) {
    if (!IsPlainObject(PropDesc)) {
        throw TypeError("Expected a plain object",, Type(PropDesc))
    }
    GetMethod(Mapper)
    for T, Fn in ObjOwnProps(PropDesc) {
        GetMethod(Fn)
        PropDesc.%T% := ObjBindMethod(Mapper,, PropDesc.%T%)
    }
    return PropDesc
}

class User {
    __New(Name) {
        this.Name := Name
    }
    SayHello() {
        MsgBox("Hello, " . this.Name)
        return "(result)"
    }
}

class User_Annot extends Annotation {
    class User {
        SayHello => [
            Before(
                (*) => MsgBox("before 1"),
                (*) => MsgBox("before 2")
            ),
            After((*) => MsgBox("after"))
        ]
    }
}

U := User("Name")
Result := U.SayHello()
MsgBox(Result)
