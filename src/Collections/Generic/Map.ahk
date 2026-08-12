#Include "%A_LineFile%\..\..\..\Core\Utils.ahk"
#Include "%A_LineFile%\..\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\..\Base\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\..\Base\Hash.ahk"
#Include "%A_LineFile%\..\..\..\Base\Eq.ahk"

;@region GenericMap

; TODO find a way to switch off value checking to make interop with ISet easier
; TODO `.ToString()` names itself "map" twice -- change that?

/**
 * Introduces generic maps, in which key-value pairs are enforced to
 * be instance of the given types.
 * 
 * @module  <Collections/Generic/Map>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * 
 * ; create a new map
 * M := Map.OfType(String, Integer)("foo", 12, "bar", 24)
 * 
 * ; the map enforces keys/values to be the specified type
 * M["foo"] := "qux" ; Error! Expected an Integer.
 * M[123]   := 23456 ; Error! Expected a String.
 */
class GenericMap extends IMap {
    ;@region Construction

    /**
     * Constructs a new subclass of `GenericMap`.
     * 
     * @param   {Class}  M  map type
     * @param   {Class}  K  key type
     * @param   {Class}  V  value type
     * @example
     * Map.OfType(String, Integer)
     */
    static __New(M := Map, K?, V?) {
        if (this == GenericMap) {
            return
        }
        if (!IsSet(K)) {
            throw UnsetError("unset value")
        }
        if (!IsSet(V)) {
            throw UnsetError("unset value")
        }
        if (!(M is Class)) {
            throw TypeError("Expected a class",, Type(M))
        }
        if ((M != IMap) && !HasBase(M, IMap)) {
            throw TypeError("Expected an IMap class",, M.Prototype.__Class)
        }

        ; make sure that class prototypes are disposable.
        DeleteProp(this.Prototype, "__Class")
        DefineConsts(this.Prototype, {
            MapType:   M,
            KeyType:   K,
            ValueType: V
        })
    }

    /**
     * Creates a new generic map containing the given elements.
     * 
     * @constructor
     * @param   {Any*}  Args  alternating key-value pairs
     */
    __New(Args*) {
        DefineConst(this, "M", (this.MapType)()).Set(Args*)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Type Info

    /**
     * The name of the class. This property is meant to be an override for
     * the `Class#Name` property defined in {@link AquaHotkey_TypeInfo}, as
     * `.__Class` cannot be used to determine the name of the class.
     * 
     * @returns {String}
     */
    static Name => (this.Prototype).ClassName

    /**
     * The name of the class. Provides information about the map, key and
     * value type.
     * 
     * @returns {String}
     */
    ClassName {
        get {
            Name := Format(
                "{}<{}, {}>",
                this.MapTypeName,
                this.KeyTypeName,
                this.ValueTypeName)
            DefineConst(OwnerOfProp(this, "MapType"), "ClassName", Name)
            return Name
        }
    }

    /**
     * Returns the map type this class wraps around.
     * 
     * @returns {Class}
     * @example
     * HashMap.OfType(String, Integer).MapType ; class HashMap
     */
    static MapType => (this.Prototype).MapType

    /**
     * Returns the map type which the generic map wraps around.
     * 
     * @abstract
     * @returns {Class}
     * @example
     * M := SkipListMap.OfType(String, { Value: Integer })
     * M.MapType ; SkipListMap
     */
    MapType {
        get {
            throw PropertyError("abstract property")
        }
    }

    /**
     * Name of the underlying map.
     * 
     * @returns {String}
     */
    static MapTypeName => (this.Prototype).MapTypeName

    /**
     * Name of the underlying map.
     * 
     * @returns {String}
     */
    MapTypeName {
        get {
            Name := (this.MapType).Prototype.__Class
            DefineConst(OwnerOfProp(this, "MapType"), "MapTypeName", Name)
            return Name
        }
    }

    /**
     * Returns the key type associated with this generic map.
     * 
     * @returns {Class}
     * @example
     * Map.OfType(String, Integer).KeyType ; class String
     */
    static KeyType => (this.Prototype).KeyType

    /**
     * Returns the key type associated with this generic map.
     * 
     * @abstract
     * @returns {Class}
     * @example
     * M := Map.OfType(String, Integer)("foo", 12)
     * M.KeyType ; class String
     */
    KeyType {
        get {
            throw PropertyError("abstract property")
        }
    }

    /**
     * Name of the key type in this generic map class.
     * 
     * @returns {String}
     */
    static KeyTypeName => (this.Prototype).KeyTypeName

    /**
     * Name of the key type in this generic map.
     * 
     * @returns {String}
     */
    KeyTypeName {
        get {
            T := this.KeyType
            if (T is Class) {
                Name := T.Prototype.__Class
            } else if (IsSet(AquaHotkey_ToString)) {
                Name := String(T)
            } else {
                Name := Type(T)
            }
            DefineConst(OwnerOfProp(this, "KeyType"), "KeyTypeName", Name)
            return Name
        }
    }

    /**
     * Returns the value type associated with this generic map.
     * 
     * @returns {Class}
     * @example
     * Map.OfType(String, Integer).ValueType ; class Integer
     */
    static ValueType => (this.Prototype).ValueType

    /**
     * Returns the value type associated with this generic map.
     * 
     * @abstract
     * @returns {Class}
     * @example
     * M := Map.OfType(String, Integer)("foo", 12)
     * M.ValueType ; class Integer
     */
    ValueType {
        get {
            throw PropertyError("abstract property")
        }
    }

    /**
     * The name of the value type in this generic map class.
     * 
     * @returns {String}
     */
    static ValueTypeName => (this.Prototype).ValueTypeName

    /**
     * The name of the value type in this generic map.
     * 
     * @returns {String}
     */
    ValueTypeName {
        get {
            T := this.ValueType
            if (T is Class) {
                Name := T.Prototype.__Class
            } else if (IsSet(AquaHotkey_ToString)) {
                Name := String(T)
            } else {
                Name := Type(T)
            }
            DefineConst(OwnerOfProp(this, "ValueType"), "ValueTypeName", Name)
            return Name
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Duck Types

    /**
     * Determines whether the given value is an instance of the generic
     * map class.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * HashMap(1, 2, 34.5, 4,6).Is(  HashMap.OfType(Number, Number)  ) ; true
     */
    static IsInstance(Val?) {
        if (!IsSet(Val) || !IMap.IsInstance(Val)) {
            return false
        }

        if (Val is GenericMap) {
            return (this.MapType).CanCastFrom(Val.MapType)
                && (this.KeyType).CanCastFrom(Val.KeyType)
                && (this.ValueType).CanCastFrom(Val.ValueType)
        }

        if (!(this.MapType).IsInstance(Val)) {
            false
        }
        K := this.KeyType
        V := this.ValueType
        for Key, Value in Val {
            if (!K.IsInstance(Key?) || !V.IsInstance(Value?)) {
                return false
            }
        }
        return true
    }

    /**
     * Determines whether the given value is considered a subtype of this
     * generic array class.
     * 
     * @param   {Any?}  T  any value
     * @returns {Boolean}
     * @example
     * T1 := IMap.OfType(Number, Number)
     * T2 := HashMap.OfType(Integer, Integer)
     * 
     * T1.CanCastFrom(T2) ; true
     */
    static CanCastFrom(T?) {
        if (!IsSet(T)) {
            return false
        }
        if (super.CanCastFrom(T)) {
            return true
        }
        if (!HasBase(T, GenericMap)) {
            return false
        }
        return (this.MapType).CanCastFrom(T.MapType)
            && (this.KeyType).CanCastFrom(T.KeyType)
            && (this.ValueType).CanCastFrom(T.ValueType)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Commons

    /**
     * Returns this generic map represented as string.
     * 
     * @returns {String}
     */
    ToString() => this.ClassName . String(this.M)

    /**
     * Returns a hash code for this generic map class.
     * 
     * @returns {Integer}
     */
    static HashCode() => Any.Hash(this.MapType, this.KeyType, this.ValueType)

    /**
     * Determines whether the given value is equal to this generic map class.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     * @example
     * C1 := Map.OfType(Integer, String)
     * C2 := Map.OfType(Integer, String)
     * 
     * C1.Eq(C2)
     * ; --> Map.Eq(Map) && Integer.Eq(Integer) && String.Eq(String)
     * ; --> true
     */
    static Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        return HasBase(Other, GenericMap)
            && (this.MapType).Eq(Other.MapType)
            && (this.KeyType).Eq(Other.KeyType)
            && (this.ValueType).Eq(Other.ValueType)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Type Checking

    /**
     * Determines whether the given key-value is valid for this map.
     * This method should be overridden by subclasses.
     * 
     * @param   {Any}  Key    key
     * @param   {Any}  Value  value
     */
    Check(Key, Value) {
        if (!(this.KeyType).IsInstance(Key)) {
            throw TypeError("Invalid key type; Expected a(n) "
                    . this.KeyTypeName, -2, Type(Key))
        }
        if (!(this.ValueType).IsInstance(Value)) {
            throw TypeError("Invalid value type; Expected a(n) "
                    . this.ValueTypeName, -2, Type(Value))
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Implementation

    /**
     * Clears the map.
     */
    Clear() {
        (this.M).Clear()
    }

    /**
     * Deletes an items from the map.
     * 
     * @param   {Any}  Key  any value
     * @returns {Any}
     */
    Delete(Key) => (this.M).Delete(Key)

    /**
     * Gets an item from the map.
     * 
     * @param   {Any}   Key      any value
     * @param   {Any?}  Default  default value
     */
    Get(Key, Default?) => (this.M).Get(Key, Default?)

    /**
     * Determines whether an item is present in the map.
     * 
     * @param   {Any}  Key  any value
     * @returns {Boolean}
     */
    Has(Key) => (this.M).Has(Key)

    /**
     * Sets zero or more items.
     * 
     * @param   {Any*}  Args  alternating key-value pairs
     */
    Set(Args*) {
        if (Args.Length & 1) {
            throw ValueError("invalid param count",, Args.Length)
        }
        Enumer := Args.__Enum(1)
        while (Enumer(&Key) && Enumer(&Value)) {
            this.Check(Key, Value)
        }
        (this.M).Set(Args*)
    }

    /**
     * Returns an {@link Enumerator} for this map.
     * 
     * @param   {Integer?}  ArgSize  argument size
     * @returns {Enumerator}
     */
    __Enum(ArgSize := 1) => (this.M).__Enum(ArgSize)

    /**
     * The number of items present in the map.
     * 
     * @returns {Integer}
     */
    Count => (this.M).Count

    /**
     * Gets or sets an item.
     * 
     * @param   {Any}  Key    map key
     * @param   {Any}  Value  associated value
     * @returns {Any}
     */
    __Item[Key] {
        set {
            this.Check(Key, value)
            (this.M)[Key] := value
        }
    }

    /**
     * Capacity of the backing map.
     * 
     * @param   {Integer}  value  new capacity
     * @returns {Integer}
     */
    Capacity {
        get => (this.M).Capacity
        set {
            (this.M).Capacity := value
        }
    }

    /**
     * Case sensitivity of the backing map.
     * 
     * @param   {Primitive}  value  new case sensitivity
     * @returns {Integer}
     */
    CaseSense {
        get => (this.M).CaseSense
        set {
            (this.M).CaseSense := value
        }
    }

    /**
     * Default value returned, if an item is not present.
     * 
     * @param   {Any?}  value  new default value
     * @returns {Any}
     */
    Default {
        get => (this.M).Default
        set {
            (this.M).Default := (value?)
        }
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

/**
 * Extension methods related to {@link GenericMap}.
 */
class AquaHotkey_GenericMap extends AquaHotkey {
    static __New() {
        if (this != AquaHotkey_GenericMap) {
            return
        }

        if (IsSet(AquaHotkey_cfg_DisableGenerics)) {
            DefineMethod(this.IMap, "OfType", (Cls, K, V) => Cls)
        } else {
            DefineMethod(this.IMap, "OfType",
                ; (Cls, K, V) => CreateClass(GenericMap, "", Cls, K, V)
                ObjBindMethod(CreateClass,, GenericMap, ""))
        }
        super.__New()
    }

    class IMap {
        /**
         * Returns a generic map class.
         * 
         * @inlined
         * @param   {Any}  K  type of keys
         * @param   {Any}  V  type of values
         * @returns {Class<? extends IMap>}
         */
        static OfType(K, V) => CreateClass(GenericMap, unset, this, K, V)
    }
}

/**
 * {@link AquaHotkey_Serializer binary serialization} support for
 * {@link GenericMap}.
 */
class AquaHotkey_GenericMap_Serialization extends AquaHotkey {
    static __New() => IsSet(AquaHotkey_Serializer) && super.__New()

    class GenericMap {
        /**
         * Serializes the generic array into binary.
         * 
         * @param   {OutputStream}  Output  output stream
         * @param   {Map}           Refs    map of previously seen objects
         * @see {@link AquaHotkey_Serializer}
         */
        Serialize(Output, Refs) {
            (Object.Prototype.Serialize)(this, Output, Refs)
            Output.WriteObject(this.MapType, Refs)
            Output.WriteObject(this.KeyType, Refs)
            Output.WriteObject(this.ValueType, Refs)
            Output.WriteObject(this.M, Refs)
        }

        /**
         * Reconstructs the generic map from binary.
         * 
         * @param   {InputStream}  Input  input stream
         * @param   {Map}          Refs   map of previously seen objects
         * @see {@link AquaHotkey_Serializer}
         */
        Deserialize(Input, Refs) {
            Input.ReadObject(&MapType, Refs)
            Input.ReadObject(&KeyType, Refs)
            Input.ReadObject(&ValueType, Refs)
            if (IsSet(AquaHotkey_cfg_DisableGenerics)) {
                KeyType := Any ; maps can never contain `unset`
                ValueType := Any
            }
            ObjSetBase(this,
                CreateClass(GenericMap,, MapType, KeyType, ValueType)
                        .Prototype)

            Input.ReadObject(&M, Refs)
            DefineConst(this, "M", M)
        }
    }
}

/**
 * {@link AquaHotkey_Json JSON bindings} for {@link GenericMap}.
 */
class AquaHotkey_GenericMap_Json extends AquaHotkey {
    static __New() => IsSet(AquaHotkey_Json) && super.__New()

    ; TODO how to convert elements, but not the class itself?

    class GenericMap {
        /**
         * Casts a JSON value into a generic map.
         * 
         * @param   {VarRef<Any>}  Val  any value
         */
        static CastFromJson(&Val) {
            static GetProp := {}.GetOwnPropDesc

            if (!(Val is Map)) {
                throw TypeError("Expected a map",, Type(Val))
            }
            K := this.KeyType
            V := this.ValueType

            Result := Array()
            for Key, Value in Val {
                K.CastFromJson(&Key)
                V.CastFromJson(&Value)
                Result.Push(Key, Value)
            }
            Val := this(Result*)
        }
    }
}

;@endregion

