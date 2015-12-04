package org.alivepdf.images.gif.frames;


import flash.display.BitmapData;

class GIFFrame
{
    public var bitmapData : BitmapData;
    public var delay : Int = 0;
    
    public function new(pImage : BitmapData, pDelay : Int)
    {
        bitmapData = pImage;
        delay = pDelay;
    }
}
