# 01 - Getting Started

## Overview

AquaHotkey consists of two separate components:

**1. Class Prototyping**:

A feature that is used to define custom methods and properties for built-in
classes.

**2. Type Extensions**:

An extensive and expressive API that builds on the previous component, providing
a large variety of new methods and properties for built-in classes and other
interesting tools.

## Installation and Setup

1. Clone the repository anywhere:

   ```sh
   git clone https://www.github.com/0w0Demonic/AquaHotkey.git
   ```

   Consider moving the repository into a standard library path such as
   `A_MyDocuments\AutoHotkey\Lib` so it can be imported more easily.

2. Include AquaHotkey.ahk in your script:

   ```ahk
   #Requires AutoHotkey >=v2.0.5
   #Include <AquaHotkey>

   ; #Include path/to/AquaHotkey.ahk
   ```

   Note: using `%A_LineFile%/../` is very useful for loading files by
   relative path, as it describes the directory in which the current file
   is located.

3. Done! Feel free to continue by [writing your own extensions](02-class-prototyping.md)
   or by reading the [API reference](./03-api-overview.md) to get started with
   AquaHotkey's built-in class API.

### Using AquaHotkeyX

To use all of the standard library that comes with AquaHotkey, use
`AquaHotkeyX.ahk` in your script instead.

```ahk
#Requires AutoHotkey >=v2.0.5
#Include <AquaHotkeyX>

; #Include path/to/AquaHotkeyX.ahk
```