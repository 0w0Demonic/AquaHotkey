#Requires AutoHotkey v2

class OrderedMap extends Map {
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
            Node := { Previous: false, Value: Value }

            if (!this.Count) {
                this.Last := Node
                Node.Next := false
            } else {
                Node.Next := this.First
                this.First.Previous := Node
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
                Node.Previous := false
            } else {
                Node.Previous := this.Last
                this.Last.Next := Node
            }
            this.Set(Value, true)
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
            this.Last := Node.Previous
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

    Delete(Value) {
        if (!this.Has(Value)) {
            throw UnsetError("Item not found")
        }
        Node := this.Get(Value)

    }
}

List := OrderedMap()

Callback(*) => MsgBox("first")
List.AddFirst(Callback)
List.AddLast(Callback)
List()