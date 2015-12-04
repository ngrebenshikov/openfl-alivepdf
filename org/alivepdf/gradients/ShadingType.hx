package org.alivepdf.gradients;


import flash.utils.ByteArray;

class ShadingType
{
    public var stream(get, set) : ByteArray;
    public var id(get, set) : Int;
    public var col2(get, never) : String;
    public var col1(get, never) : String;
    public var coords(get, never) : Array<Dynamic>;
    public var type(get, never) : Int;

    public static inline var TYPE1 : Int = 1;
    public static inline var TYPE2 : Int = 2;
    public static inline var TYPE3 : Int = 3;
    public static inline var TYPE6 : Int = 6;
    
    private var _id : Int = 0;
    private var _type : Int = 0;
    private var _coords : Array<Dynamic>;
    private var _stream : ByteArray;
    private var _col1 : String;
    private var _col2 : String;
    
    public function new(type : Int, coords : Array<Dynamic>, col1 : String, col2 : String)
    {
        _type = type;
        _coords = coords;
        _col1 = col1;
        _col2 = col2;
    }
    
    private function get_stream() : ByteArray
    {
        return _stream;
    }
    
    private function set_stream(value : ByteArray) : ByteArray
    {
        _stream = value;
        return value;
    }
    
    private function get_id() : Int
    {
        return _id;
    }
    
    private function set_id(value : Int) : Int
    {
        _id = value;
        return value;
    }
    
    private function get_col2() : String
    {
        return _col2;
    }
    
    private function get_col1() : String
    {
        return _col1;
    }
    
    private function get_coords() : Array<Dynamic>
    {
        return _coords;
    }
    
    private function get_type() : Int
    {
        return _type;
    }
}
