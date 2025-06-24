class AquaHotkey_Map extends AquaHotkey {
/**
 * AquaHotkey - Map.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/Map.ahk
 */
class Map {
    /**
     * Sets the `Default` property of the map.
     * 
     * @example
     * MapObj := Map().SetDefault("(empty)")
     * MapObj["foo"] ; "(empty)"
     * 
     * @param   {Any}  Default  new default return value
     * @return  {this}
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
     * @return  {this}
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
     * @return  {this}
     */
    SetCaseSense(CaseSense) {
        this.CaseSense := CaseSense
        return this
    }

    /**
     * Returns an array of all keys in the map.
     * 
     * @example
     * Map(1, 2, "foo", "bar").Keys() ; [1, "foo"]
     * 
     * @return  {Array}
     */
    Keys() => Array(this*)

    /**
     * Returns an array of all values in the map.
     * 
     * @example
     * Map(1, 2, "foo", "bar").Values() ; [2, "bar"]
     * 
     * @return  {Array}
     */
    Values() => Array(this.__Enum(2).Bind(&Ignore)*)

    /**
     * Returns `true`, if this map is empty (has no entries).
     * 
     * @example
     * Map().IsEmpty ; true
     * Map(1, 2, "foo", "bar").IsEmpty ; false
     * 
     * @return  {Boolean}
     */
    IsEmpty  => (!this.Count)

    /**
     * Returns a new map of all elements that fulfill the given `Condition`.
     * 
     * ```ahk
     * Condition(Key, Value, Args*)
     * ```
     * 
     * @example
     * ; Map { 1 => 2 }
     * Map(1, 2, 3, 4).RetainIf((Key, Value) => (Key == 1))
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @return  {Map}
     */
    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        Result := Map()
        Result.CaseSense := this.CaseSense
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }

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
     * Condition(Key, Value, Args*)
     * ```
     * 
     * @example
     * ; Map { 3 => 4 }
     * Map(1, 2, 3, 4).RemoveIf((Key, Value) => (Key == 1))
     * 
     * @param   {Func}  Condition  function that evaluates a condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @return  {this}
     */
    RemoveIf(Condition, Args*) {
        GetMethod(Condition)
        Result := Map()
        Result.CaseSense := this.CaseSense
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }
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
     * Mapper(Key, Value, Args*)
     * ```
     * 
     * @example
     * ; Map { 1 => 4, 3 => 8 }
     * Map(1, 2, 3, 4).ReplaceAll((Key, Value) => (Value * 2))
     * 
     * @param   {Func}  Mapper  function that returns a new value
     * @param   {Any*}  Args    zero or more additional arguments
     * @return  {this}
     */
    ReplaceAll(Mapper, Args*) {
        GetMethod(Mapper)
        Result := Map()
        Result.Capacity := this.Count
        for Key, Value in this {
            Result[Key] := Mapper(Key, Value, Args*)
        }
        for Key, Value in this {
            this[Key] := Result[Key]
        }
        return this
    }

    /**
     * Returns a new map of elements transformed by applying `Mapper` to
     * each element.
     * 
     * ```ahk
     * Mapper(Key, Value, Args*)
     * ```
     * 
     * @example
     * ; Map { 1 => 4, 3 => 8 }
     * Map(1, 2, 3, 4).Map((Key, Value) => (Value * 2))
     * 
     * @param   {Func}  Mapper  function that returns a new value
     * @param   {Any*}  Args    zero or more additional arguments
     * @return  {Map}
     */
    Map(Mapper, Args*) {
        GetMethod(Mapper)
        Result := Map()
        Result.CaseSense := this.CaseSense
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }
        for Key, Value in this {
            Result[Key] := Mapper(Key, Value, Args*)
        }
        return Result
    }

    /**
     * Calls the given `Action` for each map element.
     * 
     * `Action` is called using key and value as first two arguments, followed
     * by zero or more additional arguments `Args*`.
     * 
     * ```ahk
     * Action(Key, Value, Args*)
     * ```
     * 
     * @example
     * Print(Key, Value) {
     *     MsgBox("key: " . Key . ", value: " . Value)
     * }
     * Map(1, 2, 3, 4).ForEach(Print)
     * 
     * @param   {Func}  Action  the function to be called
     * @param   {Any*}  Args    zero or more additional arguments
     * @return  {this}
     */
    ForEach(Action, Args*) {
        GetMethod(Action)
        for Key, Value in this {
            Action(Key, Value, Args*)
        }
    }

    /**
     * If absent, adds a new map element.
     * 
     * @example
     * ; Map { "foo" => "bar" }
     * Map().PutIfAbsent("foo", "bar") ; "bar"
     * 
     * @param   {Any}  Key    map key
     * @param   {Any}  Value  value associated with map key
     * @return  {this}
     */
    PutIfAbsent(Key, Value) {
        (this.Has(Key) || this[Key] := Value)
        return this
    }
    
    ; TODO Args*?
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
     * @return  {this}
     */
    ComputeIfAbsent(Key, Mapper) {
        GetMethod(Mapper)
        (this.Has(Key) || this[Key] := Mapper(Key))
        return this
    }

    ; TODO Args*?
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
     * @return  {this}
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
     * @return  {this}
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
     * @return  {this}
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

    /**
     * Determines whether an element satisfies the given `Condition`,
     * in which case it will return the first matching element in the form
     * of an object with `Key` and `Value` properties.
     * 
     * ```ahk
     * Condition(Key, Value, Args*)
     * ```
     * 
     * @example
     * KeyEquals1(Key, Value) {
     *     return (Key == 1)
     * }
     * 
     * Output := Map(1, 2, 3, 4).AnyMatch(KeyEquals1)
     * if (Output) {
     *     MsgBox(Output.Key)   ; 1
     *     MsgBox(Output.Value) ; 2
     * }
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @return  {Object}
     */
    AnyMatch(Condition, Args*) {
        GetMethod(Condition)
        for Key, Value in this {
            if (Condition(Key, Value, Args*)) {
                return { Key: Key, Value: Value }
            }
        }
        return false
    }

    /**
     * Returns `true`, if all elements satisfy the given `Condition`.
     * 
     * ```ahk
     * Condition(Key, Value, Args*)
     * ```
     * 
     * @example
     * Map(1, 2, 3, 4).AllMatch((Key, Value) => (Key != 6)) ; true
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @return  {Boolean}
     */
    AllMatch(Condition, Args*) {
        GetMethod(Condition)
        for Key, Value in this {
            if (!Condition(Key, Value, Args*)) {
                return false
            }
        }
        return true
    }

    /**
     * Returns `true`, if none of the elements satisfy the given `Condition`.
     * 
     * ```ahk
     * Condition(Key, Value, Args*)
     * ```
     * 
     * @example
     * Map(1, 2, 3, 4).NoneMatch((Key, Value) => (Key == 3)) ; false
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @return  {Boolean}
     */
    NoneMatch(Condition, Args*) {
        GetMethod(Condition)
        for Key, Value in this {
            if (Condition(Key, Value, Args*)) {
                return false
            }
        }
        return true
    }
} ; class Map
} ; class AquaHotkey_Map extends AquaHotkey