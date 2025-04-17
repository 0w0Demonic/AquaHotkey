/**
 * AquaHotkey - DllCallType.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Other/DllCallType.ahk
 */
class DllCallType extends UninstantiableClass {
    /**
     * Returns `true`, if `Str` is a valid `DllCall()` type.
     * @example
     * 
     * DllCallType.Exists("UInt*") ; true
     * 
     * @param   {String}  Str  any string to be used as type argument
     * @return  {Boolean}
     */
    static Exists(Str) {
        static DataTypes := CreateMap()
        static CreateMap() {
            Values := StrSplit("
                    ( Join`s
                    int64,  int64p,  int64*, uint64, uint64p, uint64*,
                    int,    intp,    int*,   uint,   uintp,   uint*,
                    short,  shortp,  short*, ushort, ushortp, ushort*,
                    char,   charp,   char*,  uchar,  ucharp,  uchar*,
                    ptr,    ptrp,    ptr*,   uptr,   uptrp,   uptr*,
                    str,    strp,    str*,   astr,   astrp,   astr*,
                    wstr,   wstrp,   wstr*
                    float,  floatp,  float*,
                    double, doublep, double*,
                    hresult
                    )", ",", A_Space)

            DataTypes := Map()
            DataTypes.CaseSense := false
            for DataType in Values {
                DataTypes[DataType] := true
            }
            return DataTypes
        }
        return DataTypes.Has(Str)
    }

    /**
     * Returns an appropriate AutoHotkey `DllCall()` type for the
     * given Windows data type.
     * @example
     * 
     * DllCallType.FromWindowsType("DWORD") ; "UInt"
     * 
     * @param   {String}  WinType  windows data type
     * @return  {String}
     */
    static FromWindowsType(WinType) {
        static DataTypes := CreateMap()
        static CreateMap() {
            DataTypes := Map(
                "Int64", "INT64, LONGLONG, LONG64, USN",
                "Int64P", "PINT64, PLONGLONG, PLONG64",
                "UInt64", "DWORDLONG, DWORD64, QWORD, UINT64, ULONGLONG,"
                        . "ULONG64",
                "UInt64P", "PDWORDLONG, PDWORD64, POINTER_64, PULONGLONG,"
                         . "PULONG64, PUINT64",
                "Int", "BOOL, HFILE, HRESULT, INT, INT32, LONG, LONG32",
                "IntP", "LPBOOL, LPINT, LPLONG, PBOOL, PINT, PINT32, PLONG,"
                      . "PLONG32",
                "UInt", "COLORREF, DWORD, DWORD32, LCID, LCTYPE, LGRPID,"
                      . "POINTER_32, UINT, UINT32, ULONG, ULONG32",
                "UIntP", "LPCOLORREF, LPDWORD, PDWORD, PDWORD32, PLCID, PUINT,"
                       . "PULONG, PULONG32, PUINT32",
                "Short", "INT16, SHORT",
                "ShortP", "PSHORT",
                "UShort", "ATOM, LANGID, PWORD, UINT16, USHORT, WORD, WCHAR,"
                        . "TCHAR, TBYTE",
                "UShortP", "LPWORD, PUINT16, PUSHORT, PWCHAR",
                "Char", "CHAR, CCHAR, INT8",
                "CharP", "PCHAR, PINT8",
                "UChar", "BYTE, BOOLEAN, UCHAR, UINT8",
                "UCharP", "LPBYTE, PBOOLEAN, PBYTE, PUINT8, PUCHAR",
                "Ptr", "DWORD_PTR, HACCEL, HANDLE, HBITMAP, HBRUSH,"
                     . "HCOLORSPACE, HCONV, HCURSOR, HDC, HDDEDATA, HDESK,"
                     . "HDROP, HDWP, HENHMETAFILE, HFONT, HGDIOBJ, HGLOBAL,"
                     . "HHOOK, HICON, HINSTANCE, HKEY, HKL, HLOCAL, HMENU,"
                     . "HMETAFILE, HMODULE, HMONITOR, HPALETTE, HPEN, HRGN,"
                     . "HRSRC, HSZ, HWINSTA, HWND, INT_PTR, LONG_PTR, LPARAM,"
                     . "LPCSTR, LPCTSTR, LPCVOID, LPCWSTR, LPSTR, LPTSTR,"
                     . "LPVOID, LPWSTR, LRESULT, PCSTR, PCTSTR, PCWSTR,"
                     . "POINTER_SIGNED, PSTR, PTSTR, PVOID, PWSTR, SC_HANDLE,"
                     . "SC_LOCK, SERVICE_STATUS_HANDLE, UNICODE_STRING,"
                     . "SSIZE_T, PTCHAR",
                "PtrP", "LPHANDLE, PDWORD_PTR, PHANDLE, PHKEY, PINT_PTR,"
                      . "PLONG_PTR, POINTER_UNSIGNED, PSSIZE_T",
                "UPtr", "UINT_PTR, ULONG_PTR, WPARAM, SIZE_T",
                "UPtrP", "PSIZE_T, PUINT_PTR, PULONG_PTR",
                "Str", "",
                "AStr", "",
                "WStr", "",
                "Float", "FLOAT",
                "FloatP", "PFLOAT",
                "Double", "",
                "DoubleP", ""
            )
            if (A_PtrSize == 8) {
                DataTypes["HALF_PTR"]   := "Int"
                DataTypes["UHALF_PTR"]  := "UInt"
                DataTypes["PHALF_PTR"]  := "IntP"
                DataTypes["PUHALF_PTR"] := "UIntP"
            } else {
                DataTypes["HALF_PTR"]   := "Short"
                DataTypes["UHALF_PTR"]  := "UShort"
                DataTypes["PHALF_PTR"]  := "ShortP"
                DataTypes["PUHALF_PTR"] := "UShortP"
            }

            Values           := Map()
            Values.CaseSense := false
            
            for AhkType, WindowsTypes in DataTypes {
                if (IsSpace(WindowsTypes)) {
                    continue
                }
                WindowsTypes := StrSplit(WindowsTypes, ",", " `s`r`n`t")
                for WindowsType in WindowsTypes {
                    Values[WindowsType] := AhkType
                }
            }

            return Values
        }
        
        if (IsObject(WinType)) {
            throw TypeError("Expected a String, but received an Object",,
                            Type(WinType))
        }
        if (DataType := DataTypes.Get(WinType, false)) {
            return DataType
        }
        if (WinType ~= "i)^(?:H|L?P)\w++$|(?:_PTR|\*)$") {
            return "Ptr"
        }
        throw ValueError("unsupported data type",, WinType)
    }
}
