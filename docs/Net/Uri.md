# <[Net](./overview.md)/[Uri](../../src/Net/Uri.ahk)>

- [\<Net/Uri\>](#neturi)
  - [Overview](#overview)
  - [Create](#create)
  - [Properties](#properties)
    - [Raw URI Components](#raw-uri-components)
    - [Value Presence](#value-presence)
  - [Navigation](#navigation)
    - [Normalization](#normalization)
    - [Relativization](#relativization)
    - [Resolution](#resolution)
  - [String Representation](#string-representation)
  - [URI Handlers](#uri-handlers)
  - [String `.ToUri()` Method](#string-touri-method)

## Overview

This class represents Uniform Resource Identifiers, which represent
abstract of physical resources such as webpages, files, or emails.

## Create

Create a new instance by calling `Uri()`, which accepts a string and parses
it into the separate URI components.

```ahk
; URL to website
U := Uri("https://www.github.com/0w0Demonic/AquaHotkey")

; filepath, relative or absolute
U := Uri("/path/to/file.txt")
U := Uri("a/b.txt")
```

Strings are validated according to the syntax rules defined in RFC 3986.
Authorities are not split into smaller components such as user info, host
and port. They are not validated either, but percent escapes are
validated and normalized. This might change in the future.

## Properties

Constructing a new URI will parse the input string into the separate
URI components such as:

- scheme (protocol used to access the resource)
- authority (responsible for the resource)
- path (hierarchical location within the authority)
- query (key-value pairs used as parameters)
- fragment (subsection within the resource)

```ahk
U := Uri("https://example.com/docs/guide.html?key=value#about)

U.Scheme    ; "http"
U.Authority ; "example.com"
U.Path      ; "/docs/guide.html"
U.Query     ; "key=value"
U.Fragment  ; "about"
```

The *scheme-specific* part of an URI includes everything except the scheme
and the fragment. This field is defined whenever the URI has no path and
is considered *opaque*.

```ahk
U.SchemeSpecific ; "//example.com/docs/guide.html?key=value"
```

### Raw URI Components

Components in the URI are URL-encoded. To retrieve components in their "raw"
form without interpreting any escaped octets, use the equivalent property with
`Raw` as prefix.

```ahk
U.RawScheme    ; ...
U.RawAuthority ; ...
...
```

### Value Presence

To determine whether the URI defines a component, use equivalent properties:

```ahk
U := Uri("../file.txt#section")

U.HasScheme         ; false
U.HasAuthority      ; false
U.HasPath           ; true
U.HasQuery          ; false
U.HasFragment       ; true
U.HasSchemeSpecific ; true
```

## Navigation

### Normalization

Use `.Normalize()` to get a new URI with the path normalized. In other words,
all empty segments and single dot segments are removed, and double dot segments
are resolved if possible.

```ahk
Uri("/a/b/../c/./d").Normalize() ; --> "/a/c/d"
```

### Relativization

Use `.Relativize(Base)` to get a new URI that is relative to the specified
base URI. If this URI and the base URI are not compatible, the method returns
this URI.

```ahk
Base := Uri("https://example.com/a/b/")
Uri("https://example.com/a/c/d").Relativize(Base) ; --> "../c/d"
```

### Resolution

Use `.Resolve(Relative)` to get a new URI that is the result of resolving
the specified relative URI against this URI. If the relative URI is not
actually relative, the method returns the relative URI.

```ahk
Base := Uri("https://example.com/a/b/")
Uri("../c/d").Resolve(Base) ; --> "https://example.com/a/c/d"
```

If the relative URI is just a fragment, it is resolved against the current
resource.

```ahk
; --> Uri("path/to/resource.txt#section")
Uri("path/to/resource.txt").Resolve("#section")
```

## String Representation

Calling `.ToString()` will return the original string used to create the URI.
Method `.ToDebugString()` returns a more detailed string representation that
shows the separate components of the URI.

## URI Handlers

You can very easily add custom logic to URIs by creating subclasses of
`Uri` which resemble URIs with specific schemes. For example, you could
create an `HttpUri` class that handles both `http` and `https`.
The constructor of `Uri` knows which return type to use based on the
scheme that is being parsed.

```ahk
class HttpUri extends Uri {
    static Schemes => ["http", "https"]

    Get(Headers := {}) {
        ; ...
    }

    Post(Data?, Headers := {}) {
        ; ...
    }
}

; returns an instance of HttpUri!
U := Uri("https://info.cern.ch")

; perform a GET request to the URI
U.Get()
```

## String `.ToUri()` Method

Lastly, you can use `.ToUri()` on a string to convert it to a URI.

```ahk
; same as: --> Uri("file:///C:/Users")
"file:///C:/Users".ToUri()
```
