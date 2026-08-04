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
        if (!IsPrimitive(Key)) {
            throw TypeError("Expected a String",, Type(Key))
        }
        if (!IsPrimitive(Value)) {
            throw TypeError("Expected a String",, Type(Value))
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
