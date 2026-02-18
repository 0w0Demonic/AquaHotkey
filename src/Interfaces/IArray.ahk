#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

; TODO `.Shuffle()` for LinkedList, with the help of the list iterator

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
        this.Backup(Enumerable1, Enumerable2)
    }

    ;@region Construction

    /**
     * Creates a new empty array with the same base object and `Default`
     * behavior of the given array.
     * 
     * @param   {IArray}  Arr  the array to be copied
     * @returns {IArray}
     * @example
     * Arr := Array(1, 2, 3)
     * Arr.Default := "(empty)"
     * 
     * Copy := Array.BasedFrom(Arr)
     * 
     * MsgBox(Copy.Length) ; 0
     * MsgBox(Copy.Capacity) ; 3
     * MsgBox(Copy.Default) ; "(empty)"
     * MsgBox(ObjGetBase(Arr) == ObjGetBase(Copy)) ; always `true`
     */
    static BasedFrom(Arr) {
        static Define := {}.DefineProp
        static GetProp := {}.GetOwnPropDesc
        
        ; note: use literals to avoid `.__Init()` and `.__New()`
        if (Arr is Array) {
            Result := []
        } else {
            Result := {}
        }
        ObjSetBase(Result, ObjGetBase(Arr))
        Result.__Init()
        Result.__New() ; this is assumed to initialize, and push nothing

        ; since we're assigning the same base object, we only need to
        ; define `Default` explicitly if it's directly owned by `Arr`.
        if (ObjHasOwnProp(Arr, "Default")) {
            Define(Result, "Default", GetProp(Arr, "Default"))
        }

        ; let's be lenient and assume everything works *after*
        ; construction.
        if (!this.IsInstance(Result)) {
            throw TypeError("Expected a(n) " . this.Name,, Type(Result))
        }
        return Result
    }

    ;@endregion
    ;---------------------------------------------------------------------------
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
    ;@region Abstract Props

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
    ;@region Matching/Finding

    /**
     * Accepts two arrays and returns the index of the first different item,
     * or `0` if all items are considered equal (`.Eq()`).
     * 
     * @param   {IArray}  A  first array
     * @param   {IArray}  B  second array
     * @returns {Integer}
     * @example
     * Array.Mismatch([1, 2, 3], [1, 2, 4]) ; 3
     * Array.Mismatch([], [])               ; 0
     */
    static Mismatch(A, B) {
        if (!A.Is(this)) {
            throw TypeError("Expected a(n) " . this.Name,, Type(A))
        }
        if (!B.Is(this)) {
            throw TypeError("Expected a(n) " . this.Name,, Type(B))
        }
        Enumer1 := A.__Enum(1)
        Enumer2 := B.__Enum(1)

        loop {
            A := Enumer1(&Value1)
            B := Enumer2(&Value2)

            if (A) {
                if (!B || !Value1.Eq(Value2)) {
                    return A_Index
                }
            } else { ; if (!A) { ... }
                if (B) {
                    return A_Index
                }
                return 0
            }
        }
    }

    /**
     * Searches the array for the specified value (as decided by `.Eq()`),
     * using the binary search algorithm. The index of the first matching
     * element is returned, or `0` if the element could not be found.
     * 
     * This method assumes that the array is sorted first, using the same
     * comparator with which it was sorted, if any.
     * 
     * @param   {Any}       Value  the value to check
     * @param   {Integer?}  Low    index of first element to be searched
     * @param   {Integer?}  High   index of last element to be searched
     * @param   {Func?}     Comp   custom comparator
     * @returns {Integer}
     * @example
     * Array(1, 2, 3, 3, 3, 3, 4, 5, 6).BinarySearch(4) ; 7
     * ;     1  2  3  4  5  6  7  8  9
     * 
     * @example
     * ; custom sort with `Comp`
     * Arr.Sort(Comp)
     * 
     * ; pass `Comp` again, so the binary search knows where to go
     * Arr.BinarySearch(Value,,, Comp)
     */
    BinarySearch(Value, Low := 1, High := this.Length, Comp := Default) {
        static Default(A, B) => A.Compare(B)

        GetMethod(Comp)
        if (!IsInteger(Low)) {
            throw TypeError("Expected an Integer",, Type(Low))
        }
        if (!IsInteger(High)) {
            throw TypeError("Expected an Integer",, Type(High))
        }

        Len := this.Length
        if (Low <= 0 || Low > Len) {
            throw IndexError("invalid low index",, Low)
        }
        if (High <= 0 || High > Len) {
            throw IndexError("invalid high index",, High)
        }

        while (Low <= High) {
            Mid := Low + (High - Low) // 2
            Item := this[Mid]
            if (Item.Eq(Value)) {
                return Mid
            }
            if (Comp(Value, Item) > 0) { ; Value > Item
                Low := Mid + 1
            } else {
                High := Mid - 1
            }
        }
        return 0
    }

    /**
     * Finds the first element that matches the given `Condition`, returning
     * its index, otherwise `0`.
     * 
     * ```ahk
     * Condition(Value?, Args*) => Boolean
     * ```
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

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Misc

    /**
     * Clears the array.
     */
    Clear() {
        this.Length := 0
    }

    /**
     * Repeats this array `X` times.
     * 
     * @param   {Integer}  X  amount of times to repeat the array
     * @returns {IArray}
     * @example
     * [3].Repeat(3) ; [3, 3, 3]
     * 
     * [ [3].Repeat(3) ].Repeat(3) ; [[3, 3, 3], [3, 3, 3], [3, 3, 3]]
     */
    Repeat(X) {
        if (!IsInteger(X)) {
            throw TypeError("Expected an Integer",, Type(X))
        }
        if (X < 0) {
            throw ValueError("< 0",, X)
        }
        Result := IArray.BasedFrom(this)
        loop (X) {
            Result.Push(this*)
        }
        return Result
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Filtering

    /**
     * Returns a new array of all elements that satisfy the given
     * `Condition`.
     * 
     * ```ahk
     * Condition(ArrElement?, Args*)
     * ```
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {IArray}
     * @example
     * Array(1, 2, 3, 4).RetainIf(x => x > 2)    ; [3, 4]
     * Array("foo", "bar").RetainIf(InStr, "f")  ; ["foo"]
     */
    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        
        Result := IArray.BasedFrom(this)
        for Value in this {
            (Condition(Value?, Args*) && Result.Push(Value?))
        }
        return Result
    }

    /**
     * Returns a new array of all elements that do not satisfy the given
     * `Condition`.
     * 
     * ```ahk
     * Condition(ArrElement, Args*)
     * ```
     * 
     * @param   {Predicate}  Condition  the given condition
     * @param   {Any*}       Args       zero or more additional arguments
     * @returns {IArray}
     * @example
     * Array(1, 2, 3, 4).RemoveIf(x => x > 2)    ; [1, 2]
     * Array("foo", "bar").RemoveIf(InStr, "f")  ; ["bar"]
     */
    RemoveIf(Condition, Args*) {
        GetMethod(Condition)

        Result := IArray.BasedFrom(this)
        for Value in this {
            (Condition(Value?, Args*) || Result.Push(Value?))
        }

        return Result
    }

    /**
     * Returns a new array of unique elements by keeping track of them
     * in an {@link ISet}.
     * 
     * A custom `Hasher` can be used to retrieve map keys that should be
     * used to keep track of unique elements with.
     * 
     * ```ahk
     * Hasher(ArrElement: Any?) => Any
     * ```
     * 
     * @param   {Func?}  Hasher    function to create map keys
     * @param   {Any?}   SetParam  internal set options
     * @returns {IArray}
     * @example
     * Array(1, 2, 3, 1).Distinct() ; [1, 2, 3]
     * 
     * ; ["foo"]
     * Array("foo", "Foo", "FOO").Distinct(StrLower)
     * 
     * ; [{ Value: 1 }, { Value: 2 }]
     * Array({ Value: 1 }, { Value: 2 }, { Value: 1 })
     *         .Distinct(  (Obj) => Obj.Value )
     */
    Distinct(Hasher?, SetParam := Set()) {
        S := ISet.Create(SetParam)
        Result := IArray.BasedFrom(this)

        if (IsSet(Hasher)) {
            for Value in this {
                if (S.Add(Hasher(Value?))) {
                    Result.Push(Value?)
                }
            }
            return Result
        }
        for Value in this {
            if (S.Add(Value?)) {
                Result.Push(Value?)
            }
        }
        return Result
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Mapping

    /**
     * Returns a new array containing all values in this array transformed
     * by applying the given `Mapper` function.
     * 
     * ```ahk
     * Mapper(ArrElement?, Args*)
     * ```
     * 
     * @param   {Func}  Mapper  function that returns a new element
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {Array}
     * @example
     * Array(1, 2, 3, 4).Map(x => x * 2)         ; [2, 4, 6, 8]
     * Array("hello", "world").Map(SubStr, 1, 1) ; ["h", "w"]
     */
    Map(Mapper, Args*) {
        GetMethod(Mapper)
        Result := IArray.BasedFrom(this)
        for Value in this {
            Result.Push(Mapper(Value?, Args*))
        }
        return Result
    }

    /**
     * Returns a new array containing all elements in the array
     * transformed by applying the given `Mapper`, resulting arrays
     * flattened into separate elements.
     * 
     * ```ahk
     * Mapper(ArrElement?, Args*)
     * ```
     * 
     * The method defaults to flattening existing array elements,
     * if no `Mapper`
     * is given.
     * 
     * @param   {Func?}  Mapper  function to convert and flatten elements
     * @param   {Any*}   Args    zero or more additional arguments
     * @returns {Array}
     * @example
     * Array("hel", "lo").FlatMap(StrSplit) ; ["h", "e", "l", "l", "o"]
     * Array([1, 2], [3, 4]).FlatMap()      ; [1, 2, 3, 4]
     */
    FlatMap(Mapper?, Args*) {
        Result := IArray.BasedFrom(this)

        if (IsSet(Mapper)) {
            GetMethod(Mapper)
            for Value in this {
                Element := Mapper(Value?, Args*)
                if (Element is Array) {
                    Result.Push(Element*)
                } else {
                    Result.Push(Element )
                }
            }
            return Result
        }
        for Value in this {
            if (IsSet(Value)) {
                if (Value is Array) {
                    Result.Push(Value*)
                } else {
                    Result.Push(Value )
                }
            } else {
                ++Result.Length
            }
        }
        return Result
    }   

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Filling

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
     * Fills the array using a function that produces values.
     * 
     * ```ahk
     * Factory() => Any
     * ```
     * 
     * Note: you can get the array index by using `A_Index` in the function.
     * 
     * @param   {Func}  Factory  function that produces new elements
     * @param   {Any*}  Args     zero or more arguments for `Factory`
     * @returns {this}
     * @example
     * Arr := Array()
     * Arr.Length := 10
     * 
     * ; fill the array with each array index respectively
     * ; 
     * ; --> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
     * Arr.FillWith(() => A_Index)
     */
    FillWith(Factory, Args*) {
        GetMethod(Factory)

        loop (this.Length) {
            this[A_Index] := Factory(Args*)
        }
        return this
    }

    /**
     * Transforms all values in the array in place by applying the given
     * `Mapper`.
     * 
     * ```ahk
     * Mapper(ArrElement?, Args*)
     * ```
     * 
     * @param   {Func}  Mapper  function that returns a new element
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {this}
     * @example
     * Arr := Array(1, 2, 3)
     * 
     * Arr.ReplaceAll(x => (x * 2))
     * Arr.Join(", ").MsgBox() ; "2, 4, 6"
     */
    ReplaceAll(Mapper, Args*) {
        GetMethod(Mapper)
        for Value in this {
            this[A_Index] := Mapper(Value?, Args*)
        }
        return this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Moving Values

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
     * Shuffles the array.
     * 
     * @returns {this}
     */
    Shuffle() {
        Len := this.Length
        loop (Len - 1) {
            this.Swap(A_Index, Random(A_Index, Len))
        }
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
     * @returns {IArray}
     */
    Slice(Begin := 1, End := this.Length, Step := 1) {
        if (!IsInteger(Begin) || !IsInteger(End) || !IsInteger(Step)) {
            throw TypeError("Expected an Integer",,
                            Type(Begin) . " " . Type(End) . " " . Type(Step))
        }
        Length := this.Length
        if (!Begin || !End || !Step) {
            throw IndexError("Out of bounds",,
                             Begin . ", " . End . ", " . Step)
        }
        if (Abs(Begin) > Length || Abs(End) > Length) {
            throw ValueError("array index out of bounds",,
                             "Begin " . Begin . " End " . End)
        }
        if (Begin < 0) {
            Begin := Length + 1 + Begin ; last x elements
        }
        if (End < 0) {
            End := Length + End ; leave out last x elements
        }
        if (Step < 0) {
            Temp  := Begin
            Begin := End
            End   := temp
        }

        Result := IArray.BasedFrom(this)

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
        Length := this.Length
        EndIndex := Length + 1

        loop (Length // 2) {
            this.Swap(A_Index, EndIndex - A_Index)
        }
        return this
    }

    ; TODO sort in place and/or with a new array?

    /**
     * Sorts elements in place according to the given comparator function.
     * 
     * This method assumed that the underlying object works like an array.
     * In other words:
     * 
     * - supports `__Item[Index: Integer] => Any`
     * - index is 1-based
     * 
     * @param   {Object?}   Comp      function that orders two values
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
            Length := Arr.Length
            if (Length <= 1) {
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
            Result.Capacity := Length
            Result.Push(Quicksort(L*)*)
            Result.Push(Pivot?)
            Result.Push(Quicksort(R*)*)
            return Result
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Deque Methods

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
