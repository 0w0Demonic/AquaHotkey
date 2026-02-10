# <[Base](./overview.md)/[FileUtils](../../src/IO/FileUtils.ahk)>

## Summary

## Standard Input/Output/Error Streams

Open the standard input, output, and error streams but using `FileOpen.StdIn`,
`FileOpen.StdOut` and `FileOpen.StdErr` respectively.

```ahk
(FileOpen.StdOut).WriteLine("Hello, world!")
```

## SplitPath, But Easier

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
