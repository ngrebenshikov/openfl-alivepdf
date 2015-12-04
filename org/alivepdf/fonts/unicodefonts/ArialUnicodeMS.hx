package org.alivepdf.fonts.unicodefonts;

import org.alivepdf.fonts.unicodefonts.Arialunicid0Metrics;
import org.alivepdf.fonts.unicodefonts.Uni2cidAc15;
import org.alivepdf.fonts.unicodefonts.Uni2cidAg15;
import org.alivepdf.fonts.unicodefonts.Uni2cidAj16;
import org.alivepdf.fonts.unicodefonts.Uni2cidAk12;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import org.alivepdf.fonts.ICidFont;

class ArialUnicodeMS implements ICidFont
{
    public var charactersWidth(get, never) : StringMap<Int>;
    public var name(get, set) : String;
    public var numGlyphs(get, never) : Int;
    public var type(get, never) : String;
    public var id(get, set) : Int;
    public var underlineThickness(get, never) : Int;
    public var underlinePosition(get, never) : Int;
    public var resourceId(get, set) : Int;
    public var desc(get, never) : Dynamic;
    public var up(get, never) : Int;
    public var ut(get, never) : Int;
    public var dw(get, never) : Int;
    public var diff(get, never) : String;
    public var originalsize(get, never) : Int;
    public var enc(get, never) : String;
    public var cidinfo(get, never) : Dynamic;
    public var uni2cid(get, never) : Dynamic;

    //Metrics
    @:meta(Embed(source="arialunicid0_metrics",mimeType="application/octet-stream"))

    private static var arialunicid0Metrics : Class<Dynamic>;
    
    @:meta(Embed(source="uni2cid/uni2cid_ag15",mimeType="application/octet-stream"))

    private static var uni2cid_ag15 : Class<Dynamic>;
    
    @:meta(Embed(source="uni2cid/uni2cid_ac15",mimeType="application/octet-stream"))

    private static var uni2cid_ac15 : Class<Dynamic>;
    
    @:meta(Embed(source="uni2cid/uni2cid_aj16",mimeType="application/octet-stream"))

    private static var uni2cid_aj16 : Class<Dynamic>;
    
    @:meta(Embed(source="uni2cid/uni2cid_ak12",mimeType="application/octet-stream"))

    private static var uni2cid_ak12 : Class<Dynamic>;
    
    private static var _offset : Int = 31;
    
    private var _type : String = "cidfont0";
    private var _name : String = "ArialUnicodeMS";
    private var _underlinePosition : Int = -100;
    private var _underlineThickness : Int = 50;
    
    // 		For unicode font, the characterWidth table is not defined as 'char' -> Width but as 'charcode' -> Width
    private var _charactersWidth : Dynamic;
    private var _numGlyphs : Int = 0;
    private var _resourceId : Int = 0;
    private var _id : Int = 0;
    
    private var _desc : Dynamic = {
            Ascent : 1069,
            Descent : -271,
            CapHeight : 1069,
            Flags : 32,
            FontBBox : "[-1011 -330 2260 1078]",
            ItalicAngle : 0,
            StemV : 70,
            MissingWidth : 600,

        };
    
    private var _up : Int = -100;
    private var _ut : Int = 50;
    private var _dw : Int = 1000;
    
    private var _diff : String = "";
    private var _originalsize : Int = 23275812;
    
    private var _enc : String;
    private var _cidinfo : Dynamic;
    
    private var _uni2cid : Dynamic;
    private var dispatcher : EventDispatcher;
    
    /**
		 * Constructor
		 */
    public function new(cid : Int = CidInfo.CHINESE_SIMPLIFIED)
    {
        dispatcher = new EventDispatcher();
        initCID(cid);
        _charactersWidth = parseMetricsFile(Type.createInstance(arialunicid0Metrics, []));
    }
    
    private function initCID(cid : Int) : Void
    {
        switch (cid)
        {
            case CidInfo.CHINESE_TRADITIONAL:
                _enc = "UniCNS-UTF16-H";
                _cidinfo = {
                            Registry : "Adobe",
                            Ordering : "CNS1",
                            Supplement : 0,

                        };
                _uni2cid = parseMetricsFile(Type.createInstance(uni2cid_ac15, []));
            case CidInfo.CHINESE_SIMPLIFIED:
                _enc = "UniGB-UTF16-H";
                _cidinfo = {
                            Registry : "Adobe",
                            Ordering : "GB1",
                            Supplement : 2,

                        };
                _uni2cid = parseMetricsFile(Type.createInstance(uni2cid_ag15, []));
            case CidInfo.KOREAN:
                _enc = "UniKS-UTF16-H";
                _cidinfo = {
                            Registry : "Adobe",
                            Ordering : "Korea1",
                            Supplement : 0,

                        };
                _uni2cid = parseMetricsFile(Type.createInstance(uni2cid_ak12, []));
            case CidInfo.JAPANESE:
                _enc = "UniJIS-UTF16-H";
                _cidinfo = {
                            Registry : "Adobe",
                            Ordering : "Japan1",
                            Supplement : 5,

                        };
                _uni2cid = parseMetricsFile(Type.createInstance(uni2cid_aj16, []));
        }
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_characterswidth() : Dynamic
    {
        return _charactersWidth;
    }
    
    /**
		 * reaplace charactersWidth
		 *  @param value
		 * */
    public function replaceCharactersWidth(value : Dynamic) : Void
    {
        _charactersWidth = value;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_name() : String
    {
        return _name;
    }
    
    private function set_name(value : String) : String
    {
        _name = value;
        return value;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_numglyphs() : Int
    {
        return _numGlyphs;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_type() : String
    {
        return _type;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_id() : Int
    {
        return _id;
    }
    
    /**
		 * 
		 * @param id
		 * 
		 */
    private function set_id(id : Int) : Int
    {
        _id = id;
        return id;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_underlinethickness() : Int
    {
        return _underlineThickness;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_underlineposition() : Int
    {
        return _underlinePosition;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_resourceid() : Int
    {
        return _resourceId;
    }
    
    /**
		 * 
		 * @param resourceId
		 * 
		 */
    private function set_resourceid(resourceId : Int) : Int
    {
        _resourceId = resourceId;
        return resourceId;
    }
    
    public function toString() : String
    {
        return "[CidFont name=" + name + " type=" + type + "]";
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_desc() : Dynamic
    {
        return _desc;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_up() : Int
    {
        return _up;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_ut() : Int
    {
        return _ut;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_dw() : Int
    {
        return _dw;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_diff() : String
    {
        
        return _diff;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_originalsize() : Int
    {
        return _originalsize;
    }
    
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_enc() : String
    {
        return _enc;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_cidinfo() : Dynamic
    {
        return _cidinfo;
    }
    
    private function get_uni2cid() : Dynamic
    {
        return _uni2cid;
    }
    
    /**
		 * 
		 * @Parse Metric File 
		 * 
		 * 
		 */
    private function parseMetricsFile(metricFile : ByteArray) : Dynamic
    {
        var ret : Dynamic = new Dynamic();
        var content : String = metricFile.readUTFBytes(metricFile.length);
        var sourceCodes : Array<Dynamic> = content.split(",");
        var arr : Array<Dynamic>;
        var lng : Int = sourceCodes.length;
        
        for (i in 0...lng){
            
            arr = (try cast(sourceCodes[i], String) catch(e:Dynamic) null).replace("\r\n", "").split("=>");
            Reflect.setField(ret, Std.string(arr[0]), arr[1]);
        }
        return ret;
    }
    
    //--
    //-- IEventDispatcher
    //--
    
    public function addEventListener(type : String, listener : Function, useCapture : Bool = false, priority : Int = 0, useWeakReference : Bool = false) : Void
    {
        dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    
    public function dispatchEvent(event : Event) : Bool
    {
        return dispatcher.dispatchEvent(event);
    }
    
    public function hasEventListener(type : String) : Bool
    {
        return dispatcher.hasEventListener(type);
    }
    
    public function removeEventListener(type : String, listener : Function, useCapture : Bool = false) : Void
    {
        dispatcher.removeEventListener(type, listener, useCapture);
    }
    
    public function willTrigger(type : String) : Bool
    {
        return dispatcher.willTrigger(type);
    }
}

