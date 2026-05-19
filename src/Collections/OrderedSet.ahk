#Include "%A_LineFile%\..\Set.ahk"
#Include "%A_LineFile%\..\OrderedMap.ahk"
#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Interfaces\ISet.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IMap.ahk"

/**
 * A doubly-linked list-backed {@link ISet} that preserves insertion order.
 * 
 * @module  <Collections/OrderedSet>
 * @author  0w0Demonic
 * @see     https://wwww.github.com/0w0Demonic
 */
class OrderedSet extends Set {
    /**
     * Creates a new ordered set with the given elements.
     * 
     * @constructor
     * @param   {Any*}  Values  zero or more elements
     */
    __New(Values*) {
        M := OrderedMap()
        this.DefineProp("M", { Get: (_) => M })
        this.Add(Values*)
    }

    /**
     * Creates an ordered set using the given backing map.
     * 
     * @constructor
     * @param   {IMap}  M       the backing map
     * @param   {Any*}  Values  elements to be added
     * @returns {OrderedSet}
     * @override {@link Set.FromMap()}
     */
    static FromMap(M, Values*) {
        if (!M.Is(IMap)) {
            throw TypeError("Expected an IMap",, Type(M))
        }
        return super.FromMap((M.Is(OrderedMap)) ? M : M.Ordered(), Values*)
    }

    /**
     * Adds elements at the back of the set.
     * 
     * @param   {Any*}  Values  zero or more elements to be added
     * @returns {Integer}
     */
    Push(Values*) => this.Add(Values*)

    /**
     * Adds elements at the front of the set.
     * 
     * @param   {Any*}  Values  zero or more elements to be added
     * @returns {Integer}
     */
    Shove(Values*) {
        Count := 0
        for Value in Values {
            Count += !(this.M).Has(Value)
            (this.M).Shove(Value, true)
        }
        return Count
    }

    /**
     * Removes and returns the first element in the ordered set.
     * 
     * @returns {Any}
     */
    Poll() {
        (this.M).Poll(&Key, &Value)
        return Key
    }

    /**
     * Removes and returns the last element in the ordered set.
     * 
     * @returns {Any}
     */
    Pop() {
        (this.M).Pop(&Key, &Value)
        return Key
    }
}

/**
 * Extension methods related to {@link OrderedSet}.
 */
class AquaHotkey_OrderedSet extends AquaHotkey {
    class ISet {
        /**
         * Creates an ordered version of this set.
         * 
         * @returns {OrderedSet}
         */
        Ordered() {
            if (this is OrderedSet) {
                return this
            }
            return OrderedSet(this*)
        }
    }
}
