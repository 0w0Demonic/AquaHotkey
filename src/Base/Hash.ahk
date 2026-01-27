#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Adds a universal `.HashCode()` function on which collections like
 * {@link HashMap} and {@link HashSet} rely on.
 * 
 * For consistency, the `.HashCode()` function must adhere to the following
 * rules:
 * 
 * - The result of `.HashCode()` must not change, unless the values change
 * - If two values are equal ({@link AquaHotkey_Eq `.Eq()`}), they must produce the
 *   same hash code.
 * 
 * `Any.Hash()` can be used for conveniently creating a hash code from
 * multiple values.
 * @module  <Base/Hash>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @see {@link HashMap}
 * @see {@link HashSet}
 * @see {@link https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function#FNV-1a_hash FNV-1a}
 * @see {@link AquaHotkey_Eq `.Eq()`}
 * @example
 * class Version {
 *     __New(Major, Minor, Patch) {
 *         this.Major := Major
 *         this.Minor := Minor
 *         this.Patch := Patch
 *     }
 *     HashCode() => Any.Hash(this.Major, this.Minor, this.Patch)
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
         * @example
         * Integer.Hash(1, 2435, 123, "foo") ; Error! Expected an Integer.
         * 
         * @param   {Any*}  Values  zero or more values
         * @returns {Integer}
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
        HashCode() => ComValue.Hash(ComObjType(this), ComObjValue(this))
    }

    ;@endregion
}
