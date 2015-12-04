/**
* This class lets you play animated GIF files in the flash player
* @author Thibault Imbert (bytearray.org)
*/

package org.alivepdf.images.gif.events;


import flash.events.Event;
import flash.geom.Rectangle;

class GIFPlayerEvent extends Event
{
    public var rect : Rectangle;
    public static inline var COMPLETE : String = "complete";
    
    public function new(pType : String, pRect : Rectangle)
    {
        super(pType, false, false);
        
        rect = pRect;
    }
    
    override public function clone() : Event
    {
        return new GIFPlayerEvent(type, rect);
    }
}
