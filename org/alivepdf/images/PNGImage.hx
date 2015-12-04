package org.alivepdf.images;

import flash.errors.Error;

import flash.utils.ByteArray;

import org.alivepdf.decoding.Filter;

class PNGImage extends PDFImage
{
    private var idataBytes : ByteArray;
    private var palBytes : ByteArray;
    private var type : Int = 0;
    
    public static inline var HEADER : Int = 0x8950;
    public static inline var PLTE : Int = 0x504C5445;
    public static inline var TRNS : Int = 0x74524E53;
    public static inline var IDAT : Int = 0x49444154;
    public static inline var IEND : Int = 0x49454E44;
    
    public static inline var IO : Int = 0;
    public static inline var I1 : Int = 1;
    public static inline var I2 : Int = 2;
    public static inline var I3 : Int = 3;
    public static inline var I4 : Int = 4;
    public static inline var I16 : Int = 16;
    
    public function new(imageStream : ByteArray, colorSpace : String, id : Int)
    {
        super(imageStream, colorSpace, id);
        _filter = Filter.FLATE_DECODE;
    }
    
    override private function parse() : Void
    {
        palBytes = new ByteArray();
        idataBytes = new ByteArray();
        
        stream.position = PNGImage.I16;
        
        _width = stream.readInt();
        _height = stream.readInt();
        
        bitsPerComponent = stream.readByte();
        
        ct = stream.readByte();
        
        if (ct == PNGImage.IO) 
            colorSpace = ColorSpace.DEVICE_GRAY
        else if (ct == PNGImage.I2) 
            colorSpace = ColorSpace.DEVICE_RGB
        else if (ct == PNGImage.I3) 
            colorSpace = ColorSpace.INDEXED
        else throw new Error("Alpha channel not supported for now");
        
        if (stream.readByte() != 0) 
            throw new Error("Unknown compression method");
        if (stream.readByte() != 0) 
            throw new Error("Unknown filter method");
        if (stream.readByte() != 0) 
            throw new Error("Interlacing not supported");
        
        stream.position += PNGImage.I4;
        
        _parameters = "/DecodeParms <</Predictor 15 /Colors " + (ct == (PNGImage.I2) ? PNGImage.I3 : PNGImage.I1) + " /BitsPerComponent " + bitsPerComponent + " /Columns " + width + ">>";
        
        var trns : String = "";
        
        do
        {
            n = stream.readInt();
            type = stream.readUnsignedInt();
            
            if (type == PNGImage.PLTE) 
            {
                var str : String = "";
                for (i in 0...n){
                    str += String.fromCharCode(stream.readUnsignedByte());
                }
                pal = str;
                
                stream.readUnsignedInt();
            }
            else if (type == PNGImage.TRNS) 
            {
                
                
                
            }
            else if (type == PNGImage.IDAT) 
            {
                stream.readBytes(idataBytes, idataBytes.length, n);
                stream.position += PNGImage.I4;
            }
            else if (type == PNGImage.IEND) 
            {
                break;
            }
            else stream.position += n + PNGImage.I4;
        }        while ((n > PNGImage.IO));
        
        if (colorSpace == ColorSpace.INDEXED && pal.length > 0)
            throw new Error("Missing palette in current picture");
    }
    
    override private function get_bytes() : ByteArray
    {
        return idataBytes;
    }
}
