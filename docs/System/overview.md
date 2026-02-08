# Module `<System>`

- [All Modules](../api-overview.md)

## List of all Features

- [COM](./COM.md)
- [DLL](./DLL.md)

## COM

- [<System/COM>](./COM.md)

A small framework for creating class-based interfaces to interact with COM
objects.

```ahk
class InternetExplorer extends COM {
    static CLSID => "InternetExplorer.Application"

    __New(URL) {
        this.Visible := true
        this.Navigate(URL)
    }

    class EventSink extends COM.EventSink {
        DocumentComplete(pDisp, &URL) {
            MsgBox("document completed:" . URL)
            this.Quit()
        }
    }
}
```

## DLL

- [<System/DLL>](DLL.md)

A tool for loading DLL and calling DLL functions with typed bindings.

```ahk
class User32 extends COM {
    static FilePath => "user32.dll"

    static TypeSignature => {
        MessageBox: ["Ptr", "Str", "Str", "UInt", "Int"]
    }
}
```
