# String

AquaHotkeyX extends strings with many ergonomic and expressive methods.

## Indexing and Iteration

Strings are now enumerable. You can iterate directly over characters, optionally
together with their indices.

```ahk
for Char in Str {
    ...
}

for Index, Char in Str {
    ...
}
```

They also support array-style indexing. Works mostly like `SubStr()`:

```ahk
Str[1]    ; first character
Str[1, 2] ; first two characters
```

## Spicing and Formatting

String slicing and manipulation made a *lot* more bearable.

```ahk
Str.Before("foo").AfterRegex("m)^bar")
```

You can also format strings with:

- `.Prepend()`
- `.Append()`
- `.FormatWith()` (current string used as format string)
- `.FormatTo()` (current string used as value)

## Editing and Structure

- `.Repeat()` repeats a string the given amount of times
- `.Insert()`, `.Overwrite()`, `.Delete()`: edit substrings by their indices
- `.Length` gives back `StrLen()`
- `.Size[Encoding]` gives encoded byte size

## Paths and Files

- `.SplitPath()` gives an object with detailed parts (name, dir, ext, etc.)
- `.FindFiles()` is a cleaner take on AHK's file loops.

```ahk
A_Desktop.FindFiles(
        "FR",
        () => InStr(A_LoopFileFullPath, "foo"),
        () => A_LoopFileFullPath)
```

This performs a simple `Loop Files`, but in a more neat and declarative way. It
works because surprisingly, functions have access to the built-in file variables
while enumerating.

## Regex Matchers

- `.Match()`, `.Capture()`: first match object or overall text
- `.MatchAll()`, `.CaptureAll()`: all matches as array of results
