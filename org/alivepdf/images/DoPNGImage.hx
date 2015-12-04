package org.alivepdf.images;

import org.alivepdf.images.PNGImage;

import flash.display.BitmapData;
import flash.utils.ByteArray;

@:final class DoPNGImage extends PNGImage
{
    private var bitmap : BitmapData;
    
    public function new(buffer : BitmapData, imageStream : ByteArray, id : Int)
    {
        bitmap = buffer;
        idataBytes = imageStream;
        super(imageStream, ColorSpace.DEVICE_RGB, id);
    }
    
    override private function parse() : Void
    {
        _width = bitmap.width;
        _height = bitmap.height;
        _parameters = "/DecodeParms <</Predictor 15 /Colors 3 /BitsPerComponent " + bitsPerComponent + " /Columns " + width + ">>";
    }
}
