#Requires AutoHotkey v2.0
#Include <AquaHotkey>

#Include <AquaHotkey\src\Parse\Parser>

; the document itself
class Xml {
    ; constructor, parse entire string
    __New(Str) {
        
    }

    ; to string, including header
    ToString() {

    }

    ; TODO find a way to differentiate between eager and lazy
    static FromFile() {

    }

    WriteToFile(File) {
        
    }
}

; any kind of XML tag --- meant to be an abstract class
class XmlElement {
    ; attributes (create a new map, if absent)
    Attributes {
        get {
            M := Map()
            this.DefineProp("Attributes", { Get: (_) => M })
            return M
        }
    }

    ; elements (create a new array, if absent)
    Elements {
        get {
            A := Array()
            this.DefineProp("Elements", { Get: (_) => A })
            return A
        }
    }

    ; constructor that receives name, optionally
    ; attributes and elements
    __New(Name, Attrs?, Elems?) {
        ; ...
    }

    ToString() {
        throw ValueError("abstract method")
    }

    ; `HasAttribute` and `HasElement`, possibly something for creating
    ; predicate function for visiting, not sure yet
    static HasAttribute(Key, Condition?) {

    }

    static HasElement(Key, Condition?) {

    }
}

; a comment
class XmlComment extends XmlElement {
    __New(Content) {
        ; ...
    }

    ToString() {

    }
}

class AquaHotkey_ParserExt extends AquaHotkey {
    class Parser {
        Without(Other) {
            if (Other is String) {
                Other := Parser.String(Other)
            }
            GetMethod(Other)
            return this.SuchThat(Str => !Other.Matches(&Str))
        }
    }
}

class AquaHotkey_Optional_TryGet extends AquaHotkey {
    class Optional {
        TryGet(&Value) {
            if (ObjHasOwnProp(this, "Value")) {
                Value := this.Value
                return true
            }
            Value := unset
            return false
        }
    }
}

Group_Char_Without_Minus := "\x{09}\x{0A}\x{0D}\x{20}-\x{2C}\x{2E}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}\x{10FFFF}"
Group_Char := Group_Char_Without_Minus . "\-"
Group_Char := "\x{09}\x{0A}\x{0D}\x{20}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}\x{10FFFF}"
Group_NameStartChar := ":\w\x{C0}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{02FF}\x{0370}-\x{037D}\x{037F}-\x{1FFF}\x{200C}-\x{200D}\x{2070}-\x{218F}\x{2C00}-\x{2FEF}\x{3001}-\x{D7FF}\x{F900}-\x{FDCF}\x{FDF0}-\x{FFFD}\x{10000}-\x{EFFFF}"

Group_NameChar := Group_NameStartChar . "\-.0-9\x{B7}\x{0300}-\x{036F}\x{203F}-\x{2040}"

Regex_Char_Without_Minus := "[" . Group_Char_Without_Minus . "]"
Regex_Char := "[" . Group_Char . "]"
Regex_NameStartChar := "[" . Group_NameStartChar . "]"
Regex_NameChar := "[" Group_NameStartChar "]"
Regex_Name := Regex_NameStartChar . Regex_NameChar . "*"

; Regex_Char := "[\x{09}\x{0A}\x{0D}\x{20}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}\x{10FFFF}]"
; Regex_NameStartChar := "[:\w\x{C0}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{02FF}\x{0370}-\x{037D}\x{037F}-\x{1FFF}\x{200C}-\x{200D}\x{2070}-\x{218F}\x{2C00}-\x{2FEF}\x{3001}-\x{D7FF}\x{F900}-\x{FDCF}\x{FDF0}-\x{FFFD}\x{10000}-\x{EFFFF}]"
; Regex_NameCharAdd := "[\-.0-9\x{B7}\x{0300}-\x{036F}\x{203F}-\x{2040}]"
; Regex_NameChar := Format("(?:{}|{})", Regex_NameStartChar, Regex_NameCharAdd)
; Regex_Name := Format("{}{}*", Regex_NameStartChar, Regex_NameChar)

Char := Parser.Regex(Regex_Char)

Regex_S := "[\x{20}\x{09}\x{0D}\x{0A}]"
Regex_S_1N := Regex_S . "+"
Regex_S_0N := Regex_S . "*"

S := Parser.Regex(Regex_S_1N)
S_Opt := Parser.Regex(Regex_S_0N)
; S_Opt := S.Optional()

; NameStartChar := Parser.Regex(Regex_NameStartChar)

NameChar := Parser.Regex(Regex_NameChar)
; NameChar      := NameStartChar.Or(Parser.Regex(Regex_NameCharAdd))

Name := Parser.Regex(Regex_Name)

; Name := Parser.Sequence(Array, NameStartChar, NameChar.ZeroOrMore())
Names := Name.AtLeastOnceDelimitedBy(" ")

Nmtoken := NameChar.AtLeastOnce()
Nmtokens := Nmtoken.AtLeastOnceDelimitedBy(" ")

SystemLiteral := Parser.Regex("'[^']*'|`"[^`"]*`"")

#Include <AquaHotkey\src\Base\ToString>
#Include <AquaHotkey\src\Base\Primitives>

Group_PubidChar_WithoutQuote := "\x{20}\x{0D}\x{0A}\w\-()+,./:=?;!*#@$%"
Group_PubidChar := Group_PubidChar_WithoutQuote . "'"

Regex_PubidChar_WithoutQuote := "[" . Group_PubidChar_WithoutQuote . "]"
Regex_PubidChar := "[" . Group_PubidChar . "]"

; PubidChar := Parser.Regex("[\x{20}\x{0D}\x{0A}\w\-'()+,./:=?;!*#@$%]")

PubidLiteral := Parser.Regex(
    Format("J)`"(?<inner>{})`"|'(?<inner>{})'",
        Regex_PubidChar,
        Regex_PubidChar_WithoutQuote
    ),
    M => M["inner"]
)

; PubidLiteral := PubidChar.ZeroOrMore().Between('"')
;     .Or( (PubidChar.Without("'")).ZeroOrMore().Between("'") )


Comment := Parser.Regex(Format(
    "<!--((?:{1}|-{1})*)-->",
    Regex_Char_Without_Minus
), M => M[1])

; Comment := Char.Without("-")
;     .Or( Parser.Sequence(Array, Parser.String("-"), Char.Without("-")) )
;     .ZeroOrMore()
;     .Between("<!--", "-->")

Regex_Eq := Format("{1}={1}", Regex_S_0N)

Eq := Parser.Regex(Regex_Eq)
; Eq := Parser.String("=").Between( S_Opt )

Regex_VersionNum := "1.[0-9]+"
VersionNum := Parser.Regex(Regex_VersionNum)

; TODO transform this to something useful
CData := Parser.Regex("<!\[CDATA\[" . (Regex_Char . "*?") . "\]\]>")

StringType := Parser.String("CDATA")
TokenizedType := Parser.Regex("ID|IDREF|IDREFS|ENTITY|ENTITIES|NMTOKEN|NMTOKENS")

EntityRef := Parser.Sequence(Array, Parser.String("&"), Name, Parser.String(";"))
PEReference := Parser.Sequence(Array, Parser.String("%"), Name, Parser.String(";"))

PITarget := Name.SuchThat(Str => Str != "xml") ; case-insensitive

EndTag := CreateEndTagParser(Name)

CreateEndTagParser(Psr) {
    if (Psr is String) {
        Psr := Parser.String(Psr)
    }
    return Parser.Sequence(
        Array, Parser.String("</"),
        Psr,
        S_Opt,
        Parser.String(">")
    )
}

VersionInfo := Parser.Regex(
    Format("
        (
        J){1}version{2}(?:"(?<inner>{3})"|'(?<inner>{3})')
        )", Regex_S_1N, Regex_Eq, Regex_VersionNum),
    M => M["inner"]
)

; VersionInfo := Parser.Sequence(Array, S, Parser.String("version"), Eq,
;     VersionNum.Between('"').Or( VersionNum.Between("'") )
; )

Regex_EncName := "[A-Za-z][\w\.\-]*"
EncName := Parser.Regex(Regex_EncName)

; TODO doesn't work
PI := Parser.Sequence(Array,
    Parser.String("<?"),
    Parser.Sequence(Array,
        S,
        Parser.Regex(Regex_Char . "*?\?>"))
    .Optional(),
    Parser.String("?>")
)


SDDecl := Parser.Regex(
    Format(
        "{}standalone{}(?:`"yes`"|'yes'|`"no`"|'no')",
        Regex_S_1N,
        Regex_Eq)
).Map(Val => !!InStr(Val, "yes"))

; YesNo := Parser.Regex("yes|no")
; SDDecl := Parser.Sequence(Array, S, Parser.String("standalone"), Eq,
;     YesNo.Between('"').Or(YesNo.Between("'"))
; )

EncodingDecl := Parser.Regex(
    Format("
        (
        J){1}encoding{2}(?:"(?<inner>{3})"|'(?<inner>{3})')
        )", Regex_S_1N, Regex_Eq, Regex_EncName),
    M => M["inner"]
)

; EncodingDecl := Parser.Sequence(Array, S, Parser.String("encoding"), Eq,
;     EncName.Between('"').Or(EncName.Between("'"))
; )

CharRef := Parser.Regex("&#([0-9]+|x[0-9a-fA-F]+);", M => M[1])
    .Map((Val) => Chr(Integer("0" . Val))) ; use additional "x" to our advantage

; CharRef := Parser.Regex("&#[0-9]+;|&#x[0-9a-fA-F]+;")

Reference := EntityRef.Or(CharRef)

; TODO can omit encoding decl, but still have sddecl?
class XmlDeclaration {
    __New(Version, Encoding, Standalone) {
        this.Version := Version
        this.Encoding := Encoding
        this.Standalone := Standalone
    }
}

XMLDecl := Parser.Sequence(XmlDeclaration,
    VersionInfo,
    EncodingDecl.OrElse(""),
    SDDecl.OrElse("")
)
.FollowedBy(S_Opt)
.Between("<?xml", "?>")

; XMLDecl := Parser.Sequence(
;     Array,
;     Parser.String("<?xml"),
;     VersionInfo,
;     EncodingDecl.Optional(),
;     SDDecl.Optional(),
;     S_Opt,
;     Parser.String("?>")
; )

AttValue := Parser.Regex('[^<&"]').Or(Reference).ZeroOrMore().Between('"')
        .Or(Parser.Regex("[^<&']").Or(Reference).ZeroOrMore().Between("'"))

AttDef := Parser.Sequence(Array,
    S, Name, S, AttType, S, DefaultDecl
)

Attribute := Parser.Sequence(Array, Name, Eq, AttValue)

DefaultDecl := Parser.AnyOf(
    Parser.String("#REQUIRED"),
    Parser.String("#IMPLIED"),
    Parser.Sequence(Array, Parser.String("#FIXED"), S).Optional(),
    AttValue
)

AttlistDecl := Parser.Sequence(
    Array,
    Parser.String("<!ATTLIST"),
    S,
    Name,
    AttDef.ZeroOrMore(),
    S_Opt,
    Parser.String(">")
)
PublicID := Parser.Sequence(Array, Parser.String("PUBLIC"), S, PubidLiteral)

ExternalID := Parser.Sequence(Array, S, SystemLiteral)
    .Or( Parser.Sequence(Array, Parser.String("PUBLIC"), S, PubidLiteral, S, SystemLiteral) )

NDataDecl := Parser.Sequence(Array, S, Parser.String("NCDATA"), S, Name)
TextDecl := Parser.Sequence(Array,
    Parser.String("<?xml"),
    VersionInfo.Optional(),
    EncodingDecl,
    S_Opt,
    Parser.String("?>")
)

EmptyElemTag := Parser.Sequence(Array,
    Parser.String("<"),
    Name,
    Parser.Sequence(Array, S, Attribute).ZeroOrMore(),
    S_Opt,
    Parser.String("/>")
)

class XmlTag {
    __New(Name, Attributes) {
        this.Name := Name
        this.Attributes := Attributes
    }
}

STag := Parser.Sequence(XmlTag,
    Name,
    S.Then(Attribute).ZeroOrMore()
)
.FollowedBy(S_Opt)
.Between("<", ">")

; STag := Parser.Sequence(Array,
;     Parser.String("<"),
;     Name,
;     Parser.Sequence(Array, S, Attribute).ZeroOrMore(),
;     S_Opt,
;     Parser.String(">")
; )

; EndTag := Parser.Sequence(Array,
;     Parser.String("</"),
;     Name,
;     S_Opt,
;     Parser.String(">")
; )

DeclSep := PEReference.Or(S)

Mixed := Parser.Sequence(Array,
    Parser.String("("),
    S_Opt,
    Parser.String("#PCDATA"),

    Parser.Sequence(Array,
        S_Opt, Parser.String("|"), S_Opt,
        Name
    ).ZeroOrMore(),

    S_Opt,
    Parser.String(")")
)

cp := Parser.Rule(&_cp)

Choice := cp.AtLeastOnceDelimitedBy(Parser.String("|").Between(S_Opt))
    .SuchThat(Arr => Arr.Length > 1)
    .Between(S_Opt)
    .Between("(", ")")

Seq := cp.AtLeastOnceDelimitedBy(Parser.String(",").Between(S_Opt))
    .Between(S_Opt)
    .Between("(", ")")

_cp := Parser.Sequence(Array,
    Parser.AnyOf(Name, Choice, Seq),
    Parser.Regex("[?*+]").Optional()
)

; STag.Parse(&Str := "<person isCool='yes'>").ToString().MsgBox()
; VersionInfo.Parse(&Str := " version='1.0'").ToString().MsgBox()
; XMLDecl.Parse(&Str := "<?xml version='1.0' encoding='utf-8' standalone='yes'?>").ToString().MsgBox()

NotationType := Parser.Sequence(Array,
    Parser.String("NOTATION"),
    S,
    Parser.String("("),
    S_Opt,
    Name,
    Parser.Sequence(Array,
        S_Opt,
        Parser.String("|"),
        S_Opt,
        Name
    ).ZeroOrMore(),
    S_Opt,
    Parser.String(")")
)

EntityValue_BetweenDoubleQuotes := Parser.AnyOf(
    Parser.Regex('[^%&"]'),
    PEReference,
    Reference
).ZeroOrMore().Between('"')

EntityValue_BetweenSingleQuotes := Parser.AnyOf(
    Parser.Regex("[^%&']"),
    PEReference,
    Reference
).ZeroOrMore().Between("'")

EntityValue := EntityValue_BetweenDoubleQuotes.Or(EntityValue_BetweenSingleQuotes)

EntityDef := EntityValue.Or( Parser.Sequence(Array, ExternalID, NDataDecl.Optional()) )

; TODO is this okay?
CharData := Parser.Regex("[^<&]*(?!\]\]>)")

Misc := Parser.AnyOf(Comment, PI, S)

Content := Parser.Rule(&_Content)

; TODO extra context for tag names
Element := EmptyElemTag.Or( Parser.Sequence(Array, STag, Content, EndTag) )

Children := Parser.Sequence(Array,
    Choice.Or(Seq),
    Parser.Regex("[?*+]").Optional()
)

NotationDecl := Parser.Sequence(Array,
    Parser.String("<!NOTATION"),
    S,
    Name,
    S,
    ExternalID.Or(PublicId),
    S_Opt,
    Parser.String(">")
)

extParsedEnt := Parser.Sequence(Array,
    TextDecl.Optional(),
    Content
)
PEDef := EntityValue.Or(ExternalID)
PEDecl := Parser.Sequence(Array,
    Parser.String("<!ENTITY"),
    S,
    Parser.String("%"),
    S,
    Name,
    S,
    PEDef,
    Parser.String(">")
)

GEDecl := Parser.Sequence(Array,
    Parser.String("<!ENTITY"),
    S,
    Name,
    S,
    EntityDef,
    S_Opt,
    Parser.String(">")
)
EntityDecl := GEDecl.Or(PEDecl)

Enumeration := Nmtoken.AtLeastOnceDelimitedBy(
    Parser.String("|").Between(S_Opt)
).Between(S_Opt).Between("(", ")")

EnumeratedType := NotationType.Or(Enumeration)

AttType := Parser.AnyOf(
    StringType,
    TokenizedType,
    EnumeratedType
)

class AquaHotkey_Xml extends AquaHotkey {
    class String {
        ParseXml() => Document.Parse(&this)
    }
}

ConditionalSect := Parser.Rule(&_ConditionalSect)

ContentSpec := Parser.AnyOf(
    Parser.String("EMPTY"),
    Parser.String("ANY"),
    Mixed,
    Children
)

ElementDecl := Parser.Sequence(Array,
    Parser.String("<!ELEMENT"),
    S,
    Name,
    S,
    ContentSpec,
    S_Opt,
    Parser.String(">")
)

class Ext extends AquaHotkey {
    class String {
        DisplayParsedResult(Psr) => this.Parse(Psr).ToString().MsgBox()
    }
}

; "
; (
; <?xml version="1.0" encoding="utf-8" standalone="yes"?>
; <!-- comments -->
; <!-- more comments -->
; )".Parse(Prolog).ToString().MsgBox()

; "(a | b | c)".Parse(Children).ToString().MsgBox()

MarkupDecl := Parser.AnyOf(
    ElementDecl,
    AttlistDecl,
    EntityDecl,
    NotationDecl,
    PI,
    Comment
)
intSubset := Parser.Sequence(Array, MarkupDecl, declsep).ZeroOrMore()

DoctypeDecl := Parser.Sequence(Array,
    Parser.String("<!DOCTYPE"),
    S,
    Name,
    Parser.Sequence(Array, S, ExternalID).Optional(),
    S_Opt,
    Parser.Sequence(Array,
        Parser.String("["),
        intSubset,
        Parser.String("]"),
    ).Optional(),
    Parser.String(">")
)

Prolog := Parser.Sequence(Array,
    XMLDecl.Optional(),
    Misc.ZeroOrMore(),
    Parser.Sequence(Array,
        DoctypeDecl,
        Misc.ZeroOrMore()
    ).Optional()
)

Document := Parser.Sequence(Array, Prolog, Element, Misc.ZeroOrMore())

ExtSubsetDecl := Parser.AnyOf(
    MarkupDecl,
    ConditionalSect,
    DeclSep
).ZeroOrMore()

ExtSubset := Parser.Sequence(Array, TextDecl.Optional(), ExtSubsetDecl)

IncludeSect := Parser.Sequence(Array,
    Parser.String("<!["), S_Opt, Parser.String("INCLUDE"), S_Opt, Parser.String("["),
    ExtSubsetDecl,
    Parser.String("]]>")
)

Ignore := Parser.Regex(Format("
(
{}*(?!\Q<![\E|\Q]]>\E)
)", Regex_Char))

IgnoreSectContents := Parser.Define(I => (
    Parser.Sequence(Array,
        Ignore,
        Parser.Sequence(Array,
            Parser.String("<!["), I, Parser.String("]]>"), Ignore
        ).ZeroOrMore()
    )
))

IgnoreSect_FirstPart := Parser.Sequence(Array,
    Parser.String("<!["),
    S_Opt,
    Parser.String("IGNORE"),
    S_Opt,
    Parser.String("["),
)

IgnoreSect := Parser.Sequence(Array,
    Parser.String("<!["),
    S_Opt,
    Parser.String("IGNORE"),
    S_Opt,
    Parser.String("["),
    ExtSubsetDecl,
    Parser.String("]]>")
)

_ConditionalSect := IncludeSect.Or(IgnoreSect)

_Content := Parser.Sequence(Array,
    CharData.Optional(),
    Parser.Sequence(Array,
        Parser.AnyOf(
            Element,
            Reference,
            CData,
            PI,
            Comment
        ),
        CharData
    ).ZeroOrMore()
)

