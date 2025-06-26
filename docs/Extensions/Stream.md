# Stream

Streams are what happens when you stop writing for-loops and start thinking in
pipelines. They're lazy, expressive, and powerful; Perfect for anyone who
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

They're lazily evaluated, i.e., nothing happens until you hit something like
`.ToArray()` or `.ForEach().` That means fewer temporary arrays, less memory
churn, and a cleaner mental model.

### Works With Anything

You can create a stream on anything you can enumerate using a for-loop. In
AquaHotkeyX, that's also strings and files.

```ahk
; <1, 2, 3, 4, 5>
Array(1, 2, 3, 4, 5).Stream()

; <("foo", "bar"), ("hotel", "trivago"), ...>
MyMap.Stream(2)

; <"this is line 1", "foo", "this is line 3>
"litany.txt".FileOpen().Stream()

; <"S", "t", "r", "i", "n", "g">
"String".Stream()
```

Working with `Range()` is especially fun:

```ahk
Range(100).Stream() ; <1, 2, 3, 4, 5, ...>
```

### Loop-Friendly, Too

If you don't want to do *everything* with streams, that's totally fine.
You can still perform most of the filtering and mapping with streams, and
then enumerate it normally using a for-loop.

```ahk
Stream := Array(1, 2, 3, 4, 5, 6).Stream().RetainIf(IsEven).Map(TimesTwo)

for Value in Stream {
    ...
}
```

### Sneak peek: Tuple Streams

You know `ZipArray`? The stream version is coming. Expect something like
`ZipStream` or tuple-aware mappers where `.ForEach()` can auto-spread multiple
values. Until then, try this to get a rough approximate:

```ahk
MyZippedArray.Stream().Map(Mapper.Spread(MyFunc))
```

Drop them into for loops, `.Reduce()` each element into a single value,
or just use `.Collect()` if you're feeling fancy.

### Stream parameters and arity

Streams can handle up to 4 arguments and automatically match them to the
function you pass in. If your function only needs two, it only gets two.
Want to keep the rest? Accept them.

```ahk
MyStream.Map((Index, Value) => Format("{} = {}", Index, Value))
```

The moment you call `.Map()` or `.FlatMap()`, you're down to 1-arity. If you
want to preserve structure, make use of maps, arrays, and other objects.

### Quick heads-up on naming

You're used to `.Filter()` in most languages — here, we split it:

- `.RetainIf()` keeps elements that match
- `.RemoveIf()` removes those that do

Same goes for `Array`, `Map`, and `Stream`. It’s just more expressive this way.

### Recap: Some golden rules

- Use `.Stream(n)` to define how many parameters are yielded
- After `.Map()` or `.FlatMap()`, you're always working with single values
- `.ToArray(n)` extracts a specific param as output
- Prefer composing with `Mapper`, `Combiner`, `Condition` for clarity
- Don’t stream giant strings unless you know what you’re doing

## Some Technical Insight

This section gives a quick oversight over how streams work.

It its very core, streams are essentially just multiple `Enumerator`s stacked
on top of each other. Each stage returns a new stream that relies on the
old one, filtering and mapping values on the way.

But how even does an enumerator work in AHK?
Here's what the
[AHK Docs](https://www.autohotkey.com/docs/v2/lib/Enumerator.htm) say:

>An enumerator is a type of function object which is called repeatedly to
>enumerate a sequence of values. Enumerators exist primarily to support
>For-loops, and are not usually called directly.
>
>```ahk
>Boolean := Enum.Call(&OutputVar1 [, &OutputVar2 ])
>```
>
>- This method returns 1 (`true`) if successful or 0 (`false`) if there were no items remaining.

Now let's take a look at [the `__Enum()` method](https://www.autohotkey.com/docs/v2/Objects.htm#__Enum):

>`__Enum(NumberOfVars)`
>
>The `__Enum()` method is called when the object is passed to a for-loop.
>This method should return an enumerator which will return items contained by
>the object, such as array elements. If left undefined, the object cannot be
>passed directly to a for-loop unless it has an enumerator-compatible
>`Call()` method.
>
>`NumberOfVars` contains the number of variables passed to the for-loop.

That's about everything we need to know.

- Enumerators are functions with only VarRef parameters.
- Return `true` to continue pushing values, `false` otherwise.

To create a stream pipeline, we compose these enumerators together. When called,
the enumerator tries to take a value from the previous enumerator, and so on.
On each stage, the data is filtered and mapped.

To demonstrate, here's a very simplified implementation of `Stream.Map()`:

```ahk
Map(Mapper, Args*) {
    GetMethod(Mapper) ; check if `Mapper` is a function
    f := this.Call ; the current enumerator
    return Stream(Impl) ; return a new stream

    Impl(&Out) {
        ; call this stream's enumerator. Are there values left?
        if (f(&A)) {
            Out := Mapper(A?) ; if yes, apply `Mapper` and move to `&Out`
            return true ; "yes, there are more elements to come."
        }
        return false ; "no, there's nothing left."
    }
}
```

`.Map()` method returns a new stream with the inner `.Impl()` becoming its new
enumerator. `.Impl()` takes a reference to `f`, which is the previous enumerator
it takes elements from. When called, it tries to retrieve an element from
the previous enumerator. If there are elements left, `&Out` receives
`Mapper(&A)` as output. Finally, it returns `true` if successful, otherwise
`false`.

## Performance: good, but don’t be reckless

Streams are fast enough for most things - especially numbers and
simple objects.

Be careful with large strings - AHK copies strings around more than you'd think.
Avoid streaming large strings unless you're using `&Str` (by reference).
