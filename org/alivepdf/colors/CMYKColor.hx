package org.alivepdf.colors;

import org.alivepdf.colors.IColor;

@:final class CMYKColor implements IColor
{
    public var cyan : Float;
    public var magenta : Float;
    public var yellow : Float;
    public var black : Float;
    
    public function new(cyan : Float, magenta : Float, yellow : Float, black : Float)
    {
        this.cyan = cyan;
        this.magenta = magenta;
        this.yellow = yellow;
        this.black = black;
    }
}
