#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Adds a universal `.Hash()` function.
 * 
 * In general, this class uses FNV-1a to create hashes.
 * 
 * @module  <Base/Hash>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
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
    static Prime  => 0x00000100000001B3

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Array

    class Array {
        /**
         * Creates a hash from all elements in this array.
         * 
         * @returns {Integer}
         */
        Hash() {
            static Offset := AquaHotkey_Hash.Offset
            static Prime  := AquaHotkey_Hash.Prime

            Result := Offset
            for Value in this {
                Result ^= (IsSet(Value) && Value.Hash())
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
         * 
         * @returns {Integer}
         */
        Hash() {
            static Offset := AquaHotkey_Hash.Offset
            static Prime  := AquaHotkey_Hash.Prime

            Result := Offset
            for Key, Value in this {
                Result := (Result ^   Key.Hash()) * Prime
                Result := (Result ^ Value.Hash()) * Prime
            }
            return Result
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region String

    class String {
        /**
         * Creates a hash from all characters in this string.
         * 
         * @returns {Integer}
         */
        Hash() {
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
        Hash() {
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
        Hash() => this
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
         * If `A.Hash() == B.Hash()`, then it's extremely likely - but NOT
         * guaranteed - that `A.Eq(B)`. The same applies vice-versa.
         * 
         * @returns {Integer}
         */
        Hash() {
            static Offset := AquaHotkey_Hash.Offset
            static Prime  := AquaHotkey_Hash.Prime

            Result := Offset
            Loop {
                for PropertyName, Value in ObjOwnProps(this) {
                    ; use lowercase to make properties case-insensitive
                    Loop Parse, StrLower(PropertyName) {
                        Result ^= Ord(A_LoopField)
                        Result *= Prime
                    }

                    Result ^= (!IsSet(Value) && Value.Hash())
                    Result *= Prime
                }

                if (this == Any.Prototype) {
                    return Result
                }
                this := ObjGetBase(this)
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Any

    class Any {
        /**
         * Returns a type-checked `.Hash()` method.
         * 
         * @example
         * ObjHash := Object.Hash
         * 
         * ObjHash("Str") ; Error! Expected an Object.
         * 
         * @returns {Func}
         */
        static Hash => ObjBindMethod(this, "Hash")

        /**
         * Returns the hash code for zero or more values.
         * 
         * This method is type-checked, depending on the calling class. For
         * example:
         * 
         * @example
         * Integer.Hash(1, 2435, 123, "foo") ; Error! Expected a(n) Integer
         * 
         * @param   {Any*}  Values  zero or more values
         * @returns {Integer}
         */
        static Hash(Values*) {
            static Offset := AquaHotkey_Hash.Offset
            static Prime  := AquaHotkey_Hash.Prime

            Result := Offset
            for Value in Values {
                if (!(Value is this)) {
                    throw TypeError("Expected a(n) " . this.Prototype.__Class,,
                                    Type(Value))
                }

                Result ^= (IsSet(Value) && Value.Hash())
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
        Hash() => ComValue.Hash(ComObjType(this), ComObjValue(this))
    }

    ;@endregion
}
