/**
 * Utility class used for creating different types of mapper functions.
 * 
 * @example
 * 
 * ; [2, 3, 4, 5, 6]
 * Array(1, 2, 3, 4, 5).Map(  Mapper.Increment  )
 */
class Mapper {
    /**
     * Mapper which returns the input argument that was given.
     * @return  {Func}
     */
    static Identity => ((x) => x)

    /**
     * Mapper which increments numbers.
     * @return  {Func}
     */
    static Increment => ((x) => (x + 1))

    /**
     * Mapper which decrements numbers.
     * @return  {Func}
     */
    static Decrement => ((x) => (x - 1))

    /**
     * Mapper which prepends the given prefix.
     * @param   {String}  P  prefix to prepend with
     * @return  {Func}
     */
    static Prefix(P) {
        P .= ""
        return (Str) => (P . Str)
    }

    /**
     * Mapper which appends the given suffix.
     * @param   {String}  S  suffix to append
     * @return  {Func}
     */
    static Suffix(S) {
        S .= ""
        return (Str) => (Str . S)
    }

    /**
     * Mapper which formats values using the given `Pattern`.
     * @param   {String}  Pattern  format pattern to apply
     * @return  {Func}
     */
    static Format(Pattern) {
        Pattern .= ""
        return Format.Bind(Pattern)
    }

    /**
     * Mapper that replaces the specified substring with a new string.
     * @param   {String}      Pat        string that should be replace
     * @param   {String?}     Rep        string to replace with
     * @param   {Primitive?}  CaseSense  case sensitivity
     * @param   {Integer?}    Limit      max amount of replacements
     * @return  {Func}
     */
    static StrReplace(Pat, Rep := "", CaseSense?, Lim?) {
        return (Str) => StrReplace(Str, Pat, Rep, CaseSense?, unset, Lim?)
    }

    /**
     * Mapper that replaces occurrences of a regular expression into a string.
     * @param   {String}    Pat       regular expression to search
     * @param   {String?}   Rep       string to replace with
     * @param   {Integer?}  Lim       max amount of replacements
     * @param   {Integer?}  StartPos  index to start searching on
     * @return  {Func}
     */
    static RegExReplace(Pat, Rep := "", Lim?, StartPos?) {
        return (Str) => RegExReplace(Str, Pat, Rep, unset, Lim?, StartPos?)
    }

    /**
     * Mapper that separates a string into its characters.
     * @return  {Func}
     */
    static Split => this.Split()

    /**
     * Mapper that separates a string into an array of substrings.
     * @param   {String?/Array?}  Delim      delimiter to determine boundaries
     * @param   {String}          OmitChars  characters to omit
     * @param   {Integer}         Lim        max amount of output strings
     * @return  {Func}
     */
    static Split(Delim?, OmitChars?, Lim?) {
        return (Str) => StrSplit(Str, Delim?, OmitChars?, Lim?)
    }

    /**
     * Mapper that returns a substring.
     * @param   {Integer}   StartIndex  starting index of the substring
     * @param   {Integer?}  Length      length of the substring
     * @return  {Func}
     */
    static SubStr(StartIndex, Length?) {
        if (!IsInteger(StartIndex)) {
            throw TypeError("Expected an Integer",, Type(StartIndex))
        }
        if (!IsInteger(Length)) {
            throw TypeError("Expected an Integer",, Type(Length))
        }
        return (Str) => SubStr(Str, StartIndex, Length?)
    }

    /**
     * Mapper that accesses the `.__Item[]` property of an object.
     * @param   {Any}  Value  the value to retrieve
     */
    static Index(Value) {
        return ((Obj) => Obj[Value])
    }

    /**
     * Mapper that returns the `n`-th input argument.
     * @param   {Integer}  n  index of the argument to retrieve
     * @return  {Func}
     */
    static Arg(n) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        return ((Args*) => Args[n])
    }

    /**
     * Mapper that accesses the property of an object.
     * @param   {String}  PropertyName  name of the property to retrieve
     * @return  {Func}
     */
    static Property(PropertyName) {
        PropertyName .= ""
        return ((Obj) => (Obj.%PropertyName%))
    }

    /**
     * Mapper that access an object's method.
     * @param   {String}  MethodName  name of the method to invoke.
     * @param   {Any*}    Args        zero or more arguments.
     */
    static Method(MethodName, Args*) {
        return ((Obj) => (Obj.%MethodName%(Args*)))
    }
}