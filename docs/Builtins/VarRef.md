# VarRef

## Passing Strings by Reference

By providing a `Ptr` property for VarRefs, you can now pass strings by
reference (usually to `DllCall`) like this:

```ahk
Text := "This is a test"
Title := "Hello, world!"
DllCall("Ptr", 0, "Ptr", &Test, "Ptr", &Title, "UInt", 0)
```
