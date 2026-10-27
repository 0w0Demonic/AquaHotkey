#Requires AutoHotkey v2.0

#Include <AquaHotkey\src\Core\Utils>
#Include <AquaHotkey\src\Collections\Generic\Array>

/**
 * A node inside a tree data structure.
 */
class TreeNode {
    /**
     * Determines whether an object is a tree node.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     */
    static IsInstance(Val?) {
        if (!IsSet(Val)) {
            return false
        }
        if (Val is this) {
            return true
        }
        return (this == TreeNode)
            && IsObject(Val)
            && HasProp(Val, "Value")
            && HasMethod(Val, "AddChild")
    }

    /**
     * Constructs a new tree node with the given value.
     * 
     * @constructor
     * @param   {Any}  Value  any value
     */
    __New(Value) {
        DefineProp(this, "Value", { Get: (_) => Value })
        Children := Array()
        DefineProp(this, "Children", { Get: (_) => Children })
    }

    /**
     * Adds a node with the given value as a child to the tree node.
     * 
     * @param   {Any}  Value  any value
     * @returns {TreeNode}
     */
    AddChild(Value) {
        Node := { base: ObjGetBase(this) }
        Node.__Init()
        Node.__New(Value)
        this.Children.Push(Node)
        return Node
    }

    /**
     * Returns a string representation of this tree.
     * 
     * @returns {String}
     */
    ToString() => "<" . String(this.Value) . ", " . String(this.Children) . ">"
}

#Include <AquaHotkey\src\Interfaces\Enumerable1>

/**
 * Tree data structure.
 */
class Tree {
    static __New() => (AquaHotkey) && this.Include(Enumerable1)

    /**
     * Constructs a new tree.
     * 
     * @constructor
     * @param   {Any}  Value  any value
     */
    __New(Value) {
        Root := TreeNode(Value)
        DefineProp(this, "Root", { Get: (_) => Root })
    }

    /**
     * Adds a child to the root of the tree, returning the new node.
     * 
     * @param   {Any}  Value  value of the node
     * @returns {TreeNode}
     */
    AddChild(Value) => (this.Root).AddChild(Value)

    /**
     * Returns an {@link Enumerator} that performs a tree walk over the tree
     * structure. This tree performs depth-first traversal.
     * 
     * Only size 1 enumerators are supported.
     * 
     * @param   {Integer}  _  parameter size (ignored)
     * @returns {Enumerator}
     */
    __Enum(_) {
        Stack := [[this.Root].__Enum(1)]
        ObjSetBase(TreeWalk_DFS, Enumerator.Prototype)
        return TreeWalk_DFS

        TreeWalk_DFS(&OutValue, *) {
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

    /**
     * Returns a depth-first {@link Enumerator} of the tree elements.
     * 
     * @returns {Enumerator}
     * @example
     * T := (...)
     * ;    1
     * ;  2   3
     * ; 4 5 6 7
     * T.DFS().Join(", ") ; ==> "1, 2, 4, 5, 3, 6, 7"
     */
    DFS() => this.__Enum(1)

    /**
     * Returns a breadth-first {@link Enumerator} of the tree elements.
     * 
     * @returns {Enumerator}
     * @example
     * T := (...)
     * ;    1
     * ;  2   3
     * ; 4 5 6 7
     * T.DFS().Join(", ") ; ==> "1, 2, 3, 4, 5, 6, 7"
     */
    BFS() {
        Stack := LinkedList(this.Root)
        ObjSetBase(TreeWalk_BFS, Enumerator.Prototype)
        return TreeWalk_BFS

        TreeWalk_BFS(&OutValue, *) {
            while (Stack.Length) {
                Node := Stack.Pop()
                Stack.Shove(Node.Children*)

                OutValue := Node.Value
                return true
            }
            return false
        }
    }

    /**
     * Returns a string representation of this tree.
     * 
     * @returns {String}
     */
    ToString() => Type(this) . " { Value: " . (String(this.Root.Value)) .
            ", Children: " . String(this.Root.Children) . " }"
}

T := Tree(1)
L :=  T.AddChild(2)
R :=  T.AddChild(3)
LL := L.AddChild(4)
LR := L.AddChild(5)
RL := R.AddChild(6)
RR := R.AddChild(7)

;    1
;  2   3
; 4 5 6 7

#Include <AquaHotkey\src\Collections\LinkedList>
#Include <AquaHotkey\src\Interfaces\Enumerable1>

MsgBox T.BFS().Join()