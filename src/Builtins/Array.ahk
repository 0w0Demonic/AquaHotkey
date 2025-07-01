class AquaHotkey_Array extends AquaHotkey {
/**
 * AquaHotkey - Array.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/Array.ahk
 */
class Array {
    /**
     * Sets the `Default` property of this array which is returned when
     * accessing an unset element.
     * 
     * @example
     * Arr := Array().SetDefault(false)
     * 
     * @param   {Any}  Default  new array default value
     * @return  {this}
     */
    SetDefault(Default) {
        this.Default := Default
        return this
    }

    /**
     * Sets the `Length` property of this array.
     * 
     * @example
     * Arr := Array().SetLength(16)
     * 
     * @param   {Integer}  Length  new array length
     * @return  {this}
     */
    SetLength(Length) {
        this.Length := Length
        return this
    }

    /**
     * Sets the `Capacity` property of this array.
     * 
     * @example
     * Arr := Array().SetCapacity(16)
     * 
     * @param   {Integer}  Capacity  new array capacity
     * @return  {this}
     */
    SetCapacity(Capacity) {
        this.Capacity := Capacity
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
     */
    Slice(Begin := 1, End := this.Length, Step := 1) {
        if (!IsInteger(Begin) || !IsInteger(End) || !IsInteger(Step)) {
            throw TypeError("Expected an Integer",,
                            Type(Begin) . " " . Type(End) . " " . Type(Step))
        }
        if (!Begin || !End || !Step) {
            throw IndexError("Out of bounds",,
                             Begin . ", " . End . ", " . Step)
        }
        if (Abs(Begin) > this.Length || Abs(End) > this.Length) {
            throw ValueError("array index out of bounds",,
                             "Begin " . Begin . " End " . End)
        }
        if (Begin < 0) {
            Begin := this.Length + 1 + Begin ; last x elements
        }
        if (End < 0) {
            End := this.Length + End ; leave out last x elements
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
                if (this.Has(Begin)) {
                    Result.Push(this[Begin])
                } else {
                    Result.Push(unset)
                }
                Begin += Step
            }
            return Result
        }
        while (Begin >= End) {
            if (this.Has(Begin)) {
                Result.Push(this[Begin])
            } else {
                Result.Push(unset)
            }
            Begin += Step
        }
        return Result
    }

    /**
     * Returns `true`, if the array is empty (its length is zero).
     * 
     * @example
     * Array().IsEmpty   ; true
     * Array(42).IsEmpty ; false
     *  
     * @return  {Boolean}
     */
    IsEmpty => (!this.Length)

    /**
     * Returns `true`, if the array has values.
     * 
     * @example
     * Array(unset, 42).HasElements ; true
     * Array(unset, unset).HasElements ; false
     * 
     * @return  {Boolean}
     */
    HasElements {
        Get {
            for Value in this {
                if (IsSet(Value)) {
                    return true
                }
            }
            return false
        }
    }
    
    /**
     * Swaps two elements in the array with indices `a` and `b`.
     * 
     * This method properly swaps unset values, but throws an error if the index
     * if out of bounds.
     * 
     * @example
     * Arr := Array(1, 2, 3, 4)
     * Arr.Swap(2, 4) ; [1, 4, 3, 2]
     * 
     * @param   {Integer}  a  first index
     * @param   {Integer}  b  second index
     * @return  {this}
     */
    Swap(a, b) {
        (this.Has(a) && Temp := this[a])
        if (this.Has(b)) {
            this[a] := this[b]
        } else {
            this.Delete(a)
        }
        if (IsSet(Temp)) {
            this[b] := Temp
        } else {
            this.Delete(b)
        }
        return this
    }
    
    /**
     * Reverses the array in place.
     * 
     * @example
     * Array(1, 2, 3, 4).Reverse() ; [4, 3, 2, 1]
     * 
     * @return  {this}
     */
    Reverse() {
        EndIndex := this.Length + 1
        Loop (this.Length // 2) {
            this.Swap(A_Index, EndIndex - A_Index)
        }
        return this
    }

    /**
     * Sorts the array in place according to the given `Comparator` function.
     * 
     * The array is sorted in reverse order, if `Reversed` is set to `true`.
     * @see `Comparator`
     * 
     * @example
     * Array(5, 1, 2, 7).Sort() ; [1, 2, 5, 7]
     * 
     * @param   {Func?}     Comp        function that orders two values
     * @param   {Boolean?}  Reversed    sort in reverse order
     * @return  {this}
     */
    Sort(Comp?, Reversed := false) {
        static SizeOfField := 16
        static FieldOffset := CalculateFieldOffset()
        static CalculateFieldOffset() {
            Offset := (VerCompare(A_AhkVersion, "<2.1-") > 0 ? 3 : 5)
            return 8 + (Offset * A_PtrSize)
        }
        static GetValue(ptr, &out) {
            ; 0 - String, 1 - Integer, 2 - Float, 5 - Object
            switch NumGet(ptr + 8, "Int") {
                case 0: out := StrGet(NumGet(ptr, "Ptr") + 2 * A_PtrSize)
                case 1: out := NumGet(ptr, "Int64")
                case 2: out := NumGet(ptr, "Double")
                case 5: out := ObjFromPtrAddRef(NumGet(ptr, "Ptr"))
            }
        }

        Compare(Ptr1, Ptr2) {
            GetValue(Ptr1, &Value1)
            GetValue(Ptr2, &Value2)
            return Comp(Value1?, Value2?)
        }

        CompareReversed(Ptr1, Ptr2) {
            GetValue(Ptr1, &Value1)
            GetValue(Ptr2, &Value2)
            return Comp(Value2?, Value1?)
        }

        Comp := Comp ?? ((a, b) => (a > b) - (b > a))

        GetMethod(Comp)
        if (Reversed) {
            Callback := CompareReversed
        } else {
            Callback := Compare
        }

        mFields   := NumGet(ObjPtr(this) + FieldOffset, "Ptr")
        pCallback := CallbackCreate(Callback, "F CDecl", 2)
        DllCall("msvcrt.dll\qsort",
                "Ptr",  mFields,
                "UInt", this.Length,
                "UInt", SizeofField,
                "Ptr",  pCallback,
                "Cdecl")
        CallbackFree(pCallback)
        return this
    }

    /**
     * Lexicographically sorts the array in place using `StrCompare()`.
     * 
     * The array is sorted in reverse order, if `Reversed` is set to `true`.
     * @example
     * 
     * Array("banana", "apple").SortAlphabetically() ; ["apple", "banana"]
     * 
     * @param   {Primitive?}  CaseSense  case-sensitivity for string comparisons
     * @param   {Boolean?}    Reversed   sort in reverse order
     */
    SortAlphabetically(CaseSense := false, Reversed := false) {
        return this.Sort(ObjBindMethod(StrCompare,,,, CaseSense), Reversed)
    }

    /**
     * Returns the highest ordered element according to the given `Comparator`.
     * 
     * Unset elements are ignored.
     * 
     * @see `Comparator`
     * 
     * @example
     * Array(1, 4, 234, 67).Max()                ; 234
     * Array("banana", "zigzag").Max(StrCompare) ; "zigzag"
     * 
     * @param   {Func?}  Comp  function that orders two values
     * @return  {Any}
     */
    Max(Comp?) {
        if (!this.Length) {
            throw UnsetError("this array is empty")
        }
        Comp := Comp ?? ((a, b) => (a > b) - (b > a))
        GetMethod(Comp)
        Enumer := this.__Enum(1)
        while (Enumer(&Result) && !IsSet(Result)) {
        } ; nop
        for Value in Enumer {
            (IsSet(Value) && Comp(Value, Result) > 0 && Result := Value)
        }
        if (!IsSet(Result)) {
            throw UnsetError("every element in this array is unset")
        }
        return Result
    }

    /**
     * Returns the lowest ordered element according to the given `Comparator`.
     * 
     * Unset elements are ignored.
     * @see `Comparator`
     * 
     * @example
     * Array(1, 2, 3, 4).Min() ; 1
     * Array("apple", "banana", "foo").Min(StrCompare) ; "apple"
     * 
     * @param   {Func?}  Comp  function that orders two values
     * @return  {Any}
     */
    Min(Comp?) {
        if (!this.Length) {
            throw UnsetError("this array is empty")
        }
        Comp := Comp ?? ((a, b) => (a > b) - (b > a))
        GetMethod(Comp)
        Enumer := this.__Enum(1)
        while (Enumer(&Result) && !IsSet(Result)) {
        } ; nop
        for Value in Enumer {
            (IsSet(Value) && Comp(Value, Result) < 0 && Result := Value)
        }
        if (!IsSet(Result)) {
            throw UnsetError("every element in this array is unset")
        }
        return Result
    }

    /**
     * Returns the total sum of numbers and numerical string in the array.
     * 
     * Non-numeric and unset elements are ignored.
     * 
     * @example
     * Array("foo", 3, "4", unset).Sum() ; 7
     * 
     * @return  {Float}
     */
    Sum() {
        Result := Float(0)
        for Value in this {
            (IsSet(Value) && IsNumber(Value) && Result += Value)
        }
        return Result
    }

    /**
     * Returns the arithmetic mean of numbers and numeric strings in the array.
     * 
     * Non-numeric and unset elements are ignored.
     * 
     * @example
     * Array("foo", 3, "4", unset) ; 3.5 (total sum 7, 2 numerical values)
     * 
     * @return  {Float}
     */
    Average() {
        Sum := Float(0)
        Count := 0
        for Value in this {
            (IsSet(Value) && IsNumber(Value) && ++Count && Sum += Value)
        }
        return Sum / Count
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
     * @return  {Array}
     */
    Map(Mapper, Args*) {
        GetMethod(Mapper)
        Result := Array()
        Result.Capacity := this.Length
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }

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
     * @return  {this}
     */
    ReplaceAll(Mapper, Args*) {
        GetMethod(Mapper)
        Result := Array()
        Result.Capacity := this.Length

        for Value in this {
            Result.Push(Mapper(Value?, Args*))
        }

        Loop (this.Length) {
            this[A_Index] := Result[A_Index]
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
     * @return  {Array}
     */
    FlatMap(Mapper?, Args*) {
        Result := Array()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }
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
     * @return  {Array}
     */
    RetainIf(Condition, Args*) {
        GetMethod(Condition)
        Result := Array()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }

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
     * @return  {Array}
     */
    RemoveIf(Condition, Args*) {
        GetMethod(Condition)
        Result := Array()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }
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
     * @return  {Array}
     */
    Distinct(Hasher?, MapParam := Map()) {
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

        Result := Array()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }

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
     * Concatenates elements into a string, separated by the given `Delimiter`.
     * 
     * Objects are converted to strings by using `String(Obj)` (implicitly calls
     * the `.ToString()` method).
     * 
     * `InitialCap` can improve performance by setting an initial capacity of
     * the string.
     * 
     * @example
     * Array(1, 2, 3, 4).Join() ; "1234"
     * ReallyLargeArray.Join(", ", 1048576) ; 1MB
     * 
     * @param   {String?}   Delimiter   separator string
     * @param   {Integer?}  InitialCap  initial string capacity
     * @return  {String}
     */
    Join(Delimiter := "", InitialCap := 0) {
        Delimiter .= ""
        Result    := ""
        try VarSetStrCapacity(&Result, InitialCap)

        if (Delimiter == "") {
            for Value in this {
                (IsSet(Value) && Result .= String(Value))
            }
            return Result
        }
        for Value in this {
            (IsSet(Value) && Result .= String(Value))
            Result .= Delimiter
        }
        return SubStr(Result, 1, -StrLen(Delimiter))
    }

    /**
     * Joins all elements in this array into a single string, each element
     * separated by a newline character `\n`.
     * @see `Array.Join()`
     * 
     * @example
     * Array(1, 2, 3, 4).JoinLine() ; "1`n2`n3`n4"
     * 
     * @param   {Integer?}  InitialCap  initial string capacity
     * @return  {String}
     */
    JoinLine(InitialCap := 0) => this.Join("`n", InitialCap)
    
    /**
     * Combines all elements in the array using the given `Combiner` function
     * to produce a final result.
     * 
     * ```ahk
     * Combiner(ArrElement)
     * ```
     * 
     * Unset elements are ignored.
     * 
     * `Identity` can be used to set an initial value.
     * 
     * @example
     * Array(1, 2, 3, 4).Reduce((a, b) => (a + b)) ; 10
     * 
     * @param   {Func}  Combiner  function to combine two values
     * @param   {Any?}  Identity  initial value
     * @return  {Any}
     */
    Reduce(Combiner, Identity?) {
        if (!this.Length && IsSet(Identity)) {
            return Identity
        }
        GetMethod(Combiner)

        Enumer := this.__Enum(1)
        if (IsSet(Identity)) {
            Result := Identity
        }

        while (!IsSet(Result) && Enumer(&Result)) {
        } ; nop
        
        for Value in Enumer {
            Result := Combiner(Result, Value)
        }
        return Result
    }

    /**
     * Applies the given `Action` function on each element in the array.
     * 
     * ```ahk
     * Action(ArrElement, Args*)
     * ```
     * 
     * @example
     * Array(1, 2, 3, 4).ForEach(MsgBox, "Listing numbers in array", 0x40)
     * 
     * @param   {Func}  Action  the function to call on each element
     * @param   {Any*}  Args    zero or more additional arguments
     * @return  {this}
     */
    ForEach(Action, Args*) {
        GetMethod(Action)
        for Value in this {
            Action(Value?, Args*)
        }
        return this
    }

    /**
     * Returns `true` if any element in the array fulfills the given
     * `Condition`, in which case the first matching element is returned
     * as an object with `Value` property.
     * 
     * ```ahk
     * Condition(ArrayElement?, Args*)
     * ```
     * 
     * @example
     * Array(1, 2, 3, 4).AnyMatch(  (x) => (x > 2)  ) ; { Value: 3}
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @return  {Boolean/Object}
     */
    AnyMatch(Condition, Args*) {
        GetMethod(Condition)
        for Value in this {
            if (Condition(Value?, Args*)) {
                return { Value: Value? }
            }
        }
        return false
    }
    
    /**
     * Returns `true` if all elements in the array fulfill the given
     * `Condition`.
     * 
     * ```ahk
     * Condition(ArrayElement?, Args*)
     * ```
     * 
     * @example
     * Array(1, 2, 3, 4).AllMatch(  (x) => (x < 10)  ) ; true
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @return  {Boolean}
     */
    AllMatch(Condition, Args*) {
        GetMethod(Condition)
        for Value in this {
            if (!Condition(Value?, Args*)) {
                return false
            }
        }
        return true
    }

    /**
     * Returns `true` if none of the elements in the array fulfill the given
     * `Condition`.
     * 
     * ```ahk
     * Condition(ArrayElement?, Args*)
     * ```
     * 
     * @example
     * Array(1, 2, 3, 4).NoneMatch(  (x) => (x == 4)  ) ; false
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @return  {Boolean}
     */
    NoneMatch(Condition, Args*) {
        GetMethod(Condition)
        for Value in this {
            if (Condition(Value?, Args*)) {
                return false
            }
        }
        return true
    }

    /**
     * Returns the string representation of the array.
     * 
     * @example
     * Array(1, 2, 3, 4).ToString() ; "[1, 2, 3, 4]" 
     * 
     * @return  {String}
     */
    ToString() {
        static Mapper(Value?) {
            if (!IsSet(Value)) {
                return "unset"
            }
            if (Value is String) {
                return '"' . Value . '"'
            }
            return String(Value)
        }

        Result := "["
        for Value in this {
            if (A_Index != 1) {
                Result .= ", "
            }
            Result .= Mapper(Value?)
        }
        Result .= "]"
        return Result
    }
} ; class Array
} ; class AquaHotkey_Array extends AquaHotkey