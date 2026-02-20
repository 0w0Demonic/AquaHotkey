#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * @interface
 * @description
 * 
 * An object that maps keys to values. A map cannot contain duplicate
 * keys; each key can map to at most one value.
 * 
 * @module  <Interfaces/IMap>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class IMap {
    static __New() {
        if (this != IMap) {
            return
        }
        ObjSetBase(this,           ObjGetBase(Map))
        ObjSetBase(this.Prototype, ObjGetBase(Map.Prototype))
        ObjSetBase(Map,            this)
        ObjSetBase(Map.Prototype,  this.Prototype)

        this.Backup(Enumerable1, Enumerable2)
    }

    ;@region Construction

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

    /**
     * Creates a new `IMap`.
     * 
     * The parameter may be:
     * 
     * - an existing Map returned as-is;
     * - a callable that produces a Map;
     * - or the case-sensitivity for a newly created Map.
     * 
     * The returned Map is guaranteed to be an instance of the calling class.
     * For example, the return value of `HashMap.Create()` is guaranteed to be a
     * `HashMap` (as decided by `.Is()`).
     * 
     * @param   {Any?}  Param  map, factory, or case-sensitivity
     * @returns {IMap}
     * @see {@link HashMap}
     * @see {@link AquaHotkey_DuckTypes `.Is()`}
     * @example
     * 
     * Map.Create()      ; a normal Map
     * Map.Create(false) ; case-insensitive Map
     * HashMap.Create()  ; creates a HashMap
     * 
     * IMap.Create( () => Map() ) ; use a Map factory
     * 
     * HashMap.Create( Map() ) ; TypeError! Not a HashMap.
     */
    static Create(Param := this()) {
        switch {
            case (Param.Is(IMap)):
                M := Param
            case (HasMethod(Param)):
                M := Param()
            default:
                if (this == IMap) {
                    M := Map()
                } else {
                    M := this()
                }
                M.CaseSense := Param
        }
        if (!M.Is(this)) {
            throw TypeError("Expected a " . this.Prototype.__Class,, Type(M))
        }
        return M
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Type Info

    /**
     * Determines whether the given value is a map, or implements map
     * properties.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     */
    static IsInstance(Val?) => super.IsInstance(Val?)
            || (this == IMap)
                && IsSet(Val) && IsObject(Val)
                && HasMethod(Val, "Clear")
                && HasMethod(Val, "Delete")
                && HasMethod(Val, "Get")
                && HasMethod(Val, "Has")
                && HasMethod(Val, "Set")
                && HasMethod(Val, "__Enum")
                && HasProp(Val, "Count")

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Unimplemented

    /**
     * Unsupported `.Clear()` method.
     * @see {@link Map#Clear()}
     */
    Clear() {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Delete()` method.
     * @see {@link Map#Delete()}
     */
    Delete(Key) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Get()` method.
     * @see {@link Map#Get()}
     */
    Get(Key, *) {
        throw PropertyError("not implemented")
    }
    
    /**
     * Unsupported `.Has()` method.
     * @see {@link Map#Has()}
     */
    Has(Key) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Set()` method.
     * @see {@link Map#Set()}
     */
    Set(*) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.__Enum()` method.
     * @see {@link Map#__Enum()}
     */
    __Enum(ArgSize) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Count` property.
     * @see {@link Map#Count}
     */
    Count {
        get {
            throw PropertyError("not implemented")
        }
    }

    /**
     * Unsupported `.Capacity` property.
     * @see {@link Map#Capacity}
     */
    Capacity {
        get {
            throw PropertyError("not implemented")
        }
        set {
            throw PropertyError("not implemented")
        }
    }

    /**
     * Unsupported `.CaseSense` property.
     * @see {@link Map#CaseSense}
     */
    CaseSense {
        get {
            throw PropertyError("not implemented")
        }
        set {
            throw PropertyError("not implemented")
        }
    }

    /**
     * Unsupported `.__Item[]` property.
     * @see {@link Map#__Item}
     */
    __Item[Key] {
        get {
            throw PropertyError("not implemented")
        }
        set {
            throw PropertyError("not implemented")
        }
    }
    
    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Default Methods

    /**
     * If absent, adds a new map element.
     * 
     * @param   {Any}  Key    map key
     * @param   {Any}  Value  associated value
     * @example
     * M := Map()
     * M.PutIfAbsent("foo", "bar")
     */
    PutIfAbsent(Key, Value) {
        if (!this.Has(Key)) {
            this.Set(Key, Value)
        }
    }

    /**
     * If absent, adds a new entry using the given mapping function.
     * 
     * ```ahk
     * Mapper(Key: Any, Args: Any*) => Any
     * ```
     * 
     * @param   {Any}   Key     map key
     * @param   {Func}  Mapper  mapper function
     * @param   {Any*}  Args    zero or more arguments
     * @example
     * Mul(A, B) => (A * B)
     * 
     * M := Map()
     * M.ComputeIfAbsent(1, Mul, 2)
     */
    ComputeIfAbsent(Key, Mapper, Args*) {
        if (!this.Has(Key)) {
            GetMethod(Mapper)
            this.Set(Key, Mapper(Key, Args*))
        }
    }

    /**
     * If present, creates a new mapping given the key and its current mapped value.
     * 
     * ```ahk
     * Mapper(Key: Any, Value: Any, Args: Any*) => Any
     * ```
     * 
     * @param   {Any}   Key     map key
     * @param   {Func}  Mapper  mapper function
     * @param   {Any*}  Args    zero or more arguments
     * @example
     * Concat(A, B) => (A . B)
     * 
     * M := Map(1, "a")
     * M.ComputeIfPresent(1, Concat, "b")
     * MsgBox(M[1]) ; "ab"
     */
    ComputeIfPresent(Key, Mapper, Args*) {
        if (this.Has(Key)) {
            GetMethod(Mapper)
            this.Set(Key, Mapper(Key, this.Get(Key), Args*))
        }
    }

    /**
     * Creates a new mapping for the specified and its current mapped value,
     * or `unset` if there is no current mapping.
     * 
     * ```ahk
     * Mapper(Key: Any, Value: Any?, Args: Any* r Args: Any*A => Any
     * ```
     * 
     * @param   {Any}   Key     map key
     * @param   {Func}  Mapper  mapper function
     * @param   {Any*}  Args    zero or more arguments
     */
    Compute(Key, Mapper, Args*) {
        GetMethod(Mapper)
        if (this.Has(Key)) {
            this.Set(Key, Mapper(Key, this.Get(Key), Args*))
        } else {
            this.Set(Key, Mapper(Key, unset, Args*))
        }
    }

    /**
     * If the specified key is not already associated with a value,
     * associates it with the given value. Otherwise, replaces the value
     * with the results of a remapping function.
     * 
     * ```ahk
     * Combiner(OldValue: Any, NewValue: Any) => Any
     * ```
     * 
     * @param   {Any}   Key       map key
     * @param   {Any}   Value     the new value
     * @param   {Func}  Combiner  function to merge both values with
     * @param   {Any*}  Args      zero or more arguments
     * @example
     * Sum(A, B) => (A + B)
     * 
     * M := Map()
     * M.Merge("foo", 1, Sum)
     */
    Merge(Key, Value, Combiner, Args*) {
        if (this.Has(Key)) {
            GetMethod(Combiner)
            this.Set(Key, Combiner(this.Get(Key), Value, Args*))
        } else {
            this.Set(Key, Value, Args*)
        }
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

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region `.Try...()` Methods

    /**
     * Deletes an item, if present. This method return `true` if an element was
     * removed from the map, otherwise `false`.
     * 
     * @param   {Any}      Key       requested key
     * @param   {VarRef?}  OutValue  (out) associated value, if present
     * @returns {Boolean}
     * @example
     * SL := Map(1, 2, 3, 4)
     * if (SL.TryDelete(1, &Value)) {
     *     MsgBox(Value) ; 2
     * }
     */
    TryDelete(Key, &OutValue) {
        if (this.Has(Key)) {
            OutValue := this.Delete(Key)
            return true
        }
        return false
    }

    /**
     * Returns the value associated with the given key, if present. This
     * method returns `true` if an element was found, otherwise `false`.
     * 
     * @param   {Any}      Key       requested key
     * @param   {VarRef?}  OutValue  (out) associated value, if present
     * @returns {Boolean}
     * @example
     * SL := Map(1, 2, 3, 4)
     * if (SL.TryGet(1, &Value)) {
     *     MsgBox(Value) ; 2
     * }
     */
    TryGet(Key, &OutValue) {
        if (this.Has(Key)) {
            OutValue := this.Get(Key)
            return true
        } else {
            OutValue := unset
            return false
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Default Properties

    /**
     * Determines whether this map is empty.
     * 
     * @returns {Boolean}
     */
    IsEmpty => (!this.Count)

    /**
     * Determines whether this map is not empty.
     * 
     * @returns {Boolean}
     */
    IsNotEmpty => (!!this.Count)

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Stream Operations

    /**
     * Creates a new empty map with the same base object, case sensitivity
     * and `Default` property of the given map.
     * 
     * @param   {IMap}  M  the map to be copied
     * @returns {IMap}
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
        static Define := {}.DefineProp
        static GetProp := {}.GetOwnPropDesc

        if (M is Map) {
            Result := Map()
        } else {
            Result := {}
        }
        ObjSetBase(Result, ObjGetBase(M))
        Result.__Init()
        Result.__New()

        if (ObjHasOwnProp(M, "Default")) {
            Define(Result, "Default", GetProp(M, "Default"))
        }
        if (ObjHasOwnProp(M, "CaseSense")) {
            Define(Result, "CaseSense", GetProp(M, "CaseSense"))
        }

        if (!this.IsInstance(Result)) {
            throw TypeError("Expected a(n) " . this.Name,, Type(Result))
        }
        return Result
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
     * @returns {IMap}
     * @example
     * ; Map { 1 => 2 }
     * Map(1, 2, 3, 4).RetainIf((Key, Value) => (Key == 1))
     */
    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        Result := IMap.BasedFrom(this)
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
        Result := IMap.BasedFrom(this)
        for Key, Value in this {
            (Condition(Key, Value, Args*) || Result[Key] := Value)
        }
        return Result
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
        Result := IMap.BasedFrom(this)
        for Key, Value in this {
            Result[Key] := Mapper(Key, Value, Args*)
        }
        return Result
    }

    ;@endregion
}