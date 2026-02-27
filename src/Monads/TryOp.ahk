#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

; dev note: because of `TryOp.Call()`, the constructors of `TryOp.Success` and
;          `TryOp.Failure` must also use `static Call()`.

;@region TryOp
/**
 * Abstracts the use of try-catch blocks into a container object that is
 * either a `TryOp.Success` containing a value, or a `TryOp.Failure` containing
 * an error object.
 * 
 * @module  <Monads/TryOp>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
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
     * @param   {Func}  Supplier  the function to be executed
     * @param   {Any*}  Args      zero or more arguments
     * @returns {TryOp}
     * @example
     * Result := TryOp(() => "My Value")
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
     * @property {Boolean}
     */
    Succeeded {
      get {
        throw MethodError("not implemented")
      }
    }

    /**
     * Determines whether the `TryOp` failed.
     * 
     * @property {Boolean}
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
     * @returns {String}
     * @example
     * TryOp.Value(42).ToString() ; "TryOp.Success(42)"
     */
    ToString() => (Type(this) . "(" . String(this.Value) . ")")

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Side Effects

    /**
     * Performs the given action no matter what the result of the operation is.
     * 
     * ```ahk
     * FinalFunction(Args*) => Void
     * ```
     * 
     * @param   {Func}  FinalFunction  the function to be called
     * @param   {Any*}  Args           zero or more additional args
     * @example
     * FileName := "myfile.txt"
     * 
     * FileContent := TryOp(FileRead, FileName)
     *     .RetainIf((Str) => (Str == ""))
     *     .OnSuccess(MsgBox)
     *     .Finally(FileDelete, FileName)
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
     * @param   {Func}  Action  the function to be called
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {TryOp}
     * @example
     * ; displays "value", returns a `TryOp.Success("value")`.
     * Result := TryOp(() => "value").Then(MsgBox)
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
     * @param   {Func}  Action  the function to be called
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {TryOp}
     * @example
     * ; displays "Example"
     * TryOp(() => "Example").OnSuccess(MsgBox)
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
     * @param   {Func}  Action  the function to be called
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {TryOp}
     * @example
     * TryOp(() => (12 / 0)).OnFailure(ZeroDivisionError, (Err) {
     *     MsgBox("something went wrong...")
     * })
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
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {TryOp}
     * @example
     * ; TryOp.Success(42)
     * TryOp.Value(42).RetainIf((x) => (x > 5))
     * 
     * @example
     * ; TryOp.Failure(TypeError("Expected a Number but got a String."))
     * TryOp.Value("example").RetainIf((x) => (x > 5))
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
     * @param   {Func}  Condition  the given condition
     * @param   {Any*}  Args       zero or more additional arguments
     * @returns {TryOp}
     * @example
     * ; TryOp.Success(42)
     * TryOp.Value(42).RemoveIf(IsObject)
     * 
     * @example
     * ; TryOp.Failure(TypeError("Expected a Number but got a String."))
     * TryOp.Value("example").RemoveIf((x) => (x > 5))
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
     * @param   {Func}  Mapper  function to transform inner value
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {TryOp}
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
     * @param   {Func}  Mapper  the function to be applied
     * @param   {Any*}  Args    zero or more additional arguments
     * @returns {TryOp}
     * @example
     * ; TryOp.Success(<file content>)   (assuming the file exists)
     * TryOp.Value("example.txt").FlatMap((Str) {
     *     return TryOp(() => FileRead(Str))
     * })
     * 
     * ; TryOp.Failure(Error("oops!"))
     * TryOp.Failure(Error("oops!")).FlatMap(...)
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
     * @param   {Func}  Mapper  the function to apply
     * @returns {Any}
     * @example
     * TryOp(() => FileRead("example.txt")).Transform((Op) {
     *     if (Op.Succeeded) {
     *         return ...
     *     } else ...
     * })
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
     * @returns {Any}
     * @example
     * Result := TryOp(() => FileRead("example.txt")).Get()
     */
    Get() {
        throw MethodError("not implemented")
    }

    /**
     * Returns the inner value of this `TryOp` when successful, otherwise the
     * given `DefaultValue`.
     * 
     * @param   {Any}  DefaultValue  value to return if try-operation failed
     * @returns {Any}
     * @example
     * TryOp(() => FileRead("example.txt")).OrElse("(file not found)")
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
     * @param   {Func}  RecoverFunction  function that recovers value
     * @returns {Any}
     * @example
     * ; TryOp.Success of either file contents or "file not found"
     * TryOp(() => FileRead("myFile.txt")).OrElseGet(() => "file not found")
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
     * @param   {Func}  Action  the function to be called
     * @example
     * TryOp(() => (2 / 0)).OrElseRun(() => MsgBox("(zero division)"))
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
     * @param   {Class/Func?}  ErrorSupplier  error class or error supplier
     * @returns {Any}
     * @example
     * TryOp(() => FileRead("myFile.txt")).OrElseThrow()
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

    /**
     * Recovers a failed try-operation of any error type.
     * 
     * @param   {Func}        RecoverFunction  function to recover value
     * @param   {Any*}        Args             zero or more additional arguments
     * @returns {TryOp}
     */
    RecoverAny(RecoverFunction, Args*) {
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
         * @constructor
         * @param   {Any}  Value  any value
         * @returns {TryOp.Success}
         * @example
         * ; TryOp.Success(42)
         * SuccessfulTry := TryOp.Success(42)
         */
        static Call(Value) => (Object.Call)(this, Value)

        /**
         * Constructs a new successful try-operation that contains
         * the given value.
         * 
         * @constructor
         * @param   {Any}  Value  any value
         * @example
         * ; TryOp.Success(42)
         * SuccessfulTry := TryOp.Success(42)
         */
        __New(Value) {
            this.DefineProp("Value", { Get: (_) => Value })
        }

        /**
         * @see {@link TryOp#Succeeded}
         */
        Succeeded => true

        /**
         * @see {@link TryOp#Failed}
         */
        Failed => false

        /**
         * @see {@link TryOp#Then()}
         */
        Then(Action, Args*) {
            Action(this.Value, Args*)
            return this
        }

        /**
         * @see {@link TryOp#OnFailure()}
         */
        OnFailure(Action, *) => this

        /**
         * @see {@link TryOp#OnSuccess()}
         */
        OnSuccess(Action, Args*) {
            Action(this.Value, Args*)
            return this
        }

        /**
         * @see {@link TryOp#RetainIf()}
         */
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

        /**
         * @see {@link TryOp#RemoveIf()}
         */
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

        /**
         * @see {@link TryOp#Map()}
         */
        Map(Mapper, Args*) {
            try {
                return TryOp.Success(Mapper(this.Value, Args*))
            } catch as Err {
                return TryOp.Failure(Err)
            }
        }

        /**
         * @see {@link TryOp#FlatMap()}
         */
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

        /**
         * @see {@link TryOp#Transform()}
         */
        Transform(Mapper, Args*) => Mapper(this, Args*)

        /**
         * @see {@link TryOp#Get()}
         */
        Get() => this.Value

        /**
         * @see {@link TryOp#OrElse()}
         */
        OrElse(DefaultValue) {
            return this.Value
        }

        /**
         * @see {@link TryOp#OrElseGet()}
         */
        OrElseGet(RecoverFunction, *) => this.Value

        /**
         * @see {@link TryOp#OrElseRun()}
         */
        OrElseRun(Action, *) {
            ; nothing
        }

        /**
         * @see {@link TryOp#OrElseThrow()}
         */
        OrElseThrow(ErrorSupplier?, *) => this.Value

        /**
         * @see {@link TryOp#Recover()}
         */
        Recover(ErrorType, RecoverFunction, *) {
            return this
        }

        /**
         * @see {@link TryOp#RecoverAny()}
         */
        RecoverAny(RecoverFunction, *) {
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
        /**
         * Constructs a new failed try-operation that contains the given error.
         * 
         * @constructor
         * @param   {Error}  Err  an error
         * @returns {TryOp.Failure}
         * @example
         * ; TryOp.Success(42)
         * SuccessfulTry := TryOp.Failure(IndexError("out of bounds"))
         */
        static Call(Err) => (Object.Call)(this, Err)

        /**
         * Constructs a new failed try-operation that contains the given error.
         * 
         * @constructor
         * @param   {Error}  Err  an error
         * @returns {TryOp.Failure}
         * @example
         * ; TryOp.Success(42)
         * SuccessfulTry := TryOp.Failure(IndexError("out of bounds"))
         */
        __New(Err) {
            if (!(Err is Error)) {
                throw TypeError("Expected an Error",, Type(Err))
            }
            this.DefineProp("Value", { Get: (_) => Err })
        }

        /**
         * @see {@link TryOp#Succeeded}
         */
        Succeeded => false

        /**
         * @see {@link TryOp#Failed}
         */
        Failed => true

        /**
         * @see {@link TryOp#Then()}
         */
        Then(ThenFunction, *) => this

        /**
         * @see {@link TryOp#OnSuccess()}
         */
        OnSuccess(Action, *) => this

        /**
         * @see {@link TryOp#OnFailure()}
         */
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

        /**
         * @see {@link TryOp#RetainIf()}
         */
        RetainIf(Condition, *) => this

        /**
         * @see {@link TryOp#RemoveIf()}
         */
        RemoveIf(Condition, *) => this

        /**
         * @see {@link TryOp#Map()}
         */
        Map(Mapper, *) => this

        /**
         * @see {@link TryOp#FlatMap()}
         */
        FlatMap(Mapper, *) => this

        /**
         * @see {@link TryOp#Transform()}
         */
        Transform(Mapper, *) => this

        /**
         * @see {@link TryOp#Get()}
         */
        Get() {
            throw this.Value
        }

        /**
         * @see {@link TryOp#OrElse()}
         */
        OrElse(DefaultValue) => DefaultValue

        /**
         * @see {@link TryOp#OrElseGet()}
         */
        OrElseGet(Supplier, Args*) => Supplier(this.Value, Args*)
        
        /**
         * @see {@link TryOp#OrElseRun()}
         */
        OrElseRun(Action, Args*) {
            Action(Args*)
        }

        /**
         * @see {@link TryOp#OrElseThrow()}
         */
        OrElseThrow(ErrorSupplier?, Args*) {
            if (IsSet(ErrorSupplier)) {
                throw ErrorSupplier(this.Value, Args*)
            }
            throw this.Value
        }

        /**
         * @see {@link TryOp#Recover()}
         */
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

        /**
         * @see {@link TryOp#RecoverAny()}
         */
        RecoverAny(RecoverFunction, Args*) {
            GetMethod(RecoverFunction)
            try {
                return TryOp.Success(RecoverFunction(this.Value, Args*))
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

class AquaHotkey_Try extends AquaHotkey {
    static __New() {
        if (this == AquaHotkey_Try) {
            super.__New()
        }
    }

    class Object {
        /**
         * Tries to call this object with `Args*`, wrapped in a try-operation.
         * 
         * @param   {Any*}  Args  zero or more arguments
         * @returns {TryOp}
         * @example
         * FileContents := FileRead.TryCall("myFile.txt").OrElse("")
         */
        TryCall(Args*) {
            GetMethod(this)
            return TryOp(this, Args*)
        }
    }
}

;@endregion