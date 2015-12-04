package org.alivepdf.colors;


@:final class SpotColor implements IColor
{
    private static var idRef : Int = 0;
    public var i : Int = 0;
    public var n : Int = 0;
    public var name : String;
    public var color : CMYKColor;
    
    public function new(name : String, color : CMYKColor)
    {
        i = SpotColor.idRef++;
        this.name = name;
        this.color = color;
    }
}
