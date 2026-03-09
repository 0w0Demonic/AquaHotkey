# <[Net](./overview.md)/[UrlEncoding](../../src/Net/UrlEncoding.ahk)>

- [\<Net/UrlEncoding\>](#neturlencoding)
  - [Overview](#overview)

## Overview

Simple URL encoding/decoding utility.

Use functions `UrlEncode(Str)`/`UrlDecode(Str)`, or methods
`.UrlEncode()`/`.UrlDecode()` for URL encoding and decoding.

**Encode**:

```ahk
; --> "Hello%2C%2Bworld%21"

UrlEncode("Hello, world!")
"Hello, world!".UrlEncode().MsgBox()
```

**Decode**:

```ahk
; --> "Hello, world!"

UrlDecode("Hello%2C%2Bworld%21")
"Hello%2C%2Bworld%21".UrlDecode()
```
