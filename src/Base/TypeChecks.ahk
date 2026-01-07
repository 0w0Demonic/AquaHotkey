#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

; TODO merge together with "TypeInfo" into "TypeSystem" ?
; TODO change `.AssertType()` to use this module's `.Is()` ?

/**
 * Provides a flexible type-checking system that extends the `is`-keyword with
 * user-defined types.
 * 
 * This feature allows classes to act as predicates for values, determining
 * whether a given value is an instance of that class.
 * 
 * A value can be tested against a class by calling `Value.Is(Class)`,
 * which delegates to `Class.IsInstance(Value)`.
 * 
 * You can implement your own custom type checks by overriding the
 * `static IsInstance()` method. The method should return `true`, if the
 * input satisfies the desired semantics.
 * 
 * @module  <Base/TypeChecks>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * "123".Is(String)      ; true (calls `"123" is String`)
 * "123".Is(Numeric)     ; true (calls `IsNumber("123")`)
 * "example".Is(Numeric) ; false
 * 
 * class Numeric {
 *     static IsInstance(Val) => IsNumber(Val)
 * }
 * 
 * class Email {
 *     static IsInstance(Val) => (Val is String)
 *                            && (Val ~= "^[^@]+@[^@]+\.[^@]+$")
 * }
 */
class AquaHotkey_TypeChecks extends AquaHotkey {
    class Any {
        /**
         * Determines whether this value is an instance of the given class.
         * 
         * The default implementation uses the `is` keyword, but this behaviour
         * can be customized.
         * 
         * @param   {Class}  T  expected class
         * @returns {Boolean}
         * @example
         * "123".Is(String)      ; true
         * "example".Is(Numeric) ; false
         */
        Is(T) => T.IsInstance(this) ; TODO change to "InstanceOf()" ?
    }

    class Class {
        /**
         * Determines whether a value is an instance of this class.
         * 
         * The default behaviour of this method is using the `is` keyword to
         * determine if the value uses the prototype of this class as base
         * object.
         * 
         * @param   {Any}  Val  any value
         * @returns {Boolean}
         * @example
         * "123".Is(String)      ; true
         * "example".Is(Numeric) ; false
         */
        IsInstance(Val) => (Val is this)
    }

    ; TODO write methods that create new types?
}

/**
 * A number or numeric string (as determined by `IsNumber()`).
 */
class Numeric {
    /**
     * Determines whether the value is numeric.
     * 
     * @param   {Any}  Val  any value
     * @returns {Boolean}
     * @example
     * "example".Is(Numeric)     ; false
     * Numeric.IsInstance("123") ; true
     */
    static IsInstance(Val) => IsNumber(Val)
}

/**
 * An object with `Call` property (`HasMethod()`).
 */
class Callable {
    /**
     * Determines whether the value is callable.
     * 
     * @param   {Any}  Value  any value
     * @returns {Boolean}
     * @example
     * "example".Is(Callable)                        ; false
     * Callable.IsInstance(MsgBox)                   ; true
     * ({ Call: (this) => this.Value }).Is(Callable) ; true
     */
    static IsInstance(Val) => IsObject(Val) && HasMethod(Val)
}

/**
 * An object with `Ptr` and `Size` property.
 */
class BufferObject {
    /**
     * Determines whether the buffer is buffer-like.
     * 
     * @param   {Any}  Val  any value
     * @returns {Boolean}
     * @example
     * Buffer(16, 0).Is(BufferObject)        ; true
     * { Ptr: 0, Size: 16 }.Is(BufferObject) ; true
     */
    static IsInstance(Val) => (
            IsObject(Val) &&
            HasProp(Val, "Ptr") &&
            HasProp(Val, "Size")
    )
}
