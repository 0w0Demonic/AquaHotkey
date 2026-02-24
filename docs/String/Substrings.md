# <[String](./overview.md)/[Substrings](../../src/String/Substrings.ahk)>

- [\<String/Substrings\>](#stringsubstrings)
  - [Overview](#overview)
  - [By Index](#by-index)
  - [String Matching](#string-matching)
  - [Regex Matching](#regex-matching)

## Overview

Utility for cutting strings into smaller substrings.

## By Index

Use `.Sub(Start, Length?)` and `.__Item[Start, Length := 1]` to cut a string
into a substring based on index and length.

```ahk
"123abc789".Sub(4, 3) ; --> SubStr("123abc789", 4, 3) --> "abc"

("abc")[1] ; --> SubStr("abc", 3, a) --> "a"
```

Note that when "indexing" the string, you might need to surround it between
parentheses, or store it as variable because of syntax issues.

```ahk
"abc"[1]   ; Error!
("abc")[1] ; Ok.

Str := "abc"
Str[1] ; Ok.
```

## String Matching

Use `.Before()`, `.Until()`, `.From()` and `.After()` to cut a string into a
substring based on the occurrence of a substring.

```ahk
"Hello, world!".Before(",") ; "Hello"
```

## Regex Matching

The same applies to regular expression matches, but with `.BeforeRegex()`, `.UntilRegex()`, `.FromRegex()` and `.AfterRegex()`.

```ahk
"abc123def".BeforeRegex("\d") ; "abc"
```
