#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

; TODO merge together with "TypeInfo" into "TypeSystem" ?
; TODO change `.AssertType()` to use this module's `.Is()` ?
; TODO allow `unset` inside `static IsInstance()`?

/**
 * Provides a flexible type-checking system that extends the `is`-keyword with
 * user-defined types with so-called "traits".
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
 * "123".Is(String)      ; true ("123" is String)
 * "123".Is(Numeric)     ; true (IsNumber("123"))
 * "example".Is(Email)   ; false ("example" is String && (example ~= "..."))
 * 
 * ; >>>>
 * ; "trait classes" that represent a specification of what the value should be
 * ; <<<<
 * class Numeric {
 *     static IsInstance(Val) => IsNumber(Val)
 * }
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
        Is(T) => T.IsInstance(this)
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

        /**
         * Determines whether this value is an instance of the given class, or
         * its superclass.
         * 
         * @param   {Class}  T  expected class
         * @returns {Boolean}
         * @example
         * 
         * ; Integer
         * ; `- Number <- (base class)
         * Number.IsAssignableFrom(Integer)
         */
        IsAssignableFrom(T) => (this == T) || HasBase(T, this)

        ; TODO make the following work, for the sake of `.Is()` methods
        ;      generic arrays and maps:
        ; 
        ; String[][].Is(Any[][])
        ; => (Any[] == String[]) || Any[].IsAssignableFrom(String[])
        ; => (Any == String)     || Any.IsAssignableFrom(String)
        ; => (String == Any)     || HasBase(String, Any)
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

    /**
     * Determines whether the given class is considered a subclass of `Numeric`.
     * 
     * @param   {Class}  T  any class
     * @returns {Boolean}
     * @example
     * Numeric.IsAssignableFrom(Numeric) ; true
     * Numeric.IsAssignableFrom(Integer) ; true (every integer is numeric)
     */
    static IsAssignableFrom(T) {
        return super.IsAssignableFrom(T) || Number.IsAssignableFrom(T)
    }
}

/**
 * An object with `Call` property (`HasMethod()`).
 */
class Callable {
    /**
     * Determines whether the value is callable, excluding `.__Call()`.
     * 
     * @param   {Any}  Value  any value
     * @returns {Boolean}
     * @example
     * "example".Is(Callable)                        ; false
     * Callable.IsInstance(MsgBox)                   ; true
     * ({ Call: (this) => this.Value }).Is(Callable) ; true
     */
    static IsInstance(Val) => (IsObject(Val) && HasMethod(Val))

    /**
     * Determines whether the given class is considered a subclass of
     * `Callable`.
     * 
     * @param   {Any}  Value  any value
     * @returns {Boolean}
     * @example
     * Callable.IsAssignableFrom(Func) ; true (every function is callable)
     */
    static IsAssignableFrom(T) {
        return (super.IsAssignableFrom(T) || Func.IsAssignableFrom(T))
    }
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
            HasProp(Val, "Size"))
    
    /**
     * Determines whether the given class is considered a subtype of
     * `BufferObject`.
     * 
     * @param   {Class}  T  any class
     * @returns {Boolean}
     * @example
     * ; true (every buffer is a BufferObject)
     * BufferObject.IsAssignableFrom(Buffer)
     */
    static IsAssignableFrom(T) {
        return (super.IsAssignableFrom(T) || Buffer.IsAssignableFrom(T))
    }
}
