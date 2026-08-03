#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\Base\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\Base\Eq.ahk"
#Include "%A_LineFile%\..\..\Base\Hash.ahk"

#Include "%A_LineFile%\..\..\Interfaces\IArray.ahk"
#Include "%A_LineFile%\..\..\Interfaces\IMap.ahk"

#Include "%A_LineFile%\..\..\Parse\Parser.ahk"

;@region Json

; TODO implement custom map for e.g. navigation?

/**
 * @duck
 * 
 * Comprehensive JSON bindings, validation and type matching.
 * 
 * ---
 * 
 * ### Deserialization
 * 
 * Read a JSON string and convert it into an equivalent AHK value with
 * `Str.ParseJson()` or `Json.Load(Str)`. When appropriate, use AHK's
 * continuation section to your advantage. It's more feasible to use
 * single-quote strings to avoid having to escape strings inside the JSON data.
 * 
 * ```ahk
 * Json.Load('{ "Key": "Value" }')
 * 
 * "
 * (
 * {
 *   "Value": 42
 * }
 * )".ParseJson() ; Map { Value: 42 }
 * ```
 * 
 * By specifying a type in the `.ParseJson()` method (or as second parameter in
 * `Json.Load()`), you can "cast" the resulting value into a more complex
 * object. To implement your own deserialization, provide a method
 * `.CastFromJson(&Val)` for the type (usually a class, so that means a method
 * `static CastFromJson(&Val)`).
 * 
 * The `.CastFromJson()` method accepts a reference to a "plain" JSON value
 * (`&Val`) which should be changed in place for an AHK value. You're expected
 * to throw an error, if the value cannot be successfully casted.
 * 
 * ```ahk
 * '{ "FirstName": "John", "LastName": "Doe" }'.ParseJson(Person)
 * ; ==> Person { FirstName = "John", LastName = "Doe" }
 * 
 * class Person {
 *     __New(FirstName, LastName) {
 *         this.FirstName := FirstName
 *         this.LastName := LastName
 *     }
 * 
 *     static CastFromJson(&Val) {
 *         Val := this(Val["FirstName"], Val["LastName"])
 *     }
 * }
 * 
 * ; alternatively:
 * ; - `Json(Person).Load(' ... ')`
 * ; - `Json.Load(' ... ', Person)`
 * ```
 * 
 * ---
 * 
 * ### Serialization
 * 
 * Calling the `.ToJson()` method on any AHK value returns the equivalent
 * as JSON string.
 * 
 * Provide your own `.ToJson()` if you want custom serialization. Make sure to
 * use the existing methods to your advantage instead of creating a string
 * manually.
 * 
 * ```ahk
 * class Person {
 *     ; ...
 *     ToJson() => { FirstName: this.FirstName,
 *                   LastName:  this.LastName,  }.ToJson()
 *     ; ...
 * }
 * ```
 * 
 * There's a helper method `AquaHotkey_Json(&Value)` to help convert `unset`
 * into `Json.Null`. Only custom `.ToJson()` methods should use this.
 * 
 * ```ahk
 * Val := unset
 * AquaHotkey_Json(&Val) ; (Val becomes `Json.Null`)
 * ```
 * 
 * ---
 * 
 * ### Duck Types
 * 
 * This class offers great support for {@link AquaHotkey_DuckTypes duck types}
 * and can be used to validate JSON, optionally checking the values contained
 * inside.
 * 
 * Use `Json.IsInstance(Str)` or `Str.Is(Json)` to determine whether `Str`
 * is a valid JSON document. The JSON class can be used as type wrapper: you
 * can use e.g. `Str.Is(Json({ Value: String }))` to determine that `Str`
 * string is a valid JSON containing an object `{ Value: String }`.
 * 
 * Beware of JSON values `true`, `false` and `null` (see sections below).
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
 * ---
 * 
 * ### Booleans
 * 
 * Values `Json.True` and `Json.False` are special placeholders for JSON values
 * `true` and `false`. They're not the same as AHK's booleans (which are just
 * `1` and `0`).
 * 
 * ```ahk
 * (Json.True).ToJson() ; "true"
 * (Json.False).ToJson() ; "false"
 * ```
 * 
 * `Json.Boolean` is a {@link AquaHotkey_DuckTypes duck type} with which you
 * can determine whether a value is a JSON boolean. Otherwise, regular `is`
 * works too.
 * 
 * ```ahk
 * (Json.True).Is(Json.Boolean) ; true
 * MsgBox(Json.True is Json.Boolean) ; true (`is` works, but prefer `.Is()`)
 * ```
 * 
 * ---
 * 
 * ### Null
 * 
 * `Json.Null` is a placeholder that represents JSON `null`. You can use either
 * `Value.Is(Json.Null)` or `Json.IsSet(Value)` to determine whether a value
 * is null or not.
 * 
 * ```
 * (Json.Null).Is(Json.Null) ; true
 * 
 * Json.IsSet([1, 2, 3]) ; true
 * Json.IsSet(Json.Null) ; false
 * ```
 * 
 * It's important to note that `unset` is NOT instance of `Json.Null`, because
 * it should only be seen as placeholder value, and therefore conceptually
 * speaking it's not the same as `unset` in AHK. This type gets no special
 * treatment from {@link Nullable} or {@link Nothing}.
 * 
 * ```
 * Json.IsSet(unset) ; UnsetError!
 * 
 * (Json.Null).IsInstance(unset) ; false
 * (Json.Null).CanCastFrom(unset) ; false
 * 
 * (Json.Null).Is(Nothing) ; false
 * ```
 * 
 * ---
 * 
 * ### JSONC
 * 
 * This class supports JSONC (regular JSON but with C/C++-style comments),
 * a feature that can be activated and deactivated by accessing
 * {@link Json.AllowsComments}.
 * 
 * ```ahk
 * Json.AllowsComments := true
 * if (Json.AllowsComments) {
 *     MsgBox("comments are enabled!")
 * }
 * 
 * "
 * (
 * // single-line comment
 * { "Key": /* multi-line comment */ "Value" }
 * )".ParseJson() ; { Key: "Value" }
 * ```
 * 
 * ---
 * 
 * ### Case Sensitivity
 * 
 * You can retrieve and change the case sensitivity of properties by accessing
 * {@link Json.CaseSense}. It accepts exactly the same arguments as
 * {@link Map#CaseSense}.
 * 
 * ```ahk
 * Json.CaseSense := "Off"
 * 
 * ; (property "a" in lowercase gets overwritten, because properties are
 * ;  set to case-insensitive.)
 * '{ "a": "b", "A": "b" }'.ParseJson() ; Map { A: b }
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

        /**
         * Converts the given value into a JSON boolean. The value must either
         * already be a JSON boolean (either `Json.True` or `Json.False`), or
         * explicitly an AHK boolean (`true`/`1` or `false`/`0`).
         * 
         * @param   {Json.Boolean|Boolean}  Val  boolean value
         * @returns {Json.Boolean}
         */
        static Call(Val) {
            if (Val is this) {
                return Val
            }
            if (!(Val is Integer)) {
                throw TypeError("Expected a Json.Boolean or Boolean",, Type(Val))
            }
            if (Val & 0xFFFFFFFFFFFFFFFE) {
                throw ValueError("Invalid boolean (must be 1 or 0)",, Val)
            }
            return (Val) ? Json.True : Json.False
        }

        /**
         * Casts JSON `true`/`false` from the given JSON value.
         * 
         * @param   {VarRef<Any>}  Val  any value
         */
        CastFromJson(&Val) {
            if (Val != this) {
                throw TypeError("Expected " . this.ToString(),, Type(Val))
            }
        }
    }

    /**
     * @singleton
     * 
     * JSON boolean `true`. 
     */
    class __True extends Json.Boolean {
        ; note: During initialization, this class is renamed to `Json.True`.
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
     * @singleton
     * 
     * JSON boolean `false`.
     */
    class __False extends Json.Boolean {
        ; note: During initialization, this class is renamed to `Json.False`.
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
        ToString() => "Json.False"
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Null

    /**
     * @singleton
     * 
     * Json value `null`.
     */
    class Null extends Any {
        /**
         * Determines whether the given value is equal to `Json.Null`.
         * @param   {Any?}  Val  any value
         * @returns {Boolean}
         */
        IsInstance(Val?) => IsSet(Val) && (this == Val)

        /**
         * Determines whether the given value is equal to `Json.Null`.
         * @param   {Any?}  Val  any value
         * @returns {Boolean}
         */
        CanCastFrom(Val?) => IsSet(Val) && (this == Val)

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

        /**
         * Casts a null value from JSON.
         * 
         * @param   {VarRef<Any>}  Val  any value
         */
        CastFromJson(&Val) {
            if (Val != this) {
                throw TypeError("Expected Json.Null",, Type(Val))
            }
        }
    }
    
    /**
     * Determines whether the given value is equal to `Json.Null`.
     * 
     * @param   {Any?}  Val  any value
     * @returns {Boolean}
     */
    static IsSet(Val) => (Val != Json.Null)

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Support

    ; (see `<Base/DuckTypes/Nullable>`) for infos
    static Prototype.Prototype := this.Prototype

    ; (sets up the JSON parser as `Json.Parser { get; }`)
    static __New() {
        ;@region Helpers

        static Constantly(Value) => ((_) => (Value))

        if (this != Json) {
            throw ValueError("this class must not be subclassed")
        }

        JsonValue := Parser.Rule(&_JsonValue)

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region True/False/Null

        RenameProp(this, "__True", "True")
        RenameProp(this, "__False", "False")

        DefineConst(this, "True", this.True.Prototype)
        DefineConst(this, "False", this.False.Prototype)
        DefineConst(this, "Null", this.Null.Prototype)

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Comments

        static Ws := Parser.Rule(&_Ws)

        static NoComments := Parser.Regex("[\t\r\n ]*")
        static Comments := Parser.Regex("s)(?:[\t\r\n ]|//\V*+|/\*.*?\*/)*")

        ; TODO create marker class for JSONC comments

        static _Ws := (IsSet(AquaHotkey_cfg_Json_AllowComments))
            ? Comments
            : NoComments

        DefineProp(this, "AllowsComments", {
            Get: (_) => (_Ws == Comments),
            Set: Json_AllowsComments_Set
        })

        static Json_AllowsComments_Set(_, OnOff) {
            _Ws := (OnOff) ? Comments : NoComments
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Strings

        static Escapes := Map(
            "\", "\",
            '"', '"',
            "b", "`b",
            "f", "`f",
            "n", "`n",
            "r", "`r",
            "t", "`t"
        )

        Escape := Parser.String("\").Then(Parser.AnyOf(
            ; named escape -> access from map
            Parser.Regex('["\\bfnrt]').Map(ObjBindMethod(Escapes, "Get")),

            ; unicode escape -> hex codepoint to charchar
            Parser.Regex('[0-9a-fA-F]{4}').Map(Hex => Chr(Integer("0x" . Hex)))
        ))

        Char := Parser.Regex('(?!")[\x{20}-\x{21}\x{23}-\x{5B}\x{5D}-\x{10FFFF}]')

        ; TODO might have lots of potential for optimization, maybe write
        ;      own string parser

        JsonStr := (Escape.Or(Char)).ZeroOrMore(Concat, "").Between('"')

        static Concat(Strs*) {
            Result := ""
            for S in Strs {
                Result .= S
            }
            return Result
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Numbers

        JsonNum := Parser.Sequence(
            (Num, Exponent) => Number(Num) * (10 ** Exponent),

            ; <sign>? <integer> <fraction>?
            Parser.Regex("-?(?:0|[1-9][0-9]*)(?:\.[0-9])?"),

            ; <exponent>?
            Parser.Regex("(?:e|E)\K(?:\+|-)?(?:0|[0-9][1-9]*)").OrElse(0)
        )

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Objects

        /**
         * Case sensitivity of object properties.
         */
        static PropertyCaseSense := "On"

        DefineProp(this, "CaseSense", {
            Get: (Cls) => PropertyCaseSense,
            Set: SetPropertyCaseSense
        })

        /**
         * Sets the case sensitivity of objects.
         * 
         * @param   {Class}      Cls    calling class
         * @param   {Primitive}  Value  new case sensitivity
         */
        static SetPropertyCaseSense(Cls, Value) {
            if (!(Value is Primitive)) {
                throw TypeError("Expected a Boolean or String",, Type(Value))
            }
            if (!(Value ~= "i)^(?:1|0|on|off|locale)$")) {
                throw ValueError("invalid case sensitivity",, Cls)
            }
            PropertyCaseSense := Value
        }

        static CommaDelim := Parser.String(",").Between(Ws)

        JsonObj := Parser.Sequence(
                (Key, Value) => { Key: Key, Value: Value },
                JsonStr.FollowedBy(Parser.String(":").Between(Ws)),
                JsonValue
            )
            .Between(Ws)
            .ZeroOrMoreDelimitedBy(CommaDelim)
            .Between("{", "}")
            .Map(PropsToMap)

        static PropsToMap(Props) {
            Result := Map()
            Result.CaseSense := PropertyCaseSense
            for Prop in Props {
                Result.Set(Prop.Key, Prop.Value)
            }
            return Result
        }

        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Arrays

        JsonArr := JsonValue
            .ZeroOrMoreDelimitedBy(CommaDelim)
            .Between("[", "]")
        
        ;@endregion
        ;-----------------------------------------------------------------------
        ;@region Parser

        _JsonValue := Parser.AnyOf(
            Parser.String("true").ThenReturn(Json.True),
            Parser.String("false").ThenReturn(Json.False),
            Parser.String("null").ThenReturn(Json.Null),
            JsonNum, JsonStr, JsonArr, JsonObj
        ).Between(Ws)

        JsonParser := _JsonValue

        DefineConst(this, "Parser", JsonParser)

        ;@endregion
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region General

    ; NOTE: this section is created during `static __New()`. It is merely
    ;       there for the sake of readability and support for AHK LSP.

    /**
     * Whether the JSON parser supports JSONC comments.
     * 
     * @property {Boolean}
     */
    static AllowsComments {
        get {
            throw PropertyError("not implemented")
        }
        set {
            throw PropertyError("not implemented")
        }
    }

    /**
     * Sets the case sensitivity for objects (accepts same values as
     * {@link Map#CaseSense}).
     * 
     * @property {Primitive}
     */
    static CaseSense {
        get {
            throw PropertyError("not implemented")
        }
        set {
            throw PropertyError("not implemented")
        }
    }

    /**
     * The JSON parser.
     * 
     * @readonly
     * @property {Parser}
     */
    static Parser {
        get {
            throw PropertyError("not implemented")
        }
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
    static Call(T) => DefineProp({ base: this.Prototype },
            "T", { Get: (_) => T })

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
     * @param   {String|VarRef<String>}  Str  JSON string
     * @param   {Any?}                   T    the type to be constructed
     * @returns {Any}
     */
    static Load(Str, T?) {
        Result := (Json.Parser).Parse((Str is VarRef) ? Str : &Str)
        if (IsSet(T)) {
            T.CastFromJson(&Result)
        }
        return Result
    }

    /**
     * Converts the JSON string into an AHK value, casted into the inner type
     * described by this instance.
     * 
     * @param   {String|VarRef<String>}  Str  JSON string
     * @returns {Any}
     */
    Load(Str) {
        Result := (Json.Parser).Parse((Str is VarRef) ? Str : &Str)
        (this.T).CastFromJson(&Result)
        return Result
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
        return IsSet(Val) && (Val is Primitive) && (Json.Parser).Matches(&Val)
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
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

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
         * @param   {VarRef<Any>}  Val  any value
         */
        CastFromJson(&Val) {
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
         * @param   {VarRef<Any>}  Val  any value
         */
        CastFromJson(&Val) {
            if (!(Val is this)) {
                throw TypeError(
                        "Expected type " . this.Prototype.__Class,,
                        Type(Val))
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region IMap

    class IMap {
        /**
         * Constructs a map from a JSON value.
         * 
         * @param   {VarRef<Any>}  Val  any value
         */
        static CastFromJson(&Val) {
            if (!(Val is Map)) {
                throw TypeError("Expected a Map",, Type(Val))
            }
            if (this == IMap) {
                return
            }
            Arr := Array()
            for Key, Value in Val {
                Arr.Push(Key, Value)
            }
            Val := this(Arr*)
        }

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
         * @param   {VarRef<Any>}  Val  any value
         */
        static CastFromJson(&Val) {
            if (ObjGetBase(Val) != Array.Prototype) {
                throw TypeError("Expected a plain array",, Type(Val))
            }
            if (this == IArray) {
                return
            }
            Val := this(Val*)
        }

        /**
         * Constructs an array from a JSON value, based on the contents of
         * this array. The JSON value must be a plain array of the same length.
         * 
         * @param   {VarRef<Any>}  Val  any value
         */
        CastFromJson(&Val) {
            if (ObjGetBase(Val) != Array.Prototype) {
                throw TypeError("Expected a plain array",, Type(Val))
            }
            if (Val.Length != this.Length) {
                throw ValueError(
                    "invalid size (expected " . this.Length . ")",,
                    Val.Length)
            }
            Result := IArray.BasedFrom(this)
            loop (this.Length) {
                Val := Val[A_Index]
                this[A_Index].CastFromJson(&Val)
                Result.Push(Val?)
            }
            Val := Result
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
         * @param   {VarRef<Any>}  Val  any value
         */
        static CastFromJson(&Val) {
            this(&Val)
        }
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
            Result := (Json.Parser).Parse(&this)
            if (IsSet(T)) {
                T.CastFromJson(&Result)
            }
            return Result
        }

        /**
         * Converts this JSON string into an AHK value, applies the given
         * `Mapper` function, and then converts the result back into JSON.
         * 
         * @param   {(Any) => Any}  Mapper  mapper function
         * @returns {String}
         */
        JsonTransform(Mapper) => Mapper((Json.Parser).Parse(&this)).ToJson()
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
         * @param   {VarRef<Any>}  Val  any value
         */
        CastFromJson(&Val) {
            if (!IsNumber(Val)) {
                throw TypeError("Expected a Number",, Type(Val))
            }
            Val := this(Val)
        }
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
            if (ObjGetBase(this) != Object.Prototype) {
                throw TypeError("Expected a plain object",, Type(this))
            }

            Result := "{"
            for PropName, PropDesc in OwnValueProps(this) {
                if (A_Index != 1) {
                    Result .= ","
                }
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
         * Casts the JSON object (AHK map) into a plain AHK object. Because
         * object properties in AutoHotkey v2 are inherently case-insensitive,
         * data might get lost during conversion.
         * 
         * @param   {VarRef<Any>}  Val  any value
         */
        static CastFromJson(&Val) {
            if (this != Object) {
                throw TypeError("Not applicable for this class",,
                        this.Prototype.__Class)
            }
            if (!(Val is Map)) {
                throw TypeError("Expected a plain object",, Type(Val))
            }
            Result := {}
            for Key, Value in Val {
                DefineProp(Result, Key, { Value: Value })
            }
            Val := Result
        }

        /**
         * Reconstructs an object according to the contents of this plain
         * object. For each property defined in this object there must exist an
         * equivalent in the JSON value.
         * 
         * @param   {VarRef<Any>}  Any  any value
         */
        CastFromJson(&Val) {
            if (ObjGetBase(this) != Object.Prototype) {
                throw TypeError("Expected a plain object",, Type(this))
            }
            if (!(Val is Map)) {
                throw TypeError("Expected a plain object",, Type(Val))
            }

            Result := {}
            for PropName, T in OwnValueProps(this) {
                if (!Val.TryGet(PropName, &Value)) {
                    throw PropertyError("property not found",, PropName)
                }
                T.CastFromJson(&Value)
                if (IsSet(Value)) {
                    DefineProp(Result, PropName, { Value: Value })
                }
            }
            Val := Result
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Support

    /**
     * Helper function that converts a value into a JSON string, with
     * additional `unset` support.
     * 
     * Only custom `.ToJson()` methods should call this.
     * 
     * @param   {VarRef<Any?>}  Val  (in, out) any value
     */
    static Call(&Val) {
        Val := IsSet(Val) ? Val.ToJson() : "null"
    }

    ;@endregion
}

/**
 * {@link AquaHotkey_Serializer binary serialization} support for
 * {@link Json}.
 */
class AquaHotkey_Json_Serialization extends AquaHotkey {
    static __New() => IsSet(AquaHotkey_Serializer) && super.__New()

    class Json {
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
            DefineProp(this, "T", { Get: (_) => T })
        }
    }
}

;@endregion
