<ROLE_INTGRATION>
This module (`Module_AquaHotkey.md`) provides specialized knowledge about the AquaHotkey library, which extends your core capabilities.
</ROLE_INTGRATION>

<MODULE_OVERVIEW>
AquaHotkey is an AutoHotkey v2 library that makes it easy to add custom properties and methods into built-in types, much like extension members in C#.
In addition, it provides a large variety of custom properties and methods for the built-in types, along with functional programming patterns such as streams, function composition, comparators, and optionals.
</MODULE_OVERVIEW>

<DETECTION_SYSTEM>
  <EXPLICIT_TRIGGERS>
  Reference this module when user mentions:
  "AquaHotkey", "extension", "package"
  </EXPLICIT_TRIGGERS>
  <IMPLICIT_TRIGGERS>
  Reference this module when user mentions:

  "write utility for something" → evaluate, if custom properties are appropriate
  </IMPLICIT_TRIGGERS>
</DETECTION_SYSTEM>

<PREAMBLE>
The AquaHotkey library consists of two separate parts:
- A library for defining custom methods and properties declaratively
- An optional standard library, "AquaHotkeyX", that makes use of this new feature, leaning heavily into functional programming techniques
</PREAMBLE>

<INTEGRATION>
  <OVERVIEW>
  This section contains code snippets for integrating AquaHotkey into the script.
  Refer to "AquaHotkeyX" to include the optional standard library. Otherwise, refer to "AquaHotkey".
  </OVERVIEW>
  <FULL_VERSION>

  ```cpp
  #Requires AutoHotkey >=v2.0.5
  #Include <AquaHotkeyX>
  ```

  </FULL_VERSION>
  <MINIMAL_VERSION>

  ```cpp
  #Requires AutoHotkey >=v2.0.5
  #Include <AquaHotkey>
  ```

  </MINIMAL_VERSION>
</INTEGRATION>

<BEST_PRACTICES>
- Consider creating separate files for your extensions. Common utility is extremely reusable and should be offloaded into separate files to be shared across scripts.
- Don't be afraid to give extension classes clear and verbose names. Your extensions are essentially global classes, which may be reused across many other scripts. Giving clear names helps keep the namespace clean.
</BEST_PRACTICES>

<TERMINOLOGY>
Extension Class: A subclass of `AquaHotkey`, used to define custom members
Backup Class: A subclass of `AquaHotkey_Backup` used to create complete snapshots of classes and all of their members
Package: A file containing a single extension class, which can be reused across scripts
Ignored Class: A subclass of `AquaHotkey_Ignore`, a marker class to exclude helper or internal-use classes from AquaHotkey's class prototyping system. This also includes extension classes and backup classes.
</TERMINOLOGY>

<USAGE>
  <OVERVIEW>
  This section contains instructions on how to use the library to define extension members. Most of the time, it involves:
  - Creating a subclass of `AquaHotkey`. It is referred to as "extension class"
  - Declaring a nested class with the same name as the class to be extended
  - Inside the nested class, defining regular properties as if dealing with the actual targeted class
  </OVERVIEW>

  <CONVENTIONS>
  It is highly recommended to comply with the following conventions:

  - Always use static members when extending functions.
  - Avoid field declarations where possible. If you must initialize state, always prefer an `__Init` method instead over direct assignments.
  </CONVENTIONS>

  <BASICS>
    <TUTORIAL>
      Create a subclass of `AquaHotkey`.
      Define a nested class named after the class or function to be extended.
      Inside the nested class, define new members as if it was the actual targeted class
      (i.e.: the `this` keyword always refers to the relevant object that called
      the method / accessed the property).
      Static members are added to the targeted class itself. Instance members are added to the
      class's prototype, i.e.: to its instances.
    <TUTORIAL>
    <CAVEATS>
      Make sure that the name of the nested class matches that of the type to
      be extended, case-sensitive.

      Example:
      - To add utility to the `Number` type, your nested class must be named "Number"
      - For adding string utility, name your nested class "String"
      - Name your class "Object", for members useable for objects.
      - Name your class "Any", for members useable by any type at all.
    </CAVEATS>
    <TECHNICAL_DETAILS>
      Property descriptors, which define how the property of an object behaves
      when accessed, are transferred from the user-defined class to the targeted
      class or function to be extended at runtime.
    </TECHNICAL_DETAILS>
    <ERROR_HANDLING>
    - If an extension definition is malformed, an uncatchable error is thrown during class initialization.
    - Defining already-existing members causes them to be overridden silently. Use backup classes to preserve them. The last loaded class silently wins.
    </ERROR_HANDLING>
    <EXAMPLE>

    ```cpp
    class StringUtil extends AquaHotkey {
        ; nested class that adds a `Replace` method, and `Length` property to strings
        class String {
            Replace(Pattern, Replacement) {
                return StrReplace(this, Pattern, Replacement)
            }

            Length => StrLen(this)
        }
    }

    ; evaluates to "foooo"
    "foo".Replace("o", "oo")

    ; evaluates to 3
    "foo".Length
    ```

    </EXAMPLE>
    <EXAMPLE>

    ```cpp
    class ArrayUtil extends AquaHotkey {
        ; nested class that adds a `ForEach` method to arrays
        class Array {
            ForEach(Action) {
                GetMethod(Action)
                for Value in this {
                    Action(Value?)
                }
                return this
            }
        }
    }

    ; displays 1 through 5
    Array(1, 2, 3, 4, 5).ForEach(MsgBox)
    ```

    </EXAMPLE>
    <EXAMPLE>

    ```cpp
    class MsgBoxUtil extends AquaHotkey {
        ; nested class that adds an `Info` method for `MsgBox`
        class MsgBox {
            static Info(Text?, Title?) {
                return this(Text?, Title?, 0x40)
            }
        }
    }

    ; displays a message box with an info icon
    MsgBox.Info("hello, world!", "Title text")
    ```

    </EXAMPLE>
  </BASICS>
  <ADVANCED>
    <OVERVIEW>
    This section contains advanced patterns, edge cases and caveats.
    </OVERVIEW>

    <NESTED_CLASSES>
      <EXPLANATION>
      Extending nested class works exactly the same. Simply nest one layer deeper.
      </EXPLANATION>
      <EXAMPLE>

      ```cpp
      class ButtonUtil extends AquaHotkey {
          class Gui {
              class Button {
                  ; ...
              }
          }
      }
      ```   

      </EXAMPLE>
    </NESTED_CLASSES>

    <FIELD_DECLARATIONS>
      <EXPLANATION>
        By specifying field declarations (e.g.: `Foo := "bar"`, or an `__Init`
        method), you can control how objects are initialized.
        You should ALWAYS prefer an `__Init` method over regular declarations.
      </EXPLANATION>

      <CAVEATS>
        If multiple classes use field declarations for the same target, each
        is assigned in the order in which the extension classes were loaded.
      </CAVEATS>

      <PERFORMANCE_COSTS>
        Avoid using many field declarations, if any, as their performance cost
        is very high.
      </PERFORMANCE_COSTS>

      <EXAMPLE>

      ```cpp
      class ArrayDefaultValueEmptyString extends AquaHotkey {
          class Array {
              ; automatically assigns this field when an array is created
              __Init() {
                  this.Default := ""
              }
          }
      }
      ```

      </EXAMPLE>
    </FIELD_DECLARATIONS>

    <BACKUPS>
      <EXPLANATION>
        When defining members that already exist in the targeted class, they are **overwritten**.
        To prevent this, use a backup to create a complete snapshot of a class.
        With the exception to functions, overriding these properties without
        using a backup class is unrecoverable.
      </EXPLANATION>

      <ADVANTAGES>
        By preserving the original implementation, you can safely override and retain access to the original properties. It even allows you to provide advanced versions of the old properties through decoration. Using a backup class creates an identical, frozen snapshot of the original.
      </ADVANTAGES>

      <TUTORIAL>
        1. Create a direct subclass of `AquaHotkey_Backup`. It doesn't matter whether the class is top-level, or enclosed in an extension class.
        2. Define a `static __New` method, which calls `super.__New` to specify each class to be saved. ALWAYS prefer saving just ONE per backup class.
      </TUTORIAL>

      <EXAMPLE>

      ```cpp
      ; create a snapshot of the `Gui` class
      class OldGui extends AquaHotkey_Backup {
          static __New() {
              super.__New(Gui)
          }
      }

      ; extension class that replaces the old Gui constructor
      class GuiExtension extends AquaHotkey {
          class Gui {
              static __New() {
                  
              }

              __New(Args*)
          }
      }
      ```

      </EXAMPLE>

      <CAVEATS>
        <ORDER_OF_EXECUTION>
          The backup class must load a backup of the target **before** any extension class modifies it.
          You can achieve this by explicitly loading the backup class from any extension class that depends on it.
          ALWAYS force the appropriate backup class to load, if present.

          Example:

          ```cpp
          class GuiExtensions extends AquaHotkey {
              static __New() {
                  ; force the class to load
                  (OldGui)

                  ; create a backup as usual
                  super.__New(Gui)
              }

              class Gui {
                  ; ...
              }
          }
          ```

        </ORDER_OF_EXECUTION>
        <BACKUP_FUNCTIONS>
        There's no need to use `AquaHotkey_Backup` to tweak the behavior of global functions.
        Refer to the following example instead:

        ```cpp
        class FileOpen_WithDefaultRead extends AquaHotkey {
            class FileOpen {
                static Call(FileName, Flags := "r", Encoding?) {
                    return (Func.Prototype.Call)(this, FileName, Flags, Encoding?)
                }
            }
        }
        ```

        </BACKUP_FUNCTIONS>
      </CAVEATS>
    </BACKUPS>

    <MULTI_APPLY>
      <EXPLANATION>
        Creating direct subclasses of `AquaHotkey_MultiApply` creates a special
        type of extension class which adds all of its members to multiple unrelated
        classes, instead of only one. Conceptually, it works similar to a mixin.
        Most of the time, this is only useful for GUI controls.
      </EXPLANATION>

      <TUTORIAL>
        3. Create a direct subclass of `AquaHotkey_MultiApply`. It doesn't matter whether the class is top-level, or enclosed in an extension class.
        4. Define a `static __New` method, which calls `super.__New` to specify each class to be targeted.
      </TUTORIAL>

      <ANTI_PATTERNS>
        Only use this class if you need to override **multiple** classes with
        the same code. Otherwise, use a regular extension class.
      </ANTI_PATTERNS>
    </MULTI_APPLY>
    <IGNORED_CLASSES>
      <EXPLANATION>
        Any class that extends from `AquaHotkey_Ignore` - that includes any extension
        or backup class - is ignored by its enclosing extension class, including all
        of its subclasses and nested classes.
        Use it as to exclude helper or internal-use classes.
      </EXPLANATION>

      <EXAMPLE>

      ```cpp
      class LargeProject extends AquaHotkey {
          ; extending `AquaHotkey_Ignore` causes this class to be ignored.
          ; this is useful for helper or internal-use classes in large projects.
          class Util extends AquaHotkey_Ignore {

          }
      }
      ```

      </EXAMPLE>
    <IGNORED_CLASSES>

    <CONDITIONAL_IMPORTS>
      <EXPLANATION>
        The presence of extension classes can be checked by using `IsSet(ExtensionClass)`.
        This is usually done inside the body of a `static __New` method, i.e.: when the class loads.
      </EXPLANATION>

      <ADVANTAGES>
        Conditional imports are extremely helpful for making extensions
        depend on other extensions, and another reason why extension classes
        should be assigned clear and verbose names. If a dependency is absent,
        you can either:
        
        - throw an error
        - fall back to a limited set of extensions (i.e., by removing certain methods or nested classes before calling `super.__New`)
        - prevent the extension to load by not calling `super.__New`, optionally displaying a message box or debug output
      </ADVANTAGES>

      <EXAMPLE>
        
      ```cpp
      class StreamExtensions extends AquaHotkey {
          static __New() {
              ; check whether a dependency is present in the script.
              if (IsSet(AquaHotkey_Stream) && HasBase(AquaHotkey_Stream, AquaHotkey)) {
                  ; success
                  return super.__New()
              }

              ; otherwise, abort
              MsgBox("
              (
              StreamExtensions.Stream unavailable - Stream.ahk is missing.

              #Include .../Stream.ahk
              )", "StreamExtensions.ahk", 0x40)
          }

          class Stream {
              ; ...
          }
      }
      ```

      <EXAMPLE>
    </CONDITIONAL_IMPORTS>
  </ADVANCED>
</USAGE>
