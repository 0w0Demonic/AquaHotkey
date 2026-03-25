#Requires AutoHotkey v2.0

#Include <AquaHotkey\src\Base\ToString>

class MatchResult {
    Ok => (this is MatchResult.Success)

    class Success extends MatchResult {
        __New(Value, Pos) {
            this.DefineProp("Value", { Get: (_) => Value })
            this.DefineProp("Pos",   { Get: (_) => Pos   })
        }
        
        ToString() => (Object.Prototype.ToString)({
            base: ObjGetBase(this),
            Value: String(this.Value),
            Pos: this.Pos
        }).ToString()
    }
    
    class Failure extends MatchResult {
        __New(Message, Pos) {
            this.DefineProp("Message", { Get: (_) => Message })
            this.DefineProp("Pos",     { Get: (_) => Pos     })
        }

        ToString() => (Object.Prototype.ToString)({
            base: ObjGetBase(this),
            Message: this.Message,
            Pos: this.Pos
        }).ToString()
    }
}