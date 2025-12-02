#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
/**
 * AquaHotkey - Map.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/Map.ahk
 */
class AquaHotkey_Map extends AquaHotkey {
class Map {
    ;@region Configuration
    /**
     * Sets the `Default` property of the map.
     * 
     * @example
     * MapObj := Map().SetDefault("(empty)")
     * MapObj["foo"] ; "(empty)"
     * 
     * @param   {Any}  Default  new default return value
     * @returns {this}
     */
    SetDefault(Default) {
        this.Default := Default
        return this
    }

    /**
     * Sets the capacity of the map.
     * 
     * @example
     * MapObj := Map().SetCapacity(128)
     * 
     * @param   {Integer}  Capacity  new capacity
     * @returns {this}
     */
    SetCapacity(Capacity) {
        this.Capacity := Capacity
        return this
    }

    /**
     * Sets the case-sensitivity of the map.
     * 
     * @example
     * MapObj := Map().SetCaseSense(false)
     * 
     * @param   {Primitive}  CaseSense  new case-sensitivity
     * @returns {this}
     */
    SetCaseSense(CaseSense) {
        this.CaseSense := CaseSense
        return this
    }
    ;@endregion

    ;@region General
    /**
     * Returns an array of all keys in the map.
     * 
     * @example
     * Map(1, 2, "foo", "bar").Keys() ; [1, "foo"]
     * 
     * @returns {Array}
     */
    Keys() => Array(this*)

    /**
     * Returns an array of all values in the map.
     * 
     * @example
     * Map(1, 2, "foo", "bar").Values() ; [2, "bar"]
     * 
     * @returns {Array}
     */
    Values() => Array(this.__Enum(2).Bind(&Ignore)*)

    /**
     * Returns `true`, if this map is empty (has no entries).
     * 
     * @example
     * Map().IsEmpty ; true
     * Map(1, 2, "foo", "bar").IsEmpty ; false
     * 
     * @returns {Boolean}
     */
    IsEmpty => (!this.Count)
    ;@endregion

    ;@region Mutations
    /**
     * If absent, adds a new map element.
     * 
     * @example
     * ; Map { "foo" => "bar" }
     * Map().PutIfAbsent("foo", "bar") ; "bar"
     * 
     * @param   {Any}  Key    map key
     * @param   {Any}  Value  value associated with map key
     * @returns {this}
     */
    PutIfAbsent(Key, Value) {
        (this.Has(Key) || this[Key] := Value)
        return this
    }
    
    /**
     * Adds a new element to the map if absent. A value is computed by applying
     * `Mapper` to the given key.
     * 
     * ```ahk
     * Mapper(Key)
     * ```
     * 
     * @example
     * ; Map { 1 => 2 }
     * Map().ComputeIfAbsent(1, (Key => Key * 2))
     * 
     * @param   {Any}   Key     key of the map entry
     * @param   {Func}  Mapper  function that creates a new value
     * @returns {this}
     */
    ComputeIfAbsent(Key, Mapper) {
        GetMethod(Mapper)
        (this.Has(Key) || this[Key] := Mapper(Key))
        return this
    }

    /**
     * If present, replaces the value by applying the given `Mapper`,
     * using key and value as arguments.
     * 
     * ```ahk
     * Mapper(Key, Value)
     * ```
     * 
     * @example
     * ; Map { 1 => 3 }
     * Map(1, 2).ComputeIfPresent(1, (Key, Value) => (Key + Value))
     * 
     * @param   {Any}   Key     key of the map entry
     * @param   {Func}  Mapper  function that creates a new value
     * @returns {this}
     */
    ComputeIfPresent(Key, Mapper) {
        GetMethod(Mapper)
        (this.Has(Key) && this[Key] := Mapper(Key, this[Key]))
        return this
    }

    /**
     * If absent, adds a new map element. Otherwise, the value is changed by
     * applying the given `Mapper`.
     * 
     * ```ahk
     * Mapper(Key, Value?)
     * ```
     * 
     * @example
     * Mapper(Key, Value?) {
     *     if (!IsSet(Value)) {
     *         return 1
     *     }
     *     return ++Value
     * }
     * 
     * ; Map { "foo" => 1 }
     * Map().Compute("foo", Mapper)
     * 
     * @param   {Any}   Key     key of the map entry
     * @param   {Func}  Mapper  function that creates a new value
     * @returns {this}
     */
    Compute(Key, Mapper) {
        GetMethod(Mapper)
        if (this.Has(Key)) {
            this[Key] := Mapper(Key, this[Key])
        } else {
            this[Key] := Mapper(Key, unset)
        }
        return this
    }

    /**
     * If absent, adds a new map element. Otherwise, its current value
     * will be merged with `Value` and the given `Combiner`.
     * 
     * ```ahk
     * Combiner(OldValue, NewValue)
     * ```
     * 
     * @example
     * Map().Merge("foo", 1, (a, b) => (a + b))
     * 
     * @param   {Any}   Key       map key
     * @param   {Any}   Value     the new value
     * @param   {Func}  Combiner  function to merge both values with
     * @returns {this}
     */
    Merge(Key, Value, Combiner) {
        GetMethod(Combiner)
        if (this.Has(Key)) {
            this[Key] := Combiner(this[Key], Value)
        } else {
            this[Key] := Value
        }
        return this
    }
    ;@endregion
} ; class Map
} ; class AquaHotkey_Map extends AquaHotkey