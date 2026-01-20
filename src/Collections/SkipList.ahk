#Include <AquaHotkeyX>
#Include "%A_LineFile%\..\..\Interfaces\IMap.ahk"

; TODO this, but as a Set

/**
 * Skip lists are probabilistic data structures that combine the advantages
 * of a sorted array (`O(log n)` lookup time) and linked lists.
 * 
 * They consist of multiple layers; the first layer 1 is a regular linked
 * list that contains all of the elements, followed by a hierarchy of
 * "express lanes" that each contain a smaller subset of the layer below.
 * 
 * ---
 * 
 * **Example**:
 * 
 * ```
 * L |                                                 |
 * e |                                                 |
 * v | ----------------> o --------------------------> |
 * e | -> o -----------> o --------------------------> |
 * l | -> o ------> o -> o ----------------> o ------> |
 * s | -> o ------> o -> o -> o -----------> o -> o -> |
 *   | -> o -> o -> o -> o -> o -> o -> o -> o -> o -> |
 * Head   1    2    3    4    5    6    7    8    9   Null
 * ```
 * 
 * ---
 * 
 * **How it Works**:
 * 
 * To retrieve elements, the skip list is iterated starting from the top layer
 * and then horizontally, traversing nodes as long as the current element is
 * smaller (`.Compare()`) than the target.
 * 
 * ```
 * Target: 9 (`SL.Get(9)`)
 * 
 * L |                                                 |
 * e |                                                 |
 * v | ----------------> o                             |
 * e |                   o                             |
 * l |                   o ----------------> o         |
 * s |                                       o -> o    |
 *   |                                            o    |
 * Head   1    2    3    4    5    6    7    8    9   Null
 * ```
 * 
 * @module  <Collections/SkipList>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class SkipList extends IMap {
    /**
     * Class that represents the nodes that make up skip lists.
     */
    class Node {
        /**
         * Creates a new skip list node.
         * 
         * @constructor
         * @param   {Any}      Key    node key
         * @param   {Any}      Value  node value
         * @param   {Integer}  Level  node level
         * @returns {SkipList.Node}
         */
        static Call(Key, Value, Level) {
            if (!IsInteger(Level)) {
                throw TypeError("Expected an Integer",, Type(Level))
            }
            if (Level <= 0) {
                throw ValueError("Must be greater than zero",, Level)
            }

            Forward := Array()
            Forward.Capacity := Level
            loop Level {
                Forward.Push(false)
            }

            Obj := {
                Key: Key,
                Value: Value,
                Forward: Forward
            }
            ObjSetBase(Obj, this.Prototype)
            return Obj
        }

        /**
         * Returns a string representation of this node.
         * 
         * @returns {String}
         */
        ToString() => String(this.Key) . " -> " . String(this.Value)
    }

    /**
     * Comparator used for comparing keys (defaults to `Any.Compare`).
     * 
     * @returns {Comparator}
     */
    static Comp => (this.Prototype).Comp

    /**
     * Comparator used for comparing keys (defaults to `Any.Compare`).
     * 
     * @returns {Comparator}
     */
    Comp => Any.Compare

    /**
     * The maximum reachable level of the skip list.
     * 
     * @returns {Integer}
     */
    static MaxLevel => (this.Prototype).MaxLevel

    /**
     * The maximum reachable level of the skip list.
     * 
     * @returns {Integer}
     */
    MaxLevel => 16

    /**
     * Probability that determines on which level a new node is inserted.
     * 
     * @returns {Number}
     */
    static Prob => (this.Prototype).Prob

    /**
     * Probability that determines on which level a new node is inserted.
     * 
     * @returns {Number}
     */
    Prob => 0.50

    /**
     * The amount of elements contained in the skip list.
     * 
     * @type {Integer}
     */
    Count => this.Size

    /**
     * The amount of elements contained in the skip list.
     * 
     * @readonly
     * @type {Integer}
     */
    Size := 0

    /**
     * Creates a new skip list that contains the specified elements.
     * 
     * @constructor
     * @param   {Any*}  Values  alternating key and value
     */
    __New(Values*) {
        if (this.Size) {
            throw Error("This skip list was already initialized")
        }
        if (Values.Length & 1) {
            throw ValueError("invalid parameter count",, Values.Length)
        }

        this.Level := 1
        Forward := Array()
        Forward.Capacity := this.MaxLevel
        loop this.MaxLevel {
            Forward.Push(false)
        }

        Head := { Forward: Forward }
        ObjSetBase(Head, SkipList.Node.Prototype)
        this.Head := Head

        Enumer := Values.__Enum(1)
        while (Enumer(&Key) && Enumer(&Value)) {
            this.Set(Key, Value)
        }
    }

    /**
     * Returns the "level" at which a new node should be inserted.
     * 
     * @private
     * @returns {Integer}
     */
    RandomLevel() {
        Level := 1
        Prob := this.Prob
        MaxLevel := this.MaxLevel
        while ((Random() < Prob) && (Level < this.MaxLevel)) {
            Level++
        }
        return Level
    }

    /**
     * Determines whether the skip list has a value associated with the given key.
     * 
     * @param   {Any}  Key  the key
     * @returns {Boolean}
     * @example
     * SkipList(1, 2, 3, 4).Has(3, &Out) ; true
     * MsgBox(Out) ; 4
     */
    Has(Key, &OutValue?) {
        Node := this.FindNode(Key)
        if (Node) {
            OutValue := Node.Value
            return true
        }
        OutValue := unset
        return false
    }

    /**
     * Sets an item. This method returns `true` if a new element was added to the skip
     * list, otherwise `false`.
     * 
     * Equivalent to `__Item[]`.
     * 
     * @param   {Any}  Key    the key
     * @param   {Any}  Value  value associated with key
     * @returns {Boolean}
     * @example
     * SL := SkipList(1, 2, 3, 4)
     * SL.Set(5, 6) ; or: SL[5] := 6
     */
    Set(Key, Value) {
        Node := this.FindNode(Key, &Update)
        if (Node) {
            Node.Value := Value
            return false
        }

        NewLevel := this.RandomLevel()
        Level := this.Level
        Head  := this.Head

        while (Level < NewLevel) {
            ++Level
            Update.Push(Head)
        }
        this.Level := Level

        NewNode := SkipList.Node(Key, Value, NewLevel)
        Forward := NewNode.Forward
        loop NewLevel {
            Rightmost := Update.Get(A_Index).Forward
            Forward[A_Index] := Rightmost.Get(A_Index)
            Rightmost[A_Index] := NewNode
        }
        ++this.Size
        return true
    }

    /**
     * Returns the value associated with a key, or a default value.
     * 
     * This method either:
     * 
     * - returns the value of the element.
     * - returns `Default`, if specified.
     * - returns `(SkipListObj).Default`, if specified.
     * - throws an `UnsetItemError`.
     * 
     * @param   {Any}   Key      the requested key
     * @param   {Any?}  Default  default value
     * @returns {Any}
     * @throws  {UnsetItemError} when unable to retrieve element
     * @example
     * SL := SkipList(1, 2, 3, 4)
     * SL.Get(1) ; 2
     * SL[1]     ; 2
     * 
     * SL.Get(7, "no value") ; "no value"
     */
    Get(Key, Default?) {
        Node := this.FindNode(Key)
        if (Node) {
            return Node.Value
        }
        if (IsSet(Default)) {
            return Default
        }
        if (HasProp(this, "Default")) {
            return this.Default
        }
        throw UnsetItemError("item not found",, String(Key))
    }

    /**
     * Traverses the skip list, returning the node containing the requested key,
     * otherwise `false`.
     * 
     * `OutUpdate` receives an array of the rightmost nodes at each level during
     * traversal, which are kept track of for insertion and deletion.
     * 
     * @private
     * @param   {Any}             Key        the requested key
     * @param   {VarRef<Array>?}  OutUpdate  (out) the rightmost nodes at each level
     * @returns {SkipList.Node}
     */
    FindNode(Key, &OutUpdate?) {
        Curr  := this.Head
        Level := this.Level
        Comp  := this.Comp

        Update := Array()
        Update.Capacity := Level
        loop Level {
            Update.Push(false)
        }

        while (Level >= 1) {
            loop {
                Node := Curr.Forward.Get(Level)
                if (Node && (Comp(Node.Key, Key) < 0)) {
                    Curr := Node
                } else {
                    break
                }
            }
            Update[Level--] := Curr
        }

        OutUpdate := Update

        Curr := Curr.Forward.Get(1)
        if (Curr && !Comp(Curr.Key, Key)) {
            return Curr
        }
        return false
    }

    /**
     * Deletes an item, if present. This method returns `true` if an element was removed
     * from the skip list, otherwise `false`.
     * 
     * @param   {Any}           Key       requested key
     * @param   {VarRef<Any>?}  OutValue  (out) associated value, if present
     * @returns {Boolean}
     * @example
     * SL := SkipList(1, 2, 3, 4)
     * SL.Delete(1, &Out) ; true
     * MsgBox(Out)        ; 2
     */
    Delete(Key, &OutValue?) {
        Node := this.FindNode(Key, &Update)
        if (!Node) {
            OutValue := unset
            return false
        }

        loop (this.Level) {
            Forward := Update.Get(A_Index).Forward
            if (Forward.Get(A_Index) != Node) {
                break
            }
            Forward[A_Index] := Node.Forward.Get(A_Index)
        }

        while (this.Level > 1 && !this.Head.Forward.Get(this.Level)) {
            this.Level--
        }
        --this.Size
        OutValue := Node.Value
        return true
    }

    /**
     * Creates an {@link Enumerator} object that enumerates the items of the skip list.
     * 
     * @param   {Integer}  ArgSize  amount of parameters passed in the for-loop
     * @returns {Enumerator}
     * @example
     * SL := SkipList(...)
     * 
     * for Key in SL { ... }
     * 
     * for Key, Value in SL { ... }
     */
    __Enum(ArgSize) {
        if (!IsInteger(ArgSize)) {
            throw TypeError("Expected an Integer",, Type(ArgSize))
        }
        Curr := this.Head
        return (ArgSize < 2) ? Enumer1 : Enumer2

        Enumer1(&OutKey) {
            Node := Curr.Forward.Get(1)
            if (Node) {
                Curr := Node
                OutKey := Node.Key
                return true
            }
            return false
        }

        Enumer2(&OutKey, &OutValue) {
            Node := Curr.Forward.Get(1)
            if (Node) {
                Curr     := Node
                OutKey   := Node.Key
                OutValue := Node.Value
                return true
            }
            return false
        }
    }

    /**
     * Clears the skip list.
     */
    Clear() {
        Head := this.Head.Forward
        Curr := Head.Get(1)
        loop (Head.Length) {
            Head[A_Index] := false
        }

        while (Curr) {
            Next         := Curr.Forward.Get(1)
            Curr.Forward := unset
            Curr.Key     := unset
            Curr.Value   := unset

            Curr         := Next
        }
        this.Size := 0
    }

    /**
     * Gets and sets items.
     * 
     * @param   {Any}  Key    any key
     * @param   {Any}  Value  value associated with key
     * @returns {Any}
     */
    __Item[Key] {
        get => this.Get(Key)
        set {
            this.Set(Key, Value)
        }
    }

    /**
     * Returns a string representation of the skip list, based on its elements and
     * internal structure.
     * 
     * @returns {String}
     * @example
     * ; SkipList {
     * ;   Level: 2,
     * ;   Size: 6,
     * ;   Structure: [
     * ;     [   2   ],
     * ;     [1, 2, 3]
     * ;   ],
     * ;   Values: [1 -> 2, 3 -> 4, 5 -> 6]
     * ; }
     * SkipList(1, 2, 3, 4, 5, 6).ToString()
     */
    ToString() {
        Nodes  := Map()
        Values := Array()
        Curr   := this.Head
        loop {
            Next := Curr.Forward.Get(1)
            if (!Next) {
                break
            }
            Curr := Next
            Nodes.Set(Curr, A_Index)
            Values.Push(String(Curr))
        }

        Structure := Array()
        loop (this.Level) {
            Level := this.Level - A_Index + 1
            Arr := Array()

            Curr := this.Head
            loop {
                Next := Curr.Forward.Get(Level)
                if (!Next) {
                    break
                }
                Curr := Next
                Arr.Push(Nodes.Get(Curr))
            }

            Structure.Push(Arr)
        }
        return (super.ToString)({
            Size: this.Size,
            Values: Values,
            Structure: Structure,
            Level: this.Level,
            base: ObjGetBase(this)
        })
    }
}