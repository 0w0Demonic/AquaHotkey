#Requires AutoHotkey >=v2.1-alpha.9
#Include "%A_LineFile%/../AhkEffects.ahk"
#Include "%A_LineFile%/../../Core/AquaHotkey.ahk"
/**
 * AquaHotkey - EffectExtensions.ahk
 *
 * Author: 0w0Demonic
 *
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/EffectExtensions.ahk
 *
 * ---
 *
 * **Overview**:
 *
 * Extends native AHK types with effect capabilities via AquaHotkey's
 * prototype injection. This makes effects feel like a first-class
 * language feature.
 *
 * @example
 * ; Functions become effectful
 * MyFunction.TryEffect(arg1, arg2)
 *
 * ; Values lift naturally
 * "Hello".Pure()
 *
 * ; Strings fetch themselves
 * "https://api.com/data".Fetch()
 *
 * ; Arrays run in parallel
 * [Effect.Delay(100), Effect.Delay(200)].Parallel()
 */

;@region AquaHotkey_Effects
class AquaHotkey_Effects extends AquaHotkey {

    ;@region Func Extensions
    /**
     * Extensions for Func objects to lift functions into effects.
     */
    class Func {
        /**
         * Wraps function execution in a pure effect.
         * The function is called when the effect is interpreted.
         *
         * @example
         * GetTime() => A_Now
         * Do()
         *     .Let("time", GetTime.Effect())
         *     .Return(ctx => ctx["time"])
         *     .Run(MsgBox)
         *
         * @param {Any*} args - Arguments to pass to function
         * @returns {Effect}
         */
        Effect(args*) {
            fn := this
            return Effect.Pure(() => fn(args*))
        }

        /**
         * Wraps function in a try effect (catches errors).
         * Returns a Result.Ok or Result.Err.
         *
         * @example
         * RiskyOperation.TryEffect().Run(result =>
         *     result.Match(
         *         val => MsgBox("Success: " . val),
         *         err => MsgBox("Error: " . err.Message)
         *     )
         * )
         *
         * @param {Any*} args - Arguments to pass to function
         * @returns {Effect}
         */
        TryEffect(args*) {
            fn := this
            return Effect.Try(() => fn(args*))
        }

        /**
         * Creates a delayed version of the function.
         * Returns a Do-block that delays then executes.
         *
         * @example
         * MsgBox.Delayed(1000, "Hello!").Run()  ; Shows after 1 second
         *
         * @param {Integer} ms - Delay in milliseconds
         * @param {Any*} args - Arguments to pass to function
         * @returns {Do}
         */
        Delayed(ms, args*) {
            fn := this
            return Do()
                .Then(Effect.Delay(ms))
                .Let("result", fn.Effect(args*))
                .Return(ctx => ctx["result"])
        }

        /**
         * Lifts this function to work on Result values.
         * If input is Err, propagates error. If Ok, applies function.
         *
         * @example
         * double := (x => x * 2).LiftResult()
         * double(Result.Ok(5))   ; Result.Ok(10)
         * double(Result.Err("")) ; Result.Err("")
         *
         * @returns {Func}
         */
        LiftResult() {
            fn := this
            return (result) => result.Map(fn)
        }

        /**
         * Composes this function with another: (f >> g)(x) = g(f(x))
         *
         * @example
         * addOne := x => x + 1
         * double := x => x * 2
         * addOneThenDouble := addOne.AndThen(double)
         * addOneThenDouble(5)  ; 12
         *
         * @param {Func} g - Function to compose with
         * @returns {Func}
         */
        AndThen(g) {
            f := this
            return (x*) => g(f(x*))
        }

        /**
         * Composes this function with another: (f << g)(x) = f(g(x))
         *
         * @example
         * addOne := x => x + 1
         * double := x => x * 2
         * doubleThenAddOne := addOne.Compose(double)
         * doubleThenAddOne(5)  ; 11
         *
         * @param {Func} g - Function to compose with
         * @returns {Func}
         */
        Compose(g) {
            f := this
            return (x*) => f(g(x*))
        }
    }
    ;@endregion

    ;@region Any Extensions
    /**
     * Extensions for Any - allows all values to enter the effect world.
     */
    class Any {
        /**
         * Lifts this value into a pure effect.
         *
         * @example
         * 42.Pure()  ; Effect containing 42
         *
         * @returns {Effect}
         */
        Pure() => Effect.Pure(this)

        /**
         * Pipes this value into a function that produces an effect or Do-block.
         *
         * @example
         * "config.json".Into(path => Do()
         *     .Let("content", Effect.ReadFile(path))
         *     .Return(ctx => ctx["content"])
         * ).Run(MsgBox)
         *
         * @param {Func} effectBuilder - Function `(value) => Effect|Do`
         * @returns {Effect|Do}
         */
        Into(effectBuilder) {
            return effectBuilder(this)
        }

        /**
         * Wraps this value in a Result.Ok.
         *
         * @returns {Result}
         */
        Ok() => Result.Ok(this)

        /**
         * Wraps this value in a Result.Err.
         *
         * @returns {Result}
         */
        Err() => Result.Err(this)
    }
    ;@endregion

    ;@region Array Extensions
    /**
     * Extensions for Array to support parallel/sequential effect execution.
     */
    class Array {
        /**
         * Runs all effects in this array in parallel, collecting results.
         * All effects start immediately; completes when all finish.
         *
         * @example
         * [
         *     "api.com/users".Fetch(),
         *     "api.com/posts".Fetch(),
         *     "api.com/comments".Fetch()
         * ].Parallel().Run(results => MsgBox(results.Length . " fetched"))
         *
         * @param {EffectRunner} runner - Interpreter to use (optional)
         * @returns {Cont}
         */
        Parallel(runner?) {
            return EffectArray.Parallel(this, runner?)
        }

        /**
         * Runs effects in this array, first to complete wins.
         * Useful for timeouts or multiple sources.
         *
         * @example
         * [
         *     AhkEffects.GuiEvent(btnOk, "Click"),
         *     AhkEffects.GuiEvent(btnCancel, "Click")
         * ].Race().Run(result => MsgBox("Clicked: " . result.Control.Text))
         *
         * @param {EffectRunner} runner - Interpreter to use (optional)
         * @returns {Cont}
         */
        Race(runner?) {
            return EffectArray.Race(this, runner?)
        }

        /**
         * Runs effects in this array sequentially, collecting results.
         * Each effect waits for the previous to complete.
         *
         * @example
         * [
         *     Effect.Delay(100),
         *     Effect.Delay(200),
         *     Effect.Delay(300)
         * ].Sequence().Run(_ => MsgBox("All delays complete"))
         *
         * @param {EffectRunner} runner - Interpreter to use (optional)
         * @returns {Cont}
         */
        Sequence(runner?) {
            return EffectArray.Sequence(this, runner?)
        }

        /**
         * Converts this array of values into an array of pure effects.
         *
         * @example
         * [1, 2, 3].ToPureEffects()  ; [Effect.Pure(1), Effect.Pure(2), Effect.Pure(3)]
         *
         * @returns {Array}
         */
        ToPureEffects() {
            result := []
            for val in this {
                result.Push(Effect.Pure(val))
            }
            return result
        }
    }
    ;@endregion

    ;@region String Extensions
    /**
     * Extensions for String - common effect patterns for strings.
     */
    class String {
        /**
         * Creates an HTTP GET fetch effect for this URL.
         *
         * @example
         * "https://api.github.com/users/octocat"
         *     .Fetch()
         *     .Run(result => result.Match(
         *         data => MsgBox(data),
         *         err => MsgBox("Error: " . err)
         *     ))
         *
         * @returns {Effect}
         */
        Fetch() => Effect.Fetch(this)

        /**
         * Creates a file read effect for this path.
         *
         * @example
         * "config.json".ReadFileEffect().Run(result =>
         *     result.Match(MsgBox, err => MsgBox("Read failed"))
         * )
         *
         * @returns {Effect}
         */
        ReadFileEffect() => Effect.ReadFile(this)

        /**
         * Creates a file write effect for this path.
         *
         * @example
         * "output.txt".WriteFileEffect("Hello, World!").Run()
         *
         * @param {String} content - Content to write
         * @returns {Effect}
         */
        WriteFileEffect(content) => Effect.WriteFile(this, content)

        /**
         * Creates a Run effect for this command.
         *
         * @example
         * "notepad.exe".RunEffect().Run()
         *
         * @param {String} workingDir - Working directory (optional)
         * @returns {Effect}
         */
        RunEffect(workingDir?) => AhkEffects.Run(this, workingDir?)

        /**
         * Creates a RunWait effect for this command.
         *
         * @param {String} workingDir - Working directory (optional)
         * @returns {Effect}
         */
        RunWaitEffect(workingDir?) => AhkEffects.RunWait(this, workingDir?)

        /**
         * Creates a WaitWindow effect for this title.
         *
         * @example
         * "ahk_class Notepad".WaitWindowEffect(3000).Run(result =>
         *     result.Match(
         *         win => MsgBox("Found: " . win.Hwnd),
         *         _ => MsgBox("Timeout")
         *     )
         * )
         *
         * @param {Integer} timeout - Timeout in ms (default 5000)
         * @returns {Effect}
         */
        WaitWindowEffect(timeout := 5000) {
            return AhkEffects.WaitWindow(this, timeout)
        }
    }
    ;@endregion

    ;@region Integer Extensions
    /**
     * Extensions for Integer - delay patterns.
     */
    class Integer {
        /**
         * Creates a delay effect for this many milliseconds.
         *
         * @example
         * 1000.DelayEffect().Run(_ => MsgBox("1 second passed"))
         *
         * @returns {Effect}
         */
        DelayEffect() => Effect.Delay(this)

        /**
         * Creates a delay effect for this many seconds.
         *
         * @example
         * 5.SecondsDelay().Run(_ => MsgBox("5 seconds passed"))
         *
         * @returns {Effect}
         */
        SecondsDelay() => Effect.Delay(this * 1000)
    }
    ;@endregion

    ;@region Map Extensions
    /**
     * Extensions for Map - context manipulation in Do-blocks.
     */
    class Map {
        /**
         * Creates a new map with an additional key-value pair (immutable).
         *
         * @example
         * ctx := Map("a", 1)
         * newCtx := ctx.With("b", 2)  ; Map("a", 1, "b", 2)
         *
         * @param {Any} key - Key to add
         * @param {Any} value - Value to add
         * @returns {Map}
         */
        With(key, value) {
            result := Map()
            for k, v in this {
                result[k] := v
            }
            result[key] := value
            return result
        }

        /**
         * Creates a new map without the specified key (immutable).
         *
         * @param {Any} key - Key to remove
         * @returns {Map}
         */
        Without(key) {
            result := Map()
            for k, v in this {
                if k != key {
                    result[k] := v
                }
            }
            return result
        }

        /**
         * Gets a value, returning Result.Ok or Result.Err.
         *
         * @param {Any} key - Key to look up
         * @returns {Result}
         */
        GetResult(key) {
            if this.Has(key) {
                return Result.Ok(this[key])
            }
            return Result.Err("Key not found: " . String(key))
        }
    }
    ;@endregion
}
;@endregion

;@region Gui Extensions (Separate class to avoid conflicts)
/**
 * GUI-specific effect extensions.
 * These are loaded separately to work with Gui controls.
 */
class AquaHotkey_GuiEffects extends AquaHotkey {

    class Gui {
        class Control {
            /**
             * Creates an effect that waits for this control's event.
             *
             * @example
             * btn := myGui.AddButton("w100", "Click Me")
             * btn.EventEffect("Click").Run(result =>
             *     MsgBox("Button clicked!")
             * )
             *
             * @param {String} eventName - Event to wait for
             * @returns {Effect}
             */
            EventEffect(eventName) {
                return AhkEffects.GuiEvent(this, eventName)
            }
        }
    }
}
;@endregion
