# Collector

Collectors are the powerhouse of the [Stream](./Stream.md) ecosystem.
They gather elements into something useful - whether it be an array, map,
string, or some deeply nested structure. They're directly inspired and work
similar to Java's `Collectors`, with some extra flair to work well with other
parts of AquaHotkeyX.

## Works With Anything

Collectors are not a stream-only thing. You can call `.Collect()` on anything
enumerable.

```ahk
; Map{ " ": 1, "!": 1, ",": 1, "H": 1, "d": 1,
;      "e": 1, "l": 3, "o": 2, "r": 1, "w": 1 }
"Hello, world1".Collect(Collector.Frequency)
```

## Aliasing for sanity

Make yourself comfortable first; You should generally "alias" the `Collector`
class to avoid typing it out repeatedly. Like this:

```ahk
C := Collector

Stream(...).Collect(  C.Group(FirstLetter, C.Partition(...))  )
```

Use `C`,`Col`, whatever works - just don't write `Collector.` fifty times.

## Basic Collectors

| Method                                                            | Description                                   |
| ----------------------------------------------------------------- | --------------------------------------------- |
| `.ToArray`, `.ToArray(Mapper)`                                    | returns an array of stream elements           |
| `.Frequency`, `.Frequency(Classifier, MapParam?)`                 | counts by frequency                           |
| `.Count`                                                          | counts elements                               |
| `.Join`, `.Join(Delim, Prefix?, Suffix?)`                         | returns a joined string                       |
| `.Min`, `.Min(Comp)`                                              | returns the smallest element                  |
| `.Max`, `.Max(Comp)`                                              | returns the largest element                   |
| `.Sum`, `.Sum(Mapper)`                                            | sums numbers                                  |
| `.Average`, `.Average(Mapper)`                                    | averages numbers                              |
| `.Reduce(Merger?, Identity?)`                                     | reduces to a single value                     |
| `.Group(Classifier, Next?, MapParam?)`                            | groups elements into a map by the given key   |
| `.Partition(Condition, Next?)`                                    | partitions into a map with `true` and `false` |
| `.ToMap`, `.ToMap(KeyMapper?, ValueMapper?, Merger?, MapParam?)`  | gathers elements into a map (stream-only)     |

## Composing Collectors

Things get very interesting as soon as you **nest** collectors. Here's a nested
`Partition` collector:

```ahk
; Map {
;     true:  Map { true: [...], false: [...] },
;     false: Map { true: [...], false: [...] }
; }
MyStream.Collect(C.Partition(IsEven, C.Partition(GreaterThan100)))
```

This is what makes collectors so declarative and fun to use - just keep nesting
and it'll *just work*.

## Building Your Own Collectors

If you're curious about how you can create your own custom collectors, it's
surprisingly easy. Have a look at [Collector.ahk](../../src/Extensions/Collector.ahk)
for a quick guide on what to do.
