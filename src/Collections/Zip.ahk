#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
;@region Zip
/**
 * AquaHotkey - Zip.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/Zip.ahk
 * 
 * ---
 * 
 * An array that holds tuple values. Conceptually, it works similar to a
 * two-dimensional array, except that in stream-like methods (e.g., `.Map()`),
 * each value in the tuple is passed as separate value.
 */
class ZipArray extends Array {
    ;@region Construction
    /**
     * Creates a new ZipArray from the given arrays to zip.
     * The resulting array is truncated to the smallest element used.
     * 
     * @example
     * ZipArray.Of([1, 2], [3, 4], [5, 6, 7]) ; [(1, 3, 5), (2, 4, 6)]
     * 
     * @param   {Array*}  Arrays  the arrays to be zipped
     * @returns {ZipArray}
     */
    static Of(Arrays*) {
        if (Arrays.Length < 2) {
            throw ValueError("At least two mappers required",, Arrays.Length)
        }
        Len := unset
        for Arr in Arrays {
            if (!(Arr is Array)) {
                throw TypeError("Expected an Array",, Type(Arr))
            }
            if (!IsSet(Len) || (Arr.Length < Len)) {
                Len := Arr.Length
            }
        }

        Result := ZipArray()
        Loop Len {
            Element := Array()
            Index := A_Index
            for Arr in Arrays {
                Element.Push(Arr[Index])
            }
            ObjSetBase(Element, Tuple.Prototype)
            Result.Push(Element)
        }
        return Result
    }

    /**
     * Create a new ZipArray consisting of the given Tuple values.
     * 
     * @param   {Tuple*}  Elements  the elements to be added
     * @returns {ZipArray}
     */
    __New(Elements*) {
        for Element in Elements {
            if (!(Element is Tuple)) {
                throw TypeError("Expected a Tuple",, Type(Element))
            }
        }
        super.__New(Elements*)
    }
    ;@endregion

    /**
     * Inserts `Values*` at the given `Index`.
     * 
     * @param   {Integer}  Index   index to add elements into
     * @param   {Tuple*}   Values  the elements to add
     */
    InsertAt(Index, Values*) {
        for Value in Values {
            if (!(Value is Tuple)) {
                throw TypeError("Expected a Tuple",, Type(Value))
            }
        }
        return super.InsertAt(Index, Values*)
    }

    ;@region Accessing Values
    /**
     * Inserts `Values*` into the back of the ZipArray.
     * 
     * @param   {Tuple*}  Values  the elements to add
     */
    Push(Values*) {
        for Value in Values {
            if (!(Value is Tuple)) {
                throw TypeError("Expected a Tuple",, Type(Value))
            }
        }
        return super.Push(Values*)
    }

    /**
     * Sets the value at the given `Index`.
     * 
     * @param   {Integer}  Index  array index of the element
     * @param   {Tuple}    value  the new tuple value to be set
     */
    __Item[Index] {
        set {
            if (!(value is Tuple)) {
                throw TypeError("Expected a Tuple",, Type(value))
            }
            super[Index] := value
        }
    }
    ;@endregion

    ;@region Conversion
    /**
     * Unzips the array into arrays of separate components.
     * 
     * @example
     * ; [[1, 3], [2, 4]]
     * Z := ZipArray(Tuple(1, 2), Tuple(3, 4)).Unzip()
     * 
     * @returns {Array}
     */
    Unzip() {
        Count := 0
        Result := Array()
        for Element in this {
            while (Result.Length < Element.Length) {
                Arr := Array()
                Arr.Capacity := this.Length
                Arr.Length := Count
                Result.Push(Arr)
            }
            for Value in Element {
                if (IsSet(Value)) {
                    Result[A_Index].Push(Value)
                } else {
                    Result[A_Index].Length++
                }
            }
            ++Count
        }
        return Result
    }

    /**
     * Returns a regular array by narrowing all elements into a single value
     * using the given `Mapper` function.
     * 
     * @example
     * ; [3, 7]
     * ZipArray(Tuple(1, 2), Tuple(3, 4)).Narrow((a, b) => (a + b))
     * 
     * ; [[1, 2], [3, 4]]
     * ZipArray(Tuple(1, 2), Tuple(3, 4)).Narrow((a, b) => (a + b))
     */
    Narrow(Mapper?) {
        if (!IsSet(Mapper)) {
            return Array(this*)
        }
        GetMethod(Mapper)
        Result := Array()
        Result.Capacity := this.Length
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }

        for Values in this {
            Result.Push(Mapper(Values*))
        }
        return Result
    }
    ;@endregion

    ;@region Stream Ops
    /**
     * Returns a new ZipArray by transforming each element using the given
     * `TupleMapper` to create a new Tuple.
     * 
     * To convert back to a regular array, use `.Unzip()` or `.Narrow()
     * `instead.
     * 
     * @example
     * ; [(4, 1), (5, 2), (6, 3)]
     * ZipArray(Tuple(1, 2, 3), Tuple(4, 5, 6)).Map((L, R) => Tuple(R, L))
     * 
     * @param   {Func}  TupleMapper  the mapper to apply
     * @returns {ZipArray}
     */
    Map(TupleMapper) {
        GetMethod(TupleMapper)
        Result := ZipArray()
        Result.Capacity := this.Length
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }

        for Values in this {
            Element := TupleMapper(Values*)
            if (!(Element is Tuple)) {
                throw TypeError("Expected a Tuple",, Type(Element))
            }
            Result.Push(Element)
        }
        return Result
    }

    /**
     * Returns a ZipArray of all elements that fulfill the given
     * `Condition`.
     * 
     * @example
     * ; [(3, 4)]
     * ZipArray(Tuple(1, 2), Tuple(3, 4)).RetainIf((L, R) => (L + R > 5))
     * 
     * @param   {Func}  Condition  the given condition
     * @returns {ZipArray}
     */
    RetainIf(Condition) {
        GetMethod(Condition)
        Result := ZipArray()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }
        for Values in this {
            (Condition(Values*) && Result.Push(Values))
        }
        return Result
    }

    /**
     * Returns a ZipArray of all elements that don't fulfill the given
     * `Condition`.
     * 
     * @example
     * ; [(1, 2)]
     * ZipArray(Tuple(1, 2), Tuple(3, 4)).RemoveIf((L, R) => (L + R > 5))
     * 
     * @param   {Func}  Condition  the given condition
     * @returns {ZipArray}
     */
    RemoveIf(Condition) {
        GetMethod(Condition)
        Result := ZipArray()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }
        for Values in this {
            (Condition(Values*) || Result.Push(Values))
        }
        return Result
    }

    /**
     * Returns a new ZipArray of unique elements by keeping track of them in
     * a Map.
     * 
     * A custom `Hasher` can be used to specify the map key to be used
     * (defaults to the string representation of tuples).
     * 
     * ```ahk
     * Hasher(Values*)
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
     * ; [(1, 2), (2, 1)]
     * ZipArray(Tuple(1, 2), Tuple(1, 2), Tuple(2, 1)).Distinct()
     * 
     * @param   {Func?}                  Hasher    function to create map keys
     * @param   {Map?/Func?/Primitive?}  MapParam  internal map options
     * @returns {ZipArray}
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

        Result := ZipArray()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }

        if (IsSet(Hasher)) {
            for Value in this {
                Key := Hasher(Value*)
                if (!Cache.Has(Key)) {
                    Result.Push(Value)
                    Cache[Key] := true
                }
            }
            return Result
        }
        for Value in this {
            Key := String(Value)
            if (!Cache.Has(Key)) {
                Result.Push(Value)
                Cache[Key] := true
            }
        }
        return Result
    }

    /**
     * Returns a regular array containing the elements of the ZipArray mapped
     * using the given `Mapper`, resulting arrays flattened into separate
     * elements.
     * 
     * ```ahk
     * Mapper(Values*)
     * ```
     * 
     * The method defaults to flattening existing tuple elements, if no `Mapper`
     * is given.
     * 
     * @example
     * ; [1, 2, 3, 4]
     * ZipArray(Tuple(1, 2), Tuple(3, 4)).FlatMap()
     * 
     * ; [3, 7]
     * ZipArray(Tuple(1, 2), Tuple(3, 4)).FlatMap(Combiner.Sum)
     * 
     * ; ["H", "e", "l", "l", "o"]
     * ZipArray(Tuple("Hello")).FlatMap(StrSplit)
     * 
     * @param   {Func?}  Mapper  function to convert and flatten elements
     * @returns {Array}
     */
    FlatMap(Mapper?) {
        Result := Array()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }
        if (IsSet(Mapper)) {
            GetMethod(Mapper)
            for Value in this {
                Element := Mapper(Value*)
                if (Element is Array) {
                    Result.Push(Element*)
                } else {
                    Result.Push(Element )
                }
            }
            return Result
        }
        for Element in this {
            Result.Push(Element*)
        }
        return Result
    }

    /**
     * Performs the given `Action` on each element in the ZipArray.
     * 
     * @example
     * ; displays 3, then 7
     * ZipArray(Tuple(1, 2), Tuple(3, 4)).ForEach((L, R) => MsgBox(L + R))
     * 
     * @param   {Func}  Action  the given action
     * @returns {this}
     */
    ForEach(Action) {
        GetMethod(Action)
        for Values in this {
            Action(Values*)
        }
        return this
    }
    ;@endregion
}
;@endregion

;@region Tuple
/**
 * An immutable array.
 */
class Tuple extends Array {
    static __New() {
        if (this != Tuple) {
            return
        }
        Proto := this.Prototype
        for MethodName in Array("Delete", "InsertAt", "Pop", "Push",
                                "RemoveAt", "ReplaceAll") {
            Proto.DefineProp(MethodName, { Call: Unsupported })
        }
        for PropertyName in Array("Length", "Capacity", "Default", "__Item") {
            Proto.DefineProp(PropertyName, { Set: Unsupported })
        }

        Unsupported(*) {
            throw MethodError("Tuples are immutable")
        }
    }
}
;@endregion

;@region Extensions
class AquaHotkey_Zip {
static __New() {
    if (ObjGetBase(this) != Object) {
        return
    }
    if (!IsSet(AquaHotkey) || !(AquaHotkey is Class)) {
        return
    }
    (AquaHotkey.__New)(this)
}

;@region Array
class Array {
    /**
     * Combines the array with `Arr` by merging each value.
     * 
     * @param   {Array}  Arr  the array to zip with
     * @returns {ZippedArray}
     */
    ZipWith(Arr) => ZipArray.Of(this, Arr)

    /**
     * Returns a zipped array by converting each element to a tuple
     * using the given `TupleMapper`.
     * 
     * @example
     * ; [("apple", 5), ("banana", 6), ("kiwi", 4)]
     * Array("apple", "banana", "kiwi").Zip(Str => Tuple(Str, StrLen(Str)))
     * 
     * @param   {Func}  TupleMapper  the function to create tuples with
     * @returns {ZippedArray}
     */
    Zip(TupleMapper) {
        GetMethod(TupleMapper)

        Result := ZipArray()
        Result.Capacity := this.Length
        for Value in this {
            Result.Push(TupleMapper(Value?))
        }
        return Result
    }

    /**
     * Returns a zipped array by "spreading" each element into multiple
     * values using `Mappers`.
     * 
     * @example
     * ; [("apple", 5), ("banana", 6), ("kiwi", 4)]
     * Array("apple", "banana", "kiwi").Spread(Func.Self, StrLen)
     * 
     * @param   {Func*}  Mappers  the mappers to apply
     * @returns {ZippedArray}
     */
    Spread(Mappers*) {
        if (!Mappers.Length) {
            throw TypeError("No mappers specified")
        }
        for Mapper in Mappers {
            GetMethod(Mapper)
        }
        Result := ZipArray()
        Result.Capacity := this.Length

        for Value in this {
            Element := Array()
            for Mapper in Mappers {
                Element.Push(Mapper(Value?))
            }
            ObjSetBase(Element, Tuple.Prototype)
            Result.Push(Element)
        }
        return Result
    }
} ; class Array
;@endregion
} ; class AquaHotkey_Zip
;@endregion