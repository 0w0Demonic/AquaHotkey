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
     * Sets the `Default` property of this map.
     * @example
     * 
     * MapObj := Map().SetDefault("(empty)")
     * MapObj["foo"] ; "(empty)"
     * 
     * @param   {Any}  Default  any value
     * @return  {this}
     */
    SetDefault(Default) {
        this.Default := Default
        return this
    }

    /**
     * Sets the capacity of this map.
     * @example
     * 
     * MapObj := Map().SetCapacity(128)
     * 
     * @param   {Integer}  Capacity  new capacity of this map
     * @return  {this}
     */
    SetCapacity(Capacity) {
        this.Capacity := Capacity
        return this
    }

    /**
     * Sets the case-sensitivity `CaseSense` of this map.
     * @example
     * 
     * MapObj := Map().SetCaseSense(false)
     * 
     * @param   {Primitive}  CaseSense  new case-sensitivity of this map
     * @return  {this}
     */
    SetCaseSense(CaseSense) {
        this.CaseSense := CaseSense
        return this
    }

    /**
     * Returns an array of all keys in this map.
     * @example
     * 
     * Map(1, 2, "foo", "bar").Keys() ; [1, "foo"]
     * 
     * @return  {Array}
     */
    Keys() => Array(this*)

    /**
     * Returns an array of all values in this map.
     * @example
     * 
     * Map(1, 2, "foo", "bar").Values() ; [2, "bar"]
     * 
     * @return  {Array}
     */
    Values() => Array(this.__Enum(2).Bind(&Ignore)*)

    /**
     * Returns `true`, if this map is empty (has no entries).
     * @example
     * 
     * Map().IsEmpty ; true
     * Map(1, 2, "foo", "bar").IsEmpty ; false
     */
    IsEmpty  => (!this.Count)

    /**
     * Returns a new map containing all current elements which satisfy the given
     * predicate function `Condition`.
     * 
     * `Condition` is called using key and value as first two arguments,
     * followed by zero or more additional arguments `Args*`.
     * @example
     * 
     * ; Map { 1 => 2 }
     * Map(1, 2, 3, 4).RetainIf((Key, Value) => (Key == 1))
     * 
     * @param   {Predicate}  Condition  function that evaluates a condition
     * @param   {Any*}       Args       zero or more additional arguments
     * @return  {Map}
     */
    RetainIf(Condition, Args*) {
        if (!HasMethod(Condition)) {
            throw TypeError("Expected a Function object",, Type(Condition))
        }
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
     * Returns a new map containing all current elements which do not satisfy
     * the given predicate function `Condition`.
     * 
     * `Condition` is called using key and value as first two arguments,
     * followed by zero or more additional arguments `Args*`
     * @example
     * 
     * ; Map { 3 => 4 }
     * Map(1, 2, 3, 4).RemoveIf((Key, Value) => (Key == 1))
     * 
     * @param   {Predicate}  Condition  function that evaluates a condition
     * @param   {Any*}       Args       zero or more additional arguments
     * @return  {this}
     */
    RemoveIf(Condition, Args*) {
        if (!HasMethod(Condition)) {
            throw TypeError("Expected a Function object",, Type(Condition))
        }
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
     * Replaces all values in this map in place, by applying the given `Mapper`
     * function on each element.
     * 
     * `Mapper` is called using key and value as first two arguments, followed
     * by zero or more additional arguments `Args*`.
     * @example
     * 
     * ; Map { 1 => 4, 3 => 8 }
     * Map(1, 2, 3, 4).ReplaceAll((Key, Value) => (Value * 2))
     * 
     * @param   {Func}  Mapper  function that returns a new value
     * @param   {Any*}  Args    zero or more additional arguments
     * @return  {this}
     */
    ReplaceAll(Mapper, Args*) {
        if (!HasMethod(Mapper)) {
            throw TypeError("Expected a Function object",, Type(Mapper))
        }
        for Key, Value in this {
            this[Key] := Mapper(Key, Value, Args*)
        }
        return this
    }

    /**
     * Returns a new map containing all current elements transformed by applying
     * the given `Mapper` function to generate a new value.
     * 
     * `Mapper` is called using key and value as first two arguments, followed
     * by zero or more additional arguments `Args*`.
     * @example
     * 
     * ; Map { 1 => 4, 3 => 8 }
     * Map(1, 2, 3, 4).Map((Key, Value) => (Value * 2))
     * 
     * @param   {Func}  Mapper  function that returns a new value
     * @param   {Any*}  Args    zero or more additional arguments
     * @return  {Map}
     */
    Map(Mapper, Args*) {
        if (!HasMethod(Mapper)) {
            throw TypeError("Expected a Function object",, Type(Mapper))
        }
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
     * Calls the given `Action` function on each element of this map.
     * 
     * `Action` is called using key and value as first two arguments, followed
     * by zero or more additional arguments `Args*`.
     * @example
     * 
     * Print(Key, Value) {
     *     MsgBox("key: " . Key . ", value: " . Value)
     * }
     * 
     * Map(1, 2, 3, 4).ForEach(Print)
     * 
     * @param   {Func}  Action  the function to call on each element
     * @param   {Any*}  Args    zero or more additional arguments
     * @return  {this}
     */
    ForEach(Action, Args*) {
        if (!HasMethod(Action)) {
            throw TypeError("Expected a Function object",, Type(Action))
        }
        for Key, Value in this {
            Action(Key, Value, Args*)
        }
    }

    /**
     * If absent, adds a new element `Key ==> Value` to this map.
     * @example
     * 
     * ; Map { "foo" => "bar" }
     * Map().PutIfAbsent("foo", "bar") ; "bar"
     * 
     * @param   {Any}  Key    key of the map entry
     * @param   {Any}  Value  value associated with map key
     * @return  {this}
     */
    PutIfAbsent(Key, Value) {
        (this.Has(Key) || this[Key] := Value)
        return this
    }
    
    /**
     * If absent, adds a new element `Key` to this map, with its value computed
     * by applying the given `Mapper` function, using `Key` as argument.
     * @example
     * 
     * ; Map { 1 => 2 }
     * Map().ComputeIfAbsent(1, (Key => Key * 2))
     * 
     * @param   {Any}   Key     key of the map entry
     * @param   {Func}  Mapper  function that creates a new value
     * @return  {this}
     */
    ComputeIfAbsent(Key, Mapper) {
        if (!HasMethod(Mapper)) {
            throw TypeError("Expected a Function object",, Type(Mapper))
        }
        (this.Has(Key) || this[Key] := Mapper(Key))
        return this
    }

    /**
     * If present, replaces the value of element `Key` by applying the given
     * `Mapper` function, using key and value as arguments.
     * @example
     * 
     * ; Map { 1 => 3 }
     * Map(1, 2).ComputeIfPresent(1, (Key, Value) => (Key + Value))
     * 
     * @param   {Any}   Key     key of the map entry
     * @param   {Func}  Mapper  function that creates a new value
     * @return  {this}
     */
    ComputeIfPresent(Key, Mapper) {
        if (!HasMethod(Mapper)) {
            throw TypeError("Expected a Function object",, Type(Mapper))
        }
        (this.Has(Key) && this[Key] := Mapper(Key, this[Key]))
        return this
    }

    /**
     * If absent, puts a new element `Key ==> Value` into this map. Otherwise,
     * the value under element `Key` is replaced by applying the given `Mapper`
     * function.
     * 
     * `Mapper` is called using key and value as two arguments. If there is not
     * yet an element present, `unset` is passed as current value.
     * @example
     * 
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
        if (!HasMethod(Mapper)) {
            throw TypeError("Expected a Function object",, Type(Mapper))
        }
        if (this.Has(Key)) {
            this[Key] := Mapper(Key, this[Key])
        } else {
            this[Key] := Mapper(Key, unset)
        }
        return this
    }

    /**
     * If absent, adds a new element `Key ==> Value` to this map. Otherwise, the
     * value of element `Key` is replaced by applying the given `Mapper`
     * function.
     * 
     * `Mapper` is called using the current value and `Value` as arguments.
     * @example
     * 
     * Sum(OldValue, Value) {
     *     return OldValue + Value
     * }
     * Map().Merge("foo", 1, Sum)
     */
    Merge(Key, Value, Mapper) {
        if (!HasMethod(Mapper)) {
            throw TypeError("Expected a Function object",, Type(Mapper))
        }
        if (this.Has(Key)) {
            this[Key] := Mapper(this[Key], Value)
        } else {
            this[Key] := Value
        }
        return this
    }

    /**
     * Determines if any element in the map satisfies the given predicate
     * function `Condition`.
     * 
     * `Condition` is called using key and value as first two arguments,
     * followed by zero or more additional arguments `Args*`.
     * 
     * While this method is designed to be used as a
     * boolean-like check in conditional statements, it returns the first
     * element that satisfies `Condition` as an object with the properties
     * `Key` and `Value`, which is inherently a truthy value.
     * 
     * If no elements satisfy `Condition`, the method returns `false`.
     * @example
     * 
     * KeyEquals1(Key, Value) {
     *     return (Key == 1)
     * }
     * 
     * Map(1, 2, 3, 4).AnyMatch(KeyEquals1, &Key, &Value) ; true
     * MsgBox(Key)   ; 1
     * MsgBox(Value) ; 2
     * 
     * @param   {Predicate}  Condition  function that evaluates a condition
     * @param   {Any*}       Args       zero or more additional arguments
     * @return  {Object}
     */
    AnyMatch(Condition, Args*) {
        if (!HasMethod(Condition)) {
            throw TypeError("Expected a Function object",, Type(Condition))
        }
        for Key, Value in this {
            if (Condition(Key, Value, Args*)) {
                return { Key: Key, Value: Value }
            }
        }
        return false
    }

    /**
     * Returns `true`, if all elements in this map satisfy the given predicate
     * function `Condition`.
     * 
     * `Condition` is called using key and value as arguments, followed by zero
     * or more additional arguments `Args*`
     * @example
     * 
     * Map(1, 2, 3, 4).AllMatch((Key, Value) => (Key != 6)) ; true
     * 
     * @param   {Predicate}  Condition  function that evaluates a condition
     * @param   {Any*}       Args       zero or more additional arguments
     * @return  {Boolean}
     */
    AllMatch(Condition, Args*) {
        if (!HasMethod(Condition)) {
            throw TypeError("Expected a Function object",, Type(Condition))
        }
        for Key, Value in this {
            if (!Condition(Key, Value, Args*)) {
                return false
            }
        }
        return true
    }

    /**
     * Returns `true`, if none of the elements in this map satisfy the given
     * predicate function `Condition`.
     * 
     * `Condition` is called using key and value as first two arguments,
     * followed by zero or more additional arguments `Args*`.
     * @example
     * 
     * Map(1, 2, 3, 4).NoneMatch((Key, Value) => (Key == 3)) ; false
     * 
     * @param   {Predicate}  Condition  function that evaluates a condition
     * @param   {Any*}       Args       zero or more additional arguments
     * @return  {Boolean}
     */
    NoneMatch(Condition, Args*) {
        if (!HasMethod(Condition)) {
            throw TypeError("Expected a Function object",, Type(Condition))
        }
        for Key, Value in this {
            if (Condition(Key, Value, Args*)) {
                return false
            }
        }
        return true
    }
} ; class Map
} ; class AquaHotkey_Map extends AquaHotkey