class Test_Uri extends TestSuite {
    static __New() {
        (DummyUri)
        super.__New()
    }

    static Types_holds_Map_of_schemes() {
        (Uri.Types).AssertType(Map)
    }

    static Types_schemes_are_validated() {
        this.AssertThrows(() => (Uri.Types).Set("$invalid", DummyUri))
        this.AssertThrows(() => (Uri.Types)["$invalid", DummyUri])
    }

    static Types_classes_are_validated() {
        ; invalid value, must be subclass of Uri
        this.AssertThrows(() => (Uri.Types).Set("valid", Uri))
    }

    static Types_is_case_insensitive() {
        (Uri.Types).Set("CaseInsensitive", DummyUri)
        (Uri.Types).Has("CASEINSENSITIVE").Assert(Eq(true))
    }

    static Subclasses_are_registered() {
        (Uri.Types).Has("dummy")
    }

    static empty_uri_should_construct() {
        Uri("")
    }

    static uri_has_invalid_chars() {
        ; < is not a valid character in URIs
        this.AssertThrows(() => Uri("/a/b/<"))
    }

    static missing_authority() {
        this.AssertThrows(() => Uri("http:"))
        this.AssertThrows(() => Uri("http:/"))
    }

    static parse_simple_hierarchical() {
        U := Uri("http://example.com")
        U.Scheme.Assert(Eq("http"))
        U.Authority.Assert(Eq("example.com"))
        U.Path.Assert(Eq(""))
        U.HasAuthority.Assert(Eq(true))
        U.IsOpaque.Assert(Eq(false))
    }

    static parse_full_hierarchical() {
        U := Uri("http://example.com/path/to/resource?query=value#fragment")
        U.Scheme.Assert(Eq("http"))
        U.Authority.Assert(Eq("example.com"))
        U.Path.Assert(Eq("/path/to/resource"))
        U.Query.Assert(Eq("query=value"))
        U.Fragment.Assert(Eq("fragment"))
        U.IsOpaque.Assert(Eq(false))
    }

    static parse_opaque_uri() {
        U := Uri("mailto:user@example.com")
        U.Scheme.Assert(Eq("mailto"))
        U.SchemeSpecific.Assert(Eq("user@example.com"))
        U.IsOpaque.Assert(Eq(true))
        U.HasAuthority.Assert(Eq(false))
    }

    static parse_relative_path() {
        U := Uri("path/to/file.txt")
        U.HasScheme.Assert(Eq(false))
        U.Path.Assert(Eq("path/to/file.txt"))
        U.IsAbsolute.Assert(Eq(false))
        U.IsOpaque.Assert(Eq(false))
    }

    static parse_path_with_query() {
        U := Uri("/path?query=value")
        U.Path.Assert(Eq("/path"))
        U.Query.Assert(Eq("query=value"))
        U.HasFragment.Assert(Eq(false))
    }

    static parse_fragment_only() {
        U := Uri("#fragment")
        U.Fragment.Assert(Eq("fragment"))
        U.Path.Assert(Eq(""))
        U.HasScheme.Assert(Eq(false))
    }

    static parse_authority_only() {
        U := Uri("//example.com")
        U.Authority.Assert(Eq("example.com"))
        U.Path.Assert(Eq(""))
        U.HasScheme.Assert(Eq(false))
    }

    ; Normalization tests
    static normalize_removes_dot() {
        U := Uri("/a/./b/c").Normalize()
        U.Path.Assert(Eq("/a/b/c"))
    }

    static normalize_removes_dot_dot() {
        U := Uri("/a/b/../c").Normalize()
        U.Path.Assert(Eq("/a/c"))
    }

    static resolve_retains_dot_dot() {
        Uri("/a").Resolve("..").Path.Eq("/")
    }

    static normalize_multiple_dots() {
        U := Uri("/a/./b/../c/./d").Normalize()
        U.Path.Assert(Eq("/a/c/d"))
    }

    static normalize_preserves_leading_slash() {
        U := Uri("/").Normalize()
        U.Path.Assert(Eq("/"))
    }

    static normalize_empty_path() {
        U := Uri("").Normalize()
        U.Path.Assert(Eq(""))
    }

    static normalize_opaque_unchanged() {
        U := Uri("mailto:user@example.com").Normalize()
        U.SchemeSpecific.Assert(Eq("user@example.com"))
    }

    ; Equality tests
    static equality_same_uri() {
        U1 := Uri("http://example.com/path")
        U2 := Uri("http://example.com/path")
        U1.Eq(U2).Assert(Eq(true))
    }

    static equality_different_scheme() {
        U1 := Uri("http://example.com")
        U2 := Uri("https://example.com")
        U1.Eq(U2).Assert(Eq(false))
    }

    static equality_case_insensitive_scheme() {
        U1 := Uri("HTTP://example.com")
        U2 := Uri("http://example.com")
        U1.Eq(U2).Assert(Eq(true))
    }

    static equality_different_fragment_case() {
        U1 := Uri("http://example.com#FRAG")
        U2 := Uri("http://example.com#frag")
        U1.Eq(U2).Assert(Eq(false)) ; fragments are case-sensitive
    }

    static equality_opaque_vs_hierarchical() {
        U1 := Uri("mailto:user@example.com")
        U2 := Uri("http://user@example.com")
        U1.Eq(U2).Assert(Eq(false))
    }

    static equality_same_opaque() {
        U1 := Uri("mailto:user@example.com")
        U2 := Uri("mailto:user@example.com")
        U1.Eq(U2).Assert(Eq(true))
    }

    static equality_normalized_vs_unnormalized() {
        U1 := Uri("/a/./b/../c")
        U2 := Uri("/a/c")
        U1.Eq(U2).Assert(Eq(false)) ; not automatically normalized
    }

    ; Hash code tests
    static hash_code_consistent() {
        U := Uri("http://example.com/path")
        H1 := U.HashCode()
        H2 := U.HashCode()
        H1.Assert(Eq(H2))
    }

    static hash_code_equal_objects() {
        U1 := Uri("http://example.com/path")
        U2 := Uri("http://example.com/path")
        U1.HashCode().Assert(Eq(U2.HashCode()))
    }

    ; String representation tests
    static to_string_returns_value() {
        Str := "http://example.com/path"
        U := Uri(Str)
        U.ToString().Assert(Eq(Str))
    }

    static to_debug_string_includes_components() {
        U := Uri("http://example.com/path?query#frag")
        DebugStr := U.ToDebugString()
        ; Should contain the components
        (InStr(DebugStr, "http://example.com/path?query#frag") > 0).Assert(Eq(true))
    }

    ; Relativize tests
    static relativize_same_base() {
        Base := Uri("http://example.com/docs/")
        Target := Uri("http://example.com/docs/guide.html")

        Rel := Base.Relativize(Target)

        Rel.Path.Assert(Eq("guide.html"))

        Rel.HasAuthority.Assert(Eq(false))
        Rel.HasScheme.Assert(Eq(false))
    }

    static relativize_different_authority() {
        Base := Uri("http://example.com/")
        Target := Uri("http://other.com/path")
        Rel := Base.Relativize(Target)
        Rel.Assert(Eq(Target)) ; should return target unchanged
    }

    static relativize_opaque() {
        Base := Uri("mailto:user@example.com")
        Target := Uri("mailto:other@example.com")
        Rel := Base.Relativize(Target)
        Rel.Assert(Eq(Target))
    }

    ; Resolve tests
    static resolve_fragment() {
        Base := Uri("/a/b/c.txt")
        Frag := Uri("#section")
        Resolved := Base.Resolve(Frag)
        Resolved.Path.Assert(Eq("/a/b/c.txt"))
        Resolved.Fragment.Assert(Eq("section"))
    }

    static resolve_absolute() {
        Base := Uri("http://example.com/old")
        Abs := Uri("https://other.com/new")
        Resolved := Base.Resolve(Abs)
        Resolved.Assert(Eq(Abs))
    }

    static resolve_authority() {
        Base := Uri("http://example.com/old")
        Auth := Uri("//other.com/new")
        Resolved := Base.Resolve(Auth)
        Resolved.Scheme.Assert(Eq("http"))
        Resolved.Authority.Assert(Eq("other.com"))
        Resolved.Path.Assert(Eq("/new"))
    }

    static resolve_relative_path() {
        Base := Uri("http://example.com/a/b/c")
        Rel := Uri("../d")
        Resolved := Base.Resolve(Rel)
        Resolved.Path.Assert(Eq("/a/d"))
    }

    ; Error cases
    static invalid_scheme() {
        this.AssertThrows(() => Uri("123invalid:"))
    }

    static invalid_percent_escape() {
        this.AssertThrows(() => Uri("/path%XX"))
    }

    static fragment_with_hash() {
        this.AssertThrows(() => Uri("#frag#ment"))
    }

    static empty_scheme_specific_part() {
        this.AssertThrows(() => Uri("http:"))
    }

    ; Percent encoding normalization
    static percent_encoding_normalized() {
        U := Uri("/path%fa%bb")
        U.ToString().Assert(Eq("/path%FA%BB"))
    }

    ; Edge cases
    static uri_with_empty_components() {
        U := Uri("http://example.com?")
        U.Query.Assert(Eq(""))
        U.HasQuery.Assert(Eq(true))
    }

    static uri_with_empty_fragment() {
        U := Uri("http://example.com#")
        U.Fragment.Assert(Eq(""))
        U.HasFragment.Assert(Eq(true))
    }

    static root_path() {
        U := Uri("/")
        U.Path.Assert(Eq("/"))
        U.HasPath.Assert(Eq(true))
    }

    static multiple_slashes() {
        U := Uri("http://example.com//path")
        U.Path.Assert(Eq("//path"))
    }
}

class DummyUri extends Uri {
    static Schemes => ["dummy"]
}