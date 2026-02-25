#Include <AquaHotkeyX>

;@region URI

/**
 * Represents a unified resource identifier which is a sequence of characters
 * that identifies an abstract or physical resource.
 * 
 * @module  <Net/HashSet>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class URI {
    ;@region Registering

    static __New() {
        if (this == URI) {
            return
        }
        for Scheme in this.Schemes {
            (URI.Types).Set(Scheme, this)
        }
    }

    /**
     * Map that holds schemes mapped to their resource handlers.
     * 
     * @readonly
     * @property {Map<String, URI>}
     */
    static Types {
        get {
            ; TODO probably remove this again to get rid of mutual dep
            ; evil magic
            static Types := Map.OfType(
                InstanceOf(String).And(RegExMatch, "i)^[a-z][a-z0-9+.-]*$"),
                (Val) => HasBase(Val, URI)
            )()
            return Types
        }
    }

    /**
     * Returns the schemes supported by this class. Subclasses should override
     * this property.
     * 
     * @abstract
     * @readonly
     * @property {Array}
     */
    static Schemes => []

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Construction

    ; TODO make the calling class relevant
    /**
     * Creates a new URI by parsing the given string.
     * 
     * @constructor
     * @param   {String}  
     * @returns {URI}
     * @see {@link https://en.wikipedia.org/wiki/Uniform_Resource_Identifier Wikipedia}
     */
    static Call(Str) {
        static VALID_SCHEME := "Si)^[a-z][a-z+.-]*$"
        static INVALID_CHARS  := "i)[^\w.!~*'();/?:@&=+$,[\]%-]"
        local p, q, ; index values
              r,    ; result object
              t     ; type of object based on `Scheme`, if applicable

        if (this != URI) {
            throw MethodError("Method must be called directly by URI class")
        }

        if (!(Str is String)) {
            throw TypeError("Expected a String",, Type(Str))
        }

        r := Object()
        ObjSetBase(r, URI.Prototype)
        r.DefineProp("Value", { Get: (_) => Str })

        n := StrLen(Str) + 1
        p := InStr(Str, ":")
        if (p) {
            Scheme := SubStr(Str, 1, p - 1)
            t := URI.Types.Get(Scheme, false)
            if (t) {
                ObjSetBase(r, t.Prototype)
            } else if (!(Scheme ~= VALID_SCHEME)) {
                throw ValueError("invalid scheme",, Scheme)
            } else {
                ObjSetBase(r, URI.Prototype)
            }
            r.DefineProp("Scheme", { Get: (_) => Scheme })

            p++ ; skip ":"
            if (SubStr(Str, p, 1) == "/") {
                ParseHierarchy()
            } else {
                q := InStr(Str, "#", unset, p) || n
                if (q == p) {
                    throw ValueError("expected scheme-specific part")
                }
                Spec := SubStr(Str, p, q - p)
                Check(Spec ~= INVALID_CHARS)
                r.DefineProp("SchemeSpecificPart", { Get: (_) => Spec })
            }
        } else {
            p++
            ParseHierarchy()
        }
        if (SubStr(Str, p, 1) == "#") {
            Frag := SubStr(Str, p + 1)
            Check(Frag ~= INVALID_CHARS)
            r.DefineProp("Fragment", { Get: (_) => Frag })
        }
        return r

        ParseHierarchy() {
            if (SubStr(Str, p, 2) == "//") {
                p += 2
                q := RegExMatch(Str, "[/?#]", unset, p) || n
                Authority := SubStr(Str, p, q - p)
                Check(Authority ~= INVALID_CHARS)
                r.DefineProp("Authority", { Get: (_) => Authority })
                p := q
            }
            q := RegExMatch(Str, "[?#]", unset, p) || n
            Path := SubStr(Str, p, q - p)
            r.DefineProp("Path", { Get: (_) => Path })
            p := q
            if (SubStr(Str, p, 1) == "?") {
                p++
                q := InStr(Str, "#", unset, p) || n
                Query := SubStr(Str, p, q - p)
                Check(Query ~= INVALID_CHARS)
                r.DefineProp("Query", { Get: (_) => Query })
                p := q
            }
        }

        Check(Pos) {
            if (Pos) {
                throw ValueError("invalid char at #" . Pos,,
                                SubStr(Str, Pos, 1))
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Properties
    
    /**
     * The complete URI as string.
     * 
     * @abstract
     * @property {String}
     */
    Value => ""

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

    /**
     * Determines whether this URI is absolute. A URI is absolute whenever
     * it defines a scheme.
     * 
     * @readonly
     * @property {Boolean}
     */
    IsAbsolute => (this.Scheme != "")

    /**
     * Determines whether this URI is opaque. A URI is considered opaque if the
     * scheme-specific part does not start with a forward slash character.
     * 
     * @readonly
     * @property {Boolean}
     */
    IsOpaque => (this.Path == "")

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Commons

    /**
     * Returns a string representation of the URI.
     * 
     * @returns {String}
     */
    ToString() => (this.Value)

    /**
     * Returns a detailed string representation of the URI.
     * 
     * @returns {String}
     */
    ToDebugString() => (Object.Prototype.ToString)({
        Value: this.Value,
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
    ;@region Methods

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
    Open() => Run(this.Value)

    /**
     * Determines whether the resource represented by the given string exists.
     * 
     * @param   {URI}  Res  the given resource
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

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Handler Impl

class HierarchicalUri extends URI {
    static Schemes => []

    Resolve(Str) {

    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

class AquaHotkey_URI extends AquaHotkey {
    class String {
        /**
         * Coerces this string into a {@link Resource} and opens it.
         * 
         * @returns {Any}
         */
        Open() => URI(this).Open()

        /**
         * Coerces this string into a {@link Resource} and determines whether it
         * exists.
         * 
         * @returns {Boolean}
         */
        Exists() => URI(this).Exists()

        /**
         * Converts this string into a {@link Resource}.
         * 
         * @returns {URI}
         */
        ToUri() => URI(this)
    }
}

;@endregion

; URI {
;   Authority: "",
;   Fragment: "frag",
;   Path: "/a/b/../c",
;   Query: "key=value",
;   Scheme: "",
;   SchemeSpecificPart: "",
;   Value: "/a/b/../c?key=value#frag"
; }

URI("/a/b/../c?key=value#frag")
    .ToDebugString()
    .ToClipboard()
