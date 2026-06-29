#Include "%A_LineFile%\..\..\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\Eq.ahk"
#Include "%A_LineFile%\..\..\Hash.ahk"

/**
 * @duck
 * 
 * A duck type wrapper which allows matching both `unset` and values of
 * an inner type. While {@link Optional} is used for wrapping values, the
 * nullable class is meant to be used for creating *type predicates*.
 * 
 * @module  <Base/DuckTypes/Nullable>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @template T the inner type
 * @example
 * MaybeStr := Nullable(String)
 * 
 * MaybeStr.IsInstance(unset) ; true
 * MaybeStr.IsInstance("Str") ; true
 * MaybeStr.IsInstance(342.1) ; false
 */
class Nullable extends Class
{
    ; (evil hacks)
    ; `extends Class` allows us to use methods such as `[]` (`Array.OfType()`).
    ; 
    ; Because instance of `Nullable` are now expected to be classes, they're
    ; expected to have a `Prototype`, but right now they don't; So let's fix
    ; that. Just reuse the existing prototype defined here.
    static Prototype.Prototype := this.Prototype
    ; TODO find out if this breaks anything

    ;@region Construction

    /**
     * Creates a new nullable type with the given inner type.
     * 
     * @constructor
     * @param   {Any}  T  inner type of the nullable
     * @returns {Nullable<T>}
     */
    static Call(T) {
        if (T is this) { ; Nullable<Nullable<T>> is just Nullable<T>
            return T
        }
        Obj := Object()
        Obj.DefineProp("T", { Get: (_) => T })
        ObjSetBase(Obj, this.Prototype)
        return Obj
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Commons

    /**
     * Determines whether this nullable is equal to the other nullable.
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
    ;@region Serialization

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
        this.DefineProp("T", { Get: (_) => T })
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Duck Types

    ; TODO need to add `static` versions for just `.Is(Nullable)`?

    /**
     * Determines whether the value is considered instance of this nullable
     * type.
     * 
     * @param   {Any}  Val  any value
     * @returns {Boolean}
     * @example
     * Nullable(String).IsInstance(unset) ; true
     * Nullable(Number).IsInstance("foo") ; false
     */
    IsInstance(Val?) => (!IsSet(Val)) || this.T.IsInstance(Val)

    /**
     * Determines whether the value is compatible with this nullable type.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
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

    /**
     * Returns a type-checked 2-parameter equality function for this class.
     * 
     * The function supports `unset` values.
     * 
     * @returns {Func}
     * @example
     * Eq := Optional(Map).Equals
     * 
     * Eq(Map(1, 2), Map(1, 2)) ; true
     * Eq("foo", "bar")         ; TypeError! Expected a Map.
     * 
     * ; ==> true
     * ; (`Map.Equals()` would've thrown)
     * Eq(unset, unset)
     */
    Equals => ObjBindMethod(this, "Equals")

    /**
     * Determines whether two given values are equal.
     * 
     * Both inputs are asserted to be *instances* of the calling class.
     * For example, `Array.Equals(A, B)` will assert that `A is Array` and
     * `B is Array`.
     * 
     * This method supports `unset` values. `unset == unset` is evaluated to
     * `true`.
     * 
     * @param   {Any?}  A  value 1
     * @param   {Any?}  B  value 2
     * @returns {Boolean}
     * @see {@link AquaHotkey_Eq}
     * @example
     * Optional(String).Equals("foo", "bar") ; false
     * Optional(String).Equals([1, 2], "")   ; TypeError! Expected a String.
     * 
     * ; ==> true
     * ; (`String.Equals()` would've thrown.)
     * Optional(String).Equals(unset, unset)
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

    ;@endregion
}
