#Include <AquaHotkeyX>
#Include "%A_LineFile%\..\BufferEditor.ahk"

/**
 * Implements binary serialization for many of the built-in AHK types and
 * AquaHotkey collections.
 * 
 * ### Binary Format
 * 
 * The binary format uses tags and predetermined number sizes to mark the
 * variable type and relevant information such as size of an array/string/map,
 * data elements, or properties of an object.
 * 
 * Examples include...
 * - `u` for `unset`;
 * - `Integer`: tag `i`, followed by a 64-bit signed integer;
 * - `Float`: tag `f`, followed by a double-precision float;
 * - `String`: tag `'`, length prefix as UInt, string data
 * - plain `Object`: tag `{`, zero or more key/value pairs
 * - etc.
 * 
 * ### Graph Serialization
 * 
 * Let's take a look at the following code which shows what is known as
 * a *cyclic reference*.
 * 
 * ```ahk
 * A := Object()
 * B := Object()
 * A.Value := B
 * B.Value := A
 * FileOpen("result.txt", "w").WriteObject(A)
 * ```
 * 
 * Such an object cannot be serialized into a regular, "flat" representation.
 * Trying to do this would cause the serializer to break from infinite
 * recursion. What we need is *graph-based* serialization to assign each
 * object with a unique identifier, and use *references* to previous objects.
 * 
 * AquaHotkey's serializer is graph-based, and converts this object into the
 * following:
 * 
 * ```
 * [object #1]
 * [type: UShort 0]
 * [property]
 *   [key length: UShort 5] [key: String "Value"]
 *   [value:
 *     [object #2]
 *     [property]
 *       [type: UShort 0]
 *       [key1 length: UShort 5] [key1: String "Value"]
 *       [value: #1]]
 * ```
 * 
 * ### Custom Serialization
 * 
 * You can define custom serialization/deserialization by defining methods
 * `.Serialize(Output, Refs)` and `.Deserialize(Input, Refs)` for the class
 * prototype.
 * 
 * For more information about implementing custom serialization, see
 * {@link AquaHotkey_Serial}.
 * 
 * ```ahk
 * class Point {
 *   __New(X, Y) {
 *     this.X := X
 *     this.Y := Y
 *   }
 *   Serialize(Output, Refs) {
 *     Output.WriteDouble(this.X)
 *     Output.WriteDouble(this.Y)
 *   }
 *   Deserialize(Input, Refs) {
 *     this.X := Input.ReadDouble()
 *     this.Y := Input.ReadDouble()
 *   }
 * }
 * ```
 * 
 * @module  <IO/Serializer>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic
 */
class AquaHotkey_Serializer {
    static __New() => this.ApplyOnto(File, BufferEditor)

    ;@region .ReadObject()

    /**
     * Serializes objects or primitive types into a binary format.
     * 
     * - `unset` is converted into `u`;
     * - numbers (`Integer` and `Float`) are converted into an Int64 and Double,
     *   respectively;
     * - strings are written with length prefix in characters;
     * - objects are converted based on their `.Serialize()` method. For more
     *   information, see {@link AquaHotkey_Serial}.
     * 
     * @param   {Any?}  Val   any value
     * @param   {Map?}  Refs  map of previously seen objects
     */
    WriteObject(Val?, Refs := Map()) {
        switch {
          ; <<<< primitive types + unset >>>>
          case (!IsSet(Val)):
            this.Write("u")

          case (ObjGetBase(Val) == String.Prototype):
            this.Write('"')
            this.WriteUInt(StrLen(Val))
            this.Write(Val)

          case (IsInteger(Val)):
            this.Write("i")
            this.WriteInt64(Val)

          case (IsFloat(Val)):
            this.Write("f")
            this.WriteDouble(Val)

          ; <<<< objects >>>>
          default:
            if (!IsObject(Val)) {
                throw TypeError("Expected an Object or primitive type",,
                        Type(Val))
            }
            Ref := Refs.Get(Val, 0)
            if (Ref) {
                this.Write("#")
                this.WriteUInt(Ref)
                return
            }
            Refs.Set(Val, Refs.Count + 1)
            Val.Serialize(this, Refs)
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region .ReadObject()

    /**
     * Deserializes a binary string into the original value.
     * 
     * @param   {VarRef<Any>}  Result  (out) the original value
     * @param   {Map?}         Refs    a map of previously seen objects
     */
    ReadObject(&Result, Refs := Map()) {
        Tag := this.Read(1)
        switch (Tag) {
          case "u": Result := unset
          case '"': Result := this.Read(this.ReadUInt())
          case "i": Result := this.ReadInt64()
          case "f": Result := this.ReadDouble()
          case "#":
            Reference := this.ReadUInt()
            Result := Refs[Reference]
          case "{":
            Result := Object()
            Refs[Refs.Count + 1] := Result
            Result.Deserialize(this, Refs)
          case "[":
            Result := Array()
            Refs[Refs.Count + 1] := Result
            Result.Deserialize(this, Refs)
          case "(":
            Result := Map()
            Refs[Refs.Count + 1] := Result
            Result.Deserialize(this, Refs)
          case "b":
            Size := this.ReadUInt()
            Result := Buffer(Size)
            Refs[Refs.Count + 1] := Result
            this.RawRead(Result)
          case "c":
            Result := Class.ForName(this.Read(this.ReadUShort()))
            Refs[Refs.Count + 1] := Result
          default:
            throw ValueError("invalid tag",, Tag)
        }
    }
    
    ;@endregion
}