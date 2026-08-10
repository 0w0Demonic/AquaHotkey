# AquaHotkey - Basics

- [AquaHotkey - Basics](#aquahotkey---basics)
  - [About](#about)
  - [Install](#install)
  - [What is Class Prototyping?](#what-is-class-prototyping)
    - [How to Use it to Your Advantage](#how-to-use-it-to-your-advantage)
  - [Class Hierarchy](#class-hierarchy)
  - [The Extension Class](#the-extension-class)
    - [One Feature, One Class](#one-feature-one-class)
    - [Nested classes](#nested-classes)
  - [Extending Functions](#extending-functions)
    - [Overriding Functions](#overriding-functions)
  - [Ignored Classes](#ignored-classes)
  - [Debug Messages](#debug-messages)
  - [Variable Declarations](#variable-declarations)
    - [What are Variable Declarations?](#what-are-variable-declarations)
    - [Use in Extension Classes](#use-in-extension-classes)
    - [Array and Object Literals](#array-and-object-literals)
    - [Static Declarations](#static-declarations)
    - [Multiple Declarations](#multiple-declarations)
    - [On Primitive Classes](#on-primitive-classes)
  - [Backup Classes](#backup-classes)
    - [Create Classes](#create-classes)
      - [Known Issues](#known-issues)
  - [Override Classes](#override-classes)
    - [Override rules](#override-rules)
    - [Multiple overrides](#multiple-overrides)
    - [Recommended use](#recommended-use)
  - [Mixins](#mixins)
    - [Documentation of Mixins](#documentation-of-mixins)
  - [Extension Setup](#extension-setup)
    - [Force a Class to Load](#force-a-class-to-load)
    - [Conditional extensions](#conditional-extensions)
    - [Removing unsupported properties](#removing-unsupported-properties)
      - [AHK Version Requirements](#ahk-version-requirements)
      - [Dependancy Over Other Classes](#dependancy-over-other-classes)
      - [Standalone Features](#standalone-features)
    - [Inlining properties](#inlining-properties)

## About

If you're interested in some of AquaHotkey's design choices and history, check out [About AquaHotkey](../rambling/00_about.md).

## Install

Follow [this guide](./installation.md) to install and include the library in your script.

## What is Class Prototyping?

(also see [Wikipedia: Prototype-based programming](https://en.wikipedia.org/wiki/Prototype-based_programming))

AutoHotkey is a *prototype-based language*, much like JavaScript. In this language, we reuse data and behavior by letting many objects *inherit from* a common *prototype*.

"Prototype" might be a little misleading, because in AutoHotkey this is more commonly known as a *base object*.

A "banana" object would inherit from a "fruit" object that acts as prototype and represents properties and functionality of fruit in general.

When you create an array in AHK, it first inherits from the *Array Prototype* that defines behavior for all arrays in general. The Array Prototype then inherits from the *Object Prototype* that defines behavior for all object. Finally, the Object Prototype inherits from *Any Prototype*, which is the base for all values in AHK.

You can find these prototype objects in `<SomeClass>.Prototype`, for example `Object.Prototype`.

Structurally, our new array looks something like this:

```ahk
[1, 2, 3]
`- Array.Prototype
   `- Object.Prototype
      `- Any.Prototype
```

### How to Use it to Your Advantage

The interesting part is that, if you want to change the behavior of an array, you only need to change its prototype:

```ahk
(Array.Prototype).DefineProp("ForEach", { Call: Array_ForEach })

Array_ForEach(this, Action, Args*) {
    GetMethod(Action)
    for Value in this {
        Action(Value?, Args*)
    }
}
```

Now, every array inherits this method. You can call this new method like this:

```ahk
[1, 2, 3, 4, 5].ForEach(MsgBox)
; ==> 1, 2, 3, 4, 5
```

## Class Hierarchy

```txt
Any
`- AquaHotkey_Ignore
   |- AquaHotkey
   |- AquaHotkey_Override
   |- AquaHotkey_Backup
   `- AquaHotkey_MultiApply
```

- AquaHotkey_Ignore: [Ignored Class](#ignored-classes) (base class of core AquaHotkey classes, marks helper and utility classes)
- AquaHotkey: [Extension Classes](#the-extension-class) (add more properties)
- AquaHotkey_Override: [Override Classes](#override-classes) (override existing properties)
- AquaHotkey_Backup: [Backup Classes](#backup-classes) (create a snapshot of a class's current state)
- AquaHotkey_MultiApply: [Mixins](#mixins) (apply the same extension to multiple classes)

## The Extension Class

The main focus of AquaHotkey is all about changing these prototype objects to add own behavior. Focus only on the code and class structure, while the extension framework handles the rest.

First, start with an *extension class*. An extension class is a class that `extends AquaHotkey`.

Give it a clear, descriptive name. Don't be afraid to make it overly verbose:

```ahk
class Array_ForEach extends AquaHotkey {
}
```

Now, create *extensions*, which are the nested classes that an extension class encloses. The name of the extension should be the same as the targeted class. For example, if you want to extend `Array`, the name of the extension should be `Array`.

```ahk
class Array_ForEach extends AquaHotkey {
    class Array {
    }
}
```

Finally, declare properties and methods in the extension to extend the targeted class.

```ahk
class Array_ForEach extends AquaHotkey {
    class Array {
        ForEach(Action, Args*) {
            GetMethod(Action)
            for Value in this { ; <-- `this` is an array
                Action(Value?, Args*)
            }
        }
    }
}

[1, 2, 3, 4, 5].ForEach(MsgBox)
; ==> 1, 2, 3, 4, 5
```

Note that `.ForEach()` was declared as non-static, which means it's added to the array prototype. To add things to the `Array` class, use a static property:

```ahk
...
static WithCaseSense(CS) {
    Arr := this()
    Arr.CaseSense := CS
    return Arr
}
...

Arr := Array.WithCaseSense(false)
```

### One Feature, One Class

At first, this structure might seem a little unnecessary. After all, why do we need the nested class structure?

The reason is that an extension class represents *one feature*, where changes can span across multiple classes. An extension class should add only one functionality to reduce clutter.

```ahk
class ToString extends AquaHotkey {
    class Array  { ToString() { ... } }
    class Object { ToString() { ... } }
    class Map    { ToString() { ... } }
    ...
}
```

Extension classes like [Base/DuckTypes](./base/DuckTypes.md) span across many hundreds of lines of code and across almost all built-in types. With this structure, AquaHotkey reliably knows where to put the same property into multiple different targets.

You can save an extension class into a separate file. This lets you reuse them across multiple scripts.

```ahk
#Include <ToString>
```

Want to know whether an extension class is included in your script? Just use `IsSet()`:

```ahk
if (IsSet(ToString)) {
    MsgBox(Obj.ToString())
} else {
    MsgBox(Type(Obj))
}
```

### Nested classes

To apply extensions to a nested class of a target, simply reflect that structure in the extension class.

The following examples shows you how to extend `Gui.Button`:

```ahk
class GuiButton extends AquaHotkey {
    class Gui {
        class Button {
            Click() {
                static BM_CLICK := 0x00F5
                SendMessage(BM_CLICK, 0, 0, this) ; BM_CLICK
            }
        }
    }
}
```

If an extension contains a nested class, AquaHotkey checks if the target already contains a class with the same name.

If the target contains the nested class, AquaHotkey recursively applies the nested class in the extension to the nested class in the target.

If the target does not contain the class, AquaHotkey moves the nested class into the target.

For example:

```ahk
class AquaHotkey_Gui_IPv4 extends AquaHotkey {
    AddIPv4(Opt?) {
        Ctl := this.AddCustom(...)
        ObjSetBase(Ctl, Gui.IPv4.Prototype)
        return Ctl
    }

    class IPv4 extends Gui.Custom {
        ; (...)
    }
}
```

If `Gui.IPv4` does not exist, AquaHotkey creates a completely new `IPv4` class
at runtime. (See [known issues](#known-issues))

See [GuiIPv4.ahk](../examples/GuiIPv4.ahk) for the complete example script.

## Extending Functions

The same logic of extension classes applies to global functions:

```ahk
class MsgBoxUtil extends AquaHotkey {
    class MsgBox {
        static Info => 0x40
        static Info(Text?, Title?) => this(Text?, Title?, this.Info)
    }
}

MsgBox.Info("info: [...]", "(Title text)")
```

If an extension class targets a function, you should use only `static` properties.

### Overriding Functions

To override the function itself, assign a `static Call()` method.

Use `Func.Prototype.Call` to call the previous implemention.

```ahk
class FileOpen_DefaultRead extends AquaHotkey {
    class FileOpen {
        static Call(FileName, Flags := "r", Encoding?) {
            static Prev := Func.Prototype.Call
            Prev(this, FileName, Flags, Encoding?)
        }
    }
}
```

**Use with caution.** When possible, define a static helper method instead (see
`MsgBoxUtil` example above).

## Ignored Classes

Extend your class with `AquaHotkey_Ignore` to mark helper or internal-use classes that should be ignored by AquaHotkey. This is useful for large projects. AquaHotkey ignores any class that derives from `AquaHotkey`, or any class with `AquaHotkey_` prefix.

```ahk
class LargeProject extends AquaHotkey {
    class Utils extends AquaHotkey_Ignore {
        ; ignored during property injection
    }

    ...
}
```

## Debug Messages

If anything decides to break badly, you can always look at the debugger messages. They contain information about all of the extension classes and their targets.

For very detailed information, you can activate verbose logging by adding `#Include <AquaHotkey\cfg\VerboseLogging>` to your script.

```ahk
#Include <AquaHotkey\cfg\VerboseLogging>
```

Methods `AquaHotkey_Ignore.Log()` and `AquaHotkey_Ignore.LogVerbose()` produce `OutputDebug()` messages. You can change this behaviour by redefining the method.

In the future, AquaHotkey might provide a small interface for customizing the logging output, such as output to file.

## Variable Declarations

### What are Variable Declarations?

Variable declarations are properties that are assigned to each new instance of a class or class instance.

```ahk
class Example {
    InstanceVar := Expression ; <-- instance variable declaration
    static StaticVar := Expressions ; <-- static variable declaration
}
```

There are two ways to define variable declarations:

1. as `.__Init()` method
2. using "assignment syntax"

```ahk
; 1. __Init() method
__Init() {
    this.InstanceVar := Expression
}

; 2. assignment syntax
InstanceVar := Expression
```

Variable declarations written in assignment syntax are converted to an `.__Init()` method that first calls `super.__Init()`, and then declares the previously defined variables.

Therefore, the following two variable declarations are equivalent:

```ahk
; 1. as an assignment
class Example {
    Prop1 := "str"
    Prop2 := 42
}

; 2. using `.__Init()`
class Example {
    __Init() {
        super.__Init()      ; 1. call to `super.__Init()`
        this.Prop1 := "str" ; 2. assign variables to the object
        this.Prop2 := 42
    }
}
```

When a class loads, it executes `static __Init()` in a similar manner.

```ahk
class Example
{
    ; Executes when AHK loads `Example` class.
    ; Internally, this is a `static __Init()` method.

    static Prop := Value
}
```

### Use in Extension Classes

When AquaHotkey encounters variable declarations on an extension, it composes a new `.__Init()` method for the target prototype. The newly defined `.__Init()` first calls the previous implementation, followed by the variable declaration declared in the extension.

```ahk
class Default extends AquaHotkey {
    class Array {
        Default := "(null)"
    }
}

Arr := Array(1, 2, 3)
MsgBox(Arr.Default) ; ==> "(null)"
```

**Use with caution.**. If possible, you should always override `.__New()` or `static Call()` instead of `.__Init()`.

### Array and Object Literals

When the script initializes object and array literals (i.e. `{ ... }` and `[ ... ]`), it neither calls `.__Init()` nor `.__New()`.

Therefore, the extension has no effect on object and array literals:

```ahk
class Ext extends AquaHotkey {
    class Array {
        Default := "(null)"
    }
    class Object {
        Value := 42
    }
}

; ---- as literals ----
Arr := [1, 2, 3]
Obj := {}

MsgBox(Arr.Default) ; PropertyError! does not have "Default".
MsgBox(Obj.Value)   ; PropertyError! does not have "Value".

; ---- `Array()` and `Object()` ----
Arr := Array()
Obj := Object()

MsgBox(Arr.Default) ; ==> "(null)"
MsgBox(Obj.Value)   ; ==> 42
```

### Static Declarations

When the extension loads, it assigns the static properties declared in the variable declarations. The extension applies these resulting properties to the target, instead of `static __Init()`.

```ahk
class Ext extends AquaHotkey {
    class Example {
        static StaticProperty := 42
    }
}

class Example {
}

MsgBox(Example.StaticProperty) ; 42
```

Therefore, only the resulting properties from static declarations are applied to the target.

Prefer `static __New()` instead of variable declaration to perform extra setup logic for the extension. Also see [Extension Setup](#extension-setup).

### Multiple Declarations

It is **strongly recommended** to declare variable declarations in their "method form", i.e. `__Init() { ... }`. Using normal assignments puts you at risk of infinite recursion.

```ahk
class ObjectExt extends AquaHotkey {
    class Object {
        Foo := "bar" ; Error! infinite recursion.

        __Init() {
            this.Foo := "bar" ; o.k.
        }
    }
}
```

To understand this issue, remember that using the "assignment syntax" creates an `.__Init()` method with implicit call to `super.__Init()`. This causes infinite recursion, because `super.__Init()` is the method itself.

If multiple extensions define variable declarations for the same target class, the order of execution depends on the order in which the extensions applied.

```ahk
class ArrayDefaultEmptyString extends AquaHotkey {
    class Array {
        __Init() {
            MsgBox("setting default...")
            this.Default := ""
        }
    }
}

class ArrayCaseSenseOff extends AquaHotkey {
    class Array {
        __Init() {
            MsgBox("setting case-sense")
            this.CaseSense := "Off"
        }
    }
}

Arr := Array()
; ==> setting default...
; ==> setting case-sense

MsgBox(Arr.Default)   ; ""
MsgBox(Arr.CaseSense) ; "Off"
```

You can change the order of execution by forcing a class to load with `static
__New()`. Also see [Extension Setup](#extension-setup).

### On Primitive Classes

AquaHotkey ignores the variable declaration of any extension that targets a class that does not derive from `Object`. This is because instances of these classes cannot own any properties on their on.

As of AHK v2.0, the following classes cannot declare variable declarations:

- Primitive
  - Number
    - Float
    - Integer
  - String
- VarRef
- ComValue
  - ComObjArray
  - ComObject
  - ComValueRef

This also includes any class which derives from the list above, or any class that directly `extends Any`.

You can use the following code snippet to determine whether a target can have custom variable declarations:

```ahk
CanOverride__Init(Cls) => (Cls == Object) || HasBase(Cls, Object)
```

## Backup Classes

Extension classes overwrite properties *destructively*.

Backup classes create snapshots of classes so that their original properties could be accessed later. For this purpose, AquaHotkey offers a `.Backup()` method for classes. The following example saves the current state of `Gui` in `Gui_Backup`:

```ahk
class Gui_Backup {
    static __New() => this.Backup(Gui)
}

; alternatively:
class Gui_Backup extends AquaHotkey_Backup {
    static __New() => super.__New(Gui)
}
```

You can also use `AquaHotkey_Backup.Of(Cls)` to create a new class from scratch:

```ahk
OldGui := AquaHotkey_Backup.Of(Gui)
```

### Create Classes

AquaHotkey creates entire copies of classes, if it has to assign a new nested class to a target, or when using `AquaHotkey_Backup.Of(Cls)`.

For this purpose, AquaHotkey defines a method `AquaHotkey.CreateClass()`. It accepts the base class as first argument, followed by a class name and optional arguments which are passed to the `static __New()` function of the class, if applicable.

#### Known Issues

If you are using an AHK version below v2.1-alpha.3, this class is unable to create prototype objects which are based on native types other than Object.

Because of this, it might be unable to do the following:

1. **Copy a new nested class into a target**:

```ahk
class Ext extends AquaHotkey {
    class A {
        class B extends Array {
        }
    }
}

; found class A...
; A does not have nested class B ...
; create new nested class A.B ...
; set base of A.B to Array
; set base of A.B.Prototype to Array.Prototype
;   Error! Type mismatch. 
```

As workaround, you can *move* the class instead of creating a copy of it:

```ahk
DefineProp(A, "B", NestedClassProp(Ext.A.B)) ; o.k.
DeleteProp(A, "B") ; delete from extension class, if appropriate
```

2. **Using `AquaHotkey_Backup.Of(Cls)`**:

```ahk
class CustomArray extends Array {
}

ArrClass := AquaHotkey_Backup.Of(CustomArray)
; creating new class <Cls>...
; set base of <Cls> to Array ...
; set base of <Cls.Prototype> to Array.Prototype ...
;   Error! Type mismatch.
```

Workaround: use `.Backup()`, which doesn't overwrite the base class.

```ahk
class CustomArray_Backup {
    static __New() => this.Backup(CustomArray)
}
```

## Override Classes

An override class changes the implementation of an existing property or method.

An override class has the same structure as an extension class. It inherits from `AquaHotkey_Override` instead of `AquaHotkey`.

```ahk
class Monitor_Array_Length extends AquaHotkey_Override {
    class Array {
        Length[__super__] {
            get {
                MsgBox("getting array length...")
                return __super__(this)
            }

            set {
                MsgBox("setting array length...")
                return __super__(this, Value)
            }
        }

        Push(__super__, Args*) {
            MsgBox("pushing values...")
            return __super__(this, Args*)
        }
    }
}
```

The first parameter of an override property or method is the previous implementation `__super__()`.
The first argument of `__super__()` is always the class or class instance which called the property.

The override can call this implementation to preserve the original behavior.

This displays a message and then calls the original `.Push()` implementation.

For example:

```ahk
Push(__super__, Args*) {
    MsgBox("pushing values...")
    return __super__(this, Args*)
}
```

The previous workflow involved saving the previous implementation of properties in a backup class to override an extension property. Override classes provide the previous implementation directly through `__super__()`. The use of backup classes for overriding existing properties is therefore deprecated.

### Override rules

An override must satisfy the following rules:

- The target must already contain the overridden property.
- The overridden property must be dynamic.
- Static and regular fields (`value` properties) cannot be overridden.
- If the override defines a `get`, the target must define a `get`.
- If the override defines a `set`, the target must define a `set`.
- If the override defines a `call`, the target must define a `call`.
- An override cannot replace a nested class with a regular property.
- An override cannot replace a regular property with a nested class.
- If both classes contain a nested class with the same name, AquaHotkey recursively applies the override to that class.

The following structure is therefore valid:

```ahk
class Override extends AquaHotkey_Override {
    class Array {
        Length[__super__] {
            get {
                ; (do something)

                ; (call previous implementation)
                return __super__(this)
            }
        }
    }
}
```

The target (`Array.Prototype`) must contain a dynamic `Length` property with a `get` implementation.

### Multiple overrides

Multiple override classes can override the same property.

AquaHotkey applies the overrides in the order in which the override classes are loaded.

For example, if `OverrideA` loads before `OverrideB`, the call chain is:

1. OverrideB
2. OverrideA
3. Original implementation

You can force an override class to load before the current class by referencing it in `static __New()`.

```ahk
class Test extends AquaHotkey_Override {
    static __New() {
        (OtherClass)  ; <-- force class to load
        super.__New() ; <-- apply override class
    }

    ; ...
}
```

The reference causes `OtherClass` to load if it has not already loaded.

### Recommended use

Overrides are most useful for debugging, instrumentation, and similar tasks.

Use override classes with care. For normal application logic, prefer an extension, a wrapper, or another explicit solution when possible.

## Mixins

Mixin classes apply the same extension to multiple targets. This is useful for defining behavior for multiple classes based on their overall behavior instead of their inheritance.

Mixin classes do not have the same nested class structure as extension or override classes. Instead, properties are defined in the mixin class itself.

Contrary to extension or override classes, mixin classes **cannot overwrite** existing properties. Therefore, mixin classes are ideal for implementing default properties and methods, if they're not yet defined.

Use `Mixin.Extend(Cls)` or `Cls.Include(Mixin)` to apply a mixin class to a target. You should do this inside `static __New()`:

```ahk
; anything that is enumerable with arg-size 1 (`for Value in Obj`)
class Enumerable1
{
    static __New() => this.Extend(Array, Map, ...)

    ForEach(Action, Args*) {
        GetMethod(Action)
        for Value in this {
            Action(Value?, Args*)
        }
    }
}

; anything with `Name` property
class IHasName
{
    SayHi() {
        MsgBox("Hi! My name is " . this.Name)
    }
}

class Person
{
    static __New() => this.Include(IHasName)

    __New(Name) {
        this.Name := Name
    }
}
```

Alternatively, you can create a class that `extends AquaHotkey_MultiApply` and pass the targets in `super.__New()`:

```ahk
class Enumerable1 extends AquaHotkey_MultiApply {
    static __New() => super.__New(Array, Map, ...)

    ForEach(...) { ... }
}
```

You should always use `.Extend()` and `.Include()` instead of `AquaHotkey_MultiApply` directly. Always use `.Include()` over `.Extend()`, if possible.

### Documentation of Mixins

You **should** denote mixin classes with a prefix such as `M` for *mixin* or `I` for *interface*. For example, `IEnumerable1` or `MHasName`.

When using the Visual Studio Code AHK v2 LSP, you should add a `@mixin` tag to the class doc.

Use `@implements {MixinClass}` to denote that a class includes a mixin class. Use `@extends {TargetClass}` to denote that a mixin class actively adds behavior to a target class.

```ahk
/**
 * Blah blah blah.
 * @mixin
 * @extends {Array}
 * @extends {Map}
 */
class IEnumerable1 {
    static __New() => this.Extend(Array, Map)
}

/**
 * Blah blah blah.
 * @mixin
 */
class IHasName {
    ; ...
}

/**
 * Blah blah blah.
 * @includes {IHasName}
 */
class User {
    static __New() => this.Include(IHasName)
}
```

## Extension Setup

An extension class can define a `static __New()` method.

AquaHotkey does not apply `static __New()` to the target class. Instead, AquaHotkey uses it as setup logic for the extension.

You can also define `static __New()` in the extensions themselves. AquaHotkey does not apply these methods to the corresponding target classes.

Use `static __New()` when the extension needs to perform additional setup before it is applied.

### Force a Class to Load

When using [override classes](#override-classes) or [custom variable declarations](#variable-declarations), the order in which classes load determines how properties behave. When it's necessary that another class has already loaded, you can force it to load by referencing it in `static __New()`:

```ahk
...
static __New() {
    (Dependancy)  ; force `Dependancy` to load
    super.__New() ; apply the extension or override class
}
```

### Conditional extensions

An extension can check if another extension or configuration class is available.

If another extension is required for the feature to work, include that extension directly:

```ahk
#Include <RequiredExtension>

class Ext extends AquaHotkey {
    ; ...
}
```

If the dependency is optional, or if the extension can work without it, you can check for it before applying the extension:

```ahk
class Ext extends AquaHotkey {
    static __New() {
        if IsSet(Dependency) {
            super.__New()
        }
    }

    ; ...
}
```

If `Dependency` is not defined, `super.__New()` is not called and AquaHotkey does not apply the extension.

You can use the following shorthand:

```ahk
static __New() => IsSet(Dependency) && super.__New()
```

### Removing unsupported properties

An extension can remove individual properties when a dependency or AutoHotkey version is not available.

#### AHK Version Requirements

Use `RequiresVersion()` to remove properties that require a specific AutoHotkey version.

```ahk
static __New() {
    this.RequiresVersion(
        "v2.1-alpha.3",
        "Any.Prototype.Prop",
        "String.Method"
    )

    super.__New()
}
```

`RequiresVersion()` takes a version requirement and one or more property paths.

The version uses the format accepted by `VerCompare()`. You can add a comparison operator before the version. The default operator is `>=`.

For example:

```ahk
this.RequiresVersion("v2.1-alpha.3", ...)
this.RequiresVersion(">=v2.1-alpha.3", ...)
this.RequiresVersion("<v2.2", ...)
```

#### Dependancy Over Other Classes

Use `Requires()` to remove properties when another class is not available.

```ahk
static __New() {
    this.Requires(Dependency?, "Any.Prototype.Example")
    super.__New()
}
```

`Requires()` takes an optional class and one or more property paths.

The class argument can contain an existing variable or `unset`. Add `?` to the variable name when the variable may be `unset`:

```ahk
this.Requires(Dependency?, ...)
```

If `Dependency` is not defined, `Dependency?` evaluates as `unset` instead of causing an error.

A property path is a dot-separated list of property names:

```ahk
class Ext extends AquaHotkey {
    class Any {
        Example() { ... } ; <-- Any.Prototype.Example
    }
    class String {
        static Method() { ... } ; <-- String.Method
    }
}
```

Do not include whitespace in a property path.

#### Standalone Features

Only apply an extension class, if AquaHotkey is imported in the script.

```ahk
; Does not have `AquaHotkey` as base class, it might not be present
; in the script.
class Ext {
    ; if AquaHotkey is present in the script, apply as extension
    static __New() {
        if ((AquaHotkey ?? "") is Class) {
            ObjSetBase(this, AquaHotkey)
            (AquaHotkey.__New)(this)
        }
    }

    ...
}
```

### Inlining properties

An extension can define a property or method that forwards directly to another function.

For example:

```ahk
class Ext extends AquaHotkey {
    class String {
        Length => StrLen(this)
    }
}
```

The `Length` property only forwards `this` to `StrLen()`.

You can replace the forwarding property with the function itself:

```ahk
...
static __New() {
    (this.Prototype).DefineProp("Length", { Get: StrLen })
}
...
```

You should only do this if you feel already comfortable with class prototyping.

Use this form when the property or method forwards all arguments to a function without changing them.

The arguments must:

- have the same order
- have the same values
- have the same number of arguments
- have no additional default values

The function becomes the property value directly. This removes one additional function call.

Define the property in the extension class, not in the target class.

This is important because AquaHotkey can decide not to apply the extension during `static __New()`. The target class must not be modified before that decision is made.

If you use the Visual Studio Code LSP for AHK v2, you **should** always document an inlined property with the `@inlined` tag:

A complete example:

```ahk
/* Additional utilities for String. Blah blah blah. */
class StringLength extends AquaHotkey {
    class String {
        static __New() => DefineGetter(this.Prototype, "Length", StrLen)

        /**
         * Character count of the string.
         * 
         * @inlined
         * @readonly
         * @type {Integer}
         */
        Length => StrLen(this)
    }
}
```

When inlining properties, you are doing class prototyping manually. Be sure to check your implementation thoroughly. This procedure is only recommended if:

1. You want to extend `String` and are dealing with large strings.
2. You are very concerned about performance.

For this purpose, it is recommended that you use the helper functions defined in `<Core/Utils>`.

For more help, see extension classes like [Base/Object.ahk](../src/Base/Object.ahk) and [String/Formatting.ahk](../src/String/Formatting.ahk).
