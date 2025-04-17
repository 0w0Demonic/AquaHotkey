#Requires AutoHotkey >=v2.0.5
#Include %A_LineFile%/../../../AquaHotkey.ahk

/**
 * This extension adds a `Gui.Animation` class which wraps around the
 * SysAnimate32 windows control.
 */
class GuiAnimationExtension extends AquaHotkey {
    class Gui {
        /**
         * Adds an animation to the Gui. If specified, the animation control
         * opens an AVI file from the given file path or resource identifier
         * and module handle.
         * 
         * @example
         * 
         * GuiObj.AddAnimation("w500 h500", "path/to/file.avi")
         * GuiObj.AddAnimation("", 161, Shell32.Ptr)
         * 
         * @param   {String}            Opt     additional options
         * @param   {Integer?/String?}  wParam  file path or resource identifier
         * @param   {String}            lParam  module handle to load AVI from
         * @return  {Gui.Animation}
         */
        AddAnimation(Opt := "", wParam?, lParam?) {
            Ctl := this.Add("Custom", "ClassSysAnimate32 " . Opt)
            ObjSetBase(Ctl, Gui.Animation.Prototype)

            if (IsSet(wParam) || IsSet(lParam)) {
                Ctl.Open(wParam, lParam?)
            }
            return Ctl
        }

        class Animation extends Gui.Custom {
            ACM_OPEN      => 0x0400 + 103
            ACM_STOP      => 0x0400 + 102
            ACM_ISPLAYING => 0x0400 + 104

            ACS_CENTER      => 0x0001
            ACS_TRANSPARENT => 0x0002
            ACS_AUTOPLAY    => 0x0004
            ACS_TIMER       => 0x0008

            /**
             * Opens an AVI file from the given file path or resource identifier
             * and module handle.
             * 
             * @example

             * ; class Shell32 extends DLL { ... }
             * 
             * Anim.Open("path/to/file.avi")
             * Anim.Open(161, Shell32.Ptr)
             * Anim.Open(161, Shell32)
             * 
             * @param   {Integer?/String?}  Rsrc    file path or resource ID
             * @param   {Integer?/Object?}  Module  module handle to load from
             * @return  {Boolean}
             */
            Open(Rsrc, Module?) {
                if (IsSet(Module) && IsObject(Module)) {
                    Module := Module.Ptr
                }
                if (IsSet(Module)) {
                    return SendMessage(this.ACM_OPEN, Module, Rsrc, this)
                }
                return SendMessage(this.ACM_OPEN, 0, StrPtr(Rsrc), this)
            }

            /**
             * Closes an AVI clip.
             * 
             * @return   {Boolean}
             */
            Close() => SendMessage(this.ACM_OPEN, 0, 0, this.Hwnd)

            /**
             * Plays an AVI clip in the animation control.
             * 
             * @param   {Integer?}  From  first frame
             * @param   {Integer?}  To    last frame,        -1 == play all
             * @param   {Integer?}  Rep   number of repeats, -1 == forever
             * @return  {Boolean}
             */
            Play(From := 0, To := -1, Rep := -1) {
                return SendMessage(0x400 + 101, Rep,
                                   (From & 0xFFFF) | ((To & 0xFFFF) << 16),
                                   this)
            }

            /**
             * Stops playing an AVI in the animation control.
             * 
             * @return  {Boolean}
             */
            Stop() => SendMessage(this.ACM_STOP, 0, 0, this)

            /**
             * Checks if an AVI clip is playing in the control.
             * 
             * @return  {Boolean}
             */
            IsPlaying => SendMessage(this.ACM_ISPLAYING, 0, 0, this)

            /**
             * Displays a particular frame of an AVI clip.
             * 
             * @return  {Boolean}
             */
            Seek(Frame) => this.Play(Frame, Frame, 1)
        }
    }
}
