#Requires AutoHotkey v2.0
#Include <AquaHotkey\src\Core\Utils>
#Include <AquaHotkey\src\Interfaces\IMap>

; TODO IArray#DeleteValue
; TODO IArray#ContainsValue

/**
 * An implementation of {@link IMap} in which one key can have multiple values.
 * 
 * A multimap behaves very similar to a map that contains keys associated with
 * an array of values. A multimap can have the exact same key-value pair more
 * than once.
 * 
 * @module   <Interfaces/IMultiMap>
 * @author   0w0Demonic
 * @see      https://www.github.com/0w0Demonic/AquaHotkey
 * @template TKey type of keys
 * @template TValue type of values
 */
class IMultiMap extends IMap {
    /**
     * Deletes an item from the multi-map based on key and associated value.
     * 
     * Returns the value of the deleted item. Throws, if no such item was found.
     */
    DeleteValue(Key, Value) {
        throw MethodError("not implemented")
    }

    /**
     * Determines whether an item is present in the map. If `Value` is
     * specified, checks whether one of the items has the given value.
     * 
     * @param   {TKey}     Key    map key
     * @param   {TValue?}  Value  map value
     * @returns {Boolean}
     */
    Has(Key, Value?) {
        throw MethodError("not implemented")
    }

    /**
     * Returns the first item in the map associated with the given key.
     * 
     * @param   {TKey}  Key      map key
     * @param   {Any?}  Default  default value
     * @returns {Any}
     */
    GetFirst(Key, Default?) {
        if (this.TryGet(Key, &Values) && Values.Length) {
            return Values[1]
        }
        if (IsSet(Default)) {
            return Default
        }
        if (HasProp(this, "Default")) {
            return this.Default
        }
        throw UnsetItemError("item not found")
    }

    /**
     * Returns the last item in the map associated with the given key.
     * 
     * @param   {TKey}  Key      map key
     * @param   {Any?}  Default  default value
     * @returns {Any}
     */
    GetLast(Key, Default?) {
        if (this.TryGet(Key, &Values) && Values.Length) {
            return Values[-1]
        }
        if (IsSet(Default)) {
            return Default
        }
        if (HasProp(this, "Default")) {
            return this.Default
        }
        throw UnsetItemError("item not found")
    }

    /**
     * Adds alternating key-value pairs into the map.
     * 
     * @param   {Any*}  Args  alternating key and value
     */
    Add(Args*) {
        if (Args.Length & 1) {
            throw ValueError("invalid param count",, Args.Length)
        }
        for Key, Value in Pairwise(Args) {
            this.Get(Key).Push(Value)
        }
    }

    /**
     * Adds zero or more values into the map on the given key.
     * 
     * @param  {TKey}     Key     map key
     * @param  {TValue*}  Values  map values
     */
    AddAll(Key, Values*) {
        this.Get(Key).Push(Values*)
    }

    /**
     * Returns an {@link Enumerator} of all associations in this map.
     * 
     * @type {Enumerator<TKey, TValue>}
     * @example
     * ; <(1, "a"), (1, "b"), (2, "c")>
     * MultiMap(1, "a", 1, "b", 2, "c").Associations
     */
    Associations {
        get {
            static BaseObj := (IsSet(AquaHotkey_DoubleStream)
                            && IsSet(DoubleStream))
                                    ? DoubleStream.Prototype
                                    : Enumerator.Prototype

            Items := this.__Enum(2)

            Key := unset
            Values := (*) => false
            ObjSetBase(Associations, BaseObj)
            return Associations

            Associations(&OutKey, &OutValue?) {
                loop {
                    if (Values(&OutValue)) {
                        OutKey := Key
                        return true
                    }
                    if (!Items(&Key, &Values)) {
                        return false
                    }
                    ; (this assumes `Key` is never `unset` based on existing
                    ; specs for `IMap#__Enum()`)
                    Values := GetEnumerator(Values, 1)
                }
            }
        }
    }

    /**
     * The number of total values in this map.
     * 
     * @readonly
     * @type {Integer}
     */
    ValueCount {
        get {
            throw PropertyError("not implemented")
        }
    }
}
