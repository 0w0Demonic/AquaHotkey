#Include "%A_LineFile%\..\..\src\Core\AquaHotkey.ahk"
#Include "%A_LineFile%\..\..\src\Base\DuckTypes.ahk"
#Include "%A_LineFile%\..\..\src\Base\Buffer.ahk"
#Include "%A_LineFile%\..\..\src\Interfaces\IBuffer.ahk"

; TODO `.Read()` and `.Write()`
; TODO `.RawRead()` and `.RawWrite()`

;@region BufferEditor

/**
 * Class for objects that reads from, and writes numbers into buffers.
 * 
 * @module  <IO/BufferEditor>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class BufferEditor {
    ;@region Fields

    /**
     * The current position in the buffer.
     * 
     * @property {Integer}
     */
    Pos := 0

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Construction

    /**
     * Creates a new buffer writer that wraps over the given {@link IBuffer}.
     * 
     * @constructor
     * @param   {IBuffer?}  Buf  the buffer to wrap over
     * @example
     */
    __New(Buf := Buffer(16, 0)) {
        if (!Buf.Is(IBuffer)) {
            throw TypeError("Expected an IBuffer",, Type(Buf))
        }

        this.DefineProp("Buffer", {
            Get: (_)        => Buf })
        this.DefineProp("Ptr", {
            Get: (_)        => Buf.Ptr,
            Set: (_, Value) => (Buf.Ptr := Value) })
        this.DefineProp("Size", {
            Get: (_)        => Buf.Size,
            Set: (_, Value) => (Buf.Size := Value) })
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Alignment

    /**
     * Moves the current position to the next byte alignment.
     * Only values `2`, `4`, `8` or `16` are allowed.
     * 
     * @param   {Integer}  Boundary  the next byte boundary to align with
     * @example
     * W := Buffer(16, 0).Editor()
     * 
     * W.Align(8)
     * MsgBox(W.Pos) ; 0
     * W.WriteUChar(42)
     * MsgBox(W.Pos) ; 1
     * W.Align(8)
     * MsgBox(W.Pos) ; 8
     */
    Align(Boundary) {
        if (!IsInteger(Boundary)) {
            throw TypeError("Expected an Integer",, Type(Boundary))
        }
        switch (Boundary) {
            case 2, 4, 8, 16:
                this.Pos := (this.Pos + Boundary - 1) & ~(Boundary - 1)
            default:
                throw ValueError("Expected 2, 4, 8, or 16",, Boundary)
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Read/Write Methods

    static __New() {
        if (this != BufferEditor) {
            return
        }
        for Name, Size in Map(
                "Char", 1, "UChar", 1,
                "Short", 2, "UShort", 2,
                "Int", 4, "UInt", 4, "Float", 4,
                "Int64", 8, "UInt64", 8, "Double", 8,
                "Ptr", A_PtrSize, "UPtr", A_PtrSize)
        {
            this.Prototype.DefineProp("Write" . Name, WriteMethod(Name, Size))
            this.Prototype.DefineProp("Read" . Name, ReadMethod(Name, Size))
        }

        static WriteMethod(Name, Size) {
            return { Call: Write }

            Write(this, Value) {
                if (this.Pos + Size > this.Size) {
                    this.Size := Max(this.Size * 2, 16)
                }
                NumPut(Name, Value, this, this.Pos)
                this.Pos += Size
            }
        }

        static ReadMethod(Name, Size) {
            return { Call: Read }

            Read(this) {
                if (this.Pos + Size > this.Size) {
                    return ""
                }
                Value := NumGet(this, this.Pos, Name)
                this.Pos += Size
                return Value
            }
        }
    }
    ;@endregion
}

;@endregion
;-------------------------------------------------------------------------------
;@region Extensions

/**
 * Extensions related to {@link BufferEditor}.
 */
class AquaHotkey_BufferEditor extends AquaHotkey {
    class IBuffer {
        /**
         * Creates a {@link BufferEditor} for this buffer.
         * 
         * @returns {BufferEditor}
         */
        Editor() => BufferEditor(this)
    }
}

class AquaHotkey_Serialize {
    static __New() {
        this.ApplyOnto(File, BufferEditor)
    }

    WriteObject(Val?) {
        Refs := Map()
        switch {
            case (!IsSet(Val)):
                this.Write("u")
            case (ObjGetBase(Val) == String.Prototype):
                this.Write('"')
                this.WriteUInt(StrPut(Val, "UTF-16"))
                this.Write(Val)
            case (IsFloat(Val)):
                this.Write("f")
                this.WriteDouble(Val)
            case (IsInteger(Val)):
                this.Write("i")
                this.WriteInt64(Val)
            default:
                Ref := Refs.Get(Val, 0)
                if (Ref) {
                    ; reference to previously seen object
                    this.Write("#")
                    this.WriteUInt(Ref)
                } else {
                    Refs.Set(Val, Refs.Count + 1)
                    Val.Serialize(this)
                }
        }
    }

    ReadObject(&Result) {
        Tag := this.Read()
        switch (Tag) {
          case "u":
            Result := unset
            return true
          case '"':
            Size := this.ReadUShort()
            Result := this.Read(Size)
            return true
          case "i":
            Result := this.ReadInt64()
            return true
          case "f":
            Result := this.ReadDouble()
            return true
          case "{":
            ; TODO
            Result := Object()
            while (this.ReadObject(&Prop) && this.ReadObject(&Value)) {
                Result.DefineProp(Prop, { Value: Value })
            }
            return true
          case "}":
            return false
          case ">":
            TLen := this.ReadUShort()
            T := this.Read(TLen)

            ; TODO put this in secluded area
            Cls := %T%
            if (!(Cls is Class)) {
                throw TypeError("Expected a Class",, Type(Cls))
            }
            if (!HasMethod(Cls, "Deserialize")) {
                Result := Object()
                ObjSetBase(Result, T.Prototype)
                while (this.ReadObject(&Prop) && this.ReadObject(&Value)) {
                    Result.DefineProp(Prop, { Value: Value })
                }
                return true
            }
        }
    }
}

class AquaHotkey_Serialization extends AquaHotkey {
    class IArray {
        Serialize(Out) {
            Out.Write("a")
            if (ObjGetBase(this) == Array.Prototype) {
                Out.WriteUShort(0)
            } else {
                T := Type(this)
                Out.WriteUShort(StrPut(T, "UTF-16"))
                Out.Write(T)
            }
            Out.WriteUInt(this.Length)
            for Value in this {
                Out.WriteObject(Value?)
            }
        }

        static Deserialize(Out) {
            TLen := Out.ReadUShort()
            if (TLen == 0) {
                M := Map()
            } else {
                T := Out.Read(TLen)
            }
            ; TODO
        }
    }

    class IMap {
        Serialize(Output) {
            Output.Write("m")
            if (ObjGetBase(this) == Map.Prototype) {
                Output.WriteUShort(0)
            } else {
                T := Type(this)
                Output.WriteUShort(StrPut(T, "UTF-16"))
                Output.Write(T)
            }
            Output.WriteUInt(this.Count)
            for Key, Value in this {
                Output.WriteObject(Key?)
                Output.WriteObject(Value?)
            }
        }
    }

    class Object {
        Serialize(Output) {
            if (ObjGetBase(this) == Object.Prototype) {
                Output.Write("{")
                for PropertyName in ObjOwnProps(this) {
                    PropDesc := this.GetOwnPropDesc(PropertyName)
                    if (!ObjHasOwnProp(PropDesc, "Value")) {
                        continue
                    }
                    Value := PropDesc.Value
                    Output.WriteObject(PropertyName)
                    Output.WriteObject(Value)
                }
                Output.Write("}")
                return
            }
        }
    }
    
    class IBuffer {
        Serialize(Out) {
            Out.Write("b")
            Out.WriteUInt(this.Size)
            Out.RawWrite(this)
        }
    }
}

FileOpen("result.txt", "w").WriteObject({ foo: "bar", baz: "qux" })
