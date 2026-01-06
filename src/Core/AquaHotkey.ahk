/**
 * @file AquaHotkey.ahk
 * @fileoverview
 * 
 * AquaHotkey is a framework for defining extensions for AutoHotkey's built-in
 * classes in a declarative and simple way.
 * 
 * ## Fundamental Concept
 * 
 * At its core, AquaHotkey abstracts manual monkeypatching by using classes
 * as "property containers" whose contents can be moved around freely.
 * 
 * Members are copied from, or dispatched into the built-in classes or types.
 * This can be done with the core `AquaHotkey` classes and their exported
 * methods.
 * 
 * ## Feature Classes (Recommended Pattern)
 * 
 * For larger or reusable setups, it's highly recommended to collect related
 * changes by features into a single class, defined in its own file.
 * 
 * Even if a feature consists of multiple methods or affects several built-in
 * types, it is often conceptually *one* change. Keeping these related behaviors
 * together makes the code easier to reason about, reuse across scripts, and
 * modify in one place. Encapsulating a feature in a dedicated class also allows
 * scripts to detect its presence at runtime (for example via
 * `IsSet(MyFeature)`), making features optional and loosely coupled.
 * 
 * @module   <Core/AquaHotkey>
 * @author   0w0Demonic
 * @see      https://www.github.com/0w0Demonic/AquaHotkey
 * @date     2025/12/12
 * @version  3.0.0
 * @example
 * class MyUtils extends AquaHotkey {
 *     class String {
 *         Sub(Start, Length?) => SubStr(this, Start, Length?)
 *       
 *         Length => StrLen(this)
 *     }
 *     class Array {
 *         IsEmpty => (this.Length)
 *     }
 * }
 * 
 * @example
 * class EqualityByReference {
 *     static __New() => this.ApplyOnto(Gui, Class, File, ...)
 * 
 *     Eq(Other?) => (IsSet(Other) && (this = Other))
 * }
 * 
 * @example
 * class GuiBackup {
 *     static __New() => this.Backup(Gui)
 * }
 * 
 * @example
 * class Enumerable1 {
 *     static __New() => this.Extend(Array, Gui, Map, RegExMatchInfo)
 * 
 *     ForEach(Action, Args*) {
 *         GetMethod(Action, Args*)
 *         for Value in this {
 *             Action(Value?, Args*)
 *         }
 *         return this
 *     }
 * }
 */
;-------------------------------------------------------------------------------
;@region Version Requirement

/**
 * The minimal requirement for AquaHotkey is v2, possibly also some pre-release
 * versions. There are, however, a few version-specific caveats:
 *
 * v2.1-alpha.3:
 *   Introduces `Class([Name, ] BaseClass?, Args*)` to create classes based on
 *   native classes other than `Object`, at runtime. On earlier versions, this
 *   will cause `AquaHotkey.CreateClass()` and `AquaHotkey_Backup.Of()` to fail
 *   creating a prototype for such classes.
 */
 #Requires AutoHotkey   v2
;#Requires AutoHotkey >=v2.1-alpha.3
if (VerCompare(A_AhkVersion, "<v2.1-alpha.3")) {
    AquaHotkey.Log("INFO: using an AutoHotkey version below v2.1-alpha.3")
}

;@endregion
;-------------------------------------------------------------------------------
;@region AquaHotkey

/**
 * @public
 * @abstract
 * @class
 * @classdesc
 * A base class for defining extensions for AutoHotkey v2 built-in classes.
 * 
 * Subclasses declare nested classes whose members are applied to the
 * corresponding global class or function. This provides a very clean and
 * structured way to augment AutoHotkey's prototype-based classes without
 * manual patching.
 * 
 * @example
 * class StringExtensions extends AquaHotkey {
 *   class String {
 *     Sub(Start, Length?) => SubStr(this, Start, Length?)
 *     Length              => StrLen(this)
 *   }
 * }
 * "AquaHotkey".Sub(1, 4) ; "Aqua"
 * "foo".Length           ; 3
 */
class AquaHotkey extends AquaHotkey_Ignore
{
    ;@region static __New()
    /**
     * Initializes AquaHotkey's "main" patching system.
     * 
     * This method is called automatically when the class or any subclass
     * is loaded.
     * 
     * You can override `static __New()` to add additional logic, e.g.
     * checking the current version or AutoHotkey or whether certain
     * classes are included in the script.
     * 
     * @protected
     * @abstract
     * @example
     * static __New() {
     *     this.Requires(AquaHotkey_Stream?, "Stream")
     *     this.RequiresVersion(">=v2.1-alpha.3", "Class")
     *     super.__New()
     * }
     */
    static __New() {
        static GetProp(Obj, Name) => ({}.GetOwnPropDesc)(Obj, Name)

        Log(Str, Args*) => (AquaHotkey_Ignore.Log)(this, Str, Args*)
        Log("# Extension Class: {1}", this.Prototype.__Class)

        Classes := Array()

        for PropertyName in ObjOwnProps(this)
        {
            PropDesc := ({}.GetOwnPropDesc)(this, PropertyName)
            switch {
                case (ObjHasOwnProp(PropDesc, "Value")):
                    Supplier := PropDesc.Value
                case (ObjHasOwnProp(PropDesc, "Get")):
                    try Supplier := (PropDesc.Get)(this)
                default:
                    Supplier := unset
            }
            if (!IsSet(Supplier) || !(Supplier is Class)) {
                continue
            }
            if (HasBase(Supplier, AquaHotkey_Ignore)) {
                Log("- ignoring: {1}", Supplier.Prototype.__Class)
                continue
            }
            Receiver := (AquaHotkey.Deref)(PropertyName)
            Classes.Push(PropertyName)
            (AquaHotkey_Ignore.Apply)(this, Supplier, Receiver)
        }
        if (this == AquaHotkey) {
            for Cls in Classes {
                ({}.DeleteProp)(this, Cls)
            }
        }
        return this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Deref()

    /**
     * Resolves a global value by its name. This method must be called like
     * a function.
     * 
     * @public
     * @example
     * (AquaHotkey.Deref)("String")
     * 
     * @param   {String}  this  name of global value
     * @returns {Any}
     */
    static Deref() => %this%

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Extensions

    class Any {
        ;@region Implements()
        /**
         * Determines whether this value implements the given mixin class.
         * 
         * @public
         * @param   {Class}  Mixin  the given mixin class
         * @returns {Boolean}
         * @example
         * Array(1, 2, 3).Implements(Enumerable1) ; true
         */
        Implements(Mixin) {
            if (!(Mixin is Class)) {
                throw TypeError("Expected a Class",, Type(Mixin))
            }
            if (!HasProp(this, "Mixins")) {
                return false
            }
            Val := this
            loop {
                if (ObjHasOwnProp(Val, "Mixins")) {
                    Mixins := Val.Mixins
                    if (Mixins.Has(Mixin)) {
                        return true
                    }
                }
                Val := ObjGetBase(Val)
            } until (!Val)
            return false
        }
        ;@endregion
    }

    class Class {
        ;@region Mixins
        /**
         * The mixin classes implemented by this class.
         * 
         * @public
         * @abstract
         * @type {Map}
         */
        Mixins => Map()

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Include()

        /**
         * Applies one or more mixin classes onto this class.
         * 
         * @param   {Class}   Mixin   mixin class to apply
         * @param   {Class*}  Mixins  more mixins
         * @returns {this}
         * @example
         * class Enumerable1 {
         *   ForEach(Action, Args*) {
         *     for Value in this {
         *       Action(Value?, Args*)
         *     }
         *   }
         * }
         * Array.Include(Enumerable1)
         */
        Include(Mixin, Mixins*) {
            static Define := ({}.DefineProp)

            if (!(Mixin is Class)) {
                throw TypeError("Expected a Class",, Type(Mixin))
            }
            for M in Mixins {
                if (!(M is Class)) {
                    throw TypeError("Expected a Class",, Type(M))
                }
            }

            Mixins := this.Mixins

            if (Mixins.Count) {
                ObjGetBase(this).Backup(Mixin, Mixins*)
            } else {
                BaseClass := AquaHotkey
                        .CreateClass(ObjGetBase(this))
                        .Backup(Mixin, Mixins*)
                
                ObjSetBase(this, BaseClass)
                ObjSetBase(this.Prototype, BaseClass.Prototype)
            }

            Mixins.Set(Mixin, true)
            for M in Mixins {
                Mixins.Set(M, true)
            }

            Getter := { Get: (_) => Mixins.Clone() }
            Define(this,           "Mixins", Getter)
            Define(this.Prototype, "Mixins", Getter)
            return this
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Extend()

        /**
         * Applies this mixin class onto one or more classes.
         * 
         * @public
         * @param   {Class}   Cls      the class on which to apply the mixin
         * @param   {Class*}  Classes  more classes
         * @returns {this}
         * @example
         * class Enumerable1 {
         *   static __New() => this.Extend(Array)
         * 
         *   ForEach(Action, Args*) {
         *     for Value in this {
         *       Action(Value?, Args*)
         *     }
         *   }
         * }
         */
        Extend(Cls, Classes*) {
            if (!(Cls is Class)) {
                throw TypeError("Expected a Class",, Type(Cls))
            }
            Cls.Include(this)
            for C in Classes {
                if (!IsSet(C)) {
                    throw UnsetError("Value unset")
                }
                if (!(C is Class)) {
                    throw TypeError("Expected a Class",, Type(C))
                }
                C.Include(this)
            }
            return this
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region ApplyOnto()

        /**
         * Copies the properties of the class into one or more specified
         * targets.
         * 
         * @public
         * @param   {Object*}  Targets  targets to apply properties onto
         * @returns {this}
         * @example
         * class Enumerable1 {
         *   static __New() => this.ApplyOnto(Array)
         * 
         *   ForEach(Action, Args*) {
         *     for Value in this {
         *       Action(Value?, Args*)
         *     }
         *   }
         * }
         */
        ApplyOnto(Receivers*) => (AquaHotkey_MultiApply.__New)(this, Receivers*)

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Backup()

        /**
         * Copies the properties from one or more sources into this class.
         * 
         * @public
         * @param   {Object*}  Suppliers  where to copy properties from
         * @returns {this}
         */
        Backup(Suppliers*) => (AquaHotkey_Backup.__New)(this, Suppliers*)

        ;@endregion
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region static CreateClass()

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
     */
    static CreateClass(BaseClass := Object, Name := "(unnamed)", Args*) {
        static Define(Obj, Name, PropDesc) {
            if (ObjOwnPropCount(PropDesc)) {
                ({}.DefineProp)(Obj, Name, PropDesc)
            }
        }

        if (!(BaseClass is Class)) {
            throw TypeError("Expected a Class",, Type(BaseClass))
        }
        if (IsObject(Name)) {
            throw TypeError("Expected a String",, Type(Name))
        }

        if (VerCompare(A_AhkVersion, ">=v2.1-alpha.3")) {
            return Class(Name, BaseClass, Args*)
        }

        Cls      := Class()
        ClsProto := Object()
        Define(Cls, "Prototype", { Value: ClsProto })

        try {
            ObjSetBase(Cls.Prototype, BaseClass.Prototype)
            ObjSetBase(Cls, BaseClass)
        } catch {
            throw TypeError("Unable to subclass. Try using v2.1-alpha.3+.")
        }

        if (Cls.__New != Object.Prototype.__New) {
            Cls.__New(Args*)
        }
        Define(ClsProto, "__Class", { Value: Name })
        return Cls
    }

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region AquaHotkey_Ignore

/**
 * @public
 * @abstract
 * @class
 * @classdesc
 * 
 * Marker class for indicating that a class should be ignored by AquaHotkey's
 * class prototyping system.
 * 
 * @example
 * class MyStuff extends AquaHotkey {
 *     ; this class will be ignored
 *     class Util extends AquaHotkey_Ignore { ... }
 * 
 *     ; applies to `String`
 *     class String { ... }
 * }
 */
class AquaHotkey_Ignore
{
    ;---------------------------------------------------------------------------
    ;@region static Version()

    /**
     * Determines whether the current AutoHotkey version fulfills the given
     * version requirement. A version requirement should start with a
     * comparison operator (`>`/`<`/`>=`/`<=`), otherwise `>=` is taken
     * as the default.
     * 
     * @public
     * @param   {String}  Version  version requirement
     * @returns {Boolean}
     * @example
     * 
     * ; NOTE: prefer using `static RequiresVersion()` or `static Requires()`
     * if (this.Version(">=v2.1-alpha.3")) {
     *     this.Delete("String", "Class")
     * }
     */
    static Version(Version) {
        if (IsObject(Version)) {
            throw TypeError("Expected a String",, Type(Version))
        }
        return VerCompare(A_AhkVersion, (Version ~= "^[^<>]")
                    ? ">=" . Version
                    : Version)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region static Delete()

    /**
     * Deletes one or more properties from this class by their property
     * path. Paths consist of one or more property names delimited by dots
     * (`.`).
     * 
     * @public
     * @param   {String*}  PropertyPaths  paths of properties to delete
     * @returns {this}
     * @example
     * this.Delete("Prototype.Eq")
     */
    static Delete(PropertyPaths*) {
        Log(Str, Args*) => (AquaHotkey_Ignore.Log)(this, Str, Args*)

        if (!PropertyPaths.Length) {
            throw UnsetError("No properties specified")
        }
        for PropertyPath in PropertyPaths {
            if (!IsSet(PropertyPath)) {
                throw UnsetItemError("No value found",, "Index " . A_Index)
            }
            if (IsObject(PropertyPath)) {
                throw TypeError("Expected a String",, Type(PropertyPath))
            }
            Log("deleting " . PropertyPath)
            Props := StrSplit(PropertyPath, ".")
            Name := Props.Pop()
            Obj := this

            for Prop in Props {
                PropDesc := ({}.GetOwnPropDesc)(Obj, Prop)
                if (ObjHasOwnProp(PropDesc, "Value")) {
                    Obj := PropDesc.Value
                    continue
                }
                if (ObjHasOwnProp(PropDesc, "Get")) {
                    try Obj := (PropDesc.Get)(Obj)
                    continue
                }
                throw PropertyError("Unknown property", -2, Prop)
            }
            ({}.DeleteProp)(Obj, Name)
        }
        return this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region RequiresVersion()

    /**
     * Checks whether the given AutoHotkey version requirement is fulfilled,
     * otherwise deletes one or more properties from this class by their
     * property path.
     * 
     * @public
     * @param   {String}  Version        version requirement
     * @param   {String}  PropertyPaths  affected property paths
     * @returns {this}
     * @example
     * this.RequiresVersion(">=v2.1-alpha.3", "Class", "Any")
     */
    static RequiresVersion(Version, PropertyPaths*) {
        if (!PropertyPaths.Length) {
            throw UnsetError("No properties specified")
        }
        if (!(AquaHotkey_Ignore.Version)(this, Version)) {
            (AquaHotkey_Ignore.Log)(this, "version is not {} (current: {})",
                    Version,
                    A_AhkVersion)
            (AquaHotkey_Ignore.Delete)(this, PropertyPaths*)
        }
        return this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region static Requires()

    /**
     * Asserts that the given symbol is present, otherwise deletes one
     * or more properties from the class by their property path.
     * 
     * @param   {Any?}     Symbol         any global variable
     * @param   {String*}  PropertyPaths  affected property paths
     * @returns {this}
     * @example
     * class StringExtensions extends AquaHotkey {
     *   static __New() => this.Requires(AquaHotkey_Eq?, "Prototype.Eq")
     * 
     *   class String { ... }
     * }
     */
    static Requires(Symbol?, PropertyPaths*) {
        if (!PropertyPaths.Length) {
            throw UnsetError("No properties specified")
        }
        if (!IsSet(Symbol)) {
            (AquaHotkey_Ignore.Log)(this, "symbol not found")
            (AquaHotkey_Ignore.Delete)(this, PropertyPaths*)
        }
        return this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region static Log()

    /**
     * Outputs useful information.
     * 
     * @public
     * @param   {String}   Str   format string
     * @param   {String*}  Args  zero or more arguments
     * @example
     * this.Log("doing something... {1}", MyClass.Prototype.__Class)
     */
    static Log(Str, Args*) {
        ClassName := "[" . this.Prototype.__Class . "]"
        FormatStr := Format("{1:-30} | {2}", ClassName, Str)
        OutputDebug(Format(FormatStr, Args*))
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region static LogVerbose()

    /**
     * Outputs verbose information, if `AquaHotkey_Verbose` is declared as
     * variable somewhere in the script.
     * 
     * @public
     * @param   {String}   Str   format string
     * @param   {String*}  Args  zero or more arguments
     * @example
     * this.LogVerbose("doing something in detail...")
     * ...
     * ; this class is used as option to activate verbose mode
     * class AquaHotkey_Verbose {
     * }
     */
    static LogVerbose(Str, Args*) {
        if (IsSet(AquaHotkey_Verbose) && (AquaHotkey_Verbose)) {
            (AquaHotkey_Ignore.Log)(this, Str, Args*)
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region static Apply()

    /**
     * Transfers all of the properties owned by the `Supplier` and overwrites
     * them into the given `Receiver`.
     * 
     * @protected
     * @param   {Class|Func}  Supplier  contains the properties to be applied
     * @param   {Class|Func}  Receiver  receives the new properties
     */
    static Apply(Supplier, Receiver) {
        ;@region Helper Functions
        /**
         * `Object.Prototype.DefineProp()`.
         * 
         * @param   {Object}  Obj       object to define property on
         * @param   {String}  Name      name of property
         * @param   {Object}  PropDesc  property descriptor
         */
        static Define(Obj, Name, PropDesc) {
            if (ObjOwnPropCount(PropDesc)) {
                ({}.DefineProp)(Obj, Name, PropDesc)
            }
        }

        /**
         * `Object.Prototype.DeleteProp(`.
         * 
         * @param   {Object}  Obj   object to delete property from
         * @param   {String}  Name  name of property
         * 
         */
        static Delete(Obj, Name) => ({}.DeleteProp)(Obj, Name)

        /**
         * `Object.Prototype.GetOwnPropDesc()`.
         * 
         * @param   {Object}  Obj   object to retrieve property from
         * @param   {String}  Name  name of property
         */
        static GetPropDesc(Obj, Name) {
            static PD := ({}.GetOwnPropDesc)
            return PD(Obj, Name)
        }

        /**
         * Resolves the name and "prototype" of the given class or function.
         * 
         * @param   {Class|Func}      Target      any class or function
         * @param   {VarRef<Object>}  Proto       (out) the prototype
         * @param   {VarRef<Object>}  Name        (out) name of class/function
         * @param   {VarRef<Object>}  ProtoName   (out) name of class prototype
         */
        static Resolve(Target, &Proto, &Name, &ProtoName) {
            switch {
                case (Target is Class):
                    Proto     := Target.Prototype
                    Name      := Proto.__Class
                    ProtoName := Name . ".Prototype"
                case (Target is Func):
                    Proto     := Target
                    Name      := Target.Name
                    ProtoName := Name
                default:
                    throw TypeError("Expected a Class or Func",, Type(Target))
            }
        }

        /**
         * Returns a getter property that always returns `Value`.
         * 
         * @param   {Any}  Value  the value to return
         * @returns {Object}
         */
        static GetterProperty(Value) => { Get: (_) => Value }

        /**
         * Creates a property descriptor typical for nested classes.
         * 
         * @param   {Class}  Cls  the nested class
         * @returns {Object}
         */
        static NestedClassProperty(Cls) => {
            Get:  (_)        => Cls,
            Call: (_, Args*) => Cls(Args*)
        }

        /**
         * Creates a method which delegates to `Val`.
         * 
         * @param   {Func}  Fn   the method to call
         * @param   {Any}   Val  delegate value
         * @returns {Func}
         */
        static DelegateMethod(Fn, Val) => (_, Args*) => Fn(Val, Args*)

        /**
         * Creates a property descriptor that delegates to `Val`.
         * 
         * @param   {Object}  PropDesc  a property descriptor
         * @param   {Func}    Val       delegate value
         * @param   {Object}
         */
        static Delegate(Obj, Name, Val) {
            PropDesc := GetPropDesc(Obj, Name)
            Result := Object()
            for Name, Value in ObjOwnProps(PropDesc) {
                Value := ((Name = "Value") || !Value.IsBuiltIn)
                        ? Value
                        : DelegateMethod(Value, Val)
                Define(Result, Name, { Value: Value })
            }
            return Result
        }

        /**
         * Returns the from an object's property.
         * 
         * @param   {Object}  Obj   an object
         * @param   {String}  Name  name of the property
         * @returns {Boolean}
         */
        static GetValueOfProp(Obj, PropertyName) {
            Out := unset
            PropDesc := GetPropDesc(Obj, PropertyName)
            switch {
                case (ObjHasOwnProp(PropDesc, "Value")):
                    return PropDesc.Value

                case (ObjHasOwnProp(PropDesc, "Get")):
                    return (PropDesc.Get)(Obj)
                
                default:
                    throw PropertyError("unknown property",, PropertyName)
            }
        }

        Log(Indent, Str, Args*) {
            Pad := Format("{:" . (Indent * 2) . "}")
            (AquaHotkey_Ignore.Log)(this, Pad . Str, Args*)
        }

        LogVerbose(Str, Args*) {
            (AquaHotkey_Ignore.LogVerbose)(this, Str, Args*)
        }

        Apply(Supplier, Receiver) {
            (AquaHotkey_Ignore.Apply)(this, Supplier, Receiver)
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Resolving

        if (this == AquaHotkey_Ignore) {
            throw TypeError("This method must be called by a subclass")
        }

        Resolve(Supplier, &SupplierProto, &SupplierName, &SupplierProtoName)
        Resolve(Receiver, &ReceiverProto, &ReceiverName, &ReceiverProtoName)

        if (HasBase(Receiver, AquaHotkey_Ignore)) {
            Log(1, "# ignoring: {1}", SupplierName)
            return
        }

        Log(1, "# {1} -> {2}", SupplierName, ReceiverName)

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region __Init() Method

        ; If appropriate, create a custom `__Init()` to declare the variables
        ; of both classes.

        LogVerbose("    # __Init()")
        if ((Supplier is Class) && (Receiver is Class)
                && (HasBase(Receiver, Object)))
        {
            ReceiverInit := ReceiverProto.__Init
            SupplierInit := SupplierProto.__Init

            ReceiverInitName := ReceiverProtoName . ".__Init"
            SupplierInitName := SupplierProtoName . ".__Init"

            if (SupplierInit != ReceiverInit) {
                __Init(Instance) {
                    ReceiverInit(Instance) ; previous `__Init()`
                    SupplierInit(Instance) ; our new `__Init()`
                }

                LogVerbose("      merging __Init() methods...")
                LogVerbose("      1. {1}", ReceiverInitName)
                LogVerbose("      2. {1}", SupplierInitName)
                Define(ReceiverProto, "__Init", { Call: __Init })
                LogVerbose("      done.")
            } else {
                LogVerbose("      ignore. both __Init() methods equal {1}",
                            ReceiverInitName)
            }
        } else {
            LogVerbose("      incompatible.")
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Delegation

        LogVerbose("    # Function Delegation")
        if (Supplier is Func) {
            for Name in ObjOwnProps(Func.Prototype) {
                LogVerbose("      > {1}", Name)
                Define(Receiver, Name, Delegate(Func.Prototype, Name, Supplier))
            }
        } else {
            LogVerbose("      ignore - not a function.")
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Instance Properties

        LogVerbose("    # Instance Properties")
        for Name in ObjOwnProps(SupplierProto) {
            if (Supplier is Class) {
                switch (StrLower(Name)) {
                    case "__class", "__init":
                        LogVerbose("      > {1} (ignored)", Name)
                        continue
                }
            }
            LogVerbose("      > {1}", Name)
            Define(ReceiverProto, Name, GetPropDesc(SupplierProto, Name))
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Static Properties

        LogVerbose("    # Static Properties")
        for Name in ObjOwnProps(Supplier) {
            if (Supplier is Class) {
                switch (StrLower(Name)) {
                    case "prototype", "__new", "__init":
                        LogVerbose("      > {1} (ignored)", Name)
                        continue
                }
            }

            DoRecursion := false
            PropDesc := GetPropDesc(Supplier, Name)
            if (ObjHasOwnProp(PropDesc, "Value")) {
                DoRecursion := (PropDesc.Value is Class)
            } else if ObjHasOwnProp(Supplier, "Get") {
                try DoRecursion := ((PropDesc.Get)(Supplier) is Class)
            }

            if (!DoRecursion) {
                LogVerbose("      > {1}", Name)
                Define(Receiver, Name, GetPropDesc(Supplier, Name))
                continue
            }

            NestedSupplier := GetValueOfProp(Supplier, Name)
            NestedSupplierName := NestedSupplier.Prototype.__Class
            NestedReceiverName := ReceiverName . "." . Name

            LogVerbose("      nested class... {1}", Name)

            if (ObjHasOwnProp(Receiver, Name)) {
                NestedReceiver := GetValueOfProp(Receiver, Name)
                if (NestedReceiver is Class) {
                    LogVerbose("      recurse into existing: {1}",
                               NestedReceiverName)
                    Apply(NestedSupplier, NestedReceiver)
                    continue
                } else {
                    LogVerbose("      overwriting existing class: {1}",
                               NestedReceiverName)
                }
            }

            Base := ObjGetBase(NestedSupplier)
            NestedReceiver := AquaHotkey.CreateClass(Base, NestedSupplierName)
            
            LogVerbose("      creating new class: {1}", NestedReceiverName)
            LogVerbose("      base class: {1}", Base.Prototype.__Class)

            Define(Receiver, Name, NestedClassProperty(NestedReceiver))

            LogVerbose("      recurse into newly created class: {1}",
                       NestedReceiverName)

            Apply(NestedSupplier, NestedReceiver)
        }

        ;@endregion
    }
    ;@endregion

    /**
     * Dereferences a global variable by name.
     * 
     * This method must be called like this:
     * @example
     * (this.Deref)("MyVariableName")
     * 
     * @package
     * @returns {Any}
     */
    static Deref() => %this%
}

;@endregion
;-------------------------------------------------------------------------------
;@region AquaHotkey_MultiApply

/**
 * @public
 * @abstract
 * @class
 * @classdesc
 * 
 * Base class for copying contents of the class into one or more specified
 * targets.
 * 
 * @example
 * ; deprecated
 * class Example extends AquaHotkey_MultiApply {
 *     static __New() => super.__New(Gui.Button, Gui.CheckBox)
 *     
 *     ...
 * }
 * 
 * @example
 * ; new version
 * class Example {
 *     static __New() => this.ApplyOnto(Gui.Button, Gui.CheckBox)
 * 
 *     ...
 * }
 */
class AquaHotkey_MultiApply extends AquaHotkey_Ignore {
    ;@region static __New()
    /**
     * Initializes AquaHotkey's multi-apply system.
     * 
     * The contents of this class are copied into one or more specified
     * targets.
     * 
     * @example
     * ; deprecated
     * static __New() => super.__New(Gui.Button, Gui.ComboBox)
     * 
     * @example
     * ; new version
     * static __New() => this.ApplyOnto(Gui.Button, Gui.ComboBox)
     * 
     * @param   {Object*}  Targets  where to copy properties into
     * @returns {this}
     */
    static __New(Receivers*) {
        LogVerbose(Str, Args*) {
            (AquaHotkey_Ignore.LogVerbose)(this, Str, Args*)
        }

        if (this == AquaHotkey_MultiApply) {
            return
        }
        LogVerbose("# Multi-Apply Class: {1}", this.Prototype.__Class)
        if (!Receivers.Length) {
            throw ValueError("No targets provided")
        }

        Supplier := this
        for Receiver in Receivers {
            (AquaHotkey_Ignore.Apply)(this, Supplier, Receiver)
        }
        return this
    }
    ;@endregion
}
;@endregion

;@region AquaHotkey_Backup
/**
 * @public
 * @abstract
 * @class
 * @classdesc
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
 */
class AquaHotkey_Backup extends AquaHotkey_Ignore {
    ;@region static __New()
    /**
     * Initializes AquaHotkey's backup system.
     * 
     * This method is called automatically whenever this class and
     * its subclasses are loaded, copying and maintaining the contents of
     * one or more specified sources.
     * 
     * @example
     * ; deprecated
     * static __New() => super.__New(Array)
     * 
     * @example
     * ; new version
     * static __New() => this.Backup(Array)
     * 
     * @param   {Object*}  Suppliers  where to copy properties from
     * @returns {this}
     */
    static __New(Suppliers*) {
        if (this == AquaHotkey_Backup) {
            return
        }
        (AquaHotkey_Ignore.LogVerbose)(this,
                "# Backup class: {1}",
                this.Prototype.__Class)

        if (!Suppliers.Length) {
            throw ValueError("No source classes provided")
        }

        Receiver := this
        for Supplier in Suppliers {
            (AquaHotkey_Ignore.Apply)(this, Supplier, Receiver)
        }
        return this
    }
    
    ;@endregion
    ;---------------------------------------------------------------------------
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
        return AquaHotkey
                    .CreateClass(ObjGetBase(Cls), Cls.Prototype.__Class)
                    .Backup(Cls)
    }

    ;@endregion
}
;@endregion