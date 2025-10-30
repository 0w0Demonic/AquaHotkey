#Requires AutoHotkey >=v2.0.5

/**
 * AquaHotkey - AquaHotkeyX.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Core/AquaHotkeyX.ahk
 */
;@region Core
#Include "%A_LineFile%/../AquaHotkey.ahk"
;@endregion

;@region Builtins
#Include "%A_LineFile%/../../Builtins/Any.ahk"
#Include "%A_LineFile%/../../Builtins/Array.ahk"
#Include "%A_LineFile%/../../Builtins/Buffer.ahk"
#Include "%A_LineFile%/../../Builtins/Class.ahk"
#Include "%A_LineFile%/../../Builtins/ComValue.ahk"
#Include "%A_LineFile%/../../Builtins/Error.ahk"
#Include "%A_LineFile%/../../Builtins/Func.ahk"
#Include "%A_LineFile%/../../Builtins/Integer.ahk"
#Include "%A_LineFile%/../../Builtins/Map.ahk"
#Include "%A_LineFile%/../../Builtins/Number.ahk"
#Include "%A_LineFile%/../../Builtins/Object.ahk"
#Include "%A_LineFile%/../../Builtins/Primitive.ahk"
#Include "%A_LineFile%/../../Builtins/String.ahk"
#Include "%A_LineFile%/../../Builtins/VarRef.ahk"
;@endregion

;@region Builtins (advanced)
#Include "%A_LineFile%/../../Builtins/Pipes.ahk"
#Include "%A_LineFile%/../../Builtins/Assertions.ahk"
#Include "%A_LineFile%/../../Builtins/ToString.ahk"

#Include "%A_LineFile%/../../Builtins/StringMatching.ahk"
#Include "%A_LineFile%/../../Builtins/Substrings.ahk"
#Include "%A_LineFile%/../../Builtins/FileUtils.ahk"
#Include "%A_LineFile%/../../Builtins/StreamOps.ahk"
;@endregion

;@region Extensions
#Include "%A_LineFile%/../../Extensions/Optional.ahk"
#Include "%A_LineFile%/../../Extensions/Range.ahk"
#Include "%A_LineFile%/../../Extensions/Stream.ahk"
#Include "%A_LineFile%/../../Extensions/Collector.ahk"
#Include "%A_LineFile%/../../Extensions/Gatherer.ahk"
#Include "%A_LineFile%/../../Extensions/Condition.ahk"
#Include "%A_LineFile%/../../Extensions/Mapper.ahk"
#Include "%A_LineFile%/../../Extensions/Combiner.ahk"
#Include "%A_LineFile%/../../Extensions/Comparator.ahk"
#Include "%A_LineFile%/../../Extensions/Zip.ahk"
;@endregion