# <[String](./overview.md)/[String](../../src/String/String.ahk)>

- [\<String/String\>](#stringstring)
  - [Overview](#overview)
  - [Enumerable Strings](#enumerable-strings)
  - [Splitting](#splitting)
  - [Concatenation](#concatenation)
  - [Miscellaneous](#miscellaneous)
  - [Properties](#properties)

## Overview

Basic string utility.

## Enumerable Strings

You can enumerate strings in for-loops, which enumerates through all characters.

```ahk
for Character in Str { ... }
for Index, Character in Str { ... }
```

You can also use them in a [Stream](../Stream/Stream.md):

```ahk
"test123".Stream()
        .RetainIf(IsNumber) ; <"1", "2", "3">
        .Join(", ")         ; "1, 2, 3"
```

## Splitting

To split a string into an array of substrings, use `.Split()`.
`.Lines()` splits a string into an array of separate lines.

```ahk
"
(
line 1
line 2
)".Lines()            ; --> ["line 1", "line 2"]
"123".Split()         ; --> ["1", "2", "3"]
"1, 2, 3".Split(", ") ; --> ["1", "2", "3"]
```

Alternatively, you can use `LoopParse()` to create a push-based
[Continuation](../Func/Continuation.md) pipeline.

```ahk

```

## Concatenation

Use `.Prepend()`, `.Append()` and `.Surround()` to make string concatenations.

```ahk
"b".Prepend("a")       ; --> "ab"
"a".Append("b")        ; --> "ab"
"o".Surround(" ")      ; --> " o "
"b".Surround("a", "c") ; --> "abc"
```

## Miscellaneous

Use `.Repeat()` to repeat the string the given amount of times. `.Reversed()`
returns a reversed version of the string.

```ahk
"a".Repeat(10) ; "aaaaaaaaaa"
"abc".Reversed() ; "cba"
```

## Properties

`.Length` returns the length of the string in characters, whereas
`.SizeInBytes[Encoding?]` retrieves the size in bytes.

```ahk
"foo".Length ; --> StrLen("foo") --> 3
"foo".SizeInBytes["UTF-8"] ; --> 4
```
