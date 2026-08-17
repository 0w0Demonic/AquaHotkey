#Requires AutoHotkey v2.0

; apparently, Minecraft Bedrock Edition has its own URI scheme. Yes, you
; heard that right. Check it out at https://github.com/phasephasephase/MCBEProtocolURIs.
; This is very likely not going to be part of Aqua (because duh), but this got
; me really interested, and I want to try it out and share it here.

#Include <AquaHotkey>
#Include <AquaHotkey\src\Net\Uri>
#Include <AquaHotkey\src\Net\UrlEncoding>
#Include <AquaHotkey\src\Collections\Entry>

class Minecraft extends Any {
    static Resolve(Other) {
        static U := Uri("minecraft://")
        Result := U.Resolve(Other)
        return Result
    }

    static WithUrlParams(Args*) {
        static U := Uri("minecraft://")
        Result := U.WithUrlParams(Args*)
        return Result
    }

    static ConnectToServer(Server, Port := 19132) {
        Query := UrlParams("serverUrl", Server, "serverPort", Port)
        this.Resolve("//connect" . Query).Run()
    }

    static ConnectToLocalWorld(Name) {
        if (IsObject(Name) || !HasBase(Name, ObjGetBase(ObjGetBase("")))) {
            throw TypeError("Expected a primitive value",, Type(Name))
        }

        this.Resolve("//connect/" . UrlParams("localWorld", Name)).Run()
    }

    static LaunchWithOculus() {
        this.Resolve("//oculus_launched")
    }

    static ShowHowToPlay(Topic := true) {
        this.Resolve("/" . UrlParams("showHowToPlayScreen", Topic)).Run()
    }

    ; TODO
    /**
     * Opens the marketplace.
     * 
     * @param   {String?}  StoreItem  UUID of the store item
     */
    static OpenStore(StoreItem?) {
        if (IsSet(StoreItem)) {
            this.Resolve("//openStore" . UrlParams("showStoreOffer", StoreItem)).Run()
        } else {
            this.Resolve("//openStore").Run()
        }
    }

    static RunCommand(Command) {
        this.Resolve("/" . UrlParams("slashcommand", Command)).Run()
    }

    static AddExternalServer(Name, Address, Port := 19132) {
        Value := Name . "|" . Address . ":" . Port
        this.Resolve("/" . UrlParams("addExternalServer", Value)).Run()
    }

    static ShowMineCoinOffers() {
        this.Resolve("/" . UrlParams("showMineCoinOffers", true)).Run()
    }

    static OpenServersTab() {
        this.Resolve("//openServersTab").Run()
    }

    static ShowProfileScreen() {
        this.Resolve("//showProfileScreen").Run()
    }

    static ShowDressingRoomOffer(OfferId) {
        this.Resolve("//showDressingRoomOffer" . UrlParams("offerId", OfferId)).Run()
    }

    static JoinExperience() {
        throw MethodError("not yet implemented")
    }

    static ConnectToRealm(RealmId) {
        this.Resolve("//connectToRealm" . UrlParams("realmId", RealmId)).Run()
    }

    static AcceptRealmInvite(InviteId) {
        this.Resolve("//acceptRealmInvite" . UrlParams("inviteId", InviteId)).Run()
    }

    static OpenRealmsStories(RealmId) {
        this.Resolve("//openRealmsStories" . UrlParams("realmId", RealmId)).Run()
    }

    static Import(Filename, FromTempFile := false) {
        this.Resolve("/" . UrlParams("import", Filename, "fromtempfile", FromTempFile)).Run()
    }

    static Load(LevelId) {
        this.Resolve("/" . UrlParams("load", LevelId)).Run()
    }
}

class AquaHotkey_UrlParams extends AquaHotkey {
    class Uri {
        WithUrlParams(Args*) {
            ; TODO good enough. Will replace this with a data structure for
            ; URL params, and then add to lib
            return this.Resolve("./" . UrlParams(Args*))
        }

        UrlParams {
            get {
                if (ObjHasOwnProp(this, "__Class")) {
                    throw PropertyError("Cannot be called by a prototype")
                }

                Result := Array()
                loop parse this.Query, "&" {
                    Index := InStr(A_LoopField, "=")
                    Result.Push(Entry(
                        UrlDecode(SubStr(A_LoopField, 1, Index - 1)),
                        UrlDecode(SubStr(A_LoopField, Index + 1))
                    ))
                }
                ({}.DefineProp)(this, "UrlParams", {
                    Get: (_) => Result.Clone()
                })
                return Result
            }
        }
    }
}

IsPrimitive(Val) {
    static Primitive_Prototype := ObjGetBase(ObjGetBase(""))
    return !IsObject(Val) && HasBase(Val, Primitive_Prototype)
}

class UrlParam extends Entry {
    __New(Key, Value) {
        if (!IsPrimitive(Key)) {
            throw TypeError("Expected a String",, Type(Key))
        }
        if (!IsPrimitive(Value)) {
            throw TypeError("Expected a String",, Type(Value))
        }
        super.__New(Key, Value)
    }

    ToString() => UrlEncode(this.Key) . "=" . UrlEncode(this.Value)
}

UrlParams(Args*) {
    if (Args.Length & 1) {
        throw ValueError("invalid param length",, Args.Length)
    }
    Enumer := Args.__Enum(1)
    Str := ""
    if (!Enumer(&Key) || !Enumer(&Value)) {
        return Str
    }
    Str .= "?"
    Str .= UrlEncode(Key)
    Str .= "="
    Str .= UrlEncode(Value)

    while (Enumer(&Key) && Enumer(&Value)) {
        Str .= "&"
        Str .= UrlEncode(Key)
        Str .= "="
        Str .= UrlEncode(Value)
    }
    return Str
}

; Minecraft.ConnectToLocalWorld("My World")
