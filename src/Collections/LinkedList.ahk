/**
 * @class
 * @template T the value contained
 * @classdesc
 * A simple linked list implementation.
 * 
 * Supports negative indexing and `unset` values.
 * 
 * @module  <Collections/LinkedList>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * L := LinkedList(1, 2, 3)
 * L.Pop() ; 3
 * L.Shove("insert first value")
 */
class LinkedList {
    static __New() {
        if (this != LinkedList) {
            return
        }
        this.Backup(Sizeable, Deque)
    }

    ;@region Fields

    /**
     * The first node in the list, otherwise `false` when empty.
     * 
     * @readonly
     * @type {LinkedList.Node}
     * @example
     * LinkedList().Head        ; false
     * LinkedList(1, 2, 3).Head ; Node(1)
     */
    Head := false

    /**
     * The last node in the list, otherwise `false` when empty.
     * 
     * @readonly
     * @type {LinkedList.Node}
     * @example
     * LinkedList().Tail        ; false
     * LinkedList(1, 2, 3).Tail ; Node(3)
     */
    Tail := false

    /**
     * Amount of elements in the list.
     * 
     * @readonly
     * @type {Integer}
     * @example
     * LinkedList(1, 2, 3).Size ; 3
     */
    Size := 0

    ;@endregion
    ;---------------------------------------------------------------------------

    /**
     * Constructs a new linked list containing the specified elements.
     * 
     * @constructor
     * @param   {Any*}  Values  zero or more elements
     * @example
     * Lst := LinkedList(1, 2, 3)
     */
    __New(Values*) => this.Push(Values*)

    /**
     * Returns the node at the given index of the list, otherwise throws
     * an `UnsetError` if the index is invalid.
     * 
     * @protected
     * @param   {Integer}  Index  index of the element 
     * @returns {LinkedList.Node}
     * 
     * @example
     * LinkedList(1, 2).RequiredNodeAt(3) ; IndexError!
     */
    RequiredNodeAt(Index) {
        Node := this.NodeAt(Index)
        if (!Node) {
            throw IndexError("invalid index",, Index)
        }
        return Node
    }

    /**
     * Returns the node at the given index of the list, otherwise `false`
     * if the index is invalid.
     * 
     * @protected
     * @param   {Integer}  Index  index of the element
     * @returns {LinkedList.Node}
     * @example
     * Lst := LinkedList(1, 2, 3, 4)
     * 
     * Lst.NodeAt(2)  ; Node(2)
     * Lst.NodeAt(-2) ; Node(3)
     * Lst.NodeAt(96) ; false
     */
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

    /**
     * Determines whether the given index is valid and there is a valid at that
     * position.
     * 
     * @param   {Index}  Index  index of element
     * @returns {Boolean}
     * @example
     * LinkedList(1, 2, 3, 4).Has(87)           ; false
     * LinkedList("foo", "bar", "baz").Has(-2)  ; true
     * LinkedList(unset).Has(1)                 ; false
     */
    Has(Index) {
        Node := this.NodeAt(Index)
        return (Node && Node.Has())
    }

    /**
     * Returns the value at a given index, or a default value.
     * 
     * @param   {Integer}  Index    index of element
     * @param   {T?}       Default  default value
     * @returns {T}                 element value or a default value
     * @throws  {IndexError}        if index is invalid
     * @throws  {UnsetItemError}    if item is unset
     * @example
     * LinkedList("foo", "bar", "baz").Get(2) ; "bar"
     * LinkedList(unset).Get(1, "nothing") ; "nothing"
     * 
     * Lst := LinkedList()
     * Lst.Default := false
     * Lst.Get()
     */
    Get(Index, Default?) {
        Node := this.RequiredNodeAt(Index)

        if (Node.Has()) {
            return Node.Value
        }
        if (IsSet(Default)) {
            return Default
        }
        if (ObjHasOwnProp(this, "Default")) {
            return this.Default
        }
        throw UnsetItemError("No value present")
    }

    /**
     * Sets the value of an element.
     * 
     * @param   {Integer}  Index  index of element
     * @param   {T?}       Value  new value to set
     * @throws  {IndexError}      if index is invalid
     * @example
     * Lst := LinkedList(1, 2, 3)
     * 
     * ; LinkedList("example", 2, 3)
     * Lst.Set(1, "example")
     */
    Set(Index, Value?) => this.RequiredNodeAt(Index).Set(Value?)

    /**
     * Deletes the element from the list.
     * 
     * @param   {Integer}  Index  index of element
     * @throws  {IndexError}      if index is invalid
     * @returns {T}               value of the element
     * @example
     * Lst := LinkedList(1, 2, 3)
     * 
     * ; LinkedList(1, 3) 
     * Lst.Delete(2) ; 2
     */
    Delete(Index) => this.RequiredNodeAt(Index).Delete()

    /**
     * Enumerates the values contained in this linked list.
     * 
     * @param   {Integer}  ArgSize  size of enumerator
     * @returns {Enumerator}
     * @example
     * for Value in MyList ...
     * for Index, Value in MyList ...
     */
    __Enum(ArgSize) {
        if (!IsInteger(ArgSize)) {
            throw TypeError("Expected an Integer",, Type(ArgSize))
        }
        return (ArgSize == 1) ? Enumer1 : Enumer2

        Enumer1(&Value) {
            static Node := this.Head
            if (!Node) {
                return false
            }
            Value := (Node.Has()) ? Node.Value : unset
            Node := Node.Next
            return true
        }

        Enumer2(&Index, &Value) {
            static Idx := 1
            static Node := this.Head

            if (!Node) {
                return false
            }
            Index := Idx++
            Value := (Node.Has()) ? Node.Value : unset
            Node := Node.Next
            return true
        }
    }

    /**
     * Retrieves and gets the value of an element in the linked list.
     * 
     * @param   {Integer}  Index  element index
     * @param   {T?}       Value  the value to set
     * @returns {T}
     * @example
     * Lst := LinkedList(1, 2, 3)
     * Lst[1] := "example"
     * MsgBox(Lst[1]) ; "example"
     */
    __Item[Index] {
        get => this.Get(Index)
        set => this.Set(Index, value?)
    }

    ; TODO
    Find(&OutValue, Condition, Args*) {

    }

    FindNode(&OutNode, Condition, Args*) {

    }

    ; TODO ignore this?
    FindIndex(Condition, Args*) {

    }

    ; TODO add method to attach more lists?
    ; rename to "Bump()"?

    /**
     * Inserts the specified values at the front of the list.
     * 
     * @param   {T*}  Values  the values to insert
     * @example
     * Lst := LinkedList(3, 4)
     * 
     * ; LinkedList(1, 2, 3, 4)
     * Lst.Shove(1, 2)
     */
    Shove(Values*) {
        for Value in Values {
            Node := LinkedList.Node(Value?)
            if ((A_Index == 1) && this.IsEmpty) {
                this.DefineProp("Head", { Value: Node })
                this.DefineProp("Tail", { Value: Node })
            } else {
                this.Head.DefineProp("Prev", { Value: Node })
                Node.DefineProp("Next", { Value: this.Head })
                this.DefineProp("Head", { Value: Node })
            }
        }
        Size := (this.Size + Values.Length)
        this.DefineProp("Size", { Get: (_) => Size })
    }

    /**
     * Inserts the specified values at the back of the list.
     * 
     * @param   {T*}  Values  the values to insert
     * @example
     * Lst := LinkedList(1, 2)
     * 
     * ; LinkedList(1, 2, 3, 4)
     * Lst.Push(3, 4)
     */
    Push(Values*) {
        for Value in Values {
            Node := LinkedList.Node(Value?)
            if ((A_Index == 1) && this.IsEmpty) {
                this.DefineProp("Head", { Value: Node })
                this.DefineProp("Tail", { Value: Node })
            } else {
                this.Tail.DefineProp("Next", { Value: Node })
                Node.DefineProp("Prev", { Value: this.Tail })
                this.DefineProp("Tail", { Value: Node })
            }
        }
        Size := (this.Size + Values.Length)
        this.DefineProp("Size", { Get: (_) => Size })
    }

    /**
     * Removes the first element of the list, returning its value.
     * 
     * @throws {UnsetError} if the list is empty
     * @returns {T} value of the first element
     * 
     * @example
     * Lst := LinkedList(1, 2, 3)
     * 
     * ; LinkedList(2, 3)
     * Lst.Poll() ; 1
     */
    Poll() {
        if (this.IsEmpty) {
            throw UnsetError("linked list is empty")
        }
        Head := this.Head
        Head.Next.DeleteProp("Prev")
        Head.DeleteProp("Next")

        Size := (this.Size - 1)
        this.DefineProp("Size", { Get: (_) => Size })

        if (Head.Has()) {
            return Head.Value
        }
    }

    /**
     * Removes the last element of the list, returning its value.
     * 
     * @throws {UnsetError} if the list is empty
     * @returns {T} value of the last element
     * 
     * @example
     * Lst := LinkedList(1, 2, 3)
     * 
     * ; LinkedList(1, 2)
     * Lst.Pop() ; 3
     */
    Pop() {
        if (this.IsEmpty) {
            throw UnsetError("linked list is empty")
        }
        Tail := this.Tail
        Tail.Prev.DeleteProp("Next")
        Tail.DeleteProp("Prev")

        Size := (this.Size - 1)
        this.DefineProp("Size", { Get: (_) => Size })
        
        if (Tail.Has()) {
            return Tail.Value
        }
    }

    /**
     * 
     */
    class Node {
        __New(Value?) => this.Set(Value?)

        Set(Value?) {
            if (IsSet(Value)) {
                this.DefineProp("Value", { Value: Value })
            } else {
                this.DeleteProp("Value")
            }
        }

        Get() {
            if (!ObjHasOwnProp(this, "Value")) {
                throw UnsetError("Value not found")
            }
            return this.Value
        }

        Has() => (this is LinkedList.Node) && ObjHasOwnProp(this, "Value")

        Delete() {
            Next := this.Next
            Prev := this.Prev
            this.DeleteProp("Next")
            this.DeleteProp("Prev")
            if (Next) {
                Next.DefineProp("Prev", { Value: Prev })
            }
            if (Prev) {
                Prev.DefineProp("Next", { Value: Next })
            }
            if (ObjHasOwnProp(this, "Value")) {
                return this.Value
            }
        }

        AttachLeft(Values*) {

        }

        AttachRight(Values*) {

        }

        CutLeft() {

        }

        CutRight() {

        }

        Prev => false
        Next => false
    }
}
