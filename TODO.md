# TODO List

- tests for new IArray and IMap methods (do they work for all classes?)
- test `IMap#TryDelete()` and `IMap#TryGet()` methods

- add SubList view?
- reversed list view?

- add mapper functions to access an object property by name
  - for example: `Prop(Name) => (Obj) => Obj.%Name%`

- turn `Path()` into a whole class
- stream and doublestream should strictly enforce the return type when
  using `.FlatMap()`.

- `OutputStream` as duck type. In practice, just check whether it's a `File` or
  `BufferEditor`.

## Serialization

- throw error on unsupported types such as `Func`