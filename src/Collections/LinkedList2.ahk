#Include "%A_LineFile%\..\..\Mixins\Sizeable.ahk"
#Include "%A_LineFile%\..\..\Mixins\Enumerable1.ahk"
#Include "%A_LineFile%\..\..\Mixins\Enumerable2.ahk"
#Include "%A_LineFile%\..\..\Mixins\Deque.ahk"
#Include "%A_LineFile%\..\..\Mixins\Indexable.ahk"

class LinkedList {
    static __New() {
        if (this == LinkedList) {
            ({}.DefineProp)(this.Prototype, "__New",
                    ({}.GetOwnPropDesc)(this.Prototype, "Push"))
            this.Backup(Sizeable, Deque, Enumerable1, Enumerable2, Indexable)
        }
    }

    RequiredNodeAt(Index) {
        Node := this.NodeAt(Index)
        if (!Node) {
            throw IndexError("invalid index",, Index)
        }
        return Node
    }

    NodeAt(Index) {
        if (!IsInteger(Index)) {
            throw TypeError("Expected an Integer",, Type(Index))
        }

        Size := this.Size
        if ((Index == 0) || (Abs(Index) > Size)) {
            return false
        }
        if (Index < 0) {
            Index += Size + 1
        }
        if (Index < (Size / 2)) {
            Node := this.Head
            loop (Index - 1) {
                Node := Node.Next
            }
        } else {
            Node := this.Tail
            loop (Size - Index) {
                Node := Node.Prev
            }
        }
        return Node
    }

    Head := false
    Tail := false
    Size := 0

    __New(Values*) => this.Push(Values*)

    __Delete() => this.Clear()

    Clear() {
        Node := this.Head
        while (Node) {
            Next := Node.Next
            Node.Next := false
            Node.Prev := false
            Node := Next
        }
        this.Head := false
        this.Tail := false
    }

    Has(Index) {
        Node := this.NodeAt(Index)
        return Node && Node.HasValue
    }

    Get(Index, Default?) {
        Node := this.RequiredNodeAt(Index)

        if (Node.HasValue) {
            return Node.Value
        }
        if (IsSet(Default)) {
            return Default
        }
        if (HasProp(this, "Default")) {
            return this.Default
        }
        throw UnsetItemError("No value present")
    }

    Set(Index, Value?) {
        this.RequiredNodeAt(Index).Value := (Value?)
    }
    
    Delete(Index) {
        this.RequiredNodeAt(Index).Value := unset
    }
    
    __Enum(ArgSize) {
        if (!IsInteger(ArgSize)) {
            throw TypeError("Expected an Integer",, Type(ArgSize))
        }
        Node := this.Head
        Idx  := 0
        return (ArgSize < 2) ? Enumer1 : Enumer2

        Enumer1(&Value) {
            if (!Node) {
                return false
            }
            Value := Node.HasValue ? Node.Value : unset
            Node  := Node.Next
            return true
        }

        Enumer2(&Index, &Value) {
            if (!Node) {
                return false
            }
            Index := ++Idx
            Value := Node.HasValue ? Node.Value : unset
            Node  := Node.Next
            return true
        }
    }

    __Item[Index] {
        get => this.Get(Index)
        set => this.Set(Index, Value?)
    }

    Shove(Values*) {
        if (!Values.Length) {
            return
        }
        Enumer := Values.__Enum(1)
        Enumer(&Value)
        Curr := LinkedList.Node(Value?)
        if (!this.Size) {
            this.Tail := Curr
        } else {
            this.Head.Prev := Curr
            Curr.Next := this.Head
        }

        for Value in Enumer {
            Node := LinkedList.Node(Value?)
            Node.Next := Curr
            Curr.Prev := Node
            Curr := Node
        }
        this.Head := Curr
        this.Size += Values.Length
    }

    Push(Values*) {
        if (!Values.Length) {
            return
        }
        Enumer := Values.__Enum(1)
        Enumer(&Value)
        Curr := LinkedList.Node(Value?)
        if (!this.Size) {
            this.Head := Curr
        } else {
            this.Tail.Next := Curr
            Curr.Prev := this.Tail
        }

        for Value in Enumer {
            Node := LinkedList.Node(Value?)
            Node.Prev := Curr
            Curr.Next := Node
            Curr := Node
        }
        this.Tail := Curr
        this.Size += Values.Length
    }

    Poll() {
        if (!this.Size) {
            throw UnsetError("linked list is empty")
        }
        Head := this.Head
        Next := Head.Next
        Head.Next := false
        this.Head := Next
        
        if (Next) {
            Next.Prev := false
        }
        --this.Size

        if (Head.HasValue) {
            return Head.Value
        }
    }

    Pop() {
        if (!this.Size) {
            throw UnsetError("linked list is empty")
        }
        Tail := this.Tail
        Prev := Tail.Prev
        Tail.Prev := false
        this.Tail := Prev

        if (Prev) {
            Prev.Next := false
        }
        --this.Size

        if (Tail.HasValue) {
            return Tail.Value
        }
    }

    InsertAt(Index, Values*) {
        if (!Values.Length) {
            return
        }

        if ((Index == 0) || (Index == this.Size + 1)) {
            this.Push(Values*)
            return
        }

        Tail := this.RequiredNodeAt(Index)
        Curr := Tail.Prev

        Enumer := Values.__Enum(1)
        if (!Curr) {
            Enumer(&Value)
            Node := LinkedList.Node(Value?)
            this.Head := Node
            Curr := Node
        }

        for Value in Enumer {
            Node := LinkedList.Node(Value?)
            Node.Prev := Curr
            Curr.Next := Node
            Curr := Curr.Next
        }

        Curr.Next := Tail
        Tail.Prev := Curr
        this.Size += Values.Length
    }

    RemoveAt(Index, Length := 1) {
        if (!IsInteger(Length)) {
            throw TypeError("Expected an Integer",, Type(Length))
        }
        if (Length < 0) {
            throw ValueError("< 0",, Length)
        }
        if (Length == 0) {
            return
        }
        if (Length == 1) {
            Node := this.RequiredNodeAt(Index)
            Prev := Node.Prev
            Next := Node.Next
            if (Prev) {
                Prev.Next := Next
            }
            if (Next) {
                Next.Prev := Prev
            }
            --this.Size
            if (Node.HasValue) {
                return Node.Value
            }
            return
        }
        if ((Index + Length) > (this.Size + 1)) {
            throw IndexError("Out of bounds")
        }

        Curr := this.RequiredNodeAt(Index)
        Prev := Curr.Prev

        loop (Length) {
            Next := Curr.Next
            Curr.Next := false
            Curr.Prev := false
            Curr := Next
        }

        if (Prev) {
            Prev.Next := Next
        }
        if (Next) {
            Next.Prev := Prev
        }

        this.Size -= Length
    }

    class Node {
        Next := false
        Prev := false

        __New(Value?) {
            if (IsSet(Value)) {
                this.DefineProp("Value", { Value: Value })
            }
        }

        HasValue => ObjHasOwnProp(this, "Value")
    }
}