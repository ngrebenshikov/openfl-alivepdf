package org.alivepdf.fonts;

import flash.utils.CompressionAlgorithm;
import org.alivepdf.fonts.FontDescription;
import org.alivepdf.fonts.IFont;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.ByteArray;

import org.alivepdf.events.CharacterEvent;
import org.alivepdf.fonts.FontMetrics;
import org.alivepdf.fonts.FontType;

import haxe.ds.StringMap;


using pako.ByteArrayHelper;
/**
	 * This class represents an embedded font.
	 * An "Embedded" font is embedded in the PDF which results in a bigger PDF size.
	 * @author Thibault Imbert
	 * 
	 */
class EmbeddedFont extends CoreFont implements IFont
{
    public var encoding(get, never) : ByteArray;
    public var widths(get, never) : StringMap<Int>;
    public var weight(get, never) : String;
    public var originalSize(get, never) : Int;
    public var description(get, never) : FontDescription;
    public var differences(get, set) : String;
    public var differencesIndex: Int = 0;
    public var stream(get, never) : ByteArray;

    private var _differences : String;
    private var _stream : ByteArray;
    private var _description : FontDescription;
    private var _originalSize : Int = 0;
    private var _version : String;
    private var _weight : String;
    private var _widths : StringMap<Int>;
    private var _afmParser : AFMParser;
    private var _encoding : ByteArray;
    
    /**
		 * 
		 * @param stream The font stream - TrueType (.TTF) for now
		 * @param afm Adobe Font Metrics file (.AFM)
		 * @param codePage The character mapping table - Default CodePage.1252
		 * 
		 */
    public function new(stream : ByteArray, afm : ByteArray, codePage : ByteArray)
    {
        _afmParser = new AFMParser(stream, afm, codePage);
        _widths = _afmParser.widths;
        FontMetrics.add(_afmParser.fontName, _widths);
        super(_afmParser.fontName);
        _type = FontType.TRUE_TYPE;
        _encoding = codePage;
        _description = new FontDescription(_afmParser.weight, _afmParser.missingWidth, _afmParser.ascender, _afmParser.descender, _afmParser.capHeight, 32, _afmParser.boundingBox, 
                _afmParser.italicAngle, _afmParser.stemV, _afmParser.missingWidth);
        _underlinePosition = _afmParser.underlinePosition;
        _underlineThickness = _afmParser.underlineThickness;
        _weight = _afmParser.weight;
        _differences = _afmParser.differences;
        _originalSize = stream.length;
        _stream = stream.compressEx(CompressionAlgorithm.DEFLATE);
    }
    
    private function characterMissing(e : CharacterEvent) : Void
    {
        dispatchEvent(e);
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_encoding() : ByteArray
    {
        return _encoding;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_widths() : Dynamic
    {
        return _widths;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_weight() : String
    {
        return _weight;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_originalSize() : Int
    {
        return _originalSize;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_description() : FontDescription
    {
        return _description;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_differences() : String
    {
        return _differences;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function set_differences(differences : String) : String
    {
        _differences = differences;
        return differences;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_stream() : ByteArray
    {
        return _stream;
    }
    
    override public function toString() : String
    {
        return "[EmbeddedFont name=" + name + " weight=" + weight + " type=" + type + "]";
    }
}
