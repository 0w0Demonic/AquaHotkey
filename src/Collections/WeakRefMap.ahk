#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IMap.ahk"

; TODO add a way to use weak values?

;@region WeakRefMap

/**
 * An implementation of {@link IMap} with *weak references* as keys.
 * 
 * The presence of an object in this map will not prevent it from being
 * disposed via `.__Delete()`. When a key is being disposed, it will be
 * automatically freed from the map.
 * 
 * @module  <Collections/WeakRefMap>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * O := Object()
 * M := WeakRefMap()
 * M[O] := 42
 * 
 * MsgBox(M.Count) ; 1
 * 
 * ; frees the object from the map.
 * O := unset
 * 
 * MsgBox(M.Count) ; 0
 */
class WeakRefMap extends IMap {
    /**
     * Constructs a new weak reference map using a regular {@link Map} as the
     * underlying storage.
     * 
     * @constructor
     * @param   {Any*}  Args  alternating key-value pairs
     */
    __New(Args*) {
        if (Args.Length & 1) {
            throw ValueError("Invalid param count",, Args.Length)
        }

        M := Map()
        this.DefineProp("M", { Get: (_) => M })
        this.Set(Args*)
    }

    /**
     * Destructor that performs cleanup.
     */
    __Delete() => this.Clear()

    /**
     * Clears the map and releases references to its keys.
     */
    Clear() {
        for Key, Value in this.M {
            if (IsObject(Key)) {
                ObjAddRef(ObjPtr(Key))
                (Key.WeakRefs).Delete(this)
            }
        }
        (this.M).Clear()
    }

    /**
     * Clones the map.
     * 
     * @returns {WeakRefMap}
     */
    Clone() {
        Copy := Object()
        ObjSetBase(Copy, ObjGetBase(this))
        Copy.__Init()
        Copy.__New()
        for Key, Value in this {
            Copy.Set(Key, Value) ; <-- use `.Set()` to add weak refs
        }
        return Copy
    }

    /**
     * Deletes an element from the map. This removes the weak reference to the
     * key, if applicable.
     * 
     * @param   {Any}  Key  map key
     * @returns {Any}
     */
    Delete(Key) {
        Value := (this.M).Delete(Key)
        if (IsObject(Key)) {
            ObjAddRef(ObjPtr(Key))
            (Key.WeakRefs).Delete(this)
        }
        return Value
    }

    /**
     * Determines whether the element is present in the map.
     * 
     * @param   {Any}  Key  map key
     * @returns {Boolean}
     */
    Has(Key) => (this.M).Has(Key)

    /**
     * Retrieves an element from the map.
     * 
     * @param   {Any}   Key      map key
     * @param   {Any?}  Default  default value
     * @returns {Any}
     */
    Get(Key, Default?) => (this.M).Get(Key, Default?)

    /**
     * Sets zero or more items.
     * 
     * @param   {Any*}  Args  alternating key-value pairs
     */
    Set(Args*) {
        if (Args.Length & 1) {
            throw ValueError("invalid param count",, Args.Length)
        }
        Enumer := Args.__Enum(1)
        while (Enumer(&Key) && Enumer(&Value)) {
            NeedsDestructor := IsObject(Key) && !(this.M).Has(Key)
            (this.M).Set(Key, Value)

            if (NeedsDestructor) {
                (Key.WeakRefs)[this] := Cleaner
                ObjRelease(ObjPtr(Key))
            }
        }

        Cleaner(Instance) {
            ObjPtrAddRef(Instance)
            this.Delete(Instance)
        }
    }

    /**
     * Gets or sets items.
     * 
     * @property {Any}
     * @param    {Any}  Key  map key
     */
    __Item[Key] {
        get => this.Get(Key)
        set => this.Set(Key, value)
    }

    /**
     * Case-sensitivity of the map.
     * 
     * @property {Integer}
     */
    CaseSense {
        get => (this.M).CaseSense
        set => ((this.M).CaseSense := value)
    }

    /**
     * Default value of the map.
     * 
     * @property {Any}
     */
    Default {
        get => (this.M).Default
        set => ((this.M).Default := value)
    }

    /**
     * The amount of items in the map.
     * 
     * @readonly
     * @property {Integer}
     */
    Count => (this.M).Count
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

/**
 * Provides support for weak references in objects. This is used internally by
 * {@link WeakRefMap} to automatically clean up entries when an object is
 * disposed.
 */
class AquaHotkey_WeakRef extends AquaHotkey {
    class Object {
        /**
         * A map of weak references to this object, where keys are the
         * referencing keys and values are the corresponding cleanup callbacks.
         * 
         * @private
         * @readonly
         * @property {Map<Object, Func>}
         */
        WeakRefs {
            get {
                if (ObjHasOwnProp(this, "__Class")) {
                    throw PropertyError(
                            "Cannot be called directly from a prototype",,
                            this.__Class . ".Prototype")
                }
                Refs := Map()
                if (HasProp(this, "__Delete")) {
                    Del := this.__Delete
                }
                this.DefineProp("__Delete", { Call: Destructor  })
                this.DefineProp("WeakRefs", { Get: (_) => Refs })
                return Refs

                Destructor(this) {
                    if (IsSet(Del)) {
                        Del(this)
                    }
                    Callbacks := Array()
                    for Key, Callback in Refs {
                        Callbacks.Push(Callback)
                    }
                    for Callback in Callbacks {
                        Callback(this)
                    }
                    Refs.Clear()
                }
            }
        }
    }
}

;@endregion