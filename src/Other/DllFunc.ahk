/**
 * AquaHotkey - DllFunc.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Other/DllFunc.ahk
 */
class DllFunc {
    /**
     * Contructs a new `BoundFunc` which calls `DllCall()` bound to the given
     * type signature `Types`.
     * 
     * @param   {String/Integer}  Function  DLL function name or memory address
     * @param   {String/Array}    Types     array of strings or comma-delimited
     *                                      list of parameter types
     * @return  {BoundFunc}
     */
    static Call(Function, Types) {
        if (!IsObject(Types)) {
            Types := StrSplit(Types, ",", A_Space)
        }
        if (!(Types is Array)) {
            throw TypeError("Expected an Array",, Type(Types))
        }
        Mask := Array()
        Mask.Capacity := Types.Length * 2
        for T in Types {
            if (!DllCallType.Exists(T)) {
                T := DllCallType.FromWindowsType(T)
            }
            Mask.Push(T, unset)
        }
        if (Mask.Length) {
            Mask.Pop()
        }
        return DllCall.Bind(Function, Mask*)
    }
}
