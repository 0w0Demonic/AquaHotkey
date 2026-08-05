#Include <AquaHotkey\src\Base\DuckTypes>
#Include <AquaHotkey\src\Core\Utils>

/**
 * @duck
 * 
 * Valid HTTP methods as specified by {@link https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Methods MDN}.
 * As by RFC9110, HTTP methods are case-sensitive and must be upper-case to be
 * matched against the type pattern of this class.
 * 
 * @module  <Net/HttpMethod>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class HttpMethod extends String
{
    /**
     * All HTTP verbs.
     * 
     * @type {Map<String, true>}
     */
    static Verbs => Map(
        "GET", true,
        "HEAD", true,
        "POST", true,
        "PUT", true,
        "DELETE", true,
        "CONNECT", true,
        "PATCH", true
    )

    /**
     * Returns an enumerator for all HTTP verbs.
     * 
     * @param   {Integer?}  ArgSize  argument size
     * @returns {Enumerator}
     */
    static __Enum(ArgSize := 1) {
        static Verbs := this.Verbs
        return Verbs.__Enum(1)
    }

    /**
     * Determines whether the given value is a valid HTTP method. This may be
     * one of the following values:
     * 
     * `"GET"`, `"HEAD"`, `"POST"`, `"PUT"`, `"DELETE"`, `"CONNECT"`,
     * `"OPTIONS"`, `"TRACE"`, `"PATCH"`.
     * 
     * @inlined
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @see {@link AquaHotkey_DuckTypes duck types}
     * @example
     * "GET".Is(HttpMethod) ; ==> true
     */
    static IsInstance(Val := "") {
        static Verbs := this.Verbs
        return Verbs.Has(Val)
    }
}

