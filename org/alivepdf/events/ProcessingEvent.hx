package org.alivepdf.events;


import flash.events.Event;

@:final class ProcessingEvent extends Event
{
    public var duration : Float;
    
    public static inline var COMPLETE : String = "complete";
    public static inline var PAGE_TREE : String = "pageTree";
    public static inline var RESOURCES : String = "resources";
    public static inline var STARTED : String = "started";
    
    public function new(type : String, duration : Float = 0)
    {
        super(type, false, false);
        this.duration = duration;
    }
    
    override public function clone() : Event
    {
        return new ProcessingEvent(type, duration);
    }
}
