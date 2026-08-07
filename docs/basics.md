# AquaHotkey - Basics

- [Basics](#basics)
  - [About](#about)
  - [Install](#install)
  - [What is Class Prototyping?](#what-is-class-prototyping)
    - [How to Use it to Your Advantage](#how-to-use-it-to-your-advantage)
  - [The Extension Class](#the-extension-class)
    - [One Feature, One Class](#one-feature-one-class)
    - [Reuse for Other Scripts](#reuse-for-other-scripts)

## About

If you're interested in some of AquaHotkey's design choices and history, check out [About AquaHotkey](../rambling/00_about.md).

## Install

Follow [this guide](./installation.md) to install and include the library in your script.

## What is Class Prototyping?

(also see [Wikipedia: Prototype-based programming](https://en.wikipedia.org/wiki/Prototype-based_programming))

AutoHotkey is a *prototype-based language*, much like JavaScript. In this language, we reuse data and behavior by letting many objects *inherit from* a common *prototype*.

"Prototype" might be a little misleading, because in AutoHotkey this is more commonly known as a *base object*.

A "banana" object would inherit from a "fruit" object that acts as prototype and represents properties and functionality of fruit in general.

When you create an array in AHK, it first inherits from the *array prototype* that defines behavior for all arrays in general. The array prototype itself inherits from the *object prototype* that defines behavior for all object. Finally, the object prototype inherits from *any prototype*, which is the base for all values in AHK.

You can find these prototype objects in `<SomeClass>.Prototype`, for example `Object.Prototype`.

Structurally, our new array looks something like this:

```ahk
[1, 2, 3]
`- Array.Prototype
   `- Object.Prototype
      `- Any.Prototype
```

### How to Use it to Your Advantage

The interesting part is that, if you want to change the behavior of an array, you only need to change its prototype:

```ahk
(Array.Prototype).DefineProp("ForEach", { Call: Array_ForEach })

Array_ForEach(this, Action, Args*) {
    GetMethod(Action)
    for Value in this {
        Action(Value?, Args*)
    }
}
```

Now, every array inherits this method. You can call this new method like this:

```ahk
[1, 2, 3, 4, 5].ForEach(MsgBox)
; ==> 1, 2, 3, 4, 5
```

## The Extension Class

The main focus of AquaHotkey is all about changing these prototype objects to add own behavior. Focus only on the code and class structure, while the extension framework handles the rest:

First start with a new class that `extends AquaHotkey`. Give it a clear, descriptive name. Don't be afraid to make it overly verbose:

```ahk
class Array_ForEach extends AquaHotkey {
}
```

Now, create nested classes. Its name should be that of the class that you want to extend. For example, If you want to extend `Array`, call your nested class `Array`.

```ahk
class Array_ForEach extends AquaHotkey {
    class Array {

    }
}
```

Finally, write code as if you were changing the actual built-in `Array` class.

```ahk
class Array_ForEach extends AquaHotkey {
    class Array {
        ForEach(Action, Args*) {
            GetMethod(Action)
            for Value in this { ; <-- `this` is an array
                Action(Value?, Args*)
            }
        }
    }
}

[1, 2, 3, 4, 5].ForEach(MsgBox)
; ==> 1, 2, 3, 4, 5
```

Note that `.ForEach()` was declared as non-static, which means it's added to the array prototype. To add things to the `Array` class, use a static property:

```ahk
...
static WithCaseSense(CS) {
    Arr := this()
    Arr.CaseSense := CS
    return Arr
}
...

Arr := Array.WithCaseSense(false)
```

### One Feature, One Class

At first, this structure might seem a little unnecessary. After all, why do we need the nested class structure?

The reason is that an extension class represents *one feature*, where changes can span across multiple classes. An extension class should add one functionality to reduce clutter.

```ahk
class ToString extends AquaHotkey {
    class Array  { ToString() { ... } }
    class Object { ToString() { ... } }
    class Map    { ToString() { ... } }
    ...
}
```

Extension classes like [Base/DuckTypes](./base/DuckTypes.md) span across many hundreds of lines of code and across almost all built-in types. AquaHotkey must reliably know where to put different variations of the same methods into different classes.

### Reuse for Other Scripts

After you're done, you can save the extension class into a separate file, and reuse them across multiple scripts.

```ahk
#Include <ToString>
```

Want to know whether an extension class is included in your script? Just use `IsSet()`:

```ahk
if (IsSet(ToString)) {
    MsgBox(Obj.ToString())
} else {
    MsgBox(Type(Obj))
}
```

Start writing small convenience methods, and sooner or later you'll have your own custom version of AHK!
