#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

; TODO static Equals() for duck types
; TODO refactor things to use `Any.Equals` OR custom predicates
; TODO check whether `IArray` or `IMap` is allowed here

/**
 * Adds a universal `.Eq()` method for checking whether two values are
 * equivalent.
 * 
 * ```ahk
 * ; --> true (structural equality)
 * ([1, 2, 3]).Eq([1, 2, 3])
 * 
 * ; --> true (properties are case-insensitive)
 * ({ foo: "bar" }).Eq({ FOO: "bar" })
 * ```
 * 
 * ---
 * 
 * `.Eq()` is a method with one optional parameter `Other` - the
 * value to be compared.
 * 
 * ```ahk
 * Eq(Other?) => Boolean
 * ```
 * 
 * Introducing this polymorphic and semantic equality has some of the
 * following benefits:
 * 
 * - custom equality checks
 * - custom map/set semantics (such as {@link HashMap} and {@link HashSet})
 * - generic "find" and "contains" methods for collections
 * 
 * ---
 * 
 * For consistency, implementations of `.Eq()` should satisfy the following
 * set of rules:
 * 
 * 1. (unset handling) `A.Eq(unset)` is **always** `false`; `unset == unset`
 * 2. (reflexive) `A.Eq(A)` is **always** `true`
 * 3. (symmetric) `A.Eq(B)` must equal `B.Eq(A)`
 * 4. (transitive) if `A.Eq(B)` and `B.Eq(C)`, then `A.Eq(C)`
 * 5. (consistent) the result must not change, unless the values change
 * 
 * ---
 * 
 * **Example: Custom `.Eq() Method`**:
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
 *         ; rule #1: a non-null value can NEVER equal `unset`
 *         if (!IsSet(Other)) {
 *             return false
 *         }
 *         ; rule #2: a value is ALWAYS equal to itself
 *         if (this == Other) {
 *             return true
 *         }
 *         return (this.Major).Eq(Other.Major)
 *             && (this.Minor).Eq(Other.Major)
 *             && (this.Patch).Eq(Other.Patch)
 *     }
 * }
 * ```
 * 
 * ---
 * 
 * To ensure both values are instances of a type `T`, you can use
 * `T.Equals(A?, B?)`. This asserts that the two input values are either
 * `unset`, or an instance of the calling class `T`. It also allows support
 * for `unset`, where `T.Equals(unset, unset)` always equals `true`.
 * 
 * In the example above, the return statement can be rewritten to assert
 * that all three fields are `Integer`s:
 * 
 * ```ahk
 * return Integer.Equals(this.Major, Other.Major)
 *     || Integer.Equals(this.Minor, Other.Minor)
 *     || Integer.Equals(this.Patch, Other.Patch)
 * ```
 * 
 * ---
 * 
 * Because {@link AquaHotkey_DuckTypes duck types} might not necessarily
 * inherit the proper `.Equals()` method, you must implement a custom
 * `static Eq()` for the duck type. These overrides should use
 * {@link AquaHotkey_DuckTypes.Any#Is `.Is()`} for type-checking.
 * 
 * ```ahk
 * ; duck type for any buffer-like object
 * class BufferLike {
 *     static IsInstance(Val?) {
 *         return IsSet(Val) && IsObject(Val)
 *             && HasProp(Val, "Ptr") && HasProp(Val, "Size")
 *     }
 * 
 *     static Equals(A?, B?) {
 *         if (!IsSet(A)) {
 *             return !IsSet(B)
 *         }
 *         if (!IsSet(B)) {
 *             return false
 *         }
 *         if (A.Is(this) && B.Is(this)) { ; `Val.Is(T)` instead of `Val is T`
 *             return (A.Ptr).Eq(B.Ptr)
 *                 && (A.Size).Eq(B.Size)
 *         }
 *         throw TypeError("Expected a " . this.Name,,
 *                         Type(A) . " " . Type(B))
 *     }
 * }
 * ```
 * 
 * @module  <Base/Eq>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @see {@link AquaHotkey_DuckTypes duck types}
 * @see {@link HashMap}
 * @see {@link HashSet}
 * @example
 * ; --> true (object shares the same fields and values)
 * ({ foo: "bar" }).Eq({ FOO: "bar" })
 * 
 * ; --> true (because `unset == unset`)
 * Any.Equals(unset, unset)
 * 
 * ; Error! Expected an Object.
 * Object.Equals(124, 45)
 * 
 * ; function `AquaHotkey_Eq.Map.Equals`
 * MapEquality := Map.Equals
 */
class AquaHotkey_Eq extends AquaHotkey
{
;-------------------------------------------------------------------------------
;@region Any

class Any {
    /**
     * Determines whether this value is equal to the `Other` value.
     * 
     * If not otherwise overridden, two values `A` and `B` are
     * equal, if `A == B`.
     * 
     * In other words, regular (case-sensitive) equality checks are used,
     * unless specified otherwise.
     * 
     * @param   {Any}  Other  any value
     * @returns {Boolean}
     * @example
     * (1).Eq("1") ; true
     * 
     * Obj := {}
     * Obj.Eq(Obj) ; true
     */
    Eq(Other?) => (IsSet(Other) && (this == Other))

    /**
     * Determines whether this value is not equal to the `Other` value.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     * @example
     * "foo".Ne("bar") ; true
     */
    Ne(Other?) => !this.Eq(Other?)
}

;@endregion
;-------------------------------------------------------------------------------
;@region Class

class Class {
    /**
     * Returns a type-checked 2-parameter equality function that supports
     * `unset` values.
     * 
     * @returns {Func}
     * @example
     * Eq := Map.Equals
     * 
     * Eq(Map(1, 2), Map(1, 2)) ; true
     * Eq(unset, unset)         ; true
     * Eq("foo", "bar")         ; TypeError! Expected a Map.
     */
    Equals => ObjBindMethod(this, "Equals")

    /**
     * Determines whether two given values are equal.
     * 
     * Both inputs are asserted to be *instances* of the calling class.
     * For example, `Array.Equals(A, B)` will assert that both `A` and `B`
     * are arrays.
     * 
     * This method supports `unset` values.
     * 
     * @param   {Any?}  A  value 1
     * @param   {Any?}  B  value 2
     * @returns {Boolean}
     * @example
     * String.Equals("foo", "bar") ; false
     * String.Equals(unset, unset) ; true
     * String.Equals([1, 2], "")   ; TypeError! Expected a String.
     */
    Equals(A?, B?) {
        if (!IsSet(A)) {
            return (!IsSet(B))
        }
        if (!IsSet(B)) {
            return false
        }
        if ((A is this) && (B is this)) {
            return (A == B) || A.Eq(B)
        }
        throw TypeError("Expected a(n) " . this.Name,, Type(A) . ", " . Type(B))
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region IArray

class IArray {
    /**
     * Determines whether this array is equal to the `Other` value.
     * 
     * This happens when `this == Other`, or...
     * - `Other` is an array with the same `.Length`;
     * - all elements are equivalent (`Any.Equals` for each index)
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     * @example
     * ([1, 2, 3]).Eq([1, 2, 3]) ; true
     * 
     * ([1]).Eq([1, 2]) ; false
     * 
     * ([1]).Eq("example") ; false
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!Other.Is(IArray)) {
            return false
        }

        if (this.Length != Other.Length) {
            return false
        }
        Enumer1 := this.__Enum(1)
        Enumer2 := Other.__Enum(1)

        while (Enumer1(&A) && Enumer2(&B)) {
            if (!IsSet(A)) {
                if (IsSet(B)) {
                    return false
                }
                continue
            }
            if (!IsSet(B)) {
                return false
            }
            if (!A.Eq(B)) {
                return false
            }
        }
        return true
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Object

class Object {
    /**
     * Determines whether this object is equal to the `Other` object.
     * 
     * This happens when `this == Other`, or...
     * 
     * - `ObjGetBase(this) == ObjGetBase(Other)`
     * - `this` and `Other` share the same set of properties (case-insensitive)
     * - the values of each field (properties with `Value` descriptor) are
     *   equal, as determined by `Any.Equals()`
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     * @example
     * ; --> true (because of case-insensitive properties)
     * ({ foo: "bar" }).Eq({ FOO: "BAR" })
     */
    Eq(Other?) {
        static GetProp := ({}.GetOwnPropDesc)

        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!IsObject(Other)) {
            return false
        }
        if (ObjGetBase(this) != ObjGetBase(Other)) {
            return false
        }
        
        if (ObjOwnPropCount(this) != ObjOwnPropCount(Other)) {
            return false
        }

        ThisEnumer := ObjOwnProps(this)
        OtherEnumer := ObjOwnProps(Other)

        while (ThisEnumer(&ThisProp) && OtherEnumer(&OtherProp)) {
            if (ThisProp != OtherProp) {
                return false
            }
            ; value of this object prop
            PropDesc := GetProp(this, ThisProp)
            ThisValue := (ObjHasOwnProp(PropDesc, "Value"))
                    ? PropDesc.Value
                    : unset
            
            ; value of other object prop
            PropDesc := GetProp(Other, OtherProp)
            OtherValue := (ObjHasOwnProp(PropDesc, "Value"))
                    ? PropDesc.Value
                    : unset

            if (!IsSet(ThisValue)) {
                if (IsSet(OtherValue)) {
                    return false
                }
                ; both are `unset`
                continue
            }
            if (!IsSet(OtherValue) || !ThisValue.Eq(OtherValue)) {
                return false
            }
        }
        return true
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Reference Equality

class ByReference extends AquaHotkey_MultiApply {
    static __New() => super.__New(
        Buffer, Class, Error, File, Func, Gui, Gui.Control,
        InputHook, Menu, MenuBar, RegExMatchInfo, ComObjArray)

    /**
     * Determines whether this value is equal to the `Other` value according
     * to object reference.
     * 
     * This happens if both values share the same reference.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     */
    Eq(Other?) => (IsSet(Other) && (this == Other))
}

;@endregion
;-------------------------------------------------------------------------------
;@region Map

class Map {
    /**
     * Determines whether this `Map` is equal to the `Other` value.
     * 
     * This happens when `Other` is a map that shares the same set of key-value
     * pairs.
     * 
     * Key-value pairs are not allowed to contain `unset`.
     * 
     * @param   {Any*}  Other  any value
     * @returns {Boolean}
     * @example
     * Map(1, 2, 3, 4).Eq(Map(1, 2, 3, 4)) ; true
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!(Other is Map)) {
            return false
        }
        if (this.Count != Other.Count) {
            return false
        }

        for Key, Value in this {
            if (!Other.Has(Key) || !Other.Get(Key).Eq(Value)) {
                return false
            }
        }
        return true
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region VarRef

class VarRef {
    /**
     * Determines whether this `VarRef` equals to the `Other` value.
     * 
     * This happens when `this == Other`, or when `Other` is also a `VarRef`
     * and the underlying values are equal.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     * @example
     * A := &(StrA := "foo")
     * B := &(StrB := "foo")
     * 
     * MsgBox(A.Eq(B)) ; true
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!(Other is VarRef)) {
            return false
        }
        if (IsSetRef(this)) {
            return IsSetRef(Other) && (%this%.Eq(%Other%))
        }
        return !IsSetRef(Other)
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region ComValue

class ComValue {
    /**
     * Determines whether this `ComValue` is equal to the `Other` value.
     * 
     * This happens when the underlying value and `VARIANT` type are equal.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     * @example
     * ( ComValue(0x08, true) ).Eq( ComValue(0x08, true) ) ; true
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!(Other is ComValue)) {
            return false
        }
        return (ComObjValue(this) == ComObjValue(Other))
            && (ComObjType(this) == ComObjType(Other))
    }
}

;@endregion
} ; class AquaHotkey_Eq extends AquaHotkey