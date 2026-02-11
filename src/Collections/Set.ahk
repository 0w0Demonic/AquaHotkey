/**
 * A simple implementation of {@link ISet} which wraps around instances of
 * {@link IMap}.
 * 
 * A simple set implementation based on the built-in `Map` type.
 * 
 * @module  <Collections/Set>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Set extends ISet {
    /**
     * Constructs a new set with backing `Map` containing the given
     * values as elements.
     * 
     * @constructor
     * @param   {Any*}  Values  zero or more elements
     */
    static Call(Values*) => this.FromMap(Map(), Values*)

    /**
     * Creates a set using the given backing map.
     * 
     * @constructor
     * @param   {IMap}  M       the backing map
     * @param   {Any*}  Values  zero or more elements to be added
     * @returns {Set}
     */
    static FromMap(M, Values*) {
        if (!M.Is(IMap)) {
            throw TypeError("Expected an IMap",, Type(M))
        }
        Obj := Object()
        Obj.DefineProp("M", { Get: (_) => M })
        ObjSetBase(Obj, this.Prototype)
        if (Values.Length) {
            Obj.Add(Values*)
        }
        return Obj
    }

    /**
     * Adds one or more values to the set.
     * 
     * @param   {Any}   Value   any value
     * @param   {Any*}  Values  zero or more values
     * @returns {Boolean}
     * @example
     * S := Set()
     * S.Add("value1", "value2")
     * MsgBox(S.Contains("value1")) ; true
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
     * Clears the set.
     */
    Clear() {
        (this.M).Clear()
    }

    /**
     * Clones the set.
     * 
     * @returns {Set}
     */
    Clone() {
        M := this.M.Clone()
        Obj := Object()
        Obj.DefineProp("M", { Get: (_) => M })
        ObjSetBase(Obj, ObjGetBase(this))
        return Obj
    }

    /**
     * Deletes one or more values from the set. If the set contained
     * any of the values, this method returns `true`, otherwise `false`.
     * 
     * @param   {Any}   Value   any value
     * @param   {Any*}  Values  more values
     * @returns {Boolean}
     */
    Delete(Value, Values*) {
        M := this.M
        Changed := M.Has(Value)
        M.Delete(Value)

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
     * Set(1, 2, 3).Contains(3) ; true
     */
    Contains(Value) => (this.M).Has(Value)

    /**
     * Returns an `Enumerator` for the set.
     * 
     * @param   {Integer}  ArgSize  parameter size of for-loop
     * @returns {Enumerator}
     */
    __Enum(ArgSize) => (this.M).__Enum(1)

    /**
     * Amount of elements contained in the set.
     * 
     * @returns {Integer}
     */
    Size => (this.M).Count

    /**
     * Returns a mutable map view of the set.
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
    AsMap() => (this.M)

    /**
     * Returns a map containing a copy of all the current elements in
     * the set.
     * 
     * @example
     * S := Set(1, 2, 3)
     * 
     * ; Map { 1 => true, 2 => true, 3 => true }
     * M := S.ToMap()
     * M.Set("foo", true)
     * 
     * S.Contains("foo")
     */
    ToMap() => (this.M).Clone()

    /**
     * Retrieves and sets the current capacity of the set.
     */
    CaseSense {
        get => (this.M).CaseSense
        set => ((this.M).CaseSense := value)
    }

    /**
     * Retrieves and sets the capacity of the backing map.
     */
    Capacity {
        get => this.M.Capacity
        set => ((this.M).Capacity := value)
    }
}

class AquaHotkey_Set extends AquaHotkey {
    class IMap {
        /**
         * Returns a mutable set view of this map.
         * 
         * @param   {Class}  SetClass  the type of set
         * @returns {Set}
         */
        AsSet(SetClass := Set) {
            if (!Set.CanCastFrom(SetClass)) {
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
            if (!Set.CanCastFrom(SetClass)) {
                throw TypeError("Expected Set or Set subclass")
            }
            return SetClass.FromMap(this.Clone())
        }
    }
}