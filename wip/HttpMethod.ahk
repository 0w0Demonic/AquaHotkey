#Include <AquaHotkey\src\Base\DuckTypes>

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
class HttpMethod extends String {
    /**
     * Determines whether the given value is a valid HTTP method. This may be
     * one of the following values:
     * 
     * `"GET"`, `"HEAD"`, `"POST"`, `"PUT"`, `"DELETE"`, `"CONNECT"`,
     * `"OPTIONS"`, `"TRACE"`, `"PATCH"`.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @see {@link AquaHotkey_DuckTypes duck types}
     * @example
     * "GET".Is(HttpMethod) ; ==> true
     */
    static IsInstance(Val := "") {
        static VERBS := Map(
            "GET", true, "HEAD", true, "POST", true, "PUT", true,
            "DELETE", true, "CONNECT", true, "OPTIONS", true, "TRACE", true,
            "PATCH", true)
        return VERBS.Has(Val)
    }

    /**
     * Determines whether the given value is equivalent to, or considered a
     * subtype of this class.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @see {@link AquaHotkey_DuckTypes duck types}
     * @example
     * HttpMethod.CanCastFrom(HttpMethod) ; ==> true
     * HttpMethod.CanCastFrom("GET") ; ==> true
     */
    static CanCastFrom(Val?) {
        if (!IsSet(Val)) {
            return false
        }
        return this.IsInstance(Val) || (Val == this) || (HasBase(Val, this))
    }
}