; 2.0.5: Fixed internal calls to `__Enum` to not call `__Call`.
#Requires AutoHotkey >=v2.0.5

; AquaHotkey core classes
#Include %A_LineFile%/../AquaHotkey_Backup.ahk
#Include %A_LineFile%/../AquaHotkey_MultiApply.ahk
#Include %A_LineFile%/../AquaHotkey_Ignore.ahk
#Include %A_LineFile%/../AquaHotkey_Mixin.ahk

/**
 * @public
 * @abstract
 * @class AquaHotkey
 * @classdesc
 * A base class for defining extensions for AutoHotkey v2 built-in classes.
 * 
 * Subclasses declare nested classes whose members are applied to the
 * corresponding global built-in classes or functions. This provides a clean
 * and structured way to augment AutoHotkey's prototype-based classes without
 * manual patching.
 * 
 * @example
 * ; adds `Sub()` and `Length` properties to the `String` class:
 * class StringExtensions extends AquaHotkey {
 *     class String {
 *         Sub(Start, Length?) => SubStr(this, Start, Length?)
 *         Length => StrLen(this)
 *     }
 * }
 * 
 * @author  0w0Demonic
 * @module  <Core/AquaHotkey>
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey extends AquaHotkey_Ignore
{
;@region static __New()
/**
 * Initializes AquaHotkey's patching system.
 * 
 * This method is called automatically when the class or any subclass is
 * loaded, unless overridden.
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
 * ---
 * 
 * You can override `static __New()` to add additional logic, e.g. checking
 * the AHK version or whether certain classes exist in the script.
 * 
 * @example
 * ; add a `#Sub()` method to the `String` class
 * class StringExtensions extends AquaHotkey {
 *     ; StringExtensions.String
 *     ; `--> String
 *     class String {
 *         ; StringExtensions.String.Prototype.Sub()
 *         ; `--> String.Prototype.Sub()
 *         Sub(Start, Length?) => SubStr(this, Start, Length?)
 *     }
 * }
 * 
 * @example
 * 
 * ; overridden `static __New()` that checks whether the AHK version is
 * ; 
 * class Utils extends AquaHotkey
 * {
 *     static __New() {
 *         if (!IsSet(Foo) || !(Foo is Class)) {
 *             this.DeleteProp("Foo")
 *             return
 *         }
 *         super.__New()
 *     }
 * 
 *     class Foo {
 *     }
 * }
 *   
 * ...
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
            ; If `Namespace` is unset, search for a property receiver at global
            ; scope by name dereference. Otherwise, `Namespace` refers to
            ; the root class in which the property receiver resides
            ; (e.g. `Gui.Edit`, which is found in `Gui`).
            Receiver := (IsSet(Namespace)) ? Namespace.%ClassName%
                                           : (AquaHotkey.Deref)(ClassName)

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
            if (SupplierInit != ReceiverInit) {
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
    return this
    ;@endregion

} ; static __New()
;@endregion

;-------------------------------------------------------------------------------

;@region Dereference
/**
 * Dereferences a global variable by name.
 * 
 * For the sake of elementing **any** possible name collisions, it has no
 * parameters. Instead, this method must be called like this:
 * 
 * @example
 * (AquaHotkey.Deref)("MyVariableName")
 * 
 * @returns {Any}
 */
static Deref() => %this%
;@endregion

;-------------------------------------------------------------------------------

;@region static CreateClass()
/**
 * Creates a new class.
 * 
 * This method should be used on versions above v2.1-alpha.3, otherwise it will
 * fail to create subclasses of many built-in classes like `Array`, `Map`,
 * `Buffer`, or `Gui`.
 * 
 * @param   {Class?}   BaseClass  the base of the new class
 * @param   {String?}  Name       name of the class
 * @param   {Any*}     Args       zero or more arguments for `static __New()`
 * @returns {Class}
 */
static CreateClass(BaseClass := Object, Name := "(unnamed)", Args*) {
    static Define := ({}.DefineProp)

    if (!(BaseClass is Class)) {
        throw TypeError("Expected a Class",, Type(BaseClass))
    }
    if (IsObject(Name)) {
        throw TypeError("Expected a String",, Type(Name))
    }

    if (VerCompare(A_AhkVersion, "2.1-alpha.3") >= 0) {
        return Class(Name, BaseClass, Args*)
    }
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
    Define(ClsProto, "__Class", { Value: Name })
} ; static CreateClass()
;@endregion
} ; class AquaHotkey
