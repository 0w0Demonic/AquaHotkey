#Include <AquaHotkey\src\Parse\Parser>
#Include <AquaHotkeyX>

StrConcat(Strs*) {
    Result := ""
    for Str in Strs {
        Result .= Str
    }
    return Result
}

Char := "[\x{09}\x{0A}\x{0D}\x{20}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]"

XmlChar := Parser.Regex("[\x{09}\x{0A}\x{0D}\x{20}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]")
Whitespace := Parser.Regex("[ \t\r\n]+")

NameStartChar := Parser.Regex("[:A-Z_a-z\x{C0}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{2FF}\x{370}-\x{37D}\x{37F}-\x{1FFF}\x{200C}-\x{200D}\x{2070}-\x{218D}\x{2C00}-\x{2FEF}\x{3011}-\x{D7FF}\x{F900}-\x{FDCF}\x{FDF0}-\x{FFFD}\x{10000}-\x{EFFFF}]")
NameChar := Parser.AnyOf(NameStartChar, Parser.Regex("[\-\.0-9\x{B7}\x{0300}-\x{036F}\x{203F}-\x{2040}]"))
Name := Parser.Sequence(Array, NameStartChar, NameChar.AtLeastOnce())
Names := Name.AtLeastOnceDelimitedBy(" ")

Nmtoken := NameChar.AtLeastOnce()
Nmtokens := Nmtoken.AtLeastOnceDelimitedBy(" ")

"foo".Parse(Nmtokens).ToString().MsgBox()


; [9]   	EntityValue	   ::=   	'"' ([^%&"] | PEReference | Reference)* '"'
; |  "'" ([^%&'] | PEReference | Reference)* "'"
; [10]   	AttValue	   ::=   	'"' ([^<&"] | Reference)* '"'
; |  "'" ([^<&'] | Reference)* "'"
; [11]   	SystemLiteral	   ::=   	('"' [^"]* '"') | ("'" [^']* "'")
; [12]   	PubidLiteral	   ::=   	'"' PubidChar* '"' | "'" (PubidChar - "'")* "'"
; [13]   	PubidChar	   ::=   	#x20 | #xD | #xA | [a-zA-Z0-9] | [-'()+,./:=?;!*#@$_%]
; [14]   	CharData	   ::=   	[^<&]* - ([^<&]* ']]>' [^<&]*)
; [15]   	Comment	   ::=   	'<!--' ((Char - '-') | ('-' (Char - '-')))* '-->'

PubidChar := Parser.Regex("[ \r\na-zA-Z0-9\-'()+,\./:=?;!*#@$_%]")

PubidLiteral := Parser.AnyOf(
    PubidChar.ZeroOrMore(StrConcat, "").Between('"'),
    PubidChar.ZeroOrMore(StrConcat, "").Between("'").SuchThat(S => !InStr(S, "'"))
)

SystemLiteral := Parser.Regex("
(
"[^"]*"|'[^']*'
)")

Comment := Parser.Regex("
(
Ssx)
<!-- \K

(?:
    (?=-->(*ACCEPT))
  | --(*COMMIT)(*FAIL)
  | -
  | .)*
)").Map(XmlComment)

class XmlComment {
    __New(Str) {
        ({}.DefineProp)(this, "Value", { Get: (_) => Str })
    }

    ToString() => "<!--" . this.Value . "-->"
}

PITarget := Name.SuchThat(S => S != "xml")

Chars_0_n := XmlChar.ZeroOrMore(Array, "")

; [16]   	PI	   ::=   	'<?' PITarget (S (Char* - (Char* '?>' Char*)))? '?>'
; [17]   	PITarget	   ::=   	Name - (('X' | 'x') ('M' | 'm') ('L' | 'l'))


("<!-- Hello, world! -->").Parse(Comment).ToString().MsgBox()


; [18]   	CDSect	   ::=   	CDStart CData CDEnd
; [19]   	CDStart	   ::=   	'<![CDATA['
; [20]   	CData	   ::=   	(Char* - (Char* ']]>' Char*))
; [21]   	CDEnd	   ::=   	']]>'

CDSect := Parser.Regex("s)<![CDATA[\K" . Char . "*?(?=]]>)")


