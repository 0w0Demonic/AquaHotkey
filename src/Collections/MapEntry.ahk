#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IMap.ahk"
#Include "%A_LineFile%\..\Entry.ahk"

;@region MapEntry

/**
 * Represents a map entry directly associated with a map.
 * Changing the value of the entry writes through the backing map.
 * 
 * @module  <Collections/MapEntry>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class MapEntry extends IMapEntry {
    /**
     * Map entry value. Changing the value also changes the map item.
     */
    Value {
        get => (this.M).Get(this.Key)
        set {
            if (!(this.M).Has(this.Key)) {
                throw UnsetItemError("item does not exist")
            }
            (this.M).Set(this.Key, value)
        }
    }

    /**
     * Determines whether this map entry exists in the backing map.
     * 
     * @returns {Boolean}
     */
    Exists => (this.M).Has(this.Key)
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
        Entry(Key) {
            Entry := {}
            ObjSetBase(Entry, MapEntry.Prototype)
            ({}.DefineProp)(Entry, "M",   { Get: (_) => this })
            ({}.DefineProp)(Entry, "Key", { Get: (_) => Key  })
            return Entry
        }
    }
}

;@endregion

