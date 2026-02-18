# <[Func](./overview.md)/[Comparator](../../src/Func/Comparator.ahk)>

## Overview

Comparators are functions that impose a total ordering between two input values.
This feature augments [<Base/Comparable>](../Base/Comparable.md) using
function composition, which allows much more fine-grained sorting logic.

```ahk
; compare by string length, then by lexicographical order.
; handle `unset` and consider them "less than" any other value
Comp := Comparator.Num(StrLen).ThenAlpha().NullsFirst()

; --> [unset, "c", "aa", "bb", "dddd"]
Array("bb", "aa", "c", "dddd", unset).Sort(Comp)
```

## Building Comparators

You have several simple ways to create a comparator:

1. **Start with an existing one**
   Use the comparator functions already defined in
   [`<Base/Comparable>`](../Base/Comparable.md) by calling `Class#Compare()`.

   ```ahk
   C := Integer.Compare ; numbers
   C := String.Compare  ; lexicographic
   C := Any.Compare     ; generic fallback
   ```

2. **Numeric or lexical comparators**
   If you just want the usual order:

   ```ahk
   C1 := Comparator.Num             ; numeric
   C2 := Comparator.Alpha           ; lexicographic, case-insensitive
   C3 := Comparator.Alpha("Locale") ; lexicographic, according to locale
   ```

   You can also specify a mapper function to extract values to sort by, as you
   would in method [`.By()`](#composition):

   ```ahk
   Comparator.Num(StrLen)            ; same as (Comparator.Num).By(StrLen)
   Comparator.Alpha(Obj => Obj.Name) ; same as (Comparator.Num).By(Obj => Obj.Name)
   ```

3. **Compare by a mapped key**
   Natural ordering, but through a mapper that extract the value to sort by.

   ```ahk
   Prop(Name) => (Obj) => Obj.%Name%

   ByName := Comparator.By(Prop("Name"))
   ```

4. **Roll your own two-parameter function**

   ```ahk
   Fn := (a, b) => a.Length - b.Length

   C := Comparator(Fn)      ; copy + cast
   C := Comparator.Cast(Fn) ; cast
   ```

   **Also see**:

   - [implementing `.Compare()`](../Base/Comparable.md#implementing-compare)
   - [<Func/Cast>](./Cast.md)

## Composition

Once you have a base comparator, you can transform it. Composition returns
a fresh comparator, the original remains untouched.

- `.By(Mapper, Args*)`: run `Mapper` on both inputs and compare the results.

   ```ahk
   C := (Integer.Compare).By(StrLen)
   C("foo", "bar") ; 0 (lengths are equal)
   ```

- `.Then(Other)`: use the `Other` comparator when the first comparator returns
   zero.

   ```ahk
   C := Comparator.Num(StrLen).Then(Comparator.Alpha)
   ```

- `.ThenBy(Mapper, Args*)`: shorthand for `.Then(Comparator.By(Mapper, Args*))`.

   ```ahk
   class Version {
       __New(Major, Minor, Patch) {
           ...
       }
   }
   Prop(Name) => (Obj) => Obj.%Name%
   C := Comparator.By(Prop("Major")).ThenBy(Prop("Minor")).ThenBy(Prop("Patch"))
   ```

- `.ThenNum(Args*)` and `.ThenAlpha(Args*)`: quick forms of
  `.Then(Comparator.Num(Args*))` and `.Then(Comparator.Alpha(Args*))`,
  respectively.

  ```ahk
  C := Comparator.Num(StrLen).ThenAlpha()
  ```

## Reversing

You can flip a comparator with `.Rev()`.

```ahk
C := (Integer.Compare).Rev() ; descending numeric order
```

Avoid calling `.Rev()` repeatedly, as each invocation wraps the function and
performance degrades with deep nesting.

## Unset Handling

By default, comparators assume both arguments are set. To make one safe for
`unset` values, use one of the following methods:

- `.NullsFirst()`: unset values sort before everything else
- `.NullsLast()`: unset values sort after everything else

These should **always** be the last method in the chain. If you call them
earlier, subsequent composition will remove this type of null-safety.

```ahk
C := Comparator.Num().NullsLast().ThenAlpha() ; wrong!
C := Comparator.Num().ThenAlpha().NullsLast() ; OK.
```

## General Notes

- `StrCompare` is now a comparator; you can call comparator methods on it
  directly.

  ```ahk
  Comp := StrCompare.Rev()
  ```

- Whenever possible, you should reuse the same comparator object rather than
  rebuilding it over again.
