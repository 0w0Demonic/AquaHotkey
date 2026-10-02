<ROLE_INTEGRATION>
This module (`Module_AquaHotkeyX.md`) provides specialized knowledge about the AquaHotkeyX standard library — the batteries-included companion to the AquaHotkey extension system.
Prerequisite: `Module_AquaHotkey.md` (core extension system).
</ROLE_INTEGRATION>

<MODULE_OVERVIEW>
AquaHotkeyX is the standard library for AquaHotkey. It adds functional programming methods to all built-in AHK types (Array, String, Map, Buffer, Func, etc.) and introduces new types for streams, optionals, error handling, comparators, and collectors. Everything is prototype-injected at load time — no wrappers, no boilerplate.

AquaHotkeyX targets AutoHotkey v2.0.5+. An alpha variant (`AquaHotkeyX_Alpha`) adds an algebraic effect system requiring v2.1-alpha.9+.
</MODULE_OVERVIEW>

<DETECTION_SYSTEM>
  <EXPLICIT_TRIGGERS>
  Reference this module when user mentions:
  "AquaHotkeyX", "standard library", "Stream", "Optional", "TryOp", "Collector",
  "Gatherer", "Comparator", "Condition", "Mapper", "Combiner", "Range", "Zip",
  "functional programming", "pipe", "chain methods", "fluent API"
  </EXPLICIT_TRIGGERS>
  <IMPLICIT_TRIGGERS>
  Reference this module when user wants to:
  - filter, map, reduce, or sort arrays/maps using functional style
  - handle nullable/optional values safely
  - wrap try-catch in a monadic pattern
  - compose or decorate functions
  - create lazy evaluation pipelines
  - use assertion chaining for testing
  </IMPLICIT_TRIGGERS>
</DETECTION_SYSTEM>

<INTEGRATION>
  <OVERVIEW>
  AquaHotkeyX has three entry points with increasing scope.
  Choose the one that matches your needs.
  </OVERVIEW>

  <STABLE>

  ```cpp
  #Requires AutoHotkey >=v2.0.5
  #Include <AquaHotkeyX>
  ```

  Includes: core extension system + all builtins + all extensions.
  </STABLE>

  <ALPHA>

  ```cpp
  #Requires AutoHotkey >=v2.1-alpha.9
  #Include <AquaHotkeyX_Alpha>
  ```

  Includes: everything in stable + Effect system (`Cont`, `Effect`, `Result`, `Do`, `AhkEffects`).
  Only suggest this entry point when the user explicitly targets v2.1-alpha.
  </ALPHA>

  <CORE_ONLY>

  ```cpp
  #Requires AutoHotkey >=v2.0.5
  #Include <AquaHotkey>
  ```

  Includes: only the core extension system (no stdlib). Use this when the user
  defines their own extensions without needing the standard library.
  </CORE_ONLY>
</INTEGRATION>

<PROJECT_STRUCTURE>
  <OVERVIEW>
  The source is split into two categories that behave differently:

  - `src/Builtins/` — **Extend existing AHK types**. Methods are injected into
    prototypes of `Array`, `String`, `Map`, `Buffer`, `Func`, `Object`, etc.
    After loading, these methods are available directly on instances of those types.

  - `src/Extensions/` — **Define new standalone types**. `Optional`, `TryOp`,
    `Stream`, `Collector`, `Gatherer`, `Comparator`, `Condition`, `Mapper`,
    `Combiner`, `Range`, `Zip`. These are independent classes.
  </OVERVIEW>

  <BUILTINS>
  Files in `src/Builtins/` and what they add:

  | File               | Target Types     | Purpose                                            |
  |--------------------|------------------|----------------------------------------------------|
  | `Any.ahk`          | `Any`            | `.Type`, `.Class` properties on all values          |
  | `Array.ahk`        | `Array`          | `.Slice()`, `.Sort()`, `.Reverse()`, `.Min()`, `.Max()`, `.Sum()`, `.Average()`, `.Join()`, `.Swap()`, `.IsEmpty`, `.HasElements` |
  | `Buffer.ahk`       | `Buffer`         | `.Get<NumType>()`, `.Put<NumType>()` for all numeric types |
  | `Class.ahk`        | `Class`          | Class-level utilities                              |
  | `ComValue.ahk`     | `ComValue`       | COM object extensions                              |
  | `Error.ahk`        | `Error`          | Error type extensions                              |
  | `Func.ahk`         | `Func`           | `.AndThen()`, `.Compose()`, `.And()`, `.Or()`, `.Negate()`, `.Memoized()`, `.WithCatch()`, `.Loop()`, `Func.Self`, `Func.Constantly()` |
  | `Integer.ahk`      | `Integer`        | Integer-specific utilities                         |
  | `Map.ahk`          | `Map`            | `.Keys()`, `.Values()`, `.IsEmpty`, `.PutIfAbsent()`, `.Compute()`, `.ComputeIfAbsent()`, `.ComputeIfPresent()`, `.Merge()` |
  | `Number.ahk`       | `Number`         | Number utilities                                   |
  | `Object.ahk`       | `Object`         | `.BindMethod()`, `.SetBase()`, `.DefineConstant()`, `.DefineGetter()`, `.DefineSetter()` |
  | `Primitive.ahk`    | `Primitive`      | Primitive type utilities                           |
  | `String.ahk`       | `String`         | `__Enum` (iterate chars), `.Length`, `.Size`, `.Lines()`, `.Split()`, `.Replace()`, `.Sub()`, `__Item[]`, `.Prepend()`, `.Append()`, `.Surround()`, `.Repeat()`, `.Reversed()`, `.Formatted()`, `.Compare()` |
  | `VarRef.ahk`       | `VarRef`         | VarRef extensions                                  |
  | `Pipes.ahk`        | `Any`            | `__Call` pipe forwarding + `.o0()` explicit pipe   |
  | `Assertions.ahk`   | `Any`, `Number`, `Object`, `String` | `.Assert()`, `.AssertType()`, `.AssertEquals()`, `.AssertNotEquals()`, `.AssertGt()`, `.AssertLt()`, `.AssertInRange()`, etc. |
  | `ToString.ahk`     | `Array`, `Buffer`, `Class`, `File`, `Func`, `Object`, `VarRef` | `.ToString()` for all major types |
  | `StringMatching.ahk` | `String`       | Pattern matching utilities                         |
  | `Substrings.ahk`   | `String`         | Substring operations                               |
  | `FileUtils.ahk`    | File-related     | File utility methods                               |
  | `StreamOps.ahk`    | `Array`, `Map`   | `.Map()`, `.FlatMap()`, `.RetainIf()`, `.RemoveIf()`, `.Distinct()`, `.Reduce()`, `.ForEach()`, `.AnyMatch()`, `.AllMatch()`, `.NoneMatch()`, `.ReplaceAll()` |
  </BUILTINS>

  <EXTENSIONS>
  Files in `src/Extensions/` and what they provide:

  | File              | Type          | Purpose                                              |
  |-------------------|---------------|------------------------------------------------------|
  | `Optional.ahk`   | `Optional`    | Container that may or may not hold a value            |
  | `TryOp.ahk`      | `TryOp`       | Monadic try-catch — `TryOp.Success` or `TryOp.Failure` |
  | `Stream.ahk`     | `Stream`      | Lazy evaluation pipeline for sequences                |
  | `Range.ahk`      | `Range()`     | Arithmetic progression enumerator                    |
  | `Collector.ahk`  | `Collector`   | Accumulate stream/array elements into a final result  |
  | `Gatherer.ahk`   | `Gatherer`    | Stream-to-stream transformation (from JDK 24)         |
  | `Condition.ahk`  | `Condition`   | Predicate factory (`.GreaterThan()`, `.Equals()`, etc.) |
  | `Mapper.ahk`     | `Mapper`      | Mapper factory (`.Increment`, `.Prefix()`, etc.)      |
  | `Combiner.ahk`   | `Combiner`    | Reducer factory (`.Min()`, `.Max()`, etc.)            |
  | `Comparator.ahk` | `Comparator`  | Composable ordering (`.Numeric()`, `.Alphabetic()`, `.NullsFirst()`) |
  | `Zip.ahk`        | `ZipArray`    | Multi-array zip into tuples                          |
  </EXTENSIONS>
</PROJECT_STRUCTURE>

<SHARED_PATTERNS>
  <OVERVIEW>
  Several types in AquaHotkeyX share a common monadic interface.
  Understanding this shared vocabulary is key to using the library fluently.
  </OVERVIEW>

  <MONADIC_INTERFACE>
  `Optional`, `TryOp`, and `Stream` all support variants of these operations:

  | Operation          | Meaning                                              |
  |--------------------|------------------------------------------------------|
  | `.Map(Fn)`         | Transform the inner value(s) if present/successful   |
  | `.FlatMap(Fn)`     | Transform and flatten (Fn must return same container type) |
  | `.RetainIf(Cond)`  | Keep value only if condition is met                  |
  | `.RemoveIf(Cond)`  | Discard value if condition is met                    |
  | `.Get()`           | Extract value or throw                               |
  | `.OrElse(Default)` | Extract value or return default                      |
  | `.OrElseThrow()`   | Extract value or throw custom error                  |
  | `.ForEach(Action)` | Consume value(s) with side effect                    |
  | `.ToString()`      | String representation                                |

  Array and Map also support `.Map()`, `.RetainIf()`, `.RemoveIf()`, `.ForEach()`,
  `.Reduce()`, `.AnyMatch()`, `.AllMatch()`, `.NoneMatch()` via `StreamOps.ahk`.
  </MONADIC_INTERFACE>

  <PIPE_FORWARDING>
  `Pipes.ahk` adds `__Call` to `Any.Prototype`, enabling method-style calls to
  global functions:

  ```cpp
  ; These are equivalent:
  MsgBox(StrLen("hello"))
  "hello".StrLen().MsgBox()

  ; Explicit pipe with .o0():
  MyValue.o0(ProcessStep1).o0(ProcessStep2, ExtraArg)
  ```

  This is disabled for `Class` objects to prevent ambiguity with static methods.
  </PIPE_FORWARDING>

  <FUNCTION_COMPOSITION>
  `Func.ahk` provides composition and predicate logic on all functions:

  ```cpp
  ; Composition
  TimesTwo(x) => (x * 2)
  PlusFive(x) => (x + 5)
  Combined := TimesTwo.AndThen(PlusFive)
  Combined(3) ; 11

  ; Predicate logic
  IsPositive(x) => (x > 0)
  IsEven(x)     => (Mod(x, 2) == 0)
  IsPositiveEven := IsPositive.And(IsEven)

  ; Memoization
  ExpensiveFn.Memoized()
  ```
  </FUNCTION_COMPOSITION>

  <ASSERTION_CHAINING>
  `Assertions.ahk` adds assertion methods to `Any`, `Number`, `Object`, and `String`.
  All assertions return `this`, enabling fluent chains:

  ```cpp
  UserInput.Assert(IsNumber, "Must be a number")
           .AssertGt(0, "Must be positive")
           .AssertLt(100, "Must be under 100")
  ```

  This is also the testing pattern used in `tests/`:

  ```cpp
  class Array {
      static Sum() {
          Array(1, 2, 3, 4).Sum().AssertEquals(10)
      }
  }
  ```
  </ASSERTION_CHAINING>
</SHARED_PATTERNS>

<TYPE_REFERENCE>
  <OPTIONAL>
    <OVERVIEW>
    A container that may or may not hold a value. Inspired by Java's `java.util.Optional`.
    Use for safe handling of potentially `unset` values.
    </OVERVIEW>

    <CONSTRUCTION>

    ```cpp
    opt := Optional("hello")   ; present
    opt := Optional()          ; empty
    opt := Optional.Empty()    ; empty
    opt := "hello".Optional()  ; present (extension on Any)
    ```

    </CONSTRUCTION>

    <KEY_METHODS>

    ```cpp
    opt.IsPresent              ; true/false
    opt.IsAbsent               ; true/false
    opt.IfPresent(Action)      ; call Action(value) if present
    opt.IfAbsent(Action)       ; call Action() if absent
    opt.Map(Fn)                ; Optional(Fn(value)) or empty
    opt.RetainIf(Cond)         ; keep if condition met
    opt.RemoveIf(Cond)         ; discard if condition met
    opt.Get()                  ; value or throw UnsetError
    opt.OrElse(default)        ; value or default
    opt.OrElseGet(Supplier)    ; value or Supplier()
    opt.OrElseThrow(ErrClass)  ; value or throw
    ```

    </KEY_METHODS>

    <EXAMPLE>

    ```cpp
    Result := GetUserInput()
        .Optional()
        .RetainIf(IsNumber)
        .Map(x => x * 2)
        .OrElse(0)
    ```

    </EXAMPLE>
  </OPTIONAL>

  <TRYOP>
    <OVERVIEW>
    Monadic try-catch. Wraps a computation result as either `TryOp.Success(value)`
    or `TryOp.Failure(error)`. Eliminates nested try-catch blocks.
    </OVERVIEW>

    <CONSTRUCTION>

    ```cpp
    result := TryOp(() => FileRead("file.txt"))  ; capture success or failure
    result := TryOp(FileRead, "file.txt")         ; same, with args
    result := TryOp.Value(42)                     ; known success
    result := SomeFunc.TryCall(args*)             ; via extension on Object
    ```

    </CONSTRUCTION>

    <KEY_METHODS>

    ```cpp
    result.Succeeded             ; true/false
    result.Failed                ; true/false
    result.Map(Fn)               ; transform value, catch errors
    result.FlatMap(Fn)           ; Fn must return TryOp
    result.RetainIf(Cond)        ; filter with error capture
    result.RemoveIf(Cond)        ; inverse filter
    result.Then(Action)          ; side effect on success
    result.OnSuccess(Action)     ; side effect on success
    result.OnFailure(ErrType, Action) ; side effect on failure (typed)
    result.Finally(Action)       ; always runs
    result.Recover(ErrType, Fn)  ; recover from specific error type
    result.Get()                 ; value or rethrow
    result.OrElse(default)       ; value or default
    result.OrElseGet(Fn)         ; value or Fn(error)
    result.OrElseThrow()         ; value or rethrow
    result.Transform(Fn)         ; Fn receives the TryOp itself
    ```

    </KEY_METHODS>

    <EXAMPLE>

    ```cpp
    Content := TryOp(() => FileRead("config.ini"))
        .Map(IniParse)
        .Recover(OSError, err => Map())
        .OrElseThrow()
    ```

    </EXAMPLE>
  </TRYOP>

  <STREAM>
    <OVERVIEW>
    Lazy evaluation pipelines for sequences. Intermediate operations (`.Map()`,
    `.RetainIf()`) are deferred until a terminal operation (`.ForEach()`, `.ToArray()`,
    `.Collect()`) triggers the pipeline.
    </OVERVIEW>

    <NOTATION>
    Documentation uses `<` and `>` to denote stream contents:
    `Array(1, 2, 3).Stream()` → `<1, 2, 3>`
    </NOTATION>

    <CONSTRUCTION>

    ```cpp
    Array(1, 2, 3).Stream()    ; from array
    Stream.Repeat(5)           ; infinite: <5, 5, 5, ...>
    Stream.Iterate(1, x => x + 1) ; infinite: <1, 2, 3, ...>
    Range(10).Stream()         ; from range enumerator
    ```

    </CONSTRUCTION>

    <INTERMEDIATE_OPS>

    ```cpp
    .Map(Fn)            ; transform elements
    .FlatMap(Fn)        ; transform and flatten
    .RetainIf(Cond)     ; filter
    .RemoveIf(Cond)     ; inverse filter
    .Distinct()         ; unique elements
    .Sorted(Comp?)      ; sort with optional Comparator
    .Limit(n)           ; take first n elements
    .Skip(n)            ; skip first n elements
    .Peek(Action)       ; side effect without consuming
    .Gather(Gatherer)   ; custom stream transformation
    ```

    </INTERMEDIATE_OPS>

    <TERMINAL_OPS>

    ```cpp
    .ForEach(Action)    ; consume each element
    .ToArray()          ; collect into Array
    .Collect(Collector) ; collect using Collector
    .Reduce(Combiner)   ; fold into single value
    .Count()            ; count elements
    .Min(Comp?)         ; minimum element
    .Max(Comp?)         ; maximum element
    .AnyMatch(Cond)     ; true if any match
    .AllMatch(Cond)     ; true if all match
    .NoneMatch(Cond)    ; true if none match
    .FindFirst(Cond?)   ; first matching → Optional
    ```

    </TERMINAL_OPS>

    <EXAMPLE>

    ```cpp
    ; Get unique lowercase words longer than 3 chars
    Words := Text.Split(" ")
        .Stream()
        .Map(StrLower)
        .RetainIf(w => StrLen(w) > 3)
        .Distinct()
        .Sorted(Comparator.Alphabetic)
        .ToArray()
    ```

    </EXAMPLE>
  </STREAM>

  <RANGE>
    <OVERVIEW>
    `Range()` is a global function that returns an enumerator for an arithmetic
    progression. Not a class — returns an `Enumerator` directly.
    </OVERVIEW>

    <USAGE>

    ```cpp
    Range(10)          ; 1 through 10
    Range(4, 7)        ; 4, 5, 6, 7
    Range(5, 3)        ; 5, 4, 3 (auto-descending)
    Range(3, 8, 2)     ; 3, 5, 7

    for n in Range(5) {
        ; 1, 2, 3, 4, 5
    }
    ```

    </USAGE>
  </RANGE>

  <COLLECTOR>
    <OVERVIEW>
    Collectors accumulate elements from streams or arrays into a final result.
    They define three steps: `.Supplier()` (init), `.Accumulator()` (add element),
    `.Finisher()` (produce result). Composable for complex aggregations.
    </OVERVIEW>

    <USAGE>

    ```cpp
    ; Use with Stream.Collect() or Array.Collect()
    Array(1, 2, 3).Stream().Collect(Collector.ToArray())

    ; Custom collector via subclass
    class Average extends Collector {
        Supplier()           => { Sum: 0, Count: 0 }
        Accumulator(Acc, V)  => (Acc.Sum += V, Acc.Count++)
        Finisher(Acc)        => Acc.Sum / Acc.Count
    }
    ```

    </USAGE>
  </COLLECTOR>

  <GATHERER>
    <OVERVIEW>
    Gatherers transform a stream of input elements into a stream of output
    elements (one-to-many, many-to-one, or windowed). Adapted from JDK 24.
    Used with `Stream.Gather()`.
    </OVERVIEW>

    <USAGE>

    ```cpp
    ; Fixed-size windows: <[1,2,3], [4,5,6], [7,8,9], [10]>
    Range(10).Gather(Gatherer.WindowFixed(3))

    ; Sliding windows: <[1,2,3], [2,3,4], [3,4,5]>
    Range(5).Gather(Gatherer.WindowSliding(3))
    ```

    </USAGE>
  </GATHERER>

  <COMPARATOR>
    <OVERVIEW>
    Composable ordering functions. Return positive (a > b), zero (a == b),
    or negative (a < b). Chain with `.AndThen()` for multi-key sorting.
    </OVERVIEW>

    <USAGE>

    ```cpp
    ; Basic numeric sort
    Array(5, 1, 3).Sort(Comparator.Numeric)

    ; Multi-key sort: by string length, then alphabetical, nulls first
    Array("a", "foo", "bar", unset).Sort(
        Comparator.Numeric(StrLen)
            .AndThenAlphabetic()
            .NullsFirst()
    )
    ```

    </USAGE>
  </COMPARATOR>

  <CONDITION>
    <OVERVIEW>
    Factory for predicate functions. Use with `.RetainIf()`, `.RemoveIf()`, etc.
    </OVERVIEW>

    <USAGE>

    ```cpp
    Condition.True               ; always true
    Condition.False              ; always false
    Condition.IsNull             ; checks for unset
    Condition.IsNotNull          ; checks for set
    Condition.Equals(x)          ; equality check
    Condition.GreaterThan(x)     ; x > n
    Condition.InstanceOf(Class)  ; type check
    ```

    </USAGE>
  </CONDITION>

  <MAPPER_AND_COMBINER>
    <OVERVIEW>
    `Mapper` and `Combiner` are factory classes providing common transformation
    and reduction functions.
    </OVERVIEW>

    <USAGE>

    ```cpp
    ; Mapper factories
    Array(1, 2, 3).Map(Mapper.Increment)         ; [2, 3, 4]
    Array("a", "b").Map(Mapper.Prefix("item_"))   ; ["item_a", "item_b"]

    ; Combiner factories
    Combiner.Min(Comparator.Numeric)  ; returns smaller of two
    Combiner.Max(Comparator.Numeric)  ; returns larger of two
    ```

    </USAGE>
  </MAPPER_AND_COMBINER>

  <ZIP>
    <OVERVIEW>
    `ZipArray` combines multiple arrays into an array of tuples. Stream methods
    on `ZipArray` unpack tuple elements as separate parameters.
    </OVERVIEW>

    <USAGE>

    ```cpp
    ; [(1, "a"), (2, "b"), (3, "c")]
    ZipArray.Of([1, 2, 3], ["a", "b", "c"])
    ```

    </USAGE>
  </ZIP>
</TYPE_REFERENCE>

<ARRAY_AND_MAP_OPS>
  <OVERVIEW>
  `StreamOps.ahk` injects functional methods directly into `Array` and `Map`.
  These work eagerly (not lazily like Stream) and return new collections.
  </OVERVIEW>

  <ARRAY_METHODS>

  ```cpp
  ; Transformation
  Array(1, 2, 3).Map(x => x * 2)              ; [2, 4, 6]
  Array("hel", "lo").FlatMap(StrSplit)         ; ["h", "e", "l", "l", "o"]
  Array(1, 2, 3).ReplaceAll(x => x * 2)       ; mutates in place

  ; Filtering
  Array(1, 2, 3, 4).RetainIf(x => x > 2)     ; [3, 4]
  Array(1, 2, 3, 4).RemoveIf(x => x > 2)     ; [1, 2]
  Array(1, 2, 3, 1).Distinct()                ; [1, 2, 3]

  ; Aggregation
  Array(1, 2, 3, 4).Reduce((a, b) => a + b)   ; 10
  Array(1, 2, 3, 4).Sum()                     ; 10
  Array(1, 2, 3, 4).Average()                 ; 2.5
  Array(1, 2, 3, 4).Min()                     ; 1
  Array(1, 2, 3, 4).Max()                     ; 4
  Array(1, 2, 3, 4).Join(", ")               ; "1, 2, 3, 4"

  ; Matching
  Array(1, 2, 3).AnyMatch(x => x > 2)         ; { Value: 3 }
  Array(1, 2, 3).AllMatch(x => x > 0)         ; true
  Array(1, 2, 3).NoneMatch(x => x > 5)        ; true

  ; Iteration
  Array(1, 2, 3).ForEach(MsgBox)

  ; Structural
  Array(1, 2, 3, 4).Slice(2, 3)               ; [2, 3]
  Array(1, 2, 3, 4).Reverse()                 ; [4, 3, 2, 1] (in place)
  Array(5, 1, 3).Sort()                       ; [1, 3, 5] (in place)
  Array("b", "a").SortAlphabetically()        ; ["a", "b"]
  ```

  </ARRAY_METHODS>

  <MAP_METHODS>

  ```cpp
  ; Access
  Map(1, 2, "a", "b").Keys()                  ; [1, "a"]
  Map(1, 2, "a", "b").Values()                ; [2, "b"]
  Map().IsEmpty                               ; true

  ; Mutations
  Map().PutIfAbsent("k", "v")
  Map().ComputeIfAbsent("k", key => key . "_val")
  Map(1, 2).ComputeIfPresent(1, (k, v) => v * 2)
  Map().Compute("k", (k, v?) => IsSet(v) ? v + 1 : 1)
  Map().Merge("k", 1, (old, new) => old + new)

  ; Functional
  Map(1, 2, 3, 4).RetainIf((k, v) => k == 1)  ; Map { 1 => 2 }
  Map(1, 2, 3, 4).Map((k, v) => v * 2)        ; Map { 1 => 4, 3 => 8 }
  Map(1, 2, 3, 4).ForEach(PrintKeyValue)
  ```

  </MAP_METHODS>
</ARRAY_AND_MAP_OPS>

<COMPLETE_EXAMPLES>
  <EXAMPLE_DATA_PIPELINE>

  ```cpp
  #Requires AutoHotkey >=v2.0.5
  #Include <AquaHotkeyX>

  ; Read a CSV, parse rows, filter and aggregate
  Lines := FileRead("data.csv").Lines()

  Result := Lines
      .Stream()
      .Skip(1)                                    ; skip header
      .Map(line => line.Split(","))               ; split into fields
      .RetainIf(fields => fields[3] > 100)        ; filter by column 3
      .Map(fields => { Name: fields[1], Value: Integer(fields[3]) })
      .Sorted(Comparator.Numeric(obj => obj.Value))
      .ToArray()
  ```

  </EXAMPLE_DATA_PIPELINE>

  <EXAMPLE_ERROR_HANDLING>

  ```cpp
  #Requires AutoHotkey >=v2.0.5
  #Include <AquaHotkeyX>

  ; Safe file read with typed recovery
  Config := TryOp(() => FileRead("config.ini"))
      .Map(content => ParseIni(content))
      .Recover(OSError, err => DefaultConfig())
      .OnFailure(Error, err => LogError(err))
      .OrElseThrow()
  ```

  </EXAMPLE_ERROR_HANDLING>

  <EXAMPLE_FUNCTION_COMPOSITION>

  ```cpp
  #Requires AutoHotkey >=v2.0.5
  #Include <AquaHotkeyX>

  ; Build a processing pipeline from small functions
  Normalize := StrLower.AndThen(Trim).AndThen(StrReplace.Bind(,, "_"))
  Validate  := IsNumber.And(Condition.GreaterThan(0))

  ; Use the composed functions
  Normalized := Normalize("  Hello World  ")  ; "hello_world"
  IsValid    := Validate(42)                  ; true
  ```

  </EXAMPLE_FUNCTION_COMPOSITION>

  <EXAMPLE_COLLECTOR>

  ```cpp
  #Requires AutoHotkey >=v2.0.5
  #Include <AquaHotkeyX>

  ; Group words by first letter using Collector
  Words := Array("apple", "banana", "avocado", "cherry", "apricot")

  Grouped := Words.Stream().Collect(
      Collector.GroupingBy(word => word.Sub(1, 1))
  )
  ; Map { "a" => ["apple", "avocado", "apricot"], "b" => ["banana"], "c" => ["cherry"] }
  ```

  </EXAMPLE_COLLECTOR>
</COMPLETE_EXAMPLES>

<BEST_PRACTICES>
- Prefer Array/Map methods from `StreamOps.ahk` for simple operations.
  Use `Stream` when you need lazy evaluation, infinite sequences, or complex multi-step pipelines.
- Use `TryOp` instead of nested try-catch blocks. Chain `.Recover()` for typed error handling.
- Use `Optional` when a value might be `unset`. Avoid raw `unset` checks in favor of `.IfPresent()` / `.OrElse()`.
- Use `Comparator` for multi-key sorting instead of writing custom comparison functions.
- Use `Condition`, `Mapper`, and `Combiner` factories instead of anonymous lambdas when the intent is clearer.
- Compose functions with `.AndThen()` / `.Compose()` instead of wrapping in lambdas.
- Always return `this` from methods that modify state for fluent chaining (AquaHotkeyX follows this convention).
</BEST_PRACTICES>

<TESTING_PATTERN>
  Tests are in `tests/` and mirror the source structure (`tests/Builtins/`, `tests/Extensions/`).
  Each test file is a class with static methods. Each method is one test case.
  Assertions return `this` for chaining.

  ```cpp
  class Array {
      static Sort() {
          Array(5, 1, 2, 7).Sort().AssertEquals(Array(1, 2, 5, 7))
      }

      static RetainIf() {
          Array(1, 2, 3, 4).RetainIf(x => x > 2)
              .AssertEquals(Array(3, 4))
      }
  }
  ```

  Use `TestSuite.AssertThrows(Fn)` to verify that a function throws an error.
</TESTING_PATTERN>

<ALPHA_ONLY>
  <OVERVIEW>
  The following types are only available via `#Include <AquaHotkeyX_Alpha>` and
  require AutoHotkey v2.1-alpha.9+. Do NOT suggest these for v2.0 users.
  </OVERVIEW>

  <EFFECT_SYSTEM>
  An algebraic effect system for declarative async/effect composition:

  - `Cont` — Continuation monad for suspended computations
  - `Effect` — Tagged union describing effects (Fetch, Delay, Try, etc.)
  - `Result` — Railway-oriented error handling (Ok/Err)
  - `Do` — Do-notation DSL for fluent effect chains
  - `AhkEffects` — AHK-specific effects (WaitWindow, GuiEvent, etc.)

  ```cpp
  #Requires AutoHotkey >=v2.1-alpha.9
  #Include <AquaHotkeyX_Alpha>

  Do()
      .Let("data",   Effect.Fetch("https://api.com/data"))
      .Let("parsed", Effect.Try(ctx => ParseJson(ctx["data"])))
      .Then(Effect.Delay(100))
      .Return(ctx => ctx["parsed"])
      .Run(result => MsgBox(result.IsOk ? result.Value : "Error"))
  ```

  </EFFECT_SYSTEM>
</ALPHA_ONLY>
