#Include <AquaHotkeyX>

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
class SkipList {
    /**
     * Class that represents the nodes that make up skip lists.
     */
    class Node {
        /**
         * Creates a new skip list node.
         * 
         * TODO
         */
        __New(Key, Value, Level) {
            this.Key := Key
            this.Value := Value

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

            this.Forward := Forward
        }
    }

    static WithOptions(Comp     := this.Comp,
                       MaxLevel := this.MaxLevel,
                       Prob     := this.Prob)
    {
        ; TODO
    }

    static Comp => (this.Prototype).Comp
    Comp => Any.Compare

    static MaxLevel => (this.Prototype).MaxLevel
    MaxLevel => 16

    static Prob => (this.Prototype).Prob
    Prob => 0.50

    __New(Args*) {
        if (Args.Length & 1) {
            throw ValueError("invalid parameter count",, Args.Length)
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

        Enumer := Args.__Enum(1)
        while (Enumer(&Key) && Enumer(&Value)) {
            this.Set(Key, Value)
        }
    }

    RandomLevel() {
        Level := 1
        Prob := this.Prob
        MaxLevel := this.MaxLevel
        while ((Random() < Prob) && (Level < this.MaxLevel)) {
            Level++
        }
        return Level
    }

    Find(&Out, Key) {
        Node := this.FindNode(Key)
        if (!Node) {
            return false
        }
        Out := Node.Value
        return true
    }

    Has(Key) => !!this.FindNode(Key)

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
        return true
    }

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

    Delete(Key) {
        Node := this.FindNode(Key, &Update)
        if (!Node) {
            return false
        }

        loop this.Level {
            Forward := Update.Get(A_Index).Forward
            if (Forward.Get(A_Index) != Node) {
                break
            }
            Forward[A_Index] := Node.Forward.Get(A_Index)
        }

        while (this.Level > 1 && !this.Head.Forward.Get(this.Level)) {
            this.Level--
        }
        return true
    }

    __Enum(ArgSize) {
        Curr := this.Head
        return Enumer

        Enumer(&Out) {
            Node := Curr.Forward.Get(1)
            if (Node) {
                Curr := Node
                Out := Node.Value
                return true
            }
            return false
        }
    }

    __Item[Key] {
        get => this.Get(Key)
        set {
            if (IsSet(Value)) {
                this.Set(Key, Value)
            } else {
                this.Delete(Key)
            }
        }
    }

    ToString() {
        Nodes := Map()

        Values := Map()
        Curr := this.Head
        loop {
            Next := Curr.Forward.Get(1)
            if (!Next) {
                break
            }
            Curr := Next
            Nodes.Set(Curr, A_Index)
            Values.Set(A_Index, Curr.Value)
        }

        Structure := Array()
        loop this.Level {
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

        Obj := {
            Values: Values,
            Structure: Structure,
            Level: this.Level,
            base: ObjGetBase(this)
        }
        return (super.ToString)(Obj)
    }

    Size {
        get {
            Result := 0
            for Value in this {
                ++Result
            }
            return Result
        }
    }
}

L := SkipList(Range(50)*)
MsgBox(L.Set(2, 2))
MsgBox(String(L))