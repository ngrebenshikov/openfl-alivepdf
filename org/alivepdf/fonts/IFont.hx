package org.alivepdf.fonts;


import haxe.ds.StringMap;
import flash.events.IEventDispatcher;

interface IFont extends IEventDispatcher
{
    
    
    var name(get, set) : String;    
    
    var id(get, set) : Int;    
    var type(get, never) : String;    
    
    var resourceId(get, set) : Int;    
    var underlinePosition(get, never) : Int;    
    var underlineThickness(get, never) : Int;    
    var charactersWidth(get, never) : StringMap<Int>;
    var numGlyphs(get, never) : Int;

}
