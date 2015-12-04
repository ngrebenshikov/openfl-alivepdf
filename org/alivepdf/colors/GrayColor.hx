package org.alivepdf.colors;

import org.alivepdf.colors.IColor;

@:final class GrayColor implements IColor
{
    public var gray : Float;
    
    public function new(gray : Float)
    {
        this.gray = gray;
    }
}
