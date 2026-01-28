# Inheritance Chain

So it turns out you can change a built-in class's base.

I have no idea how I didn't think of that, I never tried because why would
AHK even allow that?

But the realization is bigger than it seems.

## The Setup

What we're going for is abstract classes here. Something that you can assume
supports a certain feature or characteristic (like being "array-like").

```ahk
class IArray {
    ForEach(Action, Args*) {
        GetMethod(Action)
        for Value in this {
            Action(Value?, Args*)
        }
        return this
    }

    Swap(A, B) {
        Value := this[A]
        this[A] := this[B]
        this[B] := Value
    }
}
```

Then, you simply rearrange the chain of base objects for the type.

```ahk
ObjSetBase(Array, IArray)
ObjSetBase(Array.Prototype, IArray.Prototype)
```

Unsurprisingly, `Array` no longer directly inherits from `Object`, but instead
from `IArray` and then `Object`.

```ahk
Arr := Array(1, 2, 3, 4)
Sum := 0

Arr.ForEach((Val := 0) => (Sum += Val))
MsgBox(Sum) ; 10

Arr.Swap(1, 2)
; --> [2, 1, 3, 4]
```

But interestingly, this also means you're able to *override* whatever
method is inherited from `IArray`, directly inside `Array`:

```ahk
class CustomSwap extends AquaHotkey {
    class Array {
        ; overrides `IArray#Swap(A, B)`
        Swap(A, B) {
            if (this.Has(A)) {
                Value := this[A]
            } else {
                Value := unset
            }
            if (this.Has(B)) {
                this[A] := this[B]
            } else {
                this.Delete(A)
            }
            this[A] := (Value?)
        }
    }
}
```

## Interfaces Without Interfaces

We've just added another layer into the inheritance chain. Every array in
the entire runtime now goes through `IArray` first. This also means that...

```ahk
( Array() is IArray )
```

For AquaHotkey, this is a very interesting pattern. It allows you to
define things in contracts. If a class works "array-like", you just
`extends IArray` the class and inherit all of its properties, with the
assumption that everything "just works".

```ahk
class LinkedList extends IArray {
    ; ( ... )
}


L := LinkedList(1, 2, 3, 4)
L.Swap(2, 3)
L.ForEach(MsgBox) ; 1, 3, 2, 4
```

## Multiple Inheritance (Kinda...)

Because base objects are just objects, you just repeat this procedure
of adding more layers.

```ahk
SetBase(Cls, BaseCls) {
    ObjSetBase(Cls, BaseCls)
    ObjSetBAse(Cls.Prototype, BaseCls.Prototype)
}

SetBase(Array, IArray)
SetBase(IArray, IEnumerable)
SetBase(IEnumerable, Object)
```

Now:

```ahk
Array
`- IArray
   `- IEnumerable
      `- Object
         `- Any
```

It's not classic multiple inheritance, but this still means...

1. every Array is an instance of `IArray`
2. every instance of `IArray` is also instance of `IEnumerable`
3. etc.

## Ehhh... Are You Sure?

These are global changes. However, if you know what you're doing, this should
be totally fine.

However, repeatedly stacking more and more layers is *not* the answer.

If you're ever dealt with old Java stuff, you know what I mean. It becomes
genuinely hard to reason about the easiest things, like...

- where does this method come from?
- where do I land, if I call `super.*Method*()`?

## Why Interfaces Exist

Interfaces decouples this logic into asking "what does this type do?" instead
of "what is this type?".

In other words, they merely care about the implemented properties or methods
of that class, instead of the base object. For something like `IEnumerable`,
this might be `__Enum`. For `IArray`, it might be all built-in array
properties.

## Final Thoughts

This feels like it should be impossible in most languages, but AHK just takes
it with ease.

It's one of the reasons why I keep being fascinated by how far you can push
the object protocol of AHK do its boundaries.
