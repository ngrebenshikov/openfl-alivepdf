package org.alivepdf.images;


import flash.utils.ByteArray;
import flash.utils.Endian;

import org.alivepdf.decoding.Filter;

class TIFFImage extends PDFImage
{
    public function new(imageStream : ByteArray, colorSpace : String, id : Int)
    {
        super(imageStream, colorSpace, id);
    }
    
    override private function parse() : Void{
    }
}
