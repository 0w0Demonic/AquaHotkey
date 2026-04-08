#Requires AutoHotkey v2.0

#Include "%A_LineFile%\..\OrderedMap.ahk"

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
}

class AquaHotkey_OrderedSet extends AquaHotkey {
    class ISet {
        /**
         * Creates an ordered version of this set.
         * 
         * @returns {OrderedSet}
         */
        Ordered() => OrderedSet(this*)
    }
}
#Include <AquaHotkeyX>

OS := Map(1, false, 2, false).AsSet().Ordered()

OS.Shove(0)
OS.Join(", ").MsgBox()