#Include <AquaHotkey>

/**
 * An immutable subclass of `Map`.
 * 
 * @module  <Collections/ImmutableMap>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * M := Map(1, 2, 3, 4).Freeze()
 * 
 * M.Set("foo", "bar") ; Error! This map is immutable.
 */
class ImmutableMap extends Map {
    /**
     * Creates an immutable map with the given key-value pairs.
     * 
     * @param   {Any*}  Values  alternating key and value
     */
    __New(Values*) {
        if (this.Count) {
            throw ValueError("This map is immutable", -2)
        }
        super.__New(Values*)
    }

    /**
     * Unsupported `.Clear()`.
     */
    Clear() {
        throw PropertyError("This map is immutable", -2)
    }

    /**
     * Unsupported `.Delete()`.
     */
    Delete(*) {
        throw PropertyError("This map is immutable", -2)
    }

    /**
     * Unsupported `.Set()`.
     */
    Set(*) {
        throw PropertyError("This map is immutable", -2)
    }

    /**
     * Readonly `CaseSense`.
     * 
     * @returns {Primitive}
     */
    CaseSense => super.CaseSense

    /**
     * Readonly `Default`.
     * 
     * @returns {Any}
     */
    Default => super.Default

    /**
     * Readonly `.__Item[]`.
     * 
     * @param   {Any}  Key  map key to be retrieved
     * @returns {Any}
     */
    __Item[Key] {
        set {
            throw PropertyError("This map is immutable")
        }
    }
}

class AquaHotkey_ImmutableMap {
    static __New() => (this == AquaHotkey_ImmutableMap)
                    && (IsSet(AquaHotkey)) && (AquaHotkey is Class)
                    && (AquaHotkey.__New)(this)

    class Map {
        /**
         * Turns a map immutable by changing its base object.
         * 
         * @returns {this}
         * @example
         * M := Map(1, 2, 3, 4).Freeze()
         */
        Freeze() {
            ObjSetBase(this, ImmutableMap.Prototype)
            return this
        }

        /**
         * Returns an immutable snapshot of the map.
         * 
         * @returns {Map}
         * @example
         * M := Map(1, 2, 3, 4)
         * Clone := M.Frozen()
         */
        Frozen() => this.Clone().Freeze()

        /**
         * Whether the map is mutable.
         * 
         * @returns {Boolean}
         */
        IsMutable => !(this is ImmutableMap)
    }
}