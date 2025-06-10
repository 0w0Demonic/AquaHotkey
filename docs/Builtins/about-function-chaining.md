# AquaHotkey's Function Chaining

## Overview

Function chaining is a feature greatly inspired by the pipe operator `|>` in
Elixir. The main focus is code readability and flow, by taking the result
of one expression, and passing it onto the next function.

### 1. Implicit Chaining

Whenever a method `.Foo()` is undefined, AquaHotkey will try to call a global
function `Foo()`. The variable is passed on as **first argument**, followed by
any additional parameters.

```ahk
"Hello, world!".Foo().Bar("Baz") ; Bar(Foo("Hello, world!"), "Baz")
```

### 2. Explicit Chaining

As opposed to the implicit version, the `.o0()` method directly accepts the
function to be called.

```ahk
"Hello, world!".o0(Foo).o0(Bar, "Baz") ; Bar(Foo("Hello, world!"), "Baz")

"hello".o0(StrUpper)              ; "HELLO"
       .o0(StrReplace, "E", "3")  ; "H3LLO"
```

**Key Differences**:

- Implicit chaining is more concise at the cost of being marginally slower.
- Explicit chaining is marginally faster and more flexible, because it accepts
  any function to be called.

## Performance

>If you're scared of performance, consider using something else than AutoHotkey.

In most cases, this feature is a very nice trade-off to make some non-critical
sections of your code significantly prettier to look at.

However, watch out for anything that has to handle very large strings, as this
can cause dramatic overhead because of the way how strings are passed *by value*
instead of *by reference*.

```ahk
; slow - file content is copied twice!
; 1st copy: returning from `FileRead()`
; 2nd copy: passing the file content to `InStr()`
"hugeFile.txt".FileRead().InStr("Hello, world!")
```

In this example, the contents of the file are copied twice, because primitive
types are always passed by value, not by reference. Firstly, the return
value of `.FileRead()`. Secondly, the call to `.InStr()`.

### Using ByRef

In general, you should handle large strings in the form of `VarRef` objects
(&MyStr). This way, you can cut down on unnecessary string copies.

```ahk
FileReadRef(FileName) {
    FileContent := FileRead(FileName)
    return &FileContent
}

InStrRef(&Str, Pattern) {
    return InStr(Str, Pattern)
}

"hugeFile.txt".FileReadRef().InStrRef("Hello, world!")
```
