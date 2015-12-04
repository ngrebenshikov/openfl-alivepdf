package org.alivepdf.links;


@:final class Outline
{
    public var level : Int = 0;
    public var pages : Int = 0;
    public var text : String;
    public var y : Float;
    public var parent : Int = 0;
    public var first : Int = 0;
    public var next : Int = 0;
    public var prev : Int = 0;
    public var last : Int = 0;
    public var redMultiplier : Float;
    public var greenMultiplier : Float;
    public var blueMultiplier : Float;
    
    public function new(text : String, level : Int, pages : Int, y : Float, redMultiplier : Float, greenMultiplier : Float, blueMultiplier : Float)
    {
        this.text = text;
        this.level = level;
        this.pages = pages;
        this.y = y;
        this.redMultiplier = redMultiplier;
        this.greenMultiplier = greenMultiplier;
        this.blueMultiplier = blueMultiplier;
    }
}
