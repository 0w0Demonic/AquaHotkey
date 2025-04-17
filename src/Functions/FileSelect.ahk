class AquaHotkey_FileSelect extends AquaHotkey {
/**
 * AquaHotkey - FileSelect.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Functions/FileSelect.ahk
 */
class FileSelect {
    static SELECT_FOLDER    => "D"
    static MULTI_SELECT     => "M"
    static SAVE_DIALOG      => "S"

    static FILE_EXISTS      => 0x1
    static PATH_EXISTS      => 0x2
    static PROMPT_CREATE    => 0x8
    static PROMPT_OVERWRITE => 0x10
    static SHORTCUTS_AS_IS  => 0x20
} ; class FileSelect
} ; class AquaHotkey_FileSelect extends AquaHotkey