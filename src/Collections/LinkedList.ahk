#Requires AutoHotkey v2.0

class LinkedList
{
    __New(Values*) {

    }

    Has(Index) {

    }

    Get(Index) {

    }

    __Item[Index] {
        get {
            
        }
        set {

        }
    }

    Contains(Value) {

    }

    Find(&OutValue, Condition, Args*) {

    }

    ; TODO ignore this?
    FindIndex(Condition, Args*) {

    }

    IsEmpty => (!this.Size)

    First() {
        if (this.IsEmpty) {
            throw UnsetError("LinkedList is empty")
        }
        ; TODO

    }

    Last() {
        if (this.IsEmpty) {
            throw UnsetError("LinkedList is empty")
        }

    }

    InsertAt() {

    }

    Poll() {

    }

    Push(Values*) {

    }

    Pop() {

    }

    ; TODO rename to pluck / skim ?
    Slurp() {

    }

    Drain() {

    }

    class Node {
        Prev {
            get => false
            set {
                if (!(this is LinkedList.Node)) {
                    throw TypeError("cannot be called from the prototype")
                }
                if (IsSet(value)) {
                    this.DefineProp("Prev", { Get: (_) => value })
                } else {
                    this.DeleteProp("Prev")
                }
            }
        }

        Next {
            get => false
            set {
                if (!(this is LinkedList.Node)) {
                    throw TypeError("cannot be called from the prototype")
                }
                if (IsSet(value)) {
                    this.DefineProp("Next", { Get: (_) => value })
                } else {
                    this.DeleteProp("Next")
                }
            }
        }

        Value {
            get {
                throw UnsetError("value not found")
            }
            set {
                if (IsSet(value)) {
                    this.DefineProp("Value", { Get: (_) => value })
                } else {
                    this.DeleteProp("Value")
                }
            }
        }
    }

    Reversed() {

    }
}
