# Module `<Net>`

- [All Modules](../api-overview.md)

---

- [Module `<Net>`](#module-net)
  - [List of Features](#list-of-features)
  - [URIs](#uris)
  - [URL Encoding](#url-encoding)

## List of Features

- [Uri](./Uri.md)

## URIs

- [Uri](./Uri.md)

A unified resource identifier (URI) is a string of characters that identifies a particular resource.

```ahk
U := Uri("https://www.example.com/path/to/rsc?k=v#frag")
```

## URL Encoding

- [UrlEncoding](./UrlEncoding.md)

Simple utility class that lets you URL encode/decode strings.

```ahk
; "%E2%82%AC"
"€".UrlEncode()
```
