
#Include <AquaHotkeyX>
#Include <AquaHotkey\wip\collections\UrlParams>
#Include <AquaHotkey\wip\http\HttpHeaders>
#Include <AquaHotkey\wip\http\HttpClient>

#Include <AquaHotkey\src\Time\Duration>

class OsuApi {
    ClientId := unset
    ClientRedirect := unset
    Client := unset
    AccessToken := unset

    __New(ClientId, ClientSecret) {
        DefineConsts(this, {
            ClientId:     ClientId.Assert(IsInteger).Assert(Gt(0)),
            ClientSecret: ClientSecret.AssertType(String),
            Client:       HttpClient(),
            Timer:        Authenticate
        })
        ObjRelease(ObjPtr(this)) ; <-- compensate for timer bound to this
        Authenticate()

        Authenticate() {
            Result := TryOp(() => this.Client.POST(
                "https://osu.ppy.sh/oauth/token", "
                (
                Accept: application/json
                Content-Type: application/x-www-form-urlencoded
                )",
                UrlParams.FromPairs(
                    "client_id", this.ClientId,
                    "client_secret", this.ClientSecret,
                    "grant_type", "client_credentials",
                    "scope", "public"
                )
            ))
            .RetainIf(Res => Res.Status == 200)
            .Map(Res => Res.ResponseText.ParseJson({
                token_type: "Bearer",
                expires_in: Integer,
                access_token: String
            }))
            .OrElseThrow()

            DefineConst(this, "AccessToken", Result.access_token)
            SetTimer(this.Timer, -Result.expires_in)
        }
    }

    __Delete() {
        ObjPtrAddRef(this)
        SetTimer(this.Timer, 0)
        DeleteProp(this, "Timer")

        (this.Client).DELETE(
            "https://osu.ppy.sh/api/v2/oauth/tokens/current", {
                %"Content-Type"%: "application/json",
                %"Accept"%: "application/json",
                %"Authorization"%: "Bearer " . this.AccessToken
            }
        )
    }

    ; TODO include search parameters
    ;
    Beatmapsets(Search := {}) {
        if (!IsPlainObject(Search)) {
            throw TypeError("Expected a plain Object",, Type(Search))
        }
        CursorString := unset
        CurrentItems := (*) => false
        FirstIteration := true
        ObjSetBase(Enumer, Enumerator.Prototype)
        return Enumer

        Enumer(&Beatmap) {
            loop {
                if (CurrentItems(&Beatmap)) {
                    return true
                }
                if (IsSet(CursorString)) {
                    DefineProp(Search, "cursor_string", { Value: CursorString })
                } else if (!FirstIteration) {
                    return false
                }

                FirstIteration := false
                Result := (this.Client).GET(
                    Uri("https://osu.ppy.sh/api/v2/beatmapsets/search").WithQueryParams(Search), {
                        %"Content-Type"%: "application/json",
                        %"Accept"%: "application/json",
                        %"Authorization"%: "Bearer " . this.AccessToken
                    })
                    .ResponseText
                    .ParseJson()

                if (!Result.TryGet("cursor_string", &CursorString)
                    || CursorString == Json.Null)
                {
                    CursorString := unset
                }

                CurrentItems := Result["beatmapsets"].__Enum(1)
            }
        }
    }
}

; A_Clipboard.ParseJson()
; MsgBox("ok")

Client := OsuApi(
    EnvGet("OSU_CLIENT_ID").ToInteger(),
    EnvGet("OSU_API_KEY"))

Using(FileOpen(A_Desktop . "\beatmaps_loved.txt", "w"), (FileObj) {
    Client.Beatmapsets({ m: "1", q: "star>5", sort: "plays_desc", s: "ranked", nsfw: "true" })
        .Stream()
        .RetainIf(BMS => BMS["beatmaps"].Any(IsFiveStarTaiko))
        .Peek(CreateCounter().AndThen(ToolTip, 50, 50))
        .Map(BMS => BMS["beatmaps"][1]["beatmapset_id"])
        .ForEach(ID => FileObj.WriteLine(ID))
})

IsFiveStarTaiko(BM) {
    return BM["mode"] == "taiko"
        && BM["difficulty_rating"] >= 5.0
}

CreateCounter() {
    x := 0
    return (*) => ++x
}

Client := unset
MsgBox("finished")


Using(Obj, Fn) {
    GetMethod(Obj, "Close", 0)
    GetMethod(Fn,, 1)
    Fn(Obj)
    Obj.Close()
}
