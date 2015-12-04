package org.alivepdf.html;


import org.alivepdf.colors.IColor;
import org.alivepdf.colors.RGBColor;

@:final class FONTTagAttributes
{
    public var face : String;
    public var size : Int = 0;
    public var color : RGBColor;
    public var letterspacing : Int = 0;
    public var kerning : Int = 0;
    
    public function new(size : Int = 12, color : RGBColor = null, face : String = "notSupportedYet", letterspacing : Int = 0, kerning : Int = 0)
    {
        this.face = face;
        this.size = size;
        
        // we can't use RGBColor.BLACK as a default due to the infamous
        // Error 1047 (compiler bug)
        if (color == null) {
            this.color = RGBColor.BLACK;
        }
        else {
            this.color = color;
        }
        
        
        this.letterspacing = letterspacing;
        this.kerning = kerning;
    }
    
    public function clone() : FONTTagAttributes{
        return new FONTTagAttributes(this.size, this.color, this.face, this.letterspacing, this.kerning);
    }
}
