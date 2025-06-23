
class AquaHotkey_Zip extends AquaHotkey {
    static __New() {
        if (this != AquaHotkey_Zip) {
            return
        }
        if (!IsSet(AquaHotkey_Array)) {
            MsgBox("
            ( ; TODO msg
            
            )", "AquaHotkey - Zip.ahk", 0x40)
            return
        }
        super.__New()
    }

    class Array {
        ZipWith(Arr) => ZippedArray.Of(this, Arr)

        Zip(TupleMapper) {
            
        }

        Dissect(Mappers*) {
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

class ZippedArray extends Array {
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

    __New(Elements*) {
        for Element in Elements {
            if (!(Element is Tuple)) {
                throw TypeError("Expected a Tuple",, Type(Element))
            }
        }
        super.__New(Elements*)
    }

    InsertAt(Index, Values*) {
        for Value in Values {
            if (!(Value is Tuple)) {
                throw TypeError("Expected a Tuple",, Type(Value))
            }
        }
        return super.InsertAt(Index, Values*)
    }

    Push(Values*) {
        for Value in Values {
            if (!(Value is Tuple)) {
                throw TypeError("Expected a Tuple",, Type(Value))
            }
        }
        return super.Push(Values*)
    }

    __Item[Index] {
        set {
            if (!(value is Tuple)) {
                throw TypeError("Expected a Tuple",, Type(value))
            }
            super[Index] := value
        }
    }

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