; TODO Intersection(), Disjunction(), Union(), etc.
; TODO generics; `.CanCastFrom()` ?
; TODO `IMap#CanCastFrom()` ?

;@region ISet
/**
 * @interface
 * @description
 * 
 * Sets are collections that contain no duplicate elements.
 * 
 * `unset` is generally not allowed as element.
 * 
 * This interface requires the an object to implement the following properties:
 * 
 * ```ahk
 * Add(Value: Any, Values: Any*) => Boolean
 * Clear() => void
 * Clone() => ISet
 * Delete(Value: Any, Values: Any*) => Boolean
 * Contains(Value: Any) => Boolean
 * __Enum(ArgSize: Integer) => Enumerator
 * Size => Integer
 * ```
 * 
 * @module  <Interfaces/ISet>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class ISet {
    static __New() {
        if (this == ISet) {
            this.Backup(Enumerable1, Sizeable, Sizeable)
        }
    }

    ;@region Construction

    /**
     * Creates a new `ISet`.
     * 
     * The parameter may be:
     * 
     * - an existing Set returned as-is;
     * - a callable that produces a Set;
     * - or the case-sensitivity for a newly created Set.
     * 
     * The returned Set is guaranteed to be an instance of the calling class.
     * For example, the return value of `HashSet.Create()` is guaranteed to
     * be a `HashSet` (as decided by `.Is()`).
     * 
     * @param   {Any?}  Param  set, factory, or case-sensitivity
     * @returns {ISet}
     * @see {@link HashSet}
     * @see {@link AquaHotkey_DuckTypes `.Is()`}
     * @example
     * 
     * Set.Create() ; a normal Set
     * Set.Create(false) ; case-insensitive Set
     * HashSet.Create() ; creates a HashSet
     * 
     * ISet.Create(() => Set()) ; use a Set factory
     * 
     * HashSet.Create( Set() ) ; TypeError! Not a HashSet.
     */
    static Create(Param := this()) {
        switch {
            case (Param.Is(ISet)):
                S := Param
            case (HasMethod(Param)):
                S := Param()
            default:
                if (this == ISet) {
                    ; fallback to concrete type `Set`
                    S := Set()
                } else {
                    S := this()
                }
                S.CaseSense := Param
        }
        if (!S.Is(this)) {
            throw TypeError("Expected a " . this.Prototype.__Class,, Type(S))
        }
        return S
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Type Info

    /**
     * Determines whether the given value is a set, or supports set operations.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     */
    static IsInstance(Val?) {
        return super.IsInstance(Val?)
            || IsSet(Val)
            && IsObject(Val)
            && HasMethod(Val, "Add")
            && HasMethod(Val, "Clear")
            && HasMethod(Val, "Clone")
            && HasMethod(Val, "Delete")
            && HasMethod(Val, "Contains")
            && HasMethod(Val, "__Enum")
            && HasProp(Val, "Size")
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Unimplemented

    /**
     * Unimplemented `.Add()` method.
     * 
     * ---
     * 
     * Adds one or more values to the set.
     * 
     * @param   {Any}   Value   any value
     * @param   {Any*}  Values  zero or more values
     * @returns {Boolean}
     * @example
     * S := Set()
     * S.Add("value1", "value2")
     * MsgBox(S.Size) ; 2
     */
    Add(Value, *) {
        throw PropertyError("not implemented")
    }

    /**
     * Unimplemented `.Clear()` method.
     * 
     * ---
     * 
     * Clears the set.
     */
    Clear() {
        throw PropertyError("not implemented")
    }

    /**
     * Unimplemented `.Clone()` method.
     * 
     * ---
     * 
     * Clones the set.
     * 
     * @returns {ISet}
     */
    Clone() {
        throw PropertyError("not implemented")
    }

    /**
     * Unimplemented `.Delete()` method.
     * 
     * ---
     * 
     * Deletes one or more values from the set. If the set contained any of
     * the values, this method returns `true`, otherwise `false`.
     * 
     * @param   {Any}   Value   any value
     * @param   {Any*}  Values  more values
     * @returns {Boolean}
     */
    Delete(Value, Values*) {
        throw PropertyError("not implemented")
    }

    /**
     * Unimplemented `.Contains()` method.
     * 
     * ---
     * 
     * Determines whether the given value is present in the set.
     * 
     * @param   {Any}  Value  any value
     * @returns {Boolean}
     * @example
     * Set(1, 2, 3).Contains(3) ; true
     */
    Contains(Value) {
        throw PropertyError("not implemented")
    }

    /**
     * Unimplemented `.__Enum()` method.
     * 
     * ---
     * 
     * Creates an `Enumerator` that enumerates all elements of this set.
     * 
     * @param   {Integer}  ArgSize  param size of for-loop
     * @returns {Enumerator}
     * @example
     * for Value in Set(1, 2, 3) { ... }
     */
    __Enum(ArgSize) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Size` property.
     * 
     * ---
     * 
     * Returns the element size of this set.
     * 
     * @returns {Integer}
     * @example
     * Set(1, 2, 3, 4).Size() ; 4
     */
    Size {
        get {
            throw PropertyError("not implemented")
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Default Methods
    
    /**
     * Determines whether any of the given values are present in the set.
     * 
     * @param   {Any}   Value   any value
     * @param   {Any*}  Values  zero or more values
     * @returns {Boolean}
     * @example
     * Set(1, 2, 3).ContainsAny(2, 5) ; true
     */
    ContainsAny(Value, Values*) {
        if (this.Contains(Value)) {
            return true
        }

        for V in Values {
            if (this.Contains(V)) {
                return true
            }
        }
        return false
    }

    /**
     * Determines whether all of the given values are present in the set.
     * 
     * @param   {Any}   Value   any value
     * @param   {Any*}  Values  zero or more values
     * @returns {Boolean}
     * @example
     * Set(1, 2, 3).ContainsAll(1, 2, 3) ; true
     */
    ContainsAll(Value, Values) {
        if (!this.Contains(Value)) {
            return false
        }
        for V in Values {
            if (!this.Contains(V)) {
                return false
            }
        }
        return true
    }

    /**
     * Determines whether the given value is present in the set.
     * 
     * @alias {@link ISet#Contains `.Contains()`}
     * @param   {Any}  Value  any value
     * @returns {Boolean}
     */
    __Item[Value] => this.Contains(Value)

    ;@endregion 
    ;---------------------------------------------------------------------------
    ;@region Commons

    /**
     * Creates a hash code based on the elements contained in the set.
     * 
     * @returns {Integer}
     */
    HashCode() => (Enumerable1.Prototype.Hash)(this)

    /**
     * Determines whether this set is equal to the `Other` value.
     * 
     * This happens when both values are sets that share the same size
     * and elements.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!Other.Is(ISet)) {
            return false
        }
        if (this.Size != Other.Size) {
            return false
        }
        for Value in this {
            if (!Other.Contains(Value)) {
                return false
            }
        }
        return true
    }

    /**
     * Returns a string representation of the set, based on its type and
     * elements contained.
     * 
     * @returns {String}
     */
    ToString() {
        Result := Type(this) . " { "
        Enumer := this.__Enum(1)

        Enumer(&Value)
        AquaHotkey_ToString.ToString(&Value)
        Result .= Value

        while (Enumer(&Value)) {
            Result .= ", "
            AquaHotkey_ToString.ToString(&Value)
            Result .= Value
        }

        Result .= " }"
        return Result
    }

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

class AquaHotkey_ISet extends AquaHotkey {
    class IMap {
        /**
         * Returns a mutable set view of the map.
         * 
         * @param   {Class<? extends ISet>?}  SetClass  type of set to create
         * @returns {ISet}
         */
        AsSet(SetClass := Set) {
            if (!ISet.CanCastFrom(SetClass)) {
                throw TypeError("Expected ISet or ISet subclass")
            }
            return SetClass.FromMap(this)
        }

        /**
         * Returns an immutable set view of the map by using a clone
         * as backing map.
         * 
         * @param   {Class<? extends ISet>?}  SetClass  type of set to create
         * @returns {ISet}
         */
        ToSet(SetClass := Set) {
            if (!ISet.CanCastFrom(SetClass)) {
                throw TypeError("Expected ISet or ISet subclass")
            }
            return SetClass.FromMap(this.Clone())
        }
    }
}

;@endregion
