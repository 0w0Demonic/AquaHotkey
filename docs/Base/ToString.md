# <[Base](./overview.md)/[ToString](../../src/Base/ToString.ahk)>

## Summary

An interface for turning any value into a human-readable string representation
for debugging and logging purposes.

```ahk
String(Array(1, 2, 3)) ; "[1, 2, 3]"
String(Buffer(128)) ; "Buffer { Ptr: 000000000024D080, Size: 128 }"
String(MsgBox) ; "Func MsgBox"
```

## Method `.ToString()`

Calling the `.ToString()` method on a value converts it into its human-readable
string representation. It is also automatically invoked whenever the value is
passed to `String(Value)`.

## How to Implement

To implement custom string representations for your own classes, simply define
a `.ToString()` method that returns a string.

As opposed to something like [<Base/Eq>](./Eq.md), there's no clear
rules behind implementing `.ToString()`, the only goal is for it to be easily
readable.

```ahk
class Version {
    __New(Major, Minor, Patch) {
        this.Major := Major
        this.Minor := Minor
        this.Patch := Patch
    }

    ToString() => Format("v{}.{}.{}", this.Major, this.Minor, this.Patch)
}

String(Version(3, 0, 0)) ; "v3.0.0"
```

On occasions, however, things might get a little complicated.

- When in doubt, just reuse existing `.ToString()` methods to your full
  advantage.

  ```ahk
  ; (SkipListMap's `.ToString()` method)
  ToString() {
      ...
      return (Object.Prototype.ToString)({
          Size: this.Size,
          Values: Values,
          Structure: Structure,
          Level: this.Level,
          base: ObjGetBase(this)
      })
  }
  ```

- Use `AutoHotkey_ToString.ToString(Val?)` to handle `unset` values more
  easily:

  ```ahk
  ; (ISet's `.ToString()` method)
  ToString() {
      Result := Type(this) . " { "
      Enumer := this.__Enum(1)

      Enumer(&Value)
      AquaHotkey_ToString.ToString(&Value)
      Result .= Value

      while (Enumer(&Value)) {
          Result .= ", "
          AquaHotkey_ToString.ToString(&Value)
          Result .= Value
      }

      Result .= " }"
      return Result
  }
  ```

Because `.ToString()` has no clear rules, feel free to make changes at will.
Ideally, you should do that with the help of [extension classes](../basics.md).

One last thing to mention is that it's always a good idea to implement your
own `.ToString()`. This is because in practice, `Object`'s `.ToString()` method
is rather fragile, and gets stuck in infinite recursion easily.

```ahk
A := Object()
B := Object()

A.Value := B
B.Value := A

MsgBox(String(A)) ; oops! infinite recursion
```
