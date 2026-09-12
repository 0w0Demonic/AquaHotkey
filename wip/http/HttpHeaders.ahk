#Include <AquaHotkey\src\Collections\Generic\Array>
#Include <AquaHotkey\src\Interfaces\Enumerable1>
#Include <AquaHotkey\wip\http\HttpHeader>

; TODO generalize this and `UrlParams`

/**
 * An array of HTTP headers.
 * 
 * @module  <Net/HttpHeaders>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class HttpHeaders extends GenericArray {
    static __New() => super.__New(Array, HttpHeader)

    static From(Val) => Val.ToHttpHeaders()
    
    ToString() => this.Join("`r`n")
}

class AquaHotkey_HttpHeaders extends AquaHotkey {
    class Any {
        ToHttpHeaders() {
            throw MethodError("not applicable",, Type(this))
        }
    }

    class String {
        ToHttpHeaders() {
            Headers := HttpHeaders()
            Arr := Headers.A
            loop parse this, "`n", "`r" {
                Index := InStr(A_LoopField, ":")
                if (!Index) {
                    throw ValueError("Missing ':'",, this)
                }
                Arr.Push(HttpHeader(
                    SubStr(A_LoopField, 1, Index - 1),
                    SubStr(A_LoopField, Index + 1)))
            }
            return Headers
        }
    }

    class Object {
        ToHttpHeaders() {
            if (!IsPlainObject(this)) {
                throw TypeError("Expected a plain object",, Type(this))
            }
            Headers := HttpHeaders()
            Arr := Headers.A
            for Key, Value in OwnValueProps(this) {
                Arr.Push(HttpHeader(Key, Value))
            }
            return Headers
        }
    }

    class IMap {
        ToHttpHeaders() {
            Headers := HttpHeaders()
            Arr := Headers.A
            for Key, Value in this {
                Arr.Push(HttpHeader(Key, Value))
            }
            return Headers
        }
    }

    class IArray {
        ToHttpHeaders() {
            Headers := HttpHeaders()
            Arr := Headers.A
            for Value in this {
                Arr.Push(Value.ToHttpHeaders()*)
            }
            return Headers
        }
    }
}

