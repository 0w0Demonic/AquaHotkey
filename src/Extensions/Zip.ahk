/**
 * AquaHotkey - Zip.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/Zip.ahk
 * 
 * An array that holds tuple values. Conceptually, it works similar to a
 * two-dimensional array, except that in stream-like methods (e.g., `.Map()`),
 * each value in the tuple is passed as separate value.
 */
class ZipArray extends Array {
    /**
     * Creates a new ZipArray from the given arrays to zip.
     * The resulting array is truncated to the smallest element used.
     * 
     * @example
     * ZipArray.Of([1, 2], [3, 4], [5, 6, 7]) ; [(1, 3, 5), (2, 4, 6)]
     * 
     * @param   {Array*}  Arrays  the arrays to be zipped
     * @return  {ZipArray}
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
     * @return  {ZipArray}
     */
    __New(Elements*) {
        for Element in Elements {
            if (!(Element is Tuple)) {
                throw TypeError("Expected a Tuple",, Type(Element))
            }
        }
        super.__New(Elements*)
    }

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
     * @return  {ZipArray}
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
     * Unzips the array into arrays of separate components.
     * 
     * @example
     * ; [[1, 3], [2, 4]]
     * Z := ZipArray(Tuple(1, 2), Tuple(3, 4)).Unzip()
     * 
     * @return  {Array}
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
                    Result[A_Index]
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

    /**
     * Returns a ZipArray of all elements that fulfill the given
     * `Condition`.
     * 
     * @example
     * ; [(3, 4)]
     * ZipArray(Tuple(1, 2), Tuple(3, 4)).RetainIf((L, R) => (L + R > 5))
     * 
     * @param   {Func}  Condition  the given condition
     * @return  {ZipArray}
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
     * @return  {ZipArray}
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
     * Performs the given `Action` on each element in the ZipArray.
     * 
     * @example
     * ; displays 3, then 7
     * ZipArray(Tuple(1, 2), Tuple(3, 4)).ForEach((L, R) => MsgBox(L + R))
     * 
     * @param   {Func}  Action  the given action
     * @return  {this}
     */
    ForEach(Action) {
        GetMethod(Action)
        for Values in this {
            Action(Values*)
        }
        return this
    }

    /**
     * 
     */
    Distinct(*) {
        throw MethodError("Not available")
    }

    /**
     * 
     */
    FlatMap(*) {
        throw MethodError("Not available")
    }
}

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

class AquaHotkey_Zip extends AquaHotkey {
    class Array {
        /**
         * Combines the array with `Arr` by merging each value.
         * 
         * @param   {Array}  Arr  the array to zip with
         * @return  {ZippedArray}
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
         * @return  {ZippedArray}
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
         * @return  {ZippedArray}
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
    }
}