#Include "%A_LineFile%\..\..\..\wip\BufferEditor.ahk"
#Include "%A_LineFile%\..\Serial.ahk"

/**
 * Implements binary serialization for many of the built-in AHK types and
 * AquaHotkey collections. It allows you to write variables permanently
 * into files and reconstruct them on demand.
 * 
 * ---
 * 
 * ### Basic Usage
 * 
 * You can use an instance of either {@link BufferEditor} or {@link File} as
 * serializer. Use `.WriteObject()` to write the binary representation of a
 * variable into a file/buffer. Use `.ReadObject()` to read binary data from
 * the file/buffer and reconstruct it back into the original value.
 * 
 * ```ahk
 * FileObj.WriteObject({ Name: "Alice", Age: 26 })
 * ...
 * FileObj.ReadObject(&Data)
 * ```
 * 
 * ---
 * 
 * ### Binary Format Specification
 * 
 * Variables in their serialized form consist of a set of tags that mark
 * the variable type, followed by an individual format that stores relevant data
 * for reconstructing data based on its type.
 * 
 * | Tag | Data Format        | Description                 |
 * | --- | ------------------ | --------------------------- |
 * | `u` | none               | `unset`                     |
 * | `i` | 64-bit integer     | `Integer`                   |
 * | `f` | 64-bit float       | `Float`                     |
 * | `"` | `<nChars> <chars>` | `String`                    |
 * | `#` | 32-bit integer     | reference to any of `c{[(b` |
 * | `c` | `<nChars> <chars>` | `Class`                     |
 * | `{` | (see below)        | `Object`                    |
 * | `[` | (see below)        | `Array`                     |
 * | `(` | (see below)        | `Map`                       |
 * | `b` | (see below)        | `Buffer`                    |
 * 
 * ---
 * 
 * #### Object Format
 * 
 * The format used for serialized objects is much less straightforward. In
 * general, an object consists of a tag that marks the *native* type of the
 * object, followed by an optional field specifying the type of object,
 * and lastly the contents of the object.
 * 
 * | Tag | Description |
 * | --- | ----------- |
 * | `{` | `Object`    |
 * | `[` | `Array`     |
 * | `(` | `Map`       |
 * | `b` | `Buffer`    |
 * 
 * Let's take a look at a more concrete example:
 * 
 * ```ahk
 * class Point {
 *     __New(X, Y) {
 *         this.X := X
 *         this.Y := Y
 *     }
 * }
 * FileOpen("stuff.bin", "w").WriteObject(Point(23, 4))
 * ```
 * 
 * The *native* type of `Point(23, 4)` is `Object`, in terms of the class
 * whose `static Call()` method is called during object construction.
 * Calling `Point()` would call `Object.Call`, `Array(1, 2, 3)` would call
 * `Array.Call`, and so on. This means that the binary representation starts
 * with `{`.
 * 
 * Next, we specify the name of the class that the object is instance of,
 * which is `"Point"`. The binary representation continues with a 16-bit integer
 * that holds the length of the class name in characters (which is `5`, in this
 * case), followed by the literal class name `"Point"`.
 * 
 * If the object is a "normal" instance of its native type -- i.e. it is not
 * an instance of a custom class, but rather directly of `Object`, `Array`,
 * `Map`, or `Buffer` -- the class name is omitted and the length is set to
 * zero. This allows the serializer to save space by not writing out the class
 * name for plain objects, which are more common.
 * 
 * Based on the native object type -- if not otherwise specified (see custom
 * serialization) -- the data-specific part is serialized in different ways:
 * 
 * - `Array`:
 * 
 *   - The length of the array as 32-bit integer;
 *   - All elements in sequence.
 * 
 * - `Map`:
 * 
 *   - The count of key-value pairs as 32-bit integer;
 *   - Alternating keys and values.
 * 
 * - `Buffer`:
 * 
 *   - Size in bytes as 32-bit integer;
 *   - Raw binary data.
 * 
 * - `Object`:
 *   Zero or more properties, which are defined as follows:
 * 
 *   - nonzero 16-bit integer as string length of the property in characters;
 *   - the property name as string;
 *   - any serialized value.
 * 
 *   The object is parsed for more properties are long as the string length
 *   is nonzero. Value `0` marks the end of the object.
 * 
 * ---
 * 
 * #### Graph Serialization
 * 
 * Graph serialization is the process of converting a graph data structure into
 * a storable format. A serialized graph typically preserves node identities,
 * so that the original topology can be accurately restored.
 * 
 * In the following example, we have two objects that reference each other in a
 * cycle.
 * 
 * ```ahk
 * A := Object()
 * B := Object()
 * A.Value := B
 * B.Value := A
 * FileOpen("result.txt", "w").WriteObject(A)
 * ```
 * 
 * Serializing this object structure without using references to previously
 * serialized objects would be impossible. `A` references `B` and vice versa,
 * so writing out properties one by one would cause the serializer to break
 * from infinite recursion.
 * 
 * This serializer is graph-based. If an object is encountered twice, it is
 * serialized as *reference* to a previous object, e.g. `#1`. It can serialize
 * any topology of objects without any issue.
 * 
 * The object in the previous example might be serialized like this:
 * 
 * ```
 *    1    2     3   4  5    6    7    8        9         10    11
 *    \/ \___/ \___/ \/ \/ \___/ \__/  \/ \____________/ \___/ \___/
 *    7B 00 00 01 00 56 7B 00 00 01 00 56 23 01 00 00 00 00 00 00 00
 *     {  .  .  .  .  V  {  .  .  .  .  V  #  .  .  .  .  .  .  .  .
 * 
 * -----------------------------------------------------------------------------
 * 
 * 1.  [object #1]         <--- this object is being kept track off inside a
 * 2.  [type: UShort 0]                 Map, with a unique ID of #1.
 * -.  [property]
 * 3.    [key length: UShort 1]
 * 4.    [key: String "V"]
 * -.    [value:
 * 5.      [object #2]    <-- same goes for this object. This here is #2.
 * -.      [property]
 * 6.        [type: UShort 0]
 * 7.        [key length: UShort 1]
 * 8         [key: String "V"]
 * 9.        [value: #1]         <--- value of #2.V is a reference back to #1!
 * 10.     [end #2]]
 * 11. [end #1]
 * ```
 * 
 * When the object is reconstructed from binary, references are kept track of
 * by using a {@link Map} of objects mapped to a 32-bit integer as unique
 * identifier. Whenever the binary data contains a reference (`#`), the object
 * is retrieved from this map based on the identifier that succeeds the tag.
 * 
 * Because the serializer is able to keep track of references, the reconstructed
 * object will have the same structure as previously.
 * 
 * ```ahk
 * FileObj("stuff.bin", "w").ReadObject(&Obj)
 * MsgBox(Obj.V.V == Obj) ; true
 * ```
 * 
 * ---
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
            Result := Buffer()
            Refs[Refs.Count + 1] := Result
            Result.Deserialize(this, Refs)
          case "c":
            Result := Class.ForName(this.Read(this.ReadUShort()))
            Refs[Refs.Count + 1] := Result
          default:
            throw ValueError("invalid tag",, Tag)
        }
    }
    
    ;@endregion
}
