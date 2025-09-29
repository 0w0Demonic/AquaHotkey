/**
 * AquaHotkey - AquaHotkey_Backup.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Core/AquaHotkey_Backup.ahk
 * 
 * ---
 * 
 * The `AquaHotkey_Backup` class creates a snapshot of all properties and
 * methods contained in one or more classes, allowing them to be safely
 * overridden or extended later.
 * 
 * ---
 * 
 * To use it, create a subclass of `AquaHotkey_Backup` and call
 * `super.__New()` within its static constructor, passing the class or classes
 * to copy from.
 *  
 * If you want your subclass to *actively apply* the collected methods to
 * multiple unrelated classes, use `AquaHotkey_MultiApply` instead.
 * 
 * This class extends `AquaHotkey_Ignore`, which means that it is skipped by
 * `AquaHotkey`'s automatic class prototyping mechanism.
 * 
 * @example
 * class Gui_Backup extends AquaHotkey_Backup {
 *     static __New() {
 *         super.__New(Gui)
 *     }
 * }
 * 
 * class LotsOfStuff extends AquaHotkey_Backup {
 *     static __New() {
 *         super.__New(MyClass, MyOtherClass, String, Array, Buffer)
 *     }
 * }
 */
class AquaHotkey_Backup extends AquaHotkey_Ignore {
;@region static __New()
/**
 * Static class initializer that copies properties and methods from one or
 * more sources. An error is thrown if a subclass calls this method without
 * passing any parameters.
 * 
 * @param   {Object*}  Suppliers  where to copy properties and methods from
 */
static __New(Suppliers*) {
    /**
     * `Object`'s implementation of `.DefineProp()`.
     * 
     * @param   {Object}  Obj           the target object
     * @param   {String}  PropName  name of new property
     * @param   {Object}  PropertyDesc  property descriptor
     */
    static Define(Obj, PropName, PropertyDesc) {
        ; Very strange edge case: defining an empty property does not
        ; throw an error, but is an invalid argument for `.DefineProp()`.
        if (!ObjOwnPropCount(PropertyDesc)) {
            return
        }
        (Object.Prototype.DefineProp)(Obj, PropName, PropertyDesc)
    }

    /**
     * `Object`'s implementation of `.GetPropDesc()`.
     * 
     * @param   {Object}  Obj           the target object
     * @param   {String}  PropName  name of existing property
     * @returns {Object}
     */
    static GetPropDesc(Obj, PropName) {
        return (Object.Prototype.GetOwnPropDesc)(Obj, PropName)
    }

    /**
     * Returns a getter property that always returns `Value`.
     * 
     * @param   {Any}  Value  the value to return
     * @returns {Object}
     */
    static CreateGetter(Value) => { Get: (_) => Value }
    
    /**
     * Creates a property descriptor for a nested class.
     * 
     * @param   {Class}  Cls  the target nested class
     * @returns {Object}
     */
    static CreateNestedClassProp(Cls) {
        return {
            Get:  (_)        => Cls,
            Call: (_, Args*) => Cls(Args*)
        }
    }

    /**
     * Creates a method in which `Caller` is the calling object.
     * 
     * @param   {Func}  Callback  the method to call
     * @param   {Any}   Caller    value that calls the method
     */
    static CreateForwardingMethod(Callback, Caller) {
        return (_, Args*) => Callback(Caller, Args*)
    }
    
    /**
     * Copies all static and instance properties from Supplier to Receiver.
     * 
     * @param   {Class/Func}  Supplier  
     * @param   {Class/Func}  Receiver  
     */
    static Transfer(Supplier, Receiver) {
        ; find prototype and name of property supplier and property receiver
        Resolve(Supplier, &SupplierProto, &SupplierName)
        Resolve(Receiver, &ReceiverProto, &ReceiverName)

        ; debugger output
        FormatString := "`n[Aqua] ######## {1} -> {2} ########`n"
        OutputDebug(Format(FormatString, SupplierName, ReceiverName))

        ; If appropriate, we redefine the `__Init()` method which is
        ; responsible for declaring new instance variables.
        ; 
        ; In this case, the object is initialized with declarations of
        ; both the supplier and receiver class.
        ; 
        ; If the receiving class is based on `Primitive`, this behavior
        ; is ignored (as they cannot own fields).
        if ((Supplier is Class) && (Receiver is Class)
                    && !(HasBase(Receiver, Primitive))
                    && (ReceiverProto.__Init != SupplierProto.__Init))
        {
            ReceiverInit := ReceiverProto.__Init
            SupplierInit := SupplierProto.__Init

            __Init(Instance) {
                ReceiverInit(Instance) ; previously defined `__Init()`
                SupplierInit(Instance) ; user-defined `__Init()`
            }

            ; Rename the new `__Init()` method to something useful
            InitMethodName := SupplierProto.__Class . ".Prototype.__Init"
            Define(__Init, "Name", { Get: (_) => InitMethodName })

            ; Finally, overwrite the old `__Init()` property with ours
            Define(ReceiverProto, "__Init", { Call: __Init })
        }

        ; If supplier is a function, we must create special methods and
        ; getter properties that forward their arguments and return value
        ; to whatever `Supplier.<some property>()` returns.
        if (Supplier is Func) {
            Caller := Supplier

            for PropName in ObjOwnProps(Func.Prototype) {
                FuncProp := GetPropDesc(Func.Prototype, PropName)
                if (ObjHasOwnProp(FuncProp, "Call")) {
                    if (!FuncProp.Call.IsBuiltIn) {
                        continue
                    }
                    Define(Receiver, PropName, {
                        Call: CreateForwardingMethod(FuncProp.Call, Caller)
                    })
                } else if (ObjHasOwnProp(FuncProp, "Get")) {
                    if (!FuncProp.Get.IsBuiltIn) {
                        continue
                    }
                    Define(Receiver, PropName, {
                        Get: CreateForwardingMethod(FuncProp.Get, Caller)
                    })
                }
            }
        }

        ; Copy all non-static properties
        for PropName in ObjOwnProps(SupplierProto) {
            ; don't remove `__Class` - only skip it
            if ((Supplier is Class) && (PropName = "__Class")) {
                continue
            }

            PropDesc := GetPropDesc(SupplierProto, PropName)
            Define(ReceiverProto, PropName, PropDesc)
        }

        ; Copy all static properties
        for PropName in ObjOwnProps(Supplier) {
            ; Very important - SKIP PROTOTYPE!
            if ((Supplier is Class) && (PropName = "Prototype")) {
                continue
            }

            ; Check if this property is a nested class.
            DoRecursion := false
            try DoRecursion := (Supplier.%PropName% is Class)
            
            ; If it's a normal property, just copy and move on.
            if (!DoRecursion) {
                PropDesc := GetPropDesc(Supplier, PropName)
                Define(Receiver, PropName, PropDesc)
                continue
            }

            ; Otherwise, we will have to recurse.
            NestedSupplier     := Supplier.%PropName%
            NestedSupplierName := NestedSupplier.Prototype.__Class
            
            ; If the nested class already exists in the receiver, use it.
            if (ObjHasOwnProp(Receiver, PropName)
                        && Receiver.%PropName% is Class) {
                NestedReceiver := Receiver.%PropName%
                Transfer(NestedSupplier, NestedReceiver)
                continue
            }
            
            ; Otherwise, we will have to generate one out of thin air.
            Base := ObjGetBase(NestedSupplier)
            NestedReceiver := AquaHotkey.CreateClass(Base, NestedSupplierName)
            
            ; Hook up new nested class to receiver
            Define(Receiver, PropName, CreateNestedClassProp(NestedReceiver))
            
            ; Keep going recursively into the new classes
            Transfer(NestedSupplier, NestedReceiver)
        }
    }

    /**
     * Resolves the name and "prototype" of the given class or function.
     * 
     * @param   {Class/Func}      Target  any class/function
     * @param   {VarRef<Object>}  Proto   class prototype / the function itself
     * @param   {VarRef<String>}  Name    name of the class/function
     */
    static Resolve(Target, &Proto, &Name) {
        switch {
            case (Target is Class):
                Proto := Target.Prototype
                Name  := Target.Prototype.__Class
            case (Target is Func):
                Proto := Target
                Name  := Target.Name
            default:
                throw TypeError("Unexpected type",, Type(Target))
        }
    }

    ; If this is `AquaHotkey_Backup` and no derived type, do nothing.
    if (this == AquaHotkey_Backup) {
        return
    }

    ; If a subclass calls this method, the parameter count must not be zero.
    if (!Suppliers.Length) {
        throw ValueError("No source classes provided")
    }

    ; Start copying properties and methods from all specified targets.
    Receiver := this
    for Supplier in Suppliers {
        Transfer(Supplier, Receiver)
    }
} ; static __New()
;@endregion

;@region static Of()
/**
 * Creates a complete and useable copy of the given class.
 * 
 * @example
 * StringClass := AquaHotkey_Backup.Of(String)
 * 
 * @param   {Class}  Cls  the class to be copied
 * @returns {Class}
 */
static Of(Cls) {
    if (!(Cls is Class)) {
        throw TypeError("Expected a Class",, Type(Cls))
    }
    Name := Cls.Prototype.__Class
    Result := AquaHotkey.CreateClass(Cls, Name)
    ObjSetBase(Result, ObjGetBase(Cls))
    (AquaHotkey_Backup.__New)(Result, Cls)
    return Result
}
;@endregion
} ; class AquaHotkey_Backup
