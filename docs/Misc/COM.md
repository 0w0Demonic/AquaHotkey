# COM

## Overview

`COM` is a user-friendly framework to wrap COM objects into class-based
interfaces.

The main idea behind `COM` is to *extend the class* and to define a few options
in the form of static members.

### `(required) static CLSID => String`

CLSID or Prog ID of the COM object.

### `(optional) static IID => String`

IID of the interface (default IID_IDispatch).

### `(optional) static MethodSignatures => Object`

An object that contains type signatures for `ComCall()`-methods.

### `(optional) static EventSink => Class`

A nested class that handles events thrown by the COM object.

Alternatively, a static property `static EventSink => Class` can point to an
event sink class somewhere else in the script.

Instead of the event sink, the `this`-keyword used in methods of the event sink
refer to the instance of `COM` that raised the event.

Due to this change, methods of the event sink no longer accept the original COM
object as last parameter.

### `(optional) static ReturnTypes => Object`

An object that maps method or property names to their corresponding COM wrapper
class. This can be used to automaticaly wrap returned COM objects to the given
type.

## Example

```ahk
class InternetExplorer extends COM {
    static CLSID => "InternetExplorer.Application"
    ; static IID => "..."

    __New(URL) {
        this.Visible := true
        this.Navigate(URL)
    }

    static MethodSignatures => {
        ; DoSomething(Arg1, Arg2) {
        ;     return ComCall(6, this, "Int", Arg1, "UInt", Arg2)
        ; }
        DoSomething: [6, "Int", "UInt"]
    }
    
    class EventSink extends ComEventSink
    {
        ; see AHK docs on `ComObjConnect()`:
        ; the last parameter `ieFinalParam` is omitted
        DocumentComplete(pDisp, &URL)
        {
            MsgBox("document completed: " . URL)
            
            ; `this` refers to the instance of `InternetExplorer`!
            ; in this example: [InternetExplorer].Quit()
            this.Quit()
        }
    }
}

ie := InternetExplorer("https://www.autohotkey.com") ; create a new COM object
ie.DoSomething(34, 9)                                ; predefined `ComCall()`
ie(6, "Ptr", 0, "Ptr")                               ; undefined `ComCall()`
```

## AbstractCom Class

`AbstractCom` is used as a marker class to mark classes that should wrap around
COM objects, but have no CLSID and are generally returned by other COM objects
(for example Word.Documents, which is returned by Word.Application).

Use `static ReturnTypes` to specify the return types of properties owned by the
COM object.

### Example

```ahk
class Word extends Com {
    static CLSID => "Word.Application"
    static ReturnTypes => { Documents: Word.Documents }

    class Documents extends AbstractCom {
        
    }
}
Wd := Word()
Docs := Wd.Documents
MsgBox(Type(Docs)) ; "Word.Documents"

MsgBox(Docs is AbstractCom) ; true
MsgBox(Docs is Com)         ; true

Docs.Add()
```
