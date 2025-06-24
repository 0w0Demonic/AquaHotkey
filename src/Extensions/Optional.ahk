/**
 * AquaHotkey - Optional.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/Optional.ahk
 * 
 * ---
 * 
 * **Overview**:
 * 
 * The `Optional` class provides a container object which may or may not
 * contain a non-null value. It is directly inspired by Java's
 * `java.util.Optional` type but tailored for AquaHotkey's ecosystem.
 * 
 * Commonly used for safe handling of potentially `unset` values, the
 * `Optional` class includes operations for mapping, filtering, and
 * consuming the contained value.
 */
class Optional {
    /**
     * Returns an optional with no value present.
     * 
     * @example
     * Opt := Optional.Empty()
     * Opt.IsPresent ; false
     * 
     * @return  {Optional}
     */
    static Empty() => Optional()

    /**
     * Constructs a new optional describing the given `Value` if specified,
     * otherwise an empty optional.
     * 
     * @example
     * Opt   := Optional("foo")
     * Empty := Optional()
     * 
     * @param   {Any?}  Value  the value contained in the optional
     * @return  {Optional}
     */
    __New(Value?) {
        (IsSet(Value) && this.DefineProp("Value", { Get: (Instance) => Value }))
    }

    /**
     * If present, returns the value of the optional, otherwise throws an
     * `UnsetError`.
     * 
     * @example
     * Optional("foo").Get()  ; "foo"
     * Optional.Empty().Get() ; Error!
     * 
     * @return  {Any}
     */
    Get() {
        if (HasProp(this, "Value")) {
            return this.Value
        }
        throw UnsetError("value unset")
    }

    /**
     * Returns `true`, if a value is present for this optional.
     * 
     * @example
     * Optional("foo").IsPresent ; true
     * Optional(unset).IsPresent ; false
     * 
     * @return  {Boolean}
     */
    IsPresent => HasProp(this, "Value")

    /**
     * Returns `true`, if this Optional does not contain a value.
     * 
     * @example
     * Optional("foo").IsAbsent ; false
     * Optional(unset).IsAbsent ; true
     * 
     * @return  {Boolean}
     */
    IsAbsent => !HasProp(this, "Value")

    /**
     * If a value is present, calls the given `Action` function on the value.
     * 
     * `Action` is called using the value as first argument, followed by zero
     * or more additional arguments `Args*`.
     * 
     * @example
     * Optional("Hello, world!").IfPresent(MsgBox)
     *
     * @param   {Func}  Action  the function to be called
     * @param   {Any*}  Args    zero or more additional arguments
     * @return  {this}
     */
    IfPresent(Action, Args*) {
        (HasProp(this, "Value") && Action(this.Value, Args*))
        return this
    }

    /**
     * If no value is present, calls the given `Action` function.
     * 
     * `Action` is called using zero or more arguments `Args*`
     * 
     * @example
     * Optional.Empty().IfAbsent(() => MsgBox("no value present"))
     * 
     * @param   {Func}  EmptyAction  the function to be called
     * @param   {Any*}  Args         zero or more additional arguments
     * @return  {this}
     */
    IfAbsent(EmptyAction, Args*) {
        (HasProp(this, "Value") || EmptyAction(Args*))
        return this
    }

    /**
     * Filters the value based on the given `Condition`.
     * The optional becomes empty, if `Condition` evaluates to `false`.
     * 
     * @example
     * Optional(4).RetainIf(IsNumber) ; Optional(4)
     *
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @return  {Optional}
     */
    RetainIf(Condition, Args*) {
        if (!HasProp(this, "Value")) {
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
     * @example
     * Optional(4).RemoveIf(IsNumber) ; Optional.Empty()
     *
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @return  {Optional}
     */
    RemoveIf(Condition, Args*) {
        if (!HasProp(this, "Value")) {
            return this
        }
        if (Condition(this.Value, Args*)) {
            return Optional()
        }
        return this
    }

    /**
     * If present, applies the given `Mapper` function to the value and returns
     * a new optional containing its result.
     * 
     * `Mapper` is called using the value as first argument, followed by zero
     * or more additional arguments `Args*`.
     * 
     * @example
     * Multiply(x, y) {
     *     return x * y
     * }
     * 
     * Optional(4).Map(Multiply, 2)       ; Optional(8)
     * Optional.Empty().Map(Multiply, 2)  ; Optional.Empty()
     *
     * @param   {Func}  Mapper  function to transform the value
     * @param   {Any*}  Args    zero or more additional arguments
     * @return  {Optional}
     */
    Map(Mapper, Args*) {
        if (!HasProp(this, "Value")) {
            return this
        }
        return Optional(Mapper(this.Value, Args*))
    }

    /**
     * If present, returns the value, otherwise returns the given default value.
     * 
     * @example
     * Optional(2).OrElse("")      ; 2
     * Optional.Empty().OrElse("") ; ""
     *
     * @param   {Any}  Default  default value to return if no value is present
     * @return  {Any}
     */
    OrElse(Default) {
        if (HasProp(this, "Value")) {
            return this.Value
        }
        return Default
    }

    /**
     * Returns the value if present, otherwise calls the `Supplier` function
     * to obtain a default value.
     * 
     * @example
     * Optional(4).OrElseGet(() => 6) ; 4
     * Optional.Empty().OrElseGet()
     *
     * @param   {Func}  Supplier  function to provide a default value
     * @param   {Any*}  Args      zero or more additional arguments
     * @return  {Any}
     */
    OrElseGet(Supplier, Args*) {
        if (HasProp(this, "Value")) {
            return this.Value
        }
        return Supplier(Args*)
    }

    /**
     * Returns the value if present, otherwise throws an exception provided by
     * the `ExceptionSupplier`.
     * 
     * @example
     * ; `throw ValueError("argument is not a number")`
     * Optional("foo").RetainIf(IsNumber)
     *                .OrElseThrow(ValueError, "argument is not a number")
     *
     * @param   {Func?}  ExceptionSupplier  function to provide an exception
     * @param   {Any*}   Args               zero or more arguments
     * @return  {Any}
     */
    OrElseThrow(ExceptionSupplier := Error, Args*) {
        if (HasProp(this, "Value")) {
            return this.Value
        }
        try Err := ExceptionSupplier(Args*)
        if (IsSet(Err)) {
            throw Err
        }
        throw ValueError("value unset")
    }

    /**
     * Returns the string representation of the optional.
     * 
     * @example
     * Array(1, 2, 3).Optional().ToString() ; "Optional{ [1, 2, 3] }"
     * 
     * @return  {String}
     */
    ToString() {
        if (!HasProp(this, "Value")) {
            return Type(this) . "{ unset }"
        }
        if (this.Value is String) {
            return Type(this) . '{ "' . this.Value . '" }'
        }
        return Type(this) . "{ " . String(this.Value) . " }"
    }
}

class AquaHotkey_Optional extends AquaHotkey {
    class Any {
        /**
         * Returns a new optional that wraps arount the element.
         * @see `Optional`
         * 
         * @example
         * "Hello world!".Optional().IfPresent(MsgBox)
         * 
         * @return  {Optional}
         */
        Optional() => Optional(this)
    }
}