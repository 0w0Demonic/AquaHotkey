# Basics - Class Prototyping

This guide covers:

- How to include the library in your script.
- How to write simple extension classes.

If you're interested in the reasoning and history behind AquaHotkey, check out
[About AquaHotkey](./docs/about.md). It covers some of the design choices and
why the library evolved into its current form.

## Including the Library

First, go ahead and clone the library:

```sh
git clone https://www.github.com/0w0Demonic/AquaHotkey.git
```

I recommend putting it inside one of the [lib folders](https://www.autohotkey.com/docs/v2/Scripts.htm#lib),
it'll make your work much easier.

You can now `#Include` it like this:

```ahk
#Include <AquaHotkey>
```

### AquaHotkeyX

To include all of the additional extras, use `AquaHotkeyX.ahk` in your file
instead:

```ahk
#Requires AutoHotkey >=v2.0.5
#Include <AquaHotkeyX>
```

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

## How This Works

Okay. What just happened?

- The `ArrayUtils` class initializes.
- All nested class are enumerated - in this case, `ArrayUtils.Array`.
- Everything defined in `ArrayUtils.Array` lands inside `Array`.

Yup, that's it.

---

Always remember to follow this schema, and AquaHotkey will do the rest for you:

```ahk
class CoolStuff extends AquaHotkey
{
    class Array {
        ... ; pretend that this here is the actual `Array` class.
    }
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
              for Value in this {
                  if (Value == Total) {
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
