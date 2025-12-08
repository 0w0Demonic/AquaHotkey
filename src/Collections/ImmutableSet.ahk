#Include "%A_LineFile%\..\Set.ahk"

/**
 * 
 */
class ImmutableSet extends Set
{
    __New(Values*) {
        if (this.Count) {
            throw Error("This set is immutable", -2)
        }
        super(Values*)
    }

    Clear() {
        throw PropertyError("This set is immutable", -2)
    }

    Delete(*) {
        throw PropertyError("This set is immutable", -2)
    }

    Add(*) {
        throw PropertyError("This set is immutable", -2)
    }
}

class AquaHotkey_ImmutableSet {
    static __New() => (this == AquaHotkey_ImmutableSet)
                && IsSet(AquaHotkey) && (AquaHotkey is Class)
                && (AquaHotkey.__New)(this)

    class Set {
        Immutable() => ImmutableSet.FromMap(this.M)
    }

    class ImmutableSet {
        Immutable() => this
    }
}

S := Map(1, 2, 3, 4).AsSet(ImmutableSet)