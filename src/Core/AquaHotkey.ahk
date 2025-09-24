#Requires AutoHotkey >=v2.0.5

/**
 * AquaHotkey - AquaHotkey.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Core/AquaHotkey.ahk
 * @example
 * 
 * class StringExtensions extends AquaHotkey {
 *     class String {
 *         FirstCharacter() {
 *             return SubStr(this, 1, 1)
 *         }
 *     }
 * }
 * "foo".FirstCharacter() ; "f"
 */
class AquaHotkey extends AquaHotkey_Ignore
{
;@region static __New()
/**
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
     * `Object`'s implementation of `GetOwnPropDesc()`.
     * 
     * @param   {Object}  Obj           object to retrieve property from
     * @param   {String}  PropertyName  name of property
     * @returns {Object}
     */
    static GetProp(Obj, PropertyName) {
        return (Object.Prototype.GetOwnPropDesc)(Obj, PropertyName)
    }

    /**
     * After properties have been successfully transferred to the target,
     * classes are erased.
     * 
     * In order to avoid issues with deleting properties *during iteration*
     * of `ObjOwnProps()`, this array keeps track of all classes to delete
     * afterwards.
     * 
     * @example
     * [() => (Object.Prototype.DeleteProp)(AquaHotkey, String),
     *  () => (Object.Prototype.DeleteProp)(AquaHotkey, Integer),
     *  ...
     * ]
     */
    static DeletionQueue := Array()

    /**
     * Outputs useful information to the debugger.
     * 
     * @param   {String}   FormatStr  format string to be used
     * @param   {String*}  Args       zero or more arguments
     */
    static Debug(FormatStr, Args*) {
        OutputDebug("[Aqua] " . Format(FormatStr, Args*))
    }

    /**
     * Main method responsible for transferring properties.
     * 
     * @param   {Class}   RootClass      class that encloses property supplier
     * @param   {String}  ClassName      name of a property
     * @param   {Array}   DeletionQueue  reference to `static DeletionQueue`
     * @param   {Class?}  Namespace      scope to find property receiver in
     */
    static Overwrite(RootClass, ClassName, DeletionQueue, Namespace?) {
        ; Get property from root class and check if it's a property supplier,
        ; otherwise return
        try Supplier := RootClass.%ClassName%
        if (!IsSet(Supplier) || !(Supplier is Class)) {
            return
        }

        ; ignore classes that extend `AquaHotkey_Ignore`
        if (HasBase(Supplier, AquaHotkey_Ignore)) {
            Debug("ignoring: {1}", Supplier.Prototype.__Class)
            return
        }
        
        ; Get a reference to the prototype
        SupplierProto := Supplier.Prototype

        ; Try to find a property receiver (usually a built-in class)
        try
        {
            ; These two methods explicitly search for global variables and
            ; avoid accidentally capturing variables local to this method.
            ; `Deref2()` is used for the edge case `class this`.
            static Deref1(this)    => %this%
            static Deref2(VarName) => %VarName%

            ; If `Namespace` is unset, search for a property receiver at global
            ; scope by name dereference. Otherwise, `Namespace` refers to
            ; the root class in which the property receiver resides
            ; (e.g. `Gui.Edit`, which is found in `Gui`).
            switch {
                case (IsSet(Namespace)):    Receiver := Namespace.%ClassName%
                case (ClassName != "this"): Receiver := Deref1(ClassName)
                default:                    Receiver := Deref2(ClassName)
            }

            SupplierName := Supplier.Prototype.__Class
            SupplierProtoName := SupplierName . ".Prototype"
            if (Receiver is Func) {
                ReceiverProtoName := ReceiverName := Receiver.Name
            } else {
                ReceiverName := Receiver.Prototype.__Class
                ReceiverProtoName := ReceiverName . ".Prototype"
            }

            Debug("{1:-40} -> {2}", SupplierName, ReceiverName)
        }
        catch
        {
            ; Oops! unable to find property receiver.
            ; Let's try to throw a reasonable exception here...
            RootClassName := RootClass.Prototype.__Class
            ReceiverName := IsSet(Namespace)
                                ? Namespace.Prototype.__Class . "." . ClassName
                                : ClassName
            
            Msg   := "unable to extend class " . ReceiverName
            Extra := "class " . RootClassName
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

        ; Ignore primitive classes, as its instances cannot have any fields.
        ; Also skip whenever both `__Init()` methods are the same, which is most
        ; of the time; we avoid calling the same method twice.
        if (!HasBase(Receiver, Primitive) && (ReceiverInit != SupplierInit)) {
            ; Rename the new `__Init()` method to something useful
            InitMethodName := SupplierProto.__Class . ".Prototype.__Init"
            Define(__Init, "Name", { Get: (_) => InitMethodName })

            ; Finally, overwrite the old `__Init()` property with ours
            Define(ReceiverProto, "__Init", { Call: __Init })
        }

        ; Remove special properties in the supplier class before starting to
        ; transfer properties.
        Delete(Supplier,      "Prototype")
        Delete(Supplier,      "__Init")
        Delete(SupplierProto, "__Init")
        Delete(SupplierProto, "__Class")

        ; Checks if the property is a nested class that should be recursed into.
        ; e.g. `AquaHotkey.Gui`              | `Gui`
        ;       `--> `AquaHotkey.Gui.Button` |  `--> `Gui.Button`
        static DoRecursion(Supplier, Receiver, PropertyName) {
            try return (Supplier is Class) && (Supplier.%PropertyName% is Class)
                    && (Receiver is Class) && (Receiver.%PropertyName% is Class)
            return false
        }

        ; Transfer all static properties
        for PropertyName in ObjOwnProps(Supplier) {
            if (PropertyName = "__New") {
                continue
            }
            if (DoRecursion(Supplier, Receiver, PropertyName)) {
                Overwrite(Supplier, PropertyName, DeletionQueue, Receiver)
            } else {
                PropDesc := GetProp(Supplier, PropertyName)
                Define(Receiver, PropertyName, PropDesc)
            }
        }
        
        ; Transfer all non-static properties
        for PropertyName in ObjOwnProps(SupplierProto) {
            PropDesc := GetProp(SupplierProto, PropertyName)
            Define(ReceiverProto, PropertyName, PropDesc)
        }
    }
    
    Debug("")
    Debug("######## Extension Class: {1} ########", this.Prototype.__Class)
    Debug("")

    ; Loop through all properties of AquaHotkey and modify classes
    for PropertyName in ObjOwnProps(this) {
        Overwrite(this, PropertyName, DeletionQueue, unset)
    }

    ; Finally, erase all supplier classes.
    while (DeletionQueue.Length) {
        DeletionQueue.Pop()()
    }
} ; static __New()
;@endregion

;@region static ApplyMixin()
/**
 * Applies one or more mixins to a given class.
 * 
 * @example
 * class Example {
 *     static __New() => AquaHotkey.ApplyMixin(this, Foo, Bar)
 * }
 * class Foo {
 *     Foo() => MsgBox("Foo!")
 * }
 * class Bar {
 *     Bar() => MsgBox("Bar!")
 * }
 * 
 * @param   {Class}   ReceiverClass  the targeted class
 * @param   {Class}   Mixin          a mixin to apply
 * @param   {Class*}  Mixins         more mixins to apply
 */
static ApplyMixin(ReceiverClass, Mixin, Mixins*) {
    if (!(ReceiverClass is Class)) {
        throw TypeError("Expected a Class",, Type(ReceiverClass))
    }
    if (!(Mixin is Class)) {
        throw TypeError("Expected a Class",, Type(Mixin))
    }
    for M in Mixins {
        if (!(M is Class)) {
            throw TypeError("Expected a Class",, Type(M))
        }
    }
    (AquaHotkey_Backup.__New)(ReceiverClass, Mixin, Mixins*)
} ; static ApplyMixin()
;@endregion
} ; class AquaHotkey

#Include %A_LineFile%/../AquaHotkey_Backup.ahk
#Include %A_LineFile%/../AquaHotkey_MultiApply.ahk
#Include %A_LineFile%/../AquaHotkey_Ignore.ahk