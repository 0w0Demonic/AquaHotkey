#Requires AutoHotkey v2

/**
 * 
 */
class OrderedSet
{
    First := false
    Last := false

    __New(Values*) {
        for Value in Values {
            this.AddLast(Value)
        }
    }

    AddFirst(Values*) {
        for Value in Values {
            if (super.Has(Value)) {
                return
            }
            Node := { Prev: false, Value: Value }

            if (!this.Count) {
                this.Last := Node
                Node.Next := false
            } else {
                Node.Next := this.First
                this.First.Prev := Node
            }
            this.Set(Value, Node)
            this.First := Node
        }
        return this
    }

    AddLast(Values*) {
        for Value in Values {
            if (super.Has(Value)) {
                return
            }
            Node := { Next: false, Value: Value }

            if (!this.Count) {
                this.First := Node
                Node.Prev := false
            } else {
                Node.Prev := this.Last
                this.Last.Next := Node
            }
            this.Set(Value, Node)
            this.Last := Node
        }
        return this
    }

    RemoveFirst() {
        if (!this.Count) {
            throw UnsetItemError("this map is empty")
        }
        Node := this.First
        this.Delete(Node.Value)

        if (!this.Count) {
            this.First := false
            this.Last := false
        } else {
            this.First := Node.Next
        }
        return Node.Value
    }

    RemoveLast() {
        if (!this.Count) {
            throw UnsetItemError("this map is empty")
        }
        Node := this.Last
        this.Delete(Node.Value)
        if (!this.Count) {
            this.Clear()
            this.First := false
            this.Last := false
        } else {
            this.Last := Node.Prev
        }
        return Node.Value
    }

    __Enum(ArgSize) {
        return Enumer

        Enumer(&Value) {
            static Node := this.First
            if (!Node) {
                return false
            }
            Value := Node.Value
            Node := Node.Next
            return true
        }
    }

    __Delete() {
        while (this.Count) {
            this.RemoveLast()
        }
    }

    Delete(Value) {
        if (!this.Has(Value)) {
            throw UnsetError("Item not found")
        }
        Node := this.Get(Value)

    }
}