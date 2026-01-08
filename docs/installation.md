# Installation

To get started, clone this repository and put it in one of the AutoHotkey
[lib folders](https://www.autohotkey.com/docs/v2/Scripts.htm#lib).

```ahk
#Requires AutoHotkey v2
#Include <AquaHotkey>
```

## Advanced Setup

This is optional, but will probably save you lots of work in the long run.
With this setup, both AquaHotkey and anything else that depends on it can
be imported with `<library>` syntax.

```ahk
; convenient library syntax
#Include <AquaHotkey>
#Include <StringUtils>
#Include <ArrayUtils>
```

Setup:

1. Create stub files `AquaHotkey.ahk` and `AquaHotkeyX.ahk` that each contain a
   single `#Include` pointing to the real source inside the repository folder:

    ```ahk
    ; ------------- AquaHotkey.ahk (stub)
    #Include "%A_LineFile%/../AquaHotkey/AquaHotkey.ahk"
    ; -------------
  
    ; ------------- AquaHotkeyX.ahk (stub)
    #Include "%A_LineFile%/../AquaHotkey/AquaHotkeyX.ahk"
    ; -------------
    ```

2. Structure your files like this:

    ```txt
    lib/
    |
    |- AquaHotkey/
    |  |- AquaHotkey.ahk  <-- the actual source (#Include these)
    |  `- AquaHotkeyX.ahk
    |
    |
    |- AquaHotkey.ahk     <-- stub files (see above)
    |- AquaHotkeyX.ahk
    |
    |
    |- StringUtils.ahk    <-- other libs
    `- ArrayUtils.ahk
    ```