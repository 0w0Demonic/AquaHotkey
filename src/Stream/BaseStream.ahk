#Include "%A_LineFile%\..\..\Func\Cast.ahk"

/**
 * Internals of {@link Stream} and {@link DoubleStream}, along with commonly
 * shared methods.
 * 
 * @module  <Stream/BaseStream>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class BaseStream extends Enumerator {
    /**
     * Constructs a new stream with the given `Source` used for retrieving
     * elements. When retrieving the underlying Enumerator object, `__Enum`
     * always takes precedence over `Call`, and goes down a chain of `__Enum`
     * calls if necessary.
     * 
     * For example:
     * ```ahk
     * class A { __Enum(ArgSize) => B()    }
     * class B { __Enum(ArgSize) => MyFunc }
     * 
     * (A.Stream().Call == MyFunc) ; true
     * ```
     * 
     * **Requirements for a Valid Stream Source**:
     * 
     * 1. Only ByRef parameters `&ref`.
     * 2. No variadic parameters `args*`.
     * 3. `MaxParams` is between `1` and `2`.
     * 
     * @param   {Any}  Source  the function used as stream source
     * @returns {BaseStream}
     */
    static Call(Source) {
        if (this == BaseStream) {
            throw TypeError("This abstract class cannot be used directly.")
        }

        ; `.__Enum()` always takes priority before `.Call()`
        if (HasProp(Source, "__Enum")) {
            Source := Source.__Enum(this.Size)
        }

        ; At this point, `Source` must be callable
        if (!HasMethod(Source)) {
            throw UnsetError("value is not enumerable",, Type(Source))
        }

        ; Do some assertions on the enumerator being used. If `Source` is an
        ; object, get the actual `Call` function.
        f := (Source is Func) ? Source : GetMethod(Source, "Call")
        if (f.IsVariadic) {
            throw ValueError("varargs parameter",, f.Name)
        }

        ; `BoundFunc`s are broken in terms of `MinParams`/`MaxParams`,
        ; but this doesn't affect this simple assertion.
        if (f.MaxParams > this.Size) {
            throw ValueError("invalid number of parameters",, f.MaxParams)
        }

        return this.Cast(Source)
    }

    /**
     * Creates a new stream consisting of zero or more values `Args*`.
     * 
     * @example
     * Stream.of("Hello", "world!") ; <"Hello", "world!">
     * Stream.of() ; <>
     * 
     * @param   {Any*}  Args  zero or more stream elements
     * @returns {Stream}
     */
    static Of(Args*) => this.Cast(Args.__Enum(this.Size))

    /**
     * The argument size of the stream.
     * 
     * @abstract
     * @returns {Integer}
     */
    static Size {
        get {
            throw PropertyError("Unknown size")
        }
    }

    /**
     * The argument size of the stream.
     * 
     * @abstract
     * @returns {Integer}
     */
    Size {
        get {
            throw PropertyError("Unknown size")
        }
    }

    /**
     * Returns a stream of the object's own properties.
     * 
     * @param   {Object}  Obj  the object whose properties to enumerate
     * @returns {Stream}
     * @example
     * class Example {
     *     a := 1
     *     b := 2
     * }
     * 
     * Stream.OfOwnProps(Example()) ; <("a", 1), ("b", 2)>
     */
    static OfOwnProps(Obj) => this.Cast(ObjOwnProps(Obj))

    /**
     * (AutoHotkey v2.1-alpha.10+):
     * 
     * Returns a stream of the object's own properties.
     * 
     * (AutoHotkey v2.1-alpha.18+):
     * 
     * This method allows any value to be passed, instead of objects only.
     * 
     * @param   {Object/Any}  Val  the value whose properties to enumerate
     * @returns {DoubleStream}
     * @example
     * BaseObj := { a: 1 }
     * Obj := { base: BaseObj, b: 2, c: 3 }
     * 
     * Stream.OfProps(Obj) ; <("a", 1), ("b", 2), ("c", 3), ...>
     */
    static __New() {
        switch {
            case (this != BaseStream):
                return
            case (VerCompare(A_AhkVersion, ">=v2.1-alpha.18")):
                P := (Any.Prototype.Props)
            case (VerCompare(A_AhkVersion, ">=v2.1-alpha.10")):
                P := (Object.Prototype.Props)
            default:
                return
        }
        ({}.DefineProp)(this, "OfProps", { Call: OfProps })

        OfProps(Cls, Val) {
            return Cls.Cast(P(Val))
        }
    }
}