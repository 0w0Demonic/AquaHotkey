#Requires AutoHotkey v2.0

#Include <AquaHotkey\src\Parse\Parser>
#Include <AquaHotkey\src\Net\Uri>

class UriTemplate {
    
}

class UriTemplateVar {
    __New(Name, Prefix?) {
        this.Name := Name
        if (!IsSet(Prefix)) {
            return
        }
        if (Prefix is Integer) {
            this.Prefix := Prefix
            ObjSetBase(this, UriTemplateVar.Prefix.Prototype)
        } else {
            ObjSetBase(this, UriTemplateVar.Explode.Prototype)
        }
    }

    class Explode extends UriTemplateVar {

    }
    class Prefix extends UriTemplateVar {

    }
}

class UriTemplateExpr {
    __New(Operator, VariableList) {
        static Bases := Map(
            "", UriTemplateExpr.Simple.Prototype,
            "+", UriTemplateExpr.Reserved.Prototype,
            "#", UriTemplateExpr.Fragment.Prototype,
            ".", UriTemplateExpr.NameLabel.Prototype,
            "/", UriTemplateExpr.Path.Prototype,
            ";", UriTemplateExpr.PathParam.Prototype,
            "?", UriTemplateExpr.Query.Prototype,
            "&", UriTemplateExpr.QueryContinuation.Prototype,
        )
        ObjSetBase(this, Bases[Operator])
        this.VariableList := VariableList
    }
    class Simple extends UriTemplateExpr {

    }
    class Reserved extends UriTemplateExpr {

    }
    class Fragment extends UriTemplateExpr {

    }
    class NameLabel extends UriTemplateExpr {

    }
    class Path extends UriTemplateExpr {

    }
    class PathParam extends UriTemplateExpr {

    }
    class Query extends UriTemplateExpr {

    }
    class QueryContinuation extends UriTemplateExpr {

    }
}


Operator := Parser.Regex("[+#./;&?=,!@|]?")

Explode := Parser.String("*") ; <-- placeholder for now
Prefix := Parser.Regex(":\K[1-9]\d{0,3}").Map(Integer)

ModifierLevel4 := Explode.Or(Prefix)

VarChar := Parser.Regex("i)(?>\w|%[\da-f]{2})+")

VarName := VarChar.AtLeastOnceDelimitedBy(".")

VarSpec := VarName.OptionallyFollowedBy(ModifierLevel4, UriTemplateVar)

VariableList := VarSpec.AtLeastOnceDelimitedBy(",")

Expression := Parser.Sequence(
    UriTemplateExpr,
    Operator,
    VariableList
).Between("{", "}")

#Include <AquaHotkey\src\Base\ToString>
#Include <AquaHotkey\src\Base\Primitives>

Expression.Parse(&Str := "{;var:3,foo.prop:344,a*}").ToString().MsgBox()