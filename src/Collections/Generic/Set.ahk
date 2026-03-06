#Include "%A_LineFile%\..\..\..\Base\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\..\Base\Eq.ahk"
#Include "%A_LineFile%\..\..\..\Base\Hash.ahk"
#Include "%A_LineFile%\..\..\..\Interfaces\ISet.ahk"
#Include "%A_LineFile%\..\..\..\IO\Serializer.ahk"

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
class GenericSet extends ISet {
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

        static Define := {}.DefineProp
        static Delete := {}.DeleteProp

        if (!IsSet(S)) {
            throw UnsetError("unset; Expected an ISet class")
        }
        if (!IsSet(T)) {
            throw UnsetError("unset; Expected element type")
        }
        if (!ISet.CanCastFrom(S)) {
            throw TypeError("Expected an ISet class",, String(S))
        }

        OuterType := S.Prototype.__Class
        InnerType := (T is Class) ? T.Prototype.__Class : String(T)
        ClassName := (OuterType . "<" . InnerType . ">")

        Delete(this.Prototype, "__Class")
        Define(this, "Name", { Get: (_) => ClassName })
        Define(this.Prototype, "ToString",      { Call: ToString })
        Define(this.Prototype, "ComponentType", { Get: (_) => T })
        Define(this.Prototype, "SetType",       { Get: (_) => S })

        ToString(this) => ClassName . String(this.S)
    }

    /**
     * Creates a new generic set containing the given elements.
     * 
     * @constructor
     * @param   {Any*}  Values  zero or more elements
     */
    __New(Values*) {
        S := (this.SetType)()
        this.DefineProp("S", { Get: (_) => S })
        this.Add(Values*)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Type Info

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
     * The type of set being wrapped around by this class.
     * 
     * @property {Class}
     * @see {@link GenericSet#SetType}
     */
    static SetType => (this.Prototype).SetType

    /**
     * The type of set being wrapped around by this class.
     * 
     * This property should be overridden by subclasses of `GenericSet`.
     * 
     * @abstract
     * @property {Class}
     * @example
     * Set.OfType(String).SetType.ToString().MsgBox() ; "class Set"
     */
    SetType {
      get {
        throw PropertyError("set type not found")
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
     * @param   {Any}  Other  other generic set class
     * @returns {Boolean}
     * @example
     * Set.OfType(Nullable)
     */
    static CanCastFrom(Other) {
        if (super.CanCastFrom(Other)) {
            return true
        }
        if (!HasBase(Other, GenericSet)) {
            return false
        }
        return (this.SetType).CanCastFrom(Other.SetType)
            && (this.ComponentType).CanCastFrom(Other.ComponentType)
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
        if (!IsSet(Val) || !Val.Is(ISet)) {
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
    ToString() => Type(this) . String(this.S)

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Serialization

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
        Output.WriteUInt(this.Size)
        for Value in this {
            Output.WriteObject(Value?, Refs)
        }
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
        Cls := AquaHotkey.CreateClass(GenericSet,, SetType, ComponentType)
        ObjSetBase(this, Cls.Prototype)

        this.__Init()
        this.__New()

        Size := Input.ReadUInt()
        loop Size {
            Input.ReadObject(&Value, Refs)
            this.Push(Value?)
        }
    }

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
                throw TypeError("Expected " . String(this.ComponentType),,
                        IsSet(Val) ? Type(Val) : "unset")
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
    Clone() {
        Copy := (this.S).Clone()

        Obj := Object()
        Obj.DefineProp("S", { Get: (_) => Copy })

        ObjSetBase(Obj, ObjGetBase(this))
        return Obj
    }

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
     * @returns {Enumerator}
     */
    __Enum(ArgSize) => (this.S).__Enum(ArgSize)

    /**
     * Size of the set.
     * 
     * @returns {Integer}
     */
    Size => (this.S).Size
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
            ({}.DefineProp)(this.ISet, "OfType", { Call: Disabled_OfType })
        }
        super.__New()

        static Disabled_OfType(Cls, T, Constraint?) => Cls
    }

    class ISet {
        /**
         * Returns a type-checked set of the given type, and optional type
         * constraint.
         * 
         * @param   {Any}   T           type pattern
         * @returns {Class}
         */
        static OfType(T) {
            return AquaHotkey.CreateClass(GenericSet,
                    unset, ; let `static __New()` do the work
                    this, T)
        }
    }
}

;@endregion
