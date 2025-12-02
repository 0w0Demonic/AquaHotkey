#Requires AutoHotkey >=v2.0.5

/**
 * AquaHotkey - AquaHotkeyX.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Core/AquaHotkeyX.ahk
 */

;-------------------------------------------------------------------------------
;@region Core

#Include "%A_LineFile%/../AquaHotkey.ahk"

;@endregion
;-------------------------------------------------------------------------------
;@region Base + Primitives

#Include "%A_LineFile%/../../Base/Any.ahk"
#Include "%A_LineFile%/../../Base/Buffer.ahk"
#Include "%A_LineFile%/../../Base/Class.ahk"
#Include "%A_LineFile%/../../Base/ComValue.ahk"
#Include "%A_LineFile%/../../Base/Error.ahk"
#Include "%A_LineFile%/../../Base/Object.ahk"
#Include "%A_LineFile%/../../Base/VarRef.ahk"

#Include "%A_LineFile%/../../Base/Assertions.ahk"
#Include "%A_LineFile%/../../Base/ToString.ahk"

#Include "%A_LineFile%/../../Primitives/Integer.ahk"
#Include "%A_LineFile%/../../Primitives/Number.ahk"
#Include "%A_LineFile%/../../Primitives/Primitive.ahk"

#Include "%A_LineFile%/../../String/String.ahk"
#Include "%A_LineFile%/../../String/StringMatching.ahk"
#Include "%A_LineFile%/../../String/Substrings.ahk"

#Include "%A_LineFile%/../../Base/Eq.ahk"
#Include "%A_LineFile%/../../Base/Ord.ahk"
#Include "%A_LineFile%/../../Base/Hash.ahk"

#Include "%A_LineFile%/../../Func/Func.ahk"
#Include "%A_LineFile%/../../Func/Pipes.ahk"

#Include "%A_LineFile%/../../IO/FileUtils.ahk"

;@endregion
;-------------------------------------------------------------------------------
;@region Collections


#Include "%A_LineFile%/../../Collections/Array.ahk"
#Include "%A_LineFile%/../../Collections/Map.ahk"

#Include "%A_LineFile%/../../Collections/StreamOps.ahk"
#Include "%A_LineFile%/../../Collections/Comparator.ahk"
#Include "%A_LineFile%/../../Collections/Zip.ahk"

;@endregion
;-------------------------------------------------------------------------------
;@region Functional

#Include "%A_LineFile%/../../Monads/Optional.ahk"
#Include "%A_LineFile%/../../Monads/TryOp.ahk"

#Include "%A_LineFile%/../../Stream/Range.ahk"
#Include "%A_LineFile%/../../Stream/Stream.ahk"
#Include "%A_LineFile%/../../Stream/Collector.ahk"
#Include "%A_LineFile%/../../Stream/Gatherer.ahk"

#Include "%A_LineFile%/../../Func/Condition.ahk"
#Include "%A_LineFile%/../../Func/Mapper.ahk"
#Include "%A_LineFile%/../../Func/Combiner.ahk"

;@endregion
;-------------------------------------------------------------------------------