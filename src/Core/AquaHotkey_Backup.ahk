/**
 * AquaHotkey - AquaHotkey_Backup.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Core/AquaHotkey_Backup.ahk
 * 
 * The `AquaHotkey_Backup` class creates a snapshot of all properties and
 * methods contained in one or more classes, allowing them to be safely
 * overridden or extended later.
 * 
 * To use it, create a subclass of `AquaHotkey_Backup` and call
 * `super.__New()` within its static constructor, passing the class or classes
 * to copy from.
 * 
 * This class extends `AquaHotkey_Ignore`, which means that it is skipped by
 * `AquaHotkey`'s automatic class prototyping mechanism.
 * 
 * If you want your subclass to *actively apply* the collected methods to
 * multiple unrelated classes, use `AquaHotkey_MultiApply` instead.
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
         * @param   {String}  PropertyName  name of new property
         * @param   {Object}  PropertyDesc  property descriptor
         */
        static Define(Obj, PropertyName, PropertyDesc) {
            ; Very strange edge case: defining an empty property does not
            ; throw an error, but is an invalid argument for `.DefineProp()`.
            if (!ObjOwnPropCount(PropertyDesc)) {
                return
            }
            (Object.Prototype.DefineProp)(Obj, PropertyName, PropertyDesc)
        }

        /**
         * `Object`'s implementation of `DeleteProp()`.
         * 
         * @param   {Object}  Obj           object to delete property from
         * @param   {String}  PropertyName  name of property
         */
        static Delete(Obj, PropertyName) {
            (Object.Prototype.DeleteProp)(Obj, PropertyName)
        }

        /**
         * `Object`'s implementation of `.GetPropDesc()`.
         * 
         * @param   {Object}  Obj           the target object
         * @param   {String}  PropertyName  name of existing property
         * @return  {Object}
         */
        static GetPropDesc(Obj, PropertyName) {
            return (Object.Prototype.GetOwnPropDesc)(Obj, PropertyName)
        }

        /**
         * Returns a getter property that always returns `Value`.
         * 
         * @param   {Any}  Value  the value to return
         * @return  {Object}
         */
        static CreateGetter(Value) => { Get: (Instance) => Value }
        
        /**
         * Creates a property descriptor for a nested class.
         * 
         * @param   {Class}  Cls  the target nested class
         * @return  {Object}
         */
        static CreateNestedClassProp(Cls) {
            return {
                Get: (Instance) => Cls,
                Call: Constructor
            }

            Constructor(Instance, Args*) {
                ; If the class has its own `Call()`, use it.
                if (ObjHasOwnProp(Cls, "Call")) {
                    if (Cls.GetOwnPropDesc("Call").Call != Object.Call) {
                        return Cls(Args*)
                    }
                }
                ; Otherwise, simulate "normal" object construction.
                Obj := Object()
                ObjSetBase(Obj, Cls.Prototype)
                Obj.__New(Args*)
                return Obj
            }
        }

        /** Creates a method in which `Caller` is the calling object. */
        static CreateForwardingMethod(Callback, Caller) {
            return (Instance, Args*) => Callback(Caller, Args*)
        }
        
        /**
         * Copies all static and instance properties from Supplier to Receiver.
         */
        static Transfer(Supplier, Receiver) {
            ; find prototype and name of property supplier
            FormatString := "`n[Aqua] ######## {1} -> {2} ########`n"
            switch {
                case (Supplier is Class):
                    SupplierProto := Supplier.Prototype
                    SupplierName  := Supplier.Prototype.__Class
                case (Supplier is Func):
                    SupplierProto := Supplier
                    SupplierName  := Supplier.Name
                default:
                    throw TypeError("Unexpected type",, Type(Supplier))
            }

            ; find prototype and name of property receiver
            switch {
                case (Receiver is Class):
                    ReceiverProto := Receiver.Prototype
                    ReceiverName  := Receiver.Prototype.__Class
                case (Receiver is Func):
                    ReceiverProto := Receiver
                    ReceiverName  := Receiver.Name
                default:
                    throw TypeError("Unexpected type",, Type(Receiver))
            }

            ; debugger output
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
                        && !(HasBase(Receiver, Primitive)))
            {
                ReceiverInit := ReceiverProto.__Init
                SupplierInit := SupplierProto.__Init

                __Init(Instance) {
                    ReceiverInit(Instance) ; previously defined `__Init()`
                    SupplierInit(Instance) ; user-defined `__Init()`
                }

                ; Rename the new `__Init()` method to something useful
                InitMethodName := SupplierProto.__Class . ".Prototype.__Init"
                Define(__Init, "Name", { Get: (Instance) => InitMethodName })

                ; Finally, overwrite the old `__Init()` property with ours
                Define(ReceiverProto, "__Init", { Call: __Init })

                ; Get rid of `__Init()` properties before copying.
                Delete(Supplier,      "__Init")
                Delete(SupplierProto, "__Init")
            }

            ; If supplier is a function, we must create special methods and
            ; getter properties that forward their arguments and return value
            ; to whatever `Supplier.<some property>()` returns.
            if (Supplier is Func) {
                Caller := Supplier

                for PropertyName in ObjOwnProps(Func.Prototype) {
                    FuncProp := GetPropDesc(Func.Prototype, PropertyName)
                    if (ObjHasOwnProp(FuncProp, "Call")) {
                        if (!FuncProp.Call.IsBuiltIn) {
                            continue
                        }
                        Define(Receiver, PropertyName, {
                            Call: CreateForwardingMethod(FuncProp.Call, Caller)
                        })
                    } else if (ObjHasOwnProp(FuncProp, "Get")) {
                        if (!FuncProp.Get.IsBuiltIn) {
                            continue
                        }
                        Define(Receiver, PropertyName, {
                            Get: CreateForwardingMethod(FuncProp.Get, Caller)
                        })
                    }
                }
            }

            ; Copy all non-static properties
            for PropertyName in ObjOwnProps(SupplierProto) {
                ; don't remove `__Class` - only skip it
                if ((Supplier is Class) && PropertyName = "__Class") {
                    continue
                }
                PropDesc := GetPropDesc(SupplierProto, PropertyName)
                Define(ReceiverProto, PropertyName, PropDesc)
            }

            ; Copy all static properties
            for PropertyName in ObjOwnProps(Supplier) {
                ; Very important - SKIP PROTOTYPE!
                if ((Supplier is Class) && (PropertyName = "Prototype")) {
                    continue
                }

                ; Check if this property is a nested class.
                try {
                    DoRecursion := (Supplier.%PropertyName% is Class)
                } catch {
                    DoRecursion := false
                }
                
                ; If it's a normal property, just copy and move on.
                if (!DoRecursion) {
                    PropDesc := GetPropDesc(Supplier, PropertyName)
                    Define(Receiver, PropertyName, PropDesc)
                    continue
                }

                ; Otherwise, we will have to recurse.
                NestedSupplier := Supplier.%PropertyName%
                NestedSupplierName := NestedSupplier.Prototype.__Class
                
                ; If the nested class already exists in the receiver, use it.
                if (ObjHasOwnProp(Receiver, PropertyName)
                            && Receiver.%PropertyName% is Class) {
                    NestedReceiver := Receiver.%PropertyName%
                    Transfer(NestedSupplier, NestedReceiver)
                    continue
                }
                
                ; Otherwise, we will have to generate one out of thin air.
                NestedReceiver := Class()
                NestedReceiverProto := Object()
                Define(NestedReceiver, "Prototype", {
                    Value: NestedReceiverProto
                })
                
                ; Define an appropriate `__Class`
                if (Index := InStr(NestedSupplierName, ".")) {
                    NestedSupplierName := SubStr(NestedSupplierName, Index + 1)
                }
                NestedReceiverName := ReceiverName . "." . NestedSupplierName
                Define(NestedReceiver, "__Class",
                        CreateGetter(NestedReceiverName))
                
                ; Hook up new nested class to receiver
                Define(Receiver, PropertyName,
                        CreateNestedClassProp(NestedReceiver))
                
                ; Keep going recursively into the new classes
                Transfer(NestedSupplier, NestedReceiver)
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
} ; class AquaHotkey_Backup
