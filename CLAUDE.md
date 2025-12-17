# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AquaHotkey is a class prototyping library for AutoHotkey v2 that enables adding custom methods and properties to built-in types (`Array`, `String`, `Map`, etc.) at runtime. It works by copying member definitions from user-defined "extension classes" into existing class prototypes.

**Two main components:**
- **AquaHotkey** (`AquaHotkey.ahk`) - Core framework for defining class extensions
- **AquaHotkeyX** (`AquaHotkeyX.ahk`) - Batteries-included standard library with functional programming patterns (streams, optionals, collectors, etc.)

## Running Scripts

```bash
# Windows
AutoHotkey64.exe script.ahk

# WSL
"/mnt/c/Program Files/AutoHotkey/v2/AutoHotkey64.exe" /ErrorStdOut script.ahk
```

## Architecture

### Core Classes (`src/Core/`)

- **`AquaHotkey`** - Base class for defining extensions. Nested classes matching built-in type names (e.g., `class String`) inject their members into those types.
- **`AquaHotkey_Backup`** - Creates frozen snapshots of classes before modification, enabling safe overrides of existing methods.
- **`AquaHotkey_MultiApply`** - Applies the same members to multiple unrelated classes (useful for mixins/GUI controls).
- **`AquaHotkey_Ignore`** - Marker base class to exclude nested helper classes from prototyping.
- **`AquaHotkey_Mixin`** - Mixin support.

### Extension Pattern

```ahk
class MyExtensions extends AquaHotkey {
    class String {
        ; Instance method - added to String.Prototype
        FirstChar() => SubStr(this, 1, 1)
    }
    class MsgBox {
        ; Static method - added to the function object
        static Info(Text?) => this(Text?, , 0x40)
    }
}
```

The `static __New()` method in AquaHotkey iterates nested classes, resolves their targets by name, and transfers property descriptors.

### AquaHotkeyX Standard Library

Organized in `src/Builtins/` (type extensions) and `src/Extensions/` (new types):

**Builtins:** `Any`, `Array`, `Buffer`, `Class`, `ComValue`, `Error`, `Func`, `Integer`, `Map`, `Number`, `Object`, `Primitive`, `String`, `VarRef`, plus specialized modules (`Pipes`, `Assertions`, `ToString`, `StringMatching`, `Substrings`, `FileUtils`, `StreamOps`)

**Extensions:** `Optional`, `TryOp`, `Range`, `Stream`, `Collector`, `Gatherer`, `Condition`, `Mapper`, `Combiner`, `Comparator`, `Zip`

### Tests (`tests/`)

Tests are `.ahk` files structured as classes with static methods. Each method is a test case using assertion methods like `.AssertEquals()`, `.AssertType()`, and `TestSuite.AssertThrows()`.

```ahk
class Array {
    static Sum() {
        Array(1, 2, 3, 4, unset).Sum().AssertEquals(10)
    }
}
```

## Key Conventions

### Extension Class Naming
- Nested class names must exactly match target types (case-sensitive)
- `class String` extends `String`, `class Gui { class Button }` extends `Gui.Button`

### Extending Functions
Use `static` members when extending global functions since they don't have instances.

### Field Declarations
Avoid direct field declarations (`Foo := "bar"`) except for simple defaults. Prefer `__Init()` methods. For `Object`/`Any`, you MUST use `__Init()` to avoid infinite recursion.

### Backup Pattern (for overriding existing members)
```ahk
class OldGui extends AquaHotkey_Backup {
    static __New() => super.__New(Gui)
}

class GuiExtensions extends AquaHotkey {
    static __New() {
        (OldGui)      ; Force backup to load first
        super.__New()
    }
    class Gui { ... }
}
```

## Contributing

- Extensions, documentation, examples, and tests are welcome
- Do NOT modify core files in `src/Core/` - open an issue instead
- Add tests for new utility methods
