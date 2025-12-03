#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Adds a universal `.Eq` property for checking whether two values are
 * equivalent.
 * 
 * In general:
 * 
 * 1. `A.Eq(A)` is always `true` (also `unset.Eq(unset)`)
 * 2. if `A.Eq(B)`, then `B.Eq(A)`
 * 3. if `A.Eq(B)` and `B.Eq(C)`, then `A.Eq(C)`
 * 4. `A.Eq(unset)` is `false`, unless `!IsSet(A)`
 * 5. `A.Eq(B)` should **consistently** return either `true` or `false` when
 *    neither values are being changed.
 * 
 * @module  <Base/Eq>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Eq extends AquaHotkey
{
;-------------------------------------------------------------------------------
;@region Any

class Any {
    /**
     * Determines whether this value is equal to the `Other` value.
     * 
     * If not otherwise overridden, two values `A` and `B` are equal, if...
     * 
     * ```ahk
     * (A = B)
     * ```
     * 
     * @example
     * (1).Eq("1") ; true
     * 
     * Obj := {}
     * Obj.Eq(Obj) ; true
     * 
     * @param   {Any}  Other  any value
     * @returns {Boolean}
     */
    Eq(Other?) => (IsSet(Other) && (this = Other))

    /**
     * Returns a type-checked `.Eq()` method.
     * 
     * This method is type-checked, depending on the calling class. For example:
     * 
     * @example
     * NumberEq := Number.Eq
     * 
     * NumberEq(1, 1)         ; true
     * NumberEq("foo", "bar") ; Error! expected a(n) Integer
     * 
     * @returns {Func}
     */
    static Eq => ObjBindMethod(this, "Eq")

    /**
     * Determines whether two values `A` and `B` are equal.
     * 
     * This method returns `true` whenever...
     * 
     * 1. `A` and `B` are both `unset`
     * 2. `A.Eq(B)`
     * 
     * @example
     * Any.Eq("a", "a")     ; true
     * Any.Eq(unset, unset) ; true
     * Any.Eq(1, unset)     ; false
     * 
     * @param   {Any?}  A  first value
     * @param   {Any?}  B  second value
     * @returns {Boolean}
     */
    static Eq(A?, B?) {
        if (!IsSet(A)) {
            return !IsSet(B)
        }
        if (!(A is this)) {
            throw TypeError("Expected a(n) " . this.Prototype.__Class,,
                            Type(A))
        }
        if (!IsSet(B)) {
            return false
        }
        if (!(B is this)) {
            throw TypeError("Expected a(n) " . this.Prototype.__Class,,
                            Type(B))
        }
        return A.Eq(B)
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Array

class Array {
    /**
     * Determines whether this array is equal to the `Other` value.
     * 
     * This happens when...
     * 
     * - `Other` is an array with the same length;
     * - Elements in this array are equal to elements in `Other` (`.Eq()`).
     * 
     * @example
     * ([1, 2, 3]).Eq([1, 2, 3]) ; true
     * 
     * ([1]).Eq([1, 2]) ; false
     * 
     * ([1]).Eq("example") ; false
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!(Other is Array)) {
            return false
        }
        if (this.Length != Other.Length) {
            return false
        }

        ThisEnumer := this.__Enum(1)
        OtherEnumer := Other.__Enum(1)

        while (ThisEnumer(&A) && OtherEnumer(&B)) {
            if (!Any.Eq(A?, B?)) {
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
     * - `IsObject(Other)`;
     * - `this` and `Other` share the same set of properties;
     * - The value of these properties is equal. More specifically, the property
     *   descriptor's `Value`.
     * 
     * Depending on the size of the object, this method is relatively expensive.
     * 
     * @example
     * Obj1 := { Foo: "bar" }
     * Obj2 := { Foo: "bar" }
     * 
     * MsgBox(Obj1 == Obj2) ; false
     * Obj1.Eq(Obj2)        ; true
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!IsObject(Other)) {
            return false
        }

        ThisObj := this
        Checked := Map()
        Checked.CaseSense := false

        loop {
            OtherObj := Other
            for PropertyName in ObjOwnProps(ThisObj) {
                if (Checked.Has(PropertyName)) {
                    continue
                }
                if (!HasProp(OtherObj, PropertyName)) {
                    return false
                }

                ; value of this property
                PropDesc := ({}.GetOwnPropDesc)(ThisObj, PropertyName)
                if (ObjHasOwnProp(PropDesc, "Value")) {
                    ThisValue := PropDesc.Value
                } else if (ObjHasOwnProp(PropDesc, "Get")) {
                    try ThisValue := (PropDesc.Get)(this)
                }

                ; value of other property
                while (!ObjHasOwnProp(OtherObj, PropertyName)) {
                    OtherObj := ObjGetBase(OtherObj)
                }
                PropDesc := ({}.GetOwnPropDesc)(OtherObj, PropertyName)
                if (ObjHasOwnProp(PropDesc, "Value")) {
                    OtherValue := PropDesc.Value
                } else if (ObjHasOwnProp(PropDesc, "Get")) {
                    try OtherValue := (PropDesc.Get)(Other)
                }

                ; equality check
                if (!Any.Eq(ThisValue?, OtherValue?)) {
                    return false
                }

                Checked.Set(PropertyName, true)
            }
            
            if (ThisObj == Any.Prototype) {
                break
            }
            ThisObj := ObjGetBase(ThisObj)
        }

        ; check whether `Other` has properties which are absent in `this`
        OtherObj := Other
        loop {
            for PropertyName in ObjOwnProps(OtherObj) {
                if (Checked.Has(PropertyName)) {
                    continue
                }
                if (!HasProp(this, PropertyName)) {
                    return false
                }
                Checked.Set(PropertyName, true)
            }

            if (OtherObj == Any.Prototype) {
                return true
            }
            OtherObj := ObjGetBase(OtherObj)
        }

        return true
    }
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
     * @example
     * Map(1, 2, 3, 4).Eq(Map(1, 2, 3, 4)) ; true
     * 
     * @param   {Any*}  Other  any value
     * @returns {Boolean}
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
     * This happens when `Other` is also a `VarRef` and the underlying values
     * are equal.
     * 
     * @example
     * A := &(StrA := "foo")
     * B := &(StrB := "foo")
     * 
     * MsgBox(A.Eq(B)) ; true
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
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
     * @example
     * ComValue(0xB, true).Eq(ComValue(0xB, true))
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