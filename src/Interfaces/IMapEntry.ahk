#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Base\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\Base\Eq.ahk"
#Include "%A_LineFile%\..\..\Base\Hash.ahk"
#Include "%A_LineFile%\..\..\Collections\MapEntrySet.ahk"
#Include "%A_LineFile%\..\..\Collections\MapEntry.ahk"
#Include "%A_LineFile%\..\IMap.ahk"

; TODO implement JSON bindings

;@region IMapEntry

/**
 * Represents a map entry consisting of a key and value. Map entries may either
 * be part of an existing {@link IMap} or be independant data.
 * 
 * @module  <Interfaces/IMapEntry>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class IMapEntry {
    ;@region Construction

    /**
     * Constructs a new key-value pair not associated with any map.
     * 
     * @constructor
     * @param   {Any}  Key    map entry key
     * @param   {Any}  Value  map entry value
     */
    __New(Key, Value) {
        ({}.DefineProp)(this, "Key", { Get: (_) => Key })
        ({}.DefineProp)(this, "Value", { Get: (_) => Value })
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
     * IMapEntry("foo", 42).Is(IMapEntry(String, Any)) ; true
     */
    IsInstance(Val?) => super.IsInstance(Val?)
        || ((this == IMapEntry)
            && IsSet(Val) && IsObject(Val)
            && HasProp(Val, "Key")
            && HasProp(Val, "Value"))

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Properties

    /**
     * Immutable and readonly map entry key.
     */
    Key {
        get {
            throw PropertyError("not implemented")
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
            throw PropertyError("not implemented")
        }
        set {
            throw PropertyError("not implemented")
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Map Interaction

    /**
     * Returns an independant copy of this map entry.
     * 
     * @returns {IMapEntry}
     */
    Copy() => IMapEntry(this.Key, this.Value)

    /**
     * Determines whether this map entry is part of an existing item of
     * an {@link IMap}.
     * 
     * @returns {Boolean}
     */
    Exists => false

    /**
     * Deletes this map entry from the backing map.
     * 
     * @returns {Any}
     */
    Delete() {
        throw MethodError("not implemented")
    }

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

    ; TODO how to implement `Eq()` based on backing map

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
 * {@link AquaHotkey_Serializer binary serialization} support for
 * {@link IMapEntry}.
 */
class AquaHotkey_IMapEntry_Serialization extends AquaHotkey {
    static __New() => IsSet(AquaHotkey_Serializer) && super.__New()

    class IMapEntry {
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

;@endregion

