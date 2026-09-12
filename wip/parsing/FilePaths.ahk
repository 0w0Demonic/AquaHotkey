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

    ; TODO File[Get|Set]... methods here

    /**
     * Returns the path for a new temporary file.
     *
     * @returns {Path}
     */
    static CreateTempFile() {
        throw Error("not yet implemented")
    }

    /**
     * Returns the path for a new temporary directory.
     *
     * @returns {Path}
     */
    static CreateTempDir() {
        throw Error("not yet implemented")
    }

    static CreateDir(Str) {

    }

    static CreateFile(Str) {

    }

    static CreateSymLink() {

    }

    /**
     * Determines whether this path exists on the filesystem.
     *
     * @readonly
     * @type {Boolean}
     */
    Exists {
        get {
            throw Error("not yet implemented")
        }
    }

    /**
     * Returns an {@link Enumerator} 
     */
    static Find(Spec) {
        ; check whether Spec is valid with `PathIsFileSpec`, then use
        ; that to iterate lazily
        ;
        ; NOTE: might need to create a special
        ; `class FileEnumerator extends Enumerator` with `.__Delete()` method
        ;
        throw Error("not yet implemented")
    }

    /**
     * Creates a new {@link Path} from a {@link Uri}.
     *
     * The input valid must be a `Uri` that has either no scheme, or a scheme
     * equal to `file://`.
     *
     * @param   {Uri}  UriObj  URI file path
     * @returns {Path}
     */
    static FromUri(UriObj) {
        throw Error("not yet implemented")
    }

    ToUri() {
        throw Error("not yet implemented")
    }

    IsAbsolute {
        get {
            throw Error("not yet implemented")
        }
    }

    IsRelative {
        get {
            throw Error("not yet implemented")
        }
    }

    Open(Flags := "r", Encoding?) {
        ; return FileOpen(this.Value, Flags, Encoding?)
    }

    IsFile {
        get {

        }
    }

    IsDirectory {
        get {

        }
    }

    ToString() {
        throw Error("not yet implemented")
    }

    Compare(Other) {
        throw Error("not yet implemented")
    }

    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!(Other is Path2)) {
            return false
        }
        throw Error("not yet implemented")
    }

    HashCode() {
        throw Error("not yet implemented")
    }

    Parent {
        get {
            throw Error("not yet implemented")
        }
    }

    WithParent(Parent) {
        throw Error("not yet implemented")
    }

    Normalize() {
        throw Error("not yet implemented")
    }

    Relativize(Other) {
        throw Error("not yet implemented")
    }

    Resolve(Other) {
        throw Error("not yet implemented")
    }

    ResolveSymLink() {
        throw Error("not yet implemented")
    }

    Children {
        get {
            ObjSetBase(Enumer, Enumerator.Prototype)
            return Enumer

            Enumer(&OutValue) {
                throw Error("not yet implemented")
            }
        }
    }

    Walk(Spec?) {

    }

    ;@region Misc

    Encrypt() {

    }

    Decrypt() {

    }

    ;@endregion
}

class AquaHotkey_Path extends AquaHotkey {
    class File {
        Path {
            get {

            }
        }
    }

    class Uri {
        ToPath() {

        }

        static FromPath(PathObj) {

        }
    }
}

class AquaHotkey_FileTransactions extends AquaHotkey {
    class File {
        /**
         * 
         */
        static CreateTransaction(Action) {
            GetMethod(Action,, 1)
            throw Error("not yet implemented")
        }
    }
}

Path2("C:\Windows\System32\Foo").ToString().MsgBox()

