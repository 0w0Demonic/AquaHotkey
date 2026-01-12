; #Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include <AquaHotkeyX>

; TODO change `.AssertType()` to use this module's `.Is()` ?
; TODO allow `unset` inside `static IsInstance()`?
; TODO String.WithPattern() ?
; TODO wrappers like `Optional<String>`
; TODO `Any#IsInstance(T) => this.Eq(T)`?
; TODO pattern matching with placeholders like `Variadic(String)`

;@region Extensions
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
    ;@region Any
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
    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Object

    class Object {
        /**
         * Determines whether the given value matches the type specification
         * asserted by this object.
         * 
         * The calling object is required to be an object literal. In other
         * words, it must be a simple object that directly inherits from
         * `Object.Prototype`.
         * 
         * This object's own fields are used for pattern matching the own fields
         * of the given object. Primitive types are matched using `.Eq()`,
         * objects are matched using `.IsInstance()`
         * 
         * @augments Any#IsInstance
         * @param    {Any}  Val  any value
         * @returns  {Boolean}
         * @example
         * Success := { status: 200, data: Any }
         * 
         * Success.IsInstance({ status: 200, data: String }) ; true
         */
        IsInstance(Val) {
            static GetProp := {}.GetOwnPropDesc

            ; this is only meant to work on object literals
            if (ObjGetBase(this) != Object.Prototype) {
                MsgBox("not a literal")
                return false
            }
            for PropName in ObjOwnProps(this) {
                PropDesc := GetProp(this, PropName)
                if (!ObjHasOwnProp(PropDesc, "Value")) {
                    continue
                }
                PropValue := PropDesc.Value

                if (!ObjHasOwnProp(Val, PropName)) {
                    return false
                }
                PropDesc := GetProp(Val, PropName)
                if (!ObjHasOwnProp(PropDesc, "Value")) {
                    return false
                }

                if (IsObject(PropValue)) {
                    if (!PropValue.IsInstance(PropDesc.Value)) {
                        return false
                    }
                } else if (!PropValue.Eq(PropDesc.Value)) {
                    return false
                }
            }
            return true
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Array

    class Array {
        /**
         * Determines whether the given value (an array) can be pattern matched
         * with this array.
         * 
         * This array's elements are used for pattern matching the elements
         * of the other array. Primitive types are matched using `.Eq()`,
         * objects are matched using `.IsInstance()`. `unset` asserts that the
         * other array has no value at the same index.
         * 
         * @param   {Any}  Val  any value
         * @returns {Boolean}
         * @example
         * ( ["foo", "bar", 42] ).Is( [String, String, Integer] ) ; true
         * 
         * ( [unset, 42] ).Is( [unset, Integer] ) ; true
         * ( ["foo", 42] ).Is( [unset, Integer] ) ; false
         */
        IsInstance(Val) {
            if (!(Val is Array)) {
                return false
            }
            if (Val.Length != this.Length) {
                return false
            }
            loop this.Length {
                if (this.Has(A_Index)) {
                    if (!Val.Has(A_Index)) {
                        return false
                    }
                    ElemThis := this.Get(A_Index)
                    ElemOther := Val.Get(A_Index)
                    if (IsObject(ElemThis)) {
                        if (!ElemThis.IsInstance(ElemOther)) {
                            return false
                        }
                    } else if (!ElemThis.Eq(ElemOther)) {
                        return false
                    }
                } else if (Val.Has(A_Index)) {
                    return false
                }
            }
            return true
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region

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
         * Number.CanCastFrom(Integer)
         */
        CanCastFrom(T) => (this == T) || HasBase(T, this)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Type

    class Type {
        /**
         * Creates a type class that represents a union of the specified types.
         * 
         * @param   {Class*}  Types  one or more classes
         * @returns {Class}
         * @example
         * StringOrInteger := Type.Union(String, Integer)
         */
        static Union(Types*) {
            if (!Types.Length) {
                throw UnsetError("no values specified")
            }
            Result := Class()
            ({}.DefineProp)(Result, "IsInstance", { Call: IsInstance })
            return Result

            IsInstance(this, Val) {
                for T in Types {
                    if (T.IsInstance(Val)) {
                        return true
                    }
                }
                return false
            }
        }

        /**
         * Creates a type class that represents an intersection of the specified
         * types.
         * 
         * @param   {Class*}  Types  one or more classes
         * @returns {Class}
         * @example
         * T := Type.Union({ status: 200 }, { data: Any })
         * 
         * Obj := { status: 200, data: "success!" }
         * MsgBox(Obj.Is(T)) ; true
         */
        static Intersection(Types*) {
            if (!Types.Length) {
                throw UnsetError("no values specified")
            }
            Result := Class()
            ({}.DefineProp)(Result, "IsInstance", { Call: IsInstance })
            return Result

            IsInstance(this, Val) {
                for T in Types {
                    if (!T.IsInstance(Val)) {
                        return false
                    }
                }
                return true
            }
        }

        /**
         * Creates a type class which represents an enumeration of the given
         * values. On pattern matching, `.Eq()` is used for comparing values.
         * 
         * @param   {Any*}  Values  one or more values
         * @returns {Class}
         * @example
         * Permissions := Type.Enum("Admin", "User", "Guest")
         * 
         * Permissions.IsInstance("Admin") ; true
         * Permissions.IsInstance("Other") ; false
         */
        static Enum(Values*) {
            if (!Values.Length) {
                throw UnsetError("no values specified")
            }
            Result := Class()
            ({}.DefineProp)(Result, "IsInstance", { Call: IsInstance })
            return Result

            IsInstance(this, Val) {
                for V in Values {
                    if (V.Eq(Val)) {
                        return true
                    }
                }
                return false
            }
        }
    }

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Numeric

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
     * Numeric.CanCastFrom(Numeric) ; true
     * Numeric.CanCastFrom(Integer) ; true (every integer is numeric)
     */
    static CanCastFrom(T) {
        return super.CanCastFrom(T) || Number.CanCastFrom(T)
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Callable

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
     * Callable.CanCastFrom(Func) ; true (every function is callable)
     */
    static CanCastFrom(T) {
        return (super.CanCastFrom(T) || Func.CanCastFrom(T))
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region BufferObject

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
     * BufferObject.CanCastFrom(Buffer)
     */
    static CanCastFrom(T) {
        return (super.CanCastFrom(T) || Buffer.CanCastFrom(T))
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Record

/**
 * A `Record<K, V>` is an object with properties of type `K` and values `V`.
 * 
 * @example
 * Permissions := Type.Enum("Admin", "User", "Guest")
 * PermissionsMap := Record(Permissions, String)
 * 
 * Obj := {
 *     Admin: "just do what you want lol",
 *     User: "okay, you're allowed in",
 *     Guest: "fine. but don't touch anything"
 * }
 * MsgBox(Obj.Is(PermissionsMap))
 */
class Record {
    static Call(KeyType, ValueType) {
        static Define  := {}.DefineProp
        static GetProp := {}.GetOwnPropDesc

        if (!HasMethod(KeyType, "IsInstance")) {
            throw TypeError("not a valid pattern")
        }
        if (!HasMethod(ValueType, "IsInstance")) {
            throw TypeError("not a valid pattern")
        }

        Result := Class()
        Define(Result, "IsInstance", { Call: IsInstance })
        return Result

        IsInstance(this, Val) {
            ; only supposed to work on plain objects, for now.
            if (ObjGetBase(Val) != Object.Prototype) {
                return false
            }

            for PropName in ObjOwnProps(Val) {
                PropDesc := GetProp(Val, PropName)
                if (!ObjHasOwnProp(PropDesc, "Value")) {
                    continue
                }
                PropVal := PropDesc.Value
                if (!KeyType.IsInstance(PropName)) {
                    return false
                }
                if (!ValueType.IsInstance(PropVal)) {
                    return false
                }
            }
            return true
        }
    }
}

;@endregion

Permissions := Type.Enum("Admin", "User", "Guest")
PermissionsMap := Record(Permissions, Numeric)


Obj := {
    Admin: "123",
    User: "897",
    Guest: "98"
}

MsgBox(Obj.Is(PermissionsMap))
