# TypeInfo

Universal properties that are related to type information, for example the
type and defining class of a value.

```ahk

;---- Type of Value ----

"".Type ; "String"

;---- Defining Class ----

"".Class ; String (class)

;---- Hierarchy (chain of base objects, including itself) ----

123.Hierarchy [123, Integer.Prototype, Number.Prototype, ...]

;---- Bases (chain of base objects) ----

Array().Bases ; [Array.Prototype, Object.Prototype, Any.Prototype]
Buffer.Bases  ; [Object, Any, Class.Prototype, Object.Prototype, Any.Prototype]

;---- Find a class by its name

Class.ForName("Gui.ActiveX") ; Gui.ActiveX (class)

```
