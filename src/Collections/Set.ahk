; TODO somehow add StreamOps to this

/**
 * A simple set implementation based on the built-in `Map` type.
 * 
 * @module  <Collections/Set>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Set {
    static __New() {
        if (this != Set) {
            return
        }
        this.IsSizedBy("Count")
        this.Backup(Enumerable1)
    }

    /**
     * Constructs a new set containing the given values as elements.
     * 
     * @constructor
     * @param   {Any*}  Values  zero or more elements
     */
    __New(Values*) {
        M := Map()
        this.DefineProp("M", { Get: (_) => M })
        if (Values.Length) {
            this.Add(Values*)
        }
    }

    /**
     * Returns a mutable map view of this set.
     * 
     * @returns {Map}
     * @example
     * S := Set(1, 2, 3)
     * 
     * ; Map { 1: true, 2: true, 3: true }
     * M := S.AsMap()
     * M.Set("foo", "bar")
     * 
     * S.Has("foo") ; true
     */
    AsMap() => this.M

    /**
     * Returns a map containing a copy of all the current elements in
     * this set.
     * 
     * @example
     * 
     * S := Set(1, 2, 3)
     * 
     * ; Map { 1 => true, 2 => true, 3 => true }
     * M := S.ToMap()
     * M.Set("foo", true)
     * 
     * S.Has("foo")
     */
    ToMap() => this.M.Clone()

    /**
     * Clears this set.
     */
    Clear() => this.M.Clear()

    /**
     * Clones this set.
     * 
     * @returns {Set}
     */
    Clone() {
        M := this.M.Clone()
        Obj := Object().DefineProp("M", { Get: (_) => M })
        ObjSetBase(Obj, ObjGetBase(this))
        return Obj
    }

    /**
     * Deletes one or more values from this set. If the set contained
     * any of the values, this method returns `true`, otherwise `false`.
     * 
     * @param   {Any}   Value   any value
     * @param   {Any*}  Values  more values
     * @returns {Boolean}
     */
    Delete(Value, Values*) {
        M := this.M
        Changed := M.Has(Value)
        this.M.Delete(Value)

        for V in Values {
            Changed |= M.Has(V)
            M.Delete(V)
        }
        return Changed
    }

    /**
     * Determines whether the given value is present in the set.
     * 
     * @param   {Any}  Value  any value
     * @returns {Boolean}
     * @example
     * Set(1, 2, 3).Has(3) ; true
     */
    Has(Value) => this.M.Has(Value)

    ; TODO what kind of equality check to use?
    /**
     * Determines whether any of the given values is present in the set.
     * 
     * @param   {Any}   Value   any value
     * @param   {Any*}  Values  zero or more values
     * @returns {Boolean}
     * @example
     * Set(1, 2, 3).HasAny()
     */
    HasAny(Value, Values*) {
        if (this.Has(Value)) {
            return true
        }
        for V in Values {
            if (this.Has(V)) {
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
     * Set(1, 2, 3).HasAll(1, 2, 3)
     */
    HasAll(Value, Values*) {
        if (!this.Has(Value)) {
            return false
        }
        for V in Values {
            if (!this.Has(V)) {
                return false
            }
        }
        return true
    }

    /**
     * Adds one or more values to the set.
     * @param   {Any}   Value   any value
     * @param   {Any*}  Values  zero or more values
     * @returns {Boolean}
     * @example
     * S := Set()
     * S.Add("value1", "value2")
     * MsgBox(S.Has("value1")) ; true
     */
    Add(Value, Values*) {
        Changed := (!this.M.Has(Value))
        this.M.Set(Value, true)
        for V in Values {
            Changed |= (!this.M.Has(V))
            this.M.Set(V, true)
        }
        return Changed
    }

    /**
     * Returns an `Enumerator` for this set.
     * 
     * @param   {Integer}  ArgSize  parameter size of for-loop
     * @returns {Enumerator}
     */
    __Enum(ArgSize) {
        return Enumer

        Enumer(&Value) {
            static Values := this.M.__Enum(1)
            return Values(&Value)
        }
    }

    /**
     * Returns the size of this set.
     * 
     * @returns {Integer}
     */
    Count => this.M.Count

    /**
     * Retrieves and sets the current capacity of the set.
     */
    CaseSense {
        get => this.M.CaseSense
        set => (this.M.CaseSense := value)
    }

    /**
     * Retrieves and sets the capacity of the backing map.
     */
    Capacity {
        get => this.M.Capacity
        set => (this.M.Capacity := value)
    }

    /**
     * Determines whether the given value is present in the set.
     * 
     * @param   {Any}  Value  any value
     * @returns {Boolean}
     * @example
     * if (MySet[123]) {
     *     ...
     * }
     */
    __Item[Value] => this.Has(Value)

    ; TODO use `Enumerable1` for hashing?

    /**
     * - (Requires `AquaHotkey_Hash`)
     * 
     * Creates a hash code based on the elements contained in this set.
     * 
     * @returns {Integer}
     */
    HashCode() => (Array.Prototype.Hash)(this)

    /**
     * - (Requires `AquaHotkey_Eq`)
     * 
     * Determines whether this set is equal to the `Other` value.
     * 
     * This happens, when both values are sets of the same size and
     * share equivalent values (`.Has(Value)`).
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
        if (!(Other is Set)) {
            return false
        }
        if (this.Count != Other.Count) {
            return false
        }
        for Value in this {
            if (!Other.Has(Value)) {
                return false
            }
        }
        return true
    }
}

class AquaHotkey_Set extends AquaHotkey {
    class Map {
        /**
         * Returns a mutable set view of this map.
         * 
         * @param   {Class}  SetClass  the type of set
         * @returns {Set}
         */
        AsSet(SetClass := Set) {
            if (SetClass != Set && !HasBase(SetClass, Set)) {
                throw TypeError("Expected Set or Set subclass")
            }
            return SetClass.FromMap(this)
        }

        /**
         * Returns a set of all currently contained keys in this map.
         * 
         * @param   {Class}  SetClass  the type of set
         * @returns {Set}
         */
        ToSet(SetClass := Set) {
            if (SetClass != Set && !HasBase(SetClass, Set)) {
                throw TypeError("Expected Set or Set subclass")
            }
            return SetClass(this*)
        }
    }
}