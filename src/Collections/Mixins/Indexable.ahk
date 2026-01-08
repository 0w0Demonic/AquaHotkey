#Include "%A_LineFile%\..\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\..\Func\Comparator.ahk"
#Include "%A_LineFile%\..\..\..\Base\Ord.ahk"
#Include "%A_LineFile%\..\..\..\Collections\Mixins\Sizeable.ahk"

/**
 * @mixin
 * Assumes:
 * 
 * - `Size => Integer`
 * - `__Item[Key: Integer] => Any`
 * - supports `.__Enum(1)`
 */
class Indexable {
    static __New() {
        (AquaHotkey_Ord, AquaHotkey_Sizeable)
        this.ApplyOnto(Array)
    }

    /**
     * Finds the first element that matches the given `Condition`, returning
     * its index, otherwise `0`.
     * 
     * ```ahk
     * Condition(Value?, Args*) => Boolean
     * ```
     * 
     * `A_Index` can be accessed in the condition function.
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more arguments
     * @returns {Integer}
     * @example
     * Array.FindIndex((v) => (A_Index == 7) || (v == "expected value"))
     */
    FindIndex(Condition, Args*) {
        GetMethod(Condition)
        for Value in this {
            if (Condition(Value?, Args*)) {
                return A_Index
            }
        }
        return 0
    }

    /**
     * Swaps two values by index.
     * 
     * @param   {Integer}  A  first index
     * @param   {Integer}  B  second index
     * @returns {this}
     */
    Swap(A, B) {
        if (!IsInteger(A)) {
            throw TypeError("Expected an Integer",, A)
        }
        if (!IsInteger(B)) {
            throw TypeError("Expected an Integer",, B)
        }
        Temp    := this[A]
        this[A] := this[B]
        this[B] := Temp
        return this
    }

    /**
     * Returns an array slice from index `Begin` to `End` (inclusive),
     * selecting elements at an interval `Step`.
     * 
     * @example
     * Array(21, 23, 453, -73).Slice(, 2)  ; [21, 23]
     * Array(1, 2, 3, 4).Slice(2, -1)      ; [2, 3]
     * Array(1, 2, 3, 4, 5).Slice(1, 4, 2) ; [1, 3]
     * 
     * @param   {Integer?}  Begin  start index
     * @param   {Integer?}  End    end index
     * @param   {Integer?}  Step   interval at which elements are selected
     * @returns {Array}
     */
    Slice(Begin := 1, End := this.Size, Step := 1) {
        if (!IsInteger(Begin) || !IsInteger(End) || !IsInteger(Step)) {
            throw TypeError("Expected an Integer",,
                            Type(Begin) . " " . Type(End) . " " . Type(Step))
        }
        Size := this.Size
        if (!Begin || !End || !Step) {
            throw IndexError("Out of bounds",,
                             Begin . ", " . End . ", " . Step)
        }
        if (Abs(Begin) > Size || Abs(End) > Size) {
            throw ValueError("array index out of bounds",,
                             "Begin " . Begin . " End " . End)
        }
        if (Begin < 0) {
            Begin := Size + 1 + Begin ; last x elements
        }
        if (End < 0) {
            End := Size + End ; leave out last x elements
        }
        if (Step < 0) {
            Temp  := Begin
            Begin := End
            End   := temp
        }

        Result          := Array()
        Result.Capacity := (Abs(Begin - End) + 1) // Abs(Step)

        if (Step > 0) {
            while (Begin <= End) {
                Result.Push(this[Begin])
                Begin += Step
            }
            return Result
        }
        while (Begin >= End) {
            Result.Push(this[Begin])
            Begin += Step
        }
        return Result
    }

    ; TODO change how this method works?
    /**
     * Reverses all elements in place.
     * 
     * @returns {this}
     * @example
     * Array(1, 2, 3, 4).Reverse() ; [4, 3, 2, 1]
     */
    Reverse() {
        Size := this.Size
        EndIndex := Size + 1

        loop (Size // 2) {
            this.Swap(A_Index, EndIndex - A_Index)
        }
        return this
    }

    ; TODO move this into a mixin more specific than `Indexable`?

    /**
     * Sorts elements in place according to the given comparator function.
     * 
     * This method assumed that the underlying object works like an array.
     * In other words:
     * 
     * - supports `__Item[Index: Integer] => Any`
     * - index is 1-based
     * 
     * @param   {Func?}     Comp      function that orders two values
     * @param   {Boolean?}  Reversed  sort in reverse order
     * @returns {this}
     * @see {@link Comparator}
     * @example
     * Array(5, 1, 2, 7).Sort() ; [1, 2, 5, 7]
     */
    Sort(Comp := Any.Compare, Reversed := false) {
        GetMethod(Comp)
        if (Reversed) {
            Comp := Comparator(Comp).Rev()
        }

        for Value in Quicksort(this*) {
            this[A_Index] := (Value?)
        }
        return this

        Quicksort(Arr*) {
            Size := Arr.Size
            if (Size <= 1) {
                return Arr
            }
            L := Array()
            R := Array()

            Enumer := Arr.__Enum(1)
            Enumer(&Pivot) ; grab first element as pivot
            for Value in Enumer {
                (Comp(Value?, Pivot?) < 0 ? L : R).Push(Value?)
            }

            Result := Array()
            Result.Capacity := Size
            Result.Push(Quicksort(L*)*)
            Result.Push(Pivot?)
            Result.Push(Quicksort(R*)*)
            return Result
        }
    }
}
