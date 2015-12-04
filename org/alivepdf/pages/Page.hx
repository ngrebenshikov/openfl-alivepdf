package org.alivepdf.pages;

import flash.errors.RangeError;

import org.alivepdf.events.PagingEvent;
import org.alivepdf.layout.Orientation;
import org.alivepdf.layout.Size;
import org.alivepdf.layout.Unit;

class Page
{
    public var advanceTiming(get, set) : Int;
    public var orientation(get, never) : String;
    public var unit(get, never) : String;
    public var width(get, set) : Float;
    public var height(get, set) : Float;
    public var wPt(get, set) : Float;
    public var hPt(get, set) : Float;
    public var w(get, set) : Float;
    public var h(get, set) : Float;
    public var size(get, set) : Size;
    public var rotation(get, set) : Float;
    public var number(get, set) : Int;
    public var content(get, set) : String;
    public var transitions(get, set) : String;
    public var annotations(get, set) : String;

    private var _width : Float;
    private var _height : Float;
    private var _fwPt : Float;
    private var _fhPt : Float;
    private var _wPt : Float;
    private var _hPt : Float;
    private var _fw : Float;
    private var _fh : Float;
    private var _w : Float;
    private var _h : Float;
    private var _rotation : Float;
    private var _page : Int = 0;
    private var _pageTransition : String;
    private var _content : String;
    private var _annots : String;
    private var _orientation : String;
    private var _size : Size;
    private var _format : Array<Dynamic>;
    private var _k : Float;
    private var _unit : String;
    private var _advanceTiming : Int = 0;
    
    
    
    public function new(orientation : String, unit : String = "Mm", size : Size = null, rotation : Float = 0)
    {
        _orientation = orientation;
        _rotation = rotation;
        _unit = setUnit(unit);
        
        if (size == null) 
            size = Size.A4;
        
        _size = Size.getSize(size).clone();
        
        if (_size != null) 
            _format = _size.dimensions
        else throw new RangeError("Incorrect dimensions.");
        
        _fwPt = _format[0];
        _fhPt = _format[1];
        _fw = _fwPt / _k;
        _fh = _fhPt / _k;
        
        if (_orientation == Orientation.PORTRAIT) 
        {
            wPt = _fwPt;
            hPt = _fhPt;
            w = _fw;
            h = _fh;
            _width = wPt;
            _height = hPt;
        }
        else if (_orientation == Orientation.LANDSCAPE) 
        {
            wPt = _fhPt;
            hPt = _fwPt;
            w = _fh;
            h = _fw;
            _width = wPt;
            _height = hPt;
        }
        else throw new RangeError("Incorrect orientation: " + orientation);
        
        _annots = "";
        _content = "";
        transitions = "";
    }
    
    private function get_advanceTiming() : Int
    {
        return _advanceTiming;
    }
    
    private function set_advanceTiming(value : Int) : Int
    {
        _advanceTiming = value;
        return value;
    }
    
    /**
		 * 
		 * @return Page
		 * @example
		 * This example shows how to clone a page :
		 * <div class="listing">
		 * <pre>
		 *
		 * var clonedPage:Page = existingPage.clone();
		 * myPDF.addPage ( clonedPage );
		 * </pre>
		 * </div>
		 */
    public function clone() : Page
    {
        var page : Page = new Page(orientation, _unit, size, rotation);
        
        page.content = content;
        page.transitions = transitions;
        
        return page;
    }
    
    private function get_orientation() : String
    {
        return _orientation;
    }
    
    public function setUnit(unit : String) : String
    {
        if (unit == Unit.POINT) 
            _k = 1
        else if (unit == Unit.MM) 
            _k = 72 / 25.4
        else if (unit == Unit.CM) 
            _k = 72 / 2.54
        else if (unit == Unit.INCHES) 
            _k = 72
        else throw new RangeError("Incorrect unit: " + unit);
        
        return unit;
    }
    
    private function get_unit() : String
    {
        return _unit;
    }
    
    public function rotate(rotation : Int) : Void
    {
        if (rotation % 90 != 0)
            throw new RangeError("Rotation must be a multiple of 90");
        
        _rotation = rotation;
    }
    
    private function paging(evt : PagingEvent) : Void
    {
        _page = evt.page;
    }
    
    /**
		 * Lets you resize the Page dimensions
		 *  
		 * @param width
		 * @param height
		 * 
		 */
    public function resize(width : Float, height : Float, resolution : Float) : Void
    {
        this.width = _fwPt = wPt = width;
        this.height = _fhPt = hPt = height;
        
        w = wPt / resolution;
        h = hPt / resolution;
    }
    
    public function addTransition(style : String = "R", duration : Float = 1, dimension : String = "H", motionDirection : String = "I", transitionDirection : Int = 0) : Void
    {
        transitions = "/Trans << /Type /Trans /D " + duration + " /S /" + style + " /Dm /" + dimension + " /M /" + motionDirection + " /Di /" + transitionDirection + " >>";
    }
    
    public function setAdvanceTiming(timing : Int) : Void
    {
        advanceTiming = timing;
    }
    
    private function set_width(width : Float) : Float
    {
        _format[0] = _width = width;
        return width;
    }
    
    private function get_width() : Float
    {
        return _width;
    }
    
    private function set_height(height : Float) : Float
    {
        _format[1] = _height = height;
        return height;
    }
    
    private function get_height() : Float
    {
        return _height;
    }
    
    private function set_wPt(wPt : Float) : Float
    {
        _wPt = wPt;
        return wPt;
    }
    
    private function get_wPt() : Float
    {
        return _wPt;
    }
    
    private function set_hPt(hPt : Float) : Float
    {
        _hPt = hPt;
        return hPt;
    }
    
    private function get_hPt() : Float
    {
        return _hPt;
    }
    
    private function set_w(w : Float) : Float
    {
        _w = w;
        return w;
    }
    
    private function get_w() : Float
    {
        return _w;
    }
    
    private function set_h(h : Float) : Float
    {
        _h = h;
        return h;
    }
    
    private function get_h() : Float
    {
        return _h;
    }
    
    private function get_size() : Size
    {
        return _size;
    }
    
    private function set_size(size : Size) : Size
    {
        _size = size;
        return size;
    }
    
    private function set_rotation(rotation : Float) : Float
    {
        _rotation = rotation;
        return rotation;
    }
    
    private function get_rotation() : Float
    {
        return _rotation;
    }
    
    private function get_number() : Int
    {
        return _page;
    }
    
    private function set_number(num : Int) : Int
    {
        _page = num;
        return num;
    }
    
    private function set_content(content : String) : String
    {
        _content = content;
        return content;
    }
    
    private function get_content() : String
    {
        return _content;
    }
    
    private function get_transitions() : String
    {
        return _pageTransition;
    }
    
    private function set_transitions(transition : String) : String
    {
        _pageTransition = transition;
        return transition;
    }
    
    private function get_annotations() : String
    {
        return _annots;
    }
    
    private function set_annotations(annotation : String) : String
    {
        _annots = annotation;
        return annotation;
    }
    
    public function toString() : String
    {
        return "[Page orientation=" + _orientation + " number=" + _page + " width=" + Std.int(w) + " height=" + Std.int(h) + "]";
    }
}
