package org.alivepdf.events;


import flash.events.Event;

class CharacterEvent extends Event
{
    public var missingCharacter(get, never) : String;
    public var fontName(get, never) : String;

    private var _missingCharacter : String;
    private var _fontName : String;
    
    public static inline var CHARACTER_MISSING : String = "missingCharacter";
    
    public function new(type : String, fontName : String, missingCharacter : String)
    {
        super(type, false, false);
        _fontName = fontName;
        _missingCharacter = missingCharacter;
    }
    
    private function get_missingCharacter() : String
    {
        return _missingCharacter;
    }
    
    private function get_fontName() : String
    {
        return _fontName;
    }
}
