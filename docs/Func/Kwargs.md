# <[Func](./overview.md)/[Kwargs](../../src/Func/Kwargs.ahk)>

- [Overview](#overview)
- [Defining Own Signatures](#defining-own-signatures)

## Overview

Allows calling functions or any callable object with keyword arguments
("kwargs").

```ahk
ControlSend.With({
    Keys: "Hello, world!",
    Ctrl: "Edit1",
    WinTitle: "ahk_exe notepad.exe"
})
```

Each function or callable or object can define a `.Signature` property that
maps parameter names (and their aliases) to positional indices. Once a
signature is defined, you can call `.With(ArgObj)`, which converts the named
arguments in a plain object (`ArgObj`) into positional arguments and invokes
the function.

```ahk
; 1. Text
; 2. Title
; 3. Options
MsgBox(String(MsgBox.Signature))

; equivalent to: MsgBox("Hello, world!", "Cool title", 0x40)
MsgBox.With({
    Text: "Hello, world!",
    Title: "Cool title",
    Options: 0x40
})
```

## Defining Own Signatures

Although [KwargsConfig.ahk](../../src/Func/KwargsConfig.ahk) already provides
signatures to most built-in AHK functions, they can be easily customized. See
[source file](../../src/Func/Kwargs.ahk) for more information.
