# Object

## Property Definition

For cleaner object definitions and an abstraction from `.DefineProp()`,
AquaHotkeyX provides a few helpers:

- `.DefineConstant()`: define a read-only property
- `.DefineGetter()`, `.DefineSetter()`, `.DefineGetterSetter()`: fine-grained
  control over accessors.
- `.DefineMethod()`: attach methods like a civilized human being

```ahk
Obj.DefineConstant("Foo", "v1.0")
   .DefineGetter("ID", Getter)
   .DefineMethod("DoSomething", Method)
```

In some isolated cases, you might want to return the value itself from
`.DefineConstant()`, e.g. for lazy initialization or quick assignment. However,
for consistency with the rest of the API - and to allow method chaining -
this method returns `this` instead. If needed, you can always access the value
like this:

```ahk
Version := Obj.DefineConstant("Version", "v2.1").Version
```

## Setting Base Objects

`.SetBase()` is a chainable shorthand for `ObjSetBase()` - fits nicely when
composing new objects.

```ahk
obj := Object().SetBase(BasePrototype).Define...
```

## ToString()

Calling `.ToString()` or `String(Obj)` returns a string representation useful
for debugging. It's not meant to be consistent or pretty - just good enough
to see what's going on.

For simple objects, they're fine to use e.g. as map keys. Don't rely too much on
them, though.

```ahk
Str := Obj.ToString()
```
