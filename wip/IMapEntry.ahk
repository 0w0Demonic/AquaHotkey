#Include <AquaHotkey>
#Include <AquaHotkey\src\Interfaces\ISet>

#Include <AquaHotkey\src\Base\Eq>
#Include <AquaHotkey\src\Base\Hash>

#Include <AquaHotkey\src\IO\Serial>
#Include <AquaHotkey\src\IO\Serializer>

; TODO move this class into e.g. `IMap`?
; TODO how to implement `.Clone()`?
; TODO add immutable and dependant map entry?

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
     * Determines whether a value matches the type pattern imposed by this
     * map entry. This is the case, if the value is another map entry with
     * the same base object, and if both the key and value are instances.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * IMapEntry("foo", 42).Is(IMapEntry(String, Any)) ; true
     */
    IsInstance(Val?) => IsSet(Val) && HasBase(Val, ObjGetBase(this))

    ;@endregion
    ;---------------------------------------------------------------------------

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
    ;---------------------------------------------------------------------------
    ;@region Serialization

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

    ;@endregion
}

; TODO is serialization even possible on "dependant" entries?

/**
 * Represents an existing item inside an {@link IMap}.
 */
class MapEntry extends IMapEntry {
    /**
     * Creates a new map entry based off the backing map and map key.
     * 
     * @constructor
     * @param   {IMap}  MapObj  backing map
     * @param   {Any}   Key     map key
     */
    __New(MapObj, Key) {
        if (!IMap.IsInstance(MapObj)) {
            throw TypeError("Expected an IMap",, Type(MapObj))
        }
        ({}.DefineProp)(this, "M", { Get: (_) => MapObj })
        ({}.DefineProp)(this, "Key", { Get: (_) => Key })
    }

    /**
     * Map entry key. Changing this key also changes the map item.
     */
    Key {
        set {
            (this.M).Set(value, (this.M).Delete(this.Key))
            ({}.DefineProp)(this, "Key", { Get: (_) => value })
        }
    }

    /**
     * Map entry value. Changing this value also changes the map item.
     */
    Value {
        get => (this.M).Get(this.Key)
        set {
            (this.M).Set(this.Key, value)
        }
    }

    /**
     * Determines whether this map entry is part of an existing item of
     * an {@link IMap}.
     * 
     * @returns {Boolean}
     */
    Exists => (this.M).Has(this.Key)
}

; TODO flyweight? use `.DefineProp()` to "inline" some props?

/**
 * A map viewed as a set of map entries.
 */
class MapEntrySet extends ISet {
    /**
     * Constructs a new map entry set from a backing {@link IMap}.
     * 
     * @constructor
     * @param   {IMap}  MapObj  backing map
     * @see {@link AquaHotkey_IMapEntry.IMap#AsEntrySet()}
     */
    __New(MapObj) {
        if (!IMap.IsInstance(MapObj)) {
            throw TypeError("Expected an IMap",, Type(MapObj))
        }
        ({}.DefineProp)(this, "M", { Get: (_) => MapObj })
    }

    /**
     * Clears the entry set.
     */
    Clear() {
        (this.M).Clear()
    }

    ; TODO clone -- how?

    Delete(Entries*) {
        Count := 0
        M := (this.M)

        for Entry in Entries {
            if (!IMapEntry.IsInstance(Entry?)) {
                continue
            }
            Count += !!M.TryDelete(Entry.Key)
        }
        return Count
    }

    ; TODO how to perform equality checks
    Contains(Entry) {
        if (!IMapEntry.IsInstance(Entry)) {
            return false
        }
        return (this.M).TryGet(Entry.Key, &Candidate)
            && (Entry.Key).Eq(Candidate)
    }

    /**
     * Returns an {@link Enumerator} for this map entry set. Calling this method
     * with two parameters returns the enumerator of the backing map.
     * 
     * @param  {Integer}  ArgSize  param count
     * @returns {Enumerator}
     * @example
     * for Entry in EntrySet { ... }
     * for Key, Value in EntrySet { ... }
     */
    __Enum(ArgSize) {
        M := (this.M)
        Enumer := M.__Enum(2)
        Result := (ArgSize > 1) ? MapToEntries : Enumer
        ObjSetBase(Result, Enumerator.Prototype)
        return Result

        MapToEntries(&Out) {
            if (Enumer(&Key, &Value)) {
                Out := MapEntry(M, Key)
                return true
            }
            return false
        }
    }

    /**
     * The size of the map entry set.
     * 
     * @returns {Integer}
     */
    Size => (this.M).Count
}

/**
 * Extensions related to map entries.
 */
class AquaHotkey_IMapEntry extends AquaHotkey {
    class IMap {
        static __New() {
            this.DefineProp("AsEntrySet", { Call: MapEntrySet })
            this.DefineProp("Entry", { Get: MapEntry })
            this.DefineProp("GetEntry", { Call: MapEntry })
        }

        ; TODO "inline" this
        ; TODO use the same `.AsEntrySet()`/`.ToEntrySet()` logic?

        /**
         * Returns this map viewed as an {@link ISet} of
         * {@link IMapEntry map entries}.
         * 
         * @returns {MapEntrySet}
         */
        AsEntrySet() => MapEntrySet(this) ; (inlined by `static __New()`)

        /**
         * Returns a snapshot of this map viewed as an {@link ISet} of
         * {@link IMapEntry map entries}.
         * 
         * @returns {MapEntrySet}
         */
        ToEntrySet() => MapEntrySet(this.Clone())

        ; TODO how to implement this?

        /**
         * Returns the map entry associated with this map and the given key.
         * 
         * @param   {Any}  Key  map entry key
         * @returns {MapEntry}
         */
        Entry[Key] => MapEntry(this, Key)

        /**
         * Returns the map entry associated with this map and the given key.
         * 
         * @param   {Any}  Key  map entry key
         * @returns {MapEntry}
         */
        GetEntry(Key) => MapEntry(this, Key)
    }
}
