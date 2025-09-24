/**
 * AquaHotkey - ToString.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Builtins/ToString.ahk
 */
class AquaHotkey_ToString extends AquaHotkey {
;@region Array
class Array {
    /**
     * Returns the string representation of the array.
     * 
     * @example
     * Array(1, 2, 3, 4).ToString() ; "[1, 2, 3, 4]" 
     * 
     * @returns {String}
     */
    ToString() {
        static Mapper(Value?) {
            if (!IsSet(Value)) {
                return "unset"
            }
            if (Value is String) {
                return '"' . Value . '"'
            }
            return String(Value)
        }

        Result := "["
        for Value in this {
            if (A_Index != 1) {
                Result .= ", "
            }
            Result .= Mapper(Value?)
        }
        Result .= "]"
        return Result
    }
}
;@endregion

;@region Buffer
class Buffer {
    /**
     * Returns a string representation of this buffer consisting of
     * its type, memory address pointer and size in bytes.
     * 
     * @example
     * Buffer(128).ToString() ; "Buffer { Ptr: 000000000024D080, Size: 128 }"
     * 
     * @returns {String}
     */
    ToString() {
        Ptr  := Format("{:p}", this.Ptr)
        return Type(this) . "{ Ptr: " . Ptr . ", Size: " . this.Size . " }"
    }
}
;@endregion

;@region Class
class Class {
    /**
     * Returns the string representation of the class.
     * 
     * @example
     * Gui.ToString() ; "Class Gui"
     * 
     * @returns {String}
     */
    ToString() => "Class " . this.Prototype.__Class
}
;@endregion

;@region File
class File {
    /**
     * Returns a string representation of this file, consisting of file name,
     * position of file pointer, encoding and the system file handle.
     * @example
     * 
     * ; "File { Name: C:\...\foo.txt, Pos: 0, Encoding: UTF-8, Handle: 362 }"
     * MyFile.ToString()
     * 
     * @returns {String}
     */
    ToString() {
        Pattern := "File{{} Name: {}, Pos: {}, Encoding: {}, Handle: {} {}}"
        return Format(Pattern, this.Name, this.Pos, this.Encoding, this.Handle)
    }
}
;@endregion

;@region Func
class Func {
    /**
     * Returns the string representation of the function.
     * 
     * @example
     * MsgBox.ToString() ; "Func MsgBox"
     * 
     * @returns {String}
     */
    ToString() {
        if (this.Name == "") {
            return Type(this) . " (unnamed)"
        }
        return Type(this) . " " . this.Name
    }
}
;@endregion

;@region Object
class Object {
    /**
     * Converts this object into a string. `String(Obj)` implicitly calls this
     * method.
     * 
     * The behavior of this method might be changed in future versions.
     * 
     * @example
     * ({ Foo: 45, Bar: 123 }) ; "Object {Bar: 123, Foo: 45}"
     * 
     * @returns {String}
     */
    ToString() {
        static KeyValueMapper(Key, Value?) {
            if (!IsSet(Value)) {
                Value := "unset"
            } else if (Value is String) {
                Value := '"' . Value . '"'
            }
            return Key . ": " . Value
        }

        Loop {
            try {
                Result := ""
                for Key, Value in this {
                    if (A_Index != 1) {
                        Result .= ", "
                    }
                    Result .= KeyValueMapper(Key, Value?)
                }
                break
            }
            try {
                Result := ""
                for Value in this {
                    if (A_Index != 1) {
                        Result .= ", "
                    }
                    Value := Value ?? "unset"
                    Result .= String(Value)
                }
                break
            }
            try {
                Result := ""
                for PropName, Value in this.OwnProps() {
                    if (A_Index != 1) {
                        Result .= ", "
                    }
                    Result .= KeyValueMapper(PropName, Value?)
                }
            }
            return Type(this)
        } until true

        return Type(this) . "{ " . (Result ?? "unset") . " }"
    }
}
;@endregion

;@region VarRef
class VarRef {
    /**
     * Returns a string representation of the reference.
     * 
     * @example
     * Bar := &(Foo := 2)
     * Bar.ToString() ; "&Foo"
     * 
     * @returns {String}
     */
    ToString() {
        pName := NumGet(ObjPtr(this) + 8 + 6 * A_PtrSize, "Ptr")
        return "&" . StrGet(pName, "UTF-16") 
    }
} ; class VarRef
;@endregion
} ; class AquaHotkey_ToString extends AquaHotkey