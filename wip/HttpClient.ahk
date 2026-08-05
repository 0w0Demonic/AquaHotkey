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
        this.Client := ComObject("MSXML2.XMLHTTP.6.0")
    }

    static __New() {
        DeleteProp(this, "__New")
        for Verb in HttpMethod {
            DefineMethod(this.Prototype, Verb, ObjBindMethod(Send,, Verb))
        }

        static Send(Verb, this, Url, Headers := [], Body?) {
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

            FileOpen("out.html", "w").Write(C.ResponseText)
            if (C.Status == 200) {
                return TryOp.Success(C.ResponseText)
            } else {
                return TryOp.Failure(Error("(placeholder)"))
            }
        }
    }
}
