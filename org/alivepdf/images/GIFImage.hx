package org.alivepdf.images;

import org.alivepdf.images.PDFImage;

import flash.utils.ByteArray;

@:final class GIFImage extends PDFImage
{
    public static inline var HEADER : String = "GIF";
    
    public function new(imageStream : ByteArray, id : Int)
    {
        super(imageStream, ColorSpace.DEVICE_RGB, id);
    }
}
