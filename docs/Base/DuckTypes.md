# <[Base](../api-overview.md)/[DuckTypes](../../src/Base/DuckTypes.ahk)>

## Summary

Introduces a flexible and customizable runtime type system that is based on
duck types. Instead of caring about the base object, you can use any value
as a "type pattern" that imposes a set of characteristics to test on
another value.

```ahk
; A "type pattern" that matches objects with `age` and `name` properties
; 
User := { age: Integer, name: String }

; Another type pattern. This time, an array of `User` objects
Pattern := Array.OfType(User)

; Our value to be tested
Obj := [{ age: 21, name: "Sasha" },
        { age: 37, name: "Sofia" }]

; Determine whether `Obj` matches the "type" imposed by `Pattern`
Obj.Is(Pattern)
```

## How it Works

Normally, the `is` operator checks whether an object is an instance of a
given class based on its base objects. In AquaHotkeyX, this is done with
*pattern matching*. Things can be used as type patterns to impose a set of
characteristics that makes up a type. A value must fulfill these
characteristics to be considered "instance of" that type.

When we call `Val.Is(T)`, we check whether `Val` is instance of the type that
is imposed by `T`.

Lots of formal talk, but it's easier than you might expect as soon as you see
it in action. Let's start with a simple example:

```ahk
"foo".Is(String)
```

For classes, this works as we might usually expect. `String` is our pattern,
whereas `"foo"` is the value to be checked.

The exact way how a pattern matches its value is defined by its `.IsInstance()`
function. For classes, this is simply...

```ahk
("foo" is String)
```

So far, so good.

That means, `Val.Is(T)` is always equivalent to `T.IsInstance(Val)`. For
classes, that's the same as `Val is T`.

### The `.IsInstance(T)` Method

The `.IsInstance()` method of a pattern determines how a value should be
checked for its instance membership. It makes up a system that is extremely
flexible and customizable:

```ahk
class Numeric {
    static IsInstance(Val?) => IsSet(Val) && IsNumber(Val)
}

Val := 42
Val.Is(Numeric) ; true (because `IsSet(42) && IsNumber(42)`)
```

We've just implemented our own duck type `Numeric` that checks whether a value
is a number. When used as a type pattern, it no longer cares about the value's
base objects, but instead checks whether it fulfills the characteristics defined
in `Numeric.IsInstance()`.

### Subclasses and `.CanCastFrom(T)`

To determine whether a type pattern is considered equivalent to, or a subtype
of another type pattern, we can use the `.CanCastFrom(T)` method.

For classes, `C1.CanCastFrom(C2)`, if `(C1 == C2) || HasBase(C2, C1)`.

```ahk
Number.CanCastFrom(Number)  ; true (`Number == Number`)
Number.CanCastFrom(Integer) ; true (`HasBase(Integer, Number)`)

Integer.CanCastFrom(Number) ; false
```

Our previous `Numeric` type should be considered a *supertype* of `Number`.
Every `Number` is also `Numeric`, but not every `Numeric` is a `Number`
(this applies to numeric strings).

To achieve this, we either change the base class to `Number`, or override
`static CanCastFrom(T)`:

```ahk
; << extends Number >>
class Numeric extends Number {
    static IsInstance(Val?) => IsSet(Val) && IsNumber(Val)
}
```

Changing the base of a class to something like `Number` might be unintuitive,
but remember we only use this class to do simple pattern matching and nothing
else.

Other objects define their own `.CanCastFrom()` in a way that reflects how
subtypes work for that particular type. Here's some small examples:

```ahk
; --> true
({ Value: Number }).CanCastFrom({ Value: Integer, OtherValue: Array })

; --> true
Number[].CanCastFrom(Integer[]) ; true

; --> true
([Any, Object]).CanCastFrom([Integer, Array])
```

## Pattern Matching

### Literal Values

Primitive types, such as strings or numbers are used as literals which
are checked for equality (via [`.Eq()`](./Eq.md)).

```ahk
Val := 42
Pattern := 42

MsgBox(Obj.Is(42)) ; true
```

### Object Literals

Plain objects can be used as structural patterns that check for an object's
key-value mappings.

For each of the pattern's fields, an object must define its *own* field with
the same name (case-insensitive) and *also* match the given value.

```ahk
; example #1 : object must have all fields imposed by the pattern
; 
; --> true (OK. defines own `Value`, which is an `Integer`)
({ Value: 42, OtherValue: "a string" })
        .Is({ Value: Integer })

; example #2 : both must be plain objects
; 
Arr := Array()
Arr.Value := 42
Arr.Is({ Value: Integer }) ; false (`Arr` is not a plain object)

; example #3 : nested objects
; 
Order := {
    user: { id: Integer, name: String }
    item: { id: Integer, name: String }
}
Obj := {
    user: { id: 2, name: "John Doe" },
    item: { id: 97823, name: "Cat Ears" }
}
MsgBox(Obj.Is(Order)) ; --> true
```

Note that both the pattern and the object must both be *plain* objects. In
other words, they should directly inherit from `Object.Prototype` instead of
being instances of other classes.

### Array Literals

Regular arrays are be used to test for the "shape" of an array. A pattern like
`[String, Integer]` asserts that an object is an array of length `2`, its
values being instance of `String` and `Integer`, respectively.

```ahk
Arr := ["giraffe", 42]

Arr.Is([String, Integer]) ; true
Arr.Is([Integer, String]) ; false (wrong order)
```

### Generic Arrays

To instead test that an array consists only of a given type, you can use
generic array classes instead.

```ahk
([1, 2, 3, 4, 5]).Is(Integer[]) ; true
```

The same applies to generic arrays:

```ahk
Integer[](1, 2, 3).Is(Number[]) ; true
```

Note that when testing a generic array, its array- and component type are being
tested for compatibility via `.CanCastFrom()`. Here's a quick rundown of how
the example above is evaluated:

```ahk
Integer[](1, 2, 3).Is(Number[])
; --> GenericArray(Array, Integer).CanCastFrom(GenericArray(Array, Number))
; --> Array.CanCastFrom(Array) && Integer.CanCastFrom(Number)
; --> true
```

**Also See**:

- [Generic Arrays](../Collections/GenericArray.md)

### Nullable

Generally speaking, a type is not considered nullable, and `unset` is not
considered a member of any type. However, you can make a type nullable by
using `Nullable(T)`:

```ahk
MaybeInteger := Nullable(Integer)

MaybeInteger.IsInstance(unset)  ; true
MaybeInteger.IsInstance(42)     ; true
MaybeInteger.IsInstance([1, 2]) ; false
```

Nullable is a class that's able to *wrap* an existing type and allow it to be
`unset`. This is known as a *type wrapper*. When using
[generic arrays](../Collections/GenericArray.md), this wrapper can be passed
*between the brackets*:

```ahk
NullableIntegers := Integer[Nullable]
```

As of now, `Nullable` is the only type wrapper already defined in AquaHotkeyX.

### Callable and Numeric

Callable refers to any callable object. In other words, an object with `Call`
property.

```ahk
MsgBox.Is(Callable) ; true

Obj := { Call: (this) => MsgBox("calling method...") }
Obj.Is(Callable) ; true
```

Numeric refers to any number or numeric string:

```ahk
"-123.302".Is(Numeric)
```

### Enums, Intersection and Union Types

Enums represent an enumeration of one or more elements. For a value to be
treated as *member* of the enum, it must be equal to one of the elements
(via [`.Eq()`](./Eq.md)).

```ahk
Permission := Type.Enum("Admin", "User", "Guest")

"Admin".Is(Permission) ; true
"Other".Is(Permission) ; false
```

Combine two or more types together into one, either through intersection
("type must fulfill *all* of those"), or by union ("type must be *one or
more* of those").

```ahk
NumericString := Type.Intersection(Numeric, String)
ArrayOrString := Type.Union(Array, String)
```

### Record

An object with keys of type `K`, and values of type `V`.

```ahk
CatName := Type.Enum("Miffy", "Boris", "Mordred")
CatInfo := { Age: Number, Breed: String }

Cats := {
   Miffy:   { Age: 10, Breed: "Persian"           },
   Boris:   { Age: 5,  Breed: "Maine Coon"        },
   Mordred: { Age: 16, Breed: "British Shorthair" }
}

MsgBox(Cats.Is( Record(CatName, CatInfo) )) ; true
```

## Writing Your Own Duck Types

To create your own duck type, simply define a class with a static
`.IsInstance()` method that checks whether a value fulfills the characteristics
of your type. You *should* also implement `.CanCastFrom()` to define how your
type relates to other types.

```ahk
class Boolean extends Integer {
    static IsInstance(Val?) => IsSet(Val) && ((Val == true) || (Val == false))
}
```

Often times, it's more than enough to simply extend an existing class to
allow `.CanCastFrom()` to work as expected without the need to explicitly
implement it.

Since `true` and `false` are built-in variables for `1` and `0`, we simply
set the base class of `Boolean` to `Integer`, and `.CanCastFrom()` will work
as intended.

## Using Functions as Type Patterns

You can use any arbitrary function as a type pattern. In that case,
the function is assumed to return a boolean value and do the work of
`IsInstance()`. This might become very interesting together with the use of
[predicates](../Func/Predicate.md).

```ahk
(42).Is(  InstanceOf(Numeric).And(Gt(0))  )
```

I *wouldn't* recommend doing this, but I won't stop you from doing so. Just
remember that the lack of `.CanCastFrom()` can become an issue rather quickly.
Proceed with a little more caution.

## Type-Checked Functions

Lastly, you can wrap a function with additional type-checking by calling
`.Checked(Signature)`.

```ahk
CheckedAdd := ((A, B) => (A + B)).Checked([Numeric, Numeric])
```
