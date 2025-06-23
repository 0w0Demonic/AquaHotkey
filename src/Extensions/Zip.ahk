
class AquaHotkey_Zip extends AquaHotkey {
    class Array {
        ZipWith(Arr) => ZippedArray.Of(this, Arr)

        Zip(TupleMapper) {
            GetMethod(TupleMapper)

            Result := ZippedArray()
            Result.Capacity := this.Length
            for Value in this {
                Result.Push(TupleMapper(Value?))
            }
            return Result
        }

        Spread(Mappers*) {
            if (Mappers.Length < 2) {
                throw ValueError("At least two mappers required",,
                                 Mappers.Length)
            }

            for Mapper in Mappers {
                GetMethod(Mapper)
            }

            Result := ZippedArray()
            Result.Capacity := this.Length

            for Value in this {
                Element := Tuple()
                for Mapper in Mappers {
                    Element.Push(Mapper(Value?))
                }
                Result.Push(Element)
            }
            return Result
        }
    }
}

/**
 * Special array that consists of tuple values. Stream-like methods
 * such as `.Map()` and `.RemoveIf()` are rewritten to *spread* their
 * arguments into the function to be called.
 * 
 * ```ahk
 * 
 * ```
 * 
 * 
 */
class ZippedArray extends Array {
    /**
     * Creates a new zipped array from the given arrays to zip.
     * The resulting array is truncated to the smallest element used.
     * 
     * ```ahk
     * ZippedArray.Of([1, 2], [3, 4], [5, 6, 7]) ; [(1, 3, 5), (2, 4, 6)]
     * ```
     * 
     * @param   {Array*}  Arrs  the arrays to be zipped
     * @return  {ZippedArray}
     */
    static Of(Arrs*) {
        if (Arrs.Length < 2) {
            throw ValueError("At least two mappers required",, Arrs.Length)
        }
        Len := unset
        for Arr in Arrs {
            if (!(Arr is Array)) {
                throw TypeError("Expected an Array",, Type(Arr))
            }
            if (!IsSet(Len) || (Arr.Length < Len)) {
                Len := Arr.Length
            }
        }

        Result := ZippedArray()
        Loop Len {
            Element := Tuple()
            Index := A_Index
            for Arr in Arrs {
                Element.Push(Arr[Index])
            }
            Result.Push(Element)
        }
        return Result
    }

    /**
     * Array constructor with additional type constraints.
     * 
     * @param   {Tuple*}  Elements  the elements to be added
     * @return  {ZippedArray}
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
     * Inserts `Values*` into the back of the zipped array.
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
     * @param   {Any}      value  the new value to be set
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
     * Returns a new zipped array by transforming each element using
     * the given `Mapper`.
     * 
     * The `Mapper` function must return a tuple. To convert back to a regular
     * array, use `.Unzip()` instead.
     * 
     * TODO docs
     */
    Map(Mapper) {
        GetMethod(Mapper)
        Result := ZippedArray()
        Result.Capacity := this.Length
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }

        for Values in this {
            Element := Mapper(Values*)
            if (!(Element is Tuple)) {
                throw TypeError("Expected a Tuple",, Type(Element))
            }
            Result.Push(Element)
        }
        return Result
    }

    /**
     * Returns a regular array by transforming each element using the
     * given `Mapper`.
     */
    Unzip(Mapper?) {
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

    RetainIf(Condition) {
        GetMethod(Condition)
        Result := ZippedArray()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }

        for Values in this {
            (Condition(Values*) && Result.Push(Values))
        }
        return Result
    }

    RemoveIf(Condition) {
        GetMethod(Condition)
        Result := ZippedArray()
        if (HasProp(this, "Default")) {
            Result.Default := this.Default
        }
        for Values in this {
            (Condition(Values*) || Result.Push(Values))
        }
        return Result
    }

    ; TODO FlatMap()
    ; TODO Distinct()?

    ForEach(Action) {
        GetMethod(Action)
        for Values in this {
            Action(Values*)
        }
        return this
    }
}

class Tuple extends Array {
}

; TODO extend `Stream` in `static __New` or something
class ZippedStream extends Stream {

}