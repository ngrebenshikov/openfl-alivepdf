package org.alivepdf.colors;


@:final class RGBColor implements IColor
{
    
    public static var BLACK : RGBColor = new RGBColor(0x000000);
    
    public var r : Int = 0;
    public var g : Int = 0;
    public var b : Int = 0;
    
    public function new(color : Int)
    {
        r = (color >> 16) & 0xFF;
        g = (color >> 8) & 0xFF;
        b = color & 0xFF;
    }
    
    public static function hexStringToRGBColor(hex : String) : RGBColor
    {
        hex = hex.toLowerCase();
        
        var l : Int = 0;
        
        // Strip "0x"
        
        if (hex.indexOf("0x") > -1) 
        {
            l = hex.length - 2;
            hex = hex.substr(hex.length - l, l);
        }
        
        if (hex.indexOf("#") > -1) 
        {
            l = hex.length - 1;
            hex = hex.substr(hex.length - l, l);
        }  // Trim/Extend to correct size  
        
        
        
        l = hex.length;
        
        if (l > 6) 
            hex = hex.substr(0, 6);
        
        var c : Int = Std.parseInt("0x"+hex);
        
        return new RGBColor(c);
    }
}
