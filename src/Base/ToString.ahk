#Include "%A_LineFile%\..\..\Core\AquaHotkey.ahk"

/**
 * Provides string representations across all AutoHotkey types by adding
 * a broad range of `.ToString()` methods.
 * 
 * This allows you to use `String(Value)` to return a string representation of
 * any given value.
 * 
 * @module  <Base/ToString>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @example
 * 
 * String({ Foo: "bar" })    ; "Object { "Foo": "bar" }"
 * Array(1, 2, 3).ToString() ; "[1, 2, 3]"
 * 
 * ; get the `.ToString()` function explicitly used by `Object.Prototype`
 * Obj_ToStr := Object.ToString
 * 
 * Obj_ToStr(Array(1, 2, 3)) ; "Array { 1: 1, 2: 2, 3: 3 }"
 * Obj_ToStr("foo") ; Error! Expected an Object.
 * 
 * Any.ToString("test") ; "test"
 * 
 * MsgBox(String(Obj))
 */
class AquaHotkey_ToString extends AquaHotkey
{
;@region Any
class Any {
    /**
     * Default `.ToString()` method.
     * 
     * @returns {String}
     */
    ToString() => String(this)
}

;@endregion
;-------------------------------------------------------------------------------
;@region Object

class Object {
    /**
     * Converts this object into a string.
     * 
     * @returns {String}
     * @example
     * ({ Foo: 45, Bar: 123 }) ; "Object { "Bar": 123, "Foo": 45 }"
     */
    ToString() {
        static ToString(Value?) {
            if (!IsSet(Value)) {
                return "unset"
            }
            if (Value is String) {
                return '"' . Value . '"'
            }
            return String(Value)
        }

        loop {
            try {
                Result := ""
                for Key, Value in this {
                    if (A_Index != 1) {
                        Result .= ", "
                    }
                    Result .= ToString(Key?) . ": " . ToString(Value?)
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
                for PropName, Value in ObjOwnProps(this) {
                    if (A_Index != 1) {
                        Result .= ", "
                    }
                    Result .= ToString(PropName?) . ": " . ToString(Value?)
                }
                break
            }
            return Type(this)
        } until true

        return Type(this) . " { " . (Result ?? "unset") . " }"
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Primitive

class Primitive {
    /**
     * Returns this number as string.
     * 
     * @returns {String}
     */
    ToString() => String(this)
}

;@endregion
;-------------------------------------------------------------------------------
;@region String

class String {
    /**
     * Returns the string itself as string presentation.
     * 
     * @returns {String}
     */
    ToString() => this
}

;@endregion
;-------------------------------------------------------------------------------
;@region Array

class Array {
    /**
     * Returns the string representation of the array.
     * 
     * @returns {String}
     * @example
     * Array(1, 2, 3, 4).ToString() ; "[1, 2, 3, 4]" 
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
;-------------------------------------------------------------------------------
;@region Buffer

class Buffer {
    /**
     * Returns a string representation of the buffer consisting of
     * its type, memory address pointer and size in bytes.
     * 
     * @returns {String}
     * @example
     * Buffer(128).ToString() ; "Buffer { Ptr: 000000000024D080, Size: 128 }"
     */
    ToString() {
        Ptr  := Format("{:p}", this.Ptr)
        return Type(this) . "{ Ptr: " . Ptr . ", Size: " . this.Size . " }"
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Class

class Class {
    /**
     * Returns the string representation of the class if no argument is given.
     * 
     * Otherwise, explicitly uses the `.ToString()` method declared in the
     * calling class to convert the input into its string representation.
     * 
     * @returns {String}
     * @example
     * Gui.ToString()       ; "Class Gui"
     * 
     * Arr := Array(34, 8)
     * Arr.ToString()       ; [34, 8]
     * Object.ToString(Arr) ; "{ 1: 34, 2: 8 }"
     */
    ToString(Args*) {
        if (!Args.Length) {
            return "Class " . this.Prototype.__Class
        }
        if (Args.Length != 1) {
            throw ValueError("invalid param count: " . Args.Length)
        }
        Value := Args[1]
        if (!(Value is this)) {
            throw TypeError("Expected a(n) " . this.Prototype.__Class,,
                            Type(Value))
        }
        return (this.Prototype.ToString)(Value)
    }

    /**
     * Returns a type-checked `.ToString()` function.
     * 
     * @returns {Func}
     * @see {@link AquaHotkey_ToString.Class#ToString() Class#ToString}
     * @example
     * ToStr := Array.ToString
     * 
     * ToStr([1, 2, 3]) ; "[1, 2, 3]"
     */
    ToString => (Value) => this.ToString(Value)
}

;@endregion
;-------------------------------------------------------------------------------
;@region File

class File {
    /**
     * Returns a string representation of this file, consisting of file name,
     * position of file pointer, encoding and the system file handle.
     * 
     * @returns {String}
     * @example
     * ; "File { Name: C:\...\foo.txt, Pos: 0, Encoding: UTF-8, Handle: 362 }"
     * MyFile.ToString()
     */
    ToString() {
        return Format("{} {{} Name: {}, Pos: {}, Encoding: {}, Handle: {} {}}",
                Type(this), this.Name, this.Pos,
                this.Encoding, this.Handle)
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region Func

class Func {
    /**
     * Returns the string representation of the function.
     * 
     * @returns {String}
     * @example
     * MsgBox.ToString() ; "Func MsgBox"
     */
    ToString() {
        if (this.Name == "") {
            return Type(this) . " (unnamed)"
        }
        return Type(this) . " " . this.Name
    }
}

;@endregion
;-------------------------------------------------------------------------------
;@region VarRef

class VarRef {
    /**
     * Returns a string representation of the reference.
     * 
     * @returns {String}
     * @example
     * Bar := &(Foo := 2)
     * Bar.ToString() ; "VarRef<2>"
     */
    ToString() => "VarRef<" . (IsSetRef(this) ? String(%this%) : "unset") . ">"
}

;@endregion
;-------------------------------------------------------------------------------
;@region ComValue

class ComValue {
    /**
     * Returns the string representation of this `ComValue`.
     * 
     * @returns {String}
     */
    ToString() => Format("{} {{} Type: {}, Value: {} {}}",
                         Type(this),
                         ComObjType(this),
                         ComObjValue(this))
} ; class ComValue
;@endregion

} ; class AquaHotkey_ToString extends AquaHotkey
