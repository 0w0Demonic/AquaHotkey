#Include <AquaHotkeyX>

/**
 * A URL query parameter consisting of key and value.
 */
class UrlParam extends Entry {
    /**
     * Constructs a new URL query parameter.
     * 
     * @constructor
     * @param   {Primitive}  Key    query key
     * @param   {Primitive}  Value  query value
     */
    __New(Key, Value) {
        if (!(Key is Primitive)) {
            throw TypeError("Expected a String",, Type(Key))
        }
        super.__New(Key, Value)
    }

    /**
     * Returns the string representation of this URL query parameter.
     * 
     * @returns {String}
     */
    ToString() => UrlEncode(this.Key) . "=" . UrlEncode(this.Value)
}
