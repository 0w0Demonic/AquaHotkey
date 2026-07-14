#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IMap.ahk"
#Include "%A_LineFile%\..\..\Base\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\IO\Serial.ahk"
#Include "%A_LineFile%\..\..\IO\Serializer.ahk"
#Include "%A_LineFile%\..\Set.ahk"

; TODO combine additions and deletions through "DELETED" as magic object?

/**
 * An immutable view of an existing {@link IMap} that has a set of added or
 * deleted items.
 * 
 * Overlay maps can be created by calling `.Assoc()` or `.Dissoc()` on any
 * instance of {@link IMap}.
 * 
 * @module  <Collections/OverlayMap>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class OverlayMap extends IMap
{
    ;@region Construction

    ; dev-note: as long as `.__New()` is callable with zero args, NOT using
    ;           key-value pairs is totally okay.

    /**
     * Creates a new overlay map. This constructor should only be accessed
     * through {@link AquaHotkey_OverlayMap.IMap#Assoc `.Assoc()`} and
     * {@link AquaHotkey_OverlayMap.IMap#Dissoc `.Dissoc()`}.
     * 
     * @private
     * @constructor
     * @param   {IMap?}     Parent  parent map
     * @param   {Integer?}  Depth   depth
     */
    __New(Parent := EMPTY, Depth := 1) {
        static EMPTY := Map() ; can be reused, because never modified

        Define(Name, Value) {
            ({}.DefineProp)(this, Name, { Get: (_) => Value })
        }

        if (!IMap.IsInstance(Parent)) {
            throw TypeError("Expected an IMap",, Type(Parent))
        }
        if (!IsInteger(Depth)) {
            throw TypeError("Expected an Integer",, Type(Depth))
        }

        if (Parent is OverlayMap) {
            Additions := IMap.BasedFrom(Parent.Additions)
            Deletions := IMap.BasedFrom(Parent.Additions).AsSet()
        } else {
            Additions := Map()
            Deletions := Set()
        }
        if (Depth < 1) {
            throw ValueError("Depth must be >= 1",, Depth)
        }
        if (this == Parent) {
            throw ValueError("parent cannot be map itself")
        }

        Define("Parent", Parent)
        Define("Additions", Additions)
        Define("Deletions", Deletions)

        if (Depth > this.MaxDepth) {
            this.Flatten()
            Depth := 1
        }
        Define("Depth", Depth)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Settings

    /**
     * The maximum amount of layers before this overlay map is "flattened".
     * 
     * @returns {Integer}
     */
    static MaxDepth => (this.Prototype).MaxDepth

    /**
     * The maximum amount of layers before this overlay map is "flattened".
     * 
     * @returns {Integer}
     */
    MaxDepth => 5

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Map Implementation

    /**
     * Gets an item in the overlay map. The added items in this overlay map
     * take precedence over the previously defined ones.
     * 
     * @param   {Any}   Key      map key
     * @param   {Any?}  Default  default value
     * @returns {Any}
     */
    Get(Key, Default?) {
        if (!(this.Deletions).Contains(Key)) {
            if ((this.Additions).TryGet(Key, &Value)) {
                return Value
            }
            if ((this.Parent).TryGet(Key, &Value)) {
                return Value
            }
        }
        if (IsSet(Default)) {
            return Default
        }
        if (HasProp(this, "Default")) {
            return this.Default
        }
        throw UnsetItemError("item not found")
    }

    /**
     * Determines whether the given key has an associated value in this overlay
     * map.
     * 
     * @param   {Any}  Key  map key
     * @returns {Boolean}
     */
    Has(Key) {
        return !(this.Deletions).Contains(Key)
            && ((this.Additions).Has(Key) || (this.Parent).Has(Key))
    }

    /**
     * Returns an {@link Enumerator} for the items present in this overlay map.
     * 
     * @param   {Integer}  _  argument length (ignored)
     * @returns {Enumerator}
     */
    __Enum(_) {
        Del := this.Deletions
        Seen := IMap.BasedFrom(this.Additions).AsSet()
        Sources := Array(this.Additions, this.Parent).__Enum(1)
        Enumer := (*) => false
        ObjSetBase(__Enum, Enumerator.Prototype)
        return __Enum

        __Enum(&Key, &Value?) {
            loop {
                if (Enumer(&Key, &Value)) {
                    if (!Del.Contains(Key) && Seen.Add(Key)) {
                        return true
                    }
                } else {
                    if (!Sources(&Source)) {
                        return false
                    }
                    Enumer := Source.__Enum(2)
                }
            }
        }
    }

    /**
     * Number of items present in the overlay map.
     * 
     * @returns {Integer}
     */
    Count {
        get {
            Count := (this.Parent).Count
            Del := (this.Deletions)
            Seen := IMap.BasedFrom(this.Additions).AsSet()

            for Key, Value in this {
                if (!Del.Contains(Key) && Seen.Add(Key)) {
                    ++Count
                }
            }
            ({}.DefineProp)(this, "Count", { get: (_) => Count })
            return Count
        }
    }

    /**
     * The case-sensitivity of this map.
     * 
     * @returns {Primitive}
     */
    CaseSense => (this.Parent).CaseSense

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Flattening

    /**
     * Whether this overlay map is flattened. In other words, whether this
     * map contains all of the changes made to the original map instead of
     * having to delegate to the parent map.
     * 
     * @returns {Boolean}
     */
    IsFlattened => false

    /**
     * Flattens this map by compressing the changes that were made to the
     * original map across multiple parents.
     * 
     * @returns {OverlayMap}
     */
    Flatten() {
        static Define := {}.DefineProp

        Chain := Array()
        M := this
        while ((M is OverlayMap) && !M.IsFlattened) {
            Chain.Push(M)
            M := M.Parent
        }

        if (Chain.Length == 1) {
            ; there's nothing to flatten
            return this
        }

        Add := IMap.BasedFrom(this.Additions)
        Del := IMap.BasedFrom(this.Additions).AsSet()

        while (Chain.Length) {
            M := Chain.Pop()
            for Key, Value in (M.Additions) {
                Add.Set(Key, Value)
            }
            Del.Add((M.Deletions)*)
        }
        
        Define(this, "Additions", { Get: (_) => Add })
        Define(this, "Deletions", { Get: (_) => Del })
        Define(this, "IsFlattened", { Get: (_) => true })
        return this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Assoc()/Dissoc()

    /**
     * Returns an immutable copy of this map, with additional items `Args*`
     * added to the copy.
     * 
     * @param   {Any*}  Args  alternating key and value
     * @returns {OverlayMap}
     */
    Assoc(Args*) {
        M := OverlayMap(this, this.Depth + 1)
        (M.Additions).Set(Args*)
        return M
    }

    /**
     * Returns an immutable copy of this map, with the given items removed
     * from the copy.
     * 
     * @param   {Any*}  Args  map keys
     * @returns {OverlayMap}
     */
    Dissoc(Args*) {
        M := OverlayMap(this, this.Depth + 1)
        (M.Deletions).Add(Args*)
        return M
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Serialization

    /**
     * Serializes this map into binary.
     * 
     * @param   {OutputStream}  Output  output stream
     * @param   {Map}           Refs    previously seen objects
     */
    Serialize(Output, Refs) {
        (Object.Prototype.Serialize)(this, Output, Refs)

        Output.WriteUInt(this.Depth)
        Output.WriteUChar(this.IsFlattened)
        Output.WriteObject(this.Parent)
        Output.WriteObject(this.Additions)
        Output.WriteObject(this.Deletions)
    }

    /**
     * Reconstructs this map from binary.
     * 
     * @param   {InputStream}  Input  input stream
     * @param   {Map}          Refs   previously seen objects
     */
    Deserialize(Input, Refs) {
        static Define := {}.DefineProp

        Depth := Input.ReadUInt()
        IsFlat := Input.ReadUChar()

        Input.ReadObject(&Parent, Refs)
        Input.ReadObject(&Additions, Refs)
        Input.ReadObject(&Deletions, Refs)

        if (IsFlat) {
            Define(this, "IsFlattened", { Get: (_) => true })
        }
        Define(this, "Depth",     { Get: (_) => Depth     })
        Define(this, "Parent",    { Get: (_) => Parent    })
        Define(this, "Additions", { Get: (_) => Additions })
        Define(this, "Deletions", { Get: (_) => Deletions })
    }

    ;@endregion
}

/**
 * Extensions related to {@link OverlayMap}.
 */
class AquaHotkey_OverlayMap extends AquaHotkey {
    class IMap {
        /**
         * Returns an immutable copy of this map, with additional items
         * `Args*` added to the copy.
         * 
         * @param   {Any*}  Args  alternating key and value
         * @returns {OverlayMap}
         * @example
         * M1 := Map(1, 2)
         * M2 := M1.Assoc(3, 4)
         */
        Assoc(Args*) {
            M := OverlayMap(this)
            (M.Additions).Set(Args*)
            return M
        }

        /**
         * Returns an immutable copy of this map, with the given items removed
         * from the map.
         * 
         * @param   {Any*}  Args  map keys to remove
         * @returns {OverlayMap}
         */
        Dissoc(Args*) {
            M := OverlayMap(this)
            (M.Deletions).Add(Args*)
            return M
        }
    }
}
