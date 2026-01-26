#Include <AquaHotkeyX>

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
    ; TODO integrate Sizeable mixin into this

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
     * @see {@link AquaHotkey_TypeChecks `.Is()`}
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
                M := this()
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
    ;@region Default Properties

    /**
     * Gets and retrieves items from the Map.
     * 
     * @param   {Any?}  Key    map key
     * @param   {Any?}  Value  associated value
     * @returns {Any}
     */
    __Item[Key?] {
        get => this.Get(Key?)
        set {
            this.Set(Key?, Value?)
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
}