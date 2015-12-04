package org.alivepdf.events;


import flash.events.Event;

import org.alivepdf.pages.Page;

@:final class PageEvent extends Event
{
    public var page : Page;
    
    public static inline var ADDED : String = "added";
    
    public function new(type : String, page : Page)
    {
        super(type, false, false);
        this.page = page;
    }
    
    override public function clone() : Event
    {
        return new PageEvent(type, page);
    }
}
