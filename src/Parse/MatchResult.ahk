/**
 * Result type used by {@link Parser}.
 * 
 * @module  <Parser/MatchResult>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class MatchResult {
    /**
     * Determines whether the match was successful
     * 
     * @readonly
     * @type {Boolean}
     */
    Ok => (this is MatchResult.Success)

    /**
     * A successful match.
     */
    class Success extends MatchResult {
        /**
         * Constructs a new successful match containing the return value and
         * the starting position for the next parser.
         * 
         * @constructor
         * @param   {Any}      Value  any value
         * @param   {Integer}  Pos    next starting position in the string
         */
        __New(Value, Pos) {
            this.DefineProp("Value", { Get: (_) => Value })
            this.DefineProp("Pos",   { Get: (_) => Pos   })
        }
        
        /**
         * Returns a string representation of this match.
         * 
         * @returns {String}
         */
        ToString() {
            Str := (Object.Prototype.ToString)({
                base: ObjGetBase(this),
                Value: String(this.Value),
                Pos: this.Pos
            }).ToString()

            this.DefineProp("ToString", { Call: (_) => Str })
            return Str
        }
    }

    /**
     * A failed match.
     */
    class Failure extends MatchResult {
        /**
         * Constructs a new failed match containing an error message and the
         * starting position of the failed parser.
         * 
         * @constructor
         * @param   {String}   Message  error message
         * @param   {Integer}  Pos      string position of failed parser
         */
        __New(Message, Pos) {
            this.DefineProp("Message", { Get: (_) => Message })
            this.DefineProp("Pos",     { Get: (_) => Pos     })
        }

        /**
         * Returns a string representation of this match.
         * 
         * @returns {String}
         */
        ToString() {
            Str := (Object.Prototype.ToString)({
                base: ObjGetBase(this),
                Message: this.Message,
                Pos: this.Pos
            }).ToString()

            this.DefineProp("ToString", { Call: (_) => Str })
            return Str
        }
    }
}
