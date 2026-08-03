#Include "%A_LineFile%\..\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\..\Base\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\..\Base\Eq.ahk"
#Include "%A_LineFile%\..\..\..\Base\Hash.ahk"
#Include "%A_LineFile%\..\..\..\Interfaces\ISet.ahk"

;@region GenericSet

/**
 * A type-checked {@link ISet}, in which values are enforced to be instance
 * of the given type.
 * 
 * @module  <Collections/Generic/Set>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * 
 * ; create a new set
 * S := Set.OfType(Integer)(1, 2, 3)
 */
class GenericSet extends ISet
{
    ;@region Construction

    /**
     * Creates a new subclass of `GenericSet`.
     * 
     * @param   {Class}  S  set type
     * @param   {Class}  T  component type
     * @example
     * Set.OfType(Integer)
     */
    static __New(S?, T?) {
        if (this == GenericSet) {
            return
        }

        if (!IsSet(S)) {
            throw UnsetError("unset; Expected an ISet class")
        }
        if (!IsSet(T)) {
            throw UnsetError("unset; Expected element type")
        }
        if (!(S is Class)) {
            throw TypeError("Expected a class",, Type(S))
        }
        if ((S != ISet) && !HasBase(S, ISet)) {
            throw TypeError("Expected an ISet class",, S.Prototype.__Class)
        }
        DeleteProp(this.Prototype, "__Class")
        DefineProp(this.Prototype, "ComponentType", { Get: (_) => T })
        DefineProp(this.Prototype, "SetType",       { Get: (_) => S })
    }

    /**
     * Creates a new generic set containing the given elements.
     * 
     * @constructor
     * @param   {Any*}  Values  zero or more elements
     */
    __New(Values*) {
        DefineConst(this, "S", (this.SetType)()).Add(Values*)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Type Info

    /**
     * The name of this generic set class.
     * 
     * @returns {String}
     */
    static Name => (this.Prototype.ClassName)

    /**
     * The name of the class. Provides information about the set and component
     * type.
     * 
     * @returns {String}
     */
    ClassName {
        get {
            Name := (this.SetTypeName) . "<" . (this.ComponentTypeName) . ">"
            DefineProp(OwnerOfProp(this, "SetType"), "ClassName", {
                Get: (_) => Name
            })
            return Name
        }
    }

    /**
     * The type of set being wrapped around by this class.
     * 
     * @returns {Class}
     * @see {@link GenericSet#SetType}
     */
    static SetType => (this.Prototype).SetType

    /**
     * The type of set being wrapped around by this class.
     * 
     * This property should be overridden by subclasses of `GenericSet`.
     * 
     * @abstract
     * @returns {Class}
     * @example
     * Set.OfType(String).SetType.ToString().MsgBox() ; "class Set"
     */
    SetType {
        get {
            throw PropertyError("set type not found")
        }
    }
    
    /**
     * Name of the underlying set type.
     * 
     * @returns {String}
     */
    static SetTypeName => (this.Prototype).SetTypeName

    /**
     * Name of the underlying set type.
     * 
     * @returns {String}
     */
    SetTypeName {
        get {
            Name := (this.SetType).Prototype.__Class
            DefineProp(OwnerOfProp(this, "SetType"), "SetTypeName", {
                Get: (_) => Name
            })
            return Name
        }
    }

    /**
     * The component type of this generic set, which describes the type of
     * elements enforced.
     * 
     * @property {Any}
     * @see {@link GenericSet#ComponentType}
     */
    static ComponentType => (this.Prototype).ComponentType

    /**
     * The component type of this generic set, which describes the type of
     * elements enforced.
     * 
     * This property should be overridden by subclasses of `GenericSet`.
     * 
     * @abstract
     * @property {Any}
     * @example
     * S := Set.OfType(Integer)
     * S.ComponentType().ToString().MsgBox() ; "class String"
     */
    ComponentType {
        get {
            throw PropertyError("component type not found")
        }
    }

    /**
     * Name of the component type used in this generic set class.
     * 
     * @property {String}
     */
    static ComponentTypeName => (this.Prototype).ComponentTypeName

    /**
     * Name of the component type used in this generic set.
     * 
     * @property {String}
     */
    ComponentTypeName {
        get {
            T := this.ComponentType
            if (T is Class) {
                Name := T.Prototype.__Class
            } else if (IsSet(AquaHotkey_ToString)) {
                Name := String(T)
            } else {
                Name := Type(T)
            }

            DefineProp(
                    OwnerOfProp(this, "ComponentType"),
                    "ComponentTypeName",
                    { Get: (_) => Name })
            return Name
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Duck Types

    /**
     * Determines whether the given input is considered equivalent to, or a
     * subtype of this generic set class.
     * 
     * This depends on the set and component type used by the class.
     * 
     * @param   {Any?}  T  any value
     * @returns {Boolean}
     * @example
     * Set.OfType(Nullable)
     */
    static CanCastFrom(T) {
        if (!IsSet(T)) {
            return false
        }
        if (super.CanCastFrom(T)) {
            return true
        }
        if (!HasBase(T, GenericSet)) {
            return false
        }
        return (this.SetType).CanCastFrom(T.SetType)
            && (this.ComponentType).CanCastFrom(T.ComponentType)
    }

    /**
     * Determines whether the given value is an instance of this generic set
     * class.
     * 
     * If the tested value is a generic set, its set and component
     * type are checked for compatibility via `.CanCastFrom()`. On regular
     * set, the type of set and its elements are checked.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * Set(1, 2, 3).Is( ISet.OfType(Number) ) ; true
     */
    static IsInstance(Val?) {
        if (!IsSet(Val) || !ISet.IsInstance(Val)) {
            return false
        }
        if (Val is GenericSet) {
            return (this.SetType).CanCastFrom(Val.SetType)
                && (this.ComponentType).CanCastFrom(Val.ComponentType)
        }

        if (!(this.SetType).IsInstance(Val)) {
            return false
        }
        T := this.ComponentType
        for Elem in Val {
            if (!T.IsInstance(Elem?)) {
                return false
            }
        }
        return true
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Commons

    /**
     * Creates a hash code for this generic set.
     * 
     * @returns {Integer}
     */
    HashCode() => (this.S).HashCode()

    /**
     * Creates a hash code for this generic set class.
     * 
     * @returns {Integer}
     */
    static HashCode() => Any.Hash(this.SetType, this.ComponentType)

    /**
     * Determins whether this class is equal to the given value.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     */
    static Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!HasBase(Other, GenericSet)) {
            return false
        }
        return (this.SetType).Eq(Other.SetType)
            && (this.ComponentType).Eq(Other.ComponentType)
    }

    /**
     * Returns the string representation of this generic set.
     * 
     * @returns {String}
     */
    ToString() => this.ClassName . String(this.S)

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Implementation

    /**
     * Adds zero or more values to the set.
     * 
     * @param   {Any*}  Values  zero or more elements
     * @returns {Integer} number of elements added
     */
    Add(Values*) {
        for Value in Values {
            if (!this.ComponentType.IsInstance(Value?)) {
                throw TypeError("Expected a(n) " . this.ComponentTypeName, -2,
                        Type(Value))
            }
        }
        return (this.S).Add(Values*)
    }

    /**
     * Clears the set.
     */
    Clear() {
        (this.S).Clear()
    }

    /**
     * Creates a clone of the set.
     * 
     * @returns {GenericSet}
     */
    Clone() => DefineConst({ base: this }, "S", (this.S).Clone())

    /**
     * Deletes zero or more elements from the set.
     * 
     * @param   {Any*}  Values  zero or more elements
     * @returns {Integer} number of elements deleted
     */
    Delete(Values*) => (this.S).Delete(Values*)

    /**
     * Determines whether the given element is part of the set.
     * 
     * @param   {Any}  Value  the value to check
     * @returns {Boolean}
     */
    Contains(Value) => (this.S).Contains(Value)

    /**
     * Returns an {@link Enumerator} that enumerates all elements of this
     * set.
     * 
     * @param   {Integer?}  ArgSize  argument size
     * @returns {Enumerator}
     */
    __Enum(ArgSize := 1) => (this.S).__Enum(ArgSize)

    /**
     * Size of the set.
     * 
     * @returns {Integer}
     */
    Size => (this.S).Size

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

/**
 * Extension methods related to {@link GenericSet}.
 */
class AquaHotkey_GenericSet extends AquaHotkey {
    static __New() {
        if (this != AquaHotkey_GenericSet) {
            return
        }

        if (IsSet(AquaHotkey_cfg_DisableGenerics)) {
            DefineMethod(this.ISet, "OfType", (Cls, T, Constraint?) => Cls)
        } else {
            DefineMethod(this.ISet, "OfType",
                ; (Cls, T) => AquaHotkey.CreateClass(GenericSet, "", Cls, T)
                ObjBindMethod(AquaHotkey, "CreateClass", GenericSet, ""))
        }
        super.__New()
    }

    class ISet {
        /**
         * Returns a type-checked set of the given type, and optional type
         * constraint.
         * 
         * @inlined
         * @param   {Any}   T  pattern
         * @returns {Class}
         */
        static OfType(T) {
            return AquaHotkey.CreateClass(GenericSet,
                    unset, ; let `static __New()` do the work
                    this, T)
        }
    }
}

/**
 * {@link AquaHotkey_Serialization binary serialization} support for
 * {@link GenericSet}.
 */
class AquaHotkey_GenericSet_Serialization extends AquaHotkey {
    static __New() => IsSet(AquaHotkey_Serializer) && super.__New()

    class GenericSet {
        /**
         * Serializes the generic set into binary.
         * 
         * @param   {OutputStream}  Output  output stream
         * @param   {Map}           Refs    map of previously seen objects
         * @see {@link AquaHotkey_Serializer}
         */
        Serialize(Output, Refs) {
            (Object.Prototype.Serialize)(this, Output, Refs)
            Output.WriteObject(this.SetType, Refs)
            Output.WriteObject(this.ComponentType, Refs)
            Output.WriteObject(this.S)
        }

        /**
         * Reconstructs the generic set from binary.
         * 
         * @param   {InputStream}  Input  input stream
         * @param   {Map}          Refs   map of previously seen objects
         * @see {@link AquaHotkey_Serializer}
         */
        Deserialize(Input, Refs) {
            Input.ReadObject(&SetType, Refs)
            Input.ReadObject(&ComponentType, Refs)
            if (!IsSet(AquaHotkey_cfg_DisableGenerics)) {
                ComponentType := Any
            }
            ObjSetBase(this, AquaHotkey.CreateClass(GenericSet,,
                    SetType, ComponentType).Prototype)

            Input.ReadObject(&S, Refs)
            DefineConst(this, "S", S)
        }
    }
}

;@endregion

