#Requires AutoHotkey v2.0

#Include <AquaHotkey\src\Core\Utils>
#Include <AquaHotkey\src\Collections\Generic\Array>

class TreeNode {
    __New(Value) {
        DefineProp(this, "Value", { Get: (_) => Value })
        Children := Array()
        DefineProp(this, "Children", { Get: (_) => Children })
    }

    Add(Value) {
        Node := TreeNode(Value)
        this.Children.Push(Node)
        return Node
    }
}

#Include <AquaHotkey\src\Interfaces\Enumerable1>

class Tree {
    static __New() => (AquaHotkey) && this.Include(Enumerable1)

    __New(RootValue) {
        Root := TreeNode(RootValue)
        DefineProp(this, "Root", { Get: (_) => Root })
    }

    Add(Value) => (this.Root).Add(Value)

    __Enum(ArgSize) {
        Stack := [[this.Root].__Enum(1)]
        return TreeWalk

        TreeWalk(&OutValue) {
            while (Stack.Length) {
                if (!Stack[-1](&Node)) {
                    Stack.Pop()
                    continue
                }
                OutValue := Node.Value
                Stack.Push(Node.Children.__Enum(1))
                return true
            }
            return false
        }
    }
}

T := Tree(1)
L := T.Add(2)
R := T.Add(3)
LL := L.Add(4)
LR := L.Add(5)
RL := R.Add(6)
RR := R.Add(7)

MsgBox(T.Sum())
