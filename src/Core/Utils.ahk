#Requires AutoHotkey v2

;-------------------------------------------------------------------------------
;@region Is(...)

/**
 * Determines whether a value is primitive, i.e. a string or a number.
 * You should this function instead of `(Val is Primitive)`, as it
 * also handles edge cases such as `(Integer.Prototype is Primitive)`,
 * which returns `true`.
 * 
 * @param   {Any}  Val  any value
 * @returns {Boolean}
 * @example
 * IsPrimitive(42)    ; true
 * IsPrimitive(4.223) ; true
 * IsPrimitive("str") ; true
 * 
 * ; handles edge cases
 * (Integer.Prototype is Primitive) ; true (oops!)
 * IsPrimitive(Integer.Prototype)   ; false
 */
IsPrimitive(Val) {
    static Primitive_Prototype := ObjGetBase(ObjGetBase(""))
    return !IsObject(Val) && HasBase(Val, Primitive_Prototype)
}

/**
 * Determines whether the value is a "plain" object that directly inherits
 * from `Object.Prototype`. Object literals are plain objects, unless a `base`
 * property is specified.
 * 
 * @param   {Any}  Val  any value
 * @returns {Boolean}
 * @example
 * MsgBox(IsPlainObject({ Key: "Value" })) ; ==> true
 */
IsPlainObject(Val) {
    static Object_Prototype := ObjGetBase({})
    return ObjGetBase(Val) == Object_Prototype
}

/**
 * Determines whether the property descriptor might potentially refer to a
 * nested class. This function does NOT call any properties to check whether
 * the returned value is a class. You can do this by using
 * `(PropDesc.Get)(EnclosingClass) is Class`.
 * 
 * @param   {Object}  PropDesc  property descriptor
 * @returns {Boolean}
 * @see {@link TryGetNestedClass()}
 */
IsNestedClassProp(PropDesc) {
    static MaxParams := GetOwnPropDesc(
        GetOwnPropDesc(Func.Prototype, "MaxParams"),
        "Get"
    ).Value

    static IsVariadic := GetOwnPropDesc(
        GetOwnPropDesc(Func.Prototype, "IsVariadic"),
        "Get"
    ).Value

    ; a nested class property always looks like this:
    ; {
    ;   Get: (Cls) => NestedClass,
    ;   Call: (Cls, Args*) => NestedClass(Args*)
    ; }
    return IsPlainObject(PropDesc)
        && ObjHasOwnProp(PropDesc, "Get")
        && ObjHasOwnProp(PropDesc, "Call")
        && (ObjOwnPropCount(PropDesc) == 2)
        && (MaxParams(PropDesc.Get) == 1)
        && (MaxParams(PropDesc.Call) == 1)
        && (IsVariadic(PropDesc.Call))
        && (!IsVariadic(PropDesc.Get))

        ; && (PropDesc.Call.IsBuiltIn) ; (despite strict rules, allow setting
        ; && (PropDesc.Get.IsBuiltIn)  ; nested classes manually, if done right)
}

;@endregion
;-------------------------------------------------------------------------------
;@region Basic Prop Methods

/**
 * Defines a new property for an object. This function returns the
 * original object (`Obj`).
 * 
 * @param   {Object}       Obj       any object
 * @param   {String}       PropName  name of the property
 * @param   {PlainObject}  PropDesc  property descriptor
 * @returns {Object}
 * @see {@link Object#DefineProp}
 * @example
 * Obj := {}
 * DefineProp(Obj, "Prop", { Get: (_) => 42 })
 * MsgBox(Obj.Prop) ; 42
 */
DefineProp(Obj, PropName, PropDesc) {
    static Define := {}.DefineProp
    return Define(Obj, PropName, PropDesc)
}

/**
 * Deletes an object's own property. If the property was defined as a value
 * property, its value is returned.
 * 
 * @param   {Object}  Obj       any object
 * @param   {String}  PropName  name of the property
 * @returns {Any}
 * @example
 * Obj := { Prop: 42 }
 * MsgBox(DeleteProp(Obj, "Prop")) ; ==> 42
 * MsgBox(ObjOwnPropCount(Obj))    ; ==> 0
 */
DeleteProp(Obj, PropName) {
    static Delete := {}.DeleteProp
    return Delete(Obj, PropName)
}

/**
 * Retrieves the descriptor of an object's own property.
 * 
 * @param   {Object}  Obj       any object
 * @param   {String}  PropName  name of the property
 * @returns {Object}
 */
GetOwnPropDesc(Obj, PropName) {
    static GetProp := {}.GetOwnPropDesc
    return GetProp(Obj, PropName)
}

;@endregion
;-------------------------------------------------------------------------------
;@region Defining Props

/**
 * Defines a method for an object. This function returns the original object
 * (`Obj`).
 * 
 * @param   {Object}  Obj       any object
 * @param   {String}  PropName  name of the property
 * @param   {Func}    Fn        the function to be called
 * @returns {Object}
 * @example
 * Obj := DefineMethod({ Name: "world" }, "SayHello",
 *             (Obj) => MsgBox("Hello, " . Obj.Name . "!"))
 * 
 * Obj.SayHello() ; ==> "Hello, world!"
 */
DefineMethod(Obj, PropName, Fn) {
    return DefineProp(Obj, PropName, { Call: Fn })
}

/**
 * Defines a `{ get; }`-property for an object. This function returns the
 * original object (`Obj`).
 * 
 * @param   {Object}  Obj       any object
 * @param   {String}  PropName  name of the property
 * @param   {Func}    Fn        the function to be called
 * @returns {Object}
 * @example
 * Obj := DefineGetter({}, "Prop", Prop)
 * Prop(Obj) {
 *     MsgBox("getting prop...")
 *     return 42
 * }
 * 
 * Val := Obj.Prop
 * ; ==> "getting prop..."
 * ; ==> 42
 */
DefineGetter(Obj, PropName, Fn) {
    return DefineProp(Obj, PropName, { Get: Fn })
}

/**
 * Defines a const property for an object. A constant property is a readonly
 * `{ get; }` property which returns a constant value. This function returns
 * the original object (`Obj`).
 * 
 * @param   {Object}  Obj       any object
 * @param   {String}  PropName  name of the property
 * @param   {Func}    Fn        the function to be called
 * @returns {Object}
 * @example
 * Obj := DefineConst({}, "Prop", (Obj) => 42)
 * MsgBox(Obj.Prop)  ; ==> 42
 * Obj.Prop := "str" ; MethodError!
 */
DefineConst(Obj, PropName, Value) {
    return DefineProp(Obj, PropName, { Get: (_) => Value })
}

/**
 * Defines multiple properties for an object. `PropDescs` must be a plain
 * object that contains the property names, mapped to their property descriptor.
 * 
 * Returns the original object.
 * 
 * @param   {Object}       Obj        any object
 * @param   {PlainObject}  PropDescs  property descriptors
 * @returns {Object}
 * @example
 * Buf := Buffer(16)
 * Obj := {}
 * DefineProps(Obj, {
 *     Ptr:  { Get: (_) => Buf.Ptr  },
 *     Size: { Get: (_) => Buf.Size }
 * })
 */
DefineProps(Obj, PropDescs) {
    if (!IsPlainObject(PropDescs)) {
        throw TypeError("Expected a plain object",, Type(Obj))
    }
    for PropName, PropDesc in OwnValueProps(PropDescs) {
        DefineProp(Obj, PropName, PropDesc)
    }
    return Obj
}

/**
 * Defines multiple readonly properties for an object.
 * `PropDescs` must be a plain object containing the property names
 * mapped to their respective constant value.
 * 
 * This function returns the original object (`Obj`).
 * 
 * @param   {Object}       Obj        any object
 * @param   {PlainObject}  PropDescs  properties
 * @returns {Object}
 * @example
 * Obj := DefineConsts({}, { Prop1: "value1", Prop2: "value2" })
 */
DefineConsts(Obj, PropDescs) {
    if (!IsPlainObject(PropDescs)) {
        throw TypeError("Expected a plain object",, Type(PropDescs))
    }
    for PropName, PropDesc in OwnValueProps(PropDescs) {
        DefineConst(Obj, PropName, PropDesc)
    }
    return Obj
}

/**
 * Creates an object described only by the property descriptors in `Desc`.
 * 
 * @param   {Object}   Desc     a set of properties
 * @param   {Object?}  BaseObj  base object to be set
 * @returns {Object}
 * @example
 * ; value of `A` and `B` are treated as prop descs
 * Obj := ObjFromDesc({
 *     A: { get: (Obj) => Obj.B },
 *     B: { get: (Obj) => 42 }
 * })
 * 
 * MsgBox(Obj.A) ; 42
 */
ObjFromDesc(Desc, BaseObj := Object.Prototype) {
    if (!IsPlainObject(Desc)) {
        throw TypeError("Expected a plain object",, Type(Desc))
    }

    Obj := { base: BaseObj }
    for PropertyName, PropDesc in OwnValueProps(Desc) {
        DefineProp(Obj, PropertyName, PropDesc)
    }
    return Obj
}

/**
 * Creates a property descriptor typical for nested classes.
 * 
 * @param   {Class}  Cls  the nested class
 * @returns {Object}
 * @example
 * class A {
 * }
 * class B {
 * }
 * PropDesc := NestedClassProp(B)
 * MsgBox(IsNestedClassProp(PropDesc)) ; ==> true
 * 
 * DefineProp(A, "B", NestedClassProp(B))
 * MsgBox(A.B == B) ; ==> true
 */
NestedClassProp(Cls) {
    if (!(Cls is Class)) {
        throw TypeError("Expected a Class",, Type(Cls))
    }
    return {
        Get:  (_)        => Cls,
        Call: (_, Args*) => Cls(Args*)
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Create Classes

/**
 * Creates a new class.
 * 
 * On AutoHotkey versions below v2.1-alpha.3, this method might fail
 * creating prototypes based on native types other than `Object`, such
 * as `Array` or `Map`.
 * 
 * @param   {Class?}   BaseClass  the base of the new class
 * @param   {String?}  Name       name of the class
 * @param   {Any*}     Args       arguments for `static __New()`
 * @returns {Class}
 * @example
 * class MyClass {
 *     static __New(Param?) => ...
 * }
 * CreateClass(MyClass, "MySubclass", "Param")
 */
CreateClass(BaseClass := Object, Name?, Args*) {
    if (!(BaseClass is Class)) {
        throw TypeError("Expected a Class",, Type(BaseClass))
    }

    if (IsSet(Name) && !(Name is Primitive)) {
        throw TypeError("Expected a String",, Type(Name))
    }

    if (VerCompare(A_AhkVersion, ">=v2.1-alpha.3")) {
        if (IsSet(Name)) {
            return Class(Name, BaseClass, Args*)
        }
        return Class(BaseClass, Args*)
    }

    ClsProto := { __Class: (Name?) }
    Cls := { base: BaseClass, Prototype: ClsProto }

    try {
        ObjSetBase(Cls.Prototype, BaseClass.Prototype)
    } catch {
        throw TypeError(
            "Unable to subclass. Try using version v2.1-alpha.3+",,
            Cls.Prototype.__Class . " -> " . BaseClass.Prototype.__Class)
    }

    if (HasMethod(Cls, "__New")) {
        Cls.__New(Args*)
    }

    return Cls
}

;@endregion
;-------------------------------------------------------------------------------
;@region Getting Props

/**
 * Attempts to retrieve a nested class from the given class `Class`
 * by the given `Name`. On success, returns `true` and outputs the
 * nested class into `&Nested`, otherwise returns `false`.
 * 
 * @param   {Class}           Cls     any class
 * @param   {String}          Name    property name
 * @param   {VarRef<Class>?}  Nested  (out) nested class
 * @param   {VarRef<Any?>?}   Err     (out) error, if thrown
 * @returns {Boolean}
 */
TryGetNestedClass(Cls, Name, &Nested?, &Err?) {
    if (!(Cls is Class) || !ObjHasOwnProp(Cls, Name)) {
        return false
    }
    PropDesc := GetOwnPropDesc(Cls, Name)
    Err      := unset
    if (IsNestedClassProp(PropDesc)) {
        try {
            Value := (PropDesc.Get)(Cls)
            if (Value is Class) {
                Nested := Value
                return true
            }
        } catch Any as Err {
        }
    }
    return false
}

/**
 * Retrieves the value of an object's own property.
 * This function throws, if the object does not own such a property, or if
 * the property is not a field nor a `get` property callable with no arguments.
 * 
 * @param   {Object}  Obj       any object
 * @param   {String}  PropName  name of the property
 * @returns {Any}
 */
GetValueOfOwnProp(Obj, PropName) {
    PropDesc := GetOwnPropDesc(Obj, PropName)
    switch {
        case (ObjHasOwnProp(PropDesc, "Value")):
            return PropDesc.Value

        case (ObjHasOwnProp(PropDesc, "Get")):
            return (PropDesc.Get)(Obj)
        
        default:
            throw PropertyError("unknown property",, PropName)
    }
}

/**
 * Enumerates an object's own properties and their property descriptors.
 * 
 * @param   {Object}  Obj  any object
 * @returns {Enumerator}
 * @example
 * for PropName, PropDesc in OwnPropDescs(Any.Prototype) {
 *     T := ""
 *     if (FirstItem(ObjOwnProps(PropDesc), &Enumer, &Value)) {
 *         T .= Value
 *         while (Enumer(&Value)) {
 *             T .= ", " . Value
 *         }
 *     }
 *     MsgBox(PropName . ": { " . T . " }")
 * }
 * ; ==> __Class: { Value }
 * ; ==> __Init: { Call }
 * ; ==> Base: { Get, Set }
 * ; ==> GetMethod: { Call }
 * ; ...
 */
OwnPropDescs(Obj) {
    Enumer := ObjOwnProps(Obj)
    ObjSetBase(ObjPropDescsImpl, Enumerator.Prototype)
    return ObjPropDescsImpl
    
    ObjPropDescsImpl(&PropName, &PropDesc) {
        if (Enumer(&PropName)) {
            PropDesc := GetOwnPropDesc(Obj, PropName)
            return true
        }
        return false
    }
}

/**
 * Enumerates the own value properties (fields) of an object.
 * 
 * @param   {Object}  Obj  any object
 * @returns {Enumerator}
 * @example
 * Obj := DefineProps({}, {
 *     A: { Value: 42 }, ; just a regular field
 *     B: { Get: ... }, ; dynamic prop with `{ get; }`
 *     C: { Call: ... }, ; method
 *     D: { Value: 8 } ; another value prop
 * })
 * for Key, Value in OwnValueProps(Obj) {
 *     MsgBox(Key . ": " . Value)
 * }
 * ; ==> A: 42
 * ; ==> D: 8
 */
OwnValueProps(Obj) {
    if (!IsObject(Obj)) {
        throw TypeError("Expected an Object",, Type(Obj))
    }
    Enumer := ObjOwnProps(Obj)
    ObjSetBase(Enumer, Enumerator.Prototype)
    return OwnValuePropsImpl

    OwnValuePropsImpl(&Key, &Value?) {
        loop {
            if (!Enumer(&Key)) {
                return false
            }
            PropDesc := GetOwnPropDesc(Obj, Key)
            if (ObjHasOwnProp(PropDesc, "Value")) {
                Value := PropDesc.Value
                return true
            }
        }
    }
}

/**
 * Returns an enumerator of all properties that an object has by the given name.
 * 
 * @param   {Object}  Obj       any object
 * @param   {String}  PropName  name of the property
 * @returns {Enumerator}
 * @example
 * Obj := { A: "a", base: { A: "b", base: { A: "c" } } }
 * for PropDesc in GetPropDescsNyName(Obj, "A") {
 *     MsgBox(PropDesc.Value)
 * }
 * ; ==> "a"
 * ; ==> "b"
 * ; ==> "c"
 */
GetPropDescsByName(Obj, PropName) {
    if (IsObject(Obj)) {
        Obj := ObjGetBase(Obj)
    }
    ObjSetBase(GetPropDescsByNameImpl, Enumerator.Prototype)
    return GetPropDescsByNameImpl

    GetPropDescsByNameImpl(&PropDesc) {
        while (!Obj) {
            if (ObjHasOwnProp(Obj, PropName)) {
                PropDesc := GetOwnPropDesc(Obj, PropName)
                return true
            }
            Obj := ObjGetBase(Obj)
        }
        return false
    }
}

/**
 * Attempts to retrieve the descriptor of an object's own property.
 * `&PropDesc` receives the property descriptor of the object. If the property
 * exists, this function returns `true`, otherwise `false`.
 * 
 * @param   {Object}           Obj       any object
 * @param   {String}           PropName  name of the property
 * @param   {VarRef<Object?>}  PropDesc  (out) property descriptor
 * @returns {Boolean}
 */
TryGetOwnPropDesc(Obj, PropName, &PropDesc) {
    if (ObjHasOwnProp(Obj, PropName)) {
        PropDesc := GetOwnPropDesc(Obj, PropName)
        return true
    } else {
        PropDesc := unset
        return false
    }
}

/**
 * Retrieves the descriptor of an object's property. The object does
 * not have to own the property directly. This function returns the
 * first found property descriptor, or `false` if the property does
 * not exist.
 * 
 * @param   {Object}  Obj       any object
 * @param   {String}  PropName  name of the property
 * @returns {Object|false}
 */
GetPropDesc(Obj, PropName) {
    if (!HasProp(Obj, PropName)) {
        return false
    }
    while (!ObjHasOwnProp(Obj, PropName)) {
        Obj := ObjGetBase(Obj)
    }
    return GetOwnPropDesc(Obj, PropName)
}

;@endregion
;-------------------------------------------------------------------------------
;@region Misc

/**
 * Attempts to retrieve the inner value of a `VarRef`. `&OutValue`
 * receives the value referenced by the `VarRef`. If a value is present,
 * this method returns `true`, otherwise `false`.
 * 
 * @param   {VarRef}        Ref       reference to a variable
 * @param   {VarRef<Any?>}  OutValue  (out) inner value
 * @returns {Boolean}
 * @example
 * A := unset
 * TryDeref(&A, &OutValue) ; ==> false
 * MsgBox(IsSet(OutValue))) ; ==> false
 * 
 * A := 42
 * if (TryDeref(&A, &OutValue)) { ; ==> true
 *     MsgBox(OutValue) ; 42
 * }
 */
TryDeref(Ref, &OutValue) {
    if (!(Ref is VarRef)) {
        throw TypeError("Expected a VarRef",, Type(Ref))
    }
    if (IsSetRef(Ref)) {
        OutValue := %Ref%
        return true
    } else {
        OutValue := unset
        return false
    }
}

/**
 * Returns the object that owns a property of the given name in the
 * inheritance chain of `Obj`, of `false` if the property doesn't exist.
 * 
 * @param   {Object}  Obj       any object
 * @param   {String}  PropName  name of the property
 * @returns {Object}
 * @example
 * Arr := [1, 2, 3]
 * OwnerOfProp(Arr, "Length") ; ==> Array.Prototype
 * OwnerOfProp(Arr, "DefineProp") ; ==> Object.Prototype
 */
OwnerOfProp(Obj, PropName) {
    if (!HasProp(Obj, PropName)) {
        return false
    }
    while (!ObjHasOwnProp(Obj, PropName)) {
        Obj := ObjGetBase(Obj)
    }
    return Obj
}

/**
 * Renames the property of an object. This function returns the original
 * object `Obj`.
 * 
 * @param   {Object}  Obj      any object
 * @param   {String}  OldName  old name
 * @param   {String}  NewName  new name
 * @returns {Object}
 */
RenameProp(Obj, OldName, NewName) {
    PropDesc := GetOwnPropDesc(Obj, OldName)
    DeleteProp(Obj, OldName)
    DefineProp(Obj, NewName, PropDesc)
    return Obj
}

/**
 * Dereferences either a `VarRef` or a string referring to a variable at
 * global scope. Throws, if the `VarRef` has no value or no variable exists
 * with that name.
 * 
 * If the value is a string, it cannot be equal to `"this"`.
 * 
 * @param   {VarRef|String}  this  value to deref
 * @returns {Any}
 * @example
 * A := 42
 * B := Deref("A") ; 42
 */
Deref(this) => %this%

;@endregion
;-------------------------------------------------------------------------------
;@region Enumerators

/**
 * Determines whether the given value is an {@link Enumerator} that resulted
 * from calling {@link ObjOwnProps()}. This function is required when checking
 * whether a function is callable with a given number of parameters.
 * 
 * @param   {Any}  Obj  any value
 * @returns {Boolean}
 * @see {@link AcceptsParamCount()}
 * @example
 * Enumer := ObjOwnProps(Obj)
 * MsgBox(IsObjOwnPropsEnumerator(Enumer)) ; true
 */
IsObjOwnPropsEnumerator(Obj) {
    static GetProp(PropName, PropType) {
        PropDesc := GetOwnPropDesc(Func.Prototype, PropName)
        if (!ObjHasOwnProp(PropDesc, PropType)) {
            throw PropertyError("incorrect prop type. Expected . " . PropType)
        }
        return PropDesc.%PropType%
    }
    static IsBuiltIn  := GetProp("IsBuiltIn",  "Get")
    static MaxParams  := GetProp("MaxParams",  "Get")
    static MinParams  := GetProp("MinParams",  "Get")
    static IsVariadic := GetProp("IsVariadic", "Get")
    static Name       := GetProp("Name",       "Get")

    return (Obj is Func) && IsBuiltIn(Obj) && !MaxParams(Obj)
        && !MinParams(Obj) && !IsVariadic(Obj) && (Name(Obj) == "")
}

/**
 * Determines whether the given object is callable with the given amount of
 * parameters without causing it to throw immediately. Same as
 * `HasMethod(Obj,, ParamSize)`, but handles the edge case of
 * `HasMethod(ObjOwnProps(Obj),, 1)` incorrectly returning `false`.
 * 
 * @param   {Object}   Obj        any object
 * @param   {Integer}  ParamSize  parameter size
 * @returns {Boolean}
 * @example
 * AcceptsParamCount(MsgBox, 0) ; ==> true
 * 
 * Enumer := ObjOwnProps({})
 * AcceptsParamCount(Enumer, 2) ; ==> true
 * HasMethod(Enumer,, 2) ; ==> false (oops!)
 */
AcceptsParamCount(Obj, ParamSize) {
    if (!IsObject(Obj)) {
        throw TypeError("Expected an object",, Type(Obj))
    }
    GetMethod(Obj)
    return HasMethod(Obj, ParamSize) || IsObjOwnPropsEnumerator(Obj)
}

/**
 * Retrieves an enumerator for an object.
 * 
 * @param   {Object}    Obj      any object
 * @param   {Integer?}  ArgSize  argument size
 * @returns {Enumerator}
 */
GetEnumerator(Obj, ArgSize := 1) {
    if (!IsInteger(ArgSize)) {
        throw TypeError("Expected an Integer",, Type(ArgSize))
    }
    
    ; `.__Enum()` always takes priority before `.Call()`.
    ; Also allowed to be something like `String.Prototype.__Enum()`.
    if (HasProp(Obj, "__Enum")) {
        Obj := Obj.__Enum(ArgSize)
    }

    ; at this point, `Obj` MUST be an object AND callable
    ; TODO use `is Object` instead?
    if (!IsObject(Obj)) {
        throw TypeError("Expected an object",, Type(Obj))
    }
    if (!HasMethod(Obj)) {
        throw MethodError("not enumerable",, Type(Obj))
    }

    ; do some assertions on the parameter length of the stream source.
    ; we allow `Obj` to be a non-func callable object, in which case we need
    ; to account for the additional `this` parameter.
    if (Obj is Func) {
        f := Obj
        ThisParam := 0
    } else {
        ThisParam := 1
        f := GetMethod(Obj, "Call")
    }

    Obj := ObjBindMethod(Obj)

    static GetProp(PropName, PropType) {
        PropDesc := GetOwnPropDesc(Func.Prototype, PropName)
        if (!ObjHasOwnProp(PropDesc, PropType)) {
            throw PropertyError("invalid prop type. Expected " . PropType)
        }
        return PropDesc.%PropType%
    }
    static IsBuiltIn  := GetProp("IsBuiltIn",  "Get")
    static MinParams  := GetProp("MinParams",  "Get")
    static MaxParams  := GetProp("MaxParams",  "Get")
    static Name       := GetProp("Name",       "Get")
    static IsVariadic := GetProp("IsVariadic", "Get")

    Hi := MaxParams(f)
    Lo := MinParams(f)
    Va := IsVariadic(f)

    if (IsBuiltIn(f) && !Hi && !Lo && !Va && (Name(f) == "")) {
        ; assume this resulted from `ObjOwnProps()`
        ; (do nothing here...)
    } else if ((Lo - ThisParam) > ArgSize) {
        throw ValueError("too many parameters for size " . ArgSize,,
                Lo - ThisParam)
    } else if (!Va && (Hi - ThisParam) < ArgSize) {
        throw ValueError("not enough parameters for size " . ArgSize,,
                Hi - ThisParam)
    }
;.  ; optional. We can ensure that all parameters are byref, but the
;.  ; function will fail soon enough with a reasonable error message, if
;.  ; something goes wrong.
;.  else {
;.      static IsByRef := GetProp("IsByRef", "Call")
;.      loop (Hi - ThisParam) {
;.          if (!IsByRef(Obj, A_Index + ThisParam)) {
;.              throw ValueError("not a ByRef parameter",, "#" . A_Index)
;.          }
;.      }
;.  }

    ObjSetBase(Obj, Enumerator.Prototype)
    return Obj
}

/**
 * Accepts an object and outputs its enumerator and the first item, if present.
 * Returns `true` if the first item exists, otherwise `false`. Throws, if
 * unable to enumerate the object.
 * 
 * @param   {Object}               Obj    any object
 * @param   {VarRef<Any>?}         Value  (out) first item
 * @param   {VarRef<Enumerator>?}  More   (out) enumerator object
 * @returns {Boolean}
 */
FirstItem(Obj, &Value?, &More?) {
    More := GetEnumerator(Obj)
    return More(&Value)
}

/**
 * Returns a 2-argument enumerator that enumerates the given object in
 * pairs of two. Instead of throwing an error, the enumerator stops, if it
 * encounters an incomplete pair. When the length of the enumerated object
 * is known (e.g. an array), you can use `(Arr.Length & 1)` to detect
 * incomplete pairs, and throw accordingly.
 * 
 * @param   {Object}  Obj  any object
 * @returns {Enumerator}
 * @example
 * Arr := ["Key1", "Value1", "Key2", "Value2"]
 * 
 * ; check for length first, if appropriate.
 * if (Arr.Length & 1) {
 *     throw ValueError("invalid param length")
 * }
 * for Key, Value in Pairwise(Arr) {
 *     MsgBox(Key . ": " . Value)
 * }
 * ; ==> Key1: Value1
 * ; ==> Key2: Value2
 */
Pairwise(Obj) {
    Enumer := GetEnumerator(Obj)
    ObjSetBase(PairwiseImpl, Enumerator.Prototype)
    return PairwiseImpl

    PairwiseImpl(&Key, &Value) => Enumer(&Key) && Enumer(&Value)
}

/**
 * Returns a 2-argument enumerator that enumerates the given object in pairs
 * of two. The enumerator throws an error if it encounters an incomplete pair.
 * You should prefer using {@link Pairwise} if the length of the enumerated
 * sequence is already known.
 * 
 * @param   {Object}  Obj  any object
 * @returns {Enumerator}
 * @example
 * for Key, Value in StrictPairwise([1, 2, 3, 4, 5]) {
 *     MsgBox(Key . ": " . Value)
 * }
 * ; ==> 1: 2
 * ; ==> 3: 4
 * ; ValueError! invalid argument pair (5).
 */
StrictPairwise(Obj) {
    Enumer := GetEnumerator(Obj)
    ObjSetBase(StrictPairwiseImpl, Enumerator.Prototype)
    return StrictPairwiseImpl

    StrictPairwiseImpl(&Key, &Value) {
        if (!Enumer(&Key)) {
            return false
        }
        if (!Enumer(&Value)) {
            throw ValueError("invalid argument pair")
        }
        return true
    }
}

;@endregion

