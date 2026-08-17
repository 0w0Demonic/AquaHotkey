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

/**
 * @class
 * @classdesc
 * Represents an URI with `http` or `https` scheme.
 * 
 * @extends {Uri}
 */
class HttpUri extends Uri {
    /**
     * @static
     * @readonly
     * @type {Array<String>}
     */
    static Schemes => ["http", "https"]
}

/**
 * 
 */
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

            RequestQueue := HANDLE()
            Res := HttpServer.HttpCreateHttpHandle(RequestQueue)
            if (Res != WIN32_ERROR.NO_ERROR) {
                Out := OSError("Unable to create HTTP handle: " . Res)
                return false
            }

            for Url in Urls {
                Res := HttpServer.HttpAddUrl(RequestQueue, Url)
                if (Res != WIN32_ERROR.NO_ERROR) {
                    Out := ValueError("Unable to add URL: " . Url)
                    return false
                }
            }

            Out := DefineProps({ base: this.Prototype }, {
                RequestQueue: { Get: (_) => RequestQueue },
                Urls: { Get: (_) => Urls.Clone() }
            })
            return true
        }

        /**
         * Default buffer size for incoming requests. This buffer is reallocated
         * if too small for the current request.
         * 
         * @readonly
         * @type {Integer}
         */
        DefaultReqBufferSize => 2048

        /**
         * Runs the HTTP server, awaiting an HTTP request with the given
         * timeout in milliseconds. If none is specified, the server waits
         * indefinitely.
         * 
         * @param   {Integer?}  TimeoutMs  timeout in milliseconds
         */
        Run(TimeoutMs := Threading.INFINITE) {
            Buf := Buffer(HTTP_REQUEST_V1.sizeof + this.DefaultReqBufferSize)
            Request := HTTP_REQUEST_V1(Buf.Ptr)
            ReqId := 0

            OL := OVERLAPPED()
            Event := Threading.CreateEventW(0, TRUE, FALSE, 0)
            if (!Event.Value) {
                throw OSError()
            }
            OL.hEvent.Value := Event.Value
            loop {
                DllCall("RtlZeroMemory", "Ptr", Buf, "Int64", Buf.Size)

                Result := HttpServer.HttpReceiveHttpRequest(
                    this.RequestQueue, ReqId, 0,
                    Buf, Buf.Size, 0,
                    OL)
                
                switch (Result) {
                    case WIN32_ERROR.NO_ERROR:
                        MsgBox("immediate success")
                    case WIN32_ERROR.ERROR_IO_PENDING:
                        MsgBox("pending...")
                        WaitResult := Threading.WaitForSingleObject(OL.hEvent, TimeoutMs)
                        switch (WaitResult) {
                            case WAIT_EVENT.WAIT_OBJECT_0:
                                MsgBox("success request")
                            case WAIT_EVENT.WAIT_TIMEOUT:
                                MsgBox("timeout")
                            default:
                                MsgBox("wait error: " . WaitResult)
                                break
                        }
                    default:
                        MsgBox("request error: " . Result)
                        break
                }
                break
            }

            ; avoid freeing twice
            OL.hEvent.Value := 0
            Buf := unset
            Request := unset
            Event := unset
        }

        /**
         * Frees the resources of the HTTP server.
         */
        __Delete() {
            for Url in this.Urls {
                HttpServer.HttpRemoveUrl(this.RequestQueue, Url)
            }
            DeleteProp(this, "RequestQueue")
            HttpServer.HttpTerminate(HTTP_INITIALIZE.HTTP_INITIALIZE_SERVER)
        }
    }
}

#Include <AquaHotkey\src\Base\ToString>
#Include <AquaHotkey\src\Base\Primitives>

#Include <AquaHotkey\src\Time\Duration>

Server := HttpServer.Create("http://localhost:8080")
Server.Run(10.Seconds)

MsgBox("finished")
Server := unset
