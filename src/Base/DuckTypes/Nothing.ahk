#Include "%A_LineFile%\..\..\DuckTypes.ahk"

/**
 * @duck
 * 
 * A {@link AquaHotkey_DuckType duck type} that represents `unset`.
 * 
 * @module  <Base/DuckTypes/Nothing>
 * @author  0w0Demonic
 * @see     https://www.github.com/0w0Demonic/AquaHotkey
 * @param   {Any?}  Val  any value
 * @returns {Boolean}
 * @example
 * ; `.IsInstance()` duck type checks
 * Nothing.IsInstance(unset) ; true
 * Nothing.IsInstance(42)    ; false
 * 
 * ; `.CanCastFrom()` type relations
 * Nothing.CanCastFrom(Any) ; false
 * Any.CanCastFrom(Nothing) ; false
 * Nothing.IsInstance(Any)  ; false
 * Any.IsInstance(Nothing)  ; false
 * 
 * ; edge case: can cast to itself
 * Nothing.CanCastFrom(Nothing) ; true
 */
Nothing(Val?) => !IsSet(Val)
