#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

; TODO replace entire thing with `Should` similar to FluentAssertions?

/**
 * Provides a wide range of chainable assertion methods.
 * 
 * @module  <Base/Assertions>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class AquaHotkey_Assertions extends AquaHotkey
{
;-------------------------------------------------------------------------------
;@region Any

class Any {
    /**
     * Asserts that the given `Condition` is true for the value. Otherwise,
     * throws an error.
     * 
     * @param   {Func}  Condition  the condition to assert
     * @returns {this}
     * @example
     * MyVariable.Assert(IsNumber)
     */
    Assert(Condition) {
        if (Condition(this)) {
            return this
        }
        throw ValueError("failed assertion", -2)
    }
    
    ; TODO integrate with `AquaHotkey_Eq?`

    /**
     * Asserts that this variable is derived from class `T`. Otherwise, a
     * `TypeError` is thrown.
     * 
     * @param   {Class}  T  expected type
     * @returns {this}
     * @example
     * MyVariable.AssertType(String)
     */
    AssertType(T) {
        if (this is T) {
            return this
        }
        throw TypeError("expected type " . T.Name, -2, Type(this))
    }

    ; TODO integrate with `AquaHotkey_Eq?`
    /**
     * Asserts that this variable is case-insensitive equal to `Other`.
     * Otherwise, a `ValueError` is thrown.
     * 
     * @param   {Any}  Other  expected value
     * @returns {this}
     * @example
     * Str.AssertEquals("foo")
     */
    AssertEquals(Other) {
        if (this = Other) {
            return this
        }
        throw ValueError("value is not equal to " . ToString(&Other), -2,
                         ToString(&this))

        static ToString(&Value) {
            try return String(Value)
            return Type(Value)
        }
    }

    /**
     * Asserts that this variable is case-sensitive equal to `Other`. Otherwise,
     * a `ValueError` is thrown.
     * 
     * @param   {Any}  Other  expected value
     * @returns {this}
     * @example
     * Str.AssertCsEquals("foo")
     */
    AssertCsEquals(Other) {
        if (this == Other) {
            return this
        }
        throw ValueError("value is not equal to " . ToString(&Other), -2,
                         ToString(&this))

        static ToString(&Value) {
            try return String(Value)
            return Type(Value)
        }
    }

    /**
     * Asserts that this variable is not case-insensitive equal to `Other`.
     * Otherwise, a `ValueError` is thrown.
 
     * @param   {Any}  Other  unexpected value
     * @returns {this}
     * @example
     * Str.AssertNotEquals("foo")
     */
    AssertNotEquals(Other) {
        if (this != Other) {
            return this
        }
        throw ValueError("value is equal to " . ToString(&Other), -2,
                         ToString(&this))
        
        static ToString(&Value) {
            try return String(Value)
            return Type(Value)
        }
    }
    
    /**
     * Asserts that this variable is not case-sensitive equal to `Other`.
     * Otherwise, a `ValueError` is thrown.
     * 
     * @param   {Any}  Other  unexpected value
     * @returns {this}
     * @example
     * Str.AssertCsNotEquals("foo")
     */
    AssertCsNotEquals(Other) {
        if (this !== Other) {
            return this
        }

        throw ValueError("value is equal to " . ToString(&Other), -2,
                         ToString(&this))
        
        static ToString(&Value) {
            try return String(Value)
            return Type(Value)
        }
    }

    /**
     * Asserts that this variable has a property by the given name, otherwise
     * throws a `PropertyError`.
     * 
     * @param   {String}  PropName  name of the property
     * @returns {this}
     * @example
     * { foo: "bar" }.AssertHasProp("foo")
     */
    AssertHasProp(PropName) {
        if (HasProp(this, PropName)) {
            return this
        }
        throw PropertyError("value has no property called " . PropName, -2)
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Primitive

class Primitive {
    /**
     * Asserts that this number is greater than `x`. Otherwise, a `ValueError`
     * is thrown.
     * 
     * @param   {Number}  x  any number
     * @returns {this}
     * @example
     * (12.23).AssertGt(5)
     */
    AssertGt(x) {
        if (this > x) {
            return this
        }
        throw ValueError("number is not greater than " . x, -2, this)
    }

    /**
     * Asserts that this number is greater than or equal to `x`. Otherwise, a
     * `ValueError` is thrown.
     * 
     * @example
     * (0).AssertGe(0)
     * 
     * @param   {Number}  x  any number
     * @returns {this}
     */
    AssertGe(x) {
        if (this >= x) {
            return this
        }
        throw ValueError("number is less than " . x, -2, this)
    }

    /**
     * Asserts that this number is less than `x`. Otherwise, a `ValueError` is
     * thrown.
     * 
     * @param   {Number}  x  any number
     * @returns {this}
     * @example
     * (23).AssertLt(65)
     */
    AssertLt(x) {
        if (this < x) {
            return this
        }
        throw ValueError("number is not less than " . x, -2, this)
    }

    /**
     * Asserts that this number is smaller than or equal to `x`. Otherwise,
     * a `ValueError` is thrown.
     * 
     * @param   {Number}  x  any number
     * @returns {this}
     * @example
     * (23).AssertLe(65)
     */
    AssertLe(x) {
        if (this <= x) {
            return this
        }
        throw ValueError("number is greater than " . X, -2, this)
    }

    /**
     * Asserts that this number lies in the inclusive range between `x` and `y`.
     * 
     * @param   {Number}  x  lower limit
     * @param   {Number}  y  upper limit
     * @returns {this}
     * @example
     * (12).AssertInRange(1, 100)
     */
    AssertInRange(x, y) {
        Hi := Max(x, y)
        Lo := Min(x, y)
        if ((this < Lo) || (this > Hi)) {
            throw ValueError("number is not in range " . Lo . " - " . Hi,
                            -2, this)
        }
        return this
    }

    /**
     * Asserts that the string is not empty.
     * 
     * @returns {this}
     */
    AssertNotEmpty() {
        if (this != "") {
            return this
        }
        throw ValueError("empty string", 2)
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Object

class Object {
    /**
     * Asserts that the object owns a property by the given name, otherwise
     * throws a `PropertyError`.
     * 
     * @param   {String}  PropName  name of the property
     * @returns {this}
     * @example
     * { foo: "bar" }.AssertHasOwnProp("foo")
     */
    AssertHasOwnProp(PropName) {
        if (ObjHasOwnProp(this, PropName)) {
            return this
        }
        throw PropertyError("object has no property called " . PropName)
    }
} ; class Object

;@endregion
;-------------------------------------------------------------------------------
} ; class AquaHotkey_Assertions extends AquaHotkey