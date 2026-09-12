#Include <AquaHotkey\src\Core\Utils>
#Include <AquaHotkey\src\Base\Assertions>

#Include <AquaHotkey\src\Net\Uri>
#Include <AquaHotkey\src\Monads\TryOp>

#Include <AquaHotkey\wip\http\HttpHeaders>
#Include <AquaHotkey\wip\http\HttpMethod>
#Include <AquaHotkey\wip\collections\UrlParam>
#Include <AquaHotkey\wip\collections\UrlParams>

class HttpUri extends Uri {
    static Schemes => ["http", "https"]
}

class HttpClient {
    __New() {
        DefineConst(this, "Client", ComObject("WinHttp.WinHttpRequest.5.1"))
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
                Body := String(Body)
            }
            
            C := (this.Client)
            C.Open(Verb, String(Url), false)
            for Header in Headers {
                C.SetRequestHeader(Header.Key, Header.Value)
            }
            C.Send(Body?)

            return HttpResponse(C.ResponseText, this.ResponseBody, C.Status, C.StatusText)
        }
    }

    ResponseBody {
        get {
            pSafeArray := ComObjValue(t := this.Client.ResponseBody)
            pvData := NumGet(pSafeArray + 8 + A_PtrSize, 'ptr')
            cbElements := NumGet(pSafeArray + 8 + A_PtrSize * 2, 'uint')
            MsgBox("returning")
            return ClipboardAll(pvData, cbElements)
        }
    }
}

class HttpResponse {
    __New(ResponseText, ResponseBody, Status, StatusText) {
        DefineConst(this, "ResponseText", ResponseText)
        DefineConst(this, "ResponseBody", ResponseBody)
        DefineConst(this, "Status", Status)
        DefineConst(this, "StatusText", StatusText)
    }

    ToString() => Format("
    (
    {}: {}
    {}
    )", this.Status, this.StatusText, this.ResponseText)
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

