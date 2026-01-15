#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

; TODO add back Swap() with unset handling
; TODO reverse view?

/**
 * Array stream-like operations.
 * 
 * @module  <Collections/Array>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Array extends AquaHotkey {
class Array {
    /**
     * Creates a new empty array with the same base object, capacity and
     * `Default` behaviour of the given array. None of the actual elements
     * are copied.
     * 
     * @param   {Array}  Arr  the array to be copied
     * @returns {Array}
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
        static Define  := {}.DefineProp
        static GetProp := {}.GetOwnPropDesc

        Result := Array()
        ObjSetBase(Result, ObjGetBase(Arr))
        Result.Capacity := Arr.Length

        for PropertyName in ObjOwnProps(Arr) {
            Define(Result, PropertyName, GetProp(Arr, PropertyName))
        }
        return Result
    }

    /**
     * Returns a new array containing all values in this array transformed
     * by applying the given `Mapper` function.
     * 
     * ```ahk
     * Mapper(ArrElement?, Args*)
     * ```
     * 
     * @example
     * Array(1, 2, 3, 4).Map(x => x * 2)         ; [2, 4, 6, 8]
     * Array("hello", "world").Map(SubStr, 1, 1) ; ["h", "w"]
     * 
     * @param   {Func}  Mapper  function that returns a new element
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {Array}
     */
    Map(Mapper, Args*) {
        GetMethod(Mapper)
        Result := Array.BasedFrom(this)
        for Value in this {
            Result.Push(Mapper(Value?, Args*))
        }
        return Result
    }

    /**
     * Transforms all values in the array in place by applying the given
     * `Mapper`.
     * 
     * ```ahk
     * Mapper(ArrElement?, Args*)
     * ```
     * 
     * @example
     * Arr := Array(1, 2, 3)
     * 
     * Arr.ReplaceAll(x => (x * 2))
     * Arr.Join(", ").MsgBox() ; "2, 4, 6"
     * 
     * @param   {Func}  Mapper  function that returns a new element
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {this}
     */
    ReplaceAll(Mapper, Args*) {
        GetMethod(Mapper)
        for Value in this {
            this[A_Index] := Mapper(Value?, Args*)
        }
        return this
    }

    /**
     * Returns a new array containing all elements in the array transformed by
     * applying the given `Mapper`, resulting arrays flattened into separate
     * elements.
     * 
     * ```ahk
     * Mapper(ArrElement?, Args*)
     * ```
     * 
     * The method defaults to flattening existing array elements, if no `Mapper`
     * is given.
     * 
     * @example
     * Array("hel", "lo").FlatMap(StrSplit)       ; ["h", "e", "l", "l", "o"]
     * Array([1, 2], [3, 4]).FlatMap()            ; [1, 2, 3, 4]
     * Array("a,b", "c,d").FlatMap(StrSplit, ",") ; ["a", "b", "c", "d"]
     * 
     * @param   {Func?}  Mapper  function to convert and flatten elements
     * @param   {Any*}   Args    zero or more additional arguments
     * @returns {Array}
     */
    FlatMap(Mapper?, Args*) {
        Result := Array.BasedFrom(this)

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
    
    /**
     * Returns a new array of all elements that satisfy the given `Condition`.
     * 
     * ```ahk
     * Condition(ArrElement?, Args*)
     * ```
     * 
     * @example
     * Array(1, 2, 3, 4).RetainIf(x => x > 2)    ; [3, 4]
     * Array("foo", "bar").RetainIf(InStr, "f")  ; ["foo"]
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {Array}
     */
    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        Result := Array.BasedFrom(this)
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
     * @example
     * Array(1, 2, 3, 4).RemoveIf(x => x > 2)    ; [1, 2]
     * Array("foo", "bar").RemoveIf(InStr, "f")  ; ["bar"]
     * 
     * @param   {Predicate}  Condition  the given condition
     * @param   {Any*}       Args       zero or more additional arguments
     * @returns {Array}
     */
    RemoveIf(Condition, Args*) {
        GetMethod(Condition)
        Result := Array.BasedFrom(this)
        for Value in this {
            (Condition(Value?, Args*) || Result.Push(Value?))
        }
        return Result
    }

    /**
     * Returns a new array of unique elements by keeping track of them in a Map.
     * 
     * A custom `Hasher` can be used to specify the map key to be used.
     * 
     * ```ahk
     * Hasher(ArrElement?)
     * ```
     * 
     * You can determine the behavior of the internal Map by passing either...
     * - the map to be used;
     * - a function that returns the map to be used;
     * - a case-sensitivity option
     * 
     * ...as value for the `MapParam` parameter.
     * 
     * @example
     * ; [1, 2, 3]
     * Array(1, 2, 3, 1).Distinct()
     * 
     * ; ["foo"]
     * Array("foo", "Foo", "FOO").Distinct(StrLower)
     * 
     * ; [{ Value: 1 }, { Value: 2 }]
     * Array({ Value: 1 }, { Value: 2 }, { Value: 1 })
     *         .Distinct(  (Obj) => Obj.Value )
     * 
     * @param   {Func?}                  Hasher    function to create map keys
     * @param   {Map?/Func?/Primitive?}  MapParam  internal map options
     * @returns {Array}
     */
    Distinct(Hasher?, MapParam := Map()) {
        ; TODO rethink how values are saved
        switch {
            case (MapParam is Map):
                Cache := MapParam
            case (HasMethod(MapParam)):
                Cache := MapParam()
                if (!(Cache is Map)) {
                    throw TypeError("Expected a Map",, Type(Cache))
                }
            default:
                Cache := Map()
                Cache.CaseSense := MapParam
        }

        Result := Array.BasedFrom(this)
        if (IsSet(Hasher)) {
            for Value in this {
                Key := Hasher(Value?)
                if (!Cache.Has(Key)) {
                    Result.Push(Value)
                    Cache[Key] := true
                }
            }
            return Result
        }
        for Value in this {
            if (IsSet(Value) && !Cache.Has(Value)) {
                Result.Push(Value)
                Cache[Value] := true
            }
        }
        return Result
    }

    /**
     * Accepts two arrays and returns the index of the first different item,
     * or `0` if all items are considered equal (`.Eq()`).
     * 
     * @param   {Array}  A  first array
     * @param   {Array}  B  second array
     * @returns {Integer}
     * @example
     * Array.Mismatch([1, 2, 3], [1, 2, 4]) ; 3
     * Array.Mismatch([], [])               ; 0
     */
    static Mismatch(A, B) {
        if (!(A is Array)) {
            throw TypeError("Expected an Array",, Type(A))
        }
        if (!(B is Array)) {
            throw TypeError("Expected an Array",, Type(B))
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
     * Searches the array for the specified value (as decided by `.Eq()`), using
     * the binary search algorithm. The index of the first matching element is
     * returned, or `0` if the element could not be found.
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
    BinarySearch(Value, Low := 1, High := this.Length, Comp := DefaultComp) {
        static DefaultComp(A, B) => A.Compare(B)

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
     * Repeats this array `X` times.
     * 
     * @param   {Integer}  X  amount of times to repeat the array
     * @returns {Array}
     * @example
     * [3].Repeat(3) ; [3, 3, 3]
     * 
     * [ [3].Repeat(3) ].Repeat(3) ; [[3, 3, 3], [3, 3, 3], [3, 3, 3]]
     */
    Repeat(X) {
        ; TODO move this somewhere else?
        if (!IsInteger(X)) {
            throw TypeError("Expected an Integer",, Type(X))
        }
        Result := Array()
        Result.Capacity := X * this.Length
        loop (X) {
            Result.Push(this*)
        }
        return Result
    }

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

    ; TODO add...
    ; - SetAll() ?
    ; - ReplaceAll(Value, NewValue) ?
} ; class Array
} ; class AquaHotkey_Array extends AquaHotkey
