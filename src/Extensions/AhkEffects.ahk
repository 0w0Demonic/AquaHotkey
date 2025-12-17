#Requires AutoHotkey >=v2.1-alpha.9
#Include "%A_LineFile%/../Effect.ahk"
/**
 * AquaHotkey - AhkEffects.ahk
 *
 * Author: 0w0Demonic
 *
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/AhkEffects.ahk
 *
 * ---
 *
 * **Overview**:
 *
 * AHK-specific effects for common async patterns. These wrap AutoHotkey's
 * callback-based APIs (SetTimer, OnEvent, Hotkey, etc.) into composable
 * effects that integrate with the Do-notation DSL.
 *
 * @example
 * ; Wait for Notepad, type text, close it
 * Do()
 *     .Then(AhkEffects.Run("notepad.exe"))
 *     .Let("hwnd", AhkEffects.WaitWindow("ahk_class Notepad"))
 *     .Then(AhkEffects.Delay(100))
 *     .Then(Effect.Pure(() => Send("Hello!")))
 *     .Then(AhkEffects.Delay(500))
 *     .Then(Effect.Pure(() => WinClose("ahk_class Notepad")))
 *     .Run()
 */

;@region AhkEffects
/**
 * Factory for AHK-specific effects.
 *
 * These effects handle common async patterns in AutoHotkey:
 * - Timer delays
 * - Window detection
 * - Hotkey triggers
 * - GUI events
 * - Clipboard monitoring
 * - Process execution
 */
class AhkEffects {

    ;@region Timer & Delay
    /**
     * Delay effect using SetTimer (non-blocking).
     * Alias for `Effect.Delay()`.
     *
     * @param {Integer} ms - Milliseconds to delay
     * @returns {Effect}
     */
    static Delay(ms) => Effect.Delay(ms)

    /**
     * Schedules a function to run after delay, returns immediately.
     * Unlike Delay, this doesn't wait - fires and forgets.
     *
     * @param {Func} fn - Function to execute
     * @param {Integer} ms - Delay in milliseconds
     * @returns {Effect}
     */
    static Schedule(fn, ms) => Effect("Schedule", {Fn: fn, Ms: ms})
    ;@endregion

    ;@region Window Effects
    /**
     * Waits for a window to exist.
     *
     * @param {String} title - Window title/criteria
     * @param {Integer} timeout - Timeout in ms (default 5000, 0 = infinite)
     * @param {Integer} interval - Check interval in ms (default 50)
     * @returns {Effect}
     */
    static WaitWindow(title, timeout := 5000, interval := 50) {
        return Effect("WaitWindow", {
            Title: title,
            Timeout: timeout,
            Interval: interval
        })
    }

    /**
     * Waits for a window to close/not exist.
     *
     * @param {String} title - Window title/criteria
     * @param {Integer} timeout - Timeout in ms (default 5000, 0 = infinite)
     * @param {Integer} interval - Check interval in ms (default 50)
     * @returns {Effect}
     */
    static WaitWindowClose(title, timeout := 5000, interval := 50) {
        return Effect("WaitWindowClose", {
            Title: title,
            Timeout: timeout,
            Interval: interval
        })
    }

    /**
     * Waits for a window to become active.
     *
     * @param {String} title - Window title/criteria
     * @param {Integer} timeout - Timeout in ms (default 5000)
     * @returns {Effect}
     */
    static WaitWindowActive(title, timeout := 5000, interval := 50) {
        return Effect("WaitWindowActive", {
            Title: title,
            Timeout: timeout,
            Interval: interval
        })
    }
    ;@endregion

    ;@region Hotkey Effects
    /**
     * Waits for a hotkey to be pressed. The hotkey is registered
     * and automatically unregistered after triggering once.
     *
     * @param {String} keyName - Hotkey definition (e.g., "^a", "F1")
     * @returns {Effect}
     */
    static WaitKey(keyName) => Effect("WaitKey", keyName)

    /**
     * Waits for any of the specified keys to be pressed.
     * Returns the key that was pressed.
     *
     * @param {Array} keys - Array of hotkey definitions
     * @returns {Effect}
     */
    static WaitAnyKey(keys*) => Effect("WaitAnyKey", keys)
    ;@endregion

    ;@region GUI Effects
    /**
     * Waits for a GUI control event to fire.
     * The handler is automatically removed after the event fires once.
     *
     * @param {Gui.Control} ctrl - The GUI control
     * @param {String} eventName - Event name (e.g., "Click", "Change")
     * @returns {Effect}
     */
    static GuiEvent(ctrl, eventName) {
        return Effect("GuiEvent", {
            Control: ctrl,
            Event: eventName
        })
    }

    /**
     * Waits for a GUI window event.
     *
     * @param {Gui} gui - The GUI object
     * @param {String} eventName - Event name (e.g., "Close", "Escape")
     * @returns {Effect}
     */
    static GuiWindowEvent(gui, eventName) {
        return Effect("GuiWindowEvent", {
            Gui: gui,
            Event: eventName
        })
    }
    ;@endregion

    ;@region Clipboard Effects
    /**
     * Waits for the clipboard to change.
     *
     * @returns {Effect}
     */
    static ClipboardChange() => Effect("ClipboardChange", "")

    /**
     * Sets clipboard content as an effect.
     *
     * @param {String} content - Content to put in clipboard
     * @returns {Effect}
     */
    static SetClipboard(content) => Effect("SetClipboard", content)
    ;@endregion

    ;@region Process Effects
    /**
     * Runs an external command/process.
     * Does not wait for completion.
     *
     * @param {String} cmd - Command to run
     * @param {String} workingDir - Working directory (optional)
     * @returns {Effect}
     */
    static Run(cmd, workingDir?) => Effect("Run", {
        Cmd: cmd,
        WorkingDir: workingDir ?? ""
    })

    /**
     * Runs an external command and waits for completion.
     * Returns the exit code as Result.
     *
     * @param {String} cmd - Command to run
     * @param {String} workingDir - Working directory (optional)
     * @returns {Effect}
     */
    static RunWait(cmd, workingDir?) => Effect("RunWait", {
        Cmd: cmd,
        WorkingDir: workingDir ?? ""
    })

    /**
     * Runs a command and captures its output.
     *
     * @param {String} cmd - Command to run
     * @returns {Effect}
     */
    static RunOutput(cmd) => Effect("RunOutput", cmd)
    ;@endregion

    ;@region Input Effects
    /**
     * Waits for user input via InputBox.
     *
     * @param {String} prompt - Prompt text
     * @param {String} title - Window title (optional)
     * @param {String} default - Default value (optional)
     * @returns {Effect}
     */
    static InputBox(prompt, title?, default?) {
        return Effect("InputBox", {
            Prompt: prompt,
            Title: title ?? "",
            Default: default ?? ""
        })
    }

    /**
     * Shows a MsgBox and waits for response.
     *
     * @param {String} text - Message text
     * @param {String} title - Window title (optional)
     * @param {String} options - MsgBox options (optional)
     * @returns {Effect}
     */
    static MsgBox(text, title?, options?) {
        return Effect("MsgBox", {
            Text: text,
            Title: title ?? "",
            Options: options ?? ""
        })
    }
    ;@endregion

    ;@region Condition Effects
    /**
     * Polls a condition until it becomes true.
     *
     * @param {Func} condition - Function returning true/false
     * @param {Integer} timeout - Timeout in ms (default 5000)
     * @param {Integer} interval - Poll interval in ms (default 50)
     * @returns {Effect}
     */
    static WaitUntil(condition, timeout := 5000, interval := 50) {
        return Effect("WaitUntil", {
            Condition: condition,
            Timeout: timeout,
            Interval: interval
        })
    }
    ;@endregion
}
;@endregion

;@region AhkEffectRunner
/**
 * Extended interpreter for AHK-specific effects.
 *
 * Handles all effects from `AhkEffects` plus the base effects
 * from `EffectRunner`.
 */
class AhkEffectRunner extends EffectRunner {

    /**
     * Interprets an effect into a continuation.
     *
     * @param {Effect} effect - The effect to interpret
     * @param {Map} ctx - Current context (optional)
     * @returns {Cont}
     */
    static Interpret(effect, ctx?) {
        ; Handle lazy effects
        if HasMethod(effect) {
            effect := effect(ctx?)
        }

        if !(effect is Effect) {
            throw TypeError("Expected Effect, got " . Type(effect), -1)
        }

        switch effect.Tag {

            ;@region Timer Effects
            case "Schedule":
                return Cont((k) => (
                    SetTimer(effect.Payload.Fn, -effect.Payload.Ms),
                    k(true)
                ))
            ;@endregion

            ;@region Window Effects
            case "WaitWindow":
                return Cont((k) => {
                    payload := effect.Payload
                    startTime := A_TickCount

                    check() {
                        if WinExist(payload.Title) {
                            SetTimer(check, 0)
                            k(Result.Ok({
                                Hwnd: WinGetID(payload.Title),
                                Title: WinGetTitle(payload.Title)
                            }))
                        } else if payload.Timeout > 0
                                && (A_TickCount - startTime > payload.Timeout) {
                            SetTimer(check, 0)
                            k(Result.Err("Timeout waiting for: " . payload.Title))
                        }
                    }
                    SetTimer(check, payload.Interval)
                })

            case "WaitWindowClose":
                return Cont((k) => {
                    payload := effect.Payload
                    startTime := A_TickCount

                    check() {
                        if !WinExist(payload.Title) {
                            SetTimer(check, 0)
                            k(Result.Ok(true))
                        } else if payload.Timeout > 0
                                && (A_TickCount - startTime > payload.Timeout) {
                            SetTimer(check, 0)
                            k(Result.Err("Timeout waiting for close: " . payload.Title))
                        }
                    }
                    SetTimer(check, payload.Interval)
                })

            case "WaitWindowActive":
                return Cont((k) => {
                    payload := effect.Payload
                    startTime := A_TickCount

                    check() {
                        if WinActive(payload.Title) {
                            SetTimer(check, 0)
                            k(Result.Ok({
                                Hwnd: WinGetID(payload.Title),
                                Title: WinGetTitle(payload.Title)
                            }))
                        } else if payload.Timeout > 0
                                && (A_TickCount - startTime > payload.Timeout) {
                            SetTimer(check, 0)
                            k(Result.Err("Timeout waiting for active: " . payload.Title))
                        }
                    }
                    SetTimer(check, payload.Interval)
                })
            ;@endregion

            ;@region Hotkey Effects
            case "WaitKey":
                return Cont((k) => {
                    keyName := effect.Payload
                    handler(_) {
                        Hotkey(keyName, "Off")
                        k({Key: keyName, Time: A_TickCount})
                    }
                    try {
                        Hotkey(keyName, handler, "On")
                    } catch as err {
                        k(Result.Err(err))
                    }
                })

            case "WaitAnyKey":
                return Cont((k) => {
                    keys := effect.Payload
                    done := false
                    handlers := Map()

                    cleanup() {
                        for keyName, _ in handlers {
                            try Hotkey(keyName, "Off")
                        }
                    }

                    for keyName in keys {
                        handler := (_) => {
                            if done {
                                return
                            }
                            done := true
                            cleanup()
                            k({Key: keyName, Time: A_TickCount})
                        }
                        handlers[keyName] := handler
                        try {
                            Hotkey(keyName, handler, "On")
                        } catch as err {
                            cleanup()
                            k(Result.Err(err))
                            return
                        }
                    }
                })
            ;@endregion

            ;@region GUI Effects
            case "GuiEvent":
                return Cont((k) => {
                    payload := effect.Payload
                    handler(ctrl, info*) {
                        ctrl.OnEvent(payload.Event, handler, 0)
                        k({Control: ctrl, Info: info, Event: payload.Event})
                    }
                    try {
                        payload.Control.OnEvent(payload.Event, handler)
                    } catch as err {
                        k(Result.Err(err))
                    }
                })

            case "GuiWindowEvent":
                return Cont((k) => {
                    payload := effect.Payload
                    handler(guiObj, info*) {
                        guiObj.OnEvent(payload.Event, handler, 0)
                        k({Gui: guiObj, Info: info, Event: payload.Event})
                    }
                    try {
                        payload.Gui.OnEvent(payload.Event, handler)
                    } catch as err {
                        k(Result.Err(err))
                    }
                })
            ;@endregion

            ;@region Clipboard Effects
            case "ClipboardChange":
                return Cont((k) => {
                    handler(type) {
                        OnClipboardChange(handler, 0)
                        k({Type: type, Content: A_Clipboard})
                    }
                    OnClipboardChange(handler)
                })

            case "SetClipboard":
                return Cont((k) => (
                    A_Clipboard := effect.Payload,
                    k(true)
                ))
            ;@endregion

            ;@region Process Effects
            case "Run":
                return Cont((k) => {
                    payload := effect.Payload
                    try {
                        pid := Run(payload.Cmd, payload.WorkingDir || unset)
                        k(Result.Ok({Pid: pid}))
                    } catch as err {
                        k(Result.Err(err))
                    }
                })

            case "RunWait":
                return Cont((k) => {
                    doRun() {
                        SetTimer(doRun, 0)
                        payload := effect.Payload
                        try {
                            exitCode := RunWait(payload.Cmd, payload.WorkingDir || unset)
                            k(Result.Ok({ExitCode: exitCode}))
                        } catch as err {
                            k(Result.Err(err))
                        }
                    }
                    SetTimer(doRun, -1)
                })

            case "RunOutput":
                return Cont((k) => {
                    doRun() {
                        SetTimer(doRun, 0)
                        try {
                            shell := ComObject("WScript.Shell")
                            exec := shell.Exec(effect.Payload)
                            output := exec.StdOut.ReadAll()
                            k(Result.Ok({
                                Output: output,
                                ExitCode: exec.ExitCode
                            }))
                        } catch as err {
                            k(Result.Err(err))
                        }
                    }
                    SetTimer(doRun, -1)
                })
            ;@endregion

            ;@region Input Effects
            case "InputBox":
                return Cont((k) => {
                    doInput() {
                        SetTimer(doInput, 0)
                        payload := effect.Payload
                        try {
                            ib := InputBox(payload.Prompt, payload.Title, , payload.Default)
                            if ib.Result == "OK" {
                                k(Result.Ok(ib.Value))
                            } else {
                                k(Result.Err("Cancelled"))
                            }
                        } catch as err {
                            k(Result.Err(err))
                        }
                    }
                    SetTimer(doInput, -1)
                })

            case "MsgBox":
                return Cont((k) => {
                    doMsg() {
                        SetTimer(doMsg, 0)
                        payload := effect.Payload
                        try {
                            result := MsgBox(payload.Text, payload.Title, payload.Options)
                            k(Result.Ok(result))
                        } catch as err {
                            k(Result.Err(err))
                        }
                    }
                    SetTimer(doMsg, -1)
                })
            ;@endregion

            ;@region Condition Effects
            case "WaitUntil":
                return Cont((k) => {
                    payload := effect.Payload
                    startTime := A_TickCount

                    check() {
                        try {
                            if payload.Condition() {
                                SetTimer(check, 0)
                                k(Result.Ok(true))
                                return
                            }
                        } catch as err {
                            SetTimer(check, 0)
                            k(Result.Err(err))
                            return
                        }

                        if payload.Timeout > 0
                                && (A_TickCount - startTime > payload.Timeout) {
                            SetTimer(check, 0)
                            k(Result.Err("Condition timeout"))
                        }
                    }
                    SetTimer(check, payload.Interval)
                })
            ;@endregion

            default:
                ; Delegate to parent for base effects
                return super.Interpret(effect, ctx?)
        }
    }
}
;@endregion

;@region Array Extensions for Effects
/**
 * Helper extensions for working with arrays of effects.
 */
class EffectArray {
    /**
     * Runs all effects in parallel, collecting results.
     *
     * @param {Array} effects - Array of effects
     * @param {EffectRunner} runner - The interpreter (optional)
     * @returns {Cont}
     */
    static Parallel(effects, runner?) {
        runner := runner ?? AhkEffectRunner
        return Cont((k) => {
            if effects.Length == 0 {
                k([])
                return
            }

            results := []
            results.Length := effects.Length
            remaining := effects.Length

            for i, eff in effects {
                runner.Interpret(eff).Run((val) => (
                    results[i] := val,
                    (--remaining == 0) && k(results)
                ))
            }
        })
    }

    /**
     * Runs effects, first to complete wins.
     *
     * @param {Array} effects - Array of effects
     * @param {EffectRunner} runner - The interpreter (optional)
     * @returns {Cont}
     */
    static Race(effects, runner?) {
        runner := runner ?? AhkEffectRunner
        return Cont((k) => {
            if effects.Length == 0 {
                k(Result.Err("Race with no effects"))
                return
            }

            done := false
            for eff in effects {
                runner.Interpret(eff).Run((val) => (
                    done || (done := true, k(val))
                ))
            }
        })
    }

    /**
     * Runs effects sequentially, collecting results.
     *
     * @param {Array} effects - Array of effects
     * @param {EffectRunner} runner - The interpreter (optional)
     * @returns {Cont}
     */
    static Sequence(effects, runner?) {
        runner := runner ?? AhkEffectRunner
        if effects.Length == 0 {
            return Cont.Of([])
        }

        return runner.Interpret(effects[1]).Then((first) => {
            if effects.Length == 1 {
                return Cont.Of([first])
            }
            rest := []
            loop effects.Length - 1 {
                rest.Push(effects[A_Index + 1])
            }
            return EffectArray.Sequence(rest, runner).Map((arr) => (
                arr.InsertAt(1, first),
                arr
            ))
        })
    }
}
;@endregion
