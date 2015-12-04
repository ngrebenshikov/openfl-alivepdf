package org.alivepdf.images;


import flash.utils.ByteArray;

class PDFImage implements IImage
{
    public var masked(get, never) : Bool;
    public var transparency(get, never) : String;
    public var resourceId(get, set) : Int;
    public var parameters(get, never) : String;
    public var pal(get, set) : String;
    public var n(get, set) : Int;
    public var filter(get, never) : String;
    public var colorSpace(get, set) : String;
    public var bitsPerComponent(get, set) : Int;
    public var height(get, never) : Int;
    public var width(get, never) : Int;
    public var bytes(get, never) : ByteArray;

    private var _width : Int = 0;
    private var _height : Int = 0;
    private var _resourceId : Int = 0;
    private var _n : Int = 0;
    private var _colorSpace : String;
    private var _bitsPerComponent : Int = 8;
    private var _filter : String;
    private var _transparency : String;
    private var _parameters : String;
    private var _pal : String;
    private var _masked : Bool;
    private var ct : Float;
    private var progressive : Bool;
    private var stream : ByteArray;
    
    public function new(imageStream : ByteArray, colorSpace : String, id : Int)
    {
        stream = imageStream;
        _colorSpace = colorSpace;
        resourceId = id;
        parse();
    }
    
    private function get_masked() : Bool
    {
        return _masked;
    }
    
    private function get_transparency() : String
    {
        return _transparency;
    }
    
    private function get_resourceId() : Int
    {
        return _resourceId;
    }
    
    private function set_resourceId(value : Int) : Int
    {
        _resourceId = value;
        return value;
    }
    
    private function get_parameters() : String
    {
        return _parameters;
    }
    
    private function set_pal(value : String) : String
    {
        _pal = value;
        return value;
    }
    
    private function get_pal() : String
    {
        return _pal;
    }
    
    private function set_n(value : Int) : Int
    {
        _n = value;
        return value;
    }
    
    private function get_n() : Int
    {
        return _n;
    }
    
    private function get_filter() : String
    {
        return _filter;
    }
    
    private function set_colorSpace(value : String) : String
    {
        _colorSpace = value;
        return value;
    }
    
    private function get_colorSpace() : String
    {
        return _colorSpace;
    }
    
    private function set_bitsPerComponent(value : Int) : Int
    {
        _bitsPerComponent = value;
        return value;
    }
    
    private function get_bitsPerComponent() : Int
    {
        return _bitsPerComponent;
    }
    
    private function get_height() : Int
    {
        return _height;
    }
    
    private function get_width() : Int
    {
        return _width;
    }
    
    private function parse() : Void{
    }
    
    private function get_bytes() : ByteArray
    {
        return stream;
    }
}
