class AquaHotkey_Assertions extends AquaHotkey {
class Any {
    /**
     * Asserts that the given `Condition` is true for the value. Otherwise,
     * throws an error.
     * 
     * @example
     * MyVariable.Assert(IsNumber, "Not a number")
     * 
     * @param   {Func}     Condition  the condition to assert
     * @param   {String?}  Msg        custom error message
     * @returns {this}
     */
    Assert(Condition, Msg?) {
        if (Condition(this)) {
            return this
        }
        throw ValueError(Msg ?? "failed assertion")
    }
    
    /**
     * Asserts that this variable is derived from class `T`. Otherwise, a
     * `TypeError` is thrown with the error message `Msg`.
     * 
     * @example
     * MyVariable.AssertType(String, "this variable is not a string")
     * 
     * @param   {Class}    T    expected type
     * @param   {String?}  Msg  custom error message
     * @returns {this}
     */
    AssertType(T, Msg?) {
        if (this is T) {
            return this
        }
        throw TypeError(Msg ?? "expected variable to be type "
                      . T.Prototype.__Class,,
                        Type(this))
    }

    /**
     * Asserts that this variable is case-insensitive equal to `Other`.
     * Otherwise, a `ValueError` is thrown with the error message `Msg`.
     * 
     * @example
     * Str.AssertEquals("foo", 'this string is not equal to "foo"')
     * 
     * @param   {Any}      Other  expected value
     * @param   {String?}  Msg    custom error message
     * @returns {this}
     */
    AssertEquals(Other, Msg?) {
        if (this = Other) {
            return this
        }
        throw ValueError(Msg ?? "value is not equal to " . ToString(&Other),,
                         ToString(&this))

        static ToString(&Value) {
            try return String(Value)
            return Type(Value)
        }
    }

    /**
     * Asserts that this variable is case-sensitive equal to `Other`. Otherwise,
     * a `ValueError` is thrown with the error message `Msg`.
     * 
     * @example
     * Str.AssertStrictEquals("foo", 'this string is not equal to "foo"')
     * 
     * @param   {Any}      Other  expected value
     * @param   {String?}  Msg    custom error message
     * @returns {this}
     */
    AssertStrictEquals(Other) {
        if (this == Other) {
            return this
        }
        throw ValueError(Msg ?? "value is not equal to " . ToString(&Other),,
                         ToString(&this))

        static ToString(&Value) {
            try return String(Value)
            return Type(Value)
        }
    }

    /**
     * Asserts that this variable is not case-insensitive equal to `Other`.
     * Otherwise, a `ValueError` is thrown with the error message `Msg`.
 
     * @example
     * Str.AssertNotEquals("foo", 'this string is equal to "foo"')
     * 
     * @param   {Any}      Other  unexpected value
     * @param   {String?}  Msg    custom error message
     * @returns {this}
     */
    AssertNotEquals(Other, Msg?) {
        if (this != Other) {
            return this
        }
        throw ValueError(Msg ?? "value is equal to " . ToString(&Other),,
                         ToString(&this))
        
        static ToString(&Value) {
            try return String(Value)
            return Type(Value)
        }
    }
    
    /**
     * Asserts that this variable is not case-sensitive equal to `Other`.
     * Otherwise, a `ValueError` is thrown with the error message `Msg`.
     * 
     * @example
     * Str.AssertStrictNotEquals("foo", 'this string is equal to "foo"')
     * 
     * @param   {Any}      Other  unexpected value
     * @param   {String?}  Msg    custom error message
     * @returns {this}
     */
    AssertStrictNotEquals(Other, Msg?) {
        if (this !== Other) {
            return this
        }

        throw ValueError(Msg ?? "value is equal to " . ToString(&Other),,
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
     * @param   {String}   PropName  name of the property
     * @param   {String?}  Msg       custom error message
     * @returns {this}
     */
    AssertHasProp(PropName, Msg?) {
        if (HasProp(this, PropName)) {
            return this
        }
        throw PropertyError(Msg ?? "object has no property called " . PropName)
    }
}

class Number {
    /**
     * Asserts that this number is greater than `x`. Otherwise, a `ValueError`
     * is thrown with the error message `Msg`.
     * 
     * @example
     * (12.23).AssertGreater(5, "number is not greater than 5")
     * 
     * @param   {Number}   x    any number
     * @param   {String?}  Msg  error message
     * @returns {this}
     */
    AssertGreater(x, Msg?) {
        if (this > x) {
            return this
        }
        throw ValueError(Msg ?? "number is not greater than " . x,, this)
    }

    /**
     * Asserts that this number is greater than or equal to `x`. Otherwise, a
     * `ValueError` is thrown with the error message `Msg`.
     * 
     * @example
     * (0).AssertGreaterOrEqual(0, "number is less than 0")
     * 
     * @param   {Number}   x    any number
     * @param   {String?}  Msg  error message
     * @returns {this}
     */
    AssertGreaterOrEqual(x, Msg?) {
        if (this >= x) {
            return this
        }
        throw ValueError(Msg ?? "number is less than " . x,, this)
    }

    /**
     * Asserts that this number is less than `x`. Otherwise, a `ValueError` is
     * thrown with the error message `Msg`.
     * 
     * @example
     * (23).AssertLess(65, "number is not less than 65")
     * 
     * @param   {Number}   x    any number
     * @param   {String?}  Msg  error message
     * @returns {this}
     */
    AssertLess(x, Msg?) {
        if (this < x) {
            return this
        }
        throw ValueError(Msg ?? "number is not less than " . x,, this)
    }

    /**
     * Asserts that this number is smaller than or equal to `x`. Otherwise,
     * a `ValueError` is thrown with the error message `Msg`.
     * 
     * @example
     * (23).AssertLessOrEqual(65, "number is greater than 65")
     * 
     * @param   {Number}   x    any number
     * @param   {String?}  Msg  error message
     * @returns {this}
     */
    AssertLessOrEqual(x, Msg?) {
        if (this <= x) {
            return this
        }
        throw ValueError(Msg ?? "number is greater than " . X,, this)
    }

    /**
     * Asserts that this number lies in the inclusive range between `x` and `y`.
     * 
     * @example
     * (12).AssertInRange(1, 100, "number is not between 1-100")
     * 
     * @param   {Number}   x    lower limit
     * @param   {Number}   y    upper limit
     * @param   {String?}  Msg  error message
     * @returns {this}
     */
    AssertInRange(x, y, Msg?) {
        Hi := Max(x, y)
        Lo := Min(x, y)
        if ((this < Lo) || (this > Hi)) {
            throw ValueError(Msg ?? "number is not in range "
                                  . Lo . " - " . Hi,, this)
        }
        return this
    }
}

class Object {
    /**
     * Asserts that the object owns a property by the given name, otherwise
     * throws a `PropertyError`.
     * 
     * @param   {String}   PropName  name of the property
     * @param   {String?}  Msg       custom error message
     * @returns {this}
     */
    AssertHasOwnProp(PropName, Msg?) {
        if (ObjHasOwnProp(this, PropName)) {
            return this
        }
        throw PropertyError(Msg ?? "object has no property called " . PropName)
    }
} ; class Object
} ; class AquaHotkey_Assertions extends AquaHotkey