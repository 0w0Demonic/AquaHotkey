#Requires AutoHotkey v2.0
#Include <AquaHotkey\src\Parse\Parser>

IsAsciiWhitespace(c) {
    return IsSpace(c) && (c != "`v")
}

IsHtmlAttrNameChar(c) {
    return (!(c ~= "[\p{Cc} `"'>/=\x{FDD0}-\x{FDEF}]"))
            && ((Ord(c) & 0xFFFE) != 0xFFFE)
}

IsHtmlAttrValueChar(c) {
    return !(c ~= "[`"'=<>``]")
}

class Html extends Parser {
    static TagName() => this
            .OneOrMore(IsAlnum, "alnum")
            .FollowedBy(this.Whitespace())

    static Whitespace() {
        return this.ZeroOrMore(IsAsciiWhitespace, "ASCII whitespace")
    }

    static AttributeName() {
        return this.OneOrMore(
                IsHtmlAttrNameChar,
                "HTML attribute name character")
    }

    static AttributeValue() {
        static Equals := this.String("=").Between(Html.Whitespace())

        static Unquoted := this.OneOrMore(
                (c) => !IsAsciiWhitespace(c) && IsHtmlAttrValueChar(c),
                "Unquoted attribute value")

        static SingleQuoted := this.OneOrMore(
                IsHtmlAttrValueChar,
                "Single-quoted attribute value").Between("'")

        static DoubleQuoted := this.OneOrMore(
                IsHtmlAttrValueChar,
                "Double-quoted attribute value").Between('"')

        return Equals.Then(this.AnyOf(
            DoubleQuoted,
            SingleQuoted,
            Unquoted
        )).OrElse("") ; empty attribute (implicit empty string as value)
    }
    
    static Attribute() {
        return this.Sequence(
            HtmlAttribute,
            this.AttributeName(),
            this.AttributeValue()
        )
    }

    static StartTag() {
        return this.Sequence(
            HtmlTag,
            this.String("<").Then(this.TagName()),
            this.Attribute().AtLeastOnceDelimitedBy(this.Whitespace())
                    .FollowedBy(this.Whitespace())
                    .FollowedBy(this.String(">")),
        )
    }

    static EndTag() {
        return this.TagName().Between(
                this.String("</"),
                this.Whitespace().FollowedBy(this.String(">"))
        )
    }

    static Comment() {
        IsValidComment(Str) {
            return SubStr(Str, 1, 1) != ">"
                && SubStr(Str, 1, 2) != "->"
                && !InStr(Str, "<!--")
                && !InStr(Str, "-->")
                && !InStr(Str, "--!>")
                && SubStr(Str, -3, 3) != "<!-"
        }

        return this.Regex("s).*?(?=-->)")
            .Between("<!--", "-->")
            .SuchThat(IsValidComment, "valid HTML comment contents")
    }
}

class HtmlTag {
    __New(Tag, Attributes) {
        if (!(Tag is String)) {
            throw TypeError("Expected a String",, Type(Tag))
        }
        for Attr in Attributes {
            if (!(Attr is HtmlAttribute)) {
                throw TypeError("Expected a HtmlAttribute",, Type(Attr))
            }
        }

        ; TODO
        this.Tag        := Tag
        this.Attributes := Attributes
    }
}

class HtmlAttribute {
    __New(Key, Value?) {
        ; TODO
        this.Key := Key
        this.Value := Value
    }
}

#Include <AquaHotkey\src\Base\Primitives> ; for `.MsgBox()`

; "<!-- this is a test y'all -->"
;     .Parse(Html.Comment())
;     .ToString()
;     .ToClipboard()
;     .MsgBox()

; HtmlTag {
;   Attributes: [
;     HtmlAttribute { Key: id, Value: head },
;     HtmlAttribute { Key: class, Value: head with buttons }
;   ],
;   Tag: header
; }

; '<header id="head" class="head with buttons">'
;     .Parse(Html.StartTag())
;     .ToString()
;     .ToClipboard()
;     .MsgBox()

Choice(Psrs*) => Parser.AnyOf(Psrs*)
AtLeastThree(Str) => Parser.String(Str)
        .AtLeastOnceDelimitedBy(Parser.Whitespace())
        .SuchThat(A => A.Length >= 3, "at least 3 characters required")

HorizontalLine := Parser.Whitespace()
    .SuchThat(s => StrLen(s) < 4, "less than 4 characters indentation")
    .FollowedBy((["-", "*", "_"]).Map(AtLeastThree).Collect(Choice))
    .FollowedBy(Parser.Whitespace())
    .FollowedBy(Parser.Regex("\v?"))

MsgBox(HorizontalLine.Matches(&Input := "   -  -     -  "))