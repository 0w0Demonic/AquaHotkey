#Requires AutoHotkey v2.0

class BitSet extends ISet {
    static FromBuffer(B) {

    }

    __New(Size := 0) {
        B := Buffer(Size)

    }

    Contains(Value) {
        if (!IsInteger(Value)) {
            throw TypeError("Expected an Integer",, Type(Value))
        }

    }

    Add(Values*) {
        B := this.B
        for Value in Values {
            Byte := Ceil(Value / 8)
            if (Byte > this.B.Size) {
                this.B.Size := Byte
            }
        }
    }

    Delete(Values*) {

    }

    Clear() {

    }

    Size {

    }

    __Enum(ArgSize) {

    }
}
