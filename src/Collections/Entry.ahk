#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Base\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\Base\Eq.ahk"
#Include "%A_LineFile%\..\..\Base\Hash.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IMap.ahk"

;@region Entry

/**
 * Represents a map entry consisting of a key and value. Map entries may either
 * be part of an existing {@link IMap} or be independant data. Neither key nor
 * value can ever be `unset`. Implementations may use a mutable value, but
 * never a mutable key.
 * 
 * @module  <Collections/Entry>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Entry {
    ;@region Construction

    /**
     * Constructs a new key-value pair not associated with any map.
     * 
     * @constructor
     * @param   {Any}  Key    map entry key
     * @param   {Any}  Value  map entry value
     */
    __New(Key, Value) {
        DefineConst(this, "Key",   Key)
        DefineConst(this, "Value", Value)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Duck Types

    /**
     * Determines whether the given value is a map entry.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * Entry("foo", 42).Is(Entry(String, Any)) ; true
     */
    static IsInstance(Val?) => super.IsInstance(Val?)
        || ((this == Entry)
            && IsSet(Val) && IsObject(Val)
            && HasProp(Val, "Key")
            && HasProp(Val, "Value"))

    /**
     * Determines whether the given value is a map entry with matching key
     * and value type.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     */
    IsInstance(Val?) {
        return Entry.IsInstance(Val?)
            && (this.Key).IsInstance(Val.Key)
            && (this.Value).IsInstance(Val.Value)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Properties

    /**
     * Immutable and readonly map entry key.
     */
    Key {
        get {
            throw PropertyError("property not found")
        }
        set {
            throw PropertyError("not implemented")
        }
    }

    /**
     * Immutable and readonly map entry value.
     */
    Value {
        get {
            throw PropertyError("value not found")
        }
        set {
            throw PropertyError("not implemented")
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Transformation

    /**
     * Returns an independant copy of this map entry.
     * 
     * @returns {Entry}
     */
    Copy() => Entry(this.Key, this.Value)

    /**
     * Returns an independant copy of this map entry with the specified key
     * and current value.
     * 
     * @param   {Any}  Key  any value
     * @returns {Entry}
     */
    WithKey(Key) => Entry(Key, this.Value)

    /**
     * Returns an independant copy of this map entr ywith the current key
     * and the specified value.
     * 
     * @param   {Any}  Value  any value
     * @returns {Entry}
     */
    WithValue(Value) => Entry(this.Key, Value)

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Commons

    /**
     * Returns the string representation of this map entry.
     * 
     * @returns {String}
     * @see {AquaHotkey_ToString}
     */
    ToString() => Type(this)
        . " { " . String(this.Key) . ": " . String(this.Value) . " }"

    /**
     * Determines whether this map entry is equal to the `Other`.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        return HasBase(Other, ObjGetBase(this))
            && (this.Key).Eq(Other.Key)
            && (this.Value).Eq(Other.Value)
    }

    /**
     * Returns a hash code for this map entry.
     * 
     * @returns {Integer}
     */
    HashCode() => (this.Key).HashCode() ^ (this.Value).HashCode()

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

/**
 * Extensions related to {@link Entry}.
 */
class AquaHotkey_Entry extends AquaHotkey {
    class IMap {
        /**
         * Determines whether the map contains the given map entry.
         * 
         * @param   {Any|Entry}  KeyOrEntry  entry or map key
         * @param   {Any?}       Value       map value
         * @returns {Boolean}
         */
        HasEntry(KeyOrEntry, Value?) {
            if (IsSet(Value)) {
                return this.TryGet(KeyOrEntry, &Curr) && Value.Eq(Curr)
            }
            if (!Entry.IsInstance(KeyOrEntry)) {
                throw TypeError("Expected a map entry",, Type(KeyOrEntry))
            }
            return this.TryGet(KeyOrEntry.Key, &Curr)
                && (KeyOrEntry.Value).Eq(Curr)
        }
    }
}

/**
 * {@link AquaHotkey_Serializer binary serialization} support for {@link Entry}.
 */
class AquaHotkey_Entry_Serialization extends AquaHotkey {
    static __New() => IsSet(AquaHotkey_Serializer) && super.__New()

    class Entry {
        /**
         * Serializes this map entry into binary.
         * 
         * @param   {OutputStream}  Output  output stream
         * @param   {Map}           Refs    previously seen objects
         */
        Serialize(Output, Refs) {
            (Object.Prototype.Serialize)(this, Output, Refs)
            Output.WriteObject(this.Key, Refs)
            Output.WriteObject(this.Value, Refs)
        }

        /**
         * Deserializes this map entry from binary.
         * 
         * @param   {InputStream}  Input  input stream
         * @param   {Map}          Refs   previously seen objects
         */
        Deserialize(Input, Refs) {
            Input.ReadObject(&Key)
            Input.ReadObject(&Value)
            this.__Init()
            this.__New(Key, Value)
        }
    }
}

/**
 * {@link AquaHotkey_Json JSON bindings} for {@Entry}.
 */
class AquaHotkey_Entry_Json extends AquaHotkey {
    static __New() => IsSet(AquaHotkey_Json) && super.__New()

    class Entry {
        /**
         * Converts this map entry to JSON.
         * 
         * @returns {String}
         */
        ToJson() => { Key: this.Key, Value: this.Value }.ToJson()

        /**
         * Creates a map entry from a plain JSON value.
         * 
         * @param   {VarRef<Any>}  Val  any value
         */
        static CastFromJson(&Val) {
            if (this != Entry) {
                throw TypeError("Not applicable for this class",,
                        this.Prototype.__Class)
            }
            if (!(Val is Map)) {
                throw TypeError("Expected a Map",, Type(Val))
            }
            Val := Entry(Val.Get("Key"), Val.Get("Value"))
        }

        /**
         * Creates a map entry from a plain JSON value, casting both key and
         * value into the specified type.
         * 
         * @param   {VarRef<Any>}  Val  any value
         */
        CastFromJson(&Val) {
            if (ObjGetBase(this) != Entry.Prototype) {
                throw TypeError("Not applicable for this type",, Type(this))
            }
            if (!(Val is Map)) {
                throw TypeError("Expected a Map",, Type(Val))
            }
            Key   := Val.Get("Key")
            Value := Val.Get("Value")
            (this.Key).CastFromJson(&Key)
            (this.Value).CastFromJson(&Value)
            Val := Entry(Key, Value)
        }
    }
}

;@endregion
