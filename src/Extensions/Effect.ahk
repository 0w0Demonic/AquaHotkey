#Requires AutoHotkey >=v2.1-alpha.9
/**
 * AquaHotkey - Effect.ahk
 *
 * Author: 0w0Demonic
 *
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/Effect.ahk
 *
 * ---
 *
 * **Overview**:
 *
 * An algebraic effect system that transforms AHK's callback-based async
 * patterns into declarative, composable effect chains. This eliminates
 * "callback hell" and enables sequential-looking code for inherently
 * asynchronous operations.
 *
 * **Core Components**:
 * - `Cont` - Continuation monad for suspended computations
 * - `Effect` - Tagged union describing effects
 * - `Result` - Railway-oriented error handling
 * - `Do` - Do-notation DSL for fluent effect chains
 * - `EffectRunner` - Interpreter that executes effects
 *
 * @example
 * Do()
 *     .Let("data",   Effect.Fetch("api.com/data"))
 *     .Let("parsed", Effect.Try(ctx => ParseJson(ctx["data"])))
 *     .Then(Effect.Delay(100))
 *     .Return(ctx => ctx["parsed"])
 *     .Run(result => MsgBox(result.IsOk ? result.Value : "Error"))
 */

;@region Cont
/**
 * The Continuation Monad.
 *
 * Wraps a computation that, instead of returning a value directly,
 * passes its result to a callback (the "continuation"). This inverts
 * control flow and enables composable async operations.
 *
 * A continuation is essentially: `(callback) => { ... callback(result) }`
 *
 * @example
 * ; Create a delayed computation
 * delayed := Cont((k) => SetTimer(() => k(42), -1000))
 *
 * ; Chain computations
 * delayed.Then(x => Cont.Of(x * 2)).Run(MsgBox)  ; Shows 84 after 1 second
 */
class Cont {
    /**
     * Constructs a new continuation from a runner function.
     *
     * The runner receives a callback `k` and should eventually call
     * `k(result)` to continue the computation.
     *
     * @param {Func} runner - Function of form `(k) => { ... k(result) }`
     */
    __New(runner) {
        if !HasMethod(runner) {
            throw TypeError("Cont requires a callable runner", -1, Type(runner))
        }
        this._runner := runner
    }

    /**
     * Executes this continuation with the given callback.
     *
     * @param {Func} k - Callback to receive the result
     */
    Run(k) {
        if !HasMethod(k) {
            throw TypeError("Run requires a callable callback", -1, Type(k))
        }
        this._runner(k)
    }

    /**
     * Monadic bind - chains this continuation with a function that
     * returns another continuation.
     *
     * When this continuation completes with value `a`, passes it to `f`,
     * which returns a new continuation, then continues with that.
     *
     * @example
     * Cont.Of(5)
     *     .Then(x => Cont.Of(x * 2))
     *     .Then(x => Cont.Of(x + 1))
     *     .Run(MsgBox)  ; Shows 11
     *
     * @param {Func} f - Function `(a) => Cont`
     * @returns {Cont}
     */
    Then(f) {
        return Cont((k) => this.Run((a) => f(a).Run(k)))
    }

    /**
     * Maps a function over the continuation's eventual value.
     *
     * @example
     * Cont.Of(5).Map(x => x * 2).Run(MsgBox)  ; Shows 10
     *
     * @param {Func} f - Function to apply to the value
     * @returns {Cont}
     */
    Map(f) {
        return this.Then((a) => Cont.Of(f(a)))
    }

    /**
     * Lifts a pure value into a continuation that immediately
     * passes it to the callback.
     *
     * @example
     * Cont.Of(42).Run(MsgBox)  ; Shows 42 immediately
     *
     * @param {Any} value - Value to lift
     * @returns {Cont}
     */
    static Of(value) => Cont((k) => k(value))

    /**
     * Creates a continuation that never completes.
     * Useful for racing operations.
     *
     * @returns {Cont}
     */
    static Never() => Cont((k) => 0)

    /**
     * Blocks and extracts the final value synchronously.
     *
     * WARNING: Only use when the continuation completes synchronously,
     * otherwise the result will be unset.
     *
     * @returns {Any}
     */
    Await() {
        result := unset
        this.Run((x) => result := x)
        if !IsSet(result) {
            throw Error("Cont.Await() called on async continuation")
        }
        return result
    }

    /**
     * Combines two continuations, running them in sequence.
     *
     * @param {Cont} other - Continuation to run after this one
     * @returns {Cont}
     */
    AndThen(other) {
        return this.Then((_) => other)
    }

    /**
     * Returns string representation.
     * @returns {String}
     */
    ToString() => "Cont { ... }"
}
;@endregion

;@region Result
/**
 * Railway-Oriented Programming result type.
 *
 * Represents either a successful value (`Ok`) or an error (`Err`).
 * Errors propagate through chains automatically without nested try/catch.
 *
 * @example
 * result := Result.Ok(42)
 * result.Map(x => x * 2).OrElse(0)  ; 84
 *
 * @example
 * result := Result.Err("Something went wrong")
 * result.Map(x => x * 2).OrElse(0)  ; 0 (error propagated, Map skipped)
 */
class Result {
    /**
     * Constructs a Result. Use `Result.Ok()` or `Result.Err()` instead.
     *
     * @param {String} tag - "Ok" or "Err"
     * @param {Any} payload - The value or error
     */
    __New(tag, payload) {
        this.Tag := tag
        this.IsOk := (tag == "Ok")
        this.IsErr := (tag == "Err")
        if this.IsOk {
            this.DefineProp("Value", {Get: (_) => payload})
        } else {
            this.DefineProp("Error", {Get: (_) => payload})
        }
    }

    /**
     * Creates a successful result containing `value`.
     *
     * @param {Any} value - The success value
     * @returns {Result}
     */
    static Ok(value) => Result("Ok", value)

    /**
     * Creates a failed result containing `error`.
     *
     * @param {Any} error - The error value
     * @returns {Result}
     */
    static Err(error) => Result("Err", error)

    /**
     * Wraps a function call in a Result, catching any errors.
     *
     * @example
     * result := Result.Try(() => JSON.Parse(data))
     *
     * @param {Func} fn - Function to execute
     * @param {Any*} args - Arguments to pass
     * @returns {Result}
     */
    static Try(fn, args*) {
        try {
            return Result.Ok(fn(args*))
        } catch as err {
            return Result.Err(err)
        }
    }

    /**
     * Maps a function over the success value.
     * If this is an Err, returns itself unchanged.
     *
     * @param {Func} fn - Function to apply
     * @returns {Result}
     */
    Map(fn) {
        if this.IsErr {
            return this
        }
        try {
            return Result.Ok(fn(this.Value))
        } catch as err {
            return Result.Err(err)
        }
    }

    /**
     * Flat maps a function that returns a Result.
     * If this is an Err, returns itself unchanged.
     *
     * @param {Func} fn - Function returning Result
     * @returns {Result}
     */
    FlatMap(fn) {
        if this.IsErr {
            return this
        }
        try {
            result := fn(this.Value)
            if !(result is Result) {
                throw TypeError("FlatMap function must return Result", -1)
            }
            return result
        } catch as err {
            return Result.Err(err)
        }
    }

    /**
     * Returns the value if Ok, otherwise returns `default`.
     *
     * @param {Any} default - Default value for Err case
     * @returns {Any}
     */
    OrElse(default) => this.IsOk ? this.Value : default

    /**
     * Returns the value if Ok, otherwise calls `fn` to get default.
     *
     * @param {Func} fn - Function to produce default
     * @returns {Any}
     */
    OrElseGet(fn) => this.IsOk ? this.Value : fn()

    /**
     * Returns the value if Ok, otherwise throws the error.
     *
     * @returns {Any}
     */
    OrThrow() {
        if this.IsErr {
            throw (this.Error is Error) ? this.Error : Error(String(this.Error))
        }
        return this.Value
    }

    /**
     * Transforms the error if this is Err.
     *
     * @param {Func} fn - Function to transform error
     * @returns {Result}
     */
    MapErr(fn) {
        return this.IsErr ? Result.Err(fn(this.Error)) : this
    }

    /**
     * Executes `onOk` if Ok, `onErr` if Err.
     *
     * @param {Func} onOk - Handler for success
     * @param {Func} onErr - Handler for error
     * @returns {Any}
     */
    Match(onOk, onErr) {
        return this.IsOk ? onOk(this.Value) : onErr(this.Error)
    }

    /**
     * Returns string representation.
     * @returns {String}
     */
    ToString() {
        if this.IsOk {
            return "Result.Ok(" . String(this.Value) . ")"
        }
        return "Result.Err(" . String(this.Error) . ")"
    }
}
;@endregion

;@region Effect
/**
 * Tagged union describing an effect.
 *
 * Effects are *values* that describe what should happen, not the
 * execution itself. The `EffectRunner` interprets effects into
 * actual operations.
 *
 * @example
 * ; These are descriptions, not executions
 * delay := Effect.Delay(1000)
 * fetch := Effect.Fetch("https://api.com")
 * tryOp := Effect.Try(() => riskyOperation())
 */
class Effect {
    /**
     * Constructs an Effect with a tag and payload.
     * Prefer using the static constructors.
     *
     * @param {String} tag - Effect type tag
     * @param {Any} payload - Effect data
     */
    __New(tag, payload?) {
        this.Tag := tag
        this.Payload := payload ?? ""
    }

    ;@region Constructors
    /**
     * Lifts a pure value or thunk into an effect.
     * If given a function, it will be called when interpreted.
     *
     * @param {Any|Func} value - Value or thunk
     * @returns {Effect}
     */
    static Pure(value) => Effect("Pure", value)

    /**
     * Creates a delay effect that waits `ms` milliseconds.
     *
     * @param {Integer} ms - Milliseconds to delay
     * @returns {Effect}
     */
    static Delay(ms) {
        if !IsInteger(ms) || ms < 0 {
            throw ValueError("Delay requires non-negative integer", -1, ms)
        }
        return Effect("Delay", ms)
    }

    /**
     * Wraps a function in a try/catch, returning Result.
     *
     * @param {Func} fn - Function to try
     * @returns {Effect}
     */
    static Try(fn) {
        if !HasMethod(fn) {
            throw TypeError("Try requires a callable", -1, Type(fn))
        }
        return Effect("Try", fn)
    }

    /**
     * Creates an HTTP GET fetch effect.
     *
     * @param {String} url - URL to fetch
     * @returns {Effect}
     */
    static Fetch(url) {
        if !IsObject(url) && !InStr(url, "://") {
            url := "https://" . url
        }
        return Effect("Fetch", url)
    }

    /**
     * Creates a file read effect.
     *
     * @param {String} path - File path to read
     * @returns {Effect}
     */
    static ReadFile(path) => Effect("ReadFile", path)

    /**
     * Creates a file write effect.
     *
     * @param {String} path - File path
     * @param {String} content - Content to write
     * @returns {Effect}
     */
    static WriteFile(path, content) => Effect("WriteFile", {
        Path: path,
        Content: content
    })

    /**
     * Creates an effect that logs a message.
     *
     * @param {String} message - Message to log
     * @returns {Effect}
     */
    static Log(message) => Effect("Log", message)

    /**
     * Creates an effect that does nothing (unit).
     *
     * @returns {Effect}
     */
    static Unit() => Effect("Pure", "")
    ;@endregion

    /**
     * Returns string representation.
     * @returns {String}
     */
    ToString() => "Effect." . this.Tag . "(" . String(this.Payload) . ")"
}
;@endregion

;@region Do
/**
 * Do-notation DSL for fluent effect chains.
 *
 * Builds a computation graph that reads like sequential code but
 * compiles to properly chained continuations.
 *
 * @example
 * Do()
 *     .Let("x", Effect.Pure(5))
 *     .Let("y", Effect.Pure(10))
 *     .Then(Effect.Delay(100))
 *     .Return(ctx => ctx["x"] + ctx["y"])
 *     .Run(MsgBox)  ; Shows 15 after 100ms
 */
class Do {
    /**
     * Creates a new Do-notation builder.
     */
    __New() {
        this._steps := []
    }

    /**
     * Binds an effect result to a named variable in the context.
     *
     * The effect can be:
     * - An `Effect` object
     * - A function `(ctx) => Effect` for dynamic effects
     *
     * @param {String} name - Variable name in context
     * @param {Effect|Func} effect - Effect or effect-producing function
     * @returns {Do} this (for chaining)
     */
    Let(name, effect) {
        this._steps.Push({
            Type: "Let",
            Name: name,
            Effect: effect
        })
        return this
    }

    /**
     * Performs an effect, discarding its result.
     *
     * @param {Effect|Func} effect - Effect to perform
     * @returns {Do} this (for chaining)
     */
    Then(effect) {
        this._steps.Push({
            Type: "Then",
            Effect: effect
        })
        return this
    }

    /**
     * Conditional branching within the chain.
     *
     * @param {Func} cond - Condition function `(ctx) => Boolean`
     * @param {Do} thenDo - Do-block if condition is true
     * @param {Do} elseDo - Do-block if condition is false (optional)
     * @returns {Do} this (for chaining)
     */
    When(cond, thenDo, elseDo?) {
        this._steps.Push({
            Type: "When",
            Cond: cond,
            ThenBranch: thenDo,
            ElseBranch: elseDo ?? Do()
        })
        return this
    }

    /**
     * Specifies the final return value of the computation.
     *
     * @param {Func} fn - Function `(ctx) => value`
     * @returns {Do} this (for chaining)
     */
    Return(fn) {
        this._steps.Push({
            Type: "Return",
            Fn: fn
        })
        return this
    }

    /**
     * Compiles this Do-block into a Continuation.
     *
     * @param {EffectRunner} runner - The interpreter to use (default: EffectRunner)
     * @returns {Cont}
     */
    Compile(runner?) {
        runner := runner ?? EffectRunner
        ctx := Map()
        return this._CompileSteps(1, ctx, runner)
    }

    /**
     * Compiles and runs this Do-block.
     *
     * @param {Func} onComplete - Callback for final result (optional)
     * @param {EffectRunner} runner - The interpreter to use (optional)
     * @returns {Any} Result if onComplete not provided and sync
     */
    Run(onComplete?, runner?) {
        runner := runner ?? EffectRunner
        cont := this.Compile(runner)
        if IsSet(onComplete) {
            cont.Run(onComplete)
            return
        }
        return cont.Await()
    }

    /**
     * Internal: compiles steps recursively.
     */
    _CompileSteps(i, ctx, runner) {
        if i > this._steps.Length {
            return Cont.Of(ctx)
        }

        step := this._steps[i]

        switch step.Type {
            case "Let":
                eff := HasMethod(step.Effect) ? step.Effect(ctx) : step.Effect
                return runner.Interpret(eff, ctx).Then((val) => (
                    ctx[step.Name] := val,
                    this._CompileSteps(i + 1, ctx, runner)
                ))

            case "Then":
                eff := HasMethod(step.Effect) ? step.Effect(ctx) : step.Effect
                return runner.Interpret(eff, ctx).Then((_) =>
                    this._CompileSteps(i + 1, ctx, runner)
                )

            case "When":
                branch := step.Cond(ctx) ? step.ThenBranch : step.ElseBranch
                return branch.Compile(runner).Then((_) =>
                    this._CompileSteps(i + 1, ctx, runner)
                )

            case "Return":
                return Cont.Of(step.Fn(ctx))

            default:
                throw ValueError("Unknown step type: " . step.Type)
        }
    }

    /**
     * Returns string representation.
     * @returns {String}
     */
    ToString() => "Do { " . this._steps.Length . " steps }"
}
;@endregion

;@region EffectRunner
/**
 * Base interpreter that executes effects.
 *
 * Pattern matches on effect tags to produce continuations.
 * Extend this class to add custom effect handlers.
 *
 * @example
 * class MyRunner extends EffectRunner {
 *     static Interpret(effect, ctx?) {
 *         if effect.Tag == "MyCustomEffect" {
 *             return Cont((k) => { ... k(result) })
 *         }
 *         return super.Interpret(effect, ctx?)
 *     }
 * }
 */
class EffectRunner {
    /**
     * Interprets an effect into a continuation.
     *
     * @param {Effect} effect - The effect to interpret
     * @param {Map} ctx - Current context (optional)
     * @returns {Cont}
     */
    static Interpret(effect, ctx?) {
        ; Handle lazy effects (functions needing context)
        if HasMethod(effect) {
            effect := effect(ctx?)
        }

        if !(effect is Effect) {
            throw TypeError("Expected Effect, got " . Type(effect), -1)
        }

        switch effect.Tag {
            case "Pure":
                val := effect.Payload
                if HasMethod(val) {
                    try {
                        return Cont.Of(val())
                    } catch as err {
                        return Cont.Of(Result.Err(err))
                    }
                }
                return Cont.Of(val)

            case "Delay":
                return Cont((k) => {
                    timer := () => (
                        SetTimer(timer, 0),
                        k(true)
                    )
                    SetTimer(timer, -effect.Payload)
                })

            case "Try":
                return Cont((k) => {
                    try {
                        result := effect.Payload()
                        k(Result.Ok(result))
                    } catch as err {
                        k(Result.Err(err))
                    }
                })

            case "Fetch":
                return Cont((k) => {
                    doFetch() {
                        SetTimer(doFetch, 0)
                        try {
                            whr := ComObject("WinHttp.WinHttpRequest.5.1")
                            whr.Open("GET", effect.Payload, false)
                            whr.Send()
                            k(Result.Ok(whr.ResponseText))
                        } catch as err {
                            k(Result.Err(err))
                        }
                    }
                    SetTimer(doFetch, -1)
                })

            case "ReadFile":
                return Cont((k) => {
                    doRead() {
                        SetTimer(doRead, 0)
                        try {
                            k(Result.Ok(FileRead(effect.Payload)))
                        } catch as err {
                            k(Result.Err(err))
                        }
                    }
                    SetTimer(doRead, -1)
                })

            case "WriteFile":
                return Cont((k) => {
                    doWrite() {
                        SetTimer(doWrite, 0)
                        try {
                            FileAppend(effect.Payload.Content, effect.Payload.Path)
                            k(Result.Ok(true))
                        } catch as err {
                            k(Result.Err(err))
                        }
                    }
                    SetTimer(doWrite, -1)
                })

            case "Log":
                return Cont((k) => (
                    OutputDebug("[Effect.Log] " . effect.Payload),
                    k(true)
                ))

            default:
                throw ValueError("Unknown effect tag: " . effect.Tag, -1)
        }
    }

    /**
     * Runs a Do-block with this interpreter.
     *
     * @param {Do} doBlock - The Do-block to run
     * @param {Func} onComplete - Callback for result (optional)
     * @returns {Any}
     */
    static Run(doBlock, onComplete?) {
        cont := doBlock.Compile(this)
        if IsSet(onComplete) {
            cont.Run(onComplete)
            return
        }
        return cont.Await()
    }
}
;@endregion
