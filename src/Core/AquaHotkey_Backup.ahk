#Include "%A_LineFile%\..\AquaHotkey.ahk"

/**
 * @public
 * @abstract
 * @class AquaHotkey_Backup
 * @classdesc
 * 
 * A base class for copying members of one or more specified classes or
 * functions, allowing them to be overridden or extended in a
 * non-destructive way.
 * 
 * @example
 * ; method 1: using subclasses and `super.__New(Targets*)`
 * class Gui_Backup extends AquaHotkey_Backup {
 *     static __New() => super.__New(Gui)
 * }
 * 
 * @example
 * ; method 2: `Class#Backup(Targets*)`
 * class Gui_Backup {
 *     static __New() => this.Backup(Gui)
 * }
 * 
 * @example
 * ; method 3: `AquaHotkey_Backup.Of(Targets*)`
 * Gui_Backup := AquaHotkey_Backup.Of(Gui)
 * 
 * @exports  Class#Backup()
 * @author   0w0Demonic
 * @module   <Core/AquaHotkey_Backup>
 * @see      https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Backup extends AquaHotkey
{
;@region static __New()
/**
 * Initializes AquaHotkey's backup system.
 * 
 * This method is called automatically whenever this class and its subclasses
 * are loaded.
 * 
 * @param   {Object*}  Suppliers  where to copy properties and methods from
 * @returns {this}
 */
static __New(Suppliers*)
{
    ;@region Helper Functions

    /**
     * `Object`'s implementation of `.DefineProp()`.
     * 
     * @param   {Object}  Obj           the target object
     * @param   {String}  PropName      name of new property
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
     * @param   {Object}  Obj       the target object
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
     * Creates a property descriptor typical for nested classes.
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
     * This allows us to create full copies of functions by "imitating"
     * built-in properties like `Name` or `MinParams`.
     * 
     * @param   {Func}  Callback  the method to call
     * @param   {Any}   Caller    value that calls the method
     */
    static CreateForwardingMethod(Callback, Caller) {
        return (_, Args*) => Callback(Caller, Args*)
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

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Transfer()

    /**
     * Copies all static and instance properties from Supplier to Receiver.
     * 
     * @param   {Class/Func}  Supplier  source being copied from
     * @param   {Class/Func}  Receiver  destination being copied into
     */
    static Transfer(Supplier, Receiver) {
        ;@region Resolving

        ; find prototype and name of property supplier and property receiver
        Resolve(Supplier, &SupplierProto, &SupplierName)
        Resolve(Receiver, &ReceiverProto, &ReceiverName)

        ; debugger output
        OutputDebug(Format("`n[Aqua] ######## {1} -> {2} ########`n",
                SupplierName, ReceiverName))

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region __Init() Method

        ; If appropriate, we redefine the `__Init()` to declare the variables
        ; of both classes.
        if ((Supplier is Class) && (Receiver is Class)
                && (HasBase(Receiver, Object)))
        {
            ReceiverInit := ReceiverProto.__Init
            SupplierInit := SupplierProto.__Init

            ; If both of these functions are the same, avoid creating a
            ; property that needlessly slows down the code by initializing
            ; multiple times.
            if (ReceiverInit != SupplierInit) {
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
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Impersonation

        ; If supplier is a function, we must create special "impersonating"
        ; properties as if they belong to the actual function.

        if (Supplier is Func) {
            for PropName in ObjOwnProps(Func.Prototype) {
                FuncProp := GetPropDesc(Func.Prototype, PropName)
                for Name, Value in FuncProp.OwnProps() {
                    if (Name == "Value" || !Value.IsBuiltIn) {
                        continue
                    }
                    FuncProp.%Name% := CreateForwardingMethod(Value, Supplier)
                }
                Define(Receiver, PropName, FuncProp)
            }
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Instance Properties

        ; Copy all non-static properties
        for PropName in ObjOwnProps(SupplierProto) {
            ; don't remove `__Class` - only skip it
            if ((Supplier is Class) && (PropName = "__Class")) {
                continue
            }

            PropDesc := GetPropDesc(SupplierProto, PropName)
            Define(ReceiverProto, PropName, PropDesc)
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Static Properties

        ; Copy all static properties
        for PropName in ObjOwnProps(Supplier)
        {
            ; Do not overwrite the reference to the class' prototype, only apply
            ; changes to the existing one
            if ((Supplier is Class) && (PropName = "Prototype")) {
                continue
            }

            ; Avoid overwriting `static __New()`
            if ((Supplier is Class) && (PropName = "__New")) {
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
        ;@endregion
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Execution

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
    return this

    ;@endregion
} ; static __New()

;@endregion
;-------------------------------------------------------------------------------
;@region static Of()

/**
 * Creates a complete and useable copy of the given class. This method
 * does NOT recursively copy base classes.
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

    return AquaHotkey
        .CreateClass(ObjGetBase(Cls), Cls.Prototype.__Class)
        .Backup(Cls)
}

;@endregion
;-------------------------------------------------------------------------------
;@region Class#Backup()

class Extensions extends Any {
    static __New() {
        if (ObjGetBase(this) != Any) {
            throw TypeError("This class cannot be extended",,
                            this.Prototype.__Class)
        }
        AquaHotkey_Backup.DeleteProp("Extensions")
        (AquaHotkey_MultiApply.__New)(this, Class)
    }

    /**
     * Copies properties and methods from one or more sources into the class.
     * 
     * @example
     * Gui_Backup := AquaHotkey.CreateClass().Backup(Gui)
     * 
     * @param   {Object*}  Suppliers  where to copy properties and methods from
     * @returns {this}
     */
    Backup(Suppliers*) => (AquaHotkey_Backup.__New)(this, Suppliers*)
}
;@endregion

} ; class AquaHotkey_Backup
