#Requires AutoHotkey v2.0

#Include <AquaHotkeyX>
#Include <AquaHotkey\src\Parse\Parser>

; TODO use MAX_PATH as contraint?

class Path2 {
    static TryParse(Str, &Out) {
        static DriveLetter := Parser.One(IsAlpha, "drive letter")
        static Backslash := Parser.One(S => (S ~= "[\\/]"), "backslash")
        static Regex_NameChars := "[^\x{00}-\x{1F}<>:`"/\\|?*]+"
        static NameChars := Parser.Regex(Regex_NameChars).SuchThat(IsValidName)

        static IsValidName(Str)
            => !(Str ~= "^(?:CON|PRN|AUX|NUL|(?:COM|LPT)[1-9¹²³])") ; reserved
            && !(Str ~= "\.$") ; trailing dot
        
        static WithBaseClass(Cls) {
            return (Value*) => { base: Cls.Prototype, Value: Value }
        }

        ServerName := NameChars
        ShareName := NameChars

        FileName := NameChars

        DirectoryName := NameChars

        DirectoryList := DirectoryName
            .AtLeastOnceDelimitedBy(Backslash)
            .OptionallyFollowedBy(Backslash)

        RelPath := (DirectoryList.OptionallyFollowedBy(FileName)).Or(FileName)

        UncPath := Parser.Sequence(WithBaseClass(CreateClass(Object, "Unc")),
            Parser.String("\\").Then(ServerName),
            Backslash.Then(ShareName),
            RelPath.Optional()
        )

        DriveAbsolutePath := Parser.Sequence(WithBaseClass(CreateClass(Object, "AbsPath")),
            DriveLetter.FollowedBy(":").FollowedBy(Backslash),
            RelPath.Optional()
        )

        AbsPath := DriveAbsolutePath.Or(UncPath)
        Path := AbsPath.Or(RelPath).FollowedBy(Parser.End())

        Out := Str.Parse(Path)
        return true
    }

    static Call(Str) {
        if (IsObject(Str) || !(Str is String)) {
            throw TypeError("Expected a String",, Type(Str))
        }
        if (!this.TryParse(Str, &Out)) {
            ; TODO throw `Out` itself
            throw ValueError("unable to parse path",, Str)
        }
        return Out
    }
}

Path2("C:\Windows\System32\Foo").ToString().MsgBox()