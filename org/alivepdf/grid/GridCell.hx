package org.alivepdf.grid;


import org.alivepdf.colors.IColor;
import org.alivepdf.colors.RGBColor;

class GridCell
{
    public var text : String;
    public var backgroundColor : IColor;
    
    public function new(text : String, bgcolor : IColor = null)
    {
        this.text = ((text == null)) ? "" : text;
        this.backgroundColor = (bgcolor != null) ? bgcolor : new RGBColor(0xffffff);
    }
}
