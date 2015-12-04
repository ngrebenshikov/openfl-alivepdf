package org.alivepdf.colors;




/**
   * This class is a static dictionnary to cache RGBColor objects by hexstring
   * @author Félix Gerzaguet
   * 
   */
import haxe.ds.StringMap;
@:final class RGBColorCache
{
    
    private static var dict : StringMap<Dynamic> = new StringMap<Dynamic>();
    
    public static function getColor(hex : String) : RGBColor
    {
        var cachedColor : RGBColor = Reflect.field(dict, hex);
        
        if (cachedColor == null) {
            cachedColor = RGBColor.hexStringToRGBColor(hex);
            Reflect.setField(dict, hex, cachedColor);
        }
        
        return cachedColor;
    }

    public function new()
    {
    }
}
