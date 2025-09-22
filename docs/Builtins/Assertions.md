# Assertions

This package introduces a wide set of assertion methods, perfect for validating
parameters and doing unit tests conveniently.

Each of these methods returns the variable itself, meaning you can chain
multiple assertions together in a fluent, expressive style.

## Features

- Literally Anything

General purpose checks that can take a predicate function.

```ahk
.Assert(Condition, Msg?) ; e.g.: Val.Assert(IsNumber, "not a number")
```

- Types

Verify that a variable derives from a certain type.

```ahk
.AssertType(T, Msg?)
```

- Equality

Compare values by loose and strict (case-sensitive) equality.

```ahk
; "="
Any#AssertEquals(Other, Msg?)

; "!="
Any#AssertNotEquals(Other, Msg?)

; "=="
Any#AssertCsEquals(Other, Msg?)

; "!=="
Any#AssertCsNotEquals(Other, Msg?)
```

- Properties

Ensure that values have certain properties, whether inherited or
owned directly.

```ahk
Any#AssertHasProp(PropName, Msg?)
Object#AssertHasOwnProp(PropName, Msg?)
```

- Numbers

Quickly check numeric relationships like greater-than, less-than,
or range inclusion.

```ahk
Number#AssertGt(x, Msg?)
Number#AssertGe(x, Msg?)
Number#AssertLt(x, Msg?)
Number#AssertLe(x, Msg?)
Number#AssertInRange(x, y, Msg?)
```

## Tip

You can chain all of these assertion methods together to make validation
a lot more compact:

```ahk
Val.AssertType(String).AssertNotEquals("")
```
