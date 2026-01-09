;#Include "%A_LineFile%\..\..\..\Core\AquaHotkey.ahk"
#Include <AquaHotkeyX>
#Include <AquaHotkey\src\Collections\Generic\Array>

; TODO type casting
; TODO also allow functions instead of doing simple type-checks?

/**
 * Introduces type-checked maps, in which key-value pairs are enforced to
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
 * ; you can use `is` to determine the type of map
 * MsgBox(  M is Map.OfType(String, Integer)  ) ; true
 * 
 * ; the map enforces keys/values to be the specified type
 * M["foo"] := "qux" ; Error! Expected an Integer.
 * M[123]   := 23456 ; Error! Expected a String.
 */
class GenericMap extends Map {
    /**
     * Constructs a new subclass of `GenericMap`.
     * 
     * @param   {Class}  K  key type
     * @param   {Class}  V  value type
     * @example
     * Map.Of(String, Integer)
     */
    static __New(K?, V?) {
        static Define := {}.DefineProp

        if (this == GenericMap) {
            ; alias `.__New()` and `.Set()`
            ({}.DefineProp)(this.Prototype, "__New",
                    ({}.GetOwnPropDesc)(this.Prototype, "Set"))
            return
        }

        if (!IsSet(K)) {
            throw UnsetError("unset value")
        }
        if (!IsSet(V)) {
            throw UnsetError("unset value")
        }
        if (!(K is Class)) {
            throw TypeError("Expected a Class",, Type(K))
        }
        if (!(V is Class)) {
            throw TypeError("Expected a Class",, Type(V))
        }
        Proto := this.Prototype
        Define(Proto, "Check",     { Call: TypeCheck })
        Define(Proto, "KeyType",   { Get: (_) => K })
        Define(Proto, "ValueType", { Get: (_) => V })

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

    /**
     * Returns the key type associated with this checked map.
     * 
     * @returns {Class}
     * @example
     * Map.Of(String, Integer).KeyType ; class String
     */
    static KeyType => (this.Prototype).KeyType

    /**
     * Returns the key type associated with this checked map.
     * 
     * @abstract
     * @returns {Class}
     * @example
     * M := Map.Of(String, Integer)("foo", 12)
     * M.KeyType ; class String
     */
    KeyType {
        get {
            throw PropertyError("abstract property")
        }
    }

    /**
     * Returns the value type associated with this checked map.
     * 
     * @returns {Class}
     * @example
     * Map.Of(String, Integer).ValueType ; class Integer
     */
    static ValueType => (this.Prototype).ValueType

    /**
     * Returns the value type associated with this checked map.
     * 
     * @abstract
     * @returns {Class}
     * @example
     * M := Map.Of(String, Integer)("foo", 12)
     * M.ValueType ; class Integer
     */
    ValueType {
        get {
            throw PropertyError("abstract property")
        }
    }

    ; TODO let this return boolean in the future?
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
     * Constructs a new checked map with the given elements.
     * 
     * @constructor
     * @param   {Any*}  Args  alternating key-value pairs
     */
    __New(Args*) => this.Set(Args*) ; NOTE: overridden by `static __New()`

    /**
     * Sets zero or more items with type-checking.
     * 
     * @param   {Any*}  Args  alternating key-value pairs.
     */
    Set(Args*) {
        if (Args.Length & 1) {
            throw ValueError("invalid param count",, Args.Length)
        }
        Enumer := Args.__Enum(1)
        while (Enumer(&K) && Enumer(&V)) {
            this.Check(K, V)
        }
        super.Set(Args*)
    }

    /**
     * Sets an element.
     * 
     * @param   {Any}  Key    map key
     * @param   {Any}  Value  new value
     */
    __Item[Key] {
        set {
            if (IsSet(value)) {
                this.Check(Key, value)
                super[Key] := value
            } else {
                super[Key] := unset
            }
        }
    }
}

class AquaHotkey_GenericMap extends AquaHotkey {
    class Class {
        /**
         * Returns a type-checked map class of this class mapped to the given
         * class representing the value type of the map class.
         * 
         * @param   {Class}  ValueType  type of values
         * @returns {Class}
         */
        MappedTo(ValueType) {
            if (!(ValueType is Class)) {
                throw TypeError("Expected a Class",, Type(ValueType))
            }
            return Map.OfType(this, ValueType)
        }
    }

    class Map {
        /**
         * Returns a type-checked map class.
         * 
         * @param   {Class}  K  type of keys
         * @param   {Class}  V  type of values
         * @returns {Class}
         */
        static OfType(K, V) {
            static Keys := Map()

            if (Keys.Has(K)) {
                Values := Keys.Get(K)
                if (Values.Has(V)) {
                    return Values.Get(V)
                }
            }

            if (!(K is Class)) {
                throw TypeError("Expected a Class",, Type(K))
            }
            if (!(V is Class)) {
                throw TypeError("Expected a Class",, Type(V))
            }

            ClsName := Format("{}<{}, {}>",
                    this.Prototype.__Class,
                    K.Prototype.__Class, V.Prototype.__Class)

            MapType := AquaHotkey.CreateClass(
                    GenericMap,
                    ClsName,
                    K, V)

            if (!Keys.Has(K)) {
                Keys.Set(K, Map())
            }
            Values := Keys.Get(K)
            Values.Set(V, MapType)
            return MapType
        }
    }
}
