#Include <AquaHotkey\src\Core\Utils>
#Include <AquaHotkey\src\Base\Assertions>

#Include <AquaHotkey\src\Net\Uri>
#Include <AquaHotkey\src\Monads\TryOp>

#Include <AquaHotkey\wip\HttpHeaders>
#Include <AquaHotkey\wip\HttpMethod>
#Include <AquaHotkey\wip\UrlParam>
#Include <AquaHotkey\wip\UrlParams>

class HttpUri extends Uri {
    static Schemes => ["http", "https"]
}

class HttpClient {
    __New() {
        DefineConst(this, "Client", ComObject("MSXML2.XMLHTTP.6.0"))
    }

    static __New() {
        DeleteProp(this, "__New")
        for Verb in HttpMethod {
            DefineMethod(
                    this.Prototype, Verb,
                    ObjBindMethod(SendRequest,, Verb))
        }

        static SendRequest(
                    Verb, ; <-- HTTP verb (bound)
                    this, Url, Headers := [], Body?)
        {
            Url := Url.AssertType(HttpUri).ToString()
            Headers := Headers.ToHttpHeaders().AssertType(HttpHeaders)
            if (IsSet(Body) && (IsObject(Body) || !(Body is String))) {
                throw TypeError("Expected a String",, Type(Body))
            }
            
            C := (this.Client)
            C.Open(Verb, String(Url), false)
            for Header in Headers {
                C.SetRequestHeader(Header.Key, Header.Value)
            }
            C.Send(Body?)

            return HttpResponse(C.ResponseText, C.ResponseXML, C.Status, C.StatusText)
        }
    }
}

class HttpResponse {
    __New(ResponseText, ResponseXML, Status, StatusText) {
        DefineConst(this, "ResponseText", ResponseText)
        DefineConst(this, "ResponseXML", ResponseXML)
        DefineConst(this, "Status", Status)
        DefineConst(this, "StatusText", StatusText)
    }
}

class AquaHotkey_HttpClient extends AquaHotkey {
    class HttpUri {
        static __New() {
            for Verb in HttpMethod {
                Callback := GetOwnPropDesc(HttpClient.Prototype, Verb).Call
                DefineMethod(
                        this.Prototype, Verb,
                        ObjBindMethod(SendRequest,, Callback))
            }

            static SendRequest(
                    Callback, ; <-- method `HttpClient.<Verb>()` (bound)
                    this, Headers := [], Body?)
            {
                ; same as `HttpClient().<Verb>(this, Headers, Body?)`
                return Callback(HttpClient(), this, Headers, Body?)
            }
        }
    }
}
