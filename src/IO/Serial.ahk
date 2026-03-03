#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Implements value-level serialization and deserialization for objects
 * supported by the {@link AquaHotkey_Serializer AquaHotkey binary serializer}.
 * 
 * ### Overview
 *
 * This class provides the concrete serialization logic for runtime values,
 * while the main serializer manages I/O and overall binary format.
 * 
 * Primitive types, `unset`, class objects, and reference handling are
 * implemented internally and **cannot** be overridden.
 *
 * ---
 *
 * ### Native Type Serialization
 *
 * Objects are serialized according to their *native type*. The native type
 * corresponds to the class whose `static Call()` method is invoked during
 * object construction. This distinction is important because certain object
 * kinds are mutually exclusive and cannot be converted after creation
 * (for example, plain objects and arrays).
 *
 * Each supported type implements its own `.Serialize()` and `.Deserialize()`
 * methods which define how the object body is written and reconstructed.
 *
 * These methods may be overridden to implement custom serialization
 * behavior.
 *
 * ---
 *
 * ### Custom Serialization
 *
 * Custom serialization is implemented by overriding `.Serialize(Output, Refs)`.
 *
 * Parameters:
 * - `Output`: output stream used to write binary data
 * - `Refs`: map containing previously serialized objects for reference tracking
 *
 * Implementations should always begin by calling:
 *
 * ```ahk
 * super.Serialize(Output, Refs)
 * ```
 *
 * This writes the required object prefix and registers the object within
 * the reference system. Afterward, only the object-specific data needs
 * to be written.
 *
 * The structure of the serialized body is implementation-defined, but it
 * should describe the characteristics that uniquely reconstruct the object,
 * similar in spirit to {@link AquaHotkey_Eq equality}- or
 * {@link AquaHotkey_Hash hash}-relevant state.
 *
 * When invoking nested serialization (for example via `Output.WriteObject()`),
 * the `Refs` parameter **must always be forwarded** to ensure correct
 * reference tracking within object graphs.
 *
 * ---
 *
 * ### Custom Deserialization
 *
 * Custom deserialization must be implemented alongside serialization by
 * overriding `.Deserialize(Input, Refs)`.
 *
 * Parameters:
 * - `Input`: input stream providing serialized binary data
 * - `Refs`: map of previously reconstructed objects
 *
 * When this method is called:
 * - the object instance (`this`) already exists
 * - object metadata and reference registration have already been processed
 *
 * Implementations should therefore begin directly by reading the object
 * body written during serialization and restoring the object's internal
 * state.
 *
 * The goal of `.Deserialize()` is to transform the newly created instance
 * into a fully reconstructed runtime object.
 *
 * ---
 *
 * ### Example: Generic Array Serialization
 *
 * The following example illustrates how a generic array restores its
 * runtime type and contents during serialization and deserialization:
 *
 * ```ahk
 * class GenericArray extends IArray {
 *   Serialize(Output, Refs) {
 *     super.Serialize(Output, Refs)
 *     Output.WriteObject(this.ArrayType, Refs)
 *     Output.WriteObject(this.ComponentType, Refs)
 *     Output.WriteUInt(this.Length)
 *     for Value in this {
 *       Output.WriteValue(Value?, Refs)
 *     }
 *   }
 *
 *   Deserialize(Input, Refs) {
 *     Input.ReadObject(&ArrayType, Refs)
 *     Input.ReadObject(&ComponentType, Refs)
 *     Cls := ArrayType.OfType(ComponentType)
 *     ObjSetBase(this, Cls.Prototype)
 *     this.__Init()
 *     this.__New()
 *     Length := Input.ReadUInt()
 *     loop Length {
 *       Input.ReadObject(&Value, Refs)
 *       this.Push(Value?)
 *     }
 *   }
 * }
 * ```
 *
 * @module  <IO/Serial>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic
 */
class AquaHotkey_Serial extends AquaHotkey {
    ;@region Array

    class Array {
        /**
         * Serializes the array into binary.
         * 
         * @param   {OutputStream}  Output  output stream
         * @param   {Map}           Refs    map of previously seen objects
         * @see {@link AquaHotkey_Serializer}
         */
        Serialize(Output, Refs) {
            Output.Write("[")
            Base := ObjGetBase(this)
            if (Base == Array.Prototype) {
                Output.WriteUShort(0)
            } else {
                T := Base.__Class
                Output.WriteUShort(StrLen(T))
                Output.Write(T)
            }
            if (this.Serialize == Array.Prototype.Serialize) {
                Output.WriteUInt(this.Length)
                for Value in this {
                    Output.WriteObject(Value?, Refs)
                }
            }
        }

        /**
         * Reconstructs the array from binary.
         * 
         * @param   {InputStream}  Input  input stream
         * @param   {Map}          Refs   map of previously seen objects
         * @see {@link AquaHotkey_Serializer}
         */
        Deserialize(Input, Refs) {
            TSize := Input.ReadUShort()
            if (TSize) {
                T := Class.ForName(Input.Read(TSize))
                ObjSetBase(this, T.Prototype)
                if (this.Deserialize != Array.Prototype.Deserialize) {
                    this.Deserialize(Input, Refs)
                    return
                }
            }
            DLen := Input.ReadUInt()
            loop DLen {
                Input.ReadObject(&Value, Refs)
                this.Push(Value?)
            }
        }

        /**
         * The native type of the array object.
         * 
         * @property {Class}
         */
        NativeType => Array
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Map

    class Map {
        /**
         * Serializes the map into binary.
         * 
         * @param   {OutputStream}  Output  output stream
         * @param   {Map}           Refs    map of previously seen objects
         * @see {@link AquaHotkey_Serializer}
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
            if (this.Serialize == Map.Prototype.Serialize) {
                Output.WriteUInt(this.Count)
                for Key, Value in this {
                    Output.WriteObject(Key, Refs)
                    Output.WriteObject(Value, Refs)
                }
            }
        }

        /**
         * Reconstructs the array from binary.
         * 
         * @param   {InputStream}  Input  input stream
         * @param   {Map}          Refs   map of previously seen objects
         * @see {@link AquaHotkey_Serializer}
         */
        Deserialize(Input, Refs) {
            Size := Input.ReadUShort()
            if (Size) {
                T := Class.ForName(Input.Read(Size))
                ObjSetBase(this, T.Prototype)
                if (this.Deserialize != Map.Prototype.Deserialize) {
                    this.Deserialize(Input, Refs)
                    return
                }
            }
            Count := Input.ReadUInt()
            loop Count {
                Input.ReadObject(&Key, Refs)
                Input.ReadObject(&Value, Refs)
                this.Set(Key, Value)
            }
        }

        /**
         * The native type of this map object.
         * 
         * @property {Class}
         */
        NativeType => Map
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Object

    class Object {
        /**
         * Serializes ths object into binary.
         * 
         * @param   {OutputStream}  Output  output stream
         * @param   {Map}           Maps    map of previously seen objects
         * @see {@link AquaHotkey_Serializer}
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
            if (this.Serialize == Object.Prototype.Serialize) {
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
        }

        /**
         * Reconstructs an object from binary.
         * 
         * @param   {InputStream}  Input  input stream
         * @param   {Map}          Refs   map of previously seen objects
         * @see {@link AquaHotkey_Serializer}
         */
        Deserialize(Input, Refs) {
            Size := Input.ReadUShort()
            if (Size) {
                T := Class.ForName(Input.Read(Size))
                ObjSetBase(this, T.Prototype)
                if (this.Deserialize != Object.Prototype.Deserialize) {
                    this.Deserialize(Input, Refs)
                    return
                }
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

        /**
         * The native type of this regular object.
         * 
         * @property {Class}
         */
        NativeType => Object
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Buffer
    
    class Buffer {
        /**
         * Serializes the buffer into binary.
         * 
         * @param   {OutputStream}  Output  output stream
         * @param   {Refs}          Refs    previously seen objects
         * @see {@link AquaHotkey_Serializer}
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

        /**
         * Reconstructs the buffer from binary.
         * 
         * @param   {InputStream}  Input  input stream
         * @param   {Map}          Refs   map of previously seen objects
         * @see {@link AquaHotkey_Serializer}
         */
        Deserialize(Input, Refs) {
            Size := Input.ReadUShort()
            if (Size) {
                T := Class.ForName(Input.Read(Size))
                ObjSetBase(this, T.Prototype)
                if (this.Deserialize != Buffer.Prototype.Deserialize) {
                    this.Deserialize(Input, Refs)
                    return
                }
            }
            this.Size := Input.ReadUInt()
            Input.RawRead(this)
        }

        /**
         * The native type of this buffer object.
         * 
         * @property {Class}
         */
        NativeType => Buffer
    }

    ;@endregion
    ;---------------------------------------------------------------------------
    ;@region Class

    class Class {
        /**
         * Serializes this class based on its class name.
         * 
         * @param   {OutputStream}  Output  output stream
         * @see {@link AquaHotkey_Serializer}
         */
        Serialize(Output, Refs) {
            T := this.Prototype.__Class
            Output.Write("c")
            Output.WriteUShort(StrLen(T))
            Output.Write(T)
        }

        ; note: `.Deserialize()` is hard-coded in `.ReadObject()`.
    }
}
