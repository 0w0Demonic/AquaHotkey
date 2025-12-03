#Include "%A_LineFile%\..\..\Base\Eq.ahk"
#Include "%A_LineFile%\..\..\Base\Hash.ahk"

/**
 * A simple hash table implementation. Only the basic {@link Map} API is
 * supported, although you can convert instances of this class into a
 * {@link Stream} or {@link DoubleStream}. Don't expect anything beyond the
 * simple map operations to work properly.
 * 
 * This map depends on modules <Base/Eq> and <Base/Hash> to disperse objects
 * and to make equality checks.
 */
class HashMap extends Map {
    /**
     * Standard load factor to indicate how full the {@link HashMap} is allowed
     * to get before being resized.
     */
    static LoadFactor => 0.75

    /**
     * Initial capacity of the hash table.
     */
    static InitialCap => 16

    ; TODO
    static NextPowerOfTwo(x) {

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
    __New(Cap := HashMap.InitialCap) {
        if (!IsInteger(Cap)) {
            throw TypeError("Initial size must be an Integer",, Type(Cap))
        }

        if (Cap | (Cap - 1)) {
            Cap |= (Cap >>> 1)
            Cap |= (Cap >>> 2)
            Cap |= (Cap >>> 4)
            Cap |= (Cap >>> 8)
            Cap |= (Cap >>> 16)
            Cap |= (Cap >>> 32)
        }

        Bucket := Array()
        Bucket.Length := Cap
        Bucket.Default := false

        this.DefineProp("Bucket", { Get: (_) => Bucket })
        this.DefineProp("Capacity", { Get: (_) => Cap })
        this.DefineProp("Count", { Get: (_) => 0 })
    }

    Clear() {
        this.Bucket.Length := 0
    }

    ; TODO
    Clone() {
        
    }

    Delete(Key) {
        Container := this.Bucket.Get(Key.Hash() & this.Mask + 1)
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

    Get(Key, Default?) {
        Container := this.Bucket.Get(Key.Hash() & this.Mask + 1)
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
        throw UnsetError("Value not found")
    }

    Has(Key) {
        Container := this.Bucket.Get(Key.Hash() & this.Mask + 1)
        if (Container) {
            for Entry in Container {
                if (Key.Eq(Entry.Key)) {
                    return true
                }
            }
        }
        return false
    }

    Set(Key, Value, Args*) {
        if (this.Count >= (this.Capacity * HashMap.LoadFactor)) {
            this.Resize(this.Capacity << 1)
        }

        if (Args.Length & 1) {
            throw ValueError("Invalid parameter count",, Args.Length)
        }
        Set(Key, Value)
        Enumer := Args.__Enum(1)
        while (Enumer(&K) && Enumer(&V)) {
            Args(K, V)
        }

        Set(Key, Value) {
            Index := (Key.Hash() & this.Mask) + 1
            
            if (!this.Bucket.Has(Index)) {
                this.Bucket[Index] := Array({ Key: Key, Value: Value })
                NewCount := this.Count + 1
                this.DefineProp("Count", { Get: (_) => NewCount })
                return
            }
            Container := this.Bucket.Get(Index)
            for Entry in Container {
                if (Key.Eq(Entry.Key)) {
                    Entry.Value := Value
                    return
                }
            }
            NewCount := this.Count + 1
            this.DefineProp("Count", { Get: (_) => NewCount })
            Container.Push({ Key: Key, Value: Value })
        }
    }

    Resize(NewCap) {
        OldBucket := this.Bucket

        Bucket := Array()
        Bucket.Capacity := NewCap

        this.DefineProp("Bucket", { Get: (_) => Bucket })
        this.DefineProp("Capacity", { Get: (_) => NewCap })

        for Container in OldBucket {
            for Entry in Container {
                this.Set(Entry.Key, Entry.Value)
            }
        }
    }

    __Enum(n) {
        return Enumer

        Enumer(&Key, &Value) {
            static Containers := this.Bucket.__Enum(1)
            static Entries := (*) => false
            
            Loop {
                if (Entries(&Entry)) {
                    Key := Entry.Key
                    Value := Entry.Value
                    return true
                }
                Loop {
                    if (!Containers(&Container)) {
                        return false
                    }
                } Until (IsSet(Container))
                Entries := Container.__Enum(1)
            }
        }
    }

    Capacity {
        get {
            throw UnsetError("Capacity property is absent")
        }
        set {
            if (!IsInteger(value)) {
                throw TypeError("Expected an Integer",, Type(value))
            }
            if (value | (value - 1)) {
                value |= value >> 1
                value |= value >> 2
                value |= value >> 4
                value |= value >> 8
                value |= value >> 16
                value |= value >> 32
            }
            if (value >= (this.Count * HashMap.LoadFactor)) {
                this.Resize(value)
            }
            this.DefineProp("Capacity", { Get: (_) => value })
        }
    }

    CaseSense {
        get {
            throw PropertyError("not supported")
        }
        set {
            throw PropertyError("not supported")
        }
    }

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

    __Item[Key] {
        get => this.Get(Key)
        set {
            this.Set(Key, Value)
        }
    }
}

#Include <AquaHotkey\src\Base\ToString>

M := HashMap()
M.Set({ Foo: "bar" }, "baz")
M.Set({ Foo: "bar" }, "qux")
M.Set("whatever", "value")

for Key, Value in M {
    MsgBox(String(Key))
    MsgBox(String(Value))
}

