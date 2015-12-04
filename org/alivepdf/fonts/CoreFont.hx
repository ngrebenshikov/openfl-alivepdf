package org.alivepdf.fonts;

import haxe.ds.StringMap;
import org.alivepdf.fonts.FontMetrics;
import org.alivepdf.fonts.IFont;

import flash.events.Event;
import flash.events.EventDispatcher;

/**
	 * This class represents a core font.
	 * A "Core" font is not embedded in the PDF, its usage relies on the user system fonts.
	 * @author Thibault Imbert
	 * 
	 */
class CoreFont implements IFont
{
    public var charactersWidth(get, never) : Dynamic;
    public var name(get, set) : String;
    public var numGlyphs(get, never) : Int;
    public var type(get, never) : String;
    public var id(get, set) : Int;
    public var underlineThickness(get, never) : Int;
    public var underlinePosition(get, never) : Int;
    public var resourceId(get, set) : Int;

    private var _type : String;
    private var _name : String;
    private var _underlinePosition : Int = -100;
    private var _underlineThickness : Int = 50;
    private var _charactersWidth : StringMap<Int>;
    private var _numGlyphs : Int = 0;
    private var _resourceId : Int = 0;
    private var _id : Int = 0;
    private var dispatcher : EventDispatcher;
    
    public function new(name : String = "Helvetica")
    {
        dispatcher = new EventDispatcher();
        _name = name;
        _type = FontType.TYPE1;
        var metrics : FontMetrics = new FontMetrics();
        _charactersWidth = FontMetrics.lookUp(name);
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_charactersWidth() : StringMap<Int>
    {
        return _charactersWidth;
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
        
        _charactersWidth = FontMetrics.lookUp(name);
        return value;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_numGlyphs() : Int
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
    private function get_underlineThickness() : Int
    {
        return _underlineThickness;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_underlinePosition() : Int
    {
        return _underlinePosition;
    }
    
    /**
		 * 
		 * @return 
		 * 
		 */
    private function get_resourceId() : Int
    {
        return _resourceId;
    }
    
    /**
		 * 
		 * @param resourceId
		 * 
		 */
    private function set_resourceId(resourceId : Int) : Int
    {
        _resourceId = resourceId;
        return resourceId;
    }
    
    public function toString() : String
    {
        return "[CoreFont name=" + name + " type=Type1]";
    }
    
    //--
    //-- IEventDispatcher
    //--
    
    public function addEventListener(type : String, listener : Dynamic, useCapture : Bool = false, priority : Int = 0, useWeakReference : Bool = false) : Void
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
    
    public function removeEventListener(type : String, listener : Dynamic, useCapture : Bool = false) : Void
    {
        dispatcher.removeEventListener(type, listener, useCapture);
    }
    
    public function willTrigger(type : String) : Bool
    {
        return dispatcher.willTrigger(type);
    }
}
