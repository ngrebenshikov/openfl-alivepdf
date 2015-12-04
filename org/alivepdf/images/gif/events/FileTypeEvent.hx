package org.alivepdf.images.gif.events;


import flash.events.Event;

class FileTypeEvent extends Event
{
    public static inline var INVALID : String = "invalid";
    
    public function new(pType : String)
    {
        super(pType, false, false);
    }
    
    override public function clone() : Event
    {
        return new FileTypeEvent(type);
    }
}
