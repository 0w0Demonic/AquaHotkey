#Include "%A_LineFile%\..\..\Base\Eq.ahk"
#Include "%A_LineFile%\..\..\Base\Hash.ahk"

/**
 * A simple hash table implementation.
 * 
 * This class uses AquaHotkey's equality checks `.Eq()` and hash methods
 * (`.HashCode()`) to test keys for equivalance instead of object reference.
 * 
 * @module  <Collections/HashMap>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * M := HashMap()
 * 
 * M.Set([1, 2], "old value")
 * M.Set([1, 2], "new value") ; [1, 2].Eq([1, 2]) => true
 * 
 * MsgBox(M.Count) ; 1
 * MsgBox(M.Get([1, 2])) ; "new value"
 */
class HashMap extends Map {
    static __New() => (this == HashMap)
        && ({}.DefineProp)(this, "CapacityFor",
                          ({}.GetOwnPropDesc)(this.Prototype, "CapacityFor"))

    /**
     * Standard load factor to indicate how full the {@link HashMap} is allowed
     * to get before being resized.
     * 
     * @returns {Float}
     */
    static LoadFactor => 0.75

    /**
     * Initial minimum capacity of the hash table.
     * 
     * @returns {Integer}
     */
    static InitialCap => 16

    ;>> NOTE: this gets replaced by `HashMap#CapacityFor` when class is loaded
    /**
     * Returns the given number if it is a power of 2, otherwise returns the
     * next power of 2.
     * 
     * @param   {Integer}  x  amount of elements to fit into the `HashMap`
     * @returns {Integer}
     */
    static CapacityFor(x) => (this.Prototype).CapacityFor(x)

    /**
     * Returns the given number if it is a power of 2, otherwise returns the
     * next power of 2.
     * 
     * @param   {Integer}  x  amount of elements to fit into the `HashMap`
     * @returns {Integer}
     */
    CapacityFor(x) {
        x := Max(x, HashMap.InitialCap)
        if (!IsInteger(x)) {
            throw TypeError("Expected an Integer",, Type(x))
        }
        if (x <= 0) {
            throw ValueError("Capacity must be greater than 0",, x)
        }
        --x ; prevent making larger, if already power of 2
        x |= (x >>> 1)
        x |= (x >>> 2)
        x |= (x >>> 4)
        x |= (x >>> 8)
        x |= (x >>> 16)
        x |= (x >>> 32)
        return ++x
    }

    /**
     * Bit mask used to create index.
     */
    Mask => (this.Capacity - 1)

    /**
     * Constructs a new hash table with the given initial capacity.
     * 
     * @param   {Integer?}  Cap  initial capacity
     */
    __New(Values*) {
        if (Values.Length & 1) {
            throw ValueError("invalid param count",, Values.Length)
        }
        Cap := this.CapacityFor(Values.Length)

        Bucket := Array()
        Bucket.Default := false
        Bucket.Capacity := Cap
        loop Cap {
            Bucket.Push(false)
        }

        this.DefineProp("Capacity", { Get: (_) => Cap    })
        this.DefineProp("Bucket",   { Get: (_) => Bucket })
        this.DefineProp("Count",    { Get: (_) => 0      })

        this.Set(Values*)
    }

    /**
     * Clears this hash map.
     */
    Clear() {
        B := this.Bucket
        loop B.Length {
            B[A_Index] := false
        }
        this.DefineProp("Count", { Get: (_) => 0 })
    }

    /**
     * Creates a clone of this hash map.
     * 
     * @returns {HashMap}
     */
    Clone() {
        Result := HashMap()

        Cap := this.Capacity
        Count := this.Count

        Bucket := Array()
        Bucket.Capacity := Cap

        for Container in this.Bucket {
            if (!Container) {
                Bucket.Push(false)
                continue
            }
            NewContainer := Array()
            NewContainer.Capacity := Container.Length
            for Entry in Container {
                NewContainer.Push(Entry.Clone())
            }
            Bucket.Push(NewContainer)
        }

        Result.DefineProp("Capacity", { Get: (_) => Cap    })
        Result.DefineProp("Count",    { Get: (_) => Count  })
        Result.DefineProp("Bucket",   { Get: (_) => Bucket })
        return Result
    }

    /**
     * Deletes a key-value pair from this hash map, returning the current
     * value.
     * 
     * @param   {Any}  Key  the map key
     * @returns {Any}
     */
    Delete(Key) {
        Container := this.Bucket.Get((Key.HashCode() & this.Mask) + 1)
        if (Container) {
            for Entry in Container {
                if (Key.Eq(Entry.Key)) {
                    Container.RemoveAt(A_Index)
                    NewCount := this.Count - 1
                    this.DefineProp("Count", { Get: (_) => NewCount })
                    return Entry.Value
                }
            }
        }
        throw UnsetError("Value not found")
    }

    /**
     * Returns the value associated with the given map key.
     * 
     * @param   {Any}   Key      the map key
     * @param   {Any?}  Default  default value, if absent
     * @returns {Any}
     */
    Get(Key, Default?) {
        Index := ((Key.HashCode() & this.Mask) + 1)
        Container := this.Bucket.Get(Index)
        if (Container) {
            for Entry in Container {
                if (Key.Eq(Entry.Key)) {
                    return Entry.Value
                }
            }
        }
        if (IsSet(Default)) {
            return Default
        }
        if (HasProp(this, "Default")) {
            return this.Default
        }
        throw UnsetError("Value not found")
    }

    /**
     * Determines whether the map has an entry with the specified map key.
     * 
     * @param   {Any}  Key  the map key
     * @returns {Boolean}
     */
    Has(Key) {
        Index := ((Key.HashCode() & this.Mask) + 1)
        Container := this.Bucket.Get(Index)
        if (Container) {
            for Entry in Container {
                if (Key.Eq(Entry.Key)) {
                    return true
                }
            }
        }
        return false
    }

    /**
     * Sets zero or more items.
     * 
     * @param   {Any*}  Args  alternating key and value
     */
    Set(Args*) {
        if (Args.Length & 1) {
            throw ValueError("Invalid parameter count",, Args.Length)
        }
        MaxCap := (this.Capacity * HashMap.LoadFactor)
        if ((this.Count + Args.Length) >= MaxCap) {
            this.Resize(this.Capacity << 1)
        }
        NewCount := this.Count

        Enumer := Args.__Enum(1)

        itemPair:
        while (Enumer(&Key) && Enumer(&Value)) {
            Index := (Key.HashCode() & this.Mask) + 1
            
            if (!this.Bucket.Get(Index)) {
                this.Bucket[Index] := Array({ Key: Key, Value: Value })
                ++NewCount
                continue
            }

            Container := this.Bucket.Get(Index)
            for Entry in Container {
                if (Key.Eq(Entry.Key)) {
                    Entry.Value := Value
                    continue itemPair
                }
            }
            Container.Push({ Key: Key, Value: Value })
            ++NewCount
        }
        ({}.DefineProp)(this, "Count", { Get: (_) => NewCount })
        return
    }

    /**
     * Increases the capacity of this hash map to the given max capacity.
     * The capacity remains at least the amount of elements present in the
     * hash map.
     * 
     * @param   {Integer}  Cap  the new capacity of the map
     */
    Resize(Cap) {
        if (Cap <= this.Capacity) {
            return
        }
        OldBucket := this.Bucket

        Bucket := Array()
        Bucket.Capacity := Cap
        loop Cap {
            Bucket.Push(false)
        }

        this.DefineProp("Bucket",   { Get: (_) => Bucket })
        this.DefineProp("Capacity", { Get: (_) => Cap })

        for Container in OldBucket {
            if (!Container) {
                continue
            }
            for Entry in Container {
                this.Set(Entry.Key, Entry.Value)
            }
        }
    }

    /**
     * Returns an `Enumerator` for this hash map.
     * 
     * @param   {Integer}  n  parameter length of the enumerator
     * @returns {Enumerator}
     */
    __Enum(n) {
        return Enumer

        Enumer(&Key, &Value?) {
            static Containers := this.Bucket.__Enum(1)
            static Entries := (*) => false
            
            loop {
                if (Entries(&Entry)) {
                    Key := Entry.Key
                    Value := Entry.Value
                    return true
                }
                loop {
                    if (!Containers(&Container)) {
                        return false
                    }
                } until (Container)
                Entries := Container.__Enum(1)
            }
        }
    }

    /**
     * The maximum capacity of this hash map.
     */
    Capacity {
        get {
            throw UnsetError("Capacity property is absent")
        }
        set {
            value := this.CapacityFor(value)
            if (value >= (this.Count * HashMap.LoadFactor)) {
                this.Resize(value)
            }
            this.DefineProp("Capacity", { Get: (_) => value })
        }
    }

    /**
     * Case sensitivity of the hashmap (unsupported).
     */
    CaseSense {
        get {
            throw PropertyError("Not supported")
        }
        set {
            throw PropertyError("Not supported")
        }
    }

    /**
     * Default value returned if no key is found.
     */
    Default {
        get {
            throw UnsetError("no default value present")
        }
        set {
            if (!IsSet(value)) {
                this.DeleteProp("Default")
            } else {
                this.DefineProp("Default", { Get: (_) => value })
            }
        }
    }

    /**
     * Gets and sets items in the hash map.
     * 
     * Newly set values are not allowed to be `unset`.
     * 
     * @param   {Any}  Key    the map key
     * @param   {Any}  Value  value to associate with the key
     * @returns {Any}
     */
    __Item[Key] {
        get => this.Get(Key)
        set {
            this.Set(Key, Value)
        }
    }
}

MsgBox("result: " . HashMap(1, 2, 1, 2).Count)