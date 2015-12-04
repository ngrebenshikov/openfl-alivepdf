package org.alivepdf.fonts;


/**
	 * Describes a TrueType Font
	 * @author Thibault Imbert
	 * 
	 */
@:final class FontDescription
{
    public var fontWeight(get, never) : String;
    public var averageWidth(get, never) : Int;
    public var ascent(get, never) : Int;
    public var descent(get, never) : Int;
    public var capHeight(get, never) : Int;
    public var flags(get, never) : Int;
    public var boundingBox(get, never) : Array<Dynamic>;
    public var italicAngle(get, never) : Int;
    public var stemV(get, never) : Int;
    public var missingWidth(get, never) : Int;

    
    private var _ascent : Int = 0;
    private var _descent : Int = 0;
    private var _capHeight : Int = 0;
    private var _flags : Int = 0;
    private var _boundingBox : Array<Dynamic>;
    private var _italicAngle : Int = 0;
    private var _stemV : Int = 0;
    private var _missingWidth : Int = 0;
    private var _fontWeight : String;
    private var _averageWidth : Int = 0;
    
    public function new(fontWeight : String, averageWidth : Int, ascent : Int, descent : Int, capHeight : Int, flags : Int, fontBoundingBox : Array<Dynamic>, italicAngle : Int, stemV : Int, missingWidth : Int)
    {
        _fontWeight = fontWeight;
        _averageWidth = averageWidth;
        _ascent = ascent;
        _descent = descent;
        _capHeight = capHeight;
        _flags = flags;
        _boundingBox = fontBoundingBox;
        _italicAngle = italicAngle;
        _stemV = stemV;
        _missingWidth = missingWidth;
    }
    
    private function get_fontWeight() : String
    {
        return _fontWeight;
    }
    
    private function get_averageWidth() : Int
    {
        return _averageWidth;
    }
    
    private function get_ascent() : Int
    {
        return _ascent;
    }
    
    private function get_descent() : Int
    {
        return _descent;
    }
    
    private function get_capHeight() : Int
    {
        return _capHeight;
    }
    
    private function get_flags() : Int
    {
        return _flags;
    }
    
    private function get_boundingBox() : Array<Dynamic>
    {
        return _boundingBox;
    }
    
    private function get_italicAngle() : Int
    {
        return _italicAngle;
    }
    
    private function get_stemV() : Int
    {
        return _stemV;
    }
    
    private function get_missingWidth() : Int
    {
        return _missingWidth;
    }
    
    public function toString() : String
    {
        return "[FontDescription weight=" + fontWeight + " width=" + averageWidth + " ascent=" + ascent + " descent=" + descent + " capHeight=" + capHeight + " flags=" + flags + " boundingBox=" + boundingBox +
        " italicAngle=" + italicAngle + " stemV=" + stemV + " missingWidth=" + missingWidth + "]";
    }
}
