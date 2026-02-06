# API Overview

## Core Library

- [Installation](./installation.md)
- [Basics](./basics.md)
- [Advanced](./advanced.md)
- [Expert](./expert.md)

## AquaHotkeyX

### List of All Features

- [Base](./Base/overview.md)
  - [DuckTypes](./Base/DuckTypes.md)
  - [Assertions](./Base/Assertions.md)
  - [Buffer](./Base/Buffer.md)
  - [ComValue](./Base/ComValue.md)
  - [Eq](./Base/Eq.md)
  - [Error](./Base/Error.md)
  - [Hash](./Base/Hash.md)
  - [Object](./Base/Object.md)
  - [Ord](./Base/Ord.md)
  - [ToString](./Base/ToString.md)
  - [TypeInfo](./Base/TypeInfo.md)
  - [VarRef](./Base/VarRef.md)
- [Collections](./Collections/overview.md)
  - [Generic](./Collections/Generic/overview.md)
    - [Array](./Collections/Generic/Array.md)
    - [Map](./Collections/Generic/Map.md)
  - [Array](./Collection/Array.md)
  - [BiMap](./Collection/BiMap.md)
  - [HashMap](./Collections/HashMap.md)
  - [HashSet](./Collections/HashSet.md)
  - [ImmutableArray](./Collections/ImmutableArray.md)
  - [ImmutableMap](./Collections/ImmutableMap.md)
  - [ImmutableSet](./Collections/ImmutableSet.md)
  - [LinkedList](./Collections/LinkedList.md)
  - [Map](./Collections/Map.md)
  - [Set](./Collections/Set.md)
  - [SkipListMap](./Collections/SkipListMap.md)
  - [SkipListSet](./Collections/SkipListSet.md)
  - [Zip](./Collections/Zip.md)
- [Func](./Func/overview.md)
  - [Cast](./Func/cast.md)
  - [Comparator](./Func/Comparator.md)
  - [Continuation](./Func/Continuation.md)
  - [Func](./Func/Func.md)
  - [Kwargs](./Func/Kwargs.md)
  - [Lazy](./Func/Lazy.md)
  - [Monoid](./Func/Monoid.md)
  - [Pipes](./Func/Pipes.md)
  - [Predicate](./Func/Predicate.md)
  - [Supplier](./Func/Supplier.md)
  - [Transducer](./Func/Transducer.md)

- [Interfaces](./Interfaces/overview.md)
  - [Enumerable1](./Interfaces/Enumerable1.md)
  - [Enumerable2](./Interfaces/Enumerable2.md)
  - [IArray](./Interfaces/IArray.md)
  - [IBuffer](./Interfaces/IBuffer.md)
  - [IDelegatingMap](./Interfaces/IDelegatingMap.md)
  - [IMap](./Interfaces/IMap.md)
  - [Indexable](./Interfaces/Indexable.md)
  - [ISet](./Interfaces/ISet.md)
  - [Sizeable](./Interfaces/Sizeable.md)

- [IO](./IO/overview.md)
  - [FileUtils](./IO/FileUtils.md)

- [Monads](./Monads/overview.md)
  - [Optional](./Monads/Optional.md)
  - [TryOp](./Monads/TryOp.md)

- [Primitives](./Primitives/overview.md)
  - [Integer](./Primitives/Integer.md)
  - [Number](./Primitives/Number.md)
  - [Primitive](./Primitives/Primitive.md)

- [Stream](./Stream/overview.md)
  - [BaseStream](./Stream/BaseStream.md)
  - [DoubleStream](./Stream/DoubleStream.md)
  - [Gatherer](./Stream/Gatherer.md)
  - [Range](./Stream/Range.md)
  - [Stream](./Stream/Stream.md)

- [String](./String/overview.md)
  - [Formatting](./String/Formatting.md)
  - [Matching](./String/Matching.md)
  - [String](./String/String.md)
  - [Substrings](./String/Substrings.md)

- [System](./System/overview.md)
  - [COM](./System/COM.md)
  - [DLL](./System/DLL.md)

### IO

[Overview](./IO/overview.md)

**File Operations**:

- [<IO/FileUtils>](./IO/FileUtils.md)

High-level file utilities for reading, writing, and manipulating file contents
and metadata.

- [<IO/FileOpen>](./IO/FileOpen.md)

Enhanced file I/O with better error handling and stream-like operations for
reading and writing files.

**Directory Operations**:

- [<IO/Directory>](./IO/Directory.md)

Directory manipulation utilities including listing, creating, and traversing
directory structures.

### Monads

[Overview](./Monads/overview.md)

**Optional**:

- [<Monads/Optional>](./Monads/Optional.md)

Optional type for representing values that may or may not be present. Provides
chainable methods for safe null/unset handling without exceptions.

**Try Operation**:

- [<Monads/TryOp>](./Monads/TryOp.md)

Exception handling wrapper for capturing errors in a functional container.
Enables error-handling chains without try-catch blocks.

### Primitives

[Overview](./Primitives/overview.md)

**Number Types**:

- [<Primitives/Number>](./Primitives/Number.md)

Utilities and extensions for numeric types including type checking and
mathematical operations.

- [<Primitives/Integer>](./Primitives/Integer.md)

Integer-specific utilities for working with whole numbers and integer operations.

**Primitive Base**:

- [<Primitives/Primitive>](./Primitives/Primitive.md)

Base utilities for all primitive types including boxing and type conversions.

### Stream API

[Overview](./Stream/overview.md)

**Stream**:

- [<Stream/Stream>](./Stream/Stream.md)

Lazy stream processing for functional composition of operations on sequences.
Supports map, filter, reduce, and other functional transformations.

**Specialized Streams**:

- [<Stream/DoubleStream>](./Stream/DoubleStream.md)

Stream optimized for numeric double values with numeric-specific operations.

**Range**:

- [<Stream/Range>](./Stream/Range.md)

Numeric range generation and iteration for creating sequences of numbers.

**Gatherer**:

- [<Stream/Gatherer>](./Stream/Gatherer.md)

Stateful stream transformation allowing complex multi-element processing
and aggregation patterns.

**Zip**:

- [<Stream/Zip>](./Stream/Zip.md)

Stream operation for combining multiple sequences element-wise.

### String

[Overview](./String/overview.md)

**String Operations**:

- [<String/String>](./String/String.md)

Extended string methods including case conversion, trimming, and manipulation.

**String Formatting**:

- [<String/StringFormatting>](./String/StringFormatting.md)

String formatting utilities for template substitution and dynamic string generation.

**String Matching**:

- [<String/StringMatching>](./String/StringMatching.md)

Pattern matching and regex utilities for searching and validating strings.

**Substrings**:

- [<String/Substrings>](./String/Substrings.md)

Substring operations and slicing utilities for extracting and manipulating
string segments.

### System & Miscellaneous

[Overview](./System/overview.md)

**COM Interop**:

- [<System/COM>](./System/COM.md)

COM (Component Object Model) interoperability utilities for working with
Windows COM objects and type information.

**DLL Interop**:

- [<System/DLL>](./System/DLL.md)

Dynamic Library interoperability utilities for calling functions from Windows
DLLs with type-safe bindings.
