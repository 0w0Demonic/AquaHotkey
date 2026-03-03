#Include <AquaHotkeyX>

/**
 * TODO
 * 
 * 
 * 
 * For general information about the binary format, see
 * {@link AquaHotkey_Serializer}.
 */
class AquaHotkey_Serial extends AquaHotkey {
    class GenericArray {
        Serialize(Output, Refs) {
            super.Serialize(Output, Refs)
            Output.WriteObject(this.ArrayType, Refs)
            Output.WriteObject(this.ComponentType, Refs)
            Output.WriteUInt(this.Length)
            for Value in this {
                Output.WriteObject(Value?, Refs)
            }
        }

        Deserialize(Input, Refs) {
            Input.ReadObject(&ArrayType, Refs)
            Input.ReadObject(&ComponentType, Refs)
            Cls := ArrayType.OfType(ComponentType)
            ObjSetBase(this, Cls.Prototype)

            this.__Init()
            this.__New()

            Length := Input.ReadUInt()
            loop Length {
                Input.ReadObject(&Value, Refs)
                this.Push(Value?)
            }
        }
    }
    
    class GenericMap {
        Serialize(Output, Refs) {
            super.Serialize(Output, Refs)
            Output.WriteObject(this.MapType, Refs)
            Output.WriteObject(this.KeyType, Refs)
            Output.WriteObject(this.ValueType, Refs)
            Output.WriteUInt(this.Count)
            for Key, Value in this {
                Output.WriteObject(Key?, Refs)
                Output.WriteObject(Value?, Refs)
            }
        }

        Deserialize(Input, Refs) {
            Input.ReadObject(&MapType, Refs)
            Input.ReadObject(&KeyType, Refs)
            Input.ReadObject(&ValueType, Refs)
            Cls := MapType.OfType(KeyType, ValueType)
            ObjSetBase(this, Cls.Prototype)
            this.__Init()
            this.__New()
            Count := Input.ReadUInt()
            loop Count {
                Input.ReadObject(&Key, Refs)
                Input.ReadObject(&Value, Refs)
                this.Set(Key, Value)
            }
        }
    }

    ;@region Array

    class Array {
        Serialize(Output, Refs) {
            Output.Write("[")
            if (ObjGetBase(this) == Array.Prototype) {
                Output.WriteUShort(0)
            } else {
                T := Type(this)
                Output.WriteUShort(StrLen(T))
                Output.Write(T)
            }
            Output.WriteUInt(this.Length)
            for Value in this {
                Output.WriteObject(Value?, Refs)
            }
        }

        Deserialize(Input, Refs) {
            TSize := Input.ReadUShort()
            if (TSize) {
                T := Class.ForName(Input.Read(TSize))
                ObjSetBase(this, T.Prototype)
            }
            DLen := Input.ReadUInt()
            this.Capacity := DLen
            loop DLen {
                Input.ReadObject(&Value, Refs)
                this.Push(Value?)
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Map

    class Map {
        /**
         * Serializes this map.
         * 
         * 
         */
        Serialize(Output, Refs) {
            Output.Write("(")
            if (ObjGetBase(this) == Map.Prototype) {
                Output.WriteUShort(0)
            } else {
                T := Type(this)
                Output.WriteUShort(StrLen(T))
                Output.Write(T)
            }
            Output.WriteUInt(this.Count)
            for Key, Value in this {
                Output.WriteObject(Key, Refs)
                Output.WriteObject(Value, Refs)
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Object

    class Object {
        /**
         * Serializes this object into binary representation.
         * 
         * @param   {OutputStream}  Output  output stream
         * @param   {Map}           Maps    map of previously seen objects
         */
        Serialize(Output, Refs) {
            Output.Write("{")
            Base := ObjGetBase(this)
            if (Base == Object.Prototype) {
                Output.WriteUShort(0)
            } else {
                T := Base.__Class
                Output.WriteUShort(StrLen(T))
                Output.Write(T)
            }
            if (this.Serialize != Object.Prototype.Serialize) {
                return
            }
            for PropertyName in ObjOwnProps(this) {
                PropDesc := this.GetOwnPropDesc(PropertyName)
                if (ObjHasOwnProp(PropDesc, "Value")) {
                    Output.WriteUShort(StrLen(PropertyName))
                    Output.Write(PropertyName)
                    Output.WriteObject(PropDesc.Value, Refs)
                }
            }
            Output.WriteUShort(0)
        }

        /**
         * Deserializes an object in binary data back into the original value.
         * 
         * @param   {InputStream}  Input  input stream
         * @param   {Map}          Refs   map of previously seen objects
         * @example
         * object     ::= "{",
         *                classLength:u16,
         *                [ className:string(classLength) ],
         *                objectBody
         * objectBody ::= customData | property* 
         * property   ::= propNameLength:u16,
         *                propName:string(propNameLength),
         *                value
         */
        Deserialize(Input, Refs) {
            Size := Input.ReadUShort()
            if (Size) {
                ClsName := Input.Read(Size)
                T := Class.ForName(ClsName)
                ObjSetBase(this, T.Prototype)
            }
            if (this.Deserialize != Object.Prototype.Deserialize) {
                this.Deserialize(Input, Refs)
                return
            }
            loop {
                Size := Input.ReadUShort()
                if (!Size) {
                    break
                }
                PropName := Input.Read(Size)
                Input.ReadObject(&Value, Refs)
                this.DefineProp(PropName, { Value: Value })
            }
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Buffer
    
    class Buffer {
        /**
         * Serializes this buffer.
         * 
         * @param   {OutputStream}  Output  output stream
         */
        Serialize(Output, Refs) {
            Output.Write("b")
            Base := ObjGetBase(this)
            if (Base == Buffer.Prototype) {
                Output.WriteUShort(0)
            } else {
                T := Base.__Class
                Output.WriteUShort(StrLen(T))
                Output.Write(T)
            }
            Output.WriteUInt(this.Size)
            Output.RawWrite(this)
        }
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Class

    class Class {
        /**
         * Serializes this class based on its class name.
         * 
         * @param   {OutputStream}  Output  output stream
         */
        Serialize(Output, Refs) {
            T := this.Prototype.__Class
            Output.Write("c")
            Output.WriteUShort(StrLen(T))
            Output.Write(T)
        }
    }
}
