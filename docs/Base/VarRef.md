# <[Base](./overview.md)/[VarRef](../../src/Base/VarRef.ahk)>

## Property `.Ptr`

`VarRef` now implements the `.Ptr` property, which attempts to find a pointer
value based on the value it references.

This also means that you can pass strings by reference like this:

```ahk
Text := "This is a test"
Title := "Hello, world!"
DllCall("DoSomething", "Ptr", 0, "Ptr", &Test, "Ptr", &Title, "UInt", 0)
```
