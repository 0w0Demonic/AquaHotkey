# AquaHotkey's Function Chaining

## Overview

Function chaining in AquaHotkey allows users to chain functions together without
nesting, similar to the pipe (`|>`) operator in Elixir. This feature improves
code readability and flow, by enabling a left-to-right transformation of data.

### 1. Implicit Function Chaining (`Any.Prototype.__Call`)

When a method is not defined for a variable, AquaHotkey attempts to invoke a
global function with the variable as the **first argument**, followed by any
additional parameters.

**Example**:

```ahk
"Hello, world!".Foo().Bar("Baz") ; Bar(Foo("Hello, world!"), "Baz")
```

### 2. Explicit Function Chaining (`Any.Prototype.o0()`)

The `.o0()` method accepts the function to be called as first argument,
followed by zero or more additional arguments.

**Example**:

```ahk
"Hello, world!".o0(Foo).o0(Bar, "Baz") ; Bar(Foo("Hello, world!"), "Baz")
```

**Example**:

```ahk
"hello".o0(StrUpper)              ; "HELLO"
       .o0(StrReplace, "E", "3")  ; "H3LLO"
```

**Key Differences:**

- Implicit chaining looks up global functions by name dereference, making this
  approach more concise at the cost of being marginally slower.
- Explicit chaining is marginally faster and more flexible, as the `.o0()` method
  accepts any function object.

## Performance

Using AquaHotkey's function chaining is a good trade-off for greater
readability, as the performance difference caused by additional overhead is
often minimal.

However, operation on very large strings leads to dramatic overhead, because
of the way they are passed as parameters or returned by functions in AutoHotkey.

```ahk
; slow - file content is copied twice!
; 1st copy: returning from `FileRead()`
; 2nd copy: passing the file content to `InStr()`
"hugeFile.txt".FileRead().InStr("Hello, world!")
```

In the example above, the contents of the file are copied twice:
The first string copy occurs when `Any.Prototype.__Call()` calls `FileRead()`
and returns its result, the second copy occurs whenever calling a method from a
string (the method accepts an implicit `this`-parameter, and therefore a copy of
the string).

### Using ByRef

Using ByRef parameters reduces overhead, because the variable is passed *by
*reference instead. Using the approach in the example below, no unnecessary
string copies are made:

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
