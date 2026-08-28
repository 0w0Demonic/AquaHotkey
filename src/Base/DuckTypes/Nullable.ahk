#Include "%A_LineFile%\..\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\..\Core\Utils.ahk"
#Include "%A_LineFile%\..\..\..\Base\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\..\Base\Eq.ahk"
#Include "%A_LineFile%\..\..\..\Base\Hash.ahk"

;@region Nullable

/**
 * @duck
 * 
 * A {@link AquaHotkey_DuckTypes duck type} that wraps an existing type
 * -- the *inner type* -- and allows it to be `unset`.
 * 
 * This class must not be subclassed.
 * 
 * @module  <Base/DuckTypes/Nullable>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @template T the inner type
 * @example
 * MaybeStr := Nullable(String)
 * 
 * MaybeStr.IsInstance(unset) ; ==> true
 * MaybeStr.IsInstance("Str") ; ==> true
 * MaybeStr.IsInstance(342.1) ; ==> false
 */
class Nullable extends Class
{
    ;@region Support

    ; (evil hacks)
    ; `extends Class` allows us to use methods such as `[]` (`Array.OfType()`).
    ; 
    ; Because an instance of `Nullable` is now expected to be a class, it's
    ; also expected to have a `Prototype`, but right now it doesn't; So let's
    ; fix that. Just reuse the existing prototype defined here. Circular ref
    ; doesn't matter here.
    static Prototype.Prototype := this.Prototype

    ; paranoia: don't let anyone mess around with this class
    static __New() {
        if (this != Nullable) {
            throw ValueError("This class must not be extended")
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Construction

    /**
     * Creates a new nullable type with the given inner type.
     * 
     * @constructor
     * @param   {T}  T  inner type of the nullable
     * @returns {Nullable<T>}
     */
    static Call(T) {
        return (T is this) ? T ; Nullable<Nullable<T>> is just Nullable<T>
            : DefineProp({ base: this.Prototype }, "T", { Get: (_) => T })
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Commons

    /**
     * Determines whether this nullable is equal to the other nullable.
     * Returns true, if `Val` is a nullable and the inner types of both `this`
     * and `Val` are equal.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     */
    Eq(Val?) {
        if (!IsSet(Val)) {
            return false
        }
        if (this == Val) {
            return true
        }
        return (Val is Nullable) && (this.T).Eq(Val.T)
    }

    /**
     * Determines whether two given values are equal.
     * 
     * Both input values must be {@link AquaHotkey_DuckTypes instance of} the
     * calling class. For example, `Nullable(Array).Equals(A, B)` accepts
     * only instances of `Nullable(Array)`.
     * 
     * This method returns `true`, if both input values are unset.
     * 
     * @param   {Any?}  A  value 1
     * @param   {Any?}  B  value 2
     * @returns {Boolean}
     * @see {@link AquaHotkey_Eq}
     * @example
     * Nullable(String).Equals("foo", "bar") ; false
     * Nullable(String).Equals([1, 2], "")   ; TypeError! Expected a String.
     * 
     * ; ==> true
     * ; (`String.Equals()` would've thrown.)
     * Nullable(String).Equals(unset, unset)
     */
    Equals(A?, B?) {
        if (!IsSet(A)) {
            return (!IsSet(B))
        }
        if (!IsSet(B)) {
            return false
        }
        if (!(this.T).IsInstance(A)) {
            throw TypeError("Unexpected argument type: param #1")
        }
        if (!(this.T).IsInstance(B)) {
            throw TypeError("Unexpected argument type: param #2")
        }
        return (A == B) || A.Eq(B)
    }

    /**
     * Returns a hash code for this nullable type.
     * 
     * @returns {Integer}
     */
    HashCode() => Any.Hash(this.T)

    /**
     * Returns a string representation of this nullable type.
     * 
     * @returns {String}
     */
    ToString() => "Nullable<" . String(this.T) . ">"

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Duck Types

    /**
     * Determines whether the given input value is an instance of this nullable
     * type. The input value must be either instance of the inner type, or
     * `unset`.
     * 
     * @param   {Any}  Val  any value
     * @returns {Boolean}
     * @example
     * Nullable(String).IsInstance(unset) ; ==> true
     * Nullable(String).IsInstance("foo") ; ==> true
     * Nullable(String).IsInstance(42)    ; ==> false
     */
    IsInstance(Val?) => (!IsSet(Val)) || this.T.IsInstance(Val)

    /**
     * Determines whether the value is considered equivalent to, or a subtype
     * of `Nullable`. This can be one of the following:
     * 
     * - `unset`
     * - `Nothing`
     * - `class Nullable`
     * - any instance of `Nullable`, e.g. `Nullable(String)`
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * Nullable.CanCastFrom(Nullable) ; ==> true
     * Nullable.CanCastFrom(Nothing) ; ==> true
     * Nullable.CanCastFrom(unset) ; ==> true
     * Nullable.CanCastFrom(Nullable(String)) ; ==> true
     */
    static CanCastFrom(Val?) {
        return (!IsSet(Val)) ; unset
            || (Val == Nothing) ; Nothing
            || (Val == this) ; Nullable
            || (Val is this) ; Nullable(...)
    }

    /**
     * Determines whether the value is equivalent to, or a subtype of this
     * nullable. A non-nullable type is a subtype of its nullable equivalent,
     * i.e. `Nullable(A).CanCastFrom(A)` for every `A`.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * Nullable(Number).CanCastFrom(Nullable(Integer)) ; ==> true
     * 
     * Nullable(Number).CanCastFrom(Number) ; ==> true
     * Number.CanCastFrom(Nullable(Number)) ; ==> false
     * 
     * Nullable(Number).CanCastFrom(Integer) ; ==> true
     */
    CanCastFrom(Val?) {
        if (!IsSet(Val) || (Val == Nothing)) {
            return true
        }
        if (Val is Nullable) {
            return (this.T).CanCastFrom(Val.T)
        }
        return (this.T).CanCastFrom(Val)
    }

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

/**
 * Support for {@link Json} deserialization.
 */
class AquaHotkey_Nullable_Json extends AquaHotkey {
    static __New() => IsSet(AquaHotkey_Json) && super.__New()

    class Nullable {
        /**
         * Casts the JSON value into this nullable type.
         * 
         * @param   {VarRef<Any>}  Val  any value
         */
        CastFromJson(&Val) {
            IsSet(Json)
            if (Val == Json.Null) {
                Val := unset
            } else {
                (this.T).CastFromJson(&Val)
            }
        }
    }
}

/**
 * Binary serialization support for {@link Nullable}.
 */
class AquaHotkey_Nullable_Serialization extends AquaHotkey {
    static __New() => IsSet(AquaHotkey_Serializer) && super.__New()

    class Nullable {
        /**
         * Serializes this nullable type into binary.
         * 
         * @param   {OutputStream}  Output  output stream
         * @param   {Map}           Refs    map of previously seen objects
         * @see {@link AquaHotkey_Serializer}
         */
        Serialize(Output, Refs) {
            (Object.Prototype.Serialize)(this, Output, Refs)
            Output.WriteObject(this.T, Refs)
        }

        /**
         * Reconstructs this nullable type from binary.
         * 
         * @param   {InputStream}  Input  input stream
         * @param   {Map}          Refs   map of previously seen objects
         * @see {@link AquaHotkey_Serializer}
         */
        Deserialize(Input, Refs) {
            Input.ReadObject(&T, Refs)
            DefineProp(this, "T", { Get: (_) => T })
        }
    }
}
