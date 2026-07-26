# Effect System Design for AquaHotkey

**Date:** 2025-12-16
**Status:** Approved for Implementation
**Target:** AutoHotkey v2.1-alpha

## Overview

An algebraic effect system that transforms AHK's callback-based async patterns into declarative, composable effect chains. This eliminates "callback hell" and enables sequential-looking code for inherently asynchronous operations.

## Philosophy

The core insight: separate **describing** effects from **executing** them.

- Effects are **values** that describe what should happen
- An **interpreter** runs effects and handles them appropriately
- **Continuations** chain effects together without nesting callbacks

### Before (Callback Hell)
```ahk
FetchData("api.com", (data) => {
    ParseJson(data, (parsed) => {
        SaveFile(parsed, (saved) => {
            MsgBox("Done!")  ; 3 levels deep
        })
    })
})
```

### After (Effect System)
```ahk
Do()
    .Let("data",   Effect.Fetch("api.com"))
    .Let("parsed", Effect.Try(ctx => ParseJson(ctx["data"])))
    .Let("saved",  Effect.Write("output.json", ctx => ctx["parsed"]))
    .Return(_ => "Done!")
    .Run(MsgBox)
```

---

## Core Data Structures

### 1. Continuation Monad

The foundation. Wraps a computation that passes its result to a callback.

```ahk
class Cont {
    __New(Run) {
        this.Run := Run
    }

    Then(f) {
        return Cont((k) => this.Run((a) => f(a).Run(k)))
    }

    static Of(value) => Cont((k) => k(value))

    Await() {
        result := unset
        this.Run((x) => result := x)
        return result
    }
}
```

**Key Methods:**
- `Cont(fn)` - Create continuation from `(callback) => {...}`
- `.Then(f)` - Chain: when done, pass result to `f`, continue with its result
- `Cont.Of(v)` - Lift pure value into continuation
- `.Await()` - Block and extract final value (when safe)

### 2. Effect (Tagged Union)

Describes what kind of effect without executing it.

```ahk
class Effect {
    __New(tag, payload) {
        this.Tag := tag
        this.Payload := payload
    }

    ; Constructors
    static Pure(value)      => Effect("Pure", value)
    static Delay(ms)        => Effect("Delay", ms)
    static Try(fn)          => Effect("Try", fn)
    static Async(promise)   => Effect("Async", promise)
    static Fetch(url)       => Effect("Fetch", url)
    static ReadFile(path)   => Effect("ReadFile", path)
    static WriteFile(p, c)  => Effect("WriteFile", {Path: p, Content: c})
}
```

### 3. Result (Railway-Oriented Programming)

Errors flow through the chain without nested try/catch.

```ahk
class Result {
    __New(tag, payload) {
        this.Tag := tag
        this.IsOk := (tag == "Ok")
        if this.IsOk {
            this.Value := payload
        } else {
            this.Error := payload
        }
    }

    static Ok(value) => Result("Ok", value)
    static Err(error) => Result("Err", error)

    Map(fn) => this.IsOk ? Result.Ok(fn(this.Value)) : this
    FlatMap(fn) => this.IsOk ? fn(this.Value) : this
    OrElse(default) => this.IsOk ? this.Value : default
    OrThrow() {
        if !this.IsOk
            throw this.Error
        return this.Value
    }
}
```

---

## Do-Notation DSL

Fluent builder that compiles to continuation chains.

```ahk
class Do {
    __New() {
        this.Steps := []
    }

    Let(name, effect) {
        this.Steps.Push({Type: "Let", Name: name, Effect: effect})
        return this
    }

    Then(effect) {
        this.Steps.Push({Type: "Then", Effect: effect})
        return this
    }

    When(cond, thenDo, elseDo?) {
        this.Steps.Push({Type: "When", Cond: cond, Then: thenDo, Else: elseDo?})
        return this
    }

    Return(fn) {
        this.Steps.Push({Type: "Return", Fn: fn})
        return this
    }

    Compile() {
        ctx := Map()
        return this._CompileSteps(1, ctx)
    }

    Run(onComplete?) {
        return EffectRunner.Run(this, onComplete?)
    }

    _CompileSteps(i, ctx) {
        if i > this.Steps.Length
            return Cont.Of(ctx)

        step := this.Steps[i]
        switch step.Type {
            case "Let":
                return EffectRunner.Interpret(step.Effect, ctx).Then((val) => (
                    ctx[step.Name] := val,
                    this._CompileSteps(i + 1, ctx)
                ))
            case "Then":
                return EffectRunner.Interpret(step.Effect, ctx).Then((_) =>
                    this._CompileSteps(i + 1, ctx)
                )
            case "When":
                branch := step.Cond(ctx) ? step.Then : (step.Else ?? Do())
                return branch.Compile().Then((_) =>
                    this._CompileSteps(i + 1, ctx)
                )
            case "Return":
                return Cont.Of(step.Fn(ctx))
        }
    }
}
```

---

## Effect Interpreter

Pattern matches on effect tags to produce continuations.

```ahk
class EffectRunner {
    static Interpret(effect, ctx?) {
        ; Handle lazy effects (functions that need context)
        if HasMethod(effect)
            effect := effect(ctx?)

        switch effect.Tag {
            case "Pure":
                return Cont.Of(effect.Payload)

            case "Delay":
                return Cont((k) => SetTimer(() => (
                    SetTimer(A_ThisFunc, 0),
                    k(true)
                ), -effect.Payload))

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
                    SetTimer(() => {
                        try {
                            whr := ComObject("WinHttp.WinHttpRequest.5.1")
                            whr.Open("GET", effect.Payload, true)
                            whr.Send()
                            whr.WaitForResponse()
                            k(Result.Ok(whr.ResponseText))
                        } catch as err {
                            k(Result.Err(err))
                        }
                    }, -1)
                })

            case "ReadFile":
                return Cont((k) => {
                    SetTimer(() => {
                        try {
                            k(Result.Ok(FileRead(effect.Payload)))
                        } catch as err {
                            k(Result.Err(err))
                        }
                    }, -1)
                })

            case "WriteFile":
                return Cont((k) => {
                    SetTimer(() => {
                        try {
                            FileAppend(effect.Payload.Content, effect.Payload.Path)
                            k(Result.Ok(true))
                        } catch as err {
                            k(Result.Err(err))
                        }
                    }, -1)
                })
        }
    }

    static Run(doBlock, onComplete?) {
        cont := doBlock.Compile()
        if IsSet(onComplete) {
            cont.Run(onComplete)
        } else {
            return cont.Await()
        }
    }
}
```

---

## AHK-Specific Effects

Handlers for common AHK async patterns.

```ahk
class AhkEffects {
    ; Timer delay
    static Delay(ms) => Effect("Delay", ms)

    ; Wait for hotkey
    static WaitKey(keyName) => Effect("WaitKey", keyName)

    ; Wait for window
    static WaitWindow(title, timeout := 5000) => Effect("WaitWindow", {
        Title: title,
        Timeout: timeout
    })

    ; GUI event
    static GuiEvent(ctrl, eventName) => Effect("GuiEvent", {
        Control: ctrl,
        Event: eventName
    })

    ; Clipboard change
    static ClipboardChange() => Effect("ClipboardChange", "")

    ; Run process
    static RunWait(cmd) => Effect("RunWait", cmd)
}
```

**Extended Interpreter:**

```ahk
class AhkEffectRunner extends EffectRunner {
    static Interpret(effect, ctx?) {
        switch effect.Tag {
            case "WaitKey":
                return Cont((k) => {
                    handler(_) {
                        Hotkey(effect.Payload, "Off")
                        k(A_ThisHotkey)
                    }
                    Hotkey(effect.Payload, handler, "On")
                })

            case "WaitWindow":
                return Cont((k) => {
                    payload := effect.Payload
                    startTime := A_TickCount
                    check() {
                        if WinExist(payload.Title) {
                            SetTimer(check, 0)
                            k(Result.Ok(WinGetID(payload.Title)))
                        } else if (A_TickCount - startTime > payload.Timeout) {
                            SetTimer(check, 0)
                            k(Result.Err("Timeout: " . payload.Title))
                        }
                    }
                    SetTimer(check, 50)
                })

            case "GuiEvent":
                return Cont((k) => {
                    payload := effect.Payload
                    handler(ctrl, info*) {
                        ctrl.OnEvent(payload.Event, handler, 0)
                        k({Control: ctrl, Info: info})
                    }
                    payload.Control.OnEvent(payload.Event, handler)
                })

            case "ClipboardChange":
                return Cont((k) => {
                    handler(type) {
                        OnClipboardChange(handler, 0)
                        k({Type: type, Content: A_Clipboard})
                    }
                    OnClipboardChange(handler, 1)
                })

            default:
                return super.Interpret(effect, ctx?)
        }
    }
}
```

---

## AquaHotkey Integration

Extend native types to support effects.

```ahk
class AquaHotkey_Effects extends AquaHotkey {

    class Func {
        ; Wrap function in effect
        Effect(args*) {
            fn := this
            return Effect.Pure(() => fn(args*))
        }

        ; Wrap in try effect
        TryEffect(args*) {
            fn := this
            return Effect.Try(() => fn(args*))
        }

        ; Delay then execute
        Delayed(ms) {
            fn := this
            return Do()
                .Then(Effect.Delay(ms))
                .Let("result", fn.Effect())
                .Return(ctx => ctx["result"])
        }
    }

    class Any {
        ; Lift value to pure effect
        Pure() => Effect.Pure(this)

        ; Pipe into effect chain
        Into(effectBuilder) => effectBuilder(this)
    }

    class Array {
        ; Run effects in parallel
        Parallel() {
            effects := this
            return Cont((k) => {
                results := []
                results.Length := effects.Length
                remaining := effects.Length

                if remaining == 0
                    return k(results)

                for i, eff in effects {
                    EffectRunner.Interpret(eff).Run((val) => (
                        results[i] := val,
                        (--remaining == 0) && k(results)
                    ))
                }
            })
        }

        ; First effect to complete wins
        Race() {
            effects := this
            return Cont((k) => {
                done := false
                for eff in effects {
                    EffectRunner.Interpret(eff).Run((val) => (
                        done || (done := true, k(val))
                    ))
                }
            })
        }
    }

    class String {
        Fetch() => Effect.Fetch(this)
        ReadFileEffect() => Effect.ReadFile(this)
        WriteFileEffect(content) => Effect.WriteFile(this, content)
    }
}
```

---

## File Structure

```
src/
  Extensions/
    Effect.ahk           ; Core: Cont, Effect, Result, Do, EffectRunner
    AhkEffects.ahk       ; AHK-specific: AhkEffects, AhkEffectRunner
    EffectExtensions.ahk ; AquaHotkey integration: AquaHotkey_Effects

tests/
  Extensions/
    Effect.ahk           ; Unit tests for core effect system
    AhkEffects.ahk       ; Tests for AHK-specific effects
```

---

## Usage Examples

### Sequential Async Operations
```ahk
Do()
    .Let("config", "config.json".ReadFileEffect())
    .Let("parsed", Effect.Try(ctx => Jxon_Load(ctx["config"].OrThrow())))
    .Let("data",   ctx => ctx["parsed"].Value.ApiUrl.Fetch())
    .Return(ctx => ctx["data"])
    .Run(result => MsgBox(result.IsOk ? result.Value : "Error: " . result.Error))
```

### Parallel Fetches
```ahk
[
    "api.com/users".Fetch(),
    "api.com/posts".Fetch(),
    "api.com/comments".Fetch()
].Parallel().Run(results => (
    MsgBox("Fetched " . results.Length . " endpoints")
))
```

### GUI Event Handling
```ahk
myGui := Gui()
btnOk := myGui.AddButton("w100", "OK")
btnCancel := myGui.AddButton("w100", "Cancel")
myGui.Show()

Do()
    .Let("clicked", [
        AhkEffects.GuiEvent(btnOk, "Click"),
        AhkEffects.GuiEvent(btnCancel, "Click")
    ].Race())
    .Return(ctx => ctx["clicked"].Control.Text)
    .Run(choice => (
        myGui.Destroy(),
        MsgBox("You chose: " . choice)
    ))
```

### Window Automation
```ahk
Do()
    .Then(AhkEffects.RunWait('notepad.exe'))
    .Let("hwnd", AhkEffects.WaitWindow("ahk_class Notepad"))
    .Then(AhkEffects.Delay(100))
    .Then(Effect.Pure(() => Send("Hello Effects!")))
    .Then(AhkEffects.Delay(50))
    .Then(Effect.Pure(() => Send("^s")))
    .Let("saveDialog", AhkEffects.WaitWindow("Save As"))
    .Then(Effect.Pure(() => Send("test.txt{Enter}")))
    .Then(AhkEffects.Delay(500))
    .Then(Effect.Pure(() => WinClose("ahk_class Notepad")))
    .Return(_ => "Complete!")
    .Run(MsgBox)
```

---

## Implementation Notes

1. **AHK v2.1-alpha requirement**: Uses improved class/prototype features
2. **Non-blocking by default**: All effects use SetTimer internally
3. **Interpreter extensibility**: Custom effects via subclassing EffectRunner
4. **Context passing**: Do-notation uses Map for named bindings
5. **Error propagation**: Result type flows through chain automatically

## Testing Strategy

1. Unit test each component in isolation (Cont, Effect, Result)
2. Integration test Do-notation compilation
3. Test AHK-specific effects with mock callbacks
4. End-to-end test with real GUI/window operations
