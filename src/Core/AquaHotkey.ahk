; 2.0.5: Fixed internal calls to `__Enum` to not call `__Call`.
#Requires AutoHotkey >=v2.0.5
#Include %A_LineFile%/../AquaHotkey_Backup.ahk
#Include %A_LineFile%/../AquaHotkey_MultiApply.ahk
#Include %A_LineFile%/../AquaHotkey_Ignore.ahk
#Include %A_LineFile%/../AquaHotkey_Mixin.ahk

/**
 * @description
 * AquaHotkey is a class prototyping framework for AutoHotkey v2 that lets
 * you very easily rewrite built-in classes like `Array`, `String` and `Map`
 * to match your own style and preferences.
 * 
 * To use this class, create a subclass of `AquaHotkey`. Then, create nested
 * classes named after the targeted class or function to extend. Finally,
 * write properties into the nested classes as if you were dealing with the
 * actual target class.
 * 
 * AquaHotkey will then transfer your custom properties into
 * 
 * @example
 * class StringExtensions extends AquaHotkey {
 *     class String {
 *         FirstCharacter() {
 *             return SubStr(this, 1, 1)
 *         }
 *     }
 * }
 * "foo".FirstCharacter() ; "f"
 * 
 * @author 0w0Demonic
 * @see https://www.github.com/0w0Demonic/AquaHotkey
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
static __New()
{
    ;@region Helper Functions
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
    ;@endregion

    ;---------------------------------------------------------------------------

    ;@region Overwrite()
    /**
     * Main method responsible for transferring properties.
     * 
     * @param   {Class}   RootClass      class that encloses property supplier
     * @param   {String}  ClassName      name of a property
     * @param   {Array}   DeletionQueue  reference to `static DeletionQueue`
     * @param   {Class?}  Namespace      scope to find property receiver in
     */
    static Overwrite(RootClass, ClassName, Namespace?)
    {
        ;@region Resolving

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
        ;@endregion

        ;------------------------------------------------------------------------

        ;@region __Init() Method
        ; If both supplier and receiver are classes, redefine the `__Init()`
        ; method which does declaration of instance variables.
        if ((Supplier is Class) && (Receiver is Class)
                && (HasBase(Receiver, Object)))
        {
            ReceiverInit := ReceiverProto.__Init
            SupplierInit := SupplierProto.__Init

            ; No need to redefine `__Init()` if both initializers are the same.
            ; This would only slow down code.
            if (ReceiverInit != ReceiverInit) {
                __Init(It) {
                    ReceiverInit(It) ; previously defined `__Init()`
                    SupplierInit(It) ; user-defined `__Init()`
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

        ;@region Static Properties
        Delete(Supplier, "__Init")    ; No need to transfer `static __Init()`
        Delete(Supplier, "Prototype") ; Avoid replaying entire prototype object

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
                Overwrite(Supplier, PropertyName, Receiver)
            } else {
                PropDesc := GetProp(Supplier, PropertyName)
                Define(Receiver, PropertyName, PropDesc)
            }
        }
        ;@endregion

        ;-----------------------------------------------------------------------

        ;@region Instance Properties
        Delete(SupplierProto, "__Init")  ; `__Init()` gets special treatment
        Delete(SupplierProto, "__Class") ; Don't change the name of the class

        ; Transfer all non-static properties
        for PropertyName in ObjOwnProps(SupplierProto)
        {
            PropDesc := GetProp(SupplierProto, PropertyName)
            Define(ReceiverProto, PropertyName, PropDesc)
        }
        ;@endregion
    }
    ;@endregion

    ;---------------------------------------------------------------------------
    
    ;@region Execution
    Debug("")
    Debug("######## Extension Class: {1} ########", this.Prototype.__Class)
    Debug("")

    ; Loop through all properties of AquaHotkey and modify classes
    for PropertyName in ObjOwnProps(this) {
        Overwrite(this, PropertyName, unset)
    }

    ; Finally, erase all supplier classes.
    while (DeletionQueue.Length) {
        DeletionQueue.Pop()()
    }
    ;@endregion

} ; static __New()
;@endregion

;@region static CreateClass()
/**
 * Creates a new class.
 * 
 * @param   {Class?}   BaseClass  the base of the new class
 * @param   {String?}  Name       name of the class
 * @returns {Class}
 */
static CreateClass(BaseClass := Object, Name := "(unnamed)", Args*)
{
    static Define := (Object.Prototype.DefineProp)

    if (VerCompare(A_AhkVersion, "2.1-alpha.3") >= 0) {
        Cls := Class(Name, BaseClass, Args*)
        ClsProto := Cls.Prototype
    } else {
        Cls := Class()
        ClsProto := Object()
        Define(Cls, "Prototype", { Value: ClsProto })

        ObjSetBase(Cls, BaseClass)
        try {
            ObjSetBase(ClsProto, BaseClass.Prototype)
        } catch {
            OutputDebug("[Aqua] Unable to assign " . Name . " as base.")
        }
        if (Cls.__Init != Object.Prototype.__Init) {
            Cls.__Init()
        }
        if (Cls.__New != Object.Prototype.__New) {
            Cls.__New(Args*)
        }
    }
    Define(ClsProto, "__Class", { Value: Name })
    return Cls
} ; static CreateClass()
;@endregion
} ; class AquaHotkey
