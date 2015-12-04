package org.alivepdf.layout;


@:final class Resize
{
    public var mode : String;
    public var position : String;
    
    public function new(mode : String, position : String)
    {
        this.mode = mode;
        this.position = position;
    }
    
    public function toString() : String
    {
        return "[Resize mode=" + mode + " position=" + position + "]";
    }
}
