package org.alivepdf.events;


import flash.events.Event;

@:final class PagingEvent extends Event
{
    public var page : Int = 0;
    
    public static inline var ADDED : String = "paging";
    
    public function new(type : String, page : Int)
    {
        super(type, false, false);
        this.page = page;
    }
    
    override public function clone() : Event
    {
        return new PagingEvent(type, page);
    }
}
