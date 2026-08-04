#Include <AquaHotkey\src\Core\Utils>
#Include <AquaHotkey\src\Base\ToString>
#Include <AquaHotkey\src\Interfaces\IMap>

/**
 * A multimap containing properties owned by objects. It allows dispatching
 * method calls and property access without an object actually owning the
 * property.
 * 
 * TODO add header here ?
 */
class DispatchMap {
    /**
     * Creates a {@link DispatchMap} based on a class. Nested classes
     * define where the properties are located. Static properties are owned
     * by the respective class object, whereas non-static properties belong
     * to the class prototype.
     * 
     * @param   {Class}  Cls  any class
     * @returns {DispatchMap}
     * @example
     * class ToString extends Dispatch {
     *     class Any {
     *         ToString() => "(any)"
     *     }
     *     class Object {
     *         ToString() => "(object)"
     *     }
     *     class String {
     *         ToString() => "(string)"
     *     }
     *     class Gui {
     *         class Control {
     *             ToUrlValue() => "(gui control)"
     *         }
     *     }
     * }
     * 
     * Result := ToString(42).Call("ToString")
     * MsgBox(Result) ; ==> "(any)"
     */
    static ForClass(Cls) {
        static GetProp := {}.GetOwnPropDesc

        static Define(Obj, Name, PropDesc) {
            ; (because prop descs can be empty on some occasions)
            if (!ObjOwnPropCount(PropDesc)) {
                return
            }
            ({}.DefineProp)(Obj, Name, PropDesc)
        }

        if (!(Cls is Class)) {
            throw TypeError("Expected a Class",, Type(Cls))
        }

        Disp := this()
        for PropName in ObjOwnProps(Cls) {
            ; search for nested classes, in which case the property name
            ; actually refers to the global variable of the same name
            if (TryGetNestedClass(Cls, PropName, &Supplier)) {
                Apply(Supplier, (AquaHotkey.Deref)(PropName), Disp)
            }
        }
        return Disp

        /**
         * Enumerates through the properties of a supplier class, adding
         * relevant properties into the dispatch map.
         * 
         * @param   {Class}        Supplier  class whose props to enumerate
         * @param   {Class}        Receiver  actual target "owning" props
         * @param   {DispatchMap}  Disp      dispatch map
         */
        static Apply(Supplier, Receiver, Disp) {
            SupProto := Supplier.Prototype
            RecProto := Receiver.Prototype
            
            ; instance properties
            ; - copy all except for __class and __init
            for Name in ObjOwnProps(Supplier.Prototype) {
                switch (StrLower(Name)) {
                    case "__class", "__init":
                        continue
                }
                Disp.Add(RecProto, Name, GetProp(SupProto, Name))
            }

            ; static properties
            ; - if both classes own a nested class, recurse
            ; - otherwise copy all except for prototype, __new and __init
            for Name in ObjOwnProps(Supplier) {
                switch (StrLower(Name)) {
                    case "prototype", "__new", "__init":
                        continue
                }
                if (!TryGetNestedClass(Supplier, Name, &NestedSupplier)
                 || !TryGetNestedClass(Receiver, Name, &NestedReceiver)
                ) {
                    Disp.Add(Receiver, Name, GetProp(Supplier, Name))
                } else {
                    Apply(NestedSupplier, NestedReceiver, Disp)
                }
            }
        }

        /**
         * Attempts to retrieve a nested class from the given class `Class`
         * by the given `Name`. On success, returns `true` and outputs the
         * nested class into `&Nested`, otherwise returns `false`.
         * 
         * @param   {Class}          Cls     any class
         * @param   {String}         Name    property name
         * @param   {VarRef<Class>}  Nested  (out) nested class
         * @returns {Boolean}
         */
        static TryGetNestedClass(Cls, Name, &Nested) {
            if (!(Cls is Class)) {
                throw TypeError("Exected a Class",, Type(Cls))
            }
            if (!(Name is String)) {
                throw TypeError("Expected a String",, Type(Name))
            }

            if (!ObjHasOwnProp(Cls, Name)) {
                return false
            }

            ; VERY strict set of constraints so we don't accidentally
            ; destroy something
            PropDesc := GetProp(Cls, Name)
            if (ObjHasOwnProp(PropDesc, "Get")
                && ObjHasOwnProp(PropDesc, "Call")
                && (ObjOwnPropCount(PropDesc) == 2)
                && (PropDesc.Get.MaxParams == 1)
                && (PropDesc.Call.MaxParams == 1)
                && (PropDesc.Call.IsVariadic)
                && (!PropDesc.Get.IsVariadic))
            {
                try {
                    Value := (PropDesc.Get)(Cls)
                    if (Value is Class) {
                        Nested := Value
                        return true
                    }
                }
            }
            return false
        }
    }

    Dispatch(Obj) => Dispatch(Obj, this)

    __New() {
        M := Map()
        ({}.DefineProp)(this, "M", { Get: (_) => M })
    }

    Add(Obj, Key, Value) {
        if (!IsObject(Obj)) {
            throw TypeError("Expected an object",, Type(Obj))
        }
        if (Key is Number) {
            Key := String(Key)
        }
        if (!(Key is String)) {
            throw TypeError("Expected a String",, Type(Key))
        }
        if (!IsPlainObject(Value)) {
            throw TypeError("Expected a plain object",, Type(Value))
        }

        ; create map for object, if absent
        Props := (this.M).Get(Obj, false)
        if (!Props) {
            Props := Map()
            Props.CaseSense := false
            (this.M).Set(Obj, Props)
        }
        ; push into props
        Props.Set(Key, Value)
    }
}

class Dispatch {
    static __New() {
        if (this == Dispatch) {
            return
        }
        Disp := DispatchMap.ForClass(this)
        if (!(Disp is DispatchMap)) {
            throw TypeError("Expected a DispatchMap",, Type(Disp))
        }
        ({}.DefineProp)(this.Prototype, "Disp", { Get: (_) => Disp })
    }

    __New(Value) {
        ({}.DefineProp)(this, "Value", { Get: (_) => Value })
    }

    /**
     * Enumerates through the property descriptors of the given name.
     * 
     * @param   {String}  Name  property name
     * @returns {Enumerator}
     */
    GetPropDescs(Name) {
        Curr := this.Value
        if (!IsObject(Curr)) {
            Curr := ObjGetBase(Curr)
        }
        M := (this.Disp).M
        return Enumer

        Enumer(&PropDesc) {
            loop {
                if (M.TryGet(Curr, &Prop) && Props.TryGet(Name, &PropDesc)) {
                    return true
                }
                if (ObjHasOwnProp(Curr, Name)) {
                    PropDesc := ({}.GetOwnPropDesc)(Curr, Name)
                    return true
                }
                Curr := ObjGetBase(Curr)
                if (!Curr) {
                    return false
                }
            }
        }
    }

    /**
     * Calls a method.
     * 
     * @param   {String}  Name  property name
     * @param   {Any*}    Args  additional args
     */
    Call(Name, Args*) {
        for PropDesc in this.GetPropDescs(Name) {
            if (ObjHasOwnProp(PropDesc, "Call")) {
                return (PropDesc.Call)(this, Args*)
            } else if (ObjHasOwnProp(PropDesc, "Value")) {
                return (PropDesc.Value)(this.Value, Args*)
            }
        }
        throw MethodError("method not found",, Name)
    }

    /**
     * Returns the value of a property.
     * 
     * @param   {String}  Name  property name
     * @param   {Any*}    Args  additional args
     * @returns {Any}
     */
    Get(Name, Args*) {
        for PropDesc in this.GetPropDescs(Name) {
            if (ObjHasOwnProp(PropDesc, "Call")) {
                if (Args.Length) {
                    throw ValueError("invalid args")
                }
                return (PropDesc.Call)
            } else if (ObjHasOwnProp(PropDesc, "Get")) {
                return (PropDesc.Get)(this.Value, Args*)
            } else if (ObjHasOwnProp(PropDesc, "Value")) {
                if (Args.Length) {
                    throw ValueError("invalid args")
                }
                return (PropDesc.Value)
            }
        }
        throw PropertyError("property not found",, Name)
    }

    /**
     * Access and sets a value to a property.
     * 
     * @param   {String}  Name   property name
     * @param   {Any?}    Value  new value
     * @param   {Any*}    Args   additional args
     */
    Set(Name, Value?, Args*) {
        for PropDesc in this.GetPropDescs(Name) {
            if (ObjHasOwnProp(PropDesc, "Set")) {
                (PropDesc.Set)(this.Value, Value?, Args*)
                return
            } else if (ObjHasOwnProp(PropDesc, "Value")) {
                if (Args.Length) {
                    throw ValueError("invalid args")
                }
                (this.Value).%Name% := (Value?)
            }
        }
        throw PropertyError("property not found",, Name)
    }

    /**
     * Returns a dispatch object for the given value.
     * 
     * @param   {Any}  Value  any value
     * @returns {Dispatch}
     */
    DispatchFor(Value) {
        Result := {}
        ObjSetBase(Result, ObjGetBase(this))
        Result.__Init()
        Result.__New(Value)
        return Result
    }
}

