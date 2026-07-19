#Include "%A_LineFile%\..\..\Interfaces\ISet.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IMapEntry.ahk"
#Include "%A_LineFile%\..\..\Collections\MapEntry.ahk"
#Include "%A_LineFile%\..\..\Base\Eq.ahk"

/**
 * A map viewed as a set of map entries.
 * 
 * @module  <Collections/MapEntrySet>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
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

    /**
     * Deletes items from the set. This method expects map entries
     * as argument. Only the map key must match, not the value.
     * 
     * @param   {Any*}  Entries  map entries
     * @returns {Integer}
     */
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

    /**
     * Determines whether the given map entry is present in this entry set.
     * The backing map must be able to retrieve an item from the map key,
     * and the value must be equal (@link AquaHotkey_Eq `.Eq()`).
     * 
     * @param   {Any}  Entry  any value
     * @returns {Boolean}
     */
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
 * Extensions related to {@link MapEntrySet}.
 */
class AquaHotkey_MapEntrySet extends AquaHotkey {
    class IMap {
        static __New() {
            ({}.DefineProp)(this.Prototype, "AsEntrySet",
                    { Call: MapEntrySet })
        }

        /**
         * Returns this map viewed as an {@link ISet} of
         * {@link IMapEntry map entries}.
         * 
         * @returns {MapEntrySet}
         */
        AsEntrySet() => MapEntrySet(this)

        /**
         * Returns a snapshot of this map viewed as an {@link ISet} of
         * {@link IMapEntry map entries}.
         * 
         * @returns {MapEntrySet}.
         */
        ToEntrySet() => MapEntrySet(this.Clone())
    }
}

