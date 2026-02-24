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
        if (!(Str is String)) {
            throw TypeError("Expected a String",, Type(Str))
        }

        Result := Object()
        Result.DefineProp("Value", { Get: (_) => Str })
        
        ; Scheme
        ;   scheme://user:pass@example.org:8182/path/to/file?k=v#frag
        ;   ______v
        Index := InStr(Str, ":")
        if (Index) {
            Scheme := SubStr(Str, 1, Index - 1)
        } else {
            Scheme := ""
        }
        Index += 1

        T := URI.Types.Get(Scheme, false)
        if (T) {
            ObjSetBase(Result, T.Prototype)
        } else if (!(Scheme ~= "i)^[a-z]?[a-z0-9+.-]*$")) {
            MsgBox(Scheme)
            throw ValueError("invalid scheme",, Scheme)
        } else {
            ObjSetBase(Result, URI.Prototype)
        }

        Result.DefineProp("Scheme", { Get: (_) => Scheme })
        End := StrLen(Str) + 1

        IsOpaque := SubStr(Str, Index, 1) != "/"
        Result.DefineProp("IsOpaque", { Get: (_) => IsOpaque })

        ; Authority
        ;   scheme://user:pass@example.org:8182/path/to/file?k=v#frag
        ;            __________________________v
        if (SubStr(Str, Index, 2) == "//") {
            Index += 2
            Next := RegExMatch(Str, "[/?#]", unset, Index + 2) || End
            Authority := SubStr(Str, Index, Next - Index)
            Index := Next + 1
        } else {
            Authority := ""
        }
        Result.DefineProp("Authority", { Get: (_) => Authority })

        ; Path
        ;   scheme://user:pass@example.org:8182/path/to/file?k=v#frag
        ;                                       ____________v
        Next := RegExMatch(Str, "[?#]", unset, Index + 1) || End
        Path := SubStr(Str, Index, Next - Index)
        Result.DefineProp("Path", { Get: (_) => Path })
        
        ; Query
        ;   scheme://user:pass@example.org:8182/path/to/file?k=v#frag
        ;                                                    ___v
        Index := Next + 1
        if (SubStr(Str, Next, 1) == "?") {
            Next := InStr(Str, "#", unset, Index) || End
            Query := SubStr(Str, Index, Next - Index)
            Index := Next + 1
        } else {
            Query := ""
        }
        Result.DefineProp("Query", { Get: (_) => Query })

        ; Fragment
        ;   scheme://user:pass@example.org:8182/path/to/file?k=v#frag
        ;                                                        ____v
        if (SubStr(Str, Next, 1) == "#") {
            Fragment := SubStr(Str, Next + 1)
        } else {
            Fragment := ""
        }
        Result.DefineProp("Fragment", { Get: (_) => Fragment })

        Cls := URI.Types.Get(Scheme, false)
        if (Cls) {
            ObjSetBase(Result, Cls.Prototype)
        } else {
            ObjSetBase(Result, URI.Prototype)
        }
        return Result
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
    Value {
        get {
            throw PropertyError("property not found")
        }
    }

    /**
     * The URI scheme.
     * 
     * @abstract
     * @property {String}
     */
    Scheme {
        get {
            throw PropertyError("property not found")
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
            throw PropertyError("property not found")
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
            throw PropertyError("property not found")
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
            throw PropertyError("property not found")
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
            throw PropertyError("property not found")
        }
    }

    /**
     * Determines whether this URI is absolute. A URI is absolute whenever
     * it defines a scheme.
     * 
     * @readonly
     * @property {String}
     */
    IsAbsolute => (this.Scheme) != ""

    /**
     * Determines whether this URI is opaque. A URI is considered opaque if the
     * scheme-specific part does not start with a forward slash character.
     * 
     * @readonly
     * @property {Strig}
     */
    IsOpaque {
        get {
            throw PropertyError("property not found")
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Commons

    /**
     * Returns a string representation of the URI.
     * 
     * @returns {String}
     */
    ToString() => (this.Value)

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