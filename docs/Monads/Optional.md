# Optional

`Optional` represents a value that might or might not exist. It helps you
avoid messy null checks and forces you to deal with absence in a clean,
declarative way.

## Creating Optionals

```ahk
; call the .Optional() method to create an Optional
Opt := AnyValue.Optional()

; otherwise, use one of the constructors
MaybeValue := Optional("something")
Nothing := Optional.Empty() ; or just `Optional()`
```

## Access & Flow

- `.Get()` – returns the value, or throws if empty
- `.IfPresent(Action, Args*)` – run something if present
- `.IfAbsent(Action, Args*)` – run something if *not* present

```ahk
MaybeValue.IfPresent(MsgBox)
```

## Transforming

- `.Map(Mapper, Args*)` – transforms the value
- `.RetainIf(Condition, Args*)` – keep it if condition passes
- `.RemoveIf(Condition, Args*)` – discard it if condition passes

## Defaults & Fallbacks

- `.OrElse(Default)` – return value or fallback
- `.OrElseGet(Supplier, Args*)` – compute fallback lazily
- `.OrElseThrow(ExceptionSupplier, Args*)` – throw custom error if empty

## Misc

- `.ToString()` gives you a nice debug view
