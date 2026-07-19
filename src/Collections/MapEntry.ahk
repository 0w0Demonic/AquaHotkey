#Include "%A_LineFile%\..\..\Interfaces\IMapEntry.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IMap.ahk"

;@region MapEntry

/**
 * Represents a map entry directly associated with a backing map.
 * 
 * @module  <Collections/MapEntry>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class MapEntry extends IMapEntry {
    /**
     * Creates a new map entry based off a backing map and a map key.
     * The map does not necessarily need to have an item for the specified key.
     * 
     * @constructor
     * @param   {IMap}  MapObj  backing map
     * @param   {Any}   Key     map key
     */
    __New(MapObj, Key) {
        if (!IMap.IsInstance(MapObj)) {
            throw TypeError("Expected an IMap",, Type(MapObj))
        }
        ({}.DefineProp)(this, "M",   { Get: (_) => MapObj })
        ({}.DefineProp)(this, "Key", { Get: (_) => Key    })
    }

    /**
     * Map entry key. Changing the key also changes the map item.
     */
    Key {
        ; note: `get {}` is implemented through `.__New()`
        set {
            ; TODO throw if item doesnt exist?
            if ((this.M).TryDelete(this.Key, &Current)) {
                (this.M).Set(value, Current)
            }
            ({}.DefineProp)(this, "Key", { Get: (_) => value })
        }
    }

    /**
     * Map entry value. Changing the value also changes the map item.
     */
    Value {
        get => (this.M).Get(this.Key)
        set {
            (this.M).Set(this.Key, value)
        }
    }

    /**
     * Determines whether this map entry exists in the backing map.
     * 
     * @returns {Boolean}
     */
    Exists => (this.M).Has(this.Key)

    ; TODO throw if not present?
    /**
     * Deletes this map entry from the backing map.
     * 
     * @returns {Any}
     */
    Delete() => (this.M).Delete(this.Key)
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

/**
 * Extensions related to {@link MapEntry}.
 */
class AquaHotkey_MapEntry extends AquaHotkey {
    class IMap {
        static __New() {
            ({}.DefineProp)(this.Prototype, "Entry",    { Get:  MapEntry })
            ({}.DefineProp)(this.Prototype, "GetEntry", { Call: MapEntry })
        }

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

;@endregion

