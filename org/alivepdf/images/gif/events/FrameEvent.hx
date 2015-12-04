/**
* This class lets you play animated GIF files in the flash player
* @author Thibault Imbert (bytearray.org)
*/

package org.alivepdf.images.gif.events;


import flash.events.Event;

import org.alivepdf.images.gif.frames.GIFFrame;

class FrameEvent extends Event
{
    public var frame : GIFFrame;
    public static inline var FRAME_RENDERED : String = "rendered";
    
    public function new(pType : String, pFrame : GIFFrame)
    {
        super(pType, false, false);
        
        frame = pFrame;
    }
    
    override public function clone() : Event
    {
        return new FrameEvent(type, frame);
    }
}
