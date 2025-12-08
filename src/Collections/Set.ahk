; TODO somehow add StreamOps to this

/**
 * A simple set implementation based on the built-in `Map` type.
 * 
 * @module  <Collections/Set>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Set
{
    /**
     * Constructs a new set by accepting a backing map.
     * 
     * @param   {Map}  M  the backing map
     * @returns {Set}
     */
    static FromMap(M) {
        ObjSetBase(Result := Object(), this.Prototype)
        Result.DefineProp("M", { Get: (_) => M })
        return Result
    }

    /**
     * Constructs a new set containing the given values as elements.
     * 
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
     * @example
     * S := Set(1, 2, 3)
     * 
     * ; Map { 1 => true, 2 => true, 3 => true }
     * M := S.AsMap()
     * M.Set("foo", true)
     * 
     * S.Contains("foo") ; true
     * 
     * @returns {Map}
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
     * S.Contains("foo")
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
     * 
     */
    Has(Value) => this.M.Has(Value)

    /**
     * 
     */
    Contains(Value) => this.M.Has(Value)

    /**
     * 
     */
    HasAny(Value, Values*) {

    }

    /**
     * 
     */
    ContainsAny(Value, Values*) {

    }

    /**
     * 
     */
    HasAll(Value, Values*) {

    }

    /**
     * 
     */
    ContainsAll(Value, Values*) {

    }

    /**
     * 
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
     * Determines whether the given value is present in the set.
     * 
     * @param   {Any}  Value  any value
     * @returns {Boolean}
     */
    __Item[Value] => this.Has(Value)
    
    ; TODO move this somehow into StreamOps, along with the mixin stuff

    /**
     * 
     */
    ForEach(Action, Args*) {
        for Value in this {
            Action(Value, Args*)
        }
        return this
    }

    /**
     * Returns an array containing all current elements in this set.
     * 
     * @returns {Array}
     */
    ToArray() => Array(this*)

    /**
     * - (Requires `AquaHotkey_Hash`)
     * 
     * Creates a hash code based on the elements contained in this set.
     * 
     * @returns {Integer}
     */
    Hash() => (Array.Prototype.Hash)(this)

    /**
     * - (Requires `AquaHotkey_Eq`)
     * 
     * Determines whether this set is equal to the `Other` value.
     * 
     * This happens, when both values are sets of the same size and
     * share equivalent values (`.Contains(Value)`).
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

    static __New() {
        if (this != Set) {
            return
        }
        if (!IsSet(AquaHotkey_Hash)) {
            this.Prototype.DeleteProp("Hash")
        }
        if (!IsSet(AquaHotkey_Eq)) {
            this.Prototype.DeleteProp("Eq")
        }
    }
}

#Include <AquaHotkey>

class AquaHotkey_Set
{
    static __New() => (this == AquaHotkey_Set)
                && IsSet(AquaHotkey) && (AquaHotkey is Class)
                && (AquaHotkey.__New)(this)

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

        ; TODO static FromSet() or similar?
    }
}