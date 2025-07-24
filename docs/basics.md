# Basics - Class Prototyping

## Quick Crash Course

This is how you write your own extensions:

```ahk
; 1. create a class that extends AquaHotkey
class ArrayUtils extends AquaHotkey {

    ; 2. define a nested class `ArrayStuff.Array` to override `Array`
    class Array {

        ; 3. define things as if you're dealing with the actual `Array` class
        IsEmpty => (!this.Length)

        Sum() {
            Sum := 0
            for Value in this { ; `this` refers to an array
                Sum += (Value ?? 0)
            }
            return Sum
        }
        
        ... ; here some more properties, if you like
    }
}

(  [1, 2, 3, 4]  ).Sum() ; 10

(  []  ).IsEmpty ; true
```

Okay. What just happened?

- The `ArrayUtils` class initializes.
- All nested class are enumerated - in this case, `ArrayUtils.Array`.
- Everything defined in `ArrayUtils.Array` lands inside `Array`.

Yup, that's it.

Always remember to follow this schema, and AquaHotkey will do the rest for you:

```ahk
class CoolStuff extends AquaHotkey
{
    class Array {
        ... ; pretend that this here is the actual `Array` class.
    }
}
```

And yes, this also works for functions, if you really want to:

```ahk
class MsgBoxUtil extends AquaHotkey
{
    class MsgBox {
        ; note: you should prefer static properties whenever you're
        ;       dealing with functions.
        static Info(Text?, Title?) => this(Text?, Title?, 0x40)
    }
}

MsgBox.Info("(insert very informative text here)", "Absolute Cinema")
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

## Conventions

These are only *recommendations*, but some very reasonable ones:

- *Consider creating new separate files for your extensions.*

  This way, you only have to define them *once*, after that you
  can reuse them elsewhere.

  ```ahk
  #Include <StringUtil>
  ```

- *Don't be afraid to give your classes clear, verbose names.*

  The extensions that you write are *global classes*, which are visible
  across the scripts you use. Giving clear names will save you lots
  of work in the long run.

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
