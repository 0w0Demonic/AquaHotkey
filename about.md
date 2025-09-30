# About

## Where it Started

The idea behind AquaHotkey originally came from one of my projects filled with
massive amounts of boilerplate and chaotic data structures.

After some browsing on the forums, I came across
[this post](https://www.autohotkey.com/boards/viewtopic.php?t=124270) that
talked about prototyping in AutoHotkey:

>The script defines a custom method "Contains" for arrays, allowing users to
>check if a specific item is present. \[...\]
>
>```ahk
>Array.Prototype.DefineProp("Contains", { Call: array_contains })
>
>array_contains(arr, search, casesense := 0) {
>    for index, value in arr {
>        if !IsSet(value)
>            continue
>        else if (value == search)
>            return index
>        else if (value = search && !casesense)
>            return index
>    }
>    return 0
>}
>```

I immediately had to test it out, and I was thrilled. Somehow, AutoHotkey didn't
complain even when adding things to `Any.Prototype`.

As a quick fix, my scripts were filled with a messy section of `DefineProp`s.

```ahk
Object.Prototype.DefineProp(...)
Any.Prototype.DefineProp(...)
Number.Prototype.DefineProp(...)
String.Prototype.DefineProp(...)
String.Prototype.DefineProp(...)

Any_Foo(Var) {
    ; ...
}
; ...
```

But somehow, I had to make this easier. The thing that bothered me the most was
having to define each property manually, with a very inconvenient syntax.

That's when I started looking into classes as a possible solution...

## First Prototype

Now with classes. The very first prototype featured a simple loop through a
predefined set of classes, each named after the target to extend, followed by
"Extension". The rest is done by iterating through `ObjOwnProps(Cls)` and
`ObjOwnProps(Cls.Prototype)`, and copying over all of the properties defined
in the class.

```ahk
class AquaHotkey {
    static __New() {
        for Cls in ["ArrayExtension", "MapExtension", ...] {
            ...
        }
    }
}

class ArrayExtension {
    Contains(Search, CaseSense := 0) {
        ; ...
    }
}

class MapExtension {
    ...
}
```

It was already a *lot* more convenient. This abstraction completely took away
the need to think about property descriptors directly. You simply define new
properties exactly like how you would when writing custom classes.

But it was pretty hard to maintain, and very rigid. You always had the same
predefined set of extension classes. Introducing a new class meant having to
add an entry in the array, a new file to put the class into, and then finally
defining a new class with a very strict naming convention.

## Second Prototype

The second iteration came with a new idea:

>"What if I just use nested classes to define all of the things?"

This time, all of the extensions were defined directly inside the `AquaHotkey`
class itself. For example, `AquaHotkey.Array` would apply changes to `Array`.
There was no need to explicitly list which classes should be extended, the
structure itself carried that information.

```ahk
class AquaHotkey {
    class Array {
        ; ...
    }
    class Map {
        ; ...
    }
}
```

This made the design far cleaner, but two big questions remained:

How could I make this modular? And how could I let other people add their own
modules without needing to edit my source code?

I kept experimenting, and at one point I created a subclass just to see what
would happen:

```ahk
class Something extends AquaHotkey {
    ; (empty)
}
```

This failed because of the way I had written `static __New()`:

```ahk
class AquaHotkey {
    static __New() {
        if (this != AquaHotkey) {
            throw Error()
        }
        ; ...
    }
}
```

But that failure was exactly the breakthrough I needed.

## Final Design

The insight was simple: subclasses of `AquaHotkey` could themselves serve as
extension modules. With this design, `static __New()` would automatically
apply extensions whenever a subclass was loaded, with no manual work required.
Nested classes specified precisely which targets to extend, and everything was
defined in plain class syntax.

```ahk
class StringExtension extends AquaHotkey {
    class String {
        Format(Args*) => Format(this, Args*)

        SubStr(Start, Length?) => SubStr(this, Start, Length?)
    }

    class Primitive {
        MsgBox(Args*) => MsgBox(this, Args*)
    }
}

"Hello, World!".SubStr(1, 7).Append("AquaHotkey!").MsgBox()
```

With this, everything fell into place. It was easy to understand, modular,
elegant, and extremely powerful. A completely new way to write AutoHotkey.

## AquaHotkeyX

Once the foundation was stable, I moved on to building a standard library:
AquaHotkeyX. The focus here was on chaining properties together into expressive
pipelines, and exploring how far AquaHotkey's extension model could be pushed.

Very quickly, I realized that functional programming patterns felt like a
natural fit. Surprisingly, AutoHotkey does this really well.

Sequences, monads, optionals, function composition, and piping all combined
into a unique library.

```ahk
; Map { "H": 1, "E": 1, "L": 2, "O": 1 }
"  hello  ".Trim().StrUpper().Stream().Collect(Collector.Frequency)
```

## Backups

The next problem was overriding existing properties. Extension classes do this
destructively, so I created `AquaHotkey_Backup`, a mechanism for snapshotting
class properties before applying new ones. This made it possible to safely
replace or extend behavior without throwing away what was already there.

## Multi-Apply

While experimenting further, I noticed how often I wanted to add the same
functionality to multiple, unrelated classes. Writing everything twice quickly
became tedious. The solution was `AquaHotkey_MultiApply`: a convenient way to
apply a single extension across several targets at once. This pattern also
turned out to be useful for implementing mixins.

## Ignored Classes

As my projects grew larger, I started relying on helper classes for internal
organization. But these were never meant to be treated as extensions, which
caused conflicts.

The answer was `AquaHotkey_Ignore`. Any class derived from it would simply be
skipped during the extension process.

I had to refactor the class structure, because I had very large projects using
their own helper classes and I needed a marker so classes can be ignored.

## Roadmap

Today, the core of AquaHotkey is complete, and most of the work left lies in
expanding the standard library. Contributions are very welcome - if you're
interested, see `CONTRIBUTING.md` for details.

Looking forward, I'd love to add extensions for `Gui` and its many controls.
The challenge is deciding what to include, since the possibilities are broad.
