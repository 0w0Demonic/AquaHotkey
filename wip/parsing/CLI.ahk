#Requires AutoHotkey v2.0

#Include <AquaHotkey\src\Parse\Parser>

class CliOption extends Parser {
    static IsValidFlag(&Name) {
        if (Name ~= "^$|\s") {
            return false
        }
        if (SubStr(Name, 1, 1) != "-") {
            Name := "-" . Name
        }
        return true
    }

    static Flag(Name) {
        if (!this.IsValidFlag(&Name)) {
            throw ValueError("Not a valid flag",, Name)
        }
        return this.Cast(this.String(Name))
    }

    static Value() => this.Whitespace().Then(this.AnyOf(
        this.Regex('"([^"]*+)"', (Match) => Match[1]),
        this.Regex("\K[^-]\S*+")
    ))

    static KeyValue(Name) {
        return this.Sequence(Array, this.Flag(Name), this.Value())
    }

    static KeyMultiValue(Name) {
        return this.Sequence(Array, this.Flag(Name),
            this.Value().AtLeastOnceDelimitedBy(this.Whitespace())
        )
    }

    static JavaOption(Prefix) {
        static Equals := this.String("=")
        
        if (!this.IsValidFlag(&Prefix)) {
            throw ValueError("Not a valid flag",, Prefix)
        }
        return this.Sequence(
            Array,
            this.String(Prefix),
            this.Regex("[\w\.]++").FollowedBy(Equals),
            this.Value()
        )
    }

    static Subcommand(Name, Psr) {
        static Ws := this.Whitespace()
        if (!(Name is String)) {
            throw TypeError("Expected a String",, Type(Name))
        }
        if (Name == "") {
            throw ValueError("string is empty")
        }
        GetMethod(Psr)
        return this.Sequence(Array, this.String(Name).FollowedBy(Ws), Psr)
    }
}

#Include <AquaHotkey\src\Base\Primitives>

; OptionD := CliOption.JavaOption("D")
; 
; "-Djava.awt.DoSomething=false".Parse(OptionD).ToString().MsgBox()

GitCommit := CliOption.Subcommand("commit", CliOption.KeyValue("m"))

'commit -m "Fixed the fix..."'.Parse(GitCommit).ToString().MsgBox()