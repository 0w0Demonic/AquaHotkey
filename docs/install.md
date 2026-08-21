# Installation

- [Installation](#installation)
  - [Version Requirements](#version-requirements)
  - [Download](#download)
    - [GitHub](#github)
    - [Aris](#aris)
  - [Import](#import)
    - [Custom](#custom)
  - [Advanced Setup](#advanced-setup)

## Version Requirements

Any version of AutoHotkey v2 is fine. However, be aware that some advanced features may not work properly on versions below v2.1-alpha.3.

See: [Known Issues](./core.md#known-issues)

## Download

### GitHub

Clone this repository into one of the AutoHotkey [lib folders](https://www.autohotkey.com/docs/v2/Scripts.htm#lib):

```batch
git clone https://www.github.com/0w0Demonic/AquaHotkey "%USERPROFILE%\Documents\AutoHotkey\lib\AquaHotkey"
```

### Aris

If you use the [Aris Package Manager](https://github.com/Descolada/Aris), you can install like this:

```ahk
aris install AquaHotkey
```

I recommend checking it out, honestly a really cool project.

Special thanks to [Descolada](https://github.com/Descolada) and [JoyHak](https://github.com/JoyHak) for including AquaHotkey in the package index.

## Import

Finally, include the library in your script:

```ahk
 #Requires AutoHotkey v2
 #Include <AquaHotkey\AquaHotkey>
;#Include <AquaHotkey\AquaHotkeyX>
```

Including `<AquaHotkey>` gives you only the core extension framework. To import an additional assortment of extension classes, use `<AquaHotkeyX>`. Also see [API Overview](./api-overview.md).

### Custom

Choose from [AquaHotkey's extension classes](./api-overview.md), and pick only what you need.

Features are grouped into:

- `src/`: source files, ready to use
- `wip/`: experimental features and tests
- `cfg/`: configuration

Example:

```ahk
#Requires AutoHotkey v2
#Include <AquaHotkey\AquaHotkey>
#Include <AquaHotkey\src\Stream\Stream>
#Include <AquaHotkey\src\Collections\HashMap>

; config: enables verbose debug messages for the framework.
#Include <AquaHotkey\cfg\LogVerbose>

; config: disable type assertions (`.AssertType()`).
#Include <AquaHotkey\cfg\DisableTypeAssertions>
```

Beware that `wip/` is where I test out new features or make random experiments. Files in this directory are not expected to be permanent.

## Advanced Setup

I recommend following this short optional setup for convenience.

Create the following stub files `AquaHotkey.ahk` and `AquaHotkeyX.ahk` in the lib folder where AquaHotkey is installed (e.g. `%USERPROFILE%\AutoHotkey\lib`).

```ahk
; ------------- AquaHotkey.ahk (stub)
#Include "%A_LineFile%\..\AquaHotkey\AquaHotkey.ahk"
; -------------

; ------------- AquaHotkeyX.ahk (stub)
#Include "%A_LineFile%\..\AquaHotkey\AquaHotkeyX.ahk"
; -------------
```

After you're finished, the folder should look like this:

```
lib/
|- AquaHotkey.ahk (stub)
|- AquaHotkeyX.ahk (stub)
`- AquaHotkey/
   |- AquaHotkey.ahk (source)
   `- AquaHotkeyX.ahk (source)
```

You can now include this library using only `#Include <AquaHotkey>` or `#Include <AquaHotkeyX>` instead of `<AquaHotkey/AquaHotkey>`/`<AquaHotkey/AquaHotkeyX>`.
