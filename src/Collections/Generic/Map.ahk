#Include "%A_LineFile%\..\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\..\Interfaces\IDelegatingMap.ahk"

;@region GenericMap
/**
 * Introduces generic maps, in which key-value pairs are enforced to
 * be instanced of the given types.
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

        Proto := this.Prototype
        Define(Proto, "Check",     { Call: TypeCheck })
        Define(Proto, "MapType",   { Get: (_) => M })
        Define(Proto, "KeyType",   { Get: (_) => K })
        Define(Proto, "ValueType", { Get: (_) => V })
        Define(Proto, "Class",     { Get: (_) => this }) ; <Base/TypeInfo>

        TypeCheck(_, Key, Value) {
            if (!Key.Is(K)) {
                throw TypeError(
                        "Expected a(n) " . K.Name . " as key",
                        -2, Type(Key))
            }
            if (!Value.Is(V)) {
                throw TypeError(
                        "Expected a(n) " . V.Name . " as value",
                        -2, Type(Value))
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Type Info

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
     * Returns a hash code for this generic map class.
     * 
     * @returns {Integer}
     */
    static HashCode() => Any.Hash(this.MapType, this.KeyType, this.ValueType)
    
    ; ; TODO implement these two according to our contract
    ; HashCode() {
    ;     throw PropertyError("not implemented yet")
    ; }

    ; Eq(Other?) {
    ;     throw PropertyError("not implemented yet")
    ; }

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
    ;@region Implementation

    /**
     * Determines whether the given key-value is valid for this map.
     * This method should be overridden by subclasses.
     * 
     * @param   {Any}  K  key
     * @param   {Any}  V  value
     */
    Check(K, V) {
        ; nop
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
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

/**
 * Extension methods related to {@link GenericMap}.
 */
class AquaHotkey_GenericMap extends AquaHotkey {
    class IMap {
        /**
         * Returns a generic map class.
         * 
         * @param   {Any}  K  type of keys
         * @param   {Any}  V  type of values
         * @returns {Class<? extends IMap>}
         */
        static OfType(K, V) {
            OwnName   := this.Prototype.__Class
            KeyName   := (K is Class) ? K.Prototype.__Class : String(K)
            ValueName := (V is Class) ? V.Prototype.__Class : String(V)
            return AquaHotkey.CreateClass(
                    GenericMap,
                    OwnName . "<" . KeyName . ", " . ValueName . ">",
                    this, K, V)
        }
    }
}

;@endregion
