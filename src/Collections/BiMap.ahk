#Include <AquaHotkeyX>

/**
 * 
 */
class BiMap extends IMap {
    /**
     * 
     */
    static Call(Args*) => this.Create(Map, Args*)
    
    /**
     * 
     */
    static Create(MapClass, Args*) {
        if (Args.Length & 1) {
            throw ValueError("invalid param count",, Args.Length)
        }
        if (!(MapClass is Class)) {
            throw TypeError("Expected a Class",, Type(MapClass))
        }
        if (!IMap.CanCastFrom(MapClass)) {
            throw TypeError("Expected an IMap class",,
                            MapClass.Prototype.__Class)
        }

        Keys := MapClass()
        Values := MapClass()

        Enumer := Args.__Enum(1)
        while (Enumer(&Key) && Enumer(&Value)) {
            Keys.Set(Key, Value)
            Values.Set(Value, Key)
        }
        Obj := { Keys: Keys, Values: Values }
        ObjSetBase(Obj, this.Prototype)
        return Obj
    }

    /**
     * 
     */
    Clear() {
        this.Keys.Clear()
        this.Values.Clear()
    }

    /**
     * 
     */
    Delete(Key) => this.Keys.Delete(Key)

    /**
     * 
     */
    DeleteValue(Value) => this.Values.Delete(Value)

    /**
     * 
     */
    Get(Key, Default?) => this.Keys.Get(Key, Default?)

    /**
     * 
     */
    GetKey(Value, Default?) => this.Values.Get(Value, Default?)

    /**
     * 
     */
    Has(Key) => this.Keys.Has(Key)

    /**
     * 
     */
    HasValue(Value) => this.Values.Has(Value)

    /**
     * 
     */
    Set(Key, Value) {
        this.Keys.Set(Key, Value)
        this.Values.Set(Value, Key)
    }

    /**
     * 
     */
    __Enum(ArgSize) => this.Keys.__Enum(ArgSize)

    /**
     * 
     */
    Count => this.Keys.Count

    /**
     * 
     */
    Size => this.Keys.Count

    /**
     * 
     */
    Reversed() {
        Obj := { Keys: this.Values, Values: this.Keys }
        ObjSetBase(Obj, ObjGetBase(this))
        return Obj
    }
}

class AquaHotkey_BiMap extends AquaHotkey {
    class IMap {
        /**
         * 
         */
        ToBiMap() => BiMap.FromMap(this)
    }
}