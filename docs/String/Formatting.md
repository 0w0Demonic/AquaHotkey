# <[String](./overview.md)/[Formatting](../../src/String/Formatting.ahk)>

- [\<String/Formatting\>](#stringformatting)
  - [Overview](#overview)
  - [Formatting](#formatting)
  - [String Replacements](#string-replacements)
  - [Insert, Overwrite, Delete](#insert-overwrite-delete)
  - [Word Wrapping](#word-wrapping)
  - [Trimming](#trimming)
  - [`ToUpper()`, `.ToLower()`, `ToTitle()`](#toupper-tolower-totitle)
  - [Enclosing With Quote Marks](#enclosing-with-quote-marks)

## Overview

String formatting.

## Formatting

Use `.Formatted(Args*)` to use the string as `Format()`-string.

```ahk
; equivalent to: Format("...", "Juliet")
"My {}, my special girl".Formatted("Juliet")
```

## String Replacements

`StrReplace()` and `RegExReplace()` come in the form of methods `.Replace()`
and `.RegExReplace()`.

```ahk
; --> "banana"
"banama".Replace("m", "n")

; --> "abc"
"abc123".RegExReplace("\d+")
```

## Insert, Overwrite, Delete

Use `.Insert()`, `.Overwrite()` and `.Delete()` to mutate sections in the
string.

```ahk
"banaa".Insert("n", -1)    ; "banana"
"banaaa".Overwrite("n", 5) ; "banana"
"aapple".Delete(2)         ; "apple"
```

## Word Wrapping

Use `.WordWrap()` to format the string into lines with word wrapping to a
given maximum length.

```ahk
Str.WordWrap(40) ; word-wrap to 40 characters per line
```

## Trimming

Use `.Trim()`, `.LTrim()` and `.RTrim()` to trim string off of whitespace or
other characters.

```ahk
" foo ".Trim() ; "foo"
" foo ".LTrim() ; "foo "
" foo ".RTrim() ; " foo"
```

## `ToUpper()`, `.ToLower()`, `ToTitle()`

Turn a string into upper/lower/title-case.

```ahk
"foo".ToUpper() ; "FOO"
"FOO".ToLower() ; "foo"
"foo".ToTitle() ; "Foo"
```

## Enclosing With Quote Marks

Use `.Quote()` to enclose the string with quote marks.

```ahk
"foo".Quote() ; `"foo"`
StrLen("foo".Quote()) ; 5
```