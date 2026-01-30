#Include "%A_LineFile%\..\..\Interfaces\Sizeable.ahk"
#Include "%A_LineFile%\..\..\Interfaces\Enumerable1.ahk"
#Include "%A_LineFile%\..\..\Interfaces\Enumerable2.ahk"
#Include "%A_LineFile%\..\..\Interfaces\Deque.ahk"
#Include "%A_LineFile%\..\..\Interfaces\Indexable.ahk"

; TODO fully complete IArray contract

/**
 * A doubly linked list implementation.
 * 
 * @module  <Collections/LinkedList>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic
 */
class LinkedList extends IArray {
    static __New() {
        if (this == LinkedList) {
            ({}.DefineProp)(this.Prototype, "__New",
                    ({}.GetOwnPropDesc)(this.Prototype, "Push"))
            this.Backup(Sizeable, Deque, Enumerable1, Enumerable2, Indexable)
        }
    }

    /**
     * Returns the node at the given index, otherwise throws an `IndexError`.
     * 
     * @private
     * @param   {Integer}  Index  index of the node
     * @returns {LinkedList.Node}
     */
    RequiredNodeAt(Index) {
        Node := this.NodeAt(Index)
        if (!Node) {
            throw IndexError("invalid index",, Index)
        }
        return Node
    }

    /**
     * Returns the node at the given index, otherwise `false`.
     * 
     * @private
     * @param   {Integer}  Index  index of the node
     * @returns {LinkedList.Node}
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
     * The first node of the list, or `false`.
     * 
     * @private
     * @readonly
     * @type {LinkedList.Node}
     */
    Head := false

    /**
     * The last element of the list, or `false`.
     * 
     * @private
     * @readonly
     * @type {LinkedList.Node}
     */
    Tail := false

    /**
     * Size of the list.
     * 
     * @public
     * @readonly
     * @type {Integer}
     */
    Size := 0

    /**
     * Constructs a new list containing the given elements.
     * 
     * @constructor
     * @param   {Any*}  Values  zero or more values.
     */
    __New(Values*) => this.Push(Values*)

    /**
     * Destructor that clears the list and the references between the nodes.
     */
    __Delete() => this.Clear()

    /**
     * Clears the list and the references between the nodes.
     * 
     * @example
     * L := LinkedList(1, 2, 3, 4)
     * L.Clear()
     * MsgBox(L.Size) ; 0
     */
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

    /**
     * Determines whether the index is valid and there is a value present at
     * the given index.
     * 
     * @param   {Integer}  Index  index of element
     * @returns {Boolean}
     * @example
     * LinkedList().Has(23)        ; false
     * LinkedList(1, 2, 3).Has(3)  ; true
     * LinkedList(1, 2, 3).Has(-2) ; true
     * LinkedList(unset, 2).Has(1) ; false
     */
    Has(Index) {
        Node := this.NodeAt(Index)
        return Node && Node.HasValue
    }

    /**
     * Retrieves the value at the given index. If there is no value present,
     * this method will attempt to:
     * 
     * - return `Default`, if specified
     * - return `ListObj.Default`, if specified
     * - otherwise, throw an `UnsetItemError`
     * 
     * @param   {Integer}  Index    index of element
     * @param   {Any?}     Default  default value
     * @throws  {IndexError}        if the index is invalid
     * @throws  {UnsetItemError}    when unable to retrieve item
     * @example
     * LinkedList(1, unset, 3).Get(2, "no value") ; "no value"
     * 
     * L := LinkedList(1, 2, unset)
     * L.Default := 3
     * L.Get() ; 3
     * 
     * LinkedList().Get(1)      ; IndexError!
     * LinkedList(unset).Get(1) ; UnsetItemError!
     */
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

    /**
     * Sets the value of the element at the given index.
     * 
     * @param   {Integer}  Index  index of element
     * @param   {Any?}     Value  new value
     * @throws  {IndexError}      if the index is invalid
     * @example
     * L := LinkedList(1, 2, 3)
     * L.Set(3, 4)      ; or: L[3] := 4
     * MsgBox(L.Get(4)) ; or: MsgBox(L[4])
     */
    Set(Index, Value?) {
        this.RequiredNodeAt(Index).Value := (Value?)
    }
    
    /**
     * Deletes the value of the element at the given index, without removing
     * the node.
     * 
     * @param   {Integer}  Index  index of element
     * @returns 
     */
    Delete(Index) {
        Node := this.RequiredNodeAt(Index)
        if (Node.HasValue) {
            Value := Node.Value
            Node.Value := unset
            return Value
        }
    }
    
    /**
     * Returns a 1-param or 2-param {@link Enumerator} that iterates through
     * the elements of this list.
     * 
     * @param   {Integer}  ArgSize  number of variables passed to for-loop
     * @returns {Enumerator}
     * @example
     * for Value in LinkedList(1, 2, 3) { ... }
     * 
     * for Index, Value in LinkedList(3, 5, 2) { ... }
     */
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

    /**
     * Gets or retrieves elements at the given index. `unset` is allowed to be
     * used when setting an element.
     * 
     * @param   {Integer}  Index  index of element
     * @param   {Any?}     Value  new value
     * @returns {Any}
     * @see {@link LinkedList#Get() .Get()}
     * @see {@link LinkedList#Set() .Set()}
     * @example
     * L := LinkedList(1, 2, 3)
     * L[1] := 23
     * L[2] := unset
     * MsgBox(L[3]) ; 3
     */
    __Item[Index] {
        get => this.Get(Index)
        set => this.Set(Index, Value?)
    }

    /**
     * Inserts the specified elements at the beginning of this linked list.
     * 
     * @param   {Any*}  Values  zero or more values
     * @example
     * L := LinkedList(3)
     * L.Shove(2, 1)
     * L.Stream().Join(", ") ; "3, 2, 1"
     */
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

    /**
     * Inserts the specified elements at the end of this linked list.
     * 
     * @param   {Any*}  Values  zero or more values
     * @example
     * L := LinkedList(1, 2)
     * L.Push(3, 4)
     * 
     * L.Stream().Join(", ") ; "1, 2, 3, 4"
     */
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

    /**
     * Retrieves and removes the head (first element) of this linked list.
     * 
     * @returns {Any}
     * @throws {UnsetItemError} if the list is empty
     * @example
     * L := LinkedList(1, 2, 3)
     * MsgBox(L.Poll()) ; 1
     * 
     * L.Stream().Join(", ") ; "2, 3"
     */
    Poll() {
        if (!this.Size) {
            throw UnsetItemError("linked list is empty")
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

    /**
     * Retrieves and removes the tail (last element) of this linked list.
     * 
     * @returns {Any}
     * @throws {UnsetItemError} if the list is empty
     * @example
     * L := LinkedList(1, 2, 3)
     * MsgBox(L.Pop())
     * 
     * L.Stream().Join(", ") ; "1, 2"
     */
    Pop() {
        if (!this.Size) {
            throw UnsetItemError("linked list is empty")
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

    /**
     * Inserts one or more elements at the given position. If no elements are
     * specified, this method does nothing.
     * 
     * @param   {Integer}  Index   position to insert at
     * @param   {Any*}     Values  one or more values
     * @example
     * L := LinkedList(1, 4, 5)
     * L.InsertAt(2,
     *            2, 3)
     * 
     * L.Stream().Join(", ") ; "1, 2, 3, 4, 5"
     */
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

    /**
     * Removes items from the list. The removed item is returned, if `Length`
     * is equal to `1`.
     * 
     * @param   {Integer}   Index   index of element
     * @param   {Integer?}  Length  range of items to remove
     * @returns {Any}
     * @example
     * L := LinkedList(1, 2, 3)
     * L.RemoveAt(2)  ; 2
     * MsgBox(L.Size) ; 2
     * 
     * L.RemoveAt(1, 2) ; ""
     * MsgBox(L.Size)   ; 0
     */
    RemoveAt(Index, Length := 1) {
        if (!IsInteger(Length)) {
            throw TypeError("Expected an Integer",, Type(Length))
        }
        if (Length < 0) {
            throw IndexError("< 0",, Length)
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
            } else { ; is first
                this.Head := Next
            }
            if (Next) {
                Next.Prev := Prev
            } else {
                this.Tail := Prev
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
        } else {
            this.Head := Next
        }
        if (Next) {
            Next.Prev := Prev
        } else {
            this.Tail := Prev
        }

        this.Size -= Length
    }

    /**
     * This class represents the nodes that make up the linked list.
     */
    class Node {
        /**
         * The next node, or `false`.
         * 
         * @private
         * @type {LinkedList.Node}
         */
        Next := false

        /**
         * The previous node, or `false`.
         * 
         * @private
         * @type {LinkedList.Node}
         */
        Prev := false

        /**
         * Constructs a new node.
         * 
         * @constructor
         * @param   {Any?}  Value  item contained in the node
         */
        __New(Value?) {
            if (IsSet(Value)) {
                this.DefineProp("Value", { Value: Value })
            }
        }

        /**
         * Determines whether this node contains a value.
         * 
         * @returns {Boolean}
         */
        HasValue => ObjHasOwnProp(this, "Value")
    }
}