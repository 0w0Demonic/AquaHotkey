#Include "%A_LineFile%\..\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\..\Interfaces\IDelegatingMap.ahk"
#Include "%A_LineFile%\..\..\..\Base\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\..\Base\Hash.ahk"
#Include "%A_LineFile%\..\..\..\Base\Eq.ahk"
#Include "%A_LineFile%\..\..\..\IO\Serializer.ahk"

;@region GenericMap

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
class GenericMap extends IDelegatingMap {
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
        static Define := {}.DefineProp
        static Delete := {}.DeleteProp

        if (this == GenericMap) {
            return
        }
        if (!IsSet(K)) {
            throw UnsetError("unset value")
        }
        if (!IsSet(V)) {
            throw UnsetError("unset value")
        }
        if (!IMap.CanCastFrom(M)) {
            throw TypeError("Expected an IMap class",, String(M))
        }

        MapName := M.Prototype.__Class
        KeyName   := (K is Class) ? K.Prototype.__Class : String(K)
        ValueName := (V is Class) ? V.Prototype.__Class : String(V)
        ClassName := MapName . "<" . KeyName . ", " . ValueName . ">"

        ; make sure that class prototypes are disposable.
        Delete(this.Prototype, "__Class")

        ; (see <Base/TypeInfo>)
        Define(this, "Name", { Get: (_) => ClassName })
        Define(this.Prototype, "Class",     { Get: (_) => this })

        Define(this.Prototype, "ToString", { Call: ToString })
        Define(this.Prototype, "MapType",   { Get: (_) => M })
        Define(this.Prototype, "KeyType",   { Get: (_) => K })
        Define(this.Prototype, "ValueType", { Get: (_) => V })

        ToString(this) => ClassName . String(this.M)
    }

    /**
     * Creates a new generic map containing the given elements.
     * 
     * @constructor
     * @param   {Any*}  Args  alternating key-value pairs
     */
    __New(Args*) {
        M := (this.MapType)()
        ({}.DefineProp)(this, "M", { Get: (_) => M })
        M.Set(Args*)
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
        if (!IsSet(Val) || !Val.Is(IMap)) {
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
     * @param   {Any}  Other  any value
     * @returns {Boolean}
     * @example
     * T1 := IMap.OfType(Number, Number)
     * T2 := HashMap.OfType(Integer, Integer)
     * 
     * T1.CanCastFrom(T2) ; true
     */
    static CanCastFrom(Other) {
        if (super.CanCastFrom(Other)) {
            return true
        }
        if (!HasBase(Other, GenericMap)) {
            return false
        }
        return (this.MapType).CanCastFrom(Other.MapType)
            && (this.KeyType).CanCastFrom(Other.KeyType)
            && (this.ValueType).CanCastFrom(Other.ValueType)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Type Info

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
     * @property {Class}
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
     * @property {Class}
     * @example
     * M := Map.OfType(String, Integer)("foo", 12)
     * M.ValueType ; class Integer
     */
    ValueType {
      get {
        throw PropertyError("abstract property")
      }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Commons

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
            throw TypeError("invalid key type", -2)
        }
        if (!(this.ValueType).IsInstance(Value)) {
            throw TypeError("invalid value type", -2)
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Implementation

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
        this.M.Set(Args*)
    }

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

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Serialization

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
        Output.WriteUInt(this.Count)
        for Key, Value in this {
            Output.WriteObject(Key?, Refs)
            Output.WriteObject(Value?, Refs)
        }
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
            KeyType := Any
            ValueType := Any
        }

        Cls := AquaHotkey.CreateClass(GenericMap,, MapType, KeyType, ValueType)
        ObjSetBase(this, Cls.Prototype)

        this.__Init()
        this.__New()

        Count := Input.ReadUInt()
        loop Count {
            Input.ReadObject(&Key, Refs)
            Input.ReadObject(&Value, Refs)
            this.Set(Key, Value)
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
            ({}.DefineProp)(this.IMap, "OfType", { Call: Disabled_OfType })
        }
        super.__New()

        static Disabled_OfType(Cls, K, V) => Cls
    }

    class IMap {
        /**
         * Returns a generic map class.
         * 
         * @param   {Any}  K  type of keys
         * @param   {Any}  V  type of values
         * @returns {Class<? extends IMap>}
         */
        static OfType(K, V) => AquaHotkey.CreateClass(GenericMap,
                unset,
                this, K, V)
    }
}

;@endregion
