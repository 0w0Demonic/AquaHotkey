#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

; TODO allow hash codes in HashMap/HashSet to be customizable?

/**
 * Adds a universal `.HashCode()` method which generates a stable,
 * well-distributed integer from a value.
 * 
 * ---
 * 
 * Implementing custom hash codes for a given type allows collections like
 * {@link HashMap} and {@link HashSet} to efficiently use its instances
 * as keys.
 * 
 * ```ahk
 * M := HashMap()
 * M.Set([1, 2], "value1")
 * M.Set([1, 2], "value2")
 * 
 * MsgBox(M.Count)       ; 1
 * MsgBox(M.Get([1, 2])) ; "value2"
 * ```
 * 
 * In the example above, the HashMap determines that `[1, 2]` is already
 * present, because `A.HashCode() == B.HashCode()` and `A.Eq(B)`.
 * 
 * ---
 * 
 * `.HashCode()` must adhere to the following rules in order to work properly:
 * 
 * - The result of `.HashCode()` must not change, unless the value changes.
 * - If two values are equal ({@link AquaHotkey_Eq `.Eq()`}), they must produce
 *   the same hash code.
 * - `.HashCode()` should work on the same fields or characteristics as `.Eq()`
 * 
 * ```ahk
 * class Version {
 *     __New(Major, Minor, Patch) {
 *         this.Major := Major
 *         this.Minor := Minor
 *         this.Patch := Patch
 *     }
 * 
 *     Eq(Other?) {
 *         return IsSet(Other) && ((this == Other) ||
 *              (Other is Version)
 *           && ((this.Major).Eq(Other.Major))
 *           && ((this.Minor).Eq(Other.Minor))
 *           && ((this.Patch).Eq(Other.Patch)))
 *     }
 *     
 *     ; - result for an instance only depends on its three fields
 *     ; - consistent with `.Eq()`
 *     ; - value is consistent, because `Any.Hash()` is a pure function
 *     HashCode() => Any.Hash(this.Major, this.Minor, this.Patch)
 * }
 * ```
 * 
 * ---
 * 
 * `Any.Hash()` conveniently combines multiple values into a single hash code.
 * You should generally use this method when implementing custom hash codes.
 * 
 * Much like in {@link AquaHotkey_Eq} or {@link AquaHotkey_Ord}, `Any.Hash()`
 * asserts that every argument `is Any`. If all fields are known to be
 * integers, the method can be specialized:
 * 
 * ```ahk
 * HashCode() => Integer.Hash(this.Major, this.Minor, this.Patch)
 * ```
 * 
 * ---
 * 
 * For {@link AquaHotkey_DuckTypes duck types}, `static Hash()` must be
 * overridden on the class, which should use {@link AquaHotkey_Eq `.Is()`}
 * instead of regular `is`.
 * 
 * @module  <Base/Hash>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @see {@link HashMap}
 * @see {@link HashSet}
 * @see {@link AquaHotkey_Eq `.Eq()`}
 * @see {@link AquaHotkey_DuckTypes duck types}
 * @example
 * class Version {
 *     __New(Major, Minor, Patch) {
 *         this.Major := Major
 *         this.Minor := Minor
 *         this.Patch := Patch
 *     }
 *     HashCode() => Integer.Hash(this.Major, this.Minor, this.Patch)
 * }
 */
class AquaHotkey_Hash extends AquaHotkey
{
    ;@region Support

    /**
     * FNV offset base.
     * @type {Integer}
     */
    static Offset => 0xCBF29CE484222325

    /**
     * FNV prime.
     * @type {Integer}
     */
    static Prime => 0x00000100000001B3

    ; TODO make this imperative?
    ; static Step(&Current, Value) ...

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Any

    class Any {
        /**
         * Unsupported `.HashCode()` function.
         * @returns {Integer}
         */
        HashCode() {
            throw TypeError("not applicable for this type " . Type(this))
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Array

    class Array {
        /**
         * Creates a hash from all elements in this array. Elements are
         * allowed to be `unset`.
         * 
         * @returns {Integer}
         */
        HashCode() {
            static Offset := AquaHotkey_Hash.Offset
            static Prime  := AquaHotkey_Hash.Prime

            Result := Offset
            for Value in this {
                Result ^= (IsSet(Value) && Value.HashCode())
                Result *= Prime
            }
            return Result
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Map

    class Map {
        /**
         * Creates a hash from all key-value pairs in this map.
         * Key-value pairs in the map are not allowed to have `unset` values.
         * 
         * @returns {Integer}
         */
        HashCode() {
            static Offset := AquaHotkey_Hash.Offset
            static Prime  := AquaHotkey_Hash.Prime

            Result := Offset
            for Key, Value in this {
                Result := (Result ^   Key.HashCode()) * Prime
                Result := (Result ^ Value.HashCode()) * Prime
            }
            return Result
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region String

    class String {
        /**
         * Creates a hash value from all characters in this string.
         * The result hash value is case-sensitive.
         * 
         * @returns {Integer}
         */
        HashCode() {
            static Offset := AquaHotkey_Hash.Offset
            static Prime  := AquaHotkey_Hash.Prime

            Result := Offset
            Loop Parse, this {
                Result := (Result ^ Ord(A_LoopField)) * Prime
            }
            return Result
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Float

    class Float {
        /**
         * Creates a hash by reinterpreting the bits of this float as a
         * 64-bit signed integer.
         * 
         * @returns {Integer}
         */
        HashCode() {
            static Buf := Buffer(8)
            NumPut("Double", this, Buf)
            return NumGet(Buf, 0, "Int64")
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Integer

    class Integer {
        /**
         * Creates a hash by returning this integer.
         * 
         * @returns {Integer}
         */
        HashCode() => this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Object

    class Object {
        /**
         * Creates a hash from all properties of this object.
         * 
         * Property names are case-insensitive. In other words, `{ foo: "bar" }`
         * and `{ FOO: "bar" }` produce the same hash code.
         * 
         * If `A.HashCode() == B.HashCode()`, then it's extremely likely - but
         * NOT guaranteed - that `A.Eq(B)`. The same applies vice-versa.
         * 
         * @returns {Integer}
         */
        HashCode() {
            static GetProp := ({}.GetOwnPropDesc)
            static Offset  := AquaHotkey_Hash.Offset
            static Prime   := AquaHotkey_Hash.Prime

            Obj := this
            Result := Offset
            loop {
                for PropertyName in ObjOwnProps(Obj) {
                    loop parse, StrLower(PropertyName) {
                        Result ^= Ord(A_LoopField)
                        Result *= Prime
                    }
                    PropDesc := GetProp(Obj, PropertyName)
                    Value := ObjHasOwnProp(PropDesc, "Value")
                        ? PropDesc.Value
                        : unset

                    Result ^= (IsSet(Value) && Value.HashCode())
                    Result *= Prime
                }
                Obj := ObjGetBase(Obj)
            } until (!Obj)
            return Result
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region ByReference

    class ByReference extends AquaHotkey_MultiApply {
        static __New() => super.__New(
            Buffer, Class, Error, File, Func, Gui, Gui.Control,
            InputHook, Menu, MenuBar, RegExMatchInfo)

        /**
         * Returns a hash value based on the object pointer.
         * 
         * @returns {Integer}
         * @example
         * Class.HashCode() ; for example: 10185408
         */
        HashCode() => ObjPtr(this)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Class

    class Class {
        /**
         * Returns a type-checked `.Hash()` method.
         * 
         * @returns {Func}
         * @example
         * ObjHash := Object.Hash
         * ObjHash("Str") ; Error! Expected an Object.
         */
        Hash => ObjBindMethod(this, "Hash")

        /**
         * Returns the hash code for zero or more values.
         * 
         * This method is type-checked, depending on the calling class. For
         * example:
         * 
         * @param   {Any*}  Values  zero or more values
         * @returns {Integer}
         * @example
         * Integer.Hash(1, 2435, 123, "foo") ; Error! Expected an Integer.
         */
        Hash(Values*) {
            static Offset := AquaHotkey_Hash.Offset
            static Prime  := AquaHotkey_Hash.Prime

            Result := Offset
            for Value in Values {
                if (!(Value is this)) {
                    throw TypeError("Expected a(n) " . this.Prototype.__Class,,
                                    Type(Value))
                }

                Result ^= (IsSet(Value) && Value.HashCode())
                Result *= Prime
            }
            return Result
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region ComValue

    class ComValue {
        /**
         * Creates a hash based on the VARIANT type and the wrapped value.
         * 
         * @returns {Integer}
         */
        HashCode() => Integer.Hash(ComObjType(this), ComObjValue(this))
    }

    ;@endregion
}
