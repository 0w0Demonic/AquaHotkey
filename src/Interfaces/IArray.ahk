#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * @interface
 * @description
 * 
 * An object that behaves like an array, implementing most of its built-in
 * methods and properties.
 * 
 * Implementing this interface also requires either a constructor of either
 * `static Call(Values*)` or `__New(Values*)`.
 * 
 * @module  <Interfaces/IArray>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class IArray {
    static __New() {
        if (this != IArray) {
            return
        }
        ObjSetBase(this,            ObjGetBase(Array))
        ObjSetBase(this.Prototype,  ObjGetBase(Array.Prototype))
        ObjSetBase(Array,           this)
        ObjSetBase(Array.Prototype, this.Prototype)
        this.Backup(Enumerable1, Enumerable2, Indexable)
    }

    ;@region Type Info

    /**
     * Determines whether the given value is considered instance of
     * {@link IArray}.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     */
    static IsInstance(Val?) => super.IsInstance(Val?)
            || (this == IArray)
                && IsSet(Val)
                && IsObject(Val)
                && HasMethod(Val, "Get")
                && HasMethod(Val, "Has")
                && HasMethod(Val, "InsertAt")
                && HasMethod(Val, "Pop")
                && HasMethod(Val, "Push")
                && HasMethod(Val, "RemoveAt")
                && HasMethod(Val, "__Enum")
                && HasProp(Val, "__Item")
                && HasProp(Val, "Length")
                && HasProp(Val, "Capacity")
    
    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Unimplemented

    /**
     * Unsupported `.Clone()` method.
     * @see {@link Array#Clone}
     */
    Clone() {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Delete()` method.
     * @see {@link Array#Delete}
     */
    Delete(Index) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Get()` method.
     * @see {@link Array#Get}
     */
    Get(Index, *) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Has()` method.
     * @see {@link Array#Has}
     */
    Has(Index) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.InsertAt()` method.
     * @see {@link Array#InsertAt}
     */
    InsertAt(Index, *) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Pop()` method.
     * @see {@link Array#Pop}
     */
    Pop() {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Push()` method.
     * @see {@link Array#Push}
     */
    Push(Values*) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.RemoveAt()` method.
     * @see {@link Array#RemoveAt}
     */
    RemoveAt(Index, Length?) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.__Enum()` method.
     * @see {@link Array#_Enum}
     */
    __Enum(ArgSize) {
        throw PropertyError("not implemented")
    }

    /**
     * Unsupported `.Length` property.
     * @see {@link Array#Length}
     */
    Length {
        get {
            throw PropertyError("not implemented")
        }
        set {
            throw PropertyError("not implemented")
        }
    }

    /**
     * Unsupported `.Capacity` property.
     * @see {@link Array#Capacity}
     */
    Capacity {
        get {
            throw PropertyError("not implemented")
        }
        set {
            throw PropertyError("not implemented")
        }
    }

    /**
     * Unsupported `.__Item[]` property.
     * @see {@link Array#__Item}
     */
    __Item[Index] {
        get {
            throw PropertyError("not implemented")
        }
        set {
            throw PropertyError("not implemented")
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Default Methods

    /**
     * Returns and removes the first item from the array.
     * 
     * @returns {Any}
     * @example
     * Arr := Array("A", "B")
     * MsgBox(Arr.Poll()) ; "A"
     * MsgBox(Arr[1])     ; "B"
     */
    Poll() => this.RemoveAt(1)

    /**
     * Clears the array.
     */
    Clear() => (this.Length := 0)

    /**
     * Fills the array with the specified value.
     * 
     * @param   {Any?}  Value  the value to set
     * @returns {this}
     */
    Fill(Value?) {
        loop (this.Length) {
            this[A_Index] := (Value?)
        }
        return this
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

    /**
     * Returns a stream of elements repeatedly `.Pop()`-ed from the array.
     * 
     * @returns {Stream}
     * @example
     * Stack := Array(1, 2, 3)
     * for Value in Stack.Drain() {
     *     MsgBox(Value) ; 3, 2, 1
     * }
     * MsgBox(Stack.IsEmpty) ; true
     * 
     * @example
     * Arr := Array(1, 2, 3, 4)
     * Arr.Drain().Map(x => x * x).ForEach(MsgBox) ; 16, 9, 4, 1
     * 
     * MsgBox(Arr.IsEmpty) ; true
     */
    Drain() {
        return Stream(Drain)

        Drain(&Out) {
            if (!this.IsEmpty) {
                Out := (this.Pop()?)
                return true
            }
            return false
        }
    }

    /**
     * Returns a stream of elements repeatedly `.Poll()`-ed from the array.
     * 
     * @returns {Stream}
     * @example
     * Lifo := Array(1, 2, 3)
     * 
     * for Value in Lifo.Slurp() {
     *     MsgBox(Lifo) ; 1, 2, 3
     * }
     * MsgBox(Lifo.IsEmpty) ; true
     * 
     * @example
     * Arr := Array(1, 2, 3, 4)
     * Arr.Slurp().Map(x => x * x).ForEach(MsgBox) ; 1, 4, 9, 16
     * 
     * MsgBox(Arr.IsEmpty) ; true
     */
    Slurp() {
        return Stream(Slurp)

        Slurp(&Out) {
            if (!this.IsEmpty) {
                Out := (this.Poll()?)
                return true
            }
            return false
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Default Properties

    /**
     * Determines whether the array is empty.
     * 
     * @returns {Boolean}
     */
    IsEmpty => (!this.Length)

    /**
     * Determines whether the array is not empty.
     * 
     * @returns {Boolean}
     */
    IsNotEmpty => (!!this.Length)
}
