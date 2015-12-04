package org.alivepdf.fonts;

import EReg;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import flash.errors.Error;

import flash.events.EventDispatcher;
import flash.utils.ByteArray;


import org.alivepdf.events.CharacterEvent;

// This class is working but still beta and will be optimized (* types to be removed)
@:final class AFMParser extends EventDispatcher
{
    public var boundingBox(get, never) : Array<Dynamic>;
    public var weight(get, never) : String;
    public var underlinePosition(get, never) : Dynamic;
    public var underlineThickness(get, never) : Dynamic;
    public var stdVW(get, never) : Int;
    public var missingWidth(get, never) : Int;
    public var italicAngle(get, never) : Int;
    public var descender(get, never) : Int;
    public var capXHeight(get, never) : Int;
    public var capHeight(get, never) : Int;
    public var ascender(get, never) : Int;
    public var fontName(get, never) : String;
    public var widths(get, never) : Map<Dynamic, Dynamic>;
    public var stemV(get, never) : Int;
    public var differences(get, never) : String;
    public var type(get, never) : String;

    private static var fix : StringMap<String> = [
            "Edot" => "Edotaccent",
            "edot" => "edotaccent",
            "Idot" => "Idotaccent",
            "Zdot" => "Zdotaccent",
            "zdot" => "zdotaccent",
            "Odblacute" => "Ohungarumlaut",
            "odblacute" => "ohungarumlaut",
            "Udblacute" => "Uhungarumlaut",
            "udblacute" => "uhungarumlaut",
            "Gcedilla" => "Gcommaaccent",
            "gcedilla" => "gcommaaccent",
            "Kcedilla" => "Kcommaaccent",
            "kcedilla" => "kcommaaccent",
            "Lcedilla" => "Lcommaaccent",
            "lcedilla" => "lcommaaccent",
            "Ncedilla" => "Ncommaaccent",
            "ncedilla" => "ncommaaccent",
            "Rcedilla" => "Rcommaaccent",
            "rcedilla" => "rcommaaccent",
            "Scedilla" => "Scommaaccent",
            "scedilla" => "scommaaccent",
            "Tcedilla" => "Tcommaaccent",
            "tcedilla" => "tcommaaccent",
            "Dslash" => "Dcroat",
            "dslash" => "dcroat",
            "Dmacron" => "Dcroat",
            "dmacron" => "dcroat",
            "combininggraveaccent" => "gravecomb",
            "combininghookabove" => "hookabovecomb",
            "combiningtildeaccent" => "tildecomb",
            "combiningacuteaccent" => "acutecomb",
            "combiningdotbelow" => "dotbelowcomb",
            "dongsign" => "dong"

        ];
    
    private static inline var C : String = "C";
    private static inline var AC : String = "20AC";
    private static inline var EURO : String = "Euro";
    
    private static inline var TRUETYPE : Int = 0x10000;
    private static inline var TYPE1 : Int = 0x25;
    
    private var _widths : StringMap<Int>;
    private var _fontName : String;
    private var _ascender : Dynamic;
    private var _capHeight : Dynamic;
    private var _capXHeight : Dynamic;
    private var _descender : Dynamic;
    private var _isFixedPitch : Bool;
    private var _italicAngle : Int = 0;
    private var _missingWidth : Int = 0;
    private var _stdVW : Dynamic;
    private var _underlineThickness : Dynamic;
    private var _underlinePosition : Dynamic;
    private var _weight : String;
    private var _flags : Int = 0;
    private var _stemV : Dynamic;
    private var _boundingBox : Array<Dynamic>;
    private var _differences : String;
    private var _type : String;
    
    private var fm : StringMap<Int>  = new StringMap<Int> ();
    private var widthsBuffer : StringMap<Int> = new StringMap<Int>();
    
    public function new(stream : ByteArray, afm : ByteArray, encoding : ByteArray)
    {
        super();
        makeFont(stream, afm, encoding);
    }
    
    /**
		 * 
		 * @param enc
		 * @return 
		 * 
		 */
    private function readMap(enc : ByteArray) : IntMap<String>
    {
        enc.position = 0;
        var a : String = enc.readUTFBytes(enc.bytesAvailable);
        var cc2gn : IntMap<String> = new IntMap<String>();
        var tab : Array<String> = a.split("\n");
        
        for (item in tab)
        {
            if (item.charAt(0) == "!") 
            {
                var e : Array<String> = item.split(" ");
                var cc : Int = Std.parseInt("0x" + e[0].substr(1));
                var gn : String = e[2];
                cc2gn.set(cc, gn);
            }
        }
        
        for (i in 0...0x100){
            if (!cc2gn.exists(i))
                cc2gn.set(i, ".notdef");
        }
        return cc2gn;
    }
    
    
    private function readAFM(file : ByteArray, map : IntMap<Dynamic>) : StringMap<Int>
    {
        widthsBuffer = new StringMap<Int>();
        var a : String = file.readUTFBytes(file.bytesAvailable);
        var buffer : Array<Dynamic> = a.split("\n");
        
        for (item in buffer)
        {
            var e : Array<Dynamic> = item.split(" ");
            
            if (e.length < 2) 
                continue;
            
            var code : String = e[0];
            var param : String = e[1];
            
            if (code == AFMParser.C) 
            {
                var cc : Int = as3hx.Compat.parseInt(e[1]);
                var w : Int = e[4];
                var gn : String = e[7];
                
                if (gn.substr(-4) == AFMParser.AC) 
                    gn = AFMParser.EURO;
                
                if (AFMParser.fix.exists(gn))
                {
                    for (n in map.keys())
                    {
                        if (map.get(n) == AFMParser.fix.get(gn))
                            map.set(n, gn);
                    }
                }
                
                if (Lambda.array(map).length == 0)
                    widthsBuffer.set(String.fromCharCode(cc), w)
                else 
                {
                    widthsBuffer.set(gn, w);
                    if (gn == "X") 
                        _capXHeight = e[13];
                }
                if (gn == ".notdef") 
                    _missingWidth = w;
            }
            else if (code == "FontName") 
                _fontName = param
            else if (code == "Weight") 
                _weight = param
            else if (code == "ItalicAngle") 
                _italicAngle = as3hx.Compat.parseInt(param)
            else if (code == "Ascender") 
                _ascender = as3hx.Compat.parseInt(param)
            else if (code == "Descender") 
                _descender = as3hx.Compat.parseInt(param)
            else if (code == "UnderlineThickness") 
                _underlineThickness = as3hx.Compat.parseInt(param)
            else if (code == "UnderlinePosition") 
                _underlinePosition = as3hx.Compat.parseInt(param)
            else if (code == "IsFixedPitch") 
                _isFixedPitch = (param == "true")
            else if (code == "FontBBox") 
                _boundingBox =[e[1], e[2], e[3], e[4]]
            else if (code == "CapHeight") 
                _capHeight = as3hx.Compat.parseInt(param)
            else if (code == "StdVW") 
                _stdVW = as3hx.Compat.parseInt(param);
        }
        
        if (_fontName == null) 
            throw new Error("FontName not found");
        
        if (Lambda.array(map).length > 0)
        {
            if (!widthsBuffer.exists(".notdef"))
                widthsBuffer.set(".notdef", 600);
            if (!widthsBuffer.exists("Delta") && widthsBuffer.exists("increment"))
                widthsBuffer.set("Delta", widthsBuffer.get("increment"));
            
            for (i in 0...0x100){
                if (!widthsBuffer.exists(map.get(i)))
                    widthsBuffer.set(String.fromCharCode(i), widthsBuffer.get(".notdef"));
                else widthsBuffer.set(String.fromCharCode(i), widthsBuffer.get(map.get(i)));
            }
        }
        return widthsBuffer;
    }
    
    private function makeFontDescriptor(fm : Dynamic, symbolic : Bool) : Void
    {
        _ascender = _ascender != (null) ? _ascender : 1000;
        _descender = _descender != (null) ? _descender : -200;
        
        var ch : Int = 0;
        
        if (_capHeight != null){}
        else if (_capHeight == null && _capXHeight != null)
            _capHeight = _capXHeight
        else 
        _capHeight = _ascender;
        
        if (_isFixedPitch) 
            _flags += 1 << 0;
        if (symbolic) 
            _flags += 1 << 2;
        if (!symbolic) 
            _flags += 1 << 5;
        if (_italicAngle != 0 && _isFixedPitch)
            _flags += 1 << 6;
        
        if (_boundingBox == null) 
            _boundingBox = [0, _descender - 100, 1000, _ascender + 100];

        if (_stdVW != 0)
            _stemV = _stdVW
        else if (_weight != null && new EReg("bold|black", "i").match(_weight))
            _stemV = 120
        else 
        _stemV = 70;
    }
    
    private function makeWidthArray(buffer : StringMap<Int>) : StringMap<Int>
    {
        fm = new StringMap<Int>();
        for (i in 0...0x100){
            fm.set(String.fromCharCode(i), buffer.get(String.fromCharCode(i)));
        }
        return fm;
    }
    
    private function makeFontEncoding(map : IntMap<Dynamic>) : String
    {
        var ref : IntMap<Dynamic> = readMap(CodePage.CP1252);
        var s : String = "";
        var last : Int = 0;
        
        for (i in 32...0x100){
            if (map.get(i) != ref.get(i))
            {
                if (i != last + 1) 
                    s += i + " ";
                last = i;
                s += "/" + map.get(i) + " ";
            }
        }
        return s;
    }
    
    public function makeFont(fontfile : ByteArray, afmfile : ByteArray, enc : ByteArray) : Void
    {
        fontfile.position = 0;
        
//        var patch : Array<Dynamic> = new Array<Dynamic>();
//
        var map : IntMap<Dynamic> = readMap(enc);
        
//        for (p in Reflect.fields(patch))
//        map[p] = patch[p];
        
        var fm : StringMap<Int> = readAFM(afmfile, map);
        
        var differences : String;
        
        differences = makeFontEncoding(map);
        
        if (differences.length > 0)
            _differences = differences;
        
        makeFontDescriptor(fm, Lambda.count(map) == 0);
        
        if (fontfile != null) 
        {
            fontfile.position = 0;
            var header : Int = fontfile.readUnsignedInt();
            
            if (header == AFMParser.TRUETYPE) 
                _type = FontType.TRUE_TYPE
            else if ((fontfile.position = 0) == 0 && fontfile.readByte() == AFMParser.TYPE1)
                _type = FontType.TYPE1
            else 
            throw new Error("Error: unrecognized font file.");
        }
        else 
        {
            if (type != FontType.TRUE_TYPE && type != FontType.TYPE1) 
                throw new Error("<b>Error:</b> incorrect font type: " + type);
        }
        
        if (_underlinePosition == null) 
            _underlinePosition = -100;
        if (_underlineThickness == null) 
            _underlineThickness = 50;
        
        _widths = makeWidthArray(fm);
    }
    
    private function get_boundingBox() : Array<Dynamic>
    {
        return _boundingBox;
    }
    
    private function get_weight() : String
    {
        return _weight;
    }
    
    private function get_underlinePosition() : Dynamic
    {
        return _underlinePosition;
    }
    
    private function get_underlineThickness() : Dynamic
    {
        return _underlineThickness;
    }
    
    private function get_stdVW() : Int
    {
        return _stdVW;
    }
    
    private function get_missingWidth() : Int
    {
        return _missingWidth;
    }
    
    private function get_italicAngle() : Int
    {
        return _italicAngle;
    }
    
    private function get_descender() : Int
    {
        return _descender;
    }
    
    private function get_capXHeight() : Int
    {
        return _capXHeight;
    }
    
    private function get_capHeight() : Int
    {
        return _capHeight;
    }
    
    private function get_ascender() : Int
    {
        return _ascender;
    }
    
    private function get_fontName() : String
    {
        return _fontName;
    }
    
    private function get_widths() : Map<Dynamic, Dynamic>
    {
        return _widths;
    }
    
    private function get_stemV() : Int
    {
        return _stemV;
    }
    
    private function get_differences() : String
    {
        return _differences;
    }
    
    private function get_type() : String
    {
        return _type;
    }
}
