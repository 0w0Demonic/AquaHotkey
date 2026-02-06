# Basics - Class Prototyping

This guide covers:

- [The fundamentals](#fundamental-concept).
- [Downloading and installing the library](#including-the-library).
- [Writing a simple extension class](#getting-started).

If you're interested in the reasoning and history behind AquaHotkey, check out
[About AquaHotkey](../rambling/00_about.md). It covers some of the design
choices and how the library evolved into its current form.

## Fundamental Concept

AquaHotkey is a framework that allows you to add properties to existing types.
It uses classes as "property containers" whose contents can be moved around
freely.

Let's say we have two classes, the built-in `Array` class and a custom
`ArrayUtils` class which we use to define custom properties for `Array`:

```ahk
class ArrayUtils (custom)
|- ...
`- Prototype
   |- ForEach(Action)
   `- Contains(Value)

    |
    | paste into...
    V

class Array (built-in)
|- ...
`- Prototype
   |- Get(Index, Default?)
   |- Has(Index)
   |- __Item[Key]
   `- etc.
```

Here, `ArrayUtils` takes the role of an *extension class*. In order to use
its properties, they need to be "pasted" into the built-in `Array` class.
This is where AquaHotkey comes into play - its purpose is to dispatch and put
everything in the right place.

```ahk
class Array (built-in)
|- ...
`- Prototype
   |- ForEach(Action)
   |- Contains(Value)
   |
   |- Get()
   |- Has()
   |- __Item[]
   `- etc.
```

## Including the Library

First, go ahead and clone the repo:

```sh
git clone https://www.github.com/0w0Demonic/AquaHotkey.git
```

I recommend putting it into one of the [lib folders](https://www.autohotkey.com/docs/v2/Scripts.htm#lib),
it'll make your work much easier.

You can now `#Include` it like this:

```ahk
#Requires AutoHotkey v2
 #Include <AquaHotkey>
;#Include <AquaHotkeyX>
```

Alternatively, `#Include <AquaHotkeyX>` to include the additional features
in AquaHotkeyX.

## Getting Started

*Extension classes* are classes that derive from `AquaHotkey` and introduce
new properties to the targeted classes.

Here's how to write them:

1. Create a class that derives from `AquaHotkey`.
2. Define a nested class named after the thing to extend (e.g. "Array").
3. Define things as if you're making changes to the actual class (`Array`).

```ahk
class ArrayUtils extends AquaHotkey {
    class Array {
        IsEmpty => (!this.Length)

        Sum() {
            Sum := 0
            for Value in this { ; `this` refers to an array
                Sum += (Value ?? 0)
            }
            return Sum
        }
    }
}

Array(1, 2, 3, 4).Sum() ; 10
Array().IsEmpty         ; true
```

In general, you should write *one feature per class*. For example, if a change
affects several built-in types then the extension class should define multiple
nested classes.

```ahk
class ToString extends AquaHotkey {
    class Array {
        ToString() { ... }
    }
    class Object {
        ToString() { ... }
    }
    ...
}
```

## Exercises

Now that we've covered the very basics, I encourage you to try it out yourself:

- Create a method `String.Contains(Str)` that checks occurrences of
  `Str` inside a string. (hint: use `InStr()`).
- Then, add a method `Array.Count(Value)` to count how many elements
  are equal to `Value`.
- Bonus: try adding `Array.ForEach(Action)`, which calls `Action(Value)`
  on each element in the array.

## Solutions

<details>
  <summary><code>String.Contains(Str)</code></summary>
  <pre>
  class StringContains extends AquaHotkey
  {
      class String {
          Contains(Pattern) => InStr(this, Pattern)
      }
  }
  </pre>
</details>

<details>
  <summary><code>Array.Count(Value)</code></summary>
  <pre>
  class ArrayCount extends AquaHotkey
  {
      class Array {
          Count(Value) {
              Total := 0
              for Elem in this {
                  if (Elem == Value) {
                      Total++
                  }
              }
              return Total
          }
      }
  }
  </pre>
  </details>

<details>
  <summary><code>Array.ForEach(Action)</code></summary>
  <pre>
  class ArrayForEach extends AquaHotkey
  {
      class Array {
          ForEach(Action) {
              GetMethod(Action)
              for Value in this {
                  Action(Value?)
              }
              return this
          }
      }
  }
  </pre>
</details>

---

## Best Practices

- *Consider creating new separate files for your extensions.*

  Extension classes are highly reusable. If you define them in their own files,
  you only have to define them once, and can reuse them elsewhere.

  ```ahk
  #Include <StringUtil>
  ```

- *Don't be afraid to give your classes clear, verbose names.*

  The extensions that you write are *global classes*, visible across the entire
  script - or even worse, across multiple different scripts. It's a good idea
  to give extension classes clear and verbose names.

  ```ahk
  class DefaultEmptyString extends AquaHotkey {
    class Array {
      Default := ""
    }
    class Map {
      Default := ""
    }
  }

  ...

  #Include <DefaultEmptyString>
  ```

  Also, it makes sense to put them in lib folders. Much easier to `#Include`.

---

## Quick Summary

- At its core, AquaHotkey involves moving properties between different classes.
  Classes are treated as property containers, and their contents (properties)
  can be copied and moved freely between each other.
- Extension classes define properties that should be applied
  onto one or more targets, usually built-in classes
  ([or functions](./advanced.md#extending-functions)).
- Schema of an extension class:

  ```ahk
  class (name) extends AquaHotkey {
      class (target) {
          (custom properties)
      }
  }
  ```

- You should usually write only *one feature per class*. Several related changes
  should be collected into a single extension class.
- Extension classes are highly reuseable. It's a good idea to put them into
  separate files for use across different scripts.
- In that case, it makes lots of sense to give them clear and verbose names.