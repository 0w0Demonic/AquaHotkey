# <[String](./overview.md)/[Matching](../../src/String/Matching.ahk)>

- [\<String/Matching\>](#stringmatching)
  - [Overview](#overview)
  - [Is-Functions](#is-functions)
  - [Regular Expressions](#regular-expressions)
  - [`InStr()` Functions](#instr-functions)

## Overview

Methods related to matching strings for specified characteristics, or regular
expressions. This includes methods that check if a string contains a substring,
or if it matches a regular expression.

## Is-Functions

The built-in "is-functions" such as `IsAlpha` and `IsDigit`, but as properties.

```ahk
"abc".IsAlpha ; true
... ; etc.
```

## Regular Expressions

Use `.RegExMatch()` and `.RegExReplace()` to match or replace occurrences of
regular expressions in a string.

```ahk
; --> ; RegExReplace(Str, Pattern, Replacement)
Str.RegExReplace(Pattern, Replacement)
```

To return one or more regex match objects, use `.Match()` or `.MatchAll()`.

```ahk
Str := "234"
Str.Match("\d++")  ; RegExMatchInfo<"234">
Str.MatchAll("\d") ; [ RegExMatchInfo<"2">, ... ]
```

Use `.Capture()` or `.Capture()` to return the overall match instead of a
regex match object.

```ahk
"Test123Hello".Capture("\d++") ; "123"
"Test123Hello".CaptureAll("\d") ; ["1", "2", "3"]
```

## `InStr()` Functions

Use `.Contains()` and `.ContainedIn()` to check if a string contains or is
contained in another string, respectively.

```ahk
"Hello".Contains("ell") ; true
"ell".ContainedIn("Hello") ; true
```