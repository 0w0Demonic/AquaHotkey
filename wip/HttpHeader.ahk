#Include <AquaHotkey\src\Collections\Entry>

/**
 * A HTTP header for passing additional information in a request or response.
 * 
 * @module  <Net/HttpHeader>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class HttpHeader extends Entry {
    /**
     * Constructs a new HTTP header.
     * 
     * @constructor
     * @param   {Primitive}  Key    HTTP header name
     * @param   {Primitive}  Value  HTTP header value
     */
    __New(Key, Value) {
        ; TODO add validation as by https://datatracker.ietf.org/doc/html/rfc7230#section-3.2.6
        if (!IsPrimitive(Key)) {
            throw TypeError("Expected a String",, Type(Key))
        }
        if (!IsPrimitive(Value)) {
            throw TypeError("Expected a String",, Type(Value))
        }

        super.__New(Key, Value)
    }

    /**
     * Returns the string representation of this HTTP header.
     * 
     * @returns {String}
     */
    ToString() => (this.Key . ": " . this.Value)
}
