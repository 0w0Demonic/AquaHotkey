# File

## Enumerating Lines

You can enumerate lines in a file simply by using the File object in a
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

Use `Mapper.ParseCSV` to parse CSV files.

```ahk
FileOpen("file.txt", "r").Stream().Map(  Mapper.ParseCSV  ).ForEach(Arr => ...)
```
