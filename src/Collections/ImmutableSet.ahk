#Include "%A_LineFile%\..\Set.ahk"

;@region ImmutableSet
/**
 * An immutable view of an {@link ISet}.
 * 
 * @module  <Collections/ImmutableSet>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class ImmutableSet extends ISet {
    ;@region Construction

    /**
     * Creates a new immutable set consisting of the specified elements.
     * The elements themselves are still mutable.
     * 
     * @param   {Any*}  Values  zero or more elements
     * @returns {ImmutableSet}
     */
    static Call(Values*) => this.FromSet(Set(Values*))

    /**
     * Returns a new immutable set by wrapping over an existing {@link ISet}.
     * 
     * @param   {ISet}  S  a set to be wrapped over
     * @returns {ImmutableSet}
     */
    static FromSet(S) {
        if (!S.Is(ISet)) {
            throw TypeError("Expected an ISet",, Type(S))
        }
        if (S is ImmutableSet) {
            return S
        }
        Obj := Object()
        Obj.DefineProp("S", { Get: (_) => S })
        ObjSetBase(Obj, this.Prototype)
        return Obj
    }

    /**
     * Creates an immutable set view of an {@link IMap}.
     * 
     * @param   {IMap}  M  backing map
     * @returns {ImmutableSet}
     */
    static FromMap(M) {
        if (!M.Is(IMap)) {
            throw TypeError("Expected an IMap",, Type(M))
        }
        return this.FromSet(Set.FromMap(M))
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Implementation

    /**
     * Returns a shallow clone of the immutable set.
     * 
     * @returns {ImmutableSet}
     */
    Clone() => ImmutableSet.FromSet((this.S).Clone())

    /**
     * Determines whether the given value is present in the set.
     * 
     * @param   {Any}  Value  any value
     * @returns {Boolean}
     */
    Contains(Value) => (this.S).Contains(Value)

    /**
     * Returns an {@link Enumerator} for the set.
     * 
     * @param   {Integer}  ArgSize  arg-size of for-loop
     * @returns {Enumerator}
     */
    __Enum(ArgSize) => (this.S).__Enum(ArgSize)

    /**
     * Returns the size of the set.
     * 
     * @returns {Integer}
     */
    Size => (this.S).Size

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

/**
 * Extension methods related to {@link ImmutableSet}.
 */
class AquaHotkey_ImmutableSet extends AquaHotkey {
    class ISet {
        /**
         * Returns a read-only view of this set. The original set may still
         * be modified elsewhere.
         * 
         * @returns {ImmutableSet}
         */
        Freeze() {
            if (this is ImmutableSet) {
                return this
            }
            return ImmutableSet.FromSet(this)
        }
    }
}