#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IMap.ahk"

/**
 * A doubly-linked list-backed {@link IMap} that preserves insertion order.
 *
 * Maintains insertion order for iteration via `__Enum()`. `Set()` appends to
 * the tail, `Shove()` prepends to the head, and `Delete()` removes from the
 * list.
 *
 * @module  <Collections/OrderedMap>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * O := Map("A", 1, "B", 2, "C", 3).Ordered()
 * 
 * ; Prints in insertion order
 * O.ForEach((Key, Value) => MsgBox(Key . ": " . Value))
 */
class OrderedMap extends IMap {
    /**
     * The first element, or `false`.
     * 
     * @private
     * @type {Object}
     */
    Head := false

    /**
     * The last element, or `false`.
     * 
     * @private
     * @type {Object}
     */
    Tail := false

    /**
     * Creates a new `OrderedMap` with optional initial key-value pairs.
     *
     * @constructor
     * @param   {Any*}  Args  alternating key-value pairs
     * @example
     * O := OrderedMap("Name", "Alice", "Age", 30)
     */
    __New(Args*) {
        M := Map()
        this.DefineProp("M", { Get: (_) => M })
        this.Set(Args*)
    }

    /**
     * Creates an `OrderedMap` from an existing Map-like object, preserving
     * order.
     * 
     * Constructs an OrderedMap from any `IMap`-compatible source.
     * The internal map is created from {@link IMap.Create() `MapParam`}, then
     * each item is inserted via `Set()` to build the linked list in order.
     *
     * @param   {Any}  MapParam  map parameter
     * @returns {OrderedMap}
     * @example
     * M := Map("A", 1, "B", 2)
     * O := OrderedMap.From(M)
     * 
     * ; same as:
     * O := Map("A", 1, "B", 2).Ordered()
     */
    static From(MapParam) {
        M := IMap.Create(MapParam)

        O := Object()
        ObjSetBase(O, this.Prototype)

        O.__Init()
        O.DefineProp("M", { Get: (_) => M })

        for Key, Value in M {
            O.Set(Key, Value)
        }
        return O
    }

    /**
     * Removes all entries and unlinks all list nodes.
     */
    Clear() {
        (this.M).Clear()
        Node := this.Head
        while (Node) {
            Next := Node.Next
            Node.Next := unset
            Node.Prev := unset
            Node := Next
        }
        this.Head := unset
        this.Tail := unset
    }

    /**
     * Appends key-value pairs to the end of the ordered map.
     *
     * @param   {Any*}  Values  alternating key-value pairs
     * @example
     * O.Set("X", 10, "Y", 20)
     */
    Set(Values*) {
        if (Values.Length & 1) {
            throw ValueError("invalid param count",, Values.Length)
        }
        Enumer := Values.__Enum(1)
        while (Enumer(&Key) && Enumer(&Value)) {
            Node := { Key: Key, Value: Value, Next: false }
            (this.M).Set(Key, Node)

            if (!this.Tail) {
                Node.Prev := false
                this.Head := Node
            } else {
                Node.Prev := this.Tail
                this.Tail.Next := Node
            }
            this.Tail := Node
        }
    }

    /**
     * Alias for `Set()` that appends to the tail.
     *
     * @param   {Any*}  Values  alternating key-value pairs
     */
    Push(Key, Value) => this.Set(Key, Value)

    /**
     * Removes the first item in the ordered map and outputs it into
     * `&Key` and `&Value`.
     * 
     * @param   {VarRef}  Key    (out) item key
     * @param   {VarRef}  Value  (out) item value
     */
    Poll(&Key, &Value) {
        if (!this.Count) {
            throw ValueError("Map is empty")
        }
        Head := this.Head
        (this.M).Delete(Head.Key)

        this.Head := this.Head.Next
        if (!(this.M).Count) {
            this.Tail := false
        } else {
            this.Head.Prev := false
        }

        Key := Head.Key
        Value := Head.Value
    }

    /**
     * Returns the last item in the ordered map and outputs it into `&Key`
     * and `&Value`.
     * 
     * @param   {VarRef}  Key    (out) item key
     * @param   {VarRef}  Value  (out) item value
     */
    Pop(&Key, &Value) {
        if (!this.Count) {
            throw ValueError("Map is empty")
        }
        Tail := this.Tail
        (this.M).Delete(Tail.Key)

        this.Tail := this.Tail.Prev
        if (!(this.M).Count) {
            this.Head := false
        } else {
            this.Tail.Next := false
        }

        Key := Tail.Key
        Value := Tail.Value
    }

    /**
     * Prepends key-value pairs to the beginning of the ordered map.
     *
     * @param   {Any*}  Values  alternating key-value pairs
     * @example
     * O.Shove("First", 1)
     */
    Shove(Values*) {
        if (Values.Length & 1) {
            throw ValueError("invalid param count",, Values.Length)
        }
        Enumer := Values.__Enum(1)
        while (Enumer(&Key) && Enumer(&Value)) {
            Node := { Key: Key, Value: Value, Prev: false }
            (this.M).Set(Key, Node)

            if (!this.Head) {
                Node.Next := false
                this.Tail := Node
            } else {
                Node.Next := this.Head
                this.Head.Prev := Node
            }
            this.Head := Node
        }
    }

    /**
     * Removes and returns the value for the given key.
     *
     * Unlinks the node from the doubly-linked list. Throws KeyError if key
     * does not exist (inherited behavior from Map.Delete).
     *
     * @param   {Any}  Key  the key to delete
     * @returns {Any}
     */
    Delete(Key) {
        Node := (this.M).Delete(Key)
        if (Node.Next) {
            Node.Next.Prev := Node.Prev
            Node.Next := false
        } else {
            this.Tail := this.Tail.Prev
        }
        if (Node.Prev) {
            Node.Prev.Next := Node.Next
            Node.Prev := false
        } else {
            this.Head := this.Head.Next
        }
        return Node.Value
    }

    /**
     * Retrieves the value associated with a key, or a default value.
     *
     * @param   {Any}   Key      the key to retrieve
     * @param   {Any?}  Default  optional value if key not found
     * @returns {Any}
     */
    Get(Key, Default?) {
        if ((this.M).Has(Key)) {
            return (this.M).Get(Key).Value
        }
        if (IsSet(Default)) {
            return Default
        }
        if (HasProp(this, "Default")) {
            return this.Default
        }
        throw UnsetItemError("unset item")
    }

    /**
     * Determines whether a key exists in the map.
     *
     * @param   {Any}  Key  the key to check
     * @returns {Boolean}
     */
    Has(Key) => (this.M).Has(Key)

    /**
     * Enumerates entries in insertion order.
     *
     * @param   {Integer}  ArgSize  1 for keys only, 2 for key-value pairs
     * @returns {Enumerator}
     */
    __Enum(ArgSize) {
        Node := this.Head
        ObjSetBase(Enumer, Enumerator.Prototype)
        return Enumer

        Enumer(&Key, &Value?) {
            if (!Node) {
                return false
            }
            Key := Node.Key
            Value := Node.Value
            Node := Node.Next
            return true
        }
    }

    /**
     * Element count of this map.
     * 
     * @type {Integer}
     */
    Count => (this.M).Count

    /**
     * Capacity of this map.
     * 
     * @type {Integer}
     */
    Capacity {
        get => (this.M).Capacity
        set => ((this.M).Capacity := value)
    }

    /**
     * Case sensitivity.
     * 
     * @type {Primitive}
     */
    CaseSense {
        get => (this.M).CaseSense
        set => ((this.M).CaseSense := value)
    }
}

/**
 * Extension methods related to {@link OrderedMap}.
 */
class AquaHotkey_OrderedMap extends AquaHotkey {
    class IMap {
        /**
         * Returns an ordered version of this map.
         * 
         * @returns {OrderedMap}
         */
        Ordered() => OrderedMap.From(this)
    }
}