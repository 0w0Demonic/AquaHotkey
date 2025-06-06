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
     * @example
     * 
     * Arr := Array().SetDefault(false)
     * 
     * @param   {Any}  Default  any value
     * @return  {this}
     */
    SetDefault(Default) {
        this.Default := Default
        return this
    }

    /**
     * Sets the `Length` property of this array.
     * @example
     * 
     * Arr := Array().SetLength(16)
     * 
     * @param   {Integer}  Length new length of this array
     * @return  {this}
     */
    SetLength(Length) {
        this.Length := Length
        return this
    }

    /**
     * Sets the `Capacity` property of this array.
     * @example
     * 
     * Arr := Array().SetCapacity(16)
     * 
     * @param   {Integer}  Capacity  new capacity of this array
     * @return  {this}
     */
    SetCapacity(Capacity) {
        this.Capacity := Capacity
        return this
    }
    
    /**
     * Returns an array slice from index `Begin` to `End` (inclusive),
     * selecting elements at an interval `Step`.
     * @example
     * 
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
     * Returns `true`, if this array is empty (its length is zero).
     * @example
     * 
     * Array().IsEmpty   ; true
     * Array(42).IsEmpty ; false
     *  
     * @return  {Boolean}
     */
    IsEmpty => (!this.Length)

    /**
     * Returns `true`, if this array has values.
     * @example
     * 
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
     * Swaps two elements in this array with indices `a` and `b`.
     * 
     * This method properly swaps unset values, but throws an error if the index
     * if out of bounds.
     * @example
     * 
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
     * Reverses this array in place.
     * @example
     * 
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
     * Sorts this array in place, according to a `Comparator` function which
     * orders two elements. Otherwise, elements in this array are sorted using
     * numerical comparison.
     * 
     * This array is sorted in reverse order, if `Reversed` is set to `true`.
     * @see `Comparator`
     * @example
     * 
     * Array(5, 1, 2, 7).Sort() ; [1, 2, 5, 7]
     * 
     * @param   {Comparator?}  Comp        function that orders two values
     * @param   {Boolean?}     Reversed    sort in reverse order
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
        if (!HasMethod(Comp)) {
            throw TypeError("Expected a Function object",, Type(Comp))
        }
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
     * Lexicographically sorts this array in place using `StrCompare()`.
     * 
     * This array is sorted in reverse order, if `Reversed` is set to `true`.
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
     * Returns the highest element in this array, according to the given
     * Comparator function `Comp`.
     * 
     * If no `Comp` is specified, the largest number in this array is
     * returned.
     * 
     * Unset elements are ignored. An `UnsetError` is thrown, if this array
     * has no values.
     * @see `Comparator`
     * @example
     * 
     * Array(1, 4, 234, 67).Max()                ; 234
     * Array("banana", "zigzag").Max(StrCompare) ; "zigzag"
     * Array().Max()                             ; Error!
     * 
     * @param   {Comparator?}  Comp  function that orders two values
     * @return  {Any}
     */
    Max(Comp?) {
        if (!this.Length) {
            throw UnsetError("this array is empty")
        }
        Comp := Comp ?? ((a, b) => (a > b) - (b > a))
        if (!HasMethod(Comp)) {
            throw TypeError("Expected a Function object",, Type(Comp))
        }
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
     * Returns the lowest element in this array, according to the given
     * Comparator function `Comp`.
     * 
     * If no `Comp` is specified, the smallest number in this array is
     * returned.
     * 
     * Unset elements are ignored. An `UnsetError` is thrown, if this array
     * has no values.
     * @see `Comparator`
     * @example
     * 
     * Array(1, 2, 3, 4).Min() ; 1
     * Array("apple", "banana", "foo").Min(StrCompare) ; "apple"
     * 
     * @param   {Comparator?}  Comp  function that orders two values
     * @return  {Any}
     */
    Min(Comp?) {
        if (!this.Length) {
            throw UnsetError("this array is empty")
        }
        Comp := Comp ?? ((a, b) => (a > b) - (b > a))
        if (!HasMethod(Comp)) {
            throw TypeError("Expected a Function object",, Type(Comp))
        }
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
     * Returns the total sum of numbers and numerical string in this array.
     * Non-numeric and unset elements are ignored.
     * @example
     * 
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
     * Returns the arithmetic mean of numbers and numeric strings in this array.
     * Non-numeric and unset elements are ignored.
     * @example
     * 
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
     * `Mapper` is called using items in the array as first argument, followed
     * by zero or more additional arguments `Args*`.
     * 
     * Unset elements are ignored, unless `Mapper` explicitly supports unset
     * parameters.
     * @example
     * 
     * Array(1, 2, 3, 4).Map(x => x * 2)         ; [2, 4, 6, 8]
     * Array("hello", "world").Map(SubStr, 1, 1) ; ["h", "w"]
     * 
     * @param   {Func}  Mapper  function that returns a new element
     * @param   {Any*}  Args    zero or more additional arguments
     * @return  {Array}
     */
    Map(Mapper, Args*) {
        if (!HasMethod(Mapper)) {
            throw TypeError("Expected a Function object",, Type(Mapper))
        }
        Result := Array()
        Result.Capacity := this.Length
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }

        if (HasMethod(Mapper,, 0)) {
            for Value in this {
                Result.Push(Mapper(Value?, Args*))
            }
            return Result
        }
        for Value in this {
            if (IsSet(Value)) {
                Result.Push(Mapper(Value, Args*))
            } else {
                ++Result.Length
            }
        }
        return Result
    }

    /**
     * Transforms all values in the array in place, by applying the given
     * `Mapper` function.
     * 
     * `Mapper` is called using items in this array as first argument, followed
     * by zero or more additional arguments `Args*`.
     * 
     * Unset elements are ignored, unless `Mapper` explicitly supports unset
     * parameters.
     * 
     * @example
     * 
     * Arr := Array(1, 2, 3)
     * Arr.ReplaceAll(x => (x * 2))
     * 
     * Arr.Join(", ").MsgBox() ; "1, 2, 3"
     * 
     * @param   {Func}  Mapper  function that returns a new element
     * @param   {Any*}  Args    zero or more additional arguments
     * @return  {this}
     */
    ReplaceAll(Mapper, Args*) {
        if (!HasMethod(Mapper)) {
            throw TypeError("Expected a Function object",, Type(Mapper))
        }
        Result := Array()
        Result.Capacity := this.Length

        if (HasMethod(Mapper,, 0)) {
            for Value in this {
                Result.Push(Mapper(Value?, Args*))
            }
        } else {
            for Value in this {
                if (IsSet(Value)) {
                    Result.Push(Mapper(Value, Args*))
                } else {
                    ++Result.Length
                }
            }
        }

        Loop (this.Length) {
            this[A_Index] := Result[A_Index]
        }
        return this
    }

    /**
     * Returns a new array containing all elements in this array transformed by
     * the given `Mapper` function, resulting arrays flattened into separate
     * elements.
     * 
     * `Mapper` is called using items in this array as first argument, followed
     * by zero or more additional arguments `Args*`.
     * 
     * Unset elements are ignored, unless `Mapper` has optional parameters.
     * 
     * If `Mapper` is unset, no transformation is done and existing arrays are
     * flattened.
     * @example
     * 
     * Array("hel", "lo").FlatMap(StrSplit)       ; ["h", "e", "l", "l", "o"]
     * Array([1, 2], [3, 4]).FlatMap()            ; [1, 2, 3, 4]
     * Array("a,b", "c,d").FlatMap(StrSplit, ",") ; ["a", "b", "c", "d"]
     * 
     * @param   {Func?}  Mapper  function that returns zero or more elements
     * @param   {Any*}   Args    zero or more additional arguments
     * @return  {Array}
     */
    FlatMap(Mapper?, Args*) {
        Result := Array()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }
        if (!IsSet(Mapper)) {
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
        if (HasMethod(Mapper,, 0)) {
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
                Element := Mapper(Value, Args*)
                if (Element is Array) {
                    Result.Push(Element*)
                } else {
                    Result.Push(Element )
                }
            } else {
                ++Result.Length
            }
        }
        return Result
    }
    
    /**
     * Returns a new array containing all elements in this array that match the
     * given predicate function `Condition`.
     * 
     * `Condition` is called using items in this array as first argument,
     * followed by zero or more additional arguments `Args*`.
     * 
     * Unset elements are removed, unless `Condition` has optional parameters.
     * @example
     * 
     * Array(1, 2, 3, 4).RetainIf(x => x > 2)                    ; [3, 4]
     * Array(unset, 2, 3).RetainIf(x => x > 2)                   ; [3]
     * Array(unset, 2, 3).RetainIf((x?) => (!IsSet(x) || x > 2)) ; [unset, 3]
     * Array("foo", "bar").RetainIf(InStr, "f")                  ; ["foo"]
     * 
     * @param   {Predicate}  Condition  function that evaluates a condition
     * @param   {Any*}       Args       zero or more additional arguments
     * @return  {Array}
     */
    RetainIf(Condition, Args*) {
        if (!HasMethod(Condition)) {
            throw TypeError("Expected a Function object",, Type(Condition))
        }
        Result := Array()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }
        if (HasMethod(Condition,, 0)) {
            for Value in this {
                (Condition(Value?, Args*) && Result.Push(Value?))
            }
            return Result
        }
        for Value in this {
            (IsSet(Value) && Condition(Value, Args*) && Result.Push(Value))
        }
        return Result
    }

    /**
     * Returns a new array containing all elements in this array that do not
     * match the given predicate function `Condition`.
     * 
     * `Condition` is called using elements in this array as first
     * argument, followed by zero or more additional arguments `Args*`.
     * 
     * Unset elements are removed, unless `Condition` has optional parameters.
     * @example
     * 
     * Array(1, 2, 3, 4).RemoveIf(x => x > 2)                   ; [1, 2]
     * Array(unset, 2, 3).RemoveIf(x => x > 2)                  ; [2]
     * Array(unset, 2, 3).RemoveIf((x?) => (IsSet(x) && x > 2)) ; [unset, 2]
     * Array("foo", "bar").RemoveIf(InStr, "f")                 ; ["bar"]
     * 
     * @param   {Predicate}  Condition  function that evaluates a condition
     * @param   {Any*}       Args       zero or more additional arguments
     * @return  {Array}
     */
    RemoveIf(Predicate, Args*) {
        if (!HasMethod(Predicate)) {
            throw TypeError("Expected a Function object",, Type(Predicate))
        }
        Result := Array()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }
        if (HasMethod(Predicate,, 0)) {
            for Value in this {
                (Predicate(Value?, Args*) || Result.Push(Value?))
            }
            return Result
        }
        for Value in this {
            (IsSet(Value) && (Predicate(Value, Args*) || Result.Push(Value)))
        }
        return Result
    }

    /**
     * Separates all elements in this array into a `Map` object with two entries
     * `true` and `false`, based on whether they satisfy the given predicate
     * function `Condition`
     * 
     * `Condition` is called using items in this array as first argument,
     * followed by zero or more additional arguments `Args*`.
     * 
     * Unset elements are removed, unless `Predicate` has optional parameters.
     * @example
     * 
     * IsEven(x) {
     *     return !(x & 1)
     * }
     * 
     * ; Map {
     * ;     true  => [2, 4],
     * ;     false => [1, 3]
     * ; }
     * Array(1, 2, 3, 4).Partition(IsEven)
     * 
     * IsUnsetOrEven(x?) {
     *     return !IsSet(x) || !(x & 1)
     * }
     * 
     * ; Map {
     * ;     true  => [2, unset],
     * ;     false => [1, 3]
     * ; }
     * Array(1, 2, 3, unset).Partition(IsUnsetOrEven)
     * 
     * ; Map {
     * ;     true  => ["foo"],
     * ;     false => ["bar"]
     * ; }
     * Array("foo", "bar").Partition(InStr, "f")
     * 
     * @param   {Predicate}  Condition  function that evaluates a condition
     * @param   {Any*}       Args       zero or more additional parameters
     * @return  {Map}
     */
    Partition(Predicate, Args*) {
        if (!HasMethod(Predicate)) {
            throw TypeError("Expected a Function object",, Predicate)
        }
        ValuesTrue  := Array()
        ValuesFalse := Array()
        if (HasMethod(Predicate,, 0)) {
            for Value in this {
                if (Predicate(Value?, Args*)) {
                    ValuesTrue.Push(Value?)
                } else {
                    ValuesFalse.Push(Value?)
                }
            }
            return Map(true, ValuesTrue, false, ValuesFalse)
        }
        for Value in this {
            if (IsSet(Value)) {
                if (Predicate(Value, Args*)) {
                    ValuesTrue.Push(Value)
                } else {
                    ValuesFalse.Push(Value)
                }
            }
        }
        return Map(true, ValuesTrue, false, ValuesFalse)
    }

    /**
     * Returns a map of all elements in this array grouped by a given function
     * `Classifier`, which returns the key used for the map.
     * 
     * `Classifier` is called using items in this array as first argument,
     * followed by zero or more additional arguments `Args*`.
     * 
     * Unset elements are ignored, unless `Classifier` has optional parameters.
     * 
     * Parameter `CaseSense` determines case-sensitivity of the underlying
     * `Map`.
     * @example
     * 
     * LastDigit(x?) {
     *     if (!IsSet(x) || !IsNumber(x)) {
     *         return "undefined"
     *     }
     *     return Mod(x, 10)
     * }
     * 
     * ; Map {
     * ;     2 => [2],
     * ;     3 => [3, 13],
     * ;     4 => [4],
     * ;     "undefined" => ["foo", unset]
     * ; }
     * Array(2, 3, 34, 13, "foo", unset).GroupBy(LastDigit)
     * 
     * ; Map {
     * ;     "f" => ["foo"],
     * ;     "b" => ["bar"]
     * ; }
     * Array("foo", "bar").GroupBy(SubStr, false, 1, 1)
     * 
     * @param   {Func}        Classifier  function that creates a map key
     * @param   {Primitive?}  CaseSense   case-sensitivity of the map
     * @param   {Any*}        Args        zero or more additional arguments
     * @return  {Map}
     */
    GroupBy(Classifier, CaseSense := true, Args*) {
        if (!HasMethod(Classifier)) {
            throw TypeError("Expected a Function object",, Type(Classifier))
        }
        Result := Map()
        Result.CaseSense := CaseSense
        if (HasMethod(Classifier,, 0)) {
            for Value in this {
                Key := Classifier(Value?, Args*)
                (Result.Has(Key) || Result[Key] := Array())
                Result[Key].Push(Value?)
            }
            return Result
        }
        for Value in this {
            if (IsSet(Value)) {
                Key := Classifier(Value, Args*)
                (Result.Has(Key) || Result[Key] := Array())
                Result[Key].Push(Value)
            }
        }
        return Result
    }

    /**
     * Returns a new array containing all unique elements of this array. This
     * method ensures that only unique elements remain in the resulting array.
     * 
     * Unset elements are removed.
     * 
     * The method determines behavior based on the type of the first parameter:
     * 
     * ---
     * 
     * **1. `CaseSenseOrHasher` (`Boolean`|`String`|`Func`, optional)**:
     * 
     * If a `Boolean` (`true` or `false`) or `String` (`"On"` or `"Off"`) is
     * provided, it determines the case-sensitivity of the internal `Map` used
     * for equality checks.
     * 
     * If a function object is provided, it is treated as a custom `Hasher` for
     * generating keys. This is useful for comparing objects based on their
     * values instead of their identity.
     * 
     * A custom `Hasher` is required for supporting streams with a parameter
     * length greater than 1.
     * 
     * ---
     * 
     * **2. `CaseSense` (`Boolean`|`String`, optional)**:
     * 
     * Specifies case-sensitivity of the internal `Map`.
     * This method uses an underlying map object to keep track of previous
     * values, its case-sensitivity is determined by `CaseSense`.
     * 
     * ---
     * @example
     * 
     * ; [1, 2, 3]
     * Array(1, 2, 3, 1).Distinct()
     * 
     * ; ["foo"]
     * Array("foo", "Foo", "FOO").Distinct(false)
     * 
     * ; [{ Value: 1 }, { Value: 2 }]
     * Array({ Value: 1 }, { Value: 2 }, { Value: 1 }).Distinct(true, "Value")
     * 
     * @param   {Primitive?/Func?}  CaseSenseOrHasher  case-sensitivity or
     *                                                 object hasher
     * @param   {Primitive?}        CaseSense          case-sensitivity
     * @return  {Array}
     */
    Distinct(CaseSenseOrHasher := true, CaseSense?) {
        if (HasMethod(CaseSenseOrHasher)) {
            Hasher    := CaseSenseOrHasher
            CaseSense := CaseSense ?? true
        } else {
            Hasher    := unset
            CaseSense := CaseSenseOrHasher
        }

        Values := Map()
        Values.CaseSense := CaseSense
        Result := Array()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }

        if (IsSet(Hasher)) {
            for Value in this {
                if (IsSet(Value) && !Values.Has(Hash := Hasher(Value?))) {
                    Values[Hash] := true
                    Result.Push(Value)
                }
            }
            return Result
        }
        for Value in this {
            if (IsSet(Value) && !Values.Has(Value)) {
                Values[Value] := true
                Result.Push(Value)
            }
        }
        return Result
    }
    
    /**
     * Concatenates all elements in this array into a single string, each
     * element separated by `Delimiter`. Objects are converted to a string using
     * their `ToString()` method whereas unset elements are ignored.
     * 
     * `InitialCap` specifies the initial capacity of the resulting string
     * (default `0`). This can improve performance when working with large
     * strings by pre-allocating the necessary memory.
     * @example
     * 
     * Array(1, 2, 3, 4).Join() ; "1234"
     * Array(1, unset, 2).Join(", ") ; "1, 2"
     * ReallyLargeArray.Join(", ", 1048576) ; 1MB
     * 
     * @param   {String?}   Delimiter   separator string
     * @param   {Integer?}  InitialCap  initial string capacity
     * @return  {String}
     */
    Join(Delimiter := "", InitialCap := 0) {
        if (IsObject(Delimiter)) {
            throw TypeError("Expected a String",, Type(Delimiter))
        }
        Result := ""
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
     * @example
     * 
     * Array(1, 2, 3, 4).JoinLine() ; "1`n2`n3`n4"
     * 
     * @param   {Integer?}  InitialCap  initial string capacity
     * @return  {String}
     */
    JoinLine(InitialCap := 0) => this.Join("`n", InitialCap)
    
    /**
     * Performs a reduction on the elements of this array, using the given
     * `Combiner` function. This method iteratively combines elements to
     * produce a single result, optionally starting with an `Identity` value.
     * 
     * Unset elements are ignored.
     * 
     * If specified, `Identity` is used as the starting value of the reduction.
     * Otherwise, the first element is taken as initial value and reduction
     * starts on the second element. An error is thrown, if the array has
     * no elements.
     * @example
     * 
     * Sum(a, b) {
     *     return a + b
     * }
     * Array(1, 2, unset, 3, unset, 4).Reduce(Sum) ; 10
     * Array(unset, unset, unset).Reduce(Sum)      ; Error!
     * Array(unset, unset, unset).Reduce(Sum, 2)   ; 2
     * 
     * @param   {Func}  Combiner  function that combines two values
     * @param   {Any?}  Identity  starting value of the reduction operation
     * @return  {Any}
     */
    Reduce(Combiner, Identity?) {
        if (!this.Length) {
            if (IsSet(Identity)) {
                return Identity
            }
            throw UnsetError("this array is empty")
        }
        if (!HasMethod(Combiner)) {
            throw TypeError("Expected a Function object",, Type(Combiner))
        }
        if (IsSet(Identity)) {
            Result := Identity
        }

        Enumer := this.__Enum(1)
        while (!IsSet(Result) && Enumer(&Result)) {
        } ; nop
        
        for Value in Enumer {
            if (IsSet(Value)) {
                Result := Combiner(Result, Value)
            }
        }
        if (!IsSet(Result)) {
            throw UnsetError("every element in this array is unset")
        }
        return Result
    }

    /**
     * Applies the given `Action` function on each element of this array.
     * 
     * `Action` is called using items in this array as first argument, followed
     * by zero or more additional arguments `Args*`.
     * 
     * Unset elements are ignored, unless `Action` has optional parameters.
     * @example
     * 
     * Array(1, 2, 3, 4).ForEach(MsgBox, "Listing numbers in array", 0x40)
     * 
     * @param   {Func}  Action  the function to call on each element
     * @param   {Any*}  Args    zero or more additional arguments
     * @return  {this}
     */
    ForEach(Action, Args*) {
        if (!HasMethod(Action)) {
            throw TypeError("Expected a Function object",, Type(Action))
        }
        if (HasMethod(Action,, 0)) {
            for Value in this {
                Action(Value?, Args*)
            }
            return this
        }
        for Value in this {
            (IsSet(Value) && Action(Value, Args*))
        }
        return this
    }
    
    /**
     * Returns a string representation of this array.
     * @example
     *
     * Array(1, 2, 3, 4).ToString() ; "[1, 2, 3, 4]" 
     * 
     * @return  {String}
     */
    ToString() {
        static Mapper(Value?) {
            if (!IsSet(Value)) {
                return Value := "unset"
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