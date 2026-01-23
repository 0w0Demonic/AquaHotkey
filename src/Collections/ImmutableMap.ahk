#Include <AquaHotkeyX>
#Include <AquaHotkey\src\Collections\Map>

/**
 * An immutable view of an {@link IMap}.
 * 
 * @module  <Collections/ImmutableMap>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * M := Map(1, 2, 3, 4).Freeze()
 * 
 * M.Set("foo", "bar") ; Error! This map is immutable.
 */
class ImmutableMap extends IMap {
    /**
     * Creates a new immutable map consisting of the specified elements.
     * The elements themselves are still mutable.
     * 
     * @param   {Any*}  Values  zero or more elements
     * @returns {ImmutableMap}
     */
    static Call(Values*) => this.FromMap(Map(Values*))

    /**
     * Creates a new immutable map by wrapping over an existing {@link IMap}.
     * 
     * @param   {IMap}  M  a map to be wrapped over
     * @returns {ImmutableMap}
     */
    static FromMap(M) {
        if (!M.Is(IMap)) {
            throw TypeError("Expected an IMap",, Type(M))
        }
        if (M is ImmutableMap) {
            return M
        }
        Obj := Object()
        Obj.DefineProp("M", { Get: (_) => M })
        ObjSetBase(Obj, this.Prototype)
        return Obj
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
     * Returns the value to which the specified key is mapped, otherwise
     * `Default` or `MapObj.Default`.
     * 
     * @param   {Any}  Key  any key
     * @returns {Any}
     */
    Get(Key, Default?) => this.M.Get(Key, Default?)

    /**
     * Determines whether the given key is mapped to a value.
     * 
     * @param   {Any}  Key  any key
     * @returns {Any}
     */
    Has(Key) => this.M.Has(Key)

    /**
     * Unsupported `.Set()`.
     */
    Set(*) {
        throw PropertyError("This map is immutable", -2)
    }

    /**
     * Returns an `Enumerator` that enumerates the items of the map.
     * 
     * @param   {Integer}  ArgSize  param-size of for-loop
     * @returns {Enumerator}
     */
    __Enum(ArgSize) => this.M.ArgSize()

    /**
     * Returns the size of the map.
     * 
     * @returns {Integer}
     */
    Count => this.M.Count

    /**
     * Returns the size of the map.
     * 
     * @returns {Integer}
     */
    Size => this.M.Size

    /**
     * Readonly `CaseSense`.
     * 
     * @returns {Primitive}
     */
    CaseSense => this.M.CaseSense

    /**
     * Readonly `Default`.
     * 
     * @returns {Any}
     */
    Default => this.M.Default

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
        get => (this.M)[Key]
    }
}

class AquaHotkey_ImmutableMap extends AquaHotkey {
    class IMap {
        /**
         * Returns a read-only view of the map. The original map may still
         * be modified elsewhere.
         * 
         * @returns {Map}
         * @example
         * M := Map(1, 2, 3, 4)
         * Clone := M.Freeze()
         * 
         * M.Set(5, 6)     ; ok.
         * Clone.Set(5, 6) ; Error!
         */
        Freeze() => ImmutableMap.FromMap(this)
    }
}
