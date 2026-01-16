/**
 * An object-oriented interface for loading and interacting with DDL files.
 * 
 * It automatically loads and frees the library, resolve function addresses and
 * creates methods that `DllCall()` the exposed function with a predefined type
 * signature.
 * 
 * ---
 * 
 * **How to Use**:
 * 
 * Define a subclass of `DLL` and specify the target DLL using
 * `static FilePath`:
 * 
 * ```ahk
 * class User32 extends DLL {
 *     static FilePath => "user32.dll"
 * }
 * ```
 * 
 * When the class loads, it loads the specified library (`"user32.dll"`) and
 * resolves all of its named exports by memory address.
 * 
 * ---
 * 
 * **Function Signatures**:
 * 
 * If a function signature is defined (`static TypeSignatures`), a method
 * for the exported function is created automatically:
 * 
 * ```ahk
 * class User32 extends DLL {
 *     static FilePath => "user32.dll"
 * 
 *     static TypeSignature => {
 *         MessageBox: ["Ptr", "Str", "Str", "UInt", "Int"]
 *     }
 * }
 * 
 * ; alternatively, you can define it like this:
 * ; 
 * ;     User.MessageBox := ["Ptr", "Str", "Str", "UInt", "Int"]
 * 
 * User32.MessageBox(...)
 * ```
 * 
 * Struct classes in v2.1-alpha are supported, too.
 * 
 * ```ahk
 * class HDC { ... }
 * class RECT { ... }
 * 
 * class Gdi32 {
 *     static FilePath => "gdi32.dll"
 * 
 *     static TypeSignature => { InvertRect: [HDC, RECT, "Int"] }
 * }
 * ```
 * 
 * @module  <System/DLL>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */
class DLL extends Any {
    /**
     * Static class constructor that loads the DLL file and dynamically creates
     * properties.
     */
    static __New() {
        static Define := {}.DefineProp

        /**
         * Loads the library targeted by `static FilePath` and defines a `Ptr`
         * property containing the module handle.
         */
        static LoadLibrary(DllClass) {
            ; ensure the class has a `static FilePath` property
            if (!ObjHasOwnProp(DllClass, "FilePath")) {
                throw PropertyError("missing property: static FilePath",,
                                    String(DllClass))
            }

            ; try to retrieve the module handle
            FilePath := DllClass.FilePath
            hModule := DllCall("GetModuleHandle", "Str", FilePath, "Ptr")
            if (!hModule) {
                hModule := DllCall("LoadLibrary", "Str", FilePath, "Ptr")
                if (!hModule) {
                    throw TargetError("unable to load library",, FilePath)
                }
            }

            return hModule
        }

        /**
         * Deletes all properties from a class and from its prototype.
         */
        static DeleteAllProperties(DllClass) {
            static Delete := {}.DefineProp

            ; collect property names in an array before iterating
            for Target in Array(DllClass, DllClass.Prototype) {
                for PropertyName in Array(ObjOwnProps(Target)*) {
                    Delete(Target, PropertyName)
                }
            }
        }

        /**
         * This method iterates through the named export table of the DLL file,
         * generating properties in the process. Learn more about DLL files at:
         * https://learn.microsoft.com/de-de/windows/win32/debug/pe-format
         */
        static LoadProperties(DllClass, TypeSignatures) {

            ; navigate to the export table via relate memory addresses
            hModule          := DllClass.Ptr
            p_peHeader       := hModule + NumGet(hModule, 0x3C, "UInt")
            p_optionalHeader := p_peHeader + 0x18
            PE_format        := NumGet(p_optionalHeader, "UShort")

            switch (PE_format) {
                case 0x020B:         offset := 0x70
                case 0x010B, 0x0107: offset := 0x60
                default: throw ValueError("invalid PE format",, PE_format)
            }

            exportTableRva := NumGet(p_optionalHeader, offset, "UInt")
            p_exportTable  := hModule + exportTableRva

            if (exportTableMagic := NumGet(p_exportTable, "UInt")) {
                exportTableMagic := Format("{:#08X}", exportTableMagic)
                throw ValueError("this DLL has no exported functions",,
                                 "unexpected value " . exportTableMagic)
            }

            ; we use the table of names instead of the ordinal table, because
            ; documented functions are what interests us the most
            cNameEntries := NumGet(p_exportTable, 0x18, "UInt")
            p_names      := hModule + NumGet(p_exportTable, 0x20, "UInt")

            Loop cNameEntries {
                offset := (A_Index - 1) * 4
                p_name := hModule + NumGet(p_names, offset, "UInt")

                ; name and proc address of an exported DLL function
                Name   := StrGet(p_name, "CP0")
                Addr   := DllCall("GetProcAddress", "Ptr", hModule,
                                  "AStr", Name, "Ptr")

                ; define getter and setter using the name and proc address
                Define(DllClass, Name, {
                    Get: CreateSetter(Addr),
                    Set: CreateSetter(Name)
                })
            }

            static CreateGetter(Addr) => ((_) => Addr)

            static CreateSetter(Name) {
                return (Cls, Value) => Cls.__Set(Name, [], Value)
            }

            if (!TypeSignatures) {
                return
            }

            ; finally, define the custom type signatures we defined, if any
            for PropName, TypeSignature in ObjOwnProps(TypeSignatures) {
                DllClass.__Set(PropName, [], TypeSignature)
            }
        }

        if (this == DLL) {
            return
        }

        if (ObjGetBase(this) != DLL) {
            for PropName in Array("FilePath", "TypeSignatures", "Ptr") {
                if (ObjHasOwnProp(this, PropName)) {
                    throw PropertyError("cannot override this property",,
                                        PropName)
                }
            }
        }

        if (ObjHasOwnProp(this, "TypeSignatures")) {
            TypeSignatures := this.TypeSignatures
            if (!IsObject(TypeSignatures)) {
                throw TypeError("Expected an Object",, Type(TypeSignatures))
            }
        } else {
            TypeSignatures := Object()
        }

        if (ObjGetBase(this) == DLL) {
            hModule := LoadLibrary(this)
            DeleteAllProperties(this)
            Define(this, "Ptr", { Get: (_) => hModule })
        }

        LoadProperties(this, TypeSignatures)
    }

    /**
     * Sets a new type signature for a method `PropName` of this DLL class.
     * 
     * @param   {String}        PropName       name of the property
     * @param   {Array}         Args           ignored
     * @param   {String/Array}  TypeSignature  type signature of DLL function
     * @example
     * class User32 extends DLL {
     *     static FilePath => "user32.dll"
     * }
     * 
     * User32.CharUpper := "Ptr, Str"            ; ["Ptr", "Str"]
     * User32.CharUpper(StrPtr("Hello, world!")) ; "HELLO, WORLD!"
     * 
     * @example
     * class UXTheme extends DLL {
     *     static FilePath => "uxtheme.dll"
     * }
     * 
     * UXTheme.SetPreferredAppMode := [135, "Int"]
     * UXTheme.FlushMenuThemes     := [136]
     */
    static __Set(PropName, Args, TypeSignature) {
        static Define := {}.DefineProp

        if (!IsObject(TypeSignature)) {
            TypeSignature := StrSplit(TypeSignature, ",", A_Space)
        }
        if (!(TypeSignature is Array)) {
            throw TypeError("Expected a String or Array",, Type(TypeSignature))
        }

        IsOrdinal := (TypeSignature.Length && IsInteger(TypeSignature[1]))

        if (IsOrdinal) {
            Ordinal    := TypeSignature.RemoveAt(1)
            EntryPoint := DllCall("GetProcAddress", "Ptr", this.Ptr,
                                   "Ptr", Ordinal, "Ptr")
            if (!EntryPoint) {
                throw PropertyError("unable to resolve ordinal " . Ordinal)
            }
        } else if (HasProp(this, PropName)) {
            ; ehhhh?? good enough. `%` is making me paranoid...
            EntryPoint := this.%PropName%
        } else {
            PropName .= "W"
            if (!HasProp(this, PropName)) {
                throw PropertyError("DLL function does not exist",, PropName)
            }
            EntryPoint := this.%PropName%
        }

        BaseClass := this
        while (ObjGetBase(BaseClass) != DLL) {
            BaseClass := ObjGetBase(BaseClass)
        }

        Define(BaseClass, PropName, {
            Get:  CreateGetter(EntryPoint),
            Set:  CreateSetter(PropName),
            Call: CreateCallback(EntryPoint, TypeSignature)
        })

        static CreateCallback(EntryPoint, TypeSignature) {
            DllCallback := DLL.Func(EntryPoint, TypeSignature)
            return (_, Args*) => DllCallback(Args*)
        }

        static CreateGetter(Addr) {
            return (_) => Addr
        }

        static CreateSetter(Name) {
            return (Cls, Signature) => Cls.__Set(Name, [], Signature)
        }
    }

    /**
     * This method is called whenever an undefined property is retrieved and
     * attempts to find a property with a "-W" suffix.
     * 
     * If a property was found, it will be retroactively defined for the class
     * to avoid calling this meta-function again.
     * 
     * @param   {String}  PropName  name of the undefined property
     * @param   {Array}   Args      zero or more arguments (ignored)
     * @example
     * class User32 extends DLL {
     *     static FilePath => "user32.dll"
     * }
     * ; only properties `MessageBoxA` and `MessageBoxW` exist
     * EntryPoint := User32.MessageBox 
     */
    static __Get(PropName, Args) {
        static GetProp := {}.GetOwnPropDesc
        static Define  := {}.DefineProp

        NewPropName := PropName . "W"
        if (HasProp(this, NewPropName)) {
            PropDesc := GetProp(this, NewPropName)
            Define(this, PropName, PropDesc)
            return (PropDesc.Get)(this)
        }
        throw PropertyError("DLL function does not exist",, PropName)
    }

    /**
     * This method is called whenever an undefined method is called and attempts
     * to find a method with a "-W" suffix.
     * 
     * If a property was found, it will be retroactively defined for the class
     * to avoid calling this meta-function again.
     * 
     * @param   {String}  PropName  name of the undefined method
     * @param   {Array}   Args      zero or more additional arguments
     */
    static __Call(PropName, Args) {
        static GetProp := {}.GetOwnPropDesc
        static Define  := {}.DefineProp

        NewPropName := PropName . "W"
        if (HasProp(this, NewPropName)) {
            PropDesc := GetProp(this, NewPropName)
            Define(this, PropName, PropDesc)
            return (PropDesc.Get)(this)
        }
        throw PropertyError("DLL function does not exist",, PropName)
    }

    /**
     * Binds a DLL function to a callable AutoHotkey function.
     * 
     * Accepts either a function name (String) or memory address (Integer),
     * and a variadic list of type parameters and return type (Array or
     * comma-delimited list of strings).
     * 
     * @param   {String/Integer}  Function  DLL function name or memory address
     * @param   {Array}           Type      function signature
     * @returns {BoundFunc}
     * @example
     * sqrt := DLL.Func("msvcrt\sqrtf", ["Float", "Float"])
     * MsgBox(sqrt(9.0)) ; 3.0
     */
    static Func(Function, Types) {
        if (!IsObject(Types)) {
            Types := StrSplit(Types, ",", A_Space)
        }
        if (!(Types is Array)) {
            throw TypeError("Expected an Array",, Type(Types))
        }
        Mask := Array()
        Mask.Capacity := Types.Length * 2

        for T in Types {
            if (IsObject(T) && !(T is Class)) {
                throw TypeError("Expected a String or Class",, Type(T))
            }
            if (!IsStruct(T)) {
                T := "Ptr"
            }
            Mask.Push(T, unset)
        }
        if (Mask.Length) {
            Mask.Pop()
        }
        return ObjBindMethod(DllCall,, Function, Mask*)

        static IsStruct(Cls) {
            static GetProp := {}.GetOwnPropDesc
            if (VerCompare(A_AhkVersion, "2.1-alpha.3") < 0) {
                return false
            }
            if (!(Cls is Class)) {
                return false
            }
            for PropertyName in ObjOwnProps(Cls.Prototype) {
                PropDesc := GetProp(Cls.Prototype, PropertyName)
                if (ObjHasOwnProp(PropDesc, "Type")) {
                    return true
                }
            }
            return false
        }
    }
}