/**
 * Creates a function that constructs objects with the specified property names.
 * The amount of input arguments must equal the amount of properties assigned.
 * 
 * @param   {String*}  Names  zero or more property names
 * @example
 * Cons := ObjConstructor("Key", "Value")
 * 
 * ; { Key: "foo", Value: "bar" }
 * Cons("foo", "bar")
 */
ObjConstructor(Names*) {
    Base := Object()
    for Name in Names {
        if (!(Name is Primitive)) {
            throw TypeError("Expected a String",, Type(Name))
        }
    }
    return Cons

    Cons(Values*) {
        if (Values.Length != Names.Length) {
            throw ValueError("expected " . Names.Length . " parameters",,
                             Values.Length)
        }
        Obj := Object()
        loop (Values.Length) {
            Obj.DefineProp(Names[A_Index], { Value: Values[A_Index] })
        }
        return Obj
    }
}

/**
 * Creates a function that "spreads" its input through varargs and then
 * forwards onto `Fn`.
 * 
 * @param   {Func}  Fn  the function to be called
 * @returns {Func}
 * @example
 * Variadic(Args*) {
 *     ...
 * }
 * Regular := Spread(Variadic)
 * Regular([1, 2, 3, 4]) ; --> Variadic(1, 2, 3, 4)
 */
Spread(Fn) => GetMethod(Fn) && (Args) => Fn(Args*)

/**
 * Creates a function that "unspreads" its input arguments through varargs
 * and then forwards onto `Fn`.
 * 
 * @param   {Func}  Fn  the function to be called
 * @returns {Func}
 * @example
 * Regular(Arg) {
 *     ...
 * }
 * Variadic := Unspread(Regular)
 * Variadic(1, 2, 3, 4) ; --> Regular([1, 2, 3, 4])
 */
Unspread(Fn) => GetMethod(Fn) && (Args*) => Fn(Args)

/**
 * Executes a function and guarantees that a cleanup routine runs afterward,
 * regardless of whether an exception occurred.
 * 
 * This is intended as a lightweight "defer" mechanism to ensure handles,
 * buffers, or other resources are released automatically.
 * 
 * It is recommended to use v2.1-alpha.3+ together with its introduction to
 * multi-line function declarations, but it isn't required.
 * 
 * @param   {() => void}  Closer  cleanup function
 * @param   {() => void}  Runner  function containing main execution logic
 * @example
 * Handle := DllCall("OpenFile", ...)
 * Defer(() => DllCall("CloseHandle", "Ptr", Handle), () {
 *   ; (do something with the file handle...)
 *   
 *   ; you can nest, if you want.
 *   Handle2 := ...
 *   Defer(() => DllCall("CloseHandle", "Ptr", Handle2), () {
 *     ...
 *   })
 * })
 */
Defer(Closer, Runner) {
    GetMethod(Closer)
    GetMethod(Runner)
    try {
        Runner()
    } catch Any as Err {
    }
    Closer()
    if (IsSet(Err)) {
        throw Err
    }
}