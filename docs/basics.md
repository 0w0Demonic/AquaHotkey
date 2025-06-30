# Basics - Class Prototyping

## Why This Matters

AutoHotkey's built-in classes are powerful, but you can't easily modify them.

Want to add `.Sum()` to every array? You'll be stuck writing wrapper functions
like this:

```ahk
Array_Sum(Arr) {
    if (!(Arr is Array)) {
        throw TypeError()
    }
    Result := 0
    for Value in Arr {
        Result += (Value ?? 0)
    }
    return Result
}

Array_Sum([1, 2, 3, 4]) ; 10
```

It works, but it's clunky.

Wouldn't it be better to just write:

```ahk
Array(1, 2, 3, 4).Sum() ; 10
```

The main idea behind AquaHotkey is to make built-in classes *even more*
powerful tailored to your needs - without caring too much about AHK's internals.

## Quick Crash Course

- AquaHotkey lets you *inject methods directly into classes*, so you can call
  them like any normal methods.
- It makes many wrapper functions *obsolete*.
- You can write `ArrayObj.Sum()` instead of `Array_Sum(Arr)`.

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

That's about it, actually. I encourage you to test it out yourself:

- Create a method `String.Contains(Str)` that checks occurrences of
  `Str` inside a string. (hint: use `InStr()`).
- Then, add a method `Array.Count(Value)` to count how many elements
  are equal to `Value`.
- Bonus: try adding `Array.ForEach(Action)`, which calls `Action(Value)`
  on each element in the array.

---

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

These are only *recommendations*, but some very useful considerations:

- Consider writing each extension class into its own file. That way,
  you only have to define it *once* and reuse it across all your scripts.
- Stick to the pattern: *one extension per file*. This keeps things tidy and
  maintainable.
- Since the classes are meant to be reused in many contexts (and the fact that
  they're visible in your scripts), don't be afraid to given them clear, even
  slightly verbose names that makes their purpose obvious. It'll save you
  lots of work in the long run.
