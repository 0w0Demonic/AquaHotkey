# Quick Start

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Quick Start](#quick-start)
  - [What is AquaHotkey?](#what-is-aquahotkey)
  - [Install & Setup](#install--setup)
  - [Extension Framework](#extension-framework)
    - [General](#general)
    - [Debugging](#debugging)
    - [Extension Classes](#extension-classes)
    - [Backup Classes](#backup-classes)
    - [Override Classes](#override-classes)
    - [Mixins](#mixins)
    - [Additional Setup Logic](#additional-setup-logic)
  - [AquaHotkeyX](#aquahotkeyx)

<!-- /code_chunk_output -->

## What is AquaHotkey?

The premise:

- [What is Class Prototyping?](./docs/core.md#what-is-class-prototyping)
- [Using Class Prototyping to your advantage](./docs/core.md#how-to-use-it-to-your-advantage)

How and why to use AquaHotkey:

- [How does AquaHotkey help you script?](./README.md#what-is-aquahotkey)
- [Why to use it](./README.md#why-use-aquahotkey)

## Install & Setup

Prerequisites:

- [Version Requirements](./docs/installation.md#version-requirements)

How to...

- [Install AquaHotkey](./docs/installation.md#download)
  - [On GitHub](./docs/installation.md#github)
  - [Aris Package Manager](./docs/installation.md#aris)
- [Include AquaHotkey in your script](./docs/installation.md#import)

For power users:

- [Perform an advanced setup](./docs/installation.md#advanced-setup)

## Extension Framework

### General

Overview of all features:

- [Class Hierarchy](./docs/core.md#class-hierarchy)
  - [Extension Classes](#extension-classes)
  - [Ignored Classes](./docs/core.md#ignored-classes)
  - [Backup Classes](./docs/core.md#backup-classes)
  <!-- TODO add classes here -->

Project organization and structure:

- [one feature, one class](./docs/core.md#one-feature-one-class)
- [one feature, one file](./docs/core.md#one-feature-one-file)

### Debugging

- [debug messages](./docs/core.md#debug-messages)
  - [verbose mode](./docs/core.md#verbose-mode)
  - [own debug messages](./docs/core.md#own-debug-messages)

### Extension Classes

- [what is an extension class?](./docs/core.md#what-is-an-extension-class)
- [how to create an extension class](./docs/core.md#how-to-create-an-extension-class)
  - [static and instance properties](./docs/core.md#static-and-instance-properties)
  - [nested classes](./docs/core.md#nested-classes)
    - [apply an extension to an already existing nested class](./docs/core.md#apply-an-extension-to-already-existing-nested-class)
  - [functions](./docs/core.md#functions)
    - [extend a function](./docs/core.md#extend-a-function)
    - [override a function](./docs/core.md#override-a-function)
- [how to write extensions effectively](./docs/core.md#how-to-write-extensions-effectively)
  - [smart static properties](./docs/core.md#smart-static-properties)
  - [smart instance properties](./docs/core.md#smart-instance-properties)
  - [one feature, one class](./docs/core.md#one-feature-one-class)
  - [one feature, one file](./docs/core.md#one-feature-one-file)
  - [check whether an extension exists in the script](./docs/core.md#check-whether-an-extension-exists-in-the-script)
- [variable declarations](./docs/core.md#variable-declarations)
  - [what are variable declarations?](./docs/core.md#what-are-variable-declarations)
  - [the two syntaxes](./docs/core.md#the-two-syntaxes)
  - [use in extension classes](./docs/core.md#use-in-extension-classes)
  - [array and object literals](./docs/core.md#array-and-object-literals)
  - [static declarations](./docs/core.md#static-declarations)
  - [always prefer `.__Init()` syntax](./docs/core.md#always-prefer-__init-syntax)
  - [multiple variable declarations](./docs/core.md#multiple-variable-declarations)
  - [on primitive classes](./docs/core.md#on-primitive-classes)

### Backup Classes

- [what is a backup class?](./docs/core.md#backup-classes)
- [create new classes at runtime](./docs/core.md#create-new-classes-at-runtime)
  - [known issues](./docs/core.md#known-issues)

### Override Classes

- [what are override classes?](./docs/core.md#override-classes)
  - [what is `__super__()`?](./docs/core.md#what-is-__super__)
  - [override rules](./docs/core.md#override-rules)
  - [multiple overrides](./docs/core.md#multiple-overrides)
  - [recommended use](./docs/core.md#recommended-use)
  - [limitations & workarounds](./docs/core.md#limitations--workarounds)

### Mixins

- [what are mixins?](./docs/core.md#mixins)
  - [how to use mixins](./docs/core.md#how-to-use-mixins)
  - [how to document mixins](./docs/core.md#how-to-document-mixins)

### Additional Setup Logic

- [extension setup](./docs/core.md#extension-setup)
  - [force a class to load](./docs/core.md#force-a-class-to-load)
  - [conditional extensions](./docs/core.md#conditional-extensions)
  - [removing unsupported properties](./docs/core.md#removing-unsupported-properties)
    - [AHK version requirements](./docs/core.md#ahk-version-requirements)
    - [dependancy over other classes](./docs/core.md#dependancy-over-other-classes)
    - [standalone features](./docs/core.md#standalone-features)
  - [inlining properties](./docs/core.md#inlining-properties)
    - [properties eligible for inlining](./docs/core.md#properties-eligible-for-inlining)
    - [where to put inlined properties](./docs/core.md#where-to-put-inlined-properties)
    - [how to document inlined properties](./docs/core.md#how-to-document-inlined-properties)

## AquaHotkeyX

For a complete reference, see [API Overview](./docs/api-overview.md).

- Overview:
  - [AquaHotkeyX API Overview](./docs/api-overview.md)

- General concepts:
  - [duck types](./docs/base/DuckTypes.md)
  - [natural order](./docs/base/Comparable.md)
  - [object equality](./docs/base/Eq.md)
  - [universal `.ToString()` method](./docs/Base/ToString.md)

- Collections:
  - [Overview](./docs/Collections/overview.md)
  - [Sets](./docs/Collections/Set.md)
  - [Generic Collections](./docs/Collections/Generic/overview.md)

  - Immutable collections:
    - [ImmutableArray](./docs/Collections/ImmutableArray.md)
    - [ImmutableMap](./docs/Collections/ImmutableMap.md)
    - [ImmutableSet](./docs/Collections/ImmutableSet.md)
  
  <!-- TODO map entries -->

  - Ordered collections:
    - [OrderedMap](./docs/Collections/OrderedMap.md)
    - [OrderedSet](./docs/Collections/OrderedSet.md)
  
  - Sorted collections:
    - [SkipListMap](./docs/Collections/SkipListMap.md)
    - [SkipListSet](./docs/Collections/SkipListSet.md)
  
  - Weak Reference collections:
    - [WeakRefMap](./docs/Collections/WeakRefMap.md)
    - [WeakRefSet](./docs/Collections/WeakRefSet.md)

- Function Types:
  - [Comparators](./docs/Func/Comparator.md)
  - [Predicates](./docs/Func/Predicate.md)

- Mixins
  - [Enumerable1](./docs/Interfaces/Enumerable1.md)
  - [Enumerable2](./docs/Interfaces/Enumerable2.md)

- Abstract class & Specifications
  - [IArray](./docs/Interfaces/IArray.md)
  - [IMap](./docs/Interfaces/IMap.md)
  - [ISet](./docs/Interfaces/ISet.md)

- Serialization
  - [binary graph serialization](./docs/IO/Serializer.md)
  <!-- TODO - JSON bindings -->

- Monads
  - [Optional (null handling)](./docs/Monads/Optional.md)
  - [TryOp (error handling)](./docs/Monads/TryOp.md)

<!-- TODO parsing -->

- Sequences ("streams")
  - [Stream](./docs/Stream/Stream.md)
  - [DoubleStream](./docs/Stream/DoubleStream.md)
  <!-- TODO join operations -->

- String utils
  - [String](./docs/String/String.md)
  - [Formatting](./docs/String/Formatting.md)
  - [Matching](./docs/String/Matching.md)
  - [Substrings](./docs/String/Substrings.md)

- Misc.
  - [COM Framework](./docs/System/COM.md)
  - [DLL Loader](./docs/System/DLL.md)
