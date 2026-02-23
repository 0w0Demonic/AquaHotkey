# <[IO](./overview.md)/[Path](../../src/IO/Path.ahk)>

- [\<IO/Path\>](#iopath)
  - [Overview](#overview)
  - [Properties](#properties)
  - [Parent Directory](#parent-directory)

## Overview

An immutable object that represents a file path, directory, or URL.

```ahk
P := Path(A_Desktop . "\myFile.txt")
```

## Properties

Much like `SplitPath()`, paths allow you to retrieve the following properties:

- `Name`: file name without the file path
- `Dir`: directory of the file
- `Ext`: file extension
- `NameNoExt`: file name without path, dot and extension
- `Drive`: the drive or server name of the file

## Parent Directory

Use `.Parent()` to retrieve the parent directory as new `Path`.

```ahk
P := Path(A_Desktop . "\myFile.txt")
P.Parent().ToString().MsgBox() ; "C:\Users\Amy\Desktop" (for example)
```
