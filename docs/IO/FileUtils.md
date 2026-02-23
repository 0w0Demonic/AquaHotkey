# <[Base](./overview.md)/[FileUtils](../../src/IO/FileUtils.ahk)>

- [\<Base/FileUtils\>](#basefileutils)
  - [Overview](#overview)
  - [Standard Input/Output/Error Streams](#standard-inputoutputerror-streams)
  - [`Path()` Function](#path-function)
  - [Enumerating Lines in Files](#enumerating-lines-in-files)
  - [Name Property of File Objects](#name-property-of-file-objects)
  - [File Loops](#file-loops)

## Overview

## Standard Input/Output/Error Streams

Open the standard input, output, and error streams but using `FileOpen.StdIn`,
`FileOpen.StdOut` and `FileOpen.StdErr` respectively.

```ahk
(FileOpen.StdOut).WriteLine("Hello, world!")
```

## `Path()` Function

Introducing `Path()`, which works exactly like `SplitPath()`, but returns an
object of all fields.

```ahk
; {
;     Name:      "Address List.txt",
;     Dir:       "C:\My Documents",
;     Ext:       "txt"
;     NameNoExt: "Address List"
;     Drive:     "C:"
; }
Path("C:\My Documents\Address List.txt")
```

## Enumerating Lines in Files

You can enumerate lines in a file simply by using the `File` object in a
for-loop (or by using streams):

```ahk
for Line in FileOpen("litany.txt", "r") {
    ...
}

for LineNumber, Line in FileOpen("stuff.txt", "r") {
    ...
}

FileOpen("something.txt", "r").Stream().TakeWhile(...).ForEach(...)
```

It's generally a good idea to close the file as soon as possible, but it's
often not necessary.

## Name Property of File Objects

Returns the file name of the `File` object.

```ahk
FileObj.Name ; "C:\...\myFile.txt"
```

## File Loops

`LoopFiles()` lets you create a [Continuation](../Func/Continuation.md), which
works very similarly to [streams](../Stream/Stream.md) and lets you create
functional pipelines to handle files and directories.

```ahk
; equivalent to:
;   loop files A_Desktop . "\*", "FR" {
;       if (A_LoopFileExt != ".ahk") {
;           continue
;       }
;       MsgBox("AHK file: " . A_LoopFilePath)
;   }

LoopFiles(A_Desktop . "\*", "FR")
    .RetainIf((*) => A_LoopFileExt = ".ahk")
    .ForEach((*) => MsgBox("AHK file: " . A_LoopFilePath))
```
