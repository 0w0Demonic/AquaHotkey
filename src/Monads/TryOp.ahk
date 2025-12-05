#Requires AutoHotkey v2.0
#Include "%A_LineFile%\..\..\Core\AquaHotkeyX.ahk"

;@region TryOp
/**
 * AquaHotkey - TryOp.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/Call.ahk
 * 
 * ---
 * 
 * **Overview**:
 * 
 * `TryOp` abstracts the use of try-catch blocks into a container object
 * that is either a `Call.Success` containing a value, or a `Call.Failure`
 * containing an error object.
 * 
 * @example
 * Result := TryOp.Value(42)
 *     .Map((x) => (x / 0))
 *     .Recover(ZeroDivisionError, Err => "Zero division error")
 *     .OrElseThrow()
 */
class TryOp {
    ;---------------------------------------------------------------------------
    ;@region Construction

    /**
     * Invokes `Supplier` with the supplied arguments, capturing its returned
     * value as `TryOp.Success` or any thrown error as `TryOp.Failure`
     * 
     * ```ahk
     * Supplier(Args*) => Any
     * ```
     * 
     * @example
     * Result := TryOp(() => "My Value")
     * 
     * @param   {Func}  Supplier  the function to be executed
     * @param   {Any*}  Args      zero or more arguments
     * @returns {TryOp}
     */
    static Call(Supplier, Args*) {
        GetMethod(Supplier)
        try {
            Value := Supplier(Args*)
            return (Object.Call)(TryOp.Success, Value)
        } catch as Err {
            return (Object.Call)(TryOp.Failure, Err)
        }
    }

    /**
     * Constructs a successful try-operation containing the given value.
     * 
     * @example
     * ; TryOp.Success(42)
     * TryValue := TryOp.Value(42)
     * 
     * @param   {Any}  Value  any value
     * @returns {TryOp.Success}
     */
    static Value(Value) => TryOp.Success(Value)

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region General

    /**
     * Determines whether the `TryOp` is successful.
     * 
     * @returns {Boolean}
     */
    Succeeded {
        get {
            throw MethodError("not implemented")
        }
    }

    /**
     * Determines whether the `TryOp` failed.
     * 
     * @returns {Boolean}
     */
    Failed {
        get {
            throw MethodError("not implemented")
        }
    }

    /**
     * Returns the string representation of this try-operation, assuming
     * the contained value can be represented as a string value.
     * 
     * According to the AHK docs, `String(Value)` automatically returns
     * `Value.ToString()`, if the value is an object.
     * 
     * @example
     * TryOp.Value(42).ToString() ; "TryOp.Success(42)"
     * 
     * @returns {String}
     */
    ToString() => (Type(this) . "(" . String(this.Value) . ")")

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Actions

    /**
     * Performs the given action no matter what the result of the operation is.
     * 
     * ```ahk
     * FinalFunction(Args*) => Void
     * ```
     * 
     * @example
     * FileName := "myfile.txt"
     * 
     * FileContent := TryOp(FileRead, FileName)
     *     .RetainIf((Str) => (Str == ""))
     *     .OnSuccess(MsgBox)
     *     .Finally(FileDelete, FileName)
     * 
     * @param   {Func}  FinalFunction  the function to be called
     * @param   {Any*}  Args           zero or more additional args
     */
    Finally(FinalFunction, Args*) {
        FinalFunction(Args*)
        return this
    }

    /**
     * Performs the given `Action` if this try-operation is successful.
     * 
     * ```ahk
     * Action(InnerValue, Args*) => Void
     * ```
     * 
     * @example
     * ; displays "value", returns a `TryOp.Success("value")`.
     * Result := TryOp(() => "value").Then(MsgBox)
     * 
     * @param   {Func}  Action  the function to be called
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {TryOp}
     */
    Then(Action, Args*) {
        throw MethodError("not implemented")
    }

    /**
     * Performs the given `Action` if this try-operation has succeeded.
     * 
     * ```
     * Action(InnerValue, Args*) => Void
     * ```
     * 
     * @example
     * ; displays "Example"
     * TryOp(() => "Example").OnSuccess(MsgBox)
     * 
     * @param   {Func}  Action  the function to be called
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {TryOp}
     */
    OnSuccess(Action, Args*) {
        throw MethodError("not implemented")
    }

    /**
     * Performs the given `Action` if this try-operation has failed.
     * 
     * ```ahk
     * Action(ErrorObj, Args*) => Void
     * ```
     * 
     * @example
     * TryOp(() => (12 / 0)).OnFailure(ZeroDivisionError, (Err) {
     *     MsgBox("something went wrong...")
     * })
     * 
     * @param   {Func}  Action  the function to be called
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {TryOp}
     */
    OnFailure(ClassOrAction, Action?, Args*) {
        throw MethodError("not implemented")
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Filtering

    /**
     * Returns `this` if the try-operation is successful and fulfills the
     * given operation, else a `TryOp.Failure` if the function returns `false`
     * or throws an error.
     * 
     * ```ahk
     * Condition(InnerValue, Args*)
     * ```
     * 
     * @example
     * ; TryOp.Success(42)
     * TryOp.Value(42).RetainIf((x) => (x > 5))
     * 
     * @example
     * ; TryOp.Failure(TypeError("Expected a Number but got a String."))
     * TryOp.Value("example").RetainIf((x) => (x > 5))
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {TryOp}
     */
    RetainIf(Condition, Args*) {
        throw MethodError("not implemented")
    }

    /**
     * Returns `this` if the try-operation is successful and its inner
     * value does NOT fulfill the given condition, else a `TryOp.Failure`
     * is the function returns `false` or throws an error.
     * 
     * ```ahk
     * Condition(InnerValue, Args*)
     * ```
     * 
     * @example
     * ; TryOp.Success(42)
     * TryOp.Value(42).RemoveIf(IsObject)
     * 
     * @example
     * ; TryOp.Failure(TypeError("Expected a Number but got a String."))
     * TryOp.Value("example").RemoveIf((x) => (x > 5))
     * 
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {TryOp}
     */
    RemoveIf(Condition, Args*) {
        throw MethodError("not implemented")
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Transformation

    /**
     * Transforms the inner value of this `TryOp` when successful.
     * 
     * ```ahk
     * Mapper(InnerValue, Args*) => Any
     * ```
     * 
     * @example
     * Divide(a, b) => (a / b)
     * 
     * ; TryOp.Success(6)
     * TryOp.Value(12).Map(Divide, 2)
     * 
     * ; TryOp.Failure(ZeroDivisionError)
     * TryOp.Value(12).Map(Divide, 0)
     * 
     * ; TryOp.Failure(MethodError)
     * TryOp.Failure(MethodError()).Map(Divide, 0)
     * 
     * @param   {Func}  Mapper  function to transform inner value
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {TryOp}
     */
    Map(Mapper, Args*) {
        throw MethodError("not implemented")
    }

    /**
     * If this try-operation is successful, applies the given `Mapper`
     * function to its inner value and returns the resulting `TryOf`.
     * 
     * ```ahk
     * Mapper(InnerValue, Args*) => TryOf
     * ```
     * 
     * @example
     * ; TryOp.Success(<file content>)   (assuming the file exists)
     * TryOp.Value("example.txt").FlatMap((Str) {
     *     return TryOp(() => FileRead(Str))
     * })
     * 
     * ; TryOp.Failure(Error("oops!"))
     * TryOp.Failure(Error("oops!")).FlatMap(...)
     * 
     * @param   {Func}  Mapper  the function to be applied
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {TryOp}
     */
    FlatMap(Mapper, Args*) {
        throw MethodError("not implemented")
    }

    /**
     * Transforms this `TryOp` by applying it to the given `Mapper` function.
     * 
     * ```ahk
     * Mapper(TryOp, Args*) => Any
     * ```
     * 
     * @example
     * TryOp(() => FileRead("example.txt")).Transform((Op) {
     *     if (Op.Succeeded) {
     *         return ...
     *     } else ...
     * })
     * 
     * @param   {Func}  Mapper  the function to apply
     * @returns {Any}
     */
    Transform(Mapper, Args*) {
        throw MethodError("not implemented")
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Returning Values

    /**
     * Returns the inner value contained in this try-operation when successful,
     * otherwise throws an error.
     * 
     * @example
     * Result := TryOp(() => FileRead("example.txt")).Get()
     * 
     * @returns {Any}
     */
    Get() {
        throw MethodError("not implemented")
    }

    /**
     * Returns the inner value of this `TryOp` when successful, otherwise the
     * given `DefaultValue`.
     * 
     * @example
     * TryOp(() => FileRead("example.txt")).OrElse("(file not found)")
     * 
     * @param   {Any}  DefaultValue  value to return if try-operation failed
     * @returns {Any}
     */
    OrElse(DefaultValue) {
        throw MethodError("not implemented")
    }

    /**
     * Returns the inner value of this `TryOp` when successful, otherwise
     * applies `RecoverFunction` with the error object contained in the failed
     * try-operation.
     * 
     * ```ahk
     * RecoverFunction(Err: Error, Args*) => Any
     * ```
     * 
     * @example
     * ; TryOp.Success of either file contents or "file not found"
     * TryOp(() => FileRead("myFile.txt")).OrElseGet(() => "file not found")
     * 
     * @param   {Func}  RecoverFunction  function that recovers value
     * @returns {Any}
     */
    OrElseGet(RecoverFunction, Args*) {
        throw MethodError("not implemented")
    }

    /**
     * Performs the given `Action` if this try-operation has failed.
     * 
     * ```ahk
     * Action(Args*) => Void
     * ```
     * 
     * @example
     * TryOp(() => (2 / 0)).OrElseRun(() => MsgBox("(zero division)"))
     * 
     * @param   {Func}  Action  the function to be called
     */
    OrElseRun(Action, Args*) {
        throw MethodError("not implemented")
    }

    /**
     * Returns the inner value of this `TryOp` when successful, otherwise
     * throws an error.
     * 
     * ```ahk
     * ThrowFunction(Err: Error, Args*) => Error
     * ```
     * 
     * @example
     * TryOp(() => FileRead("myFile.txt")).OrElseThrow()
     * 
     * @param   {Class/Func?}  ErrorSupplier  error class or error supplier
     * @returns {Any}
     */
    OrElseThrow(ErrorSupplier := ((e) => e)) {
        throw MethodError("not implemented")
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Recovery

    /**
     * Recovers a failed try-operation containing an error of the given
     * `ErrorType`.
     * 
     * @param   {Class/Func}  ErrorType        error type or condition
     * @param   {Func}        RecoverFunction  function to recover value
     * @param   {Any*}        Args             zero or more additional arguments
     * @returns {TryOp}
     */
    Recover(ErrorType, RecoverFunction, Args*) {
        throw MethodError("not implemented")
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region TryOp.Success

    /**
     * A succeeded try-operation.
     */
    class Success extends TryOp {
        /**
         * Constructs a new successful try-operation that contains
         * the given value.
         * 
         * @example
         * ; TryOp.Success(42)
         * SuccessfulTry := TryOp.Success(42)
         * 
         * @param   {Any}  Value  any value
         * @returns {TryOp.Success}
         */
        static Call(Value) => (Object.Call)(this, Value)

        /**
         * Constructs a new successful try-operation that contains
         * the given value.
         * 
         * @example
         * ; TryOp.Success(42)
         * SuccessfulTry := TryOp.Success(42)
         * 
         * @param   {Any}  Value  any value
         */
        __New(Value) {
            this.DefineProp("Value", { Get: (_) => Value })
        }

        Succeeded => true
        Failed => false

        Then(Action, Args*) {
            Action(this.Value, Args*)
            return this
        }

        OnFailure(Action, *) => this

        OnSuccess(Action, Args*) {
            Action(this.Value, Args*)
            return this
        }

        RetainIf(Condition, Args*) {
            try {
                if (Condition(this.Value, Args*)) {
                    return this
                }
                switch {
                    case (Condition is Func): Name := Condition.Name
                    default:                  Name := GetMethod(Condition).Name
                }
                if (IsSpace(Name)) {
                    Name := "(unnamed)"
                }
                return TryOp.Failure(Error("Did not match condition: " . Name))
            } catch as Err {
                return TryOp.Failure(Err)
            }
        }

        RemoveIf(Condition, Args*) {
            try {
                if (!Condition(this.Value, Args*)) {
                    return this
                }
                switch {
                    case (Condition is Func): Name := Condition.Name
                    default:                  Name := GetMethod(Condition).Name
                }
                if (IsSpace(Name)) {
                    Name := "(unnamed)"
                }
                return TryOp.Failure(Error("Matched condition: " . Name))
            } catch as Err {
                return TryOp.Failure(Err)
            }
        }

        FlatMap(Mapper, Args*) {
            try {
                Result := Mapper(this.Value, Args*)
                if (!(Result is TryOp)) {
                    throw TypeError("Expected a Call",, Type(Result))
                }
                return Result
            } catch as Err {
                return TryOp.Failure(Err)
            }
        }

        Transform(Mapper, Args*) => Mapper(this, Args*)

        Get() => this.Value

        OrElse(DefaultValue) {
            return this.Value
        }

        OrElseGet(RecoverFunction, *) => this.Value

        OrElseRun(Action, *) {
            ; nothing
        }

        OrElseThrow(ErrorSupplier?, *) => this.Value

        Map(Mapper, Args*) {
            try {
                return TryOp.Success(Mapper(this.Value, Args*))
            } catch as Err {
                return TryOp.Failure(Err)
            }
        }

        Recover(ErrorType, RecoverFunction, *) {
            return this
        }
    }
    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region TryOp.Failure

    /**
     * A failed try-operation.
     */
    class Failure extends TryOp
    {
        static Call(Err) => (Object.Call)(this, Err)

        __New(Err) {
            if (!(Err is Error)) {
                throw TypeError("Expected an Error",, Type(Err))
            }
            this.DefineProp("Value", { Get: (_) => Err })
        }

        Succeeded => false
        Failed => true

        Get() {
            throw this.Value
        }

        Then(ThenFunction, *) => this

        OnSuccess(Action, *) => this

        OnFailure(ErrorType, Action, Args*) {
            GetMethod(Action)
            Err := this.Value
            if (!(ErrorType is Class))
            {
                GetMethod(ErrorType)
                if (!ErrorType(Err)) {
                    return this
                }
            }
            else if ((ErrorType != Error) && !HasBase(ErrorType, Error))
            {
                throw TypeError("This class is not an Error class",,
                                ErrorType.Prototype.__Class)
            }
            else if (!(Err is ErrorType))
            {
                return this
            }
            Action(Err, Args*)
            return this
        }

        RetainIf(Condition, *) => this
        RemoveIf(Condition, *) => this

        FlatMap(Mapper, *) => this
        Map(Mapper, *) => this
        Transform(Mapper, *) => this

        OrElse(DefaultValue) => DefaultValue
        OrElseGet(Supplier, Args*) => Supplier(this.Value, Args*)
        OrElseRun(Action, Args*) {
            Action(Args*)
        }
        OrElseThrow(ErrorSupplier?, Args*) {
            if (IsSet(ErrorSupplier)) {
                throw ErrorSupplier(this.Value, Args*)
            }
            throw this.Value
        }

        Recover(ErrorType, RecoverFunction, Args*) {
            GetMethod(RecoverFunction)
            Value := this.Value
            if (!(ErrorType is Class))
            {
                GetMethod(ErrorType)
                if (!ErrorType(Value)) {
                    return this
                }
            }
            else if ((ErrorType != Error) && !HasBase(ErrorType, Error))
            {
                throw TypeError("This class is not an Error class",,
                                ErrorType.Prototype.__Class)
            }
            else if (!(Value is ErrorType))
            {
                return this
            }

            try {
                return TryOp.Success(RecoverFunction(Value, Args*))
            } catch as Err {
                return TryOp.Failure(Err)
            }
        }
    }
    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

class AquaHotkey_Try {
    static __New() => (this == AquaHotkey_Try)
                   && (IsSet(AquaHotkey))
                   && (AquaHotkey is Class)
                   && (AquaHotkey.__New)(this)

    class Object {
        /**
         * Tries to call this object with `Args*`, wrapped in a try-operation.
         * 
         * @returns {TryOp}
         */
        TryCall(Args*) {
            GetMethod(this)
            return TryOp(this, Args*)
        }
    }
}

;@endregion