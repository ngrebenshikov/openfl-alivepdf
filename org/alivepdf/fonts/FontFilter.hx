package org.alivepdf.fonts;


import org.alivepdf.fonts.EmbeddedFont;
import org.alivepdf.fonts.CoreFont;

@:final class FontFilter
{
    public static var EMBEDDED : Class<Dynamic> = EmbeddedFont;
    public static var CORE : Class<Dynamic> = CoreFont;

    public function new()
    {
    }
}
