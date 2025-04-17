class AquaHotkey_MsgBox extends AquaHotkey {
/**
 * AquaHotkey - MsgBox.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Functions/MsgBox.ahk
 */
class MsgBox {
    class ButtonLayout extends UninstantiableClass
    {
        static OK                     => 0x0
        static O                      => 0x0
        static OKCancel               => 0x1
        static OC                     => 0x1
        static AbortRetryIgnore       => 0x2
        static ARI                    => 0x2
        static YesNoCancel            => 0x3
        static YNC                    => 0x3
        static YesNo                  => 0x4
        static YN                     => 0x4
        static RetryCancel            => 0x5
        static RC                     => 0x5
        static CancelTryAgainContinue => 0x6
        static CTC                    => 0x6
    }

    class Icon extends UninstantiableClass
    {
        static Error      => 0x10
        static Question   => 0x20
        static Warning    => 0x30
        static Info       => 0x40
    }

    static Default2       => 0x100
    static Default3       => 0x200
    static Default4       => 0x300

    static SystemModal    => 0x1000
    static TaskModal      => 0x2000
    static AlwaysOnTop    => 0x40000

    static HelpButton     => 0x4000
    static RightJustified => 0x80000
    static RightToLeft    => 0x100000
} ; class MsgBox
} ; class AquaHotkey_MsgBox extends AquaHotkey