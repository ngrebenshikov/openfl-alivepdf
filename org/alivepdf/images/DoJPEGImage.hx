package org.alivepdf.images;

import org.alivepdf.images.JPEGImage;

import flash.display.BitmapData;
import flash.utils.ByteArray;

@:final class DoJPEGImage extends JPEGImage
{
    private var bitmap : BitmapData;
    
    public function new(buffer : BitmapData, imageStream : ByteArray, id : Int)
    {
        bitmap = buffer;
        super(imageStream, ColorSpace.DEVICE_RGB, id);
    }
    
    override private function parse() : Void
    {
        _width = bitmap.width;
        _height = bitmap.height;
    }
}
