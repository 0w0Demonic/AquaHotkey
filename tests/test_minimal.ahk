; << for quick one-off tests >>
#Requires AutoHotkey v2.0
#Include <AquaHotkeyX>

Base := Uri("http://example.com/docs/")
Target := Uri("http://example.com/docs/guide.html")

Rel := Base.Relativize(Target)
Rel.Path.Assert(Eq("guide.html"))

Rel.HasAuthority.Assert(Eq(false))
Rel.HasScheme.Assert(Eq(false))
