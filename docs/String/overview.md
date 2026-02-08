# Module `<String>`

- [All Modules](../api-overview.md)

## List of Features

- [String](./String.md)
- [Formatting](./Formatting.md)
- [Matching](./Matching.md)
- [Substrings](./Substrings.md)

## String

- [<String/String>](./String.md)

A few basic string utilities that include support in for-loops, concatenation,
formatting and splitting.

```ahk
"example".Surround("[", "]") ; "[example]"
"a".Repeat(10) ; "aaaaaaaaaa"

for Char in "Hello" {
    ...
}
; alternatively, with <Stream/Stream>:
"Hello".Stream().ForEach(Char => ...)
```

## Formatting

- [<String/Formatting>](./Formatting.md)

A wide range of string formatting methods.

```ahk
" example ".Trim() ; "example"
"ahk".ToUpper() ; "AHK"
```

## Matching

- [<String/Matching>](./Matching.md)

Methods of matching strings for specified characteristics or regular
expressions.

```ahk
"".IsEmpty ; true

"test".Contains("e") ; true

; --> RegExMatchInfo<"123">
Match := "test123".Match("\d+")
```

## Substrings

- [<String/Substrings>](./Substrings.md)

Introduces a way to split strings based on the occurrences of substrings or
regular expression matches inside a string.

```ahk
"Hello, world!".After(" ") ; "world!"
```
