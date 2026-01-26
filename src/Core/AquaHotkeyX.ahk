#Requires AutoHotkey >=v2.0.5

/**
 * @version 3.0.0-alpha
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 */

;-------------------------------------------------------------------------------
;@region Core

#Include "%A_LineFile%/../AquaHotkey.ahk"

;@endregion
;-------------------------------------------------------------------------------
;@region Base + Primitives

#Include "%A_LineFile%/../../Base/Buffer.ahk"
#Include "%A_LineFile%/../../Base/ComValue.ahk"
#Include "%A_LineFile%/../../Base/Error.ahk"
#Include "%A_LineFile%/../../Base/Object.ahk"
#Include "%A_LineFile%/../../Base/VarRef.ahk"

#Include "%A_LineFile%/../../Base/Assertions.ahk"
#Include "%A_LineFile%/../../Base/ToString.ahk"
#Include "%A_LineFile%/../../Base/TypeInfo.ahk"
#Include "%A_LineFile%/../../Base/TypeChecks.ahk"

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


#Include "%A_LineFile%/../../Collections/Generic/Array.ahk"
#Include "%A_LineFile%/../../Collections/Generic/Map.ahk"

#Include "%A_LineFile%/../../Collections/Array.ahk"
#Include "%A_LineFile%/../../Collections/Map.ahk"
#Include "%A_LineFile%/../../Collections/Set.ahk"
#Include "%A_LineFile%/../../Collections/HashMap.ahk"
#Include "%A_LineFile%/../../Collections/Zip.ahk"


;@endregion
;-------------------------------------------------------------------------------
;@region Functional

#Include "%A_LineFile%/../../Monads/Optional.ahk"
#Include "%A_LineFile%/../../Monads/TryOp.ahk"

#Include "%A_LineFile%/../../Stream/Range.ahk"
#Include "%A_LineFile%/../../Stream/Gatherer.ahk"

#Include "%A_LineFile%/../../Stream/Stream.ahk"
#Include "%A_LineFile%/../../Stream/BaseStream.ahk"
#Include "%A_LineFile%/../../Stream/DoubleStream.ahk"

;@endregion
;-------------------------------------------------------------------------------
;@region Mixins

#Include "%A_LineFile%/../../Interfaces/Indexable.ahk"
#Include "%A_LineFile%/../../Interfaces/Sizeable.ahk"
#Include "%A_LineFile%/../../Interfaces/Enumerable1.ahk"
#Include "%A_LineFile%/../../Interfaces/Enumerable2.ahk"

#Include "%A_LineFile%/../../Interfaces/ISet.ahk"
#Include "%A_LineFile%/../../Interfaces/IMap.ahk"

;@endregion
