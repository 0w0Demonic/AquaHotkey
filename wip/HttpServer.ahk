#Requires AutoHotkey v2.0

#DllLoad "httpapi.dll"
#Include <AhkWin32Projection\Windows\Win32\Networking\HttpServer\Apis>
#Include <AhkWin32Projection\Windows\Win32\Networking\HttpServer\HTTP_VERSION>
#Include <AhkWin32Projection\Windows\Win32\Networking\HttpServer\HTTP_INITIALIZE>
#Include <AhkWin32Projection\Windows\Win32\Networking\HttpServer\HTTP_REQUEST_V1>
#Include <AhkWin32Projection\Windows\Win32\Networking\HttpServer\HTTP_VERB>

#Include <AhkWin32Projection\Windows\Win32\Foundation\WIN32_ERROR>
#Include <AhkWin32Projection\Windows\Win32\Foundation\Apis>
#Include <AhkWin32Projection\Windows\Win32\Foundation\HANDLE>
#Include <AhkWin32Projection\Windows\Win32\Foundation\WAIT_EVENT>
#Include <AhkWin32Projection\Windows\Win32\System\Kernel\Apis>

#Include <AhkWin32Projection\Windows\Win32\System\IO\OVERLAPPED>
#Include <AhkWin32Projection\Windows\Win32\System\IO\Apis>
#Include <AhkWin32Projection\Windows\Win32\System\Threading\Apis>

#Include <AquaHotkey>
#Include <AquaHotkey\src\Net\Uri>
#Include <AquaHotkey\src\Base\DuckTypes>

class HttpUri extends Uri {
    static Schemes => ["http", "https"]
}

class AquaHotkey_HttpServer extends AquaHotkey
{
    ; evil hacks, just add to existing `HttpServer`.
    class HttpServer {
        static Create(Urls*) {
            if (!this.TryCreate(&Out, Urls*)) {
                throw Out
            }
            return Out
        }

        static Call(Urls*) {
            if (!this.TryCreate(&Out, Urls*)) {
                throw Out
            }
            return Out
        }

        static TryCreate(&Out, Urls*) {
            static VERSION := 1

            if (!Urls.Length) {
                Out := ValueError("no URLs specified")
                return false
            }

            Enumer := Urls.__Enum(1)
            Urls := Array()
            for Url in Enumer {
                if (!IsObject(Url) && (Url is String)) {
                    Url := Uri(Url)
                }
                if (!(Url is HttpUri)) {
                    throw TypeError("Expected a valid HTTP URL",, Type(Url))
                }
                if (Url.Path == "") {
                    Url := Url.Resolve("/")
                }
                Urls.Push(String(Url))
            }

            Res := HttpServer.HttpInitialize(
                VERSION,
                HTTP_INITIALIZE.HTTP_INITIALIZE_SERVER)

            if (Res != WIN32_ERROR.NO_ERROR) {
                Out := OSError("Unable to initialize HTTP server")
                return false
            }

            H := HANDLE()
            Res := HttpServer.HttpCreateHttpHandle(H)
            if (Res != WIN32_ERROR.NO_ERROR) {
                Out := OSError("Unable to create HTTP handle")
                return false
            }

            for Url in Urls {
                Res := HttpServer.HttpAddUrl(H, Url)
                if (Res != WIN32_ERROR.NO_ERROR) {
                    Out := ValueError("Unable to add URL: " . Url)
                    return false
                }
            }

            Out := { base: this.Prototype }
            DefineConst(Out, "Handle", H)
            DefineGetter(Out, "Urls", (_) => Urls.Clone())
            return true
        }

        DefaultReqBufferSize => 2048

        Listen(TimeoutMs := 10000) {
            Buf := Buffer(HTTP_REQUEST_V1.sizeof + this.DefaultReqBufferSize, 0)
            ReqId := 0

            DllCall("RtlZeroMemory", "Ptr", Buf, "Int64", Buf.Size)
            
            OL := OVERLAPPED()
            Event := OL.hEvent
            Event.Value := Threading.CreateEventW(0, true, false, 0).Value

            if (!OL.hEvent) {
                throw OSError()
            }

            Result := HttpServer.HttpReceiveHttpRequest(
                this.Handle, ReqId, 0,
                Buf, Buf.Size, &BytesRead := 0,
                OL)


            switch {
                case (Result == WIN32_ERROR.NO_ERROR):
                    MsgBox("immediate success")
                    return
                case (Result == WIN32_ERROR.ERROR_IO_PENDING):
                    throw OSError()
            }

            WaitResult := Threading.WaitForSingleObject(OL.hEvent, TimeoutMs)
            if (WaitResult == WAIT_EVENT.WAIT_OBJECT_0) {
                MsgBox("delayed success")
                return
            }
            if (WaitResult == WAIT_EVENT.WAIT_TIMEOUT) {
                MsgBox("timeout")
            } else {
                MsgBox("other error")
            }
            IO.CancelIoEx(this.Handle, OL)
            

            ; switch (Result) {
            ; case WIN32_ERROR.NO_ERROR:
            ;     Request := HTTP_REQUEST_V1(Buf.Ptr)

            ;     switch (Request.Verb) {
            ;     case HTTP_VERB.HttpVerbGET:
            ;         MsgBox("GET")
            ;     }
            ; }
        }

        __Delete() {
            for Url in this.Urls {
                HttpServer.HttpRemoveUrl(this.Handle, Url)
            }
            DeleteProp(this, "Handle")
            HttpServer.HttpTerminate(HTTP_INITIALIZE.HTTP_INITIALIZE_SERVER)
        }
    }
}

#Include <AquaHotkey\src\Base\ToString>
#Include <AquaHotkey\src\Base\Primitives>

#Include <AquaHotkey\src\Time\Duration>

Server := HttpServer.Create("http://localhost:8080")
Server.Listen(Timeout := 10.Seconds)

Server := unset
MsgBox("finished")
