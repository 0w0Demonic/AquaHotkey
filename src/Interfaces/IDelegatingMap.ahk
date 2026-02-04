#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * @interface
 * @description
 * 
 * Represents the base for Map classes which delegate certain operations to
 * `this.M`, which is another {@link IMap}.
 * 
 * @module  <Interfaces/IDelegatingMap>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class IDelegatingMap extends IMap {
    /**
     * Determines whether the given value is a delegating Map.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     */
    static IsInstance(Val?) {
        return super.IsInstance(Val?) ; must be an `IMap`
            && HasProp(Val, "M") ; must have a property `M` ...
            && Val.M.Is(this) ; ... whose value is also an `IMap`.
    }

    /**
     * Clears the Map.
     */
    Clear() {
        this.M.Clear()
    }

    /**
     * Removes a key-value pair from the Map.
     * 
     * @param   {Any}  Key  map key
     */
    Delete(Key) => this.M.Delete()

    /**
     * Gets a value for the given map key.
     * 
     * @param   {Any}   Key      map key
     * @param   {Any?}  Default  default value
     * @returns {Any}
     */
    Get(Key, Default?) => this.M.Get(Key, Default?)

    /**
     * Determines whether the map has a value for the given key.
     * 
     * @param   {Any}  Key  map key
     * @returns {Boolean}
     */
    Has(Key) => this.M.Has(Key)

    /**
     * Sets zero or more items.
     * 
     * @param   {Any*}  Args  alternating key-value pairs
     */
    Set(Args*) {
        this.M.Set(Args*)
    }

    /**
     * Returns an {@link Enumerator} for the Map.
     * 
     * @param   {Integer}  ArgSize  param-size of for-loop
     * @returns {Enumerator}
     */
    __Enum(ArgSize) => this.M.__Enum(ArgSize)

    /**
     * Retrieves the count of key-value pairs in the Map.
     * 
     * @returns {Integer}
     */
    Count => this.M.Count

    /**
     * Gets and sets the capacity of the Map.
     * 
     * @param   {Integer}  value  the new capacity
     * @returns {Integer}
     */
    Capacity {
        get => this.M.Capacity
        set {
            this.M.Capacity := value
        }
    }

    /**
     * Gets and sets the case sensitivity of the Map.
     * 
     * @param   {Primitive}  value  the new case sensitivity
     * @returns {Primitive}
     */
    CaseSense {
        get => this.M.CaseSense
        set {
            this.M.CaseSense := value
        }
    }

    /**
     * Gets and sets the default value of the Map.
     * 
     * @param   {Any}  value  the new default value
     * @returns {Any}
     */
    Default {
        get => this.M.Default
        set {
            this.M.Default := value
        }
    }

    /**
     * Gets or sets an item.
     * 
     * @param   {Any}   Key    map key
     * @param   {Any?}  Value  associated value
     * @returns {Any}
     */
    __Item[Key] {
        get => (this.M)[Key]
        set {
            (this.M)[Key] := (value?)
        }
    }
}