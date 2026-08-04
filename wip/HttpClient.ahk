#Requires AutoHotkey v2.0

#Include <AquaHotkey\src\Net\Uri>
#Include <AquaHotkey\src\Monads\TryOp>
#Include <AquaHotkey\wip\HttpHeaders>

class HttpUri extends Uri {
    static Schemes => ["http", "https"]
}

class HttpClient {
    __New() {
        this.Client := ComObject("MSXML2.XMLHTTP.6.0")
    }

    GET(Url, Headers := [], Body?) {
        Url.AssertType(HttpUri)
        Headers.AssertType(HttpHeaders)
        
        C := (this.Client)
        C.Open("GET", String(Url), false)
        for Header in Headers {
            C.SetRequestHeader(Header.Key, Header.Value)
        }
        C.Send()
        if (C.Status == 200) {
            return TryOp.Success(C.ResponseText)
        } else {
            return TryOp.Failure("(placeholder)")
        }
    }
}