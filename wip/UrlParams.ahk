#Include <AquaHotkey\src\Collections\Generic\Array>
#Include <AquaHotkey\src\Net\UrlEncoding>
#Include <AquaHotkey\src\Net\Uri>

#Include <AquaHotkey\wip\UrlParam>

/**
 * An array of URL query parameters.
 */
class UrlParams extends GenericArray {
    ; this is basically the same as a `UrlParams[]`
    static __New() => super.__New(Array, UrlParam)

    /**
     * Creates a new URL query params array from alternating keys and values.
     * 
     * @param   {Any*}  Args  alternating key and value
     * @returns {UrlParams}
     */
    static FromPairs(Args*) => this().Add(Args*)

    /**
     * Creates a new URL query params array by parsing a string.
     * 
     * @param   {String}  Str  query string
     * @returns {UrlParams}
     */
    static Parse(Str) {
        if (!(Str is String)) {
            throw TypeError("Expected a String",, Type(Str))
        }
        Result := this()
        loop parse Str, "&", "?" {
            Index := InStr(A_LoopField, "=")
            if (!Index) {
                throw ValueError("invalid query parameter",, A_LoopField)
            }
            Result.Push(UrlParam(
                SubStr(A_LoopField, 1, Index - 1),
                SubStr(A_LoopField, Index + 1)
            ))
        }
        return Result
    }

    /**
     * Returns the string representation of this URL params array.
     * 
     * @returns {String}
     */
    ToString() {
        Result := ""
        Enumer := this.__Enum(1)
        if (!Enumer(&Param)) {
            return Result
        }
        Result .= "?"
        Result .= Param.ToString()

        for Param in Enumer {
            Result .= "&"
            Result .= Param.ToString()
        }
        return Result
    }

    /**
     * Appends an URL param to the URL params array.
     * 
     * @param   {Any*}  Args  alternating key and value
     * @returns {this}
     */
    Add(Args*) {
        for Key, Value in Pairwise(Args) {
            this.Push(UrlParam(Key, Value))
        }
        return this
    }
}

/**
 * Extensions related to {@link UrlParams}.
 */
class AquaHotkey_UrlParams extends AquaHotkey {
    static __New() => IsSet(AquaHotkey_Uri) && super.__New()

    class Uri {
        /**
         * Query parameters viewed as {@link UrlParams}.
         * 
         * @property {UrlParams}
         */
        QueryParams {
            get {
                Params := UrlParams.Parse(this.Query)
                ({}.DefineProp)(this, "QueryParams", {
                    Get: (_) => Params.Clone()
                })
                return Params
            }
        }

        ; TODO decide how to display this as JSDoc
        /**
         * Returns a new URI that resolves to the current directory, with
         * the given query parameters. This method accepts either a
         * {@link UrlParams} or alternating query key and value.
         * 
         * @param   {UrlParams|Any}  Params  URL query params or query key
         * @param   {Any*}           Args    alternating key and value
         * @returns {Uri}
         * @example
         * Uri("https://www.example.com")
         *     .WithQueryParams("a", 1, "b", 2) ; or `UrlParams(...)`
         *     .ToString()
         * ; ==> "https://www.example.com?a=1&b=2"
         */
        WithQueryParams(Params, Args*) {
            if (Args.Length) {
                Params := UrlParams.FromPairs(Params, Args*)
            }
            if (!(Params is UrlParams)) {
                throw TypeError("Expected a UrlParams",, Type(Params))
            }
            return this.Resolve("./" . Params.ToString())
        }

        /**
         * Resolves a new URI by adding query parameters to the existing
         * URI. This method accepts either a {@link UrlParams} or alternating
         * query key and value.
         * 
         * @param   {UrlParams|Any}  Params  URL query params or query key
         * @param   {Any*}           Args    alternating key and value
         * @returns {Uri}
         * @example
         * Uri("https://www.example.com?a=1")
         *     .AddQueryParams("b", 1) ; or `UrlParams(...)`
         *     .ToString()
         * ; ==> "https://www.example.com?a=1&b=2"
         */
        AddQueryParams(Params, Args*) {
            QueryParams := this.QueryParams
            if (Args.Length) {
                return this.WithQueryParams(QueryParams.Add(Params, Args*))
            }
            if (!(Params is UrlParams)) {
                throw TypeError("Expected an UrlParams",, Type(Params))
            }
            QueryParams.Push(Params*)
            return this.WithQueryParams(QueryParams)
        }
    }
}
