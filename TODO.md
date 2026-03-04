# TODO List

- tests for new IArray and IMap methods (do they work for all classes?)
- test `IMap#TryDelete()` and `IMap#TryGet()` methods

- add SubList view?
- reversed list view?
- add `GenericSet`

- add mapper functions to access an object property by name
  - for example: `Prop(Name) => (Obj) => Obj.%Name%`

- move fileutils back to IO (in docs)
- use more JSDoc tags
- turn `Path()` into a whole class
- figure out how to do loose coupling / mutual deps
- stream and doublestream should strictly enforce the return type when
  using `.FlatMap()`.

- `OutputStream` as duck type. In practice, just check whether it's a `File` or
  `BufferEditor`.

## Serialization

- throw error on unsupported types such as `Func`
- for `GenericArray` and `GenericMap`, just serialize the backing map?
