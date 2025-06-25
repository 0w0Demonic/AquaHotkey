# Stream

Streams are what happens when you stop writing for-loops and start thinking in
pipelines. They're lazy, expressive, and powerful — perfect for anyone who
wants to slice, filter, and map data without boilerplate.

```ahk
Array(1, 2, 3, 4, 5, 6)
    .Stream()
    .RetainIf(x => x > 2)
    .ForEach(MsgBox)
```

## What's a Stream?

Streams are like a conveyor belt for your data. You push stuff on, bolt on some
operations, and pull off exactly what you want at the end — all without
mutating anything. Inspired by Java’s stream API, but tailored to AutoHotkey’s
quirks and strengths.

And yes, they're lazy — nothing happens until you hit something like .ToArray()
or .ForEach(). That means fewer temporary arrays, less memory churn, and a
cleaner mental model.

## Loop-Friendly, Too

```ahk
Stream := Array(1, 2, 3, 4).Stream(2) ; yields Index + Value

for Index, Value in Stream {
    MsgBox(Format("{} = {}", Index, Value))
}
```

Drop them into for loops, chain them into reducers, or just use
`.Collect()` if you're feeling fancy.

### Quick heads-up on naming

You're used to `.Filter()` in most languages — here, we split it:

- `.RetainIf()` keeps elements that match
- `.RemoveIf()` removes those that do

Same goes for `Array`, `Map`, and `Stream`. It’s just more expressive this way.

---

### Stream parameters and arity

Streams can handle up to 4 arguments — like `(Index, Key, Value, etc.)` — and
automatically match them to the function you pass in. If your function only
needs two, it only gets two. Want to keep the rest? Accept them.

```ahk
MyStream.Map((Index, Value) => Format("{} = {}", Index, Value))
```

The moment you call `.Map()` or `.FlatMap()`, you're down to 1-arity. If you
want to preserve structure, transform smarter or offload to something like
`Mapper.Spread()`.

---

### Performance: good, but don’t be reckless

Streams are fast enough for most things — especially numbers and
simple objects.

Be careful with large strings - AHK copies strings around more than you'd think.
Avoid streaming large strings unless you're using `&Str` (by reference).

---

### Works With Anything

You can create a stream with anything you can enumerate in a for-loop. In
AquaHotkeyX, that's also Strings and File objects.

Working with `Range()` is especially fun:

```ahk
; <1, 2, 3, 4, 5, ...>
Range(100).Stream()
```

### Sneak peek: Tuple Streams

You know `ZipArray`? The stream version is coming. Expect something like
`ZipStream` or tuple-aware mappers where `.ForEach()` can auto-spread multiple
values. Until then, try this to get a rough approximate:

```ahk
MyZippedArray.Stream().Map(Mapper.Spread(MyFunc))
```

---

### Recap: Some golden rules

- Use `.Stream(n)` to define how many parameters are yielded
- After `.Map()` or `.FlatMap()`, you're always working with single values
- `.ToArray(n)` extracts a specific param as output
- Prefer composing with `Mapper`, `Combiner`, `Condition` for clarity
- Don’t stream giant strings unless you know what you’re doing
