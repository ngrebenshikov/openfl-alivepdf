package org.alivepdf.fonts;

import haxe.ds.StringMap;
import org.alivepdf.fonts.IFont;

@:final class FontCollection
{
    public var name(get, never) : String;

    private var _name : String;
    private var styles : StringMap<Dynamic>;
    
    public function new(name : String)
    {
        _name = name;
        styles = new StringMap<Dynamic>();
    }
    
    public function add(style : String, font : IFont) : Void
    {
        styles.set(style, font);
    }
    
    public function getFont(style : String) : IFont
    {
        return styles.get(style);
    }
    
    public function hasStyle(style : String) : Bool
    {
        return styles.exists(style);
    }
    
    public function contains(fontName : String) : Bool
    {
        var found : Bool = false;
        for (f in styles)
        {
            if (f.name == fontName) 
            {
                found = true;
                break;
            }
        }
        return found;
    }
    
    private function get_name() : String
    {
        return _name;
    }
}
