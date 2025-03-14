/**
 * AquaHotkey - Buffer.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Classes/Buffer.ahk
 */
class Buffer {
    /**
     * Class initialization to set up all `Get<NumType>` and `Put<Numtype>`
     * methods.
     */
    static __New() {
        for NumType in Array("Char", "UChar", "Short", "UShort", "Int", "UInt",
                        "Int64", "UInt64", "Ptr", "UPtr", "Float", "Double")
        {
            this.Prototype.DefineProp("Get" . NumType, {
                Call: CreateGetter(this, Numtype)
            })
            this.Prototype.DefineProp("Put" . NumType, {
                Call: CreateSetter(this, NumType)
            })
        }
        return
        
        static CreateGetter(Cls, NumType) {
            FunctionName := Cls.Prototype.__Class . ".Prototype.Get" . NumType
            Getter.DefineProp("Name", { Get: (Instance) => FunctionName })
            return Getter
            /**
             * Gets a number from this buffer at offset `Offset`.
             * @example
             * 
             * MyBuffer.GetInt64(8) ; e.g. 12813612291
             * 
             * @param   {Integer?}  Offset  byte offset (default 0)
             * @return  {Number}
             */
            Getter(Instance, Offset := 0) {
                return NumGet(Instance, Offset, NumType)
            }
        }
        
        static CreateSetter(Cls, NumType) {
            FunctionName := Cls.Prototype.__Class . ".Prototype.Put" . NumType
            Setter.DefineProp("Name", { Get: (Instance) => FunctionName })
            return Setter
            /**
             * Puts a number `Value` into this buffer at offset `Offset`, and
             * returns the previously stored value.
             * 
             * @param   {Number}    Value   the new value to be stored
             * @param   {Integer?}  Offset  offset in bytes
             * @return  {Number}
             */
            Setter(Instance, Value, Offset := 0) {
                PreviousValue := NumGet(Instance, Offset, Numtype)
                NumPut(NumType, Value, Instance, Offset)
                return PreviousValue
            }
        }
    }

    /**
     * Returns a hexadecimal representation of this buffer.
     * @example
     * 
     * Buffer.OfString("foo", "UTF-8").HexDump() ; "66 6F 6F 00"
     * 
     * @param   {String?}   Delimiter   separator string
     * @param   {Integer?}  LineLength  amount of bytes per line, (if zero, no
     *                                  line breaks are made)
     * @return  {String}
     */
    HexDump(Delimiter := A_Space, LineLength := 16) {
        Delimiter.AssertType(String)
        LineLength := LineLength.AssertInteger().AssertGreaterOrEqual(0)

        if (Delimiter == "" && !LineLength) {
            if (DllCall("crypt32.dll\CryptBinaryToStringW",
                    "Ptr", this,
                    "UInt", this.Size,
                    "UInt", 0x4,
                    "Ptr", 0,
                    "Ptr", &(Str := ""))) {
                return Str
            }
        }

        VarSetStrCapacity(&Out,
                (this.Size                     * (StrLen(Delimiter) + 1))
              + ((this.Size - 1) // LineLength * (StrLen(Delimiter) - 1)))

        if (!LineLength) {
            Loop this.Size {
                Out .= Format("{:02X}", NumGet(this, A_Index - 1, "UChar"))
                Out .= Delimiter
            }
            return Out
        }
        
        Loop this.Size {
            Out .= Format("{:02X}", NumGet(this, A_Index - 1, "UChar"))
            if (Mod(A_Index, LineLength)) {
                Out .= Delimiter
            } else {
                Out .= "`n"
            }
        }
        return Out
    }

    /**
     * Returns a buffer entirely containing the string `Str`
     * encoded in `Encoding`.
     * @example
     * 
     * Buf := Buffer.OfString("foo", "UTF-8")
     * 
     * @param   {String}      Str       any string
     * @param   {Primitive?}  Encoding  target encoding
     * @return  {Buffer}
     */
    static OfString(Str, Encoding?) {
        Str.AssertType(Primitive)
        Encoding.AssertType(Primitive)
        
        Buf := Buffer(StrPut(Str, Encoding?))
        StrPut(Str, Buf, Encoding?)
        return Buf
    }

    /**
     * Returns a string representation of this buffer consisting of
     * its type, memory address pointer and size in bytes.
     * @example
     * 
     * Buffer(128).ToString() ; "Buffer { Ptr: 000000000024D080, Size: 128 }"
     * 
     * @return  {String}
     */
    ToString() {
        Ptr  := Format("{:p}", this.Ptr)
        return Type(this) "{ Ptr: " . Ptr . ", Size: " . this.Size . " }"
    }
}
