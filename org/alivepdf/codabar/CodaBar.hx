package org.alivepdf.codabar;


import haxe.ds.StringMap;

class CodaBar
{
    public var barChar(get, set) : StringMap<Dynamic>;
    public var height(get, set) : Float;
    public var baseWidth(get, set) : Float;
    public var end(get, set) : String;
    public var start(get, set) : String;
    public var code(get, set) : String;
    public var y(get, set) : Float;
    public var x(get, set) : Float;

    private var _barChar : StringMap<Dynamic> = new StringMap<Dynamic>();
    private var _x : Float;
    private var _y : Float;
    private var _code : String;
    private var _start : String;
    private var _end : String;
    private var _baseWidth : Float;
    private var _height : Float;
    
    public function new(x : Int, y : Int, code : String, start : String = "A", end : String = "A", baseWidth : Float = 0.35, height : Float = 16)
    {
        _x = x;
        _y = y;
        _code = code;
        _start = start;
        _end = end;
        _baseWidth = baseWidth;
        _height = height;
        
        barChar.set("0", [6.5, 10.4, 6.5, 10.4, 6.5, 24.3, 17.9]);
        barChar.set("1", [6.5, 10.4, 6.5, 10.4, 17.9, 24.3, 6.5]);
        barChar.set("2", [6.5, 10.0, 6.5, 24.4, 6.5, 10.0, 18.6]);
        barChar.set("3", [17.9, 24.3, 6.5, 10.4, 6.5, 10.4, 6.5]);
        barChar.set("4", [6.5, 10.4, 17.9, 10.4, 6.5, 24.3, 6.5]);
        barChar.set("5", [17.9, 10.4, 6.5, 10.4, 6.5, 24.3, 6.5]);
        barChar.set("6", [6.5, 24.3, 6.5, 10.4, 6.5, 10.4, 17.9]);
        barChar.set("7", [6.5, 24.3, 6.5, 10.4, 17.9, 10.4, 6.5]);
        barChar.set("8", [6.5, 24.3, 17.9, 10.4, 6.5, 10.4, 6.5]);
        barChar.set("9", [18.6, 10.0, 6.5, 24.4, 6.5, 10.0, 6.5]);
        barChar.set("$", [6.5, 10.0, 18.6, 24.4, 6.5, 10.0, 6.5]);
        barChar.set("-", [6.5, 10.0, 6.5, 24.4, 18.6, 10.0, 6.5]);
        barChar.set(":", [16.7, 9.3, 6.5, 9.3, 16.7, 9.3, 14.7]);
        barChar.set("/", [14.7, 9.3, 16.7, 9.3, 6.5, 9.3, 16.7]);
        barChar.set(".", [13.6, 10.1, 14.9, 10.1, 17.2, 10.1, 6.5]);
        barChar.set("+", [6.5, 10.1, 17.2, 10.1, 14.9, 10.1, 13.6]);
        barChar.set("A", [6.5, 8.0, 19.6, 19.4, 6.5, 16.1, 6.5]);
        barChar.set("T", [6.5, 8.0, 19.6, 19.4, 6.5, 16.1, 6.5]);
        barChar.set("B", [6.5, 16.1, 6.5, 19.4, 6.5, 8.0, 19.6]);
        barChar.set("N", [6.5, 16.1, 6.5, 19.4, 6.5, 8.0, 19.6]);
        barChar.set("C", [6.5, 8.0, 6.5, 19.4, 6.5, 16.1, 19.6]);
        barChar.set("*", [6.5, 8.0, 6.5, 19.4, 6.5, 16.1, 19.6]);
        barChar.set("D", [6.5, 8.0, 6.5, 19.4, 19.6, 16.1, 6.5]);
        barChar.set("E", [6.5, 8.0, 6.5, 19.4, 19.6, 16.1, 6.5]);
    }
    
    private function get_barChar() : StringMap<Dynamic>
    {
        return _barChar;
    }
    
    private function set_barChar(value : StringMap<Dynamic>) : StringMap<Dynamic>
    {
        _barChar = value;
        return value;
    }
    
    private function get_height() : Float
    {
        return _height;
    }
    
    private function set_height(value : Float) : Float
    {
        _height = value;
        return value;
    }
    
    private function get_baseWidth() : Float
    {
        return _baseWidth;
    }
    
    private function set_baseWidth(value : Float) : Float
    {
        _baseWidth = value;
        return value;
    }
    
    private function get_end() : String
    {
        return _end;
    }
    
    private function set_end(value : String) : String
    {
        _end = value;
        return value;
    }
    
    private function get_start() : String
    {
        return _start;
    }
    
    private function set_start(value : String) : String
    {
        _start = value;
        return value;
    }
    
    private function get_code() : String
    {
        return _code;
    }
    
    private function set_code(value : String) : String
    {
        _code = value;
        return value;
    }
    
    private function get_y() : Float
    {
        return _y;
    }
    
    private function set_y(value : Float) : Float
    {
        _y = value;
        return value;
    }
    
    private function get_x() : Float
    {
        return _x;
    }
    
    private function set_x(value : Float) : Float
    {
        _x = value;
        return value;
    }
}
