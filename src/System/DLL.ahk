/**
 * AquaHotkey - DLL.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Extensions/DLL.ahk
 * 
 * ---
 * 
 * **Overview**:
 * 
 * The `DLL` class provides an object-oriented interface for dynamically
 * loading and interacting with DLL files in a clean and structured way.
 * It automatically loads and frees the library, resolves function addresses
 * and binds method signatures for type safety.
 * 
 * **How to Use**:
 * 
 * To create a DLL wrapper, define a subclass and specify the target DLL using
 * the `static FilePath` property:
 * 
 * ```
 * class User32 extends DLL {
 *     static FilePath => "user32.dll"
 * }
 * ```
 * 
 * This automatically resolves all named exports of `user32.dll` by memory
 * address when the class is initialized.
 * 
 * **Defining Function Signatures**:
 * 
 * Function parameters can be defined explicitly via:
 * 
 * 1. Assigning signatures dynamically:
 * 
 * ```
 * User32.CharUpper := ["Str", "Str"]
 * ```
 * 
 * 2. Defining them inside the subclass:
 * 
 * ```
 * class User32 extends DLL {
 *     static FilePath => "user32.dll"
 * 
 *     static TypeSignatures => {
 *         MessageBox: ["Ptr", "Str", "Str", "UInt", "Int"],
 *         CharUpper: "Str, Str"
 *         ; ...
 *     }
 * }
 * ```
 * 
 * **Function Resolution Behavior**:
 * 
 * - If a method is **directly defined**, it is used immediately.
 * - If a method is **not available**, the class automatically 
 *   tries **appending "W" (Wide)**.
 * - Once resolved, the function address is retroactively added as property,
 *   improving performance for repeated calls.
 * 
 * **Using Hidden Ordinal Functions**:
 * 
 * The `DLL` class supports calling undocumented functions that are **only
 * accessible via ordinal numbers** rather than exported names. The functions
 * are automatically loaded whenever an entry in the `TypeSignatures` property
 * starts with a **numeric value** (indicating an ordinal).
 * 
 * ```
 * class UXTheme extends DLL {
 *     static FilePath => "uxtheme.dll"
 * 
 *     static TypeSignatures => {
 *         SetPreferredAppMode: [135, "Int"],
 *         FlushMenuThemes:     [136]
 *     }
 * }
 * ```
 * 
 * Note that **hidden functions are undocumented** and may very between Windows
 * versions.
 * 
 * **Limitations**:
 * 
 * Each subclass can only reference a single DLL.
 * 
 * Further subclasses cannot override properties:
 * - `static FilePath`
 * - `static TypeSignatures` 
 * - `static Ptr`
 * 
 * **Example Usage**:
 * 
 * ```
 * class Kernel32 extends DLL {
 *     static FilePath => "kernel32"
 * 
 *     static TypeSignatures {
 *         GetTickCount: ["UInt"]
 *     }
 * }
 * 
 * TickCount := Kernel32.GetTickCount()
 * 
 * ; defining a function signature
 * Kernel32.Sleep := ["UInt"]
 * 
 * ; sleep for one second
 * Kernel32.Sleep(1000)
 * ```
 */
class DLL extends Any {
    /**
     * Static class constructor that loads the DLL file and dynamically creates
     * properties.
     */
    static __New() {
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
            static Delete := (Object.Prototype.DeleteProp)
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
                DllClass.DefineProp(Name, {
                    Get: CreateGetter(Addr),
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
            this.DefineProp("Ptr", { Get: (Instance) => hModule })
        }

        LoadProperties(this, TypeSignatures)
    }

    /**
     * Sets a new type signature for a method `PropName` of this DLL class.
     * @example
     * 
     * class User32 extends DLL {
     *     static FilePath => "user32.dll"
     * }
     * 
     * User32.CharUpper := "Ptr, Str"            ; ["Ptr", "Str"]
     * User32.CharUpper(StrPtr("Hello, world!")) ; "HELLO, WORLD!"
     * 
     * @example
     * 
     * class UXTheme extends DLL {
     *     static FilePath => "uxtheme.dll"
     * }
     * 
     * UXTheme.SetPreferredAppMode := [135, "Int"]
     * UXTheme.FlushMenuThemes     := [136]
     * 
     * @param   {String}
     * @param   {Array}
     * @param   {String/Array}
     */
    static __Set(PropName, Args, TypeSignature) {
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

        BaseClass.DefineProp(PropName, {
            Get:  CreateGetter(EntryPoint),
            Set:  CreateSetter(PropName),
            Call: CreateCallback(EntryPoint, TypeSignature)
        })

        static CreateCallback(EntryPoint, TypeSignature) {
            DllCallback := DLL.Func(EntryPoint, TypeSignature)
            return (Instance, Args*) => DllCallback(Args*)
        }

        static CreateGetter(Addr) {
            return (Instance) => Addr
        }

        static CreateSetter(Name) {
            return (Instance, Signature) => Instance.__Set(Name, [], Signature)
        }
    }

    /**
     * This method is called whenever an undefined property is retrieved and
     * attempts to find a property with a "-W" suffix.
     * 
     * If a property was found, it will be retroactively defined for the class
     * to avoid calling this meta-function again.
     * 
     * @example
     * 
     * class User32 extends DLL {
     *     static FilePath => "user32.dll"
     * }
     * ; only properties `MessageBoxA` and `MessageBoxW` exist
     * EntryPoint := User32.MessageBox 
     * 
     * @param   {String}  PropName  name of the undefined property
     * @param   {Array}   Args      zero or more arguments (ignored)
     */
    static __Get(OldPropName, Args) {
        NewPropName := OldPropName . "W"
        if (HasProp(this, NewPropName)) {
            this.DefineProp(OldPropName, this.GetOwnPropDesc(NewPropName))
            return this.%NewPropName%
        }
        throw PropertyError("DLL function does not exist",, OldPropName)
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
    static __Call(OldPropName, Args) {
        NewPropName := OldPropName . "W"
        if (HasProp(this, NewPropName)) {
            this.DefineProp(OldPropName, this.GetOwnPropDesc(NewPropName))
            return this.%NewPropName%(Args*)
        }
        throw PropertyError("DLL function does not exist",, OldPropName)
    }

    /**
     * Binds a DLL function to a callable AutoHotkey function.
     * 
     * Accepts either a function name (String) or memory address (Integer),
     * and a variadic list of type parameters and return type (Array or
     * comma-delimited list of strings).
     * 
     * @example
     * 
     * sqrt := DLL.Func("msvcrt\sqrtf", "Float", "Float")
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
            static GetProp := (Object.Prototype.GetOwnPropDesc)
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