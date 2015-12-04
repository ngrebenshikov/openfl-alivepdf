package org.alivepdf.images.gif.events;


import flash.events.Event;

class TimeoutEvent extends Event
{
    public static inline var TIME_OUT : String = "timeout";
    
    public function new(pType : String)
    {
        super(pType, false, false);
    }
    
    override public function clone() : Event
    {
        return new TimeoutEvent(type);
    }
}
