package org.alivepdf.annotations;


class TextAnnotation extends Annotation
{
    public var open(get, set) : Bool;

    private var _open : Bool;
    
    public function new(type : String, text : String = "A text note!", x : Int = 0, y : Int = 0, width : Int = 100, height : Int = 100, open : Bool = false)
    {
        super(type, text, x, y, width, height);
        _open = open;
    }
    
    private function get_open() : Bool
    {
        return _open;
    }
    
    private function set_open(value : Bool) : Bool
    {
        _open = value;
        return value;
    }
}
