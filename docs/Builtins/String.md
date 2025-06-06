# String

## Method Summary

| Method Name                                                                                                                                                                  | Return Type      | Description                                                                |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- | -------------------------------------------------------------------------- |
| [`__Enum(n)`](#__Enum)                                                                                                                                                       | `Enumerator`     | Enumerates all characters in this string as a for-loop                     |
| [`Lines()`](#Lines)                                                                                                                                                          | `Array`          | Splits this string into an array of separate lines                         |
| [`Chars()`](#Chars)                                                                                                                                                          | `Array`          | Splits this string into each character                                     |
| [`Before(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1)`](#Before)                                                                                          | `String`         | Returns a substring that ends before substring `Pattern`                   |
| [`BeforeRegex(Pattern, StartingPos := 1)`](#BeforeRegex)                                                                                                                     | `String`         | Returns a substring that ends before regex `Pattern`                       |
| [`Until(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1)`](#Until)                                                                                            | `String`         | Returns a substring that ends on substring `Pattern`                       |
| [`UntilRegex(Pattern, StartingPos := 1)`](#UntilRegex)                                                                                                                       | `String`         | Returns a substring that ends on regex `Pattern`                           |
| [`From(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1)`](#From)                                                                                              | `String`         | Returns a substring that starts with substring `Pattern`                   |
| [`FromRegex(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1)`](#FromRegex)                                                                                    | `String`         | Returns a substring that starts with regex `Pattern`                       |
| [`After(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1)`](#After)                                                                                            | `String`         | Returns a substring that starts after substring `Pattern`                  |
| [`AfterRegex(Pattern, StartingPos := 1)`](#AfterRegex)                                                                                                                       | `String`         | Returns a substring that starts after regex `Pattern`                      |
| [`Prepend(Before)`](#Prepend)                                                                                                                                                | `String`         | Prepends this string with `Before`                                         |
| [`Append(After)`](#After)                                                                                                                                                    | `String`         | Appends `After` to this string                                             |
| [`Surround(Before, After := Before)`](#Surround)                                                                                                                             | `String`         | Surrounds this string with `Before` and `After`                            |
| [`Repeat(n)`](#Repeat)                                                                                                                                                       | `String`         | Returns this string repeated `n` times                                     |
| [`Reversed()`](#Reversed)                                                                                                                                                    | `String`         | Repeats this string with its characters reversed                           |
| [`FileRead(Options?)`](#FileRead)                                                                                                                                            | `String`         | Reads the contents of the file this string leads to                        |
| [`FileAppend(FileName?, Options?)`](#FileAppend)                                                                                                                             | `this`           | Appends this string into file `FileName`                                   |
| [`FileOverwrite(FileName)`](#FileOverwrite)                                                                                                                                  | `this`           | Overwrites this string into file `FileName`                                |
| [`FileOpen(Flags, Encoding?)`](#FileOpen)                                                                                                                                    | `File`           | Opens a file with this string used as file path                            |
| [`SplitPath()`](#SplitPath)                                                                                                                                                  | `Object`         | Separates a file name or URL into its name, directory, extension and drive |
| [`FindFiles(Mode := "FR", Pattern?, ReturnValue?)`](#FindFiles)                                                                                                              | `Array`          | Performs a file-loop with this string used as file path                    |
| [`RegExMatch(Pattern, &MatchObj?, StartingPos := 1)`](#RegExMatch)                                                                                                           | `Integer`        | Determines whether this string contains a regex `Pattern`                  |
| [`RegExReplace(Pattern, Replace?, &Count?, Limit?, Start?)`](#RegExReplace)                                                                                                  | `String`         | Replaces regex occurrences in this string                                  |
| [`Match(Pattern, StartingPos := 1)`](#Match)                                                                                                                                 | `RegExMatchInfo` | Returns the match object for the first match of a regex `Pattern`          |
| [`MatchAll(Pattern, StartingPos := 1)`](#MatchAll)                                                                                                                           | `Array`          | Returns an array of all match objects matched by regex `Pattern`           |
| [`Capture(Pattern, StartingPos := 1)`](#Capture)                                                                                                                             | `String`         | Returns the first substring matched by regex `Pattern`                     |
| [`CaptureAll(Pattern, StartingPos := 1)`](#CaptureAll)                                                                                                                       | `Array`          | Returns an array of all substrings matched by regex `Pattern`              |
| [`Insert(Str, Position := 1)`](#Insert)                                                                                                                                      | `String`         | Inserts `Str` into this string                                             |
| [`Overwrite(Str, Position := 1)`](#Overwrite)                                                                                                                                | `String`         | Overwrites `Str` into this string                                          |
| [`Delete(Position, Length := 1)`](#Delete)                                                                                                                                   | `String`         | Deletes a section from this string                                         |
| [`LPad(PaddingStr := " ", n := 1)`](#LPad)                                                                                                                                   | `String`         | Pads this string on the left                                               |
| [`RPad(PaddingStr := " ", n := 1)`](#RPad)                                                                                                                                   | `String`         | Pads this string on the right                                              |
| [`WordWrap(n := 80)`](#WordWrap)                                                                                                                                             | `String`         | Wraps this string into new lines after reaching `n` characters             |
| [`Trim(OmitChars?)`](#Trim)                                                                                                                                                  | `String`         | Trims characters from the beginning and end of this string                 |
| [`LTrim(OmitChars?)`](#LTrim)                                                                                                                                                | `String`         | Trims characters from the beginning of this string                         |
| [`RTrim(OmitChars?)`](#RTrim)                                                                                                                                                | `String`         | Trims characters from the end of this string                               |
| [`Format(Args*)`](#Format)<br>[`FormatWith(Args*)`](#FormatWith)                                                                                                             | `String`         | Returns a formatted string, using this string as format pattern            |
| [`StrLower()`](#StrLower)<br>[`ToLower()`](#ToLower)                                                                                                                         | `String`         | Converts this string to lowercase                                          |
| [`StrUpper()`](#StrUpper)<br>[`ToUpper()`](#ToUpper)                                                                                                                         | `String`         | Converts this string to uppercase                                          |
| [`StrTitle()`](#StrTitle)<br>[`ToTitle`](#ToTitle)                                                                                                                           | `String`         | Converts this string to title case                                         |
| [`StrReplace(Pattern, Rep := "", CaseSense := false, &Out?, Limit := -1)`](#StrReplace)<br>[`Replace(Pattern, Rep := "", CaseSense := false, &Out?, Limit := -1)`](#Replace) | `String`         | Replaces occurrences of `Pattern` in this string                           |
| [`StrSplit(Delimiter := "", OmitChars := "", MaxParts := -1)`](#StrSplit)<br>[`Split(Delimiter := "", OmitChars := "", MaxParts := -1)`](#Split)                             | `Array`          | Separates this string into an array of substrings                          |
| [`InStr(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1)`](#InStr)<br>[`Contains(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1)`](#Contains) | `Integer`        | Searches this string for an occurrence of `Pattern`                        |
| [`SubStr(Start, Length?)`](#SubStr)                                                                                                                                          | `String`         | Returns a substring with the given starting index and length in characters |
| [`StrLen()`](#StrLen)                                                                                                                                                        | `Integer`        | Returns the length of this string in characters                            |
| [`StrCompare(Other, CaseSense := false)`](#StrCompare)<br>[`CompareTo(Other, CaseSense := false)`](#Compare)                                                                 | `Integer`        | Lexicographically compares this string with `Other`                        |

---

## Property Summary

| Property Name                                                                                                                                                                                        | Property Type | Return Type | Description                                                                |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- | ----------- | -------------------------------------------------------------------------- |
| [`IsDigit`](#IsDigit)<br>[`IsXDigit`](#IsXDigit)<br>[`IsAlpha`](#IsAlpha)<br>[`IsUpper`](#IsUpper)<br>[`IsLower`](#IsLower)<br>[`IsAlnum`](#IsAlnum)<br>[`IsSpace`](#IsSpace)<br>[`IsTime`](#IsTime) | `get`         | `Boolean`   | Is-functions (see AHK docs)                                                |
| [`IsEmpty`](#IsEmpty)                                                                                                                                                                                | `get`         | `Boolean`   | Returns `true`, if this string is empty                                    |
| [`__Item(Start, Length := 1)`](#__Item)                                                                                                                                                              | `get`         | `String`    | Returns a substring with the given starting index and length in characters |
| [`Length`](#Length)                                                                                                                                                                                  | `get`         | `Integer`   | Returns the length of this string in characters                            |
| [`Size[Encoding?]`](#Size)                                                                                                                                                                           | `get`         | `Integer`   | Returns the length of this string in bytes with the specified encoding     |

---

## Method Details

<a id="__Enum"></a>

### `__Enum(n: Integer) => Enumerator`

**Description**:

Enumerates all characters in this string as a for-loop.

**Example**:

```ahk
for Character in "Hello, world!" {
    MsgBox(Character)
}

for Index, Character in "Hello, world!" {
    MsgBox(Index . ": " . Character)
}
```

**Parameters**:

| Parameter Name | Type      | Description                      |
| -------------- | --------- | -------------------------------- |
| `n`            | `Integer` | Parameter length of the for-loop |

**Return Value**:

- **Type**: `Enumerator`

---

<a id="Lines"></a>

### `Lines() => Array`

**Description**:

Splits this string into an array of separate lines.

**Example**:

```ahk
"
(
Hello,
world!
)".Lines() ; ["Hello,", "world!"]
```

**Return Value**:

- **Type**: `Array`

---

<a id="Before"></a>

### `Before(Pattern: String, CaseSense: Primitive := false, StartingPos: Integer := 1, Occurrence: Integer := 1) => String`

**Description**:

Returns a substring that ends just before a specified occurrence of `Pattern`.

**Example**:

```ahk
"Hello, world!".Before(", ") ; "Hello"
"abcABCabc".Before("ABC", True) ; "abc"
```

**Parameters**:

| Parameter Name | Type                 | Description                      |
| -------------- | -------------------- | -------------------------------- |
| `Pattern`      | `String`             | The substring to search for      |
| `CaseSense`    | `Primitive := false` | Case-sensitivity of the search   |
| `StartingPos`  | `Integer := 1`       | Position to start searching from |
| `Occurrence`   | `Integer := 1`       | n-th occurrence to find          |

**Return Value**:

- **Type**: `String`

---

<a id="BeforeRegex"></a>

### `BeforeRegex(Pattern: String, StartingPos: Integer := 1) => String`

**Description**:

Returns a substring that ends just before the first match of a regex `Pattern`.

**Example**:

```ahk
"Test123Hello".BeforeRegex("\d++") ; "Test"
```

**Parameters**:

| Parameter Name | Type           | Description                      |
| -------------- | -------------- | -------------------------------- |
| `Pattern`      | `String`       | Regular expression to search for |
| `StartingPos`  | `Integer := 1` | Position to start searching from |

**Return Value**:

- **Type**: `String`

---

<a id="Until"></a>

### `Until(Pattern: String, CaseSense: Primitive := false, StartingPos: Integer := 1, Occurrence: Integer := 1) => String`

**Description**:

Returns a substring that ends on the end of a specified occurrence of `Pattern`.

**Example**:

```ahk
"Hello, world!".To(", ") ; "Hello, "
```

**Parameters**:

| Parameter Name | Type                 | Description                      |
| -------------- | -------------------- | -------------------------------- |
| `Pattern`      | `String`             | The substring to search for      |
| `CaseSense`    | `Primitive := false` | Case-sensitivity of the search   |
| `StartingPos`  | `Integer := 1`       | Position to start searching from |
| `Occurrence`   | `Integer := 1`       | n-th occurrence to find          |

**Return Value**:

- **Type**: `String`

---

<a id="UntilRegex"></a>

### `UntilRegex(Pattern: String, StartingPos: Integer := 1) => String`

**Description**:

Returns a substring that ends on the end of the first match of a regex `Pattern`.

**Example**:

```ahk
"Test123Hello".ToRegex("\d++") ; "Test123"
```

**Parameters**:

| Parameter Name | Type           | Description                      |
| -------------- | -------------- | -------------------------------- |
| `Pattern`      | `String`       | Regular expression to search for |
| `StartingPos`  | `Integer := 1` | Position to start searching from |

**Return Value**:

- **Type**: `String`

---

<a id="From"></a>

### `From(Pattern: String, CaseSense: Primitive := false, StartingPos: Integer := 1, Occurrence: Integer := 1) => String`

**Description**:

Returns a substring that starts at a specified occurrence of `Pattern`.

**Example**:

```ahk
"Hello, world!".From(",") ; ", world!"
```

**Parameters**:

| Parameter Name | Type                 | Description                      |
| -------------- | -------------------- | -------------------------------- |
| `Pattern`      | `String`             | The substring to search for      |
| `CaseSense`    | `Primitive := false` | Case-sensitivity of the map      |
| `StartingPos`  | `Integer := 1`       | Position to start searching from |
| `Occurrence`   | `Integer := 1`       | n-th occurrence to find          |

**Return Value**:

- **Type**: `String`

---

<a id="FromRegex"></a>

### `FromRegex(Pattern: String, StartingPos: Integer := 1) => String`

**Description**:

Returns a substring that starts at the first match of a regex `Pattern`.

**Example**:

```ahk
"Test123Hello".FromRegex("\d++") ; "123Hello"
```

**Parameters**:

| Parameter Name | Type           | Description                      |
| -------------- | -------------- | -------------------------------- |
| `Pattern`      | `String`       | Regular expression to search for |
| `StartingPos`  | `Integer := 1` | Position to start searching from |

**Return Value**:

- **Type**: `String`

---

<a id="After"></a>

### `After(Pattern: String, CaseSense: Primitive := false, StartingPos: Integer := 1, Occurrence: Integer := 1) => String`

**Description**:

Returns a substring that starts after a specified occurrence of `Pattern`.

**Example**:

```ahk
"Hello, world!".After(",") ; " world!"
```

**Parameters**:

| Parameter Name | Type                 | Description                      |
| -------------- | -------------------- | -------------------------------- |
| `Pattern`      | `String`             | The substring to search for      |
| `CaseSense`    | `Primitive := false` | Case-sensitivity of the search   |
| `StartingPos`  | `Integer := 1`       | Position to start searching from |
| `Occurrence`   | `Integer := 1`       | n-th occurrence to find          |

**Return Value**:

- **Type**: `String`

---

<a id="AfterRegex"></a>

### `AfterRegex(Pattern: String, StartingPos: Integer := 1) => String`

**Description**:

Returns a substring that starts after the first match of a regex `Pattern`.

**Example**:

```ahk
"Test123Hello".AfterRegex("\d++") ; "Hello"
```

**Parameters**:

| Parameter Name | Type           | Description                      |
| -------------- | -------------- | -------------------------------- |
| `Pattern`      | `String`       | Regular expression to search for |
| `StartingPos`  | `Integer := 1` | Position to start searching from |

**Return Value**:

- **Type**: `String`

---

<a id="Prepend"></a>

### `Prepend(Before: String) => String`

**Description**:

Returns this string prepended by `Before`.

**Example**:

```ahk
"world!".Prepend("Hello, ") ; "Hello, world!"
```

**Parameters**:

| Parameter Name | Type     | Description           |
| -------------- | -------- | --------------------- |
| `Before`       | `String` | The string to prepend |

**Return Value**:

- **Type**: `String`

---

<a id="Append"></a>

### `Append(After: String) => String`

**Description**:

Returns this string append with `After`.

**Example**:

```ahk
"Hello, ".Append("world!") ; "Hello, world!"
```

**Parameters**:

| Parameter Name | Type     | Description          |
| -------------- | -------- | -------------------- |
| `After`        | `String` | The string to append |

**Return Value**:

- **Type**: `String`

---

<a id="Surround"></a>

### `Surround(Before: String, After: String := Before) => String`

**Description**:

Returns a new string surrounded by `Before` and `After`.

**Example**:

```ahk
"foo".Surround("(", ")") ; "(foo)"
"foo".Surround("_")      ; "_foo_"
```

**Parameters**:

| Parameter Name | Type               | Description           |
| -------------- | ------------------ | --------------------- |
| `Before`       | `String`           | The string to prepend |
| `After`        | `String := Before` | The string to append  |

**Return Value**:

- **Type**: `String`

---

<a id="Repeat"></a>

### `Repeat(n: Integer) => String`

**Description**:

Returns this string repeated `n` times.

**Example**:

```ahk
"foo".Repeat(3) ; "foofoofoo"
```

**Parameters**:

| Parameter Name | Type      | Description                          |
| -------------- | --------- | ------------------------------------ |
| `n`            | `Integer` | Amount of times to repeat the string |

**Return Value**:

- **Type**: `String`

---

<a id="Reversed"></a>

### `Reversed() => String`

**Description**:

Returns this string with all characters in reverse order.

**Example**:

```ahk
"foo".Reversed() ; "oof"
```

**Return Value**:

- **Type**: `String`

---

<a id="FileRead"></a>

### `FileRead(Options: String?) => String`

**Description**:

Reads the contents of the file which this string leads to.

**Example**:

```ahk
"message.txt".FileRead()
```

**Parameters**:

| Parameter Name | Type     | Description                         |
| -------------- | -------- | ----------------------------------- |
| `Options`      | `String` | Additional options for `FileRead()` |

**Return Value**:

- **Type**: `String`

---

<a id="FileAppend"></a>

### `FileAppend(FileName: String?, Options: String?) => this`

**Description**:

**Example**:

```ahk
"Hello, world!".FileAppend("message.txt")
```

**Parameters**:

| Parameter Name | Type      | Description                           |
| -------------- | --------- | ------------------------------------- |
| `FileName`     | `String?` | Name of the file to be appended       |
| `Options`      | `String?` | Additional options for `FileAppend()` |

**Return Value**:

- **Type**: `this`

---

<a id="FileOverwrite"></a>

### `FileOverwrite(FileName) => this`

**Description**:

Overwrites the file `FileName` with this string (Previous file contents are lost!).

**Example**:

```ahk
"Hello, world!".FileOverwrite("message.txt")
```

**Parameters**:

| Parameter Name | Type     | Description                   |
| -------------- | -------- | ----------------------------- |
| `FileName`     | `String` | Name of the file to overwrite |

**Return Value**:

- **Type**: `this`

---

<a id="FileOpen"></a>

### `FileOpen(Flags: Primitive, Encoding: Primitive?) => File`

**Description**:

Opens a file which this string leads to.

**Example**:

```ahk
FileObj := "message.txt".FileOpen("r")
```

**Parameters**:

| Parameter Name | Type         | Description         |
| -------------- | ------------ | ------------------- |
| `Flags`        | `Primitive`  | Desired access mode |
| `Encoding`     | `Primitive?` | File encoding       |

**Return Value**:

- **Type**: `String`

---

<a id="SplitPath"></a>

### `SplitPath() => Object`

**Description**:

Separates a file name of URL into its name, directory, extension, and drive.

**Example**:

```ahk
; {
;     Name:      "Address List.txt",
;     Dir:       "C:\My Documents",
;     Ext:       "txt"
;     NameNoExt: "Address List"
;     Drive:     "C:"
; }
"C:\My Documents\Address List.txt".SplitPath()
```

**Return Value**:

- **Type**: `Object`

---

<a id="FindFiles"></a>

### `FindFiles(Mode: String := "FR", Pattern: Func?, ReturnValue: String?/Func?) => Array`

**Description**:

Returns the contents of a file-loop using this string as file pattern. Parameter `Pattern` refers to a 0-parameter predicate function which has access to the built-in file-loop variables such as `A_LoopFilePath`. Parameter `ReturnValue` is the name of a file-loop variable to be returned, or a zero-parameter function similar to `Pattern`.

**Example**:

```ahk
"C:\*".FindFiles("D") ; ["C:\Users", "C:\Windows", ...]
```

**Parameters**:

| Parameter Name | Type            | Description                                                     |
| -------------- | --------------- | --------------------------------------------------------------- |
| `Mode`         | `String?`       | File-loop mode                                                  |
| `Pattern`      | `Func?`         | Function that evaluates a condition                             |
| `ReturnValue`  | `String?/Func?` | Name of a file-loop variable or a function that returns a value |

**Return Value**:

- **Type**: `Array`

---

<a id="RegExMatch"></a>

### `RegExMatch(Pattern: String, &MatchObj: VarRef?, StartingPos: Integer := 1) => Integer`

**Description**:

Determines whether this string contains a regular expression `Pattern`.
If present, the index of the first occurrence is returned.

**Example**:

```ahk
"Test123Hello".RegExMatch("\d++") ; 5
```

**Parameters**:

| Parameter Name | Type     | Description |
| -------------- | -------- | ----------- |
| `Pattern`      | `String` |             |

**Return Value**:

- **Type**: `Integer`

---

<a id="RegExReplace"></a>

### `RegExReplace(Pattern: String, Replace: String?, &Count: VarRef?, Limit: Integer?, Start: Integer?) => String`

**Description**:

Replaces regular expression occurrences of this string.

**Example**:

```ahk
"Test123Hello".RegExReplace("\d++", "") ; "TestHello"
```

**Parameters**:

| Parameter Name | Type       | Description                      |
| -------------- | ---------- | -------------------------------- |
| `Pattern`      | `String`   | Regular expression pattern       |
| `Replace`      | `String?`  | Replacement string               |
| `&Count`       | `VarRef?`  | Output count                     |
| `Limit`        | `Integer?` | Maximum number of replacements   |
| `Start`        | `Integer?` | Position to start searching from |

**Return Value**:

- **Type**: `String`

---

<a id="Match"></a>

### `Match(Pattern: String, StartingPos: Integer := 1) => RegExMatchInfo`

**Description**:

Returns the match object for the first occurrence of a regular expression `Pattern`.
If this string has no occurrence of `Pattern`, this method returns `false`.

**Example**:

```ahk
MatchObj := "Test123Hello".Match("\d++")
```

**Parameters**:

| Parameter Name | Type           | Description                      |
| -------------- | -------------- | -------------------------------- |
| `Pattern`      | `String`       | Regular expression pattern       |
| `StartingPos`  | `Integer := 1` | Position to start searching from |

**Return Value**:

- **Type**: `RegExMatchInfo`

---

<a id="MatchAll"></a>

### `MatchAll(Pattern: String, StartingPos: Integer := 1) => Array`

**Description**:

Returns an array of all match objects for occurrence of a regular, expression `Pattern`.
Match objects do not overlap with each other.

**Example**:

```ahk
; 1st iteration: "12"
; 2nd iteration: "34"
for MatchObj in "12345".MatchAll("\d{2}+") {
    MsgBox(MatchObj[0])
}
```

**Parameters**:

| Parameter Name | Type           | Description                      |
| -------------- | -------------- | -------------------------------- |
| `Pattern`      | `String`       | Regular expression pattern       |
| `StartingPos`  | `Integer := 1` | Position to start searching from |

**Return Value**:

- **Type**: `Array`

---

<a id="Capture"></a>

### `Capture(Pattern: String, StartingPos: Integer := 1) => String`

**Description**:

Returns the overall match of the first occurrence of a regular expression `Pattern`.

**Example**:

```ahk
"Test123Hello".Capture("\d++") ; "123"
```

**Parameters**:

| Parameter Name | Type           | Description                      |
| -------------- | -------------- | -------------------------------- |
| `Pattern`      | `String`       | Regular expression pattern       |
| `StartingPos`  | `Integer := 1` | Position to start searching from |

**Return Value**:

- **Type**: `String`

---

<a id="CaptureAll"></a>

### `CaptureAll(Pattern: String, StartingPos: Integer := 1) => Array`

**Description**:

Returns an array of all occurrence of all occurrences of regular expression `Pattern`.
Matches do not overlap with each other.

**Example**:

```ahk
"12345".CaptureAll("\d{2}+") ; ["12", "34"]
```

**Parameters**:

| Parameter Name | Type           | Description                      |
| -------------- | -------------- | -------------------------------- |
| `Pattern`      | `String`       | Regular expression pattern       |
| `StartingPos`  | `Integer := 1` | Position to start searching from |

**Return Value**:

- **Type**: `Array`

---

<a id="Insert"></a>

### `Insert(Str: String, Position: Integer := 1) => String`

**Description**:

Inserts `Str` into the string at index `Position`.

**Example**:

```ahk
"Hello world!".Insert(",", 6) ; "Hello, world!"
"banaa".Insert("n", -1)       ; "banana"
```

**Parameters**:

| Parameter Name | Type       | Description                 |
| -------------- | ---------- | --------------------------- |
| `Str`          | `String`   | String to insert            |
| `Position`     | `Integer?` | Index to insert string into |

**Return Value**:

- **Type**: `String`

---

<a id="Overwrite"></a>

### `Overwrite(Str: String, Position: Integer := 1) => String`

**Description**:

Overwrites `Str` into this string at index `Position`.

**Example**:

```ahk
"banaaa".Overwrite("n", 5) ; "banana"
"appll".Overwrite("e", -1) ; "apple"
```

**Parameters**:

| Parameter Name | Type           | Description                   |
| -------------- | -------------- | ----------------------------- |
| `Str`          | `String`       | String to overwrite with      |
| `Position`     | `Integer := 1` | Index to place the new string |

**Return Value**:

- **Type**: `String`

---

<a id="Delete"></a>

### `Delete(Position: Integer, Length: Integer := 1) => String`

**Description**:

Removes a section from this string at index `Position`,  `Length` characters long.

**Example**:

```ahk
"aapple".Delete(2)       ; "apple"
"banabana".Delete(-4, 2) ; "banana"
```

**Parameters**:

| Parameter Name | Type           | Description    |
| -------------- | -------------- | -------------- |
| `Position`     | `Integer`      | Section start  |
| `Length`       | `Integer := 1` | Section length |

**Return Value**:

- **Type**: `String`

---

<a id="LPad"></a>

### `LPad(PaddingStr: String := " ", n: Integer := 1) => String`

**Description**:

Pads this string on the left using `PaddingStr` a total of `n` times.

**Example**:

```ahk
"foo".LPad(" ", 5) ; "     foo"
```

**Parameters**:

| Parameter Name | Type            | Description             |
| -------------- | --------------- | ----------------------- |
| `PaddingStr`   | `String := " "` | String used for padding |
| `n`            | `Integer := 1`  | Amount of padding       |

**Return Value**:

- **Type**: `String`

---

<a id="RPad"></a>

### `RPad(PaddingStr: String := " ", n: Integer := 1) => String`

**Description**:

Pads this on the right using `PaddingStr` a total of `n` times.

**Example**:

```ahk
"foo".RPad(" ", 5) ; "foo     "
```

**Parameters**:

| Parameter Name | Type            | Description            |
| -------------- | --------------- | ---------------------- |
| `PaddingStr`   | `String := " "` | String used to padding |
| `n`            | `Integer := 1`  | Amount of padding      |

**Return Value**:

- **Type**: `String`

---

<a id="WordWrap"></a>

### `WordWrap(n: Integer := 80) => String`

**Description**:

Strips all whitespace from this string and then formats words into lines with a maximum length of `n` characters.

**Example**:

```ahk
; (use a really small line length for demonstration purposes)
; "hello,`nworld!"
"hello, world!".WordWrap(3)
```

**Parameters**:

| Parameter Name | Type            | Description         |
| -------------- | --------------- | ------------------- |
| `n`            | `Integer := 80` | Maximum line length |

**Return Value**:

- **Type**: `String`

---

<a id="Trim"></a>

### `Trim(OmitChars: String?) => String`

**Description**:

Trims characters from the beginning and end of this string.

**Example**:

```ahk
" foo ".Trim() ; "foo"
```

**Parameters**:

| Parameter Name | Type      | Description        |
| -------------- | --------- | ------------------ |
| `OmitChars`    | `String?` | Characters to trim |

**Return Value**:

- **Type**: `String`

---

<a id="LTrim"></a>

### `LTrim(OmitChars: String?) => String`

**Description**:

Trims characters from the beginning of this string.

**Example**:

```ahk
" foo ".LTrim() ; "foo "
```

**Parameters**:

| Parameter Name | Type      | Description        |
| -------------- | --------- | ------------------ |
| `OmitChars`    | `String?` | Characters to trim |

**Return Value**:

- **Type**: `String`

---

<a id="RTrim"></a>

### `RTrim(OmitChars: String?) => String`

**Description**:

Trims characters from the end of this string.

**Example**:

```ahk
" foo ".RTrim() ; " foo"
```

**Parameters**:

| Parameter Name | Type     | Description       |
| -------------- | -------- | ----------------- |
| `OmitChars`    | `String` | Character to trim |

**Return Value**:

- **Type**: `String`

---

<a id="Format"></a>

### `Format(Args: Any*) => String`

<a id="FormatWith"></a>

### `FormatWith(Args: Any*) => String`

**Description**:

Returns a formatted string, using this string as format pattern.

If an object is passed, it is converted to a string by using its `ToString()` method.

**Example**:

```ahk
"a: {}, b: {}".FormatWith(2, 42) ; "a: 2, b: 42"
```

**Parameters**:

| Parameter Name | Type   | Description                       |
| -------------- | ------ | --------------------------------- |
| `Args`         | `Any*` | Zero or more additional arguments |

**Return Value**:

- **Type**: `String`

---

<a id="StrLower"></a>

### `StrLower() => String`

<a id="ToLower"></a>

### `ToLower() => String`

**Description**:

Converts this string to lowercase.

**Example**:

```ahk
"FOO".ToLower() ; "foo"
```

**Return Value**:

- **Type**: `String`

---

<a id="StrUpper"></a>

### `StrUpper() => String`

<a id="ToUpper"></a>

### `ToUpper() => String`

**Description**:

Converts this string to uppercase.

**Example**:

```ahk
"foo".ToUpper() ; "FOO"
```

**Return Value**:

- **Type**: `String`

---

<a id="StrTitle"></a>

### `StrTitle() => String`

<a id="ToTitle"></a>

### `ToTitle() => String`

**Description**:

Converts this string to title case.

**Example**:

```ahk
"foo".ToTitle() ; "Foo"
```

**Return Value**:

- **Type**: `String`

---

<a id="StrReplace"></a>

### `StrReplace(Pattern: String, Rep: String := "", CaseSense: Primitive := false, &Out: VarRef?, Limit: Integer := -1) => String`

<a id="Replace"></a>

### `Replace(Pattern: String, Rep: String := "", CaseSense: Primitive := false, &Out: VarRef?, Limit: Integer := -1) => String`

**Description**:

Replaces occurrences of `Pattern` in this string.

**Example**:

```ahk
"abz".Replace("z", "c") ; "abc"
```

**Parameters**:

| Parameter Name | Type                 | Description                          |
| -------------- | -------------------- | ------------------------------------ |
| `Pattern`      | `String`             | String whose content is replaced     |
| `Rep`          | `String := ""`       | Replacement string                   |
| `CaseSense`    | `Primitive := false` | Case-sensitivity of the search       |
| `&Out`         | `VarRef?`            | Output of replacements that occurred |
| `Limit`        | `Integer := 1`       | Maximum number of replacements       |

**Return Value**:

- **Type**: `String`

---

<a id="StrSplit"></a>

### `StrSplit(Delimiters: String := "", OmitChars: String?, MaxParts: Integer?) => Array`

<a id="Split"></a>

### `Split(Delimiters: String := "", OmitChars: String?, MaxParts: Integer?) => Array`

**Description**:

Splits this string into separate substrings delimited using `Delimiters`.

If specified, the character list `OmitChars` is trimmed from the beginning and
end of each substring.

`MaxParts` describes the maximum number of substrings to return.

**Example**:

```ahk
"a,b,c,d,e".Split(",") ; ["a", "b", "c", "d", "e"]
```

**Parameters**:

| Parameter Name | Type     | Description                   |
| -------------- | -------- | ----------------------------- |
| `Delimiters`   | `String` | Boundaries between substrings |
| `OmitChars`    | `String` | List of characters to trim    |

**Return Value**:

- **Type**: `Array`

---

<a id="InStr"></a>

### `InStr(Pattern: String, CaseSense: Primitive := false, StartingPos: Integer := 1, Occurrence: Integer := 1) => Integer`

<a id="Contains"></a>

### `Contains(Pattern: String, CaseSense: Primitive := false, StartingPos: Integer := 1, Occurrence: Integer := 1) => Integer`

**Description**:

Searches for a given occurrence of a string, from the left or the right.

**Example**:

```ahk
"foo bar".Contains("b") ; 5
```

**Parameters**:

| Parameter Name | Type                 | Description                      |
| -------------- | -------------------- | -------------------------------- |
| `Pattern`      | `String`             | String to search for             |
| `CaseSense`    | `Primitive := false` | Case-sensitivity of the search   |
| `StartingPos`  | `Integer := 1`       | Position to start searching from |
| `Occurrence`   | `Integer := 1`       | n-th occurrence to search for     |

**Return Value**:

- **Type**: `Integer`

---

<a id="SubStr"></a>

### `SubStr(Start: Integer, Length: Integer?) => String`

**Description**:

Returns a substring at index `Start` and length `Length` in characters.

**Example**:

```ahk
"123abc789".SubStr(4, 3) ; "abc"
```

**Parameters**:

| Parameter Name | Type       | Description                  |
| -------------- | ---------- | ---------------------------- |
| `Start`        | `Integer`  | Start index of the substring |
| `Length`       | `Integer?` | Length in characters         |

**Return Value**:

- **Type**: `String`

---

<a id="__Item"></a>

### `__Item[Start: Integer, Length: Integer := 1] => String`

**Description**:

This item property returns a substring at index `Start` and length `Length` in characters. Unlike `SubStr()`, `Length` defaults to 1 when omitted.

**Example**:

```ahk
("foo bar")[5] ; "b"
```

**Parameters**:

| Parameter Name | Type           | Description                  |
| -------------- | -------------- | ---------------------------- |
| `Start`        | `Integer`      | Start index of the substring |
| `Length`       | `Integer := 1` | Length in characters         |

**Return Value**:

- **Type**: `String`

---

<a id="StrLen"></a>

### `StrLen() => Integer`

**Description**:

Returns the length of this string in characters.

**Example**:

```ahk
"Hello, world!".StrLen() ; 13
```

**Return Value**:

- **Type**: `Integer`

---

<a id="StrCompare"></a>

### `StrCompare(Other: String, CaseSense: Primitive := false) => Integer`

<a id="Compare"></a>

### `Compare(Other: String, CaseSense: Primitive := false) => Integer`

**Description**:

Lexicographically compares this string with `Other`.

**Example**:

```ahk
"a".Compare("b") ; -1
```

**Parameters**:

| Parameter Name | Type                 | Description                        |
| -------------- | -------------------- | ---------------------------------- |
| `Other`        | `String`             | String to be compared              |
| `CaseSense`    | `Primitive := false` | Case-sensitivity of the comparison |

**Return Value**:

- **Type**: `Integer`

---

## Property Details

<a id="IsDigit"></a>

### `IsDigit => Boolean`

<a id="IsXDigit"></a>

### `IsXDigit => Boolean`

<a id="IsAlpha"></a>

### `IsAlpha => Boolean`

<a id="IsUpper"></a>

### `IsUpper => Boolean`

<a id="IsLower"></a>

### `IsLower => Boolean`

<a id="IsAlnum"></a>

### `IsAlnum => Boolean`

<a id="IsSpace"></a>

### `IsSpace => Boolean`

<a id="IsTime"></a>

### `IsTime => Boolean`

**Description**:

Checks whether this string matches a specific pattern.

**Property Type**: `get`

**Example**:

```ahk
"AAA".IsUpper ; true
"aaa".IsLower ; true
"   ".IsSpace ; true
```

**Return Value**:

- **Type**: `Boolean`

---

<a id="IsEmpty"></a>

### `IsEmpty => Boolean`

**Description**:

Returns `true`, if this string is empty.

**Example**:

```ahk
"Hello, world!".IsEmpty ; false
"".IsEmpty              ; true
```

**Return Value**:

- **Type**: `Boolean`

---

<a id="Length"></a>

### `Length => Integer`

**Description**:

Returns the length of this string in characters.

**Property Type**: `get`

**Example**:

```ahk
"Hello, world!".Length ; 13
```

**Return Value**:

- **Type**: `get`

---

<a id="__Item"></a>

### `__Item[Start, Length := 1] => String`

**Description**:

Returns a substring starting at index `Start` with a total length of `Length`
in characters. Unlike `SubStr()`, the second parameter `Length` defaults to `1`.

**Property Type**: `String`

**Example**:

```ahk
("foo")[2]    ; "o"
("bar")[-1]   ; "r"
("foo")[1, 2] ; "fo"
```

**Parameters**:

| Parameter Name | Type           | Description                     |
| -------------- | -------------- | ------------------------------- |
| `Start`        | `Integer`      | Starting index of the substring |
| `Length`       | `Integer := 1` | Length of the substring         |

**Return Value**:

- **Type**: `String`

---

<a id="Size"></a>

### `Size[Encoding] => Integer`

**Description**:

Returns the total size of this string in bytes in the specified encoding
(default UTF-16).

**Property Type**: `get`

**Example**:

```ahk
"foo".Size ; 8 ((3 characters + 1 null terminator) * 2 bytes per character)

; 20127 - US-ASCII
"foo".Size[20127] ; 4 (3 characters + 1 null terminator)
```

**Parameters**:

| Parameter Name | Type        | Description            |
| -------------- | ----------- | ---------------------- |
| `Encoding`     | `Primitive` | Encoding of the string |

**Return Value**:

- **Type**: `Integer`
