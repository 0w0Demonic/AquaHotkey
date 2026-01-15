#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

#Include <AquaHotkey\src\Collections\Mixins\Enumerable1>
#Include <AquaHotkey\src\Collections\Mixins\Enumerable2>
#Include <AquaHotkey\src\Collections\Mixins\Sizeable>

/**
 * Map utils and stream-like operations.
 * 
 * @module  <Collections/Map>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Map extends AquaHotkey {
class Map {
    /**
     * Creates a new empty map with the same base object, case sensitivity and
     * `Default` property of the given map. None of the actual map elements
     * are copied.
     * 
     * @param   {Map}  M  the map to be copied
     * @returns {Map}
     * @example
     * M := Map(1, 2, 3, 4)
     * M.CaseSense := false
     * M.Default := "(empty)"
     * 
     * Copy := Map.BasedFrom(M)
     * MsgBox(ObjGetBase(Copy) == ObjGetBase(M)) ; always `true`
     * MsgBox(Copy.CaseSense) ; false
     * MsgBox(Copy.Default) ; "(empty)"
     */
    static BasedFrom(M) {
        static Define  := {}.DefineProp
        static GetProp := {}.GetOwnPropDesc

        Result := Map()
        ObjSetBase(Result, ObjGetBase(M))

        Result.CaseSense := M.CaseSense
        for PropertyName in ObjOwnProps(M) {
            Define(Result, PropertyName, GetProp(M, PropertyName))
        }
        return Result
    }

    /**
     * Creates a new `Map`.
     * 
     * The parameter may be:
     * - an existing Map returned as-is,
     * - a callable that produces a Map,
     * - or the case-sensitivity for a newly created Map
     * 
     * The returned Map is guaranteed to be an instance of the calling class,
     * so for example the return value of `HashMap.Create()` is guaranteed
     * to be a `HashMap`.
     * 
     * @param   {Any}  Param  a map, map factory, or case sensitivity
     * @returns {Map}
     * @see {HashMap}
     * @example
     * Map.Create()      ; create a normal Map
     * Map.Create(false) ; create a case-insensitive Map
     * 
     * Map.Create(HashMap) ; creates a HashMap (because `HashMap` is callable)
     * HashMap.Create( Map() ) ; TypeError! Not a HashMap.
     */
    static Create(Param := this()) {
        switch {
            case (Param is Map):     M := Param
            case (HasMethod(Param)): M := Param()
            default:
                M := this()
                M.CaseSense := Param
        }
        if (!(M is this)) {
            throw TypeError("Expected a " . this.Prototype.__Class,,
                            Type(M))
        }
        return M
    }

    /**
     * Returns a new map of all elements that fulfill the given `Condition`.
     * 
     * ```ahk
     * Condition(Key, Value, Args*) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {Map}
     * @example
     * ; Map { 1 => 2 }
     * Map(1, 2, 3, 4).RetainIf((Key, Value) => (Key == 1))
     */
    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        Result := Map.BasedFrom(this)
        for Key, Value in this {
            (Condition(Key, Value, Args*) && Result[Key] := Value)
        }
        return Result
    }

    /**
     * Returns a new map of all elements that don't satisfy the given
     * `Condition`.
     * 
     * ```ahk
     * Condition(Key, Value, Args*) => Boolean
     * ```
     * 
     * @param   {Func}  Condition  function that evaluates a condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {this}
     * @example
     * ; Map { 3 => 4 }
     * Map(1, 2, 3, 4).RemoveIf((Key, Value) => (Key == 1))
     */
    RemoveIf(Condition, Args*) {
        GetMethod(Condition)
        Result := Map.BasedFrom(this)
        for Key, Value in this {
            (Condition(Key, Value, Args*) || Result[Key] := Value)
        }
        return Result
    }

    /**
     * Replaces all values in the map *in place* by applying `Mapper` to
     * each element.
     * 
     * ```ahk
     * Mapper(Key, Value, Args*) => Any
     * ```
     * 
     * @param   {Func}  Mapper  function that returns a new value
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {this}
     * @example
     * ; Map { 1 => 4, 3 => 8 }
     * Map(1, 2, 3, 4).ReplaceAll((Key, Value) => (Value * 2))
     */
    ReplaceAll(Mapper, Args*) {
        GetMethod(Mapper)
        for Key, Value in this {
            this[Key] := Mapper(Key, Value, Args*)
        }
        return this
    }

    /**
     * Returns a new map of elements transformed by applying `Mapper` to
     * each element.
     * 
     * ```ahk
     * Mapper(Key, Value, Args*) => Any
     * ```
     * 
     * @param   {Func}  Mapper  function that returns a new value
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {Map}
     * @example
     * ; Map { 1 => 4, 3 => 8 }
     * Map(1, 2, 3, 4).Map((Key, Value) => (Value * 2))
     */
    Map(Mapper, Args*) {
        GetMethod(Mapper)
        Result := Map.BasedFrom(this)
        for Key, Value in this {
            Result[Key] := Mapper(Key, Value, Args*)
        }
        return Result
    }

    ;@region General

    ; TODO views as keys, values, entryset?

    /**
     * Returns an array of all keys in the map.
     * 
     * @returns {Array}
     * @example
     * Map(1, 2, "foo", "bar").Keys() ; [1, "foo"]
     */
    Keys() => Array(this*)

    /**
     * Returns an array of all values in the map.
     * 
     * @returns {Array}
     * @example
     * Map(1, 2, "foo", "bar").Values() ; [2, "bar"]
     */
    Values() => Array(this.__Enum(2).Bind(&Ignore)*)

    ;@endregion

    ;@region Mutations
    /**
     * If absent, adds a new map element.
     * 
     * @param   {Any}  Key    map key
     * @param   {Any}  Value  value associated with map key
     * @returns {this}
     * @example
     * ; Map { "foo" => "bar" }
     * Map().PutIfAbsent("foo", "bar") ; "bar"
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
     * Mapper(Key) => Any
     * ```
     * 
     * @param   {Any}   Key     key of the map entry
     * @param   {Func}  Mapper  function that creates a new value
     * @returns {this}
     * @example
     * ; Map { 1 => 2 }
     * Map().ComputeIfAbsent(1, (Key => Key * 2))
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
     * Mapper(Key, Value) => Any
     * ```
     * 
     * @param   {Any}   Key     key of the map entry
     * @param   {Func}  Mapper  function that creates a new value
     * @returns {this}
     * @example
     * ; Map { 1 => 3 }
     * Map(1, 2).ComputeIfPresent(1, (Key, Value) => (Key + Value))
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
     * @param   {Any}   Key     key of the map entry
     * @param   {Func}  Mapper  function that creates a new value
     * @returns {this}
     * @example
     * ; Map { "foo" => 1 }
     * Map().Compute("foo", (Key, Value?) => ((Value ?? 0) + 1))
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
     * @param   {Any}   Key       map key
     * @param   {Any}   Value     the new value
     * @param   {Func}  Combiner  function to merge both values with
     * @returns {this}
     * @example
     * Map().Merge("foo", 1, (a, b) => (a + b))
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