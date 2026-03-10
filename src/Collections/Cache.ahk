#Include "%A_LineFile%\..\..\Interfaces\IDelegatingMap.ahk"

/**
 * A simple {@link IMap} which holds entries with a specified time-to-live
 * (TTL). Entries expire after a certain duration of time unless they are
 * access via get/set/has operations.
 * 
 * This class is meant to be used together with {@link AquaHotkey_Duration}.
 * 
 * @module  <Collections/Cache>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * Cls := Cache.WithTtl((10).Seconds)
 * 
 * CacheObj := Cls(1, 2, 3, 4)
 * MsgBox(CacheObj.Count) ; 2 (`1 -> 2` and `3 -> 4`)
 * 
 * Sleep(6000)
 * X := Cls.Get(1) ; refresh TTL
 * 
 * ; At this point, the other entry (`3 -> 4`) will have expired, as the TTL
 * ; is defined as 10 seconds.
 * Sleep(6000)
 * MsgBox(CacheObj.Count) ; 1
 * 
 */
class Cache extends IDelegatingMap {
    /**
     * Creates a subclass with the specified time-to-live (TTL)
     * in milliseconds.
     * 
     * @param   {Duration|Integer}  Ttl  time-to-live of map entries
     * @returns {Class}
     */
    static WithTtl(Ttl) {
        if (!IsInteger(Ttl)) {
            throw TypeError("Expected a Duration or Integer",, Type(Ttl))
        }
        if (Ttl < 0) {
            throw ValueError("Must be > 0",, Ttl)
        }
        ; note:
        Cls := Object()
        Proto := Object()
        Proto.DefineProp("TTL", { Get: (_) => Ttl })
        Cls.DefineProp("Prototype", { Value: Proto })
        ObjSetBase(Cls, Cache)
        ObjSetBase(Cls, Cache.Prototype)
    }

    /**
     * Default time-to-live in milliseconds, which is equivalent to 30 seconds.
     * To specify your own value, use {@link Cache.WithTtl()} or a subclass
     * that overrides this property.
     * 
     * @abstract
     * @property {Integer}
     */
    TTL => 30000

    /**
     * Constructs a new cache object.
     * 
     * @constructor
     * @param   {Any*}  Args  alternating key-value pairs
     */
    __New(Args*) {
        if (Args.Length & 1) {
            throw ValueError("invalid param count",, Args.Length)
        }

        M := Map()
        Timers := Map()

        this.DefineProp("M", { Get: (_) => M })
        this.DefineProp("Timers", { Get: (_) => Timers })
        this.Set(Args*)
    }

    /**
     * Clears the map.
     */
    Clear() {
        Prev := Critical("On")
        
        for Key, Timer in (this.Timers) {
            SetTimer(Timer, false)
        }
        (this.M).Clear()
        (this.Timers).Clear()

        Critical(Prev)
    }

    /**
     * Clones the map.
     * 
     * @returns {Cache}
     */
    Clone() {
        Prev := Critical("On")

        Copy := Object()
        ObjSetBase(Copy, ObjGetBase(this))
        Copy.__Init()
        Copy.__New()
        for Key, Value in this {
            Copy.Set(Key, Value)
        }

        Critical(Prev)
        return Copy
    }

    /**
     * Retrieves items from the cache. If present, the TTL of the entry is
     * refreshed.
     * 
     * @param   {Any}   Key      map key
     * @param   {Any?}  Default  default value
     * @returns {Any}
     */
    Get(Key, Default?) {
        if ((this.M).Has(Key)) {
            Prev := Critical("On")

            Value := (this.M).Get(Key)
            SetTimer((this.Timers)[Key], -1000)

            Critical(Prev)
            return Value
        }
        return (this.M).Get(Key, Default?)
    }

    /**
     * Deletes an item from the cache, returning its value or throwing an
     * {@link UnsetItemError} if the entry cannot be found.
     * 
     * @param   {Any}  Key  map key
     * @returns {Any}
     */
    Delete(Key) {
        Prev := Critical("On")

        Value := (this.M).Delete(Key)
        (this.Timers).Delete(Key)

        Critical(Prev)
        return Value
    }

    /**
     * Sets items in the cache. The TTL of existing entries is refreshed.
     * 
     * @param   {Any*}  Args  alternating key-value pairs
     */
    Set(Args*) {
        if (Args.Length & 1) {
            throw ValueError("invalid param count",, Args.Length)
        }
        Enumer := Args.__Enum(1)
        while (Enumer(&Key) && Enumer(&Value)) {
            Timer := CreateTimer(this, Key)
            (this.Timers)[Key] := Timer
            SetTimer(Timer, -1000)

            (this.M).Set(Key, Value)
        }

        static CreateTimer(CacheObj, Key) {
            return Timer
            Timer() {
                (CacheObj.Timers).Delete(Key)
                (CacheObj.M).Delete(Key)
            }
        }
    }

    /**
     * Determines whether an entry is present in the cache. If present, its
     * TTL is refreshed.
     * 
     * @param   {Any}  Key  map key
     * @returns {Boolean}
     */
    Has(Key) {
        Prev := Critical("On")

        Result := (this.M).Has(Key)
        if (Result) {
            SetTimer((this.Timers)[Key], -1000)
        }

        Critical(Prev)
        return Result
    }

    /**
     * Gets and sets items in the cache.
     * 
     * @property {Any}
     * @param    {Any}  Key  map key
     */
    __Item[Key] {
        get => this.Get(Key)
        set => this.Set(Key, value)
    } 
}