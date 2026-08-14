#Requires AutoHotkey v2.0
#Include <AquaHotkey>

#Include <AquaHotkey\src\Parse\Parser>
#Include <AquaHotkey\src\Base\ToString>
#Include <AquaHotkey\src\Base\Primitives>

; any kind of XML tag --- meant to be an abstract class
class XmlElement {
    ; constructor that receives name, optionally
    ; attributes and elements
    __New(Name, Attributes := [], Elements := []) {
        this.Name := Name
        this.Attributes := Attributes

        Children := []
        TextNodes := []
        for Item in Elements {
            ((Item is String) ? TextNodes : Children).Push(Item)
        }

        this.Children := Children
        this.TextNodes := TextNodes
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
    __New(Value) {
        this.Value := Value
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

Char := Parser.Regex(Regex_Char)

Regex_S := "[\x{20}\x{09}\x{0D}\x{0A}]"
Regex_S_1N := Regex_S . "+"
Regex_S_0N := Regex_S . "*"

S := Parser.Regex(Regex_S_1N)
S_Opt := Parser.Regex(Regex_S_0N)

NameChar := Parser.Regex(Regex_NameChar)
Name := Parser.Regex(Regex_Name)

Names := Name.AtLeastOnceDelimitedBy(" ")

Nmtoken := Parser.Regex(Regex_NameChar . "+")
Nmtokens := Nmtoken.AtLeastOnceDelimitedBy(" ")

SystemLiteral := Parser.Regex("'[^']*'|`"[^`"]*`"")

Group_PubidChar_WithoutQuote := "\x{20}\x{0D}\x{0A}\w\-()+,./:=?;!*#@$%"
Group_PubidChar := Group_PubidChar_WithoutQuote . "'"

Regex_PubidChar_WithoutQuote := "[" . Group_PubidChar_WithoutQuote . "]"
Regex_PubidChar := "[" . Group_PubidChar . "]"

PubidLiteral := Parser.Regex(
    Format("J)`"(?<inner>{})`"|'(?<inner>{})'",
        Regex_PubidChar,
        Regex_PubidChar_WithoutQuote
    ),
    M => M["inner"]
)

Comment := Parser.Regex(Format(
    "<!--((?:{1}|-{1})*)-->",
    Regex_Char_Without_Minus
), M => XmlComment(M[1]))

Regex_Eq := Format("{1}={1}", Regex_S_0N)

Eq := Parser.Regex(Regex_Eq)

; TODO strictness of version numbers
Regex_VersionNum := "1\.[0-9]+"
VersionNum := Parser.Regex(Regex_VersionNum)

CData := Parser.Regex(
    "<!\[CDATA\[(" . (Regex_Char . "*?") . ")\]\]>",
    M => M[1]
)

StringType := Parser.String("CDATA")
TokenizedType := Parser.Regex("ID|IDREF|IDREFS|ENTITY|ENTITIES|NMTOKEN|NMTOKENS")

class XmlEntityRef {
    __New(Name) {
        this.Name := Name
    }
}

class XmlParameterEntityRef {
    __New(Name) {
        this.Name := Name
    }
}

EntityRef := Name.Between("&", ";").Map(XmlEntityRef)
PEReference := Name.Between("%", ";").Map(XmlParameterEntityRef)

PITarget := Parser.Regex("i)(?!xml)").Then(Name)

CreateEndTagParser(Psr) {
    if (Psr is String) {
        Psr := Parser.String(Psr)
    }
    return Psr.FollowedBy(S_Opt).Between("</", ">")
}

VersionInfo := Parser.Regex(
    Format("
        (
        J){1}version{2}(?:"(?<inner>{3})"|'(?<inner>{3})')
        )", Regex_S_1N, Regex_Eq, Regex_VersionNum),
    M => M["inner"]
)

Regex_EncName := "[A-Za-z][\w\.\-]*"

class XmlProcessInstruction {
    __New(Target, Value) {
        this.Target := Target
        this.Value := Value
    }
}

PI := Parser.Sequence(XmlProcessInstruction,
    PITarget,
    S.Then(Parser.Regex(Regex_Char . "*?(?=\?>)")).OrElse(""),
).Between("<?", "?>")

SDDecl := Parser.Regex(
    Format(
        "{}standalone{}(?:`"yes`"|'yes'|`"no`"|'no')",
        Regex_S_1N,
        Regex_Eq)
).Map(Val => !!InStr(Val, "yes"))

EncodingDecl := Parser.Regex(
    Format("
        (
        J){1}encoding{2}(?:"(?<inner>{3})"|'(?<inner>{3})')
        )", Regex_S_1N, Regex_Eq, Regex_EncName),
    M => M["inner"]
)

CharRef := Parser.Regex("&#([0-9]+|x[0-9a-fA-F]+);",
    M => Chr(Integer("0" . M[1]))) ; use additional "x" to our advantage

Reference := EntityRef.Or(CharRef)

; TODO can omit encoding decl, but still have sddecl?
class XmlDeclaration {
    __New(Version, Encoding, Standalone) {
        this.Version := Version
        if (Encoding.IsPresent) {
            this.Encoding := Encoding.Value
        }
        if (Standalone.IsPresent) {
            this.Standalone := Standalone.Value
        }
    }
}

XMLDecl := Parser.Sequence(XmlDeclaration,
    VersionInfo,
    EncodingDecl.Optional(),
    SDDecl.Optional()
)
.FollowedBy(S_Opt)
.Between("<?xml", "?>")

StrJoin(Strs*) {
    Result := ""
    for Str in Strs {
        Result .= Str
    }
    return Result
}

AttValue := (
    Parser.Regex('[^<&"]+').Map(StrJoin).Or(Reference)
        .ZeroOrMore(StrJoin)
        .Between('"')
.Or(Parser.Regex("[^<&']+").Map(StrJoin).Or(Reference)
        .ZeroOrMore(StrJoin)
        .Between("'")))

class XmlAttribute {
    __New(Name, Value) {
        this.Name := Name
        this.Value := Value
    }
}

Attribute := Parser.Sequence(XmlAttribute, Name.FollowedBy(Eq), AttValue)

DefaultDecl := Parser.AnyOf(
    Parser.String("#REQUIRED"),
    Parser.String("#IMPLIED"),
    Parser.Sequence(Array,
        Parser.String("#FIXED", S).Optional(),
        AttValue
    )
)

class XmlPublicId {
    __New(Value) {
        this.Value := Value
    }
}

PublicID := Parser.String("PUBLIC").Then(S).Then(PubidLiteral).Map(XmlPublicId)

; TODO create useful output for this

class XmlSystemExternal {
    __New(Value) {
        this.Value := Value
    }
}

class XmlPublicExternal {
    __New(Pub, Sys) {
        this.Pub := Pub
        this.Sys := Sys
    }
}

ExternalID := Parser.AnyOf(
    Parser.String("SYSTEM").Then(S).Then(SystemLiteral).Map(XmlSystemExternal),
    Parser.Sequence(XmlPublicExternal,
        Parser.String("PUBLIC").Then(S).Then(PubidLiteral),
        S.Then(SystemLiteral)
    )
)

class XmlNDataDeclaration {
    __New(Name) {
        this.Name := Name
    }
}

NDataDecl := Parser.String("NCDATA").Between(S).Then(Name).Map(XmlNDataDeclaration)

class XmlTextDecl {
    __New(VersionInfo, EncodingDecl) {
        this.VersionInfo := VersionInfo
        this.EncodingDecl := EncodingDecl
    }
}

TextDecl := Parser.Sequence(XmlTextDecl,
    VersionInfo.Optional(),
    EncodingDecl
)
.FollowedBy(S_Opt)
.Between("<?xml", "?>")

class XmlEmptyElement {
    __New(Name, Attributes) {
        this.Name := Name
        this.Attributes := Attributes
    }
}

class XmlTag {
    __New(Name, Attributes) {
        this.Name := Name
        this.Attributes := Attributes
    }
}

EmptyElemTag := Parser.Sequence(XmlEmptyElement,
    Name,
    (S.Then(Attribute)).ZeroOrMore(),
)
.FollowedBy(S_Opt)
.Between("<", "/>")

STag := Parser.Sequence(XmlTag,
    Name,
    S.Then(Attribute).ZeroOrMore()
)
.FollowedBy(S_Opt)
.Between("<", ">")

DeclSep := PEReference.Or(S)

class XmlMixed {
    __New(Value) {
        this.Value := Value
    }
}

Mixed := Parser.String("#PCDATA").Then(
    Parser.String("|").Between(S_Opt).Then(Name).ZeroOrMore()
).Between(S_Opt).Between("(", ")")

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

class XmlNotationType {
    __New(Values*) {
        this.Values := Values
    }
}

NotationType := Parser.String("NOTATION").Then(S).Then(
    Name.AtLeastOnceDelimitedBy(Parser.String("|").Between(S_Opt))
        .Between(S_Opt)
        .Between("(", ")")
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

Element := Parser.String("<").Then(
    Parser.Sequence(Array, Name, (S.Then(Attribute)).ZeroOrMore())
          .FlatMap(ElementFlatMap)
)

ElementFlatMap(Tag) {
    static Empty    := Parser.String("/>")
    static Nonempty := Parser.String(">").Then(Content)
    
    return Parser.AnyOf(
        Empty.Map((*) => XmlEmptyElement(Tag[1], Tag[2])),
        Nonempty.FollowedBy(CreateEndTagParser(Tag[1]))
                .Map(Content => XmlElement(Tag[1], Tag[2], Content))
    )
}

; Element := EmptyElemTag.Or(STag.FlatMap(ParserBasedOnStartingTag))
; ParserBasedOnStartingTag(Tag) {
;     return Content.FollowedBy(CreateEndTagParser(Tag.Name))
;         .Map(Content => XmlElement(Tag.Name, Tag.Attributes, Content))
; }

Children := Parser.Sequence(Array,
    Choice.Or(Seq),
    Parser.Regex("[?*+]").Optional()
)

class XmlNotationDecl {
    __New(Name, Ref) {
        this.Name := Name
        this.Ref := Ref
    }
}

NotationDecl := Parser.Sequence(XmlNotationDecl,
    Name.Between(S),
    ExternalID.Or(PublicID).FollowedBy(S_Opt)
).Between("<!NOTATION", ">")

ExtParsedEnt := Parser.Sequence(Array,
    TextDecl.Optional(),
    Content
)
PEDef := EntityValue.Or(ExternalID)

class XmlParameterEntity {
    __New(Name, Def) {
        this.Name := Name
        this.Def := Def
    }
}

PEDecl := Parser.Sequence(XmlParameterEntity,
    Parser.String("%").Between(S).Then(Name),
    S.Then(PEDef)
).Between("<!ENTITY", ">")

; PEDecl := Parser.Sequence(Array,
;     Parser.String("<!ENTITY"),
;     S,
;     Parser.String("%"),
;     S,
;     Name,
;     S,
;     PEDef,
;     Parser.String(">")
; )

class XmlGEDecl {
    __New(Name, Def) {
        this.Name := Name
        this.Def := Def
    }
}

GEDecl := Parser.Sequence(XmlGEDecl,
    Name.Between(S),
    EntityDef.FollowedBy(S_Opt)
).Between("<!ENTITY", ">")

; GEDecl := Parser.Sequence(Array,
;     Parser.String("<!ENTITY"),
;     S,
;     Name,
;     S,
;     EntityDef,
;     S_Opt,
;     Parser.String(">")
; )
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

class XmlElementDeclaration {
    __New(Name, ContentSpec) {
        this.Name := Name
        this.ContentSpec := ContentSpec
    }
}

ElementDecl := Parser.Sequence(XmlElementDeclaration,
    Name.Between(S),
    ContentSpec.FollowedBy(S_Opt),
).Between("<!ELEMENT", ">")


; ElementDecl := Parser.Sequence(Array,
;     Parser.String("<!ELEMENT"),
;     S,
;     Name,
;     S,
;     ContentSpec,
;     S_Opt,
;     Parser.String(">")
; )

class Ext extends AquaHotkey {
    class String {
        DisplayParsedResult(Psr) => this.Parse(Psr).ToString().MsgBox()
    }
}

; TODO make XMLDecl mandatory by default;
;      allow omitting by option, because of spec

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

XmlChildren(Opt_CharData, More) {
    Result := Array()
    if (Opt_CharData.IsPresent) {
        Result.Push(Opt_CharData.Value)
    }
    for Item in More {
        Result.Push(Item.Elem)
        if (Item.Opt_CharData.IsPresent) {
            Result.Push(Item.Opt_CharData.Value)
        }
    }
    return Result
}

_Content := Parser.Sequence(XmlChildren,
    CharData.Optional(),
    Parser.Sequence(
        (Elem, Opt_CharData) => { Elem: Elem, Opt_CharData: Opt_CharData },
        Parser.AnyOf(
            Element,
            Reference,
            CData,
            PI,
            Comment
        ),
        CharData.Optional()
    ).ZeroOrMore()
)

class XmlAttDef {
    __New(Name, T, Decl) {
        this.Name := Name
        this.T := T
        this.Decl := Decl
    }
}

AttDef := Parser.Sequence(XmlAttDef, S.Then(Name), S.Then(AttType), S.Then(DefaultDecl))

; AttDef := Parser.Sequence(Array,
;     S, Name, S, AttType, S, DefaultDecl
; )

class XmlAttlistDecl {
    __New(Name, Defs) {
        this.Name := Name
        this.Defs := Defs
    }
}

AttlistDecl := Parser.Sequence(XmlAttlistDecl,
    S.Then(Name),
    AttDef.ZeroOrMore().FollowedBy(S_Opt)
).Between("<!ATTLIST", ">")

; AttlistDecl := Parser.Sequence(Array,
;     Parser.String("<!ATTLIST"),
;     S,
;     Name,
;     AttDef.ZeroOrMore(),
;     S_Opt,
;     Parser.String(">")
; )

MarkupDecl := Parser.AnyOf(
    ElementDecl,
    AttlistDecl,
    EntityDecl,
    NotationDecl,
    PI,
    Comment
)
IntSubset := Parser.AnyOf(MarkupDecl, declsep).ZeroOrMore()

class XmlDoctypeDecl {
    __New(Name, ExternalID, Subset) {
        this.Name := Name
        this.ExternalID := ExternalID
        this.Subset := Subset
    }
}

DoctypeDecl := Parser.Sequence(XmlDoctypeDecl,
    S.Then(Name),
    S.Then(ExternalID).Optional(),
    S_Opt.Then(
        IntSubset.Between("[", "]").FollowedBy(S_Opt).Optional()
    )
).Between("<!DOCTYPE", ">")

; DoctypeDecl := Parser.Sequence(Array,
;     Parser.String("<!DOCTYPE"),
;     S,
;     Name,
;     Parser.Sequence(Array, S, ExternalID).Optional(),
;     S_Opt,
;     Parser.Sequence(Array,
;         Parser.String("["),
;         intSubset,
;         Parser.String("]"),
;         S_Opt
;     ).Optional(),
;     Parser.String(">")
; )

class XmlProlog {
    static Strict := true

    __New(Header, Misc, DoctypeDecls) {
        if (XmlProlog.Strict) {
            Header := Header.OrElseThrow(UnsetError, "missing XML header")
        }
        this.Header := Header
        this.Misc := Misc
        this.DoctypeDecls := DoctypeDecls
    }
}

; TODO allow XMLDecl to be mandatory
Prolog := Parser.Sequence(XmlProlog,
    XMLDecl.Optional(),
    Misc.ZeroOrMore(),
    Parser.Sequence(Array,
        DoctypeDecl,
        Misc.ZeroOrMore()
    ).Optional()
)

class XmlDocument {
    __New(Prolog, Content, Misc) {
        this.Prolog := Prolog
        this.Content := Content
        this.Misc := Misc
    }

    static Parse(Str) {
        return (Str is VarRef) ? Document.Parse(Str) : Document.Parse(&Str)
    }
}

Document := Parser.Sequence(XmlDocument,
    Prolog,
    Element,
    Misc.ZeroOrMore()
)
.FollowedBy(Parser.End()) ; anchor ending so we don't drop erroneous "misc"s

ExtSubsetDecl := Parser.AnyOf(MarkupDecl, ConditionalSect, DeclSep).ZeroOrMore()
ExtSubset := Parser.Sequence(Array, TextDecl.Optional(), ExtSubsetDecl)

class XmlIncludeSection {
    __New(Decl) {
        this.Decl := Decl
    }
}

IncludeSect := ExtSubsetDecl.Between(
    Parser.Regex(Format("\Q<![{1}INCLUDE{1}[\E", Regex_S_0N)),
    Parser.String("]]>")
).Map(XmlIncludeSection)

; IncludeSect := Parser.Sequence(Array,
;     Parser.String("<!["), S_Opt, Parser.String("INCLUDE"), S_Opt, Parser.String("["),
;     ExtSubsetDecl,
;     Parser.String("]]>")
; )

class XmlIgnoreSection {
    __New(Decl) {
        this.Decl := Decl
    }
}

IgnoreSect := ExtSubsetDecl.Between(
    Parser.Regex(Format("\Q<![{1}IGNORE{1}[\E", Regex_S_0N)),
    Parser.String("]]>")
).Map(XmlIgnoreSection)

; IgnoreSect := Parser.Sequence(Array,
;     Parser.String("<!["),
;     S_Opt,
;     Parser.String("IGNORE"),
;     S_Opt,
;     Parser.String("["),
;     ExtSubsetDecl,
;     Parser.String("]]>")
; )

_ConditionalSect := IncludeSect.Or(IgnoreSect)

DllCall("QueryPerformanceFrequency", "int64*", &f := 0)
DllCall("QueryPerformanceCounter", "int64*", &t1 := 0)

Result := XmlDocument.Parse("
(
<?xml version="1.0" encoding="UTF-8"?>
<!-- The DOCTYPE defines the root element and encloses the internal DTD -->
<!DOCTYPE company [
    <!ELEMENT company (employee+)>
    <!ELEMENT employee (name, department, email)>
    <!ATTLIST employee id CDATA #REQUIRED>
    <!ELEMENT name (#PCDATA)>
    <!ELEMENT department (#PCDATA)>
    <!ELEMENT email (#PCDATA)>
]>

<company>
    <employee id="emp101">
        <name>Jane Doe</name>
        <department>Engineering</department>
        <email>jane.doe@example.com</email>
    </employee>
    <employee id="emp102">
        <name>John Smith</name>
        <department>Marketing</department>
        <email>john.smith@example.com</email>
        <!-- comment! -->
    </employee>
</company>
)")

DllCall("QueryPerformanceCounter", "int64*", &t2 := 0)

MsgBox(((t2 - t1) / f * 1000) . "ms")

Result.ToString().MsgBox()
