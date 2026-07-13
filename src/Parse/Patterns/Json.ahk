#Include "%A_LineFile%\..\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\..\Base\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\..\Base\Eq.ahk"
#Include "%A_LineFile%\..\..\..\Base\Hash.ahk"

#Include "%A_LineFile%\..\..\..\Interfaces\IArray.ahk"
#Include "%A_LineFile%\..\..\..\Interfaces\IMap.ahk"
#Include "%A_LineFile%\..\..\..\Interfaces\ISet.ahk"

#Include "%A_LineFile%\..\..\..\IO\Serial.ahk"
#Include "%A_LineFile%\..\..\..\IO\Serializer.ahk"

#Include "%A_LineFile%\..\..\Parser.ahk"

;@region Json

/**
 * @duck
 * 
 * Class used to represent JSON values and perform JSON parsing.
 * 
 * @module  <Parse/Patterns/Json>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class Json extends Class
{
    ;@region Support

    ; (see `<Base/DuckTypes/Nullable>`) for infos
    static Prototype.Prototype := this.Prototype

    ; (sets up the JSON parser as `Json.Parser { get; }`)
    static __New() {
        static Define := {}.DefineProp

        static Concat(Strs*) {
            Result := ""
            for S in Strs {
                Result .= S
            }
            return Result
        }

        static HexToChar(Hex) => Chr(Integer("0x" . Hex))

        static PropsToObj(Props*) {
            Result := {}
            for Prop in Props {
                Define(Result, Prop.Key, { Value: Prop.Value })
            }
            return Result
        }

        if (this != Json) {
            throw ValueError("this class must not be subclassed")
        }

        Ws := Parser.Whitespace()
        CommaDelim := Parser.String(",").Between(Ws)

        Escapes := Map(
            "\\", "\",
            '\"', '"',
            "\b", "`b",
            "\f", "`f",
            "\n", "`n",
            "\r", "`r",
            "\t", "`t"
        )
        NamedEscape := Parser.Regex("\\[`"\\bfnrt]").Map(S => Escapes[S])
        UnicodeEscape := Parser.Regex("\\u\K[0-9a-fA-F]{4}").Map(HexToChar)
        Char := Parser.Regex("[\x{20}-\x{21}\x{23}-\x{5B}\x{5D}-\x{10FFFF}]")

        Str := Parser.AnyOf(Char, NamedEscape, UnicodeEscape)
                     .ZeroOrMore(Concat, "")
                     .Between('"')

        Exponent := Parser.Regex("(?:e|E)\K(?:\+|-)?(?:0|[0-9][1-9]*)")
                          .Optional()
        
        Num := Parser.Sequence(
            (Num, Exponent) => Number(Num) * (10 ** Exponent.OrElse(0)),
            Parser.Regex("-?(?:0|[1-9][0-9]*)(?:\.[0-9])?"),
            Exponent)

        Value := Parser.Rule(&_Value)

        Prop := Parser.Sequence(
            (Key, Value) => { Key: Key, Value: Value },
            Str.FollowedBy(Parser.String(":").Between(Ws)),
            Value
        ).Between(Ws)

        Obj := Prop.ZeroOrMoreDelimitedBy(CommaDelim, PropsToObj)
                   .Between("{", "}")

        Arr := (Value.Between(Ws))
            .ZeroOrMoreDelimitedBy(CommaDelim)
            .Between("[", "]")

        T    := {}
        F    := {}
        Null := {}
        Define(Null, "ToJson", { Call: (_) => "null"  })
        Define(T,    "ToJson", { Call: (_) => "true"  })
        Define(F,    "ToJson", { Call: (_) => "false" })

        _Value := Parser.AnyOf(
            Parser.String("true").Map((*) => T),
            Parser.String("false").Map((*) => F),
            Parser.String("null").Map((*) => Null),
            Num, Str, Arr, Obj)

        Define(this, "Parser", { Get: (_) => Value })
        Define(this, "True", { Get: (_) => T })
        Define(this, "False", { Get: (_) => F })
        Define(this, "Null", { Get: (_) => Null })
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Construction

    /**
     * Creates a new duck type that represents JSON strings which contain
     * the given "inner type" `T`.
     * 
     * @constructor
     * @param   {Any}  T  inner type
     * @returns {Class}
     */
    static Call(T) {
        Cls := {}
        ObjSetBase(Cls, this.Prototype)
        ({}.DefineProp)(Cls, "T", { Get: (_) => T })
        return Cls
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Duck Types

    /**
     * Determines whether the given value is considered a valid JSON string.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * "{}".Is(Json)      ; true
     * "giraffe".Is(Json) ; false
     */
    static IsInstance(Val?) {
        return IsSet(Val) && (Val is Primitive)
            && (this.Parser).Matches(&Val)
    }

    /**
     * Determines whether the given value is considered a valid JSON string,
     * and that its contents match the specified "inner type".
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     * @example
     * "[1, 2, 3]".Is(Json([Integer, Integer, Integer])) ; ==> true
     * 
     * "foo".Is(Json(Number)) ; ==> false (not a JSON)
     */
    IsInstance(Val?) {
        if (!IsSet(Val) || !(Val is Primitive)) {
            return false
        }
        Result := (Json.Parser)(&Val)
        return Result.Ok && (this.T).IsInstance(Result.Value)
    }

    /**
     * Determines whether the given value is considered a subtype of this
     * `Json` instance.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     * @example
     * ; ==> true (because `Number.CanCastFrom(Integer)`)
     * Json(Number).CanCastFrom(Json(Integer))
     */
    CanCastFrom(Other?) {
        return IsSet(Other) && HasBase(Other, ObjGetBase(this))
            && (this.T).CanCastFrom(Other.T)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Commons

    /**
     * Determines whether this instance of `Json` is equal to the `Other`.
     * 
     * @param   {Any?}  Other  any value
     * @returns {Boolean}
     */
    Eq(Other?) {
        if (!IsSet(Other)) {
            return false
        }
        if (this == Other) {
            return true
        }
        return HasBase(Other, ObjGetBase(this)) && (this.T).Eq(Other.T)
    }

    /**
     * Returns a hash code for this instance of `Json`.
     * 
     * @returns {Integer}
     */
    HashCode() => (this.T).HashCode()

    /**
     * Returns a string representation of this `Json`.
     * 
     * @returns {String}
     * @example
     * Json(Number).ToString() ; "Json { Number }"
     */
    ToString() => Type(this) . " { " . String(this.T) . " }"

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Serialization

    /**
     * Serializes this instance of `Json` into binary.
     * 
     * @param   {OutputStream}  Output  output stream
     * @param   {Map}           Refs    previously seen objects
     */
    Serialize(Output, Refs) {
        (Object.Prototype.Serialize)(this, Output, Refs)
        Output.WriteObject(this.T, Refs)
    }

    /**
     * Reconstructs this instance of `Json` from binary.
     * 
     * @param   {InputStream}  Input  input stream
     * @param   {Map}          Refs   previously seen objects
     */
    Deserialize(Input, Refs) {
        Input.ReadObject(&T, Refs)
        (this.DefineProp)(this, "T", { Get: (_) => T })
    }

    ;@region
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

/**
 * Extensions related to {@link Json}.
 */
class AquaHotkey_ToJson extends AquaHotkey {
    ;@region Primitive

    class Primitive {
        /**
         * Parses this JSON string into an AHK value.
         * 
         * @returns {Any}
         * @example
         * "[1, 2, 3, 4]".ToJson() ; ==> [1, 2, 3, 4] (AHK array)
         */
        ParseToJson() => this.Parse(Json.Parser)

        /**
         * Converts this JSON string into an AHK value, applies the given
         * `Mapper` function, and then converts the result back into JSON.
         * 
         * @param   {Callable}  Mapper  mapper function
         * @returns {Json(Primitive)}
         */
        JsonTransform(Mapper) {
            GetMethod(Mapper)

            Result := (Json.Parser)(&this)
            if (!Result.Ok) {
                throw ValueError(Result.Err)
            }
            return Mapper(Result.Value).ToJson()
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Number

    class Number {
        /**
         * Converts this number into JSON (returns itself).
         * 
         * @returns {Json(Number)}
         */
        ToJson() => this
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region String

    class String {
        /**
         * Returns this string into JSON.
         * 
         * @returns {Json(String)}
         */
        ToJson() {
            static Escapes := Map(
                Chr(0), "\u0000",  Chr(1), "\u0001",
                Chr(2), "\u0002",  Chr(3), "\u0003",
                Chr(4), "\u0004",  Chr(5), "\u0005",
                Chr(6), "\u0006",  Chr(7), "\u0007",
                "`b", "\b", "`t", "\t", "`n", "\n",
                Chr(11), "\u000b", "`f", "\f", "`r", "\r",
                Chr(14), "\u000e", Chr(15), "\u000f",
                Chr(16), "\u0010", Chr(17), "\u0011",
                Chr(18), "\u0012", Chr(19), "\u0013",
                Chr(20), "\u0014", Chr(21), "\u0015",
                Chr(22), "\u0016", Chr(23), "\u0017",
                Chr(24), "\u0018", Chr(25), "\u0019",
                Chr(26), "\u001a", Chr(27), "\u001b",
                Chr(28), "\u001c", Chr(29), "\u001d",
                Chr(30), "\u001e", Chr(31), "\u001f",
                '"', '\"', "\", "\\"
            )

            VarSetStrCapacity(&Result, Integer(StrLen(this) * 1.05))
            Result .= '"'
            loop parse this {
                Result .= Escapes.Get(A_LoopField, A_LoopField)
            }
            Result .= '"'
            return Result
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region IMap

    class IMap {
        /**
         * Converts this {@link IMap} into JSON.
         * 
         * Map keys must explicitly be strings.
         * 
         * @returns {Json(Object)}
         */
        ToJson() {
            Result := "{"
            for Key, Value in this {
                if (!(Key is String)) {
                    throw TypeError("Expected a String",, Type(Key))
                }
                AquaHotkey_ToJson(&Key)
                AquaHotkey_ToJson(&Value)
                Result .= Key
                Result .= ":"
                Result .= Value
            }
            Result .= "}"
            return Result
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Object

    class Object {
        /**
         * Converts this object into a JSON string.
         * 
         * This object must be plain, i.e. its base must be `Object.Prototype`.
         * Only value properties are converted, everything else is ignored.
         * Proceed with caution, this method might easily cause infinite
         * recursion.
         * 
         * @returns {Json(Object)}
         */
        ToJson() {
            static GetProp := {}.GetOwnPropDesc
            if (!ObjGetBase(this) == Object.Prototype) {
                throw TypeError("Expected a plain object",, Type(this))
            }

            Result := "{"
            Count := 0
            for PropName in ObjOwnProps(this) {
                PropDesc := GetProp(this, PropName)
                if (!ObjHasOwnProp(PropDesc, "Value")) {
                    continue
                }
                if (++Count != 1) {
                    Result .= ","
                }
                Value := PropDesc.Value
                AquaHotkey_ToJson(&PropName)
                AquaHotkey_ToJson(&Value)
                Result .= PropName
                Result .= ":"
                Result .= Value
            }
            Result .= "}"
            return Result
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region IArray

    class IArray {
        /**
         * Converts this {@link IArray} into a JSON string.
         * 
         * `unset` is converted into `null`.
         * 
         * @returns {Json(Array)}
         */
        ToJson() {
            Result := "["
            for Value in this {
                if (A_Index != 1) {
                    Result .= ","
                }
                AquaHotkey_ToJson(&Value)
                Result .= Value
            }
            Result .= "]"
            return Result
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Support

    /**
     * Helper function that converts a value into a JSON string, with
     * additional `unset` support.
     * 
     * Only custom `.ToJson()` method should call this method.
     * 
     * @param   {VarRef<Any?>}  Val  (in, out) any value
     */
    static Call(&Val) {
        Val := IsSet(Val) ? Val.ToJson() : "null"
    }

    ;@endregion
}

;@endregion
