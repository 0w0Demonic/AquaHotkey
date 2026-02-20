# <[Func](./overview.md)/[Pipes](../../src/Func/Pipes.ahk)>

## Overview

Allows streamlining code in the form of pipelines like you would in
languages like Bash or PowerShell.

Calling `.o0()` on any value accepts a function to pipe to, following by zero
or more arguments. `A.o0(B, C)` becomes equivalent to `B(A, C)`.

```ahk
"  Hello, world!  ".o0(Trim).o0(StrUpper).o0(MsgBox)
```

<sub>(Note: `.o0()` kind of looks like water bubbles, hence the name)</sub>

Note: avoid using this feature when dealing with large strings.
