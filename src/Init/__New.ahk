/**
 * AquaHotkey - AquaHotkey.__New
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Init/__New.ahk
 * 
 * **Overview**:
 * 
 * The `AquaHotkey.__New()` method is responsible for adding custom
 * implementations to AutoHotkey's built-in types and functions.
 * 
 * **Terminology used in comments**:
 * 
 * - **Property Supplier**:
 * 
 *   The class that is defined by the user, which contains custom
 *   implementations and is "supplied" to the given target, a class or a
 *   function.
 * 
 * - **Property Receiver**:
 * 
 *   The class or global function that receives custom implementations
 *   defined by the user.
 * 
 * @example
 * 
 * class StringExtensions extends AquaHotkey {
 *     ; StringExtensions.String
 *     ; `--> String
 *     class String {
 *         ; StringExtensions.String.Prototype.FirstCharacter()
 *         ; `--> String.Prototype.FirstCharacter()
 *         FirstCharacter() {
 *             return SubStr(this, 1, 1)
 *         }
 *     }
 * }
 */
static __New() {
    /**
     * `Object`'s implementation of `DefineProp()`.
     * 
     * @param   {Object}  Obj           object to define property on
     * @param   {String}  PropertyName  name of property
     * @param   {Object}  PropertyDesc  property descriptor
     */
    static Define(Obj, PropertyName, PropertyDesc) {
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
     * In order to avoid issues with deleting properties during iteration
     * of `ObjOwnProps()`, keep an array of `BoundFunc` to delete all property
     * supplier classes after successful setup.
     * 
     * @example
     * 
     * [() => (Object.Prototype.DeleteProp)(AquaHotkey, String),
     *  () => (Object.Prototype.DeleteProp)(AquaHotkey, Integer),
     *  ...
     * ]
     */
    static DeletionQueue := Array()

    /**
     * This method gets rid of special class properties from property suppliers,
     * namely `__Init()`, `Call()`, `__New()`, `__Class` and `Prototype`.
     * 
     * @param   {Class}  ClassObj  property supplier to delete properties from
     */
    static DiscardProperties(ClassObj) {
        static Props := ["__Init", "Call", "__New", "__Class", "Prototype"]
        Proto := ClassObj.Prototype
        for PropertyName in Props {
            Delete(ClassObj, PropertyName)
            Delete(Proto,    PropertyName)
        }
    }

    /**
     * Main method responsible for transferring properties.
     * 
     * @param   {Class}   RootClass      class that encloses property supplier
     * @param   {String}  ClassName      name of a property
     * @param   {Array}   DeletionQueue  `static DeletionQueue`
     * @param   {Class?}  Namespace      scope to find property receiver in
     */
    static Overwrite(RootClass, ClassName, DeletionQueue, Namespace?) {
        ; Get property from root class and check if it's a property supplier,
        ; otherwise return
        Supplier := RootClass.%ClassName%
        if (!(Supplier is Class)) {
            return
        }
        
        ; Get a reference to the prototype
        SupplierProto := Supplier.Prototype
        
        ; Try to find a property receiver (usually a built-in class)
        try
        {
            ; These two methods find variables in global namespace. `Deref2()`
            ; avoids the edge case `class this`.
            static Deref1(this)    => %this%
            static Deref2(VarName) => %VarName%

            ; If `Namespace` is unset, search for a property receiver at global
            ; scope by name dereference. Otherwise, `Namespace` refers to
            ; the root class in which the property receiver resides
            ; (e.g. `Gui.Edit`, which is found in `Gui`).
            if (IsSet(Namespace)) {
                Receiver := Namespace.%ClassName%
            } else if (ClassName != "this") {
                Receiver := Deref1(ClassName)
            } else {
                Receiver := Deref2(ClassName)
            }
        }
        catch
        {
            ; Oops! unable to find property receiver.
            ; Let's try to throw a reasonable exception here...
            SupplierName := Supplier.Prototype.__Class
            ReceiverName := IsSet(Namespace)
                                ? Namespace.Prototype.__Class . "." . ClassName
                                : ClassName
            Msg   := SupplierName . " is unable to resolve a property receiver"
            Extra := ReceiverName
            throw UnsetError(Msg,, Extra)
        }
        
        ; Create a `BoundFunc` which deletes the reference to the property
        ; supplier when called, and push it to an array.
        DeletionQueue.Push(ObjBindMethod(Delete,, RootClass, Supplier))

        ; Check type the property receiver (must be `Class` or `Func`). If the
        ; property receiver is a `Func`, all properties are seen as `static`, as
        ; functions cannot have instances.
        switch {
            case Receiver is Class: ReceiverProto := Receiver.Prototype
            case Receiver is Func:  ReceiverProto := Receiver
            default:
                throw TypeError("receiver must be a Class or a Func",,
                                Type(Receiver))
        }

        ; Redefine `__Init()` method (which does instance variable declarations)
        ; to call both the previous method and then the `__Init()` method of the
        ; property supplier.
        ReceiverInit := ReceiverProto.__Init
        SupplierInit := SupplierProto.__Init

        /**
         * The new `__Init()` method used during object construction. This
         * method first calls the previously defined `__Init()`, followed by the
         * new `__Init()` which was defined in the property supplier.
         */
        __Init(Instance) {
            ReceiverInit(Instance) ; previously defined `__Init()`
            SupplierInit(Instance) ; user-defined `__Init()`
        }

        ; Check whether the receiver is a primitive class, in which case
        ; defining a new `__Init()` would have no effect as primitive types
        ; cannot own any properties.
        if (!HasBase(Receiver, Primitive)) {
            ; Rename the new `__Init()` method to something useful
            InitMethodName := SupplierProto.__Class . ".Prototype.__Init"
            Define(__Init, "Name", { Get: (Instance) => InitMethodName })

            ; Finally, overwrite the old `__Init()` property with ours
            Define(ReceiverProto, "__Init", { Call: __Init })
        }

        ; Get rid of properties `__Init`, `__New`, `__Class`, `Call` and
        ; `Prototype` in the user-defined class before transferring properties
        DiscardProperties(Supplier)

        ; Checks if the property is a nested class that should be recursed into,
        ; e.g. `AquaHotkey.Gui`              | `Gui`
        ;       `--> `AquaHotkey.Gui.Button` |  `--> `Gui.Button`
        static DoRecursion(Supplier, Receiver, PropertyName) {
            return (Supplier is Class) && (Supplier.%PropertyName% is Class)
                && (Receiver is Class) && (Receiver.%PropertyName% is Class)
                ; e.g. InStr("AquaHotkey.Integer", "Integer")
                && InStr(Type(Supplier), Type(Receiver))
        }

        ; Transfer all static properties
        for PropertyName in ObjOwnProps(Supplier) {
            if (DoRecursion(Supplier, Receiver, PropertyName)) {
                Overwrite(Supplier, PropertyName, DeletionQueue, Receiver)
            } else {
                PropDesc := Supplier.GetOwnPropDesc(PropertyName)
                Define(Receiver, PropertyName, PropDesc)
            }
        }
        
        ; Transfer all non-static properties
        for PropertyName in ObjOwnProps(SupplierProto) {
            PropDesc := SupplierProto.GetOwnPropDesc(PropertyName)
            Define(ReceiverProto, PropertyName, PropDesc)
        }
    }
    
    ; Loop through all properties of AquaHotkey and modify classes
    for PropertyName in ObjOwnProps(this) {
        Overwrite(this, PropertyName, DeletionQueue, unset)
    }

    ; Finally, delete all supplier classes.
    ; They can no longer be accessed through member access
    ; `AquaHotkey.{...}` anymore.
    while (DeletionQueue.Length) {
        DeletionQueue.Pop()()
    }
}