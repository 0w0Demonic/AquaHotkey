#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Base\Eq.ahk"
#Include "%A_LineFile%\..\..\Base\Hash.ahk"

; TODO
; - fit URL percent encoding into this, somehow. Make it fast.
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
     * Opens the resource represented by the given string.
     * 
     * @param   {String}  Str  string representing a resource
     * @returns {Any}
     */
    static Open(Str) => this(Str).Open()

    /**
     * Opens the resource. Subclases should override this method, if needed.
     * 
     * @returns {Any}
     */
    Open() => Run(String(this))

    /**
     * Determines whether the resource represented by the given string exists.
     * 
     * @param   {Uri}  Res  the given resource
     * @returns {Boolean}
     */
    static Exists(Res) {
        throw MethodError("not implemented")
    }

    /**
     * Determines whether this resource exists. Subclasses should override this
     * method.
     * 
     * @returns {Boolean}
     */
    Exists() {
        throw MethodError("not implemented")
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
                    ValidateScheme(Key)
                    ValidateUriSubclass(Value)
                }
                (Map.Prototype.Set)(M, Values*)
            }

            __Item_set(MapObj, Value, Key) {
                ValidateScheme(Key)
                ValidateUriSubclass(Value)
            }

            ValidateScheme(Key) {
                if (!(Key is String)) {
                    throw TypeError("Expected a String",, Type(Key))
                }
                if (!(Key ~= "i)^[a-z][a-z0-9+.-]*$")) {
                    throw ValueError("invalid scheme",, Key)
                }
            }

            ValidateUriSubclass(Cls) {
                if (!(Cls is Class)) {
                    throw TypeError("Expected a Class",, Type(Cls))
                }
                if (!HasBase(Cls, Uri)) {
                    throw TypeError("Expected a subclass of Uri",,
                                    Cls.Prototype.__Class)
                }
            }
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
     * @constructor
     * @param   {String}  
     * @returns {Uri}
     * @see {@link https://en.wikipedia.org/wiki/Uniform_Resource_Identifier Wikipedia}
     */
    static Call(Str) {
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

        local p, q, ; index values
              r,    ; result object
              t,    ; type of object based on `Scheme`, if applicable
              n,    ; `StrLen(Str) + 1`
              e     ; start index of malformed URI sequence, if applicable

        if (this != Uri) {
            throw MethodError("Method must be called directly by Uri class")
        }
        
        if (!(Str is String)) {
            throw TypeError("Expected a String",, Type(Str))
        }

        ; check for invalid sequences
        e := (Str ~= INVALID_SEQUENCES)
        if (e) {
            BadChar := SubStr(Str, e, 1)
            if (BadChar == "%") {
                throw ValueError("bad percent escape at #" . e, -2,
                                    SubStr(Str, e, 3))
            } else {
                throw ValueError("invalid char at #" . e, -2, BadChar)
            }
        }
        ; normalize percent-encoding to uppercase
        Str := RegExReplace(Str, "i)(?<=%)[0-9a-f]{2}", "$U0")

        ; initialize result object with `Value` prop (entire URI string)
        r := Object()
        ObjSetBase(r, Uri.Prototype)

        ; try to find scheme (the part before ":")
        n := StrLen(Str) + 1
        p := InStr(Str, ":")
        if (p) {
            ; scheme found; try to find handler OR perform validation.
            ; there's no need to validate if the scheme is part of the map.
            Scheme := SubStr(Str, 1, p - 1)
            t := (Uri.Types).Get(Scheme, false)
            if (t) {
                ObjSetBase(r, t.Prototype)
            } else if (!(Scheme ~= VALID_SCHEME)) {
                throw ValueError("invalid scheme",, Scheme)
            } else {
                ObjSetBase(r, Uri.Prototype)
            }
            r.DefineProp("Scheme", { Get: (_) => Scheme })
            p++ ; skip ":"

            ; does URI define a path?
            if (SubStr(Str, p, 1) == "/") {
                ParseHierarchy()
            } else {
                ; parse until fragment (can't be next char directly)
                q := InStr(Str, "#", unset, p) || n
                if (q == p) {
                    throw ValueError("expected scheme-specific part")
                }

                ; the scheme-specific part of the URI
                Spec := SubStr(Str, p, q - p)
                r.DefineProp("SchemeSpecificPart", { Get: (_) => Spec })
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
                throw ValueError('invalid char "#" in fragment',, Frag)
            }
            r.DefineProp("Fragment", { Get: (_) => Frag })
        }
        return r

        ; [//authority]<path>[?<query>]
        ParseHierarchy() {
            ; authority (optional)
            if (SubStr(Str, p, 2) == "//") {
                p += 2
                q := RegExMatch(Str, "[/?#]", unset, p) || n
                Authority := SubStr(Str, p, q - p)
                r.DefineProp("Authority", { Get: (_) => Authority })
                p := q
            }
            ; path (terminates on either query "?" or fragment "#")
            q := RegExMatch(Str, "[?#]", unset, p) || n
            Path := SubStr(Str, p, q - p)
            r.DefineProp("Path", { Get: (_) => Path })
            p := q

            ; query
            if (SubStr(Str, p, 1) == "?") {
                p++
                q := InStr(Str, "#", unset, p) || n
                Query := SubStr(Str, p, q - p)
                r.DefineProp("Query", { Get: (_) => Query })
                p := q
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region URI Components
    
    /**
     * The URI scheme.
     * 
     * @abstract
     * @property {String}
     */
    Scheme => ""

    /**
     * The scheme-specific part for non-hierarchical URIs.
     * 
     * @abstract
     * @property {String}
     */
    SchemeSpecificPart => ""

    /**
     * The authority of the URI.
     * 
     * @abstract
     * @property {String}
     */
    Authority => ""

    /**
     * Path defined by the URI.
     * 
     * @abstract
     * @property {String}
     */
    Path => ""

    /**
     * The URI query.
     * 
     * @abstract
     * @property {String}
     */
    Query => ""

    /**
     * The URI fragment.
     * 
     * @abstract
     * @property {String}
     */
    Fragment => ""

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Value Presence

    /**
     * Determines whether this URI has a defined scheme.
     * 
     * @property {Boolean}
     */
    HasScheme => ObjHasOwnProp(this, "Scheme")

    /**
     * Determines whether this URI has a defined scheme-specific part.
     * 
     * @property {Boolean}
     */
    HasSchemeSpecificPart => ObjHasOwnProp(this, "SchemeSpecificPart")

    /**
     * Determines whether this URI has a defined authority.
     * 
     * @property {Boolean}
     */
    HasAuthority => ObjHasOwnProp(this, "Authority")

    /**
     * Determines whether this URI has a defined path.
     * 
     * @property {Boolean}
     */
    HasPath => ObjHasOwnProp(this, "Path")

    /**
     * Determines whether this URI has a defined query.
     * 
     * @property {Boolean}
     */
    HasQuery => ObjHasOwnProp(this, "Query")

    /**
     * Determines whether this URI has a defined fragment.
     * 
     * @property {Boolean}
     */
    HasFragment => ObjHasOwnProp(this, "Fragment")

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
            Str .= this.Scheme
            Str .= ":"
        }
        if (this.IsOpaque) {
            Str .= this.SchemeSpecificPart
        } else {
            if (this.HasAuthority) {
                Str .= "//"
                Str .= this.Authority
            }
            if (this.HasPath) {
                Str .= this.Path
            }
            if (this.HasQuery) {
                Str .= "?"
                Str .= this.Query
            }
        }
        if (this.HasFragment) {
            Str .= "#"
            Str .= this.Fragment
        }
        this.DefineProp("ToString", { Call: (_) => Str })
        return Str
    }

    /**
     * Returns a detailed string representation of the URI.
     * 
     * @returns {String}
     */
    ToDebugString() => (Object.Prototype.ToString)({
        Value: this.ToString(),
        Scheme: this.Scheme,
        SchemeSpecificPart: this.SchemeSpecificPart,
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
            return this.SchemeSpecificPart == Other.SchemeSpecificPart
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
        Result ^= this.HasFragment && this.Query.Fragment()
        Result *= Prime

        if (this.IsOpaque) {
            ; scheme-specific part
            Result ^= this.SchemeSpecificPart
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
        
        NormalizedPath := Uri.NormalizePath(this.Path)
        if (NormalizedPath == this.Path) {
            return this
        }
        
        Result := this.Clone()
        Result.DefineProp("Path", { Get: (_) => NormalizedPath })
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

        ThisPath := Uri.NormalizePath(this.Path)
        OtherPath := Uri.NormalizePath(Other.Path)

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
        Result := Object()
        ObjSetBase(Result, Uri.Prototype)
        Path := SubStr(OtherPath, Len + 1)
        Result.DefineProp("Path", { Get: (_) => Path })

        if (Other.HasQuery) {
            Query := Other.Query
            Result.DefineProp("Query", { Get: (_) => Query })
        }
        if (Other.HasFragment) {
            Fragment := Other.Fragment
            Result.DefineProp("Fragment", { Get: (_) => Fragment })
        }
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
            Result := this.Clone()    
            Frag := Other.Fragment
            Result.DefineProp("Fragment", { Get: (_) => Frag })
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
            Result := Other.Clone()
            Result.DeleteProp("Scheme")
            if (this.HasScheme) {
                Scheme := this.Scheme
                Result.DefineProp("Scheme", { Get: (_) => Scheme })
                ObjSetBase(Result, ObjGetBase(this))
            } else {
                ObjSetBase(Result, Uri.Prototype)
            }
            return Result
        }

        ; only query, fragment and path are different from the current URI.
        Result := this.Clone()
        Result.DeleteProp("Query")
        Result.DeleteProp("Fragment")
        if (Other.HasQuery) {
            Query := Other.Query
            Result.DefineProp("Query", { Get: (_) => Query })
        }
        if (Other.HasFragment) {
            Fragment := Other.Fragment
            Result.DefineProp("Fragment", { Get: (_) => Fragment })
        }

        Path := Other.Path
        if (SubStr(Path, 1, 1) == "/") {
            ; path is absolute
            Result.DefineProp("Path", { Get: (_) => Path })
            return Result
        }

        ; resolve relative path
        Path := Uri.ResolvePath(this.Path, Other.Path, this.IsAbsolute)

        Result.DefineProp("Path", { Get: (_) => Path })
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
         * Coerces this string into a {@link Resource} and opens it.
         * 
         * @returns {Any}
         */
        Open() => Uri(this).Open()

        /**
         * Coerces this string into a {@link Resource} and determines whether
         * it exists.
         * 
         * @returns {Boolean}
         */
        Exists() => Uri(this).Exists()

        /**
         * Converts this string into a {@link Resource}.
         * 
         * @returns {Uri}
         */
        ToUri() => Uri(this)
    }
}

;@endregion
