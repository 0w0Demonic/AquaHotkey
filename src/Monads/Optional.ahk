#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Base\Eq.ahk"
#Include "%A_LineFile%\..\..\Base\Hash.ahk"

;@region Optional

/**
 * Represents an optional value: either a value is present, or it is absent.
 * 
 * The inner value is *not* allowed to be `unset`. Creating an Optional with
 * value `unset` will result in an empty Optional.
 * 
 * @module  <Monads/Optional>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * MaybeValue := Optional(42)
 * MaybeValue.IsPresent ; true
 * MaybeValue.Get()     ; 42
 * 
 * MaybeValue.IfPresent(MsgBox) ; displays "42"
 * 
 * ; equality checks
 * OptA := Optional(4)
 * OptB := Optional(4)
 * MsgBox(OptA.Eq(OptB)) ; true
 */
class Optional {
    ;@region Construction

    /**
     * Returns an optional with no value present.
     * 
     * @constructor
     * @returns {Optional}
     * @example
     * Opt := Optional.Empty()
     * Opt.IsPresent ; false
     */
    static Empty() => Optional()

    /**
     * Returns an optional with the given nonnull value.
     * 
     * @constructor
     * @param   {Any}  Value  any value
     * @returns {Optional}
     * @example
     * Opt := Optional.Of(42)
     * Opt.IsPresent ; true
     */
    static Of(Value) => Optional(Value)

    /**
     * Constructs a new optional describing the given `Value` if specified,
     * otherwise an empty optional.
     * 
     * @param   {Any?}  Value  the value contained in the optional
     * @returns {Optional}
     * @example
     * Opt   := Optional("foo")
     * Empty := Optional()
     */
    __New(Value?) {
        (IsSet(Value) && this.DefineProp("Value", { Get: (_) => Value }))
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Value Presence

    /**
     * Returns `true`, if a value is present for this optional.
     * 
     * @readonly
     * @property {Boolean}
     * @example
     * Optional("foo").IsPresent ; true
     * Optional(unset).IsPresent ; false
     */
    IsPresent => ObjHasOwnProp(this, "Value")

    /**
     * Returns `true`, if this Optional does not contain a value.
     * 
     * @readonly
     * @property {Boolean}
     * @example
     * Optional("foo").IsAbsent ; false
     * Optional(unset).IsAbsent ; true
     */
    IsAbsent => !ObjHasOwnProp(this, "Value")

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Side Effects

    /**
     * If a value is present, calls the given `Action` function on the value.
     * 
     * `Action` is called using the value as first argument, followed by zero
     * or more additional arguments `Args*`.
     * 
     * @param   {Func}  Action  the function to be called
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {this}
     * @example
     * Optional("Hello, world!").IfPresent(MsgBox)
     */
    IfPresent(Action, Args*) {
        (ObjHasOwnProp(this, "Value") && Action(this.Value, Args*))
        return this
    }

    /**
     * If no value is present, calls the given `Action` function.
     * 
     * `Action` is called using zero or more arguments `Args*`
     * 
     * @param   {Func}  EmptyAction  the function to be called
     * @param   {Any*}  Args         zero or more additional arguments
     * @returns {this}
     * @example
     * Optional.Empty().IfAbsent(() => MsgBox("no value present"))
     */
    IfAbsent(EmptyAction, Args*) {
        (ObjHasOwnProp(this, "Value") || EmptyAction(Args*))
        return this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Filtering

    /**
     * Filters the value based on the given `Condition`.
     * The optional becomes empty, if `Condition` evaluates to `false`.
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {Optional}
     * @example
     * Optional(4).RetainIf(IsNumber) ; Optional(4)
     */
    RetainIf(Condition, Args*) {
        if (!ObjHasOwnProp(this, "Value")) {
            return this
        }
        if (!Condition(this.Value, Args*)) {
            return Optional()
        }
        return this
    }

    /**
     * Removes the value if the value fulfills the given `Condition`.
     *
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {Optional}
     * @example
     * Optional(4).RemoveIf(IsNumber) ; Optional.Empty()
     */
    RemoveIf(Condition, Args*) {
        if (!ObjHasOwnProp(this, "Value")) {
            return this
        }
        if (Condition(this.Value, Args*)) {
            return Optional()
        }
        return this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Transformation

    /**
     * If present, applies the given `Mapper` function to the value and returns
     * a new optional containing its result.
     * 
     * `Mapper` is called using the value as first argument, followed by zero
     * or more additional arguments `Args*`.
     * 
     * @param   {Func}  Mapper  function to transform the value
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {Optional}
     * @example
     * Multiply(x, y) {
     *     return x * y
     * }
     * 
     * Optional(4).Map(Multiply, 2)       ; Optional(8)
     * Optional.Empty().Map(Multiply, 2)  ; Optional.Empty()
     */
    Map(Mapper, Args*) {
        if (!ObjHasOwnProp(this, "Value")) {
            return this
        }
        return Optional(Mapper(this.Value, Args*))
    }

    /**
     * If present, applies the given `Mapper` function to the inner value and
     * flat-maps the resulting `Optional`.
     * 
     * @param   {Func}  Mapper  the given mapper function
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {Optional}
     * @example
     * ; Optional<2>
     * Optional.Of(A).FlatMap(A => A.Find(Even))
     */
    FlatMap(Mapper, Args*) {
        if (!ObjHasOwnProp(this, "Value")) {
            return this
        }
        O := Mapper(this.Value, Args*)
        if (!(O is Optional)) {
            throw TypeError("Expected an Optional",, Type(O))
        }
        return O
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Retrieving Values

    /**
     * If present, returns the value of the optional, otherwise throws an
     * `UnsetError`.
     * 
     * @returns {Any}
     * @example
     * Optional("foo").Get()  ; "foo"
     * Optional.Empty().Get() ; Error!
     */
    Get() {
        if (ObjHasOwnProp(this, "Value")) {
            return this.Value
        }
        throw UnsetError("value unset")
    }

    /**
     * If present, returns the value, otherwise returns the given default value.
     * 
     * @param   {Any}  Default  default value to return if no value is present
     * @returns {Any}
     * @example
     * Optional(2).OrElse("")      ; 2
     * Optional.Empty().OrElse("") ; ""
     */
    OrElse(Default) {
        if (ObjHasOwnProp(this, "Value")) {
            return this.Value
        }
        return Default
    }

    /**
     * Returns the value if present, otherwise calls the `Supplier` function
     * to obtain a default value.
     *
     * @param   {Func}  Supplier  function to provide a default value
     * @param   {Any*}  Args      zero or more additional arguments
     * @returns {Any}
     * @example
     * Optional(4).OrElseGet(() => 6) ; 4
     * Optional.Empty().OrElseGet()
     */
    OrElseGet(Supplier, Args*) {
        if (ObjHasOwnProp(this, "Value")) {
            return this.Value
        }
        return Supplier(Args*)
    }

    /**
     * Returns the value if present, otherwise throws an exception provided by
     * the `ExceptionSupplier`.
     * 
     * @param   {Func?}  ExceptionSupplier  function to provide an exception
     * @param   {Any*}   Args               zero or more arguments
     * @returns {Any}
     * @example
     * ; `throw ValueError("argument is not a number")`
     * Optional("foo").RetainIf(IsNumber)
     *                .OrElseThrow(ValueError, "argument is not a number")
     */
    OrElseThrow(ExceptionSupplier := Error, Args*) {
        if (ObjHasOwnProp(this, "Value")) {
            return this.Value
        }
        try Err := ExceptionSupplier(Args*)
        if (IsSet(Err)) {
            throw Err
        }
        throw ValueError("value unset")
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Commons

    /**
     * Determines whether this optional is equal to another `Other` optional.
     * This is true, when both optionals are empty, or when both contain
     * equal values.
     * 
     * @param   {Any?}  Other  another optional
     * @returns {Boolean}
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!(Other is Optional)) {
            return false
        }
        if (ObjHasOwnProp(Other, "Value")) {
            return ObjHasOwnProp(this, "Value") && (this.Value).Eq(Other.Value)
        }
        return (!ObjHasOwnProp(this, "Value"))
    }

    /**
     * Returns a hash code for this optional.
     * 
     * @returns {Integer}
     */
    HashCode() => (ObjHasOwnProp(this, "Value") && this.Value.HashCode())

    /**
     * Returns the string representation of the optional.
     * 
     * @example
     * Array(1, 2, 3).Optional().ToString() ; "Optional{ [1, 2, 3] }"
     * 
     * @returns {String}
     */
    ToString() {
        if (!ObjHasOwnProp(this, "Value")) {
            return Type(this) . "{ unset }"
        }
        if (this.Value is String) {
            return Type(this) . '{ "' . this.Value . '" }'
        }
        return Type(this) . "{ " . String(this.Value) . " }"
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

class AquaHotkey_Optional extends AquaHotkey {
    static __New() {
        if (this == AquaHotkey_Optional) {
            super.__New()
        }
    }
    
    /**
     * Provides a universal `.Optional()` method.
     */
    class Any {
        ; TODO rename to `.ToOptional()`?
        /**
         * Returns a new optional that wraps arount the element.
         * 
         * @example
         * "Hello world!".Optional().IfPresent(MsgBox)
         * 
         * @returns {Optional}
         */
        Optional() => Optional(this)
    }
}

;@endregion
