# Advanced Improvements for AquaHotkey — v2.1-alpha Features

**Date:** 2026-03-16
**Status:** Proposal / Ideas
**Target:** AutoHotkey v2.1-alpha.9 through v2.1-alpha.22+
**Authors:** DB, Claude

## Overview

This document proposes 12 advanced features for AquaHotkey that exploit new
language primitives in the v2.1-alpha series. The features are organized into
tiers by which alpha-specific primitives they depend on and how deeply they
push AHK's capabilities.

The goal is to bring patterns from Haskell, Scala, Rust, SolidJS, Go, and
Clojure into AHK in a way that feels native to AquaHotkey's existing
extension/prototype-injection architecture.

### Alpha Features Referenced

| Feature                    | Alpha Version | Description                                          |
|----------------------------|---------------|------------------------------------------------------|
| `Struct` keyword           | alpha.22      | Typed fields in contiguous memory with known offsets  |
| `&x.y` / `PropRef`        | alpha.22      | Virtual references to object properties               |
| `__Ref` property           | alpha.22      | Custom ref behavior for nested structs                |
| `DefineProp()` function    | alpha.22      | Define typed/struct properties programmatically       |
| `#Module` / `#Import`      | alpha.10+     | Module system with scoped globals                     |
| `Export` / `Import`        | alpha.17+     | Fine-grained symbol export/import                     |
| `?.` optional chaining     | alpha.2       | Safe property access, short-circuits on unset         |
| `??` null coalescing       | alpha.2       | Default value for unset expressions                   |
| `??=` null-assign          | alpha.2       | Assign only if currently unset                        |
| `Props()` on Any           | alpha.18      | Enumerate own and inherited properties on any value   |
| Function expressions       | alpha.3       | `myFunc := (x, y) { return x + y }`                  |
| `Struct` pointer classes   | alpha.22      | `_struct_.Ptr` for struct pointer arithmetic          |
| `Type()` returns `"unset"` | alpha.22      | Detect unset without try/catch                        |

---

## Tier 1: Struct System — Raw Memory Functional Programming

These features exploit the `Struct` system (alpha.22) to bring typed,
memory-efficient data structures to AquaHotkey. No AHK library has explored
this territory.

---

### 1. StructArray — Typed Contiguous Collections

**Problem:** AHK Arrays store each element as a full AHK value (object header +
type tag + payload = 16 bytes per field). For large numerical datasets, this is
extremely wasteful. Iterating 10,000 elements means 10,000 AHK value
dereferences.

**Solution:** A `StructArray` backed by a single contiguous `Buffer`. Elements
are `Struct` instances stored at fixed offsets with no per-element object
allocation.

#### API Design

```ahk
; Define a typed struct
class Vec3 extends Struct {
    Float x, y, z
}

; Create a typed array of 10,000 Vec3 structs
; Internally: one Buffer of 10000 * Vec3.Size bytes
positions := StructArray(Vec3, 10000)

; Index access returns a Struct view into the buffer (no copy)
positions[1].x := 3.14
positions[1].y := 2.71
positions[1].z := 0.0

; Iteration — no object allocation per step
for pos in positions {
    ; pos is a Struct view, not a new object
    total += pos.x
}

; Stream integration
positions.Stream()
    .Map(v => Vec3(v.x * 2, v.y * 2, v.z * 2))
    .RetainIf(v => v.x > 0)
    .Collect(StructCollector(Vec3))

; Bulk operations via DllCall on the raw buffer
DllCall("my_math_lib\batch_normalize",
    "Ptr", positions.Ptr,
    "UInt", positions.Length,
    "CDecl")
```

#### Internal Architecture

```
StructArray
├── .Buffer       → Buffer(count * Struct.Size)
├── .Struct       → the Struct class (Vec3, etc.)
├── .Length        → element count
├── .Ptr           → Buffer.Ptr (for DllCall)
├── .__Item[i]    → returns Struct view at offset (i-1) * Struct.Size
├── .__Enum(n)    → iterates Struct views without allocation
├── .Stream()     → lazy Stream over Struct views
├── .Sort(Comp?)  → in-place qsort on raw buffer
└── .Collect(C)   → collect into another StructArray
```

**Key insight:** Each `__Item` access returns a `Struct` instance whose `Ptr`
points into the buffer at the correct offset. No memory is copied. The struct
"view" is a flyweight — one reusable struct object that repositions its pointer
on each access.

#### Why This Matters

- **Memory:** 10,000 `Float` values = 40KB in a StructArray vs ~160KB+ in an
  AHK Array (plus GC pressure from 10,000 value objects).
- **Speed:** Contiguous memory = CPU cache-friendly iteration. `DllCall` into
  BLAS, SIMD, or any C library that expects a float pointer.
- **Interop:** Pass `.Ptr` directly to COM objects, DllCalls, or shared memory.

#### StructCollector

A `Collector` subclass that accumulates into a `StructArray` instead of an
`Array`:

```ahk
class StructCollector extends Collector {
    __New(StructClass, initialCapacity := 64) {
        this.StructClass := StructClass
        this.InitialCapacity := initialCapacity
    }

    Supplier() => StructArray(this.StructClass, this.InitialCapacity)

    Accumulator(arr, val) {
        ; Grow if needed, copy fields
        arr.Push(val)
    }

    Finisher(arr) => arr.Trim()  ; shrink buffer to actual length
}
```

---

### 2. Struct Lenses — Composable Optics for Nested Data

**Problem:** Updating deeply nested data in AHK is verbose and error-prone.
Immutable updates (returning a modified copy while preserving the original)
require manually cloning at every level.

**Solution:** Lenses — composable pairs of getter/setter that focus on a
specific part of a data structure. Borrowed from Haskell's `lens` library.

#### Concept

A lens is an object with two operations:

- **Get(whole)** — extract the focused part from a whole
- **Set(whole, newPart)** — return a new whole with the focused part replaced

Lenses compose: if you have a lens from `A → B` and a lens from `B → C`, you
can compose them into a lens from `A → C`.

#### API Design

```ahk
; Property lens — focuses on a named property
nameLens := Lens.Prop("name")
nameLens.Get({ name: "Alice", age: 30 })          ; "Alice"
nameLens.Set({ name: "Alice", age: 30 }, "Bob")   ; { name: "Bob", age: 30 }

; Composition — focus deeper
streetLens := Lens.Prop("address").Then(Lens.Prop("street"))
streetLens.Get(user)                               ; "123 Main St"
streetLens.Set(user, "456 Oak Ave")                ; new user with updated street

; Over — modify via function (read-modify-write)
streetLens.Over(user, StrUpper)                    ; street uppercased

; Index lens — focuses on an array index
firstLens := Lens.Index(1)
firstLens.Get([10, 20, 30])                        ; 10
firstLens.Set([10, 20, 30], 99)                    ; [99, 20, 30]

; Struct lens — focuses on a struct field (uses &struct.field PropRef)
posXLens := StructLens(Vec3, "x")
posXLens.Get(myVec3)                               ; 3.14
posXLens.Set(myVec3, 6.28)                         ; new Vec3 with x = 6.28
```

#### Integration with AquaHotkey

```ahk
; Use lenses with Stream and Optional
users.Stream()
    .Map(nameLens.Getter())              ; extract names
    .RetainIf(name => name.Length > 3)
    .ToArray()

; Use lenses with TryOp for safe nested access
TryOp.Value(response)
    .Map(Lens.Prop("data").Then(Lens.Prop("users")).Getter())
    .OrElse(Array())

; Batch update via lens
users.Map(ageLens.Over(, age => age + 1))  ; increment everyone's age
```

#### Internal Architecture

```ahk
class Lens {
    __New(getter, setter) {
        this.DefineProp("Get", { Call: (_, whole) => getter(whole) })
        this.DefineProp("Set", { Call: (_, whole, part) => setter(whole, part) })
    }

    ; Modify focused value via function
    Over(whole, fn) => this.Set(whole, fn(this.Get(whole)))

    ; Compose: this focuses A→B, other focuses B→C, result focuses A→C
    Then(other) => Lens(
        (whole) => other.Get(this.Get(whole)),
        (whole, part) => this.Set(whole, other.Set(this.Get(whole), part))
    )

    ; Return a mapper function suitable for .Map()
    Getter() => (whole) => this.Get(whole)
    Setter(value) => (whole) => this.Set(whole, value)

    ; Built-in lens constructors
    static Prop(name) => Lens(
        (obj) => obj.%name%,
        (obj, val) => (clone := obj.Clone(), clone.%name% := val, clone)
    )

    static Index(i) => Lens(
        (arr) => arr[i],
        (arr, val) => (clone := arr.Clone(), clone[i] := val, clone)
    )
}
```

#### Why This Matters

- **Immutability made practical:** Modify deeply nested data without mutation
  or manual cloning boilerplate.
- **Composability:** Small lenses combine into complex accessors. A library of
  reusable lenses replaces repetitive property access chains.
- **Struct integration:** `&struct.field` (PropRef) provides the foundation for
  efficient struct field lenses that avoid cloning.

---

## Tier 2: Module System — Scoped Extensions

These features exploit the `#Module` / `#Import` system (alpha.10+) to make
AquaHotkey safe for library authors.

---

### 3. Module-Scoped Prototype Extensions

**Problem:** AquaHotkey injects methods into global prototypes. If a library
uses AquaHotkey internally, every consumer of that library gets those prototype
modifications — whether they want them or not. This is the classic "global
monkey-patching" problem.

**Solution:** Module-scoped extensions that only apply within a module boundary.

#### Concept

```ahk
#Module MyLibrary
Import AquaHotkeyX

; .Stream(), .Map(), .Optional() etc. are available here
Export ProcessData(input) {
    return input.Stream()
        .Map(StrLower)
        .RetainIf(s => s.Length > 3)
        .ToArray()
}
```

```ahk
#Module ConsumerApp
Import { ProcessData } from MyLibrary

; ProcessData works, but Array doesn't have .Stream() here
; unless ConsumerApp also imports AquaHotkeyX
result := ProcessData(["Hello", "Hi", "World"])
```

#### Design Challenge

This is architecturally the hardest feature because AquaHotkey's `static __New()`
currently modifies the actual global `Array.Prototype`, `String.Prototype`, etc.
Module scoping requires one of:

**Option A: Prototype Chains per Module**

Each module gets its own prototype chain layer. When module `M` loads AquaHotkey,
the extensions are added to a module-local prototype that sits between the
base type and `M`'s code. Other modules don't see this layer.

This requires AHK's module system to support per-module prototype resolution,
which is unclear from current alpha docs.

**Option B: Wrapper Types**

Instead of modifying prototypes, provide wrapper constructors that are only
visible within the importing module:

```ahk
#Module MyLib
Import { XArray, XString, XMap } from AquaHotkeyScoped

; XArray has all AquaHotkeyX methods, but global Array is untouched
result := XArray(1, 2, 3).Map(x => x * 2)
```

**Option C: Import-Time Extension Selection**

```ahk
Import { StreamOps, Assertions } from AquaHotkeyX

; Only StreamOps and Assertions are injected, not Pipes or ToString
```

#### Status

This depends on how the module system stabilizes. Option B is implementable
today. Options A and C need alpha features that may change before v2.1 stable.

**Recommendation:** Design the API now, implement Option B as a proof of
concept, and migrate to Option A/C when modules stabilize.

---

### 4. Reusable Pipeline Modules

**Problem:** Complex data transformations are written inline and not reusable
across scripts.

**Solution:** Export composed pipelines as module APIs.

```ahk
#Module UserPipeline
Import AquaHotkeyX
Export Import { Collector, Comparator, Condition } from AquaHotkeyX

Export class Transforms {
    static NormalizeName := StrLower
        .AndThen(Trim)
        .AndThen(StrReplace.Bind(,, "_"))

    static ValidAge := Condition.GreaterThan(0)
        .And(Condition.LessThan(150))

    static ByAge := Comparator.Numeric(user => user.age)
}

Export ProcessUsers(users) {
    return users.Stream()
        .Map(u => ({ name: Transforms.NormalizeName(u.name), age: u.age }))
        .RetainIf(u => Transforms.ValidAge(u.age))
        .Sorted(Transforms.ByAge)
        .Collect(Collector.GroupingBy(u => u.age > 30 ? "senior" : "junior"))
}
```

This pattern makes AquaHotkey's functional primitives composable at the module
level — not just inline.

---

## Tier 3: Continuation + Effect System Upgrades

These build on the existing `Cont` / `Effect` / `Do` system.

---

### 5. Coroutines and Generators

**Problem:** AHK has no generator/yield mechanism. Creating lazy sequences
requires manually writing enumerator closures with captured state — tedious
and error-prone.

**Solution:** Python/JS-style generators built on the existing `Cont`
(continuation monad) infrastructure.

#### API Design

```ahk
; Define a generator — yield pauses execution, resumes on next iteration
fibonacci := Generator((yield) {
    a := 0, b := 1
    Loop {
        yield(a)
        temp := b
        b := a + b
        a := temp
    }
})

; Use with for-in (lazy — only computes as needed)
for n in fibonacci {
    if (n > 1000)
        break
    MsgBox(n)
}

; Integrates with Stream (lazy)
fibonacci.Stream()
    .Limit(20)
    .RetainIf(n => Mod(n, 2) == 0)
    .ToArray()  ; first 20 even fibonacci numbers

; Finite generator
countdown := Generator((yield) {
    n := 10
    while (n > 0) {
        yield(n)
        n--
    }
})

; Generator that reads lines from a file lazily
lineReader := Generator.From(path, (yield) {
    f := FileOpen(path, "r")
    while (!f.AtEOF) {
        yield(f.ReadLine())
    }
    f.Close()
})
```

#### How It Works

Under the hood, a Generator captures the continuation at each `yield` point:

1. Caller creates a Generator, passing a body function that receives `yield`.
2. On first iteration (`__Enum`), the body begins executing.
3. When `yield(value)` is called, the current continuation is saved and
   `value` is returned to the caller.
4. On next iteration, execution resumes from the saved continuation.
5. When the body function returns, the generator is exhausted.

```
Generator Body          Caller (for-in)
─────────────          ────────────────
yield(1) ──────────►   &Out := 1, return true
         ◄──────────   (next iteration)
yield(2) ──────────►   &Out := 2, return true
         ◄──────────   (next iteration)
return   ──────────►   return false (done)
```

This uses `Cont` to capture the "rest of the body" at each yield point,
converting synchronous-looking code into a resumable state machine.

#### Why This Matters

- **Eliminates boilerplate:** No manual closure state management for custom
  iterators.
- **Composable:** Generators produce enumerators, which plug directly into
  `Stream()`, `for-in`, `Collect()`, etc.
- **Infinite sequences:** Natural way to express infinite sequences
  (Fibonacci, primes, sensor readings) without allocating everything upfront.

---

### 6. Free Monad — Generalized Effect Interpretation

**Problem:** The current `EffectRunner.Interpret()` uses a fixed `switch`
statement on `effect.Tag`. Adding a new effect type requires modifying the
runner. This couples effect definition to interpretation.

**Solution:** A Free Monad that separates effect description from
interpretation completely. Effects become pure data; any interpreter can
handle them.

#### Concept

```
┌─────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│   Effect DSL    │    │   Free Monad     │    │   Interpreter    │
│                 │    │                  │    │                  │
│ DbEffect.Query  │───►│ Pure(value)      │───►│ TestInterpreter  │
│ DbEffect.Insert │    │ Free(effect, k)  │    │ ProdInterpreter  │
│ HttpEffect.Get  │    │                  │    │ LoggingInterp    │
└─────────────────┘    └──────────────────┘    └──────────────────┘
    DESCRIBE               COMPOSE                EXECUTE
```

#### API Design

```ahk
; 1. Define effects as pure data (no execution logic)
class DbEffect {
    static Query(sql)          => Effect("Db.Query", sql)
    static Insert(table, data) => Effect("Db.Insert", { table: table, data: data })
    static Transaction(effects) => Effect("Db.Transaction", effects)
}

; 2. Write logic using Do-notation (same as today)
GetActiveUsers() {
    return Do()
        .Let("users",  DbEffect.Query("SELECT * FROM users WHERE active = 1"))
        .Let("count",  ctx => Effect.Pure(ctx["users"].Length))
        .Return(ctx => { users: ctx["users"], count: ctx["count"] })
}

; 3. Interpret differently depending on context

; Production: real database
class ProdDbInterpreter extends EffectRunner {
    static Interpret(effect, ctx?) {
        switch effect.Tag {
            case "Db.Query":
                return Cont((k) => {
                    result := this.Connection.Query(effect.Payload)
                    k(result)
                })
            case "Db.Insert":
                return Cont((k) => {
                    this.Connection.Insert(effect.Payload.table, effect.Payload.data)
                    k(true)
                })
        }
        return super.Interpret(effect, ctx?)
    }
}

; Testing: in-memory mock
class MockDbInterpreter extends EffectRunner {
    static Data := Map(
        "SELECT * FROM users WHERE active = 1",
        [{ name: "Alice", active: 1 }, { name: "Bob", active: 1 }]
    )

    static Interpret(effect, ctx?) {
        switch effect.Tag {
            case "Db.Query":
                return Cont.Of(this.Data.Get(effect.Payload, []))
            case "Db.Insert":
                return Cont.Of(true)
        }
        return super.Interpret(effect, ctx?)
    }
}

; Same logic, different execution
GetActiveUsers().Run(MsgBox, ProdDbInterpreter)   ; real DB
GetActiveUsers().Run(MsgBox, MockDbInterpreter)   ; mock data
```

#### Composing Interpreters

```ahk
; Layer interpreters for cross-cutting concerns
class LoggingInterpreter extends EffectRunner {
    static Inner := ProdDbInterpreter

    static Interpret(effect, ctx?) {
        OutputDebug("Effect: " effect.Tag " | " String(effect.Payload))
        result := this.Inner.Interpret(effect, ctx?)
        return result.Map(val => (
            OutputDebug("Result: " String(val)),
            val
        ))
    }
}
```

#### Why This Matters

- **Testability:** Swap the interpreter for tests. No mocking frameworks needed.
- **Separation of concerns:** Business logic doesn't know about databases,
  HTTP, or files — it only describes what it needs.
- **Composability:** Layer logging, metrics, caching as interpreter wrappers
  without touching business logic.

---

### 7. Typed Channels (CSP — Communicating Sequential Processes)

**Problem:** AHK is single-threaded but event-driven. Coordinating between
timer-based producers and consumer logic requires manual state management,
shared variables, and careful ordering.

**Solution:** Go-style channels built on the Effect system. Channels provide a
typed, bounded queue with backpressure via continuations.

#### API Design

```ahk
; Create a bounded channel (buffer size 5)
ch := Channel(5)

; Producer: sends values into the channel
producer := Do()
    .Then(Range(100).ForEachEffect(n => ch.SendEffect(n)))
    .Then(ch.CloseEffect())

; Consumer: receives values from the channel
consumer := Do()
    .Let("items", ch.ReceiveAllEffect())
    .Return(ctx => ctx["items"])

; Run both — producer fills, consumer drains
Array(producer, consumer).Parallel()
    .Run(results => MsgBox(results[2].Join(", ")))
```

#### Backpressure via Continuations

```
Producer                Channel (buffer=2)         Consumer
────────                ──────────────────         ────────
Send(1) ─────────►      [1]                        (idle)
Send(2) ─────────►      [1, 2]                     (idle)
Send(3) ─── SUSPEND     [1, 2] (full)              (idle)
                         ◄──────────────────        Receive() → 1
         ◄── RESUME      [2, 3]                     (has 1)
Send(4) ─────────►      [2, 3, ...next]            ...
```

When a `Send` is attempted on a full channel, the producer's continuation is
suspended. When a consumer `Receive`s and frees a slot, the suspended
continuation is resumed. This is genuine backpressure without blocking the
event loop.

#### Internal Structure

```ahk
class Channel {
    __New(bufferSize := 0) {
        this.Buffer := Array()
        this.Buffer.Capacity := bufferSize
        this.MaxSize := bufferSize
        this.Closed := false
        this.WaitingSenders := Array()    ; suspended Cont callbacks
        this.WaitingReceivers := Array()  ; suspended Cont callbacks
    }

    SendEffect(value) {
        ch := this
        return Effect("Channel.Send", { channel: ch, value: value })
    }

    ReceiveEffect() {
        ch := this
        return Effect("Channel.Receive", { channel: ch })
    }

    CloseEffect() {
        ch := this
        return Effect("Channel.Close", { channel: ch })
    }
}
```

#### Why This Matters

- **Structured concurrency:** Channels enforce ordering and backpressure.
  No race conditions from shared mutable state.
- **Natural producer/consumer:** Timer-based data sources (sensor polling,
  API polling, file watching) feed channels; processing logic consumes.
- **Composable with Effects:** Channels are effects, so they work inside
  `Do()` blocks, compose with `Effect.Try`, etc.

---

## Tier 4: Advanced Functional Patterns

These don't require specific alpha features but complete AquaHotkey's
functional programming story.

---

### 8. Transducers — Source-Independent Transformations

**Problem:** AquaHotkey implements `.Map()`, `.RetainIf()`, `.Reduce()` etc.
separately for `Array`, `Map`, `Stream`, and `Collector`. The same
transformation logic is duplicated 3-4 times. Composing transformations
requires either creating intermediate collections (wasteful) or using
Streams (overkill for simple cases).

**Solution:** Transducers — composable transformation functions that are
independent of the data source and destination.

#### Concept

A transducer is a function that transforms a "reducing step" into another
reducing step:

```
Transducer :: (Reducer) → Reducer
Reducer    :: (Accumulator, Value) → Accumulator
```

Because transducers operate on the reducing function rather than the data,
they can be composed once and applied to any source.

#### API Design

```ahk
; Define a reusable transformation pipeline
xform := Transducer.Map(x => x * 2)
    .Pipe(Transducer.RetainIf(x => x > 5))
    .Pipe(Transducer.Take(10))

; Apply to different sources — same transformation, zero duplication
xform.Into(Array(1, 2, 3, 4, 5))              ; eager → Array
xform.Over(Range(10000).Stream())              ; lazy → Stream
xform.Reduce(Range(1000), 0, (a, b) => a + b) ; direct reduce
xform.Collect(Range(1000), Collector.Sum)      ; into collector
```

#### Built-in Transducers

```ahk
Transducer.Map(fn)             ; transform each element
Transducer.RetainIf(pred)      ; keep elements matching predicate
Transducer.RemoveIf(pred)      ; drop elements matching predicate
Transducer.Take(n)             ; first n elements, then stop
Transducer.Drop(n)             ; skip first n elements
Transducer.TakeWhile(pred)     ; take while predicate holds
Transducer.DropWhile(pred)     ; skip while predicate holds
Transducer.Distinct()          ; unique elements
Transducer.FlatMap(fn)         ; map and flatten
Transducer.Partition(n)        ; group into chunks of n
Transducer.Interpose(sep)      ; insert separator between elements
Transducer.Dedupe()            ; remove consecutive duplicates
```

#### Composition

```ahk
; Transducers compose left-to-right (unlike function composition)
normalize := Transducer.Map(StrLower)
    .Pipe(Transducer.Map(Trim))
    .Pipe(Transducer.RetainIf(s => s != ""))
    .Pipe(Transducer.Distinct())

; Use anywhere
normalize.Into(rawStrings)                    ; Array → Array
normalize.Collect(rawStrings, Collector.Join(", "))  ; Array → String
```

#### Internal Architecture

```ahk
class Transducer {
    __New(xf) {
        ; xf :: (reducer) => reducer
        this.Transform := xf
    }

    ; Compose two transducers
    Pipe(other) {
        thisXf := this.Transform
        otherXf := other.Transform
        return Transducer((reducer) => thisXf(otherXf(reducer)))
    }

    ; Apply to an array, producing a new array
    Into(source) {
        reducer := this.Transform((acc, val) => (acc.Push(val), acc))
        result := Array()
        for val in source {
            result := reducer(result, val)
        }
        return result
    }

    static Map(fn) => Transducer(
        (reducer) => (acc, val) => reducer(acc, fn(val))
    )

    static RetainIf(pred) => Transducer(
        (reducer) => (acc, val) => pred(val) ? reducer(acc, val) : acc
    )
}
```

#### Why This Matters

- **Zero intermediate allocations:** Unlike `.Map().RetainIf().Map()` on
  Arrays, transducers don't create intermediate arrays.
- **One definition, many targets:** Same transformation works on Arrays,
  Streams, Collectors, Channels, or any fold-able source.
- **Composability:** Small transducers combine freely. A library of domain
  transducers replaces repetitive inline chains.

---

### 9. Algebraic Data Types + Pattern Matching

**Problem:** AHK has no sum types (tagged unions with exhaustiveness checking).
Representing "a value that could be one of several shapes" requires either
duck typing (error-prone) or manual type checks (verbose).

**Solution:** First-class ADTs with exhaustive pattern matching.

#### API Design

```ahk
; Define a sum type with variants
class Shape extends ADT {
    static Circle(radius)      => Shape.Variant("Circle", { radius: radius })
    static Rect(w, h)         => Shape.Variant("Rect", { w: w, h: h })
    static Triangle(a, b, c)  => Shape.Variant("Triangle", { a: a, b: b, c: c })
}

; Construct values
myShape := Shape.Circle(5)
myShape.Tag      ; "Circle"
myShape.radius   ; 5

; Exhaustive pattern match
area := Match(myShape)
    .When(Shape.Circle,   s => 3.14159 * s.radius ** 2)
    .When(Shape.Rect,     s => s.w * s.h)
    .When(Shape.Triangle, s => HeronFormula(s.a, s.b, s.c))
    .Exhaustive()  ; throws at LOAD TIME if a variant is missing

; Non-exhaustive with default
label := Match(myShape)
    .When(Shape.Circle, s => "circle r=" s.radius)
    .Default(_ => "other shape")
    .Get()
```

#### Exhaustiveness Checking

The key innovation: `.Exhaustive()` checks at class load time (`static __New`)
that every variant of the ADT is covered:

```ahk
; This THROWS when the script loads (not at runtime):
area := Match(myShape)
    .When(Shape.Circle, s => ...)
    .When(Shape.Rect,   s => ...)
    ; Missing Shape.Triangle — Error!
    .Exhaustive()
```

This is the closest AHK can get to compile-time safety.

#### Integration with Stream

```ahk
; Process heterogeneous collections safely
shapes := Array(Shape.Circle(5), Shape.Rect(3, 4), Shape.Triangle(3, 4, 5))

areas := shapes.Stream()
    .Map(s => Match(s)
        .When(Shape.Circle,   s => 3.14159 * s.radius ** 2)
        .When(Shape.Rect,     s => s.w * s.h)
        .When(Shape.Triangle, s => HeronFormula(s.a, s.b, s.c))
        .Exhaustive())
    .ToArray()
```

#### Built-in ADTs

AquaHotkey could provide common ADTs:

```ahk
; Either — Left or Right (already partially covered by TryOp)
class Either extends ADT {
    static Left(value)  => Either.Variant("Left", value)
    static Right(value) => Either.Variant("Right", value)
}

; Tree — recursive data structure
class Tree extends ADT {
    static Leaf(value)        => Tree.Variant("Leaf", { value: value })
    static Node(left, right)  => Tree.Variant("Node", { left: left, right: right })
}

; List — cons list for functional patterns
class List extends ADT {
    static Nil()            => List.Variant("Nil", {})
    static Cons(head, tail) => List.Variant("Cons", { head: head, tail: tail })
}
```

---

### 10. Reactive Signals

**Problem:** AHK GUIs are imperative — you manually update controls when data
changes. Keeping UI in sync with state requires manual event wiring.

**Solution:** SolidJS-style reactive signals. A `Signal` holds a value and
automatically notifies dependents when it changes. `Computed` derives values
that auto-update. `Watcher` runs side effects on change.

#### API Design

```ahk
; Create a reactive value
count := Signal(0)

; Computed values auto-track dependencies
doubled := Computed(() => count.Value * 2)
label   := Computed(() => "Count: " . doubled.Value)

; Watcher — side effect that reruns when dependencies change
Watcher(() => ToolTip(label.Value))

; Trigger reactivity — all dependents update automatically
count.Value := 5    ; ToolTip shows "Count: 10"
count.Value := 10   ; ToolTip shows "Count: 20"
```

#### Dependency Tracking

```
Signal(count)
  └─► Computed(doubled)     ; reads count.Value → tracked
        └─► Computed(label) ; reads doubled.Value → tracked
              └─► Watcher   ; reads label.Value → tracked → runs side effect
```

When `count.Value` is set:
1. `count` notifies `doubled`
2. `doubled` recomputes, notifies `label`
3. `label` recomputes, notifies `Watcher`
4. `Watcher` re-executes its side effect

Updates propagate synchronously and topologically — no glitches, no stale reads.

#### GUI Integration

```ahk
; Reactive GUI — controls auto-sync with signals
count := Signal(0)

gui := DarkGui("Reactive Counter")

; Text control bound to signal
gui.AddText("w200", "")
Watcher(() => gui["Static1"].Value := "Count: " . count.Value)

; Buttons modify the signal — GUI updates automatically
gui.AddButton("w95", "+1").OnEvent("Click", (*) => count.Value++)
gui.AddButton("w95 x+10", "-1").OnEvent("Click", (*) => count.Value--)

gui.Show()
```

#### Batch Updates

```ahk
; Batch multiple signal changes into one update cycle
Batch(() {
    firstName.Value := "Jane"
    lastName.Value  := "Doe"
    age.Value       := 30
})
; All dependents recompute once, not three times
```

#### Internal Architecture

```ahk
class Signal {
    __New(initialValue) {
        this._value := initialValue
        this._subscribers := Array()
    }

    Value {
        Get {
            ; If a Computed is currently tracking, register this Signal
            if (Signal._currentTracker) {
                Signal._currentTracker._dependencies.Push(this)
            }
            return this._value
        }
        Set {
            if (this._value != value) {
                this._value := value
                this._notify()
            }
        }
    }

    _notify() {
        for subscriber in this._subscribers {
            subscriber._update()
        }
    }
}

class Computed extends Signal {
    __New(computeFn) {
        this._computeFn := computeFn
        this._dependencies := Array()
        ; Initial computation with tracking
        this._track()
    }

    _track() {
        ; Set ourselves as the current tracker
        Signal._currentTracker := this
        this._dependencies := Array()
        this._value := this._computeFn()
        Signal._currentTracker := ""
        ; Subscribe to all read signals
        for dep in this._dependencies {
            dep._subscribers.Push(this)
        }
    }

    _update() {
        ; Unsubscribe from old deps, recompute, subscribe to new deps
        this._track()
        this._notify()
    }
}
```

#### Why This Matters

- **Eliminates manual syncing:** No more `ctrl.Value := newValue` scattered
  across event handlers.
- **Composable state:** Computed values compose freely. Complex derived state
  (filtered lists, aggregated totals, formatted labels) is declared once.
- **Efficient updates:** Only affected dependents recompute. Batch updates
  prevent redundant work.

---

## Tier 5: Research-Grade / Esoteric

These push AHK to its absolute limits. They're valuable as proofs of concept
and for niche performance-critical use cases.

---

### 11. Persistent Immutable Data Structures (HAMT)

**Problem:** Immutable data patterns (used by lenses, reactive signals, and
functional pipelines) require cloning entire data structures on every
"modification." For large maps, this is O(n) per update.

**Solution:** A Hash Array Mapped Trie (HAMT) — an immutable map where
"modifications" return a new map that shares most of its internal structure
with the old one.

#### API Design

```ahk
m1 := PersistentMap()
m2 := m1.Set("a", 1)       ; m1 is unchanged, m2 = { a: 1 }
m3 := m2.Set("b", 2)       ; m2 is unchanged, m3 = { a: 1, b: 2 }
m4 := m3.Remove("a")       ; m3 is unchanged, m4 = { b: 2 }

m3.Get("a")                 ; 1 (still there in m3)
m4.Get("a")                 ; unset (removed in m4)

; Structural sharing: m2, m3, m4 share most trie nodes
; Memory: ~O(log32 N) new nodes per update, not O(N)
```

#### Performance Characteristics

| Operation | AHK Map (mutable) | PersistentMap (HAMT)  |
|-----------|--------------------|-----------------------|
| Get       | O(1) amortized     | O(log32 N) ≈ O(1)    |
| Set       | O(1) amortized     | O(log32 N) + path copy |
| Remove    | O(1) amortized     | O(log32 N) + path copy |
| Clone     | O(N)               | O(1) — just share root |
| Memory    | N entries           | shared nodes across versions |

For practical sizes (< 1M entries), `log32(N)` never exceeds 4, so it's
effectively O(1).

#### Struct-Based Trie Nodes

Using the `Struct` system for trie nodes minimizes object overhead:

```ahk
class TrieNode extends Struct {
    UInt bitmap      ; 32-bit bitmap indicating which children exist
    Ptr  children    ; pointer to child array
    Ptr  entries     ; pointer to key-value pairs at this level
}
```

Each node uses a 32-bit bitmap to indicate which of 32 possible children
exist. A population count (`popcnt`) on the bitmap gives the array index.
This is the same structure used by Clojure, Scala, and Haskell's `HashMap`.

---

### 12. Effect-Based Declarative GUI

**Problem:** AHK GUI code is imperative: create controls, position them, wire
events, manually update on state changes. For complex UIs, this becomes
a tangled mess of event handlers and control references.

**Solution:** Combine Reactive Signals (#10) with the Effect system (#6) to
describe GUIs declaratively.

#### API Design

```ahk
; Declarative GUI description
App() {
    count := Signal(0)
    items := Computed(() =>
        Range(count.Value).Stream()
            .Map(n => ["Item " . n, n * n])
            .ToArray()
    )

    return Gui.Declare(
        Window("Reactive App", "w400 h300",
            VStack(
                Text(() => "Count: " . count.Value),
                HStack(
                    Button("+", (*) => count.Value++, "+Accent"),
                    Button("-", (*) => count.Value--)
                ),
                ListView(["Name", "Square"], () => items.Value)
            )
        )
    ).Run()
}
```

#### How It Works

1. **Describe:** The GUI is a tree of component descriptors (not actual
   controls yet).
2. **Render:** The framework walks the tree, creates actual AHK Gui controls
   with correct positioning.
3. **Bind:** Reactive expressions (lambdas returning signal values) are
   wrapped in `Watcher`s that update controls when signals change.
4. **Re-render:** When a signal changes, only affected controls update.
   The ListView rebuilds its items; the Text updates its label. Buttons
   and layout don't change.

#### Component Descriptors

```ahk
; These return plain objects describing the UI, not actual controls
Text(content, options?)          ; static or reactive text
Button(label, onClick, options?) ; click handler
Edit(value, options?)            ; two-way bound edit
ListView(columns, rows, options?) ; reactive list
VStack(children*)               ; vertical layout
HStack(children*)               ; horizontal layout
If(condition, then, else?)      ; conditional rendering
For(items, template)            ; list rendering
```

#### Why This Matters

- **Separation of concerns:** UI structure is separate from update logic.
- **Automatic updates:** No manual `ctrl.Value := x` calls.
- **Composable:** Components are functions that return descriptors. They
  compose, nest, and can be reused across GUIs.
- **Testable:** The descriptor tree can be inspected without creating
  actual windows.

---

## Implementation Priority

Recommended implementation order based on impact, feasibility, and
dependencies:

| Priority | Feature              | Depends On     | Alpha Required | Impact    |
|----------|----------------------|----------------|----------------|-----------|
| 1        | Transducers          | Nothing        | No (v2.0 ok)   | High      |
| 2        | ADTs + Pattern Match | Nothing        | No (v2.0 ok)   | High      |
| 3        | Coroutines           | Existing Cont  | No (v2.0 ok)   | High      |
| 4        | Reactive Signals     | Nothing        | No (v2.0 ok)   | Very High |
| 5        | StructArray          | Struct system  | alpha.22       | High      |
| 6        | Lenses               | Nothing        | alpha.22 opt.  | Medium    |
| 7        | Free Monad Effects   | Existing Effect| No (v2.0 ok)   | Medium    |
| 8        | Channels (CSP)       | #7 + Cont     | No (v2.0 ok)   | Medium    |
| 9        | Persistent HAMT      | Struct system  | alpha.22       | Low-Med   |
| 10       | Module Extensions    | Module system  | alpha.10+      | High*     |
| 11       | Pipeline Modules     | #10            | alpha.10+      | Medium    |
| 12       | Declarative GUI      | #4 + #7       | No (v2.0 ok)   | Very High |

*\* High impact but blocked on module system stabilization.*

Note that features 1-4 and 6-8 work on stable v2.0 — they don't require alpha
features. The alpha-specific features (5, 9, 10, 11) are the Struct and Module
system integrations.

---

## Relationship to Existing AquaHotkey Architecture

All features integrate through AquaHotkey's existing extension mechanism:

```ahk
class AquaHotkey_Transducers extends AquaHotkey {
    class Array {
        Transduce(xform, reducer, init) { ... }
    }
    class Stream {
        Transduce(xform) { ... }
    }
}

class AquaHotkey_Signals extends AquaHotkey {
    class Any {
        Signal() => Signal(this)      ; wrap value in signal
    }
    class Gui {
        class Control {
            Bind(signal) { ... }      ; two-way bind control to signal
        }
    }
}
```

New types (`Transducer`, `ADT`, `Signal`, `Generator`, `Channel`,
`PersistentMap`, `Lens`) live in `src/Extensions/`. Prototype injections
for existing types live in `src/Builtins/`. Tests mirror source structure
in `tests/`.

This follows the existing `src/Builtins/` vs `src/Extensions/` split and
requires no changes to the core framework in `src/Core/`.
