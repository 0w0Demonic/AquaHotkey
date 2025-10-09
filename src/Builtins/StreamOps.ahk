#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
/**
 * AquaHotkey - StreamOps.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/StreamOps.ahk
 */
class AquaHotkey_StreamOps extends AquaHotkey {
; @region Array
class Array {
    /**
     * Returns a new array containing all values in this array transformed
     * by applying the given `Mapper` function.
     * 
     * ```ahk
     * Mapper(ArrElement?, Args*)
     * ```
     * 
     * @example
     * Array(1, 2, 3, 4).Map(x => x * 2)         ; [2, 4, 6, 8]
     * Array("hello", "world").Map(SubStr, 1, 1) ; ["h", "w"]
     * 
     * @param   {Func}  Mapper  function that returns a new element
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {Array}
     */
    Map(Mapper, Args*) {
        GetMethod(Mapper)
        Result := Array()
        Result.Capacity := this.Length
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }

        for Value in this {
            Result.Push(Mapper(Value?, Args*))
        }
        return Result
    }

    /**
     * Transforms all values in the array in place by applying the given
     * `Mapper`.
     * 
     * ```ahk
     * Mapper(ArrElement?, Args*)
     * ```
     * 
     * @example
     * Arr := Array(1, 2, 3)
     * 
     * Arr.ReplaceAll(x => (x * 2))
     * Arr.Join(", ").MsgBox() ; "2, 4, 6"
     * 
     * @param   {Func}  Mapper  function that returns a new element
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {this}
     */
    ReplaceAll(Mapper, Args*) {
        GetMethod(Mapper)
        Result := Array()
        Result.Capacity := this.Length

        for Value in this {
            Result.Push(Mapper(Value?, Args*))
        }

        Loop (this.Length) {
            this[A_Index] := Result[A_Index]
        }
        return this
    }

    /**
     * Returns a new array containing all elements in the array transformed by
     * applying the given `Mapper`, resulting arrays flattened into separate
     * elements.
     * 
     * ```ahk
     * Mapper(ArrElement?, Args*)
     * ```
     * 
     * The method defaults to flattening existing array elements, if no `Mapper`
     * is given.
     * 
     * @example
     * Array("hel", "lo").FlatMap(StrSplit)       ; ["h", "e", "l", "l", "o"]
     * Array([1, 2], [3, 4]).FlatMap()            ; [1, 2, 3, 4]
     * Array("a,b", "c,d").FlatMap(StrSplit, ",") ; ["a", "b", "c", "d"]
     * 
     * @param   {Func?}  Mapper  function to convert and flatten elements
     * @param   {Any*}   Args    zero or more additional arguments
     * @returns {Array}
     */
    FlatMap(Mapper?, Args*) {
        Result := Array()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }
        if (IsSet(Mapper)) {
            GetMethod(Mapper)
            for Value in this {
                Element := Mapper(Value?, Args*)
                if (Element is Array) {
                    Result.Push(Element*)
                } else {
                    Result.Push(Element )
                }
            }
            return Result
        }
        for Value in this {
            if (IsSet(Value)) {
                if (Value is Array) {
                    Result.Push(Value*)
                } else {
                    Result.Push(Value )
                }
            } else {
                ++Result.Length
            }
        }
        return Result
    }
    
    /**
     * Returns a new array of all elements that satisfy the given `Condition`.
     * 
     * ```ahk
     * Condition(ArrElement?, Args*)
     * ```
     * 
     * @example
     * Array(1, 2, 3, 4).RetainIf(x => x > 2)    ; [3, 4]
     * Array("foo", "bar").RetainIf(InStr, "f")  ; ["foo"]
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {Array}
     */
    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        Result := Array()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }

        for Value in this {
            (Condition(Value?, Args*) && Result.Push(Value?))
        }
        return Result
    }

    /**
     * Returns a new array of all elements that do not satisfy the given
     * `Condition`.
     * 
     * ```ahk
     * Condition(ArrElement, Args*)
     * ```
     * 
     * @example
     * Array(1, 2, 3, 4).RemoveIf(x => x > 2)    ; [1, 2]
     * Array("foo", "bar").RemoveIf(InStr, "f")  ; ["bar"]
     * 
     * @param   {Predicate}  Condition  the given condition
     * @param   {Any*}       Args       zero or more additional arguments
     * @returns {Array}
     */
    RemoveIf(Condition, Args*) {
        GetMethod(Condition)
        Result := Array()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }
        for Value in this {
            (Condition(Value?, Args*) || Result.Push(Value?))
        }
        return Result
    }

    /**
     * Returns a new array of unique elements by keeping track of them in a Map.
     * 
     * A custom `Hasher` can be used to specify the map key to be used.
     * 
     * ```ahk
     * Hasher(ArrElement?)
     * ```
     * 
     * You can determine the behavior of the internal Map by passing either...
     * - the map to be used;
     * - a function that returns the map to be used;
     * - a case-sensitivity option
     * 
     * ...as value for the `MapParam` parameter.
     * 
     * @example
     * ; [1, 2, 3]
     * Array(1, 2, 3, 1).Distinct()
     * 
     * ; ["foo"]
     * Array("foo", "Foo", "FOO").Distinct(StrLower)
     * 
     * ; [{ Value: 1 }, { Value: 2 }]
     * Array({ Value: 1 }, { Value: 2 }, { Value: 1 })
     *         .Distinct(  (Obj) => Obj.Value )
     * 
     * @param   {Func?}                  Hasher    function to create map keys
     * @param   {Map?/Func?/Primitive?}  MapParam  internal map options
     * @returns {Array}
     */
    Distinct(Hasher?, MapParam := Map()) {
        switch {
            case (MapParam is Map):
                Cache := MapParam
            case (HasMethod(MapParam)):
                Cache := MapParam()
                if (!(Cache is Map)) {
                    throw TypeError("Expected a Map",, Type(Cache))
                }
            default:
                Cache := Map()
                Cache.CaseSense := MapParam
        }

        Result := Array()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }

        if (IsSet(Hasher)) {
            for Value in this {
                Key := Hasher(Value?)
                if (!Cache.Has(Key)) {
                    Result.Push(Value)
                    Cache[Key] := true
                }
            }
            return Result
        }
        for Value in this {
            if (IsSet(Value) && !Cache.Has(Value)) {
                Result.Push(Value)
                Cache[Value] := true
            }
        }
        return Result
    }
    
    /**
     * Combines all elements in the array using the given `Combiner` function
     * to produce a final result.
     * 
     * ```ahk
     * Combiner(ArrElement)
     * ```
     * 
     * Unset elements are ignored.
     * 
     * `Identity` can be used to set an initial value.
     * 
     * @example
     * Array(1, 2, 3, 4).Reduce((a, b) => (a + b)) ; 10
     * 
     * @param   {Func}  Combiner  function to combine two values
     * @param   {Any?}  Identity  initial value
     * @returns {Any}
     */
    Reduce(Combiner, Identity?) {
        if (!this.Length && IsSet(Identity)) {
            return Identity
        }
        GetMethod(Combiner)

        Enumer := this.__Enum(1)
        if (IsSet(Identity)) {
            Result := Identity
        }

        while (!IsSet(Result) && Enumer(&Result)) {
        } ; nop
        
        for Value in Enumer {
            Result := Combiner(Result, Value)
        }
        return Result
    }

    /**
     * Applies the given `Action` function on each element in the array.
     * 
     * ```ahk
     * Action(ArrElement, Args*)
     * ```
     * 
     * @example
     * Array(1, 2, 3, 4).ForEach(MsgBox, "Listing numbers in array", 0x40)
     * 
     * @param   {Func}  Action  the function to call on each element
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {this}
     */
    ForEach(Action, Args*) {
        GetMethod(Action)
        for Value in this {
            Action(Value?, Args*)
        }
        return this
    }

    /**
     * Returns `true` if any element in the array fulfills the given
     * `Condition`, in which case the first matching element is returned
     * as an object with `Value` property.
     * 
     * ```ahk
     * Condition(ArrayElement?, Args*)
     * ```
     * 
     * @example
     * Array(1, 2, 3, 4).AnyMatch(  (x) => (x > 2)  ) ; { Value: 3 }
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {Boolean/Object}
     */
    AnyMatch(Condition, Args*) {
        GetMethod(Condition)
        for Value in this {
            if (Condition(Value?, Args*)) {
                return { Value: Value? }
            }
        }
        return false
    }
    
    /**
     * Returns `true` if all elements in the array fulfill the given
     * `Condition`.
     * 
     * ```ahk
     * Condition(ArrayElement?, Args*)
     * ```
     * 
     * @example
     * Array(1, 2, 3, 4).AllMatch(  (x) => (x < 10)  ) ; true
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {Boolean}
     */
    AllMatch(Condition, Args*) {
        GetMethod(Condition)
        for Value in this {
            if (!Condition(Value?, Args*)) {
                return false
            }
        }
        return true
    }

    /**
     * Returns `true` if none of the elements in the array fulfill the given
     * `Condition`.
     * 
     * ```ahk
     * Condition(ArrayElement?, Args*)
     * ```
     * 
     * @example
     * Array(1, 2, 3, 4).NoneMatch(  (x) => (x == 4)  ) ; false
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {Boolean}
     */
    NoneMatch(Condition, Args*) {
        GetMethod(Condition)
        for Value in this {
            if (Condition(Value?, Args*)) {
                return false
            }
        }
        return true
    }
} ; class Array
;@endregion

;@region Map
class Map {
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
     * @returns {Map}
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
     * @returns {this}
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
     * @returns {this}
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
     * @returns {Map}
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
     * @returns {this}
     */
    ForEach(Action, Args*) {
        GetMethod(Action)
        for Key, Value in this {
            Action(Key, Value, Args*)
        }
    }

    /**
     * Determines whether an element satisfies the given `Condition`,
     * in which case the first matching element is returned in the form
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
     * @returns {Boolean/Object}
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
     * @returns {Boolean}
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
     * @returns {Boolean}
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
;@endregion
} ; class AquaHotkey_StreamOps extends AquaHotkey