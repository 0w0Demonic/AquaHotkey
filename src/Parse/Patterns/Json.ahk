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

; TODO add marker class to allow comments inside the JSON file

;@region Json

/**
 * @duck
 * 
 * Class used to represent JSON values and perform JSON parsing.
 * 
 * This class supports {@link AquaHotkey_DuckTypes duck types} and is a
 * type wrapper. To determine whether a string is a valid JSON, you
 * can use `Json.IsInstance(Str)` or `Str.Is(Json)`. To determine
 * whether the string is a valid JSON with specific contents, you can use
 * instances of `Json(T)`, where `T` is the inner type that the JSON
 * represents.
 * 
 * ```ahk
 * Object().Is(Json) ; false (not a JSON string)
 * 
 * "[1, 2, 3]".Is(Json) ; ==> true
 * "[1, 2, 3]".Is(Json([Integer, Integer, Integer])) ; ==> true
 * ```
 * 
 * Also understands how different types are related to each other:
 * 
 * ```ahk
 * Json(Any).CanCastFrom(Json({ Key: String })) ; ==> true
 * ```
 * 
 * To convert a JSON string into an AHK value, use `Str.ParseToJson()`
 * or `Str.Parse(Json.Parser)`. Use AHK's continuation section to your
 * advantage.
 * 
 * ```ahk
 * "
 * (
 * {
 *   "Value": 42
 * }
 * )".ParseToJson() ; { Value: 42 }
 * ```
 * 
 * Values `Json.True`, `Json.False` and `Json.Null` are used to represent JSON
 * `true`/`false`/`null`. You should use `.Is(Json.Null)` to assert that
 * something is not null in the context of JSON. `Json.Boolean` is a type that
 * represents either `Json.True` or `Json.False`.
 *
 * You can convert `Json.True` and `Json.False` into booleans by using
 * `.AsBoolean()`.
 * 
 * ```ahk
 * N := "null".ParseJson()
 * T := "true".ParseJson()
 * F := "false".ParseJson()
 * 
 * N.Is(Json.Null) ; true
 * 
 * T.Is(Json.True)    ; true
 * F.Is(Json.Boolean) ; true
 * 
 * ; `Json.True`/`Json.False` are subtypes of `Json.Boolean`
 * (Json.Boolean).CanCastFrom(Json.True)
 * ```
 * 
 * This class supports JSONC, regular JSON but with C/C++-style comments, a
 * feature that can be activated and deactivated by calling
 * `Json.EnableComments()` and `Json.DisableComments()`. `Json.AllowsComments`
 * holds the current option, and is readonly.
 * 
 * ```ahk
 * Json.EnableComments()
 * "
 * (
 * // this is a comment
 * { "Key": /* this is fine too */ "Value" }
 * )".ParseJson() ; { Key: Value }
 * ```
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
        static Define := ({}.DefineProp)
        static DefineGetter(Obj, Name, Getter) {
            Define(Obj, Name, { Get: Getter })
        }
        static DefineConstGetter(Obj, Name, Value) {
            DefineGetter(Obj, Name, Constantly(Value))
        }
        static DefineMethod(Obj, Name, Method) {
            Define(Obj, Name, { Call: Method })
        }
        static DefineConstMethod(Obj, Name, Value) {
            DefineMethod(Obj, Name, Constantly(Value))
        }
        static Constantly(Value) => (_) => (Value)

        /**
         * String concat.
         * 
         * @param   {String*}  Strs  strings
         * @returns {String}
         */
        static Concat(Strs*) {
            Result := ""
            for S in Strs {
                Result .= S
            }
            return Result
        }

        /**
         * 4 hex chars code point (Unicode escape) to corresponding character.
         * 
         * @param   {String}  Hex  4 hex digits
         * @returns {String}
         */
        static HexToChar(Hex) => Chr(Integer("0x" . Hex))

        /**
         * Properties (key-value pairs) to a single plain object.
         * 
         * @param   {Object*}  Props  object properties
         * @returns {Object}
         */
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

        static Ws := Parser.Rule(&_Ws)

        static WsWithoutComments := Parser.Regex("[\t\r\n ]*")
        static WsWithComments := Parser.Regex("s)(?:[\t\r\n ]|//\V*+|/\*.*?\*/)*")

        static _Ws := (IsSet(AquaHotkey_cfg_Json_AllowComments))
            ? WsWithComments
            : WsWithoutComments
        
        static Json_EnableComments(_) {
            _Ws := WsWithComments
        }
        static Json_DisableComments(_) {
            _Ws := WsWithoutComments
        }

        Define(this, "AllowsComments", { Get: (_) => (_Ws == WsWithComments )})
        DefineMethod(this, "EnableComments", Json_EnableComments)
        DefineMethod(this, "DisableComments", Json_DisableComments)

        static CommaDelim := Parser.String(",").Between(Ws)

        static Escapes := Map(
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

        JsonStr := Parser.AnyOf(Char, NamedEscape, UnicodeEscape)
            .ZeroOrMore(Concat, "")
            .Between('"')

        Exponent := Parser
            .Regex("(?:e|E)\K(?:\+|-)?(?:0|[0-9][1-9]*)")
            .Optional()
        
        JsonNum := Parser.Sequence(
            (Num, Exponent) => Number(Num) * (10 ** Exponent.OrElse(0)),
            Parser.Regex("-?(?:0|[1-9][0-9]*)(?:\.[0-9])?"),
            Exponent)

        JsonValue := Parser.Rule(&_JsonValue)

        JsonProp := Parser.Sequence(
            (Key, Value) => { Key: Key, Value: Value },
            JsonStr.FollowedBy(Parser.String(":").Between(Ws)),
            JsonValue
        ).Between(Ws)

        JsonObj := JsonProp
            .ZeroOrMoreDelimitedBy(CommaDelim, PropsToObj)
            .Between("{", "}")

        JsonArr := (JsonValue.Between(Ws))
            .ZeroOrMoreDelimitedBy(CommaDelim)
            .Between("[", "]")

        JsonTrue  := {}
        JsonFalse := {}
        JsonNull  := {}
        JsonBool  := {}
        JsonBool_IsInstance(_, Val?) {
            return IsSet(Val)
                && ((Val == JsonTrue)
                 || (Val == JsonFalse))
        }
        JsonBool_CanCastFrom(_, Val?) {
            return IsSet(Val)
                && ((Val == JsonBool)
                 || (Val == JsonTrue)
                 || (Val == JsonFalse))
        }
        DefineMethod(JsonBool, "IsInstance", JsonBool_IsInstance)
        DefineMethod(JsonBool, "CanCastFrom", JsonBool_CanCastFrom)

        DefineConstMethod(JsonTrue, "AsBoolean", true)
        DefineConstMethod(JsonFalse, "AsBoolean", false)

        DefineConstMethod(JsonNull,  "ToJson", "null")
        DefineConstMethod(JsonTrue,  "ToJson", "true")
        DefineConstMethod(JsonFalse, "ToJson", "false")

        _JsonValue := Parser.AnyOf(
            Parser.String("true").Map((*) => JsonTrue),
            Parser.String("false").Map((*) => JsonFalse),
            Parser.String("null").Map((*) => JsonNull),
            JsonNum, JsonStr, JsonArr, JsonObj
        ).Between(Ws)

        JsonParser := JsonValue.Between(Ws)

        DefineConstGetter(this, "Parser", JsonParser)
        DefineConstGetter(this, "True", JsonTrue)
        DefineConstGetter(this, "False", JsonFalse)
        DefineConstGetter(this, "Null", JsonNull)
        DefineConstGetter(this, "Boolean", JsonBool)
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
    ;@region Conversion

    /**
     * Converts an AHK value into JSON.
     * 
     * @param   {Any}  Value  any value
     * @returns {String}
     */
    static Stringify(Value) => Value.ToJson()

    /**
     * Converts a JSON string into an AHK value.
     * 
     * @param   {String}  Str  JSON string
     * @returns {Any}
     */
    static Load(Str) {
        static Psr := (Json.Parser)
        return Psr.Parse(&Str)
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
        static Psr := (Json.Parser)
        return IsSet(Val)
            && (Val is Primitive)
            && Psr.Matches(&Val)
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
        static Psr := (Json.Parser)
        if (!IsSet(Val) || !(Val is Primitive)) {
            return false
        }
        Result := Psr(&Val)
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

; TODO construction of more complex objects through `.FromJson()`

/**
 * Extensions related to {@link Json}.
 */
class AquaHotkey_ToJson extends AquaHotkey {
    ;@region Any

    class Any {
        /**
         * Unsupported `.ToJson()` method.
         * 
         * @returns {String}
         */
        ToJson() {
            throw MethodError("not applicable")
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Primitive

    class Primitive {
        /**
         * Parses this JSON string into an AHK value.
         * 
         * @returns {Any}
         * @example
         * "[1, 2, 3, 4]".ToJson() ; ==> [1, 2, 3, 4] (AHK array)
         */
        ParseToJson() {
            static Psr := (Json.Parser)
            return Psr.Parse(&this)
        }

        /**
         * Converts this JSON string into an AHK value, applies the given
         * `Mapper` function, and then converts the result back into JSON.
         * 
         * @param   {(Any) => Any}  Mapper  mapper function
         * @returns {String}
         */
        JsonTransform(Mapper) {
            static Psr := (Json.Parser)
            return Mapper(Psr.Parse(&this)).ToJson()
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
