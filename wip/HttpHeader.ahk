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
     * Creates a new HTTP header from name and value.
     * 
     * @constructor
     * @param   {String}  Key    HTTP header name
     * @param   {String}  Value  HTTP header value
     */
    __New(Key, Value) {
        static INVALID_NAME_CHARS  := "[^!#$%&'*+\-.^_``|~\w]"
        static INVALID_VALUE_CHARS := "[^\x{20}-\x{7E}\t]"

        if (IsObject(Key) || !(Key is String)) {
            throw TypeError("Expected a String",, Type(Key))
        } else if (Key == "") {
            throw ValueError("empty string")
        }
        if (IsObject(Value) || !(Value is String)) {
            throw TypeError("Expected a String",, Type(Value))
        }

        Index := RegExMatch(Key, INVALID_NAME_CHARS)
        if (Index) {
            Char := SubStr(Key, Index, 1)
            throw ValueError("invalid char at index #" . Index,,
                    "'" . Char . "' (" . Ord(Char) . ")")
        }

        Value := Trim(Value, "`t`s")
        if (Value == "") {
            return TypeError("empty string")
        }

        Index := RegExMatch(Value, INVALID_VALUE_CHARS)
        if (Index) {
            Char := SubStr(Value, Index, 1)
            throw ValueError("invalid char at index #" . Index,,
                    "'" . Char . "' (" . Ord(Char) . ")")
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

class AquaHotkey_HttpHeader extends AquaHotkey {
    class Object {
        ToHttpHeader() {
            if (!IsPlainObject(this)) {
                throw TypeError("Expected an HTTP header, Entry or plain object",,
                            Type(this))
            }
            if (ObjOwnPropCount(this) != 1) {
                throw ValueError("plain object can contain only one property",,
                        ObjOwnPropCount(this))
            }
            for PropName in ObjOwnProps(this) {
                PropDesc := GetOwnPropDesc(this, PropName)
                if (!ObjHasOwnProp(PropDesc, "Value")) {
                    throw PropertyError("Not a value property")
                }
                return HttpHeader(PropName, PropDesc.Value)
            }
        }
    }
    class String {
        ToHttpHeader() {
            Index := InStr(this, ":")
            if (!Index) {
                throw TypeError("Missing ':'",, this)
            }
            return HttpHeader(SubStr(this, 1, Index - 1), SubStr(this, Index + 1))
        }
    }

    class Any {
        ToHttpHeader() {
            throw MethodError("not applicable",, Type(this))
        }
    }
}

