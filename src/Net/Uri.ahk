#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Base\Eq.ahk"
#Include "%A_LineFile%\..\..\Base\Hash.ahk"
#Include "%A_LineFile%\..\UrlEncoding.ahk"

; TODO
; - find a way to make URIs comparable

;@region Uri

/**
 * Represents a unified resource identifier which is a sequence of characters
 * that identifies an abstract or physical resource.
 * 
 * This class is a simplified rewrite of `java.net.URI`, and follows the same
 * logic. Parsing authorities into smaller parts is not supported.
 * 
 * @module  <Net/HashSet>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @see {@link https://docs.oracle.com/en/java/javase/24/docs/api/java.base/java/net/URI.html `java.net.URI`}
 */
class Uri {
    ;@region Uri Handlers

    static __New() {
        for Scheme in this.Schemes {
            (Uri.Types).Set(Scheme, this)
        }
    }

    /**
     * Map that holds schemes mapped to their resource handlers.
     * 
     * @readonly
     * @property {Map<String, Uri>}
     */
    static Types {
      get {
        static Types := Init()
        return Types

        static Init() {
            M := Map()
            M.CaseSense := false
            M.DefineProp("Set", { Call: Set })
            M.DefineProp("__Item", { Set: __Item_set })
            return M

            Set(MapObj, Values*) {
                if (Values.Length & 1) {
                    throw ValueError("invalid param count",, Values.Length)
                }
                Enumer := Values.__Enum(1)
                while (Enumer(&Key) && Enumer(&Value)) {
                    if (!(Key is String)) {
                        throw TypeError("Expected a String",, Type(Key))
                    }
                    if (!(Key ~= "i)^[a-z][a-z0-9+.-]*$")) {
                        throw ValueError("invalid scheme",, Key)
                    }
                    if (!(Value is Class)) {
                        throw TypeError("Expected a Class",, Type(Value))
                    }
                    if (!HasBase(Value, Uri)) {
                        throw TypeError("Expected a subclass of Uri",,
                                        Value.Prototype.__Class)
                    }
                }
                (Map.Prototype.Set)(M, Values*)
            }

            __Item_set(MapObj, Value, Key) => Set(MapObj, Key, Value)
        }
      }
    }

    /**
     * Returns the schemes supported by this class. Subclasses should override
     * this property.
     * 
     * @abstract
     * @readonly
     * @property {Enumerable1}
     * @example
     * class MailUri extends Uri {
     *     static Schemes => ["mailto"]
     * }
     * class FileUri extends Uri {
     *     static Schemes => ["file"]
     * }
     */
    static Schemes => []

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Construction

    /**
     * Creates a new Uri by parsing the given string into separate URI
     * components. This method performs input validation and normalization of
     * percent escapes (such as `%fa` into `%FA`), but no URL encoding/decoding
     * is done.
     * 
     * Parameter #2 is internal and meant for serialization support; avoid
     * using it.
     * 
     * @constructor
     * @param   {String}   Str  string that represents a URI
     * @param   {Object?}  r    plain object that should be constructed
     * @returns {Uri}
     * @see {@link https://en.wikipedia.org/wiki/Uniform_Resource_Identifier Wikipedia}
     */
    static Call(Str) {
        if (this.TryParse(Str, &Out)) {
            return Out
        }
        throw Out
    }

    /**
     * Creates a new Uri by parsing the given string.
     * 
     * @param   {String}  Str  string that represents a URI
     * @see {@link Uri()}
     * @returns {Uri}
     */
    static Parse(Str) => this(Str)

    /**
     * Attempts to parse a URI string into separate components, outputting
     * either an instance of {@link Uri} or an {@link Error} into `&Out`.
     * Returns `true` on success, otherwise `false`.
     * 
     * @param   {String}             Str  string that represents a URI
     * @param   {VarRef<Uri|Error>}  Out  (out) output Uri or Error
     * @returns {Boolean}
     */
    static TryParse(Str, &Out) {
        static VALID_SCHEME      := "Si)^[a-z][a-z+.-]*$"
        static INVALID_SEQUENCES := "
        (
        Six)
        (?(DEFINE)
          (?<hex> [0-9a-f] )                         # hex chars
          (?<badChar> [^\w.!~*'();/?:@&=+$,[\]%#-] ) # invalid Uri char
          (?<badEscape> % (?! (?&hex){2} ) ))        # invalid percent escapes

        # pattern start
        (?&badChar) | (?&badEscape)
        )"

        if (this != Uri) {
            Out := MethodError("Method must be called directly by Uri class")
            return false
        }
        if (!(Str is String)) {
            Out := TypeError("Expected a String",, Type(Str))
            return false
        }

        ; check for invalid sequences
        e := (Str ~= INVALID_SEQUENCES)
        if (e) {
            BadChar := SubStr(Str, e, 1)
            if (BadChar == "%") {
                Out := ValueError("bad percent escape at #" . e, -2,
                                    SubStr(Str, e, 3))
            } else {
                Out := ValueError("invalid char at #" . e, -2, BadChar)
            }
            return false
        }
        ; normalize percent-encoding to uppercase
        Str := RegExReplace(Str, "i)(?<=%)[0-9a-f]{2}", "$U0")

        ; start of construction. first, define a base object to hold primary
        ; fields (raw parts), then the actual result object as deriving object
        ; that contains all other properties through lazy init.
        b := Object()
        r := Object()
        ObjSetBase(b, Uri.Prototype)
        ObjSetBase(r, b)

        ; try to find scheme (the part before ":")
        n := StrLen(Str) + 1
        p := InStr(Str, ":")
        if (p) {
            ; scheme found; try to find handler OR perform validation.
            ; there's no need to validate if the scheme is part of the map.
            Scheme := SubStr(Str, 1, p - 1)
            t := (Uri.Types).Get(Scheme, false)
            if (t) {
                ObjSetBase(b, t.Prototype)
            } else if (!(Scheme ~= VALID_SCHEME)) {
                Out := ValueError("invalid scheme",, Scheme)
                return false
            }
            b.DefineProp("RawScheme", { Get: (_) => Scheme })
            p++ ; skip ":"

            ; does URI define a path?
            if (SubStr(Str, p, 1) == "/") {
                ParseHierarchy()
            } else {
                ; parse until fragment (can't be next char directly)
                q := InStr(Str, "#", unset, p) || n
                if (q == p) {
                    Out := ValueError("expected scheme-specific part")
                    return false
                }

                ; the scheme-specific part of the URI
                Spec := SubStr(Str, p, q - p)
                b.DefineProp("RawSchemeSpecific", { Get: (_) => Spec })
            }
        } else {
            ; no scheme was found; try to parse path / authority
            p++
            ParseHierarchy()
        }
        ; fragment "#" until end
        if (SubStr(Str, p, 1) == "#") {
            Frag := SubStr(Str, p + 1)
            if (InStr(Frag, "#")) {
                Out := ValueError('invalid char "#" in fragment',, Frag)
                return false
            }
            b.DefineProp("RawFragment", { Get: (_) => Frag })
        }
        Out := r
        return true

        ; [//authority]<path>[?<query>]
        ParseHierarchy() {
            ; authority (optional)
            if (SubStr(Str, p, 2) == "//") {
                p += 2
                q := RegExMatch(Str, "[/?#]", unset, p) || n
                Authority := SubStr(Str, p, q - p)
                b.DefineProp("RawAuthority", { Get: (_) => Authority })
                p := q
            }
            ; path (terminates on either query "?" or fragment "#")
            q := RegExMatch(Str, "[?#]", unset, p) || n
            Path := SubStr(Str, p, q - p)
            b.DefineProp("RawPath", { Get: (_) => Path })
            p := q

            ; query
            if (SubStr(Str, p, 1) == "?") {
                p++
                q := InStr(Str, "#", unset, p) || n
                Query := SubStr(Str, p, q - p)
                b.DefineProp("RawQuery", { Get: (_) => Query })
                p := q
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Raw URI Components

    /**
     * The raw URI scheme.
     * 
     * @abstract
     * @property {String}
     */
    RawScheme => ""

    /**
     * The raw scheme-specific part for non-hierarchical URIs.
     * 
     * @abstract
     * @property {String}
     */
    RawSchemeSpecific => ""

    /**
     * The raw authority of the URI.
     * 
     * @abstract
     * @property {String}
     */
    RawAuthority => ""

    /**
     * The raw path defined by the URI.
     * 
     * @abstract
     * @property {String}
     */
    RawPath => ""

    /**
     * The raw URI query.
     * 
     * @abstract
     * @property {String}
     */
    RawQuery => ""

    /**
     * The raw URI fragment.
     * 
     * @abstract
     * @property {String}
     */
    RawFragment => ""

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region URI Components
    
    /**
     * The URI scheme.
     * 
     * @abstract
     * @property {String}
     */
    Scheme {
      get {
        Str := UrlDecode(this.RawScheme)
        this.DefineProp("Scheme", { Get: (_) => Str })
        return Str
      }
    }

    /**
     * The scheme-specific part for non-hierarchical URIs.
     * 
     * @abstract
     * @property {String}
     */
    SchemeSpecific {
      get {
        Str := UrlDecode(this.RawSchemeSpecific)
        this.DefineProp("SchemeSpecific", { Get: (_) => Str })
        return Str
      }
    }

    /**
     * The authority of the URI.
     * 
     * @abstract
     * @property {String}
     */
    Authority {
      get {
        Str := UrlDecode(this.RawAuthority)
        this.DefineProp("Authority", { Get: (_) => Str })
        return Str
      }
    }

    /**
     * Path defined by the URI.
     * 
     * @abstract
     * @property {String}
     */
    Path {
      get {
        Str := UrlDecode(this.RawPath)
        this.DefineProp("Path", { Get: (_) => Str })
        return Str
      }
    }

    /**
     * The URI query.
     * 
     * @abstract
     * @property {String}
     */
    Query {
      get {
        Str := UrlDecode(this.RawQuery)
        this.DefineProp("Query", { Get: (_) => Str })
        return Str
      }
    }

    /**
     * The URI fragment.
     * 
     * @abstract
     * @property {String}
     */
    Fragment {
      get {
        Str := UrlDecode(this.RawFragment)
        this.DefineProp("Fragment", { Get: (_) => Str })
        return Str
      }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Value Presence

    /**
     * Determines whether this URI has a defined scheme.
     * 
     * @property {Boolean}
     */
    HasScheme => ObjHasOwnProp(ObjGetBase(this), "RawScheme")

    /**
     * Determines whether this URI has a defined scheme-specific part.
     * 
     * @property {Boolean}
     */
    HasSchemeSpecific => ObjHasOwnProp(ObjGetBase(this), "RawSchemeSpecific")

    /**
     * Determines whether this URI has a defined authority.
     * 
     * @property {Boolean}
     */
    HasAuthority => ObjHasOwnProp(ObjGetBase(this), "RawAuthority")

    /**
     * Determines whether this URI has a defined path.
     * 
     * @property {Boolean}
     */
    HasPath => ObjHasOwnProp(ObjGetBase(this), "RawPath")

    /**
     * Determines whether this URI has a defined query.
     * 
     * @property {Boolean}
     */
    HasQuery => ObjHasOwnProp(ObjGetBase(this), "RawQuery")

    /**
     * Determines whether this URI has a defined fragment.
     * 
     * @property {Boolean}
     */
    HasFragment => ObjHasOwnProp(ObjGetBase(this), "RawFragment")

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region URI Properties

    /**
     * Determines whether this URI is absolute. A URI is absolute whenever
     * it defines a scheme.
     * 
     * @readonly
     * @property {Boolean}
     */
    IsAbsolute => this.HasScheme

    /**
     * Determines whether this URI is opaque. A URI is considered opaque if the
     * scheme-specific part does not start with a forward slash character.
     * 
     * @readonly
     * @property {Boolean}
     */
    IsOpaque => !this.HasPath

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region String Features

    /**
     * Returns a string representation of this URI.
     * 
     * @returns {String}
     */
    ToString() {
        Str := ""
        if (this.HasScheme) {
            Str .= this.RawScheme
            Str .= ":"
        }
        if (this.IsOpaque) {
            Str .= this.RawSchemeSpecific
        } else {
            if (this.HasAuthority) {
                Str .= "//"
                Str .= this.RawAuthority
            }
            if (this.HasPath) {
                Str .= this.RawPath
            }
            if (this.HasQuery) {
                Str .= "?"
                Str .= this.RawQuery
            }
        }
        if (this.HasFragment) {
            Str .= "#"
            Str .= this.RawFragment
        }
        Str := UrlDecode(Str)
        this.DefineProp("ToString", { Call: (_) => Str })
        return Str
    }

    /**
     * Returns a detailed string representation of the URI.
     * 
     * @returns {String}
     */
    ToDebugString() => (Object.Prototype.ToString)({
        Value: String(this),
        Scheme: this.Scheme,
        SchemeSpecific: this.SchemeSpecific,
        Authority: this.Authority,
        Path: this.Path,
        Query: this.Query,
        Fragment: this.Fragment,
        base: ObjGetBase(this)
    })

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Commons

    /**
     * Determines whether this URI is equal to the `Other` value.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        if (!(Other is URI)) {
            return false
        }
        if (this.IsOpaque != Other.IsOpaque) {
            return false
        }

        ; case-insensitive scheme, fragment
        if (this.HasScheme != Other.HasScheme
         || this.Scheme != Other.Scheme) {
            return false
        }

        if (this.HasFragment != Other.HasFragment
         || this.Fragment !== Other.Fragment) {
            return false
        }

        ; scheme-specific part
        if (this.IsOpaque) {
            return this.SchemeSpecific == Other.SchemeSpecific
        }

        ; path, query, authority
        return (this.HasPath      == Other.HasPath
             && this.HasQuery     == Other.HasQuery
             && this.HasAuthority == Other.HasAuthority
             && this.Path         == Other.Path
             && this.Query        == Other.Query
             && this.Authority    == Other.Authority)
    }

    /**
     * Creates a hash from the components in the URI.
     * 
     * @returns {Integer}
     */
    HashCode() {
        static Offset := AquaHotkey_Hash.Offset
        static Prime  := AquaHotkey_Hash.Prime
        Result := Offset

        ; case-insensitive scheme, fragment
        Result ^= this.Scheme && StrLower(this.Scheme).HashCode()
        Result *= Prime
        Result ^= this.HasFragment && this.Fragment.HashCode()
        Result *= Prime

        if (this.IsOpaque) {
            ; scheme-specific part
            Result ^= this.SchemeSpecific
        } else {
            ; path, query, authority
            Result ^= this.HasPath && this.Path.HashCode()
            Result *= Prime
            Result ^= this.HasQuery && this.Query.HashCode()
            Result *= Prime
            Result ^= this.HasAuthority && this.Authority.HashCode()
            Result *= Prime
        }
        this.DefineProp("HashCode", { Call: (_) => Result })
        return Result
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Serialization

    /**
     * Converts this URI into binary based on its string representation.
     * 
     * @param   {OutputStream}  Output  output stream
     * @param   {Map}           Refs    map of previously seen objects
     * @see {@link AquaHotkey_Serializer}
     */
    Serialize(Output, Refs) {
        (Object.Prototype.Serialize)(this, Output, Refs)
        Str := String(this)
        Output.WriteUInt(StrLen(Str))
        Output.Write(Str)
    }

    /**
     * Reconstructs the URI from binary.
     * 
     * @param   {InputStream}  Input  input stream
     * @param   {Map}          Refs   map of previously seen objects
     * @see {@link AquaHotkey_Serializer}
     */
    Deserialize(Input, Refs) {
        U := Uri( Input.Read( Input.ReadUInt() ) )
        Base := ObjGetBase(U)
        ObjSetBase(U, Object.Prototype)
        ObjSetBase(this, Base)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Normalize()

    /**
     * Returns a normalized version of this URI.
     * 
     * @returns {URI}
     * @example
     * Uri("/a/./b/c/../d").Normalize() ; Uri("/a/b/d")
     */
    Normalize() {
        if (this.IsOpaque || this.Path == "") {
            return this
        }
        
        NormalizedPath := Uri.NormalizePath(this.RawPath)
        if (NormalizedPath == this.RawPath) {
            return this
        }
        
        Base := ObjGetBase(this).Clone()
        Base.DefineProp("RawPath", { Get: (_) => NormalizedPath })
        Result := Object()
        ObjSetBase(Result, Base)
        return Result
    }

    /**
     * Normalizes the path of a URI as string.
     * 
     * @private
     * @param   {String}  Path  URI path
     * @returns {String}
     */
    static NormalizePath(Path) {
        Segs := Array()
        loop parse Path, "/" {
            switch (A_LoopField) {
              case "", ".":
                continue
              case "..":
                if (Segs.Length && Segs[-1] != "..") {
                    Segs.Pop()
                    continue
                }
            }
            Segs.Push(A_LoopField)
        }

        Normalized := ""
        for Seg in Segs {
            if (A_Index != 1 || SubStr(Path, 1, 1) == "/") {
                Normalized .= "/"
            }
            Normalized .= Seg
        }
        if (SubStr(Path, -1, 1) == "/") {
            Normalized .= "/"
        }
        return Normalized
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Relativize()

    /**
     * Returns a new URI whose target is expressed by the given URI, *relative
     * to* the current URI.
     * 
     * @param   {Uri}  Other  other URI
     * @returns {Uri}
     * @example
     * BaseUri := Uri("www.example.com/docs/")
     * Target := Uri("www.example.com/docs/guide/intro.html")
     * 
     * ; --> Uri("guide/intro.html")
     * BaseUri.Relativize(Target)
     */
    Relativize(Other) {
        if (Other is String) {
            Other := Uri(Other)
        }
        if (!(Other is Uri)) {
            throw TypeError("Expected a String or a Uri",, Type(Other))
        }
        if (this.IsOpaque || Other.IsOpaque) {
            return Other
        }
        if ((this.HasScheme != Other.HasScheme)
         || (this.HasAuthority != Other.HasAuthority)
         || (this.Scheme != Other.Scheme) ; case-insensitive
         || (this.Authority !== Other.Authority))
        {
            return Other
        }

        ThisPath := Uri.NormalizePath(this.RawPath)
        OtherPath := Uri.NormalizePath(Other.RawPath)

        Len := StrLen(ThisPath)
        if (ThisPath !== OtherPath) {
            if (SubStr(ThisPath, -1, 1) != "/") {
                ThisPath .= "/"
                ++Len
            }
            if (SubStr(OtherPath, 1, Len) != ThisPath) {
                return Other
            }
        }

        Base := Object()
        ObjSetBase(Base, Uri.Prototype)

        RawPath := SubStr(OtherPath, Len + 1)
        Base.DefineProp("RawPath", { Get: (_) => RawPath })

        if (Other.HasQuery) {
            RawQuery := Other.RawQuery
            Base.DefineProp("RawQuery", { Get: (_) => RawQuery })
        }
        if (Other.HasFragment) {
            RawFragment := Other.RawFragment
            Base.DefineProp("RawFragment", { Get: (_) => RawFragment })
        }
        Result := Object()
        ObjSetBase(Result, Base)
        return Result
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Resolve()

    /**
     * Resolves the other URI against this URI.
     * 
     * @param   {Uri}  Other  other URI
     * @returns {Uri}
     * @example
     * ; fragment in the same document
     * ; --> Uri("/a/b/c.txt"#frag)
     * Uri("/a/b/c.txt").Resolve("#frag")
     * 
     * ; move into different scheme
     * ; --> Uri("https://example.com")
     * Uri("/a/b").Resolve("https://example.com") 
     * 
     * ; copy everything except current scheme
     * ; --> Uri("https://www.github.com")
     * Uri("https://www.google.com").Resolve("//www.github.com")
     * 
     * ; change query, fragment and path
     * ; --> Uri("/a/c?key=value#frag")
     * Uri("/a/b?foo=bar#section").Resolve("../c?key=value#frag")
     */
    Resolve(Other) {
        if (Other is String) {
            Other := Uri(Other)
        }
        if (!(Other is Uri)) {
            throw TypeError("Expected a String or a Uri",, Type(Other))
        }
        if (this.IsOpaque || Other.IsOpaque) {
            return Other
        }

        ; reference to current document
        ; example:
        ; 
        ; Uri("/a/b.txt").Resolve("#frag") ; Uri("/a/b.txt#frag")
        if (!Other.HasScheme && !Other.HasAuthority
                    && (Other.Path == "") && Other.HasFragment)
        {
            Base := ObjGetBase(this).Clone()
            Result := Object()
            ObjSetBase(Result, Base)

            RawFragment := Other.RawFragment
            Base.DefineProp("RawFragment", { Get: (_) => RawFragment })
            return Result
        }

        ; other URI is absolute
        ; example:
        ; 
        ; [...].Resolve("https://...") --> "https://..."
        if (Other.HasScheme) {
            return Other
        }

        ; has authority; copy everything from other URI, except scheme.
        ; example:
        ; 
        ; --> Uri("https://www.github.com")
        ; Uri("https://www.example.com").Resolve("//www.github.com")
        if (Other.HasAuthority) {
            Base := ObjGetBase(Other).Clone()
            Result := Object()
            ObjSetBase(Result, Base)

            Base.DeleteProp("RawScheme")
            if (this.HasScheme) {
                RawScheme := this.RawScheme
                Base.DefineProp("RawScheme", { Get: (_) => RawScheme })
                ObjSetBase(Base, ObjGetBase(this))
            } else {
                ObjSetBase(Base, Uri.Prototype)
            }
            return Result
        }

        ; only query, fragment and path are different from the current URI.
        Base := ObjGetBase(this).Clone()
        Result := Object()
        ObjSetBase(Result, Base)

        Base.DeleteProp("RawQuery")
        Base.DeleteProp("RawFragment")
        if (Other.HasQuery) {
            RawQuery := Other.RawQuery
            Base.DefineProp("RawQuery", { Get: (_) => RawQuery })
        }
        if (Other.HasFragment) {
            RawFragment := Other.RawFragment
            Base.DefineProp("RawFragment", { Get: (_) => RawFragment })
        }

        RawPath := Other.RawPath
        if (SubStr(RawPath, 1, 1) == "/") {
            ; path is absolute
            Base.DefineProp("RawPath", { Get: (_) => RawPath })
            return Result
        }

        ; resolve relative path
        RawPath := Uri.ResolvePath(this.Path, Other.Path, this.IsAbsolute)

        Base.DefineProp("RawPath", { Get: (_) => RawPath })
        return Result
    }

    /**
     * Resolves a relative path.
     * 
     * @private
     * @param   {String}    Base        base path
     * @param   {String}    Child       child path
     * @param   {Boolean?}  IsAbsolute  whether the base path is absolute
     * @returns {String}
     */
    static ResolvePath(Base, Child, IsAbsolute := true) {
        SlashIndex := InStr(Base, "/", unset, unset, -1)
        Len := StrLen(Child)

        Path := ""
        if (Len == 0) {
        } else {
            if (SlashIndex || !IsAbsolute) {
                Path := SubStr(Base, 1, SlashIndex) . Child
            } else {
                Path := "/" . Child
            }
        }
        return Uri.NormalizePath(Path)
    }

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

class AquaHotkey_Uri extends AquaHotkey {
    class String {
        /**
         * Converts this string into a {@link Resource}.
         * 
         * @returns {Uri}
         */
        ToUri() => Uri(this)
    }
}

;@endregion
