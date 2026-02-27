; << for quick one-off tests >>
#Requires AutoHotkey v2.0
#Include <AquaHotkeyX>

Target := Uri("https://example.com/a/b/c/d")
Base := Uri("https://example.com/a/b/")
Rel := Base.Relativize(Target) ; --> "c/d"
Rel.ToString().MsgBox()
Base.Resolve(Rel).ToString().MsgBox()
