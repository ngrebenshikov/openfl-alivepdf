package org.alivepdf.annotations;


class Annotation
{
    public var text(get, never) : String;
    public var width(get, never) : Int;
    public var height(get, never) : Int;
    public var y(get, never) : Int;
    public var x(get, never) : Int;
    public var type(get, never) : String;

    private var _type : String;
    private var _text : String;
    private var _x : Int = 0;
    private var _y : Int = 0;
    private var _width : Int = 0;
    private var _height : Int = 0;
    
    public function new(type : String, text : String, x : Int = 0, y : Int = 0, width : Int = 100, height : Int = 100)
    {
        _type = type;
        _text = text;
        _x = x;
        _y = y;
        _width = width;
        _height = height;
    }
    
    private function get_text() : String
    {
        return _text;
    }
    
    private function get_width() : Int
    {
        return _width;
    }
    
    private function get_height() : Int
    {
        return _height;
    }
    
    private function get_y() : Int
    {
        return _y;
    }
    
    private function get_x() : Int
    {
        return _x;
    }
    
    private function get_type() : String
    {
        return _type;
    }
}
