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

Regex_Char := "[\x{09}\x{0A}\x{0D}\x{20}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}\x{10FFFF}]"
Regex_NameStartChar := "[:\w\x{C0}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{02FF}\x{0370}-\x{037D}\x{037F}-\x{1FFF}\x{200C}-\x{200D}\x{2070}-\x{218F}\x{2C00}-\x{2FEF}\x{3001}-\x{D7FF}\x{F900}-\x{FDCF}\x{FDF0}-\x{FFFD}\x{10000}-\x{EFFFF}]"
Regex_NameCharAdd := "[\-.0-9\x{B7}\x{0300}-\x{036F}\x{203F}-\x{2040}]"

Regex_NameChar := Format("(?:{}|{})", Regex_NameStartChar, Regex_NameCharAdd)
Regex_Name := Format("{}{}*", Regex_NameStartChar, Regex_NameChar)
Regex_S := "[\x{20}\x{09}\x{0D}\x{0A}]+"

Char := Parser.Regex(Regex_Char)

S := Parser.Regex(Regex_S)
S_Opt := S.Optional()

; NameStartChar := Parser.Regex(Regex_NameStartChar)

NameChar := Parser.Regex(Regex_NameChar)
; NameChar      := NameStartChar.Or(Parser.Regex(Regex_NameCharAdd))

Name := Parser.Regex(Regex_Name)

; Name := Parser.Sequence(Array, NameStartChar, NameChar.ZeroOrMore())
Names := Name.AtLeastOnceDelimitedBy(" ")

Nmtoken := NameChar.AtLeastOnce()
Nmtokens := Nmtoken.AtLeastOnceDelimitedBy(" ")

SystemLiteral := Parser.Regex("
(
x)'[^']*'
| "[^"]*"
)")

#Include <AquaHotkey\src\Base\ToString>
#Include <AquaHotkey\src\Base\Primitives>

PubidChar := Parser.Regex("[\x{20}\x{0D}\x{0A}\w\-'()+,./:=?;!*#@$%]")

PubidLiteral := PubidChar.ZeroOrMore().Between('"')
    .Or( (PubidChar.Without("'")).ZeroOrMore().Between("'") )

Comment := Char.Without("-")
    .Or( Parser.Sequence(Array, Parser.String("-"), Char.Without("-")) )
    .ZeroOrMore()
    .Between("<!--", "-->")

Eq := Parser.String("=").Between( S_Opt )
VersionNum := Parser.Regex("1.[0-9]+")

CData := Parser.Regex("<!\[CDATA\[" . (Regex_Char . "*?") . "\]\]>")

StringType := Parser.String("CDATA")
TokenizedType := Parser.Regex("ID|IDREF|IDREFS|ENTITY|ENTITIES|NMTOKEN|NMTOKENS")

EntityRef := Parser.Sequence(Array, Parser.String("&"), Name, Parser.String(";"))
PEReference := Parser.Sequence(Array, Parser.String("%"), Name, Parser.String(";"))

PITarget := Name.SuchThat(Str => Str != "xml")

ETag := Parser.Sequence(Array, Parser.String("</"), Name, S_Opt, Parser.String(">"))

VersionInfo := Parser.Sequence(Array, S, Parser.String("version"), Eq,
    VersionNum.Between('"').Or( VersionNum.Between("'") )
)

EncName := Parser.Regex("[A-Za-z][\w.\-]*")

; TODO doesn't work
PI := Parser.Sequence(Array,
    Parser.String("<?"),
    Parser.Sequence(Array,
        S,
        Parser.Regex(Regex_Char . "*?\?>"))
    .Optional()
)

YesNo := Parser.Regex("yes|no")

SDDecl := Parser.Sequence(Array, S, Parser.String("standalone"), Eq,
    YesNo.Between('"').Or(YesNo.Between("'"))
)

EncodingDecl := Parser.Sequence(Array, S, Parser.String("encoding"), Eq,
    EncName.Between('"').Or(EncName.Between("'"))
)

CharRef := Parser.Regex("&#[0-9]+;|&#x[0-9a-fA-F]+;")

Reference := EntityRef.Or(CharRef)

; TODO can omit encoding decl, but still have sddecl?
XMLDecl := Parser.Sequence(
    Array,
    Parser.String("<?xml"),
    VersionInfo,
    EncodingDecl.Optional(),
    SDDecl.Optional(),
    S_Opt,
    Parser.String("?>")
)

AttValue := Parser.Regex('[^<&"]').Or(Reference).ZeroOrMore().Between('"')
        .Or(Parser.Regex("[^<&']").Or(Reference).ZeroOrMore().Between("'"))

; TODO
AttDef := Parser.Char()

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
    __New(Name) {

    }
}

STag := Parser.Sequence(Array,
    Parser.String("<"),
    Name,
    Parser.Sequence(Array, S, Attribute).ZeroOrMore(),
    S_Opt,
    Parser.String(">")
)
ETag := Parser.Sequence(Array,
    Parser.String("</"),
    Name,
    S_Opt,
    Parser.String(">")
)

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

CharData := Parser.Regex("[^<&]*(?!\]\]>)")

Misc := Parser.AnyOf(Comment, PI, S)

Content := Parser.Rule(&_Content)

; TODO extra context for tag names
Element := EmptyElemTag.Or( Parser.Sequence(Array, STag, Content, ETag) )

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
intSubset := Parser.Sequence(Array, markupdecl, declsep).ZeroOrMore()

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

"<person isCool='yes'>".DisplayParsedResult(STag)