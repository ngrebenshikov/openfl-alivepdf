package org.alivepdf.fonts;




/**
   * This class is a static dictionnary to cache CoreFont object
   * @author Félix Gerzaguet
   * 
   */
import haxe.ds.StringMap;

@:final class CoreFontCache
{
    private static var dict :StringMap<Dynamic> = new StringMap<Dynamic>();
    
    public static function getFont(fontName : String) : CoreFont
    {
        var cachedFont : CoreFont = Reflect.field(dict, fontName);
        
        if (cachedFont == null) {
            cachedFont = new CoreFont(fontName);
            dict.set(fontName, cachedFont);
        }
        
        return cachedFont;
    }

    public function new()
    {
    }
}
