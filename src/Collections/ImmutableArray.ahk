#Requires AutoHotkey v2.0

#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IArray.ahk"

; TODO implement `static Eq()` and `static HashCode()`
;      (Tuple is meant to be an alias of ImmutableArray)

/**
 * An immutable view of an {@link IArray}
 * 
 * @module  <Collections/ImmutableArray>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @see {@link Tuple}
 */
class ImmutableArray extends IArray {
    /**
     * Creates an immutable array view from an existing {@link IArray}.
     * 
     * @param   {IArray}  A  any array-like object
     * @returns {ImmutableArray}
     * @see {@link AquaHotkey_ImmutableArray `.Freeze()`}
     * @example
     * A := Array(1, 2, 3)
     * IA := ImmutableArray.FromArray(A)
     */
    static FromArray(A) {
        if (!A.Is(IArray)) {
            throw TypeError("Expected an IArray")
        }
        Obj := Object()
        Obj.DefineProp("A", { Get: (_) => A })
        ObjSetBase(Obj, this.Prototype)
        return Obj
    }

    /**
     * Creates an immutable array containing the specified elements.
     * 
     * @param   {Any*}  Values  zero or more values
     * @returns {ImmutableArray}
     */
    static Call(Values*) => this.FromArray(Values)

    /**
     * Returns a clone of this immutable array.
     * 
     * @returns {ImmutableArray}
     */
    Clone() => ImmutableArray.FromArray((this.A).Clone())

    /**
     * Retrieves an element from the immutable array.
     * 
     * @param   {Integer}  Index    array index
     * @param   {Any?}     Default  default value
     * @returns {Any}
     */
    Get(Index, Default?) => (this.A).Get(Index, Default?)

    /**
     * Determines whether the index is valid and there is a value at the
     * given index.
     * 
     * @param   {Integer}  Index  array index
     * @returns {Boolean}
     */
    Has(Index) => (this.A).Has(Index)

    /**
     * Returns an {@link Enumerator} for the immutable array.
     * 
     * @returns {Enumerator}
     */
    __Enum(ArgSize) => (this.A).__Enum(ArgSize)

    /**
     * Readonly `.Length`.
     * 
     * @returns {Integer}
     */
    Length => (this.A).Length

    /**
     * Readonly `.Capacity`.
     * 
     * @returns {Integer}
     */
    Capacity => (this.A).Capacity

    /**
     * Readonly `.Default`.
     * 
     * @returns {Any}
     */
    Default => (this.A).Default

    /**
     * Readonly `.__Item[]`.
     * 
     * @param   {Integer}  Index  array index
     * @returns {Any}
     */
    __Item[Index] => (this.A)[Index]
}

class AquaHotkey_ImmutableArray extends AquaHotkey {
    class IArray {
        /**
         * Creates an immutable view of the IArray.
         * 
         * @returns {ImmutableArray}
         * @see {@link Tuple}
         * @example
         * A := Array(1, 2, 3, 4).Freeze()
         * 
         * ; more conveniently:
         * T := Tuple(1, 2, 3, 4)
         */
        Freeze() {
            if (this is ImmutableArray) {
                return this
            }
            return ImmutableArray.FromArray(this)
        }
    }
}

/**
 * Alias for {@link ImmutableArray}.
 */
class Tuple extends ImmutableArray {
    ; `is Tuple` becomes equivalent to `is ImmutableArray`.
    static __New() => (this.Prototype := ObjGetBase(this).Prototype)
}