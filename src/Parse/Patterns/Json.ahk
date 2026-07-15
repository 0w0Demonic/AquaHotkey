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
 * This class offers great support for {@link AquaHotkey_DuckTypes duck types}
 * and can be used to validate JSON, optionally checking the values contained
 * inside the JSON.
 * 
 * Use `Json.IsInstance(Str)` or `Str.Is(Json)` to determine whether `Str`
 * is a valid JSON document. The JSON class can be used as type wrapper: you
 * can use e.g. `Str.Is(Json({ Value: String }))` to determine that `Str`
 * string is a valid JSON containing an object `{ Value: String }`.
 * 
 * ```ahk
 * Object().Is(Json) ; false (not a JSON string)
 * 
 * "[1, 2, 3]".Is(Json) ; ==> true
 * "[1, 2, 3]".Is(Json([Integer, Integer, Integer])) ; ==> true
 * ```
 * 
 * This class also understands how different types are related to each other:
 * 
 * ```ahk
 * Json(Any).CanCastFrom(Json({ Key: String })) ; ==> true
 * ```
 * 
 * To convert a JSON string into an AHK value, use `Str.ParseJson()`
 * or `Str.Parse(Json.Parser)`. Alternatively, you can use `Json.Load(Str)`.
 * 
 * When deserializing string literals, you should use AHK's continuation
 * section to your advantage.
 * 
 * ```ahk
 * "
 * (
 * {
 *   "Value": 42
 * }
 * )".ParseJson() ; { Value: 42 }
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
 * holds the current option (as a boolean), and is readonly.
 * 
 * ```ahk
 * Json.EnableComments()
 * if (Json.AllowsComments) {
 *     MsgBox("comments are enabled!")
 * }
 * 
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
    ;@region Booleans

    /**
     * JSON boolean values `true` and `false`. Supports
     * {@link AquaHotkey_DuckTypes duck types}.
     */
    class Boolean extends Any {
        /**
         * Determines whether the given value is considered a JSON boolean.
         * This is only true, if the value is `Json.True` or `Json.False`.
         * 
         * @param   {Any?}  Val  any value
         * @returns {Boolean}
         * @example
         * (Json.True).Is(Json.Boolean) ; true
         * (Json.False).Is(Json.Boolean) ; true
         */
        IsInstance(Val?) => IsSet(Val) && HasBase(Val, this)

        /**
         * Determines whether the given value is considered a subtype.
         * 
         * @param   {Any?}  Val  any value
         * @returns {Boolean}
         */
        CanCastFrom(Val?) => IsSet(Val) && ((this == Val) || HasBase(Val, this))
    }

    /**
     * JSON boolean `true`. During initialization, this class is renamed to
     * `Json.True`.
     */
    class __True extends Json.Boolean {
        /**
         * Determines whether the given value equals `Json.True`.
         * 
         * @param   {Any?}  Val  any value
         * @returns {Boolean}
         * @example
         * (Json.True).Is(Json.True) ; true
         */
        IsInstance(Val?) => IsSet(Val) && (this == Val)

        /**
         * Converts this JSON boolean into an AHK boolean (`true` or `1`).
         * 
         * @returns {Boolean}
         */
        ToBoolean() => true

        /**
         * Converts this value into a JSON string (`true`).
         * 
         * @returns {String}
         */
        ToJson() => "true"

        /**
         * Converts this value into a string.
         * 
         * @returns {String}
         */
        ToString() => "Json.True"
    }

    /**
     * JSON boolean `false`. During initialization, this class is renamed to
     * `Json.False`.
     */
    class __False extends Json.Boolean {
        /**
         * Determines whether the given value is equal to `Json.False`.
         * 
         * @param   {Any?}  Val  any value
         * @returns {Boolean}
         * @example
         * (Json.False).Is(Json.False) ; true
         */
        IsInstance(Val?) => IsSet(Val) && (this == Val)
        
        /**
         * Converts this JSON boolean into an AHK boolean (`false` or `0`).
         * 
         * @returns {Boolean}
         */
        ToBoolean() => false

        /**
         * Converts this JSON boolean into a JSON string (`false`).
         * 
         * @returns {String}
         */
        ToJson() => "false"

        /**
         * Converts this value into a string.
         * 
         * @returns {String}
         */
        ToString() => "Json.True"
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Null

    /**
     * Json value `null`.
     */
    class Null extends Any {
        /**
         * Determines whether the given value is equal to `Json.Null`.
         * @param   {Any}  Val  any value
         * @returns {Boolean}
         */
        IsInstance(Val?) => !IsSet(Val) || (this == Val)

        /**
         * Determines whether the given value is equal to `Json.Null`.
         * @param   {Any}  Val  any value
         * @returns {Boolean}
         */
        CanCastFrom(Val?) => !IsSet(Val) || (this == Val)

        /**
         * Converts this null value into JSON (`null`).
         * 
         * @returns {String}
         */
        ToJson() => "null"

        /**
         * Converts this null value into a string.
         * 
         * @returns {String}
         */
        ToString() => "Json.Null"
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Support

    ; (see `<Base/DuckTypes/Nullable>`) for infos
    static Prototype.Prototype := this.Prototype

    ; (sets up the JSON parser as `Json.Parser { get; }`)
    static __New() {
        static Define  := {}.DefineProp
        static GetProp := {}.GetOwnPropDesc
        static Delete  := {}.DeleteProp

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

        static Rename(Obj, OldName, NewName) {
            PropDesc := GetProp(Obj, OldName)
            Delete(Obj, OldName)
            Define(Obj, NewName, PropDesc)
        }
        
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

        Rename(this, "__True", "True")
        Rename(this, "__False", "False")

        DefineConstGetter(this, "True", this.True.Prototype)
        DefineConstGetter(this, "False", this.False.Prototype)
        DefineConstGetter(this, "Null", this.Null.Prototype)

        static Ws := Parser.Rule(&_Ws)

        static NoComments := Parser.Regex("[\t\r\n ]*")
        static Comments := Parser.Regex("s)(?:[\t\r\n ]|//\V*+|/\*.*?\*/)*")

        static _Ws := (IsSet(AquaHotkey_cfg_Json_AllowComments))
            ? WsWithComments
            : NoComments
        
        static Json_EnableComments(_) {
            _Ws := Comments
        }
        static Json_DisableComments(_) {
            _Ws := NoComments
        }

        ; TODO make this mutable?
        static Json_AllowsComments(_) => (_Ws == WsWithComments)

        DefineGetter(this, "AllowsComments", Json_AllowsComments)
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

        _JsonValue := Parser.AnyOf(
            Parser.String("true").Map((*) => Json.True),
            Parser.String("false").Map((*) => Json.False),
            Parser.String("null").Map((*) => Json.Null),
            JsonNum, JsonStr, JsonArr, JsonObj
        ).Between(Ws)

        JsonParser := JsonValue.Between(Ws)

        DefineConstGetter(this, "Parser", JsonParser)
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

    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

; TODO construction of more complex objects through `.FromJson()`

/**
 * Extensions related to {@link Json}.
 */
class AquaHotkey_Json extends AquaHotkey {
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

        /**
         * Unsupported `.CastFromJson()` method.
         * 
         * @param   {Any}  Val  any value
         * @returns {Any}
         */
        CastFromJson(Val) {
            throw MethodError("not applicable")
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Class

    class Class {
        /**
         * Asserts that the given JSON value is instance of this class,
         * returning the value itself.
         * 
         * @param   {Any}  Val  any value
         * @returns {Any}
         */
        CastFromJson(Val) {
            if (!(Val is this)) {
                throw TypeError("Expected type " . this.Prototype.__Class,,
                        Type(Val))
            }
            return Val
        }

        ; TODO add `.ToJson()`?
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region IMap

    class IMap {
        /**
         * Reconstructs a map from the given JSON value. The value must be a
         * plain object.
         * 
         * @param   {Any}  Val  any value
         * @returns {Any}
         */
        static CastFromJson(Val) {
            static GetProp := {}.GetOwnPropDesc

            if (ObjGetBase(Val) != Object.Prototype) {
                throw TypeError("Expected a plain object",, Type(Val))
            }

            Arr := Array()
            for PropName in ObjOwnProps(Val) {
                PropDesc := GetProp(Val, PropName)
                if (!ObjHasOwnProp(PropDesc, "Value")) {
                    continue
                }
                Arr.Push(PropName, PropDesc.Value)
            }
            return this(Arr*)
        }

        /**
         * Converts this {@link IMap} into JSON.
         * 
         * Map keys must explicitly be strings.
         * 
         * @returns {Json(Object)}
         */
        ToJson() {
            ; TODO allow casting numbers to strings?
            Result := "{"
            for Key, Value in this {
                if (!(Key is String)) {
                    throw TypeError("Expected a String",, Type(Key))
                }
                AquaHotkey_Json(&Key)
                AquaHotkey_Json(&Value)
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
    ;@region IArray

    class IArray {
        /**
         * Reconstructs an array from the given JSON value.
         * 
         * @param   {Any}  Val  any value
         * @returns {Any}
         */
        static CastFromJson(Val) {
            if (ObjGetBase(Val) != Array.Prototype) {
                throw TypeError("Expected a plain Array",, Type(Val))
            }
            return this(Val*)
        }

        /**
         * Constructs an array from a JSON value, based on the contents of
         * this array. The JSON value must be a plain array of the same length.
         * 
         * @param   {Any}  Val  any value
         * @returns {Any}
         */
        CastFromJson(Val) {
            if (ObjGetBase(Val) != Array.Prototype) {
                throw TypeError("Expected a plain array",, Type(Val))
            }
            if (Val.Length != this.Length) {
                throw ValueError("invalid size (TODO error message)")
            }

            ; TODO figure out what to do with `unset`
            Result := IArray.BasedFrom(this)
            loop (this.Length) {
                Result.Push(this[A_Index].CastFromJson(Val[A_Index]))
            }
            return Result
        }

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
                AquaHotkey_Json(&Value)
                Result .= Value
            }
            Result .= "]"
            return Result
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Func

    class Func {
        /**
         * Converts an AHK value by applying this function and returning
         * the result.
         * 
         * @param   {Any}  Val  any value
         * @returns {Any}
         */
        static CastFromJson(Val) => this(Val)
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Primitive

    class Primitive {
        /**
         * Parses this JSON string into an AHK value, optionally "casting"
         * and reconstructing into the specified type.
         * 
         * @param   {Any?}  T  the type to be constructed
         * @returns {Any}
         * @example
         * "[1, 2, 3, 4]".ToJson() ; ==> [1, 2, 3, 4] (AHK array)
         */
        ParseJson(T?) {
            static Psr := (Json.Parser)
            Result := Psr.Parse(&this)

            return (IsSet(T)) ? T.CastFromJson(Result)
                              : Result
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

        /**
         * Converts the given JSON value into a number. Throws, if unable
         * to convert.
         * 
         * @param   {Any}  Val  any value
         * @returns {Any}
         */
        CastFromJson(Val) => this(Val)
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

        /**
         * Casts a JSON value into a string. Only casts from numbers to
         * strings are supported.
         * 
         * @param   {Any}  Val  any value
         * @returns {Any}
         */
        static CastFromJson(Val) {
            if (!(Val is Primitive)) {
                throw TypeError("Expected a String",, Type(Val))
            }
            return String(Val)
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
            if (ObjGetBase(this) != Object.Prototype) {
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
                AquaHotkey_Json(&PropName)
                AquaHotkey_Json(&Value)
                Result .= PropName
                Result .= ":"
                Result .= Value
            }
            Result .= "}"
            return Result
        }

        /**
         * Reconstructs an object according to the contents of this plain
         * object. For each property defined in this object there must exist an
         * equivalent in the JSON value.
         * 
         * @param   {Any}  Any  any value
         * @returns {Any}
         */
        CastFromJson(Val) {
            static GetProp := {}.GetOwnPropDesc
            static Define  := {}.DefineProp

            if (ObjGetBase(this) != Object.Prototype) {
                throw TypeError("Expected a plain object",, Type(this))
            }
            if (ObjGetBase(Val) != Object.Prototype) {
                throw TypeError("Expected a plain object",, Type(Val))
            }

            Result := Object()
            for PropName in ObjOwnProps(this) {
                PropDesc := GetProp(this, PropName)
                if (!ObjHasOwnProp(PropDesc, "Value")) {
                    continue
                }
                T := PropDesc.Value

                if (!ObjHasOwnProp(Val, PropName)) {
                    throw PropertyError("property not found",, PropName)
                }
                PropDesc := GetProp(Val, PropName)
                if (!ObjHasOwnProp(PropDesc, "Value")) {
                    throw PropertyError("not a value property")
                }
                Value := T.CastFromJson(PropDesc.Value)
                Define(Result, PropName, { Value: Value })
            }
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

#Include <AquaHotkeyX>

Json.EnableComments()

"
(
// this is fine
{ "foo": "bar" }
)".ParseJson(SkipListMap).ToString().MsgBox()

