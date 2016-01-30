package org.alivepdf.images;

import org.alivepdf.images.PDFImage;

import flash.utils.ByteArray;

import org.alivepdf.decoding.Filter;

class JPEGImage extends PDFImage
{
    private var format : Int = 0;
    private var physicalWidthDpi : Int = 0;
    private var physicalHeightDpi : Int = 0;
    
    public static inline var FORMAT : Int = 0;
    public static inline var HEADER : Int = 0xFFD8;
    
    public function new(imageStream : ByteArray, colorSpace : String, id : Int)
    {
        super(imageStream, colorSpace, id);
        _filter = Filter.DCT_DECODE;
    }
    
    override private function parse() : Void
    {
        var data : ByteArray = new ByteArray();
        var marker : Int = 0;
        var size : Int = 0;
        var appID : ByteArray = new ByteArray();
        appID.writeByte(0x4A);
        appID.writeByte(0x46);
        appID.writeByte(0x49);
        appID.writeByte(0x46);
        appID.writeByte(0x00);
        var x : Int = 0;
        var y : Int = 0;
        
        while (true)
        {
            if (read(data, 0, 4) != 4) 
                return;
            
            marker = getShortBigEndian(data, 0);
            size = getShortBigEndian(data, 2);
            
            if ((marker & 0xFF00) != 0xFF00) 
                return;
            
            if (marker == 0xFFE0) 
            {
                if (size < 14)                     return;
                
                if (read(data, 0, 12) != 12) 
                    return;
                
                if (equals(appID, 0, data, 0, 5)) 
                {
                    if (data[7] == 1)
                    {
                        physicalWidthDpi = getShortBigEndian(data, 8);
                        physicalHeightDpi = getShortBigEndian(data, 10);
                        if ((data[12] & 0xFF) == 1)
                            colorSpace = ColorSpace.DEVICE_GRAY;
                    }
                    else if (data[7] == 2)
                    {
                        x = getShortBigEndian(data, 8);
                        y = getShortBigEndian(data, 10);
                        
                        if ((data[12] & 0xFF) == 1)
                            colorSpace = ColorSpace.DEVICE_GRAY;
                        
                        physicalWidthDpi = as3hx.Compat.parseInt(x * 2.54);
                        physicalHeightDpi = as3hx.Compat.parseInt(y * 2.54);
                    }
                }
                
                stream.position += size - 14;
            }
            else if (marker >= 0xFFC0 && marker <= 0xFFCF && marker != 0xFFC4 && marker != 0xFFC8) 
            {
                if (read(data, 0, 6) != 6) 
                    return;
                
                format = JPEGImage.FORMAT;
                bitsPerComponent = ((colorSpace != ColorSpace.DEVICE_RGB)) ? 8 : Std.int((data[0] & 0xFF) * (data[5] & 0xFF) / 3);
                progressive = marker == 0xFFC2 || marker == 0xFFC6 || marker == 0xFFCA || marker == 0xFFCE;
                
                _width = getShortBigEndian(data, 3);
                _height = getShortBigEndian(data, 1);
                
                if ((data[5] & 0xFF) == 1)
                    colorSpace = ColorSpace.DEVICE_GRAY;
            }
            else stream.position += size - 2;
        }
    }
    
    private function read(dest : ByteArray, offset : Int, num : Int) : Int
    {
        stream.readBytes(dest, offset, num);
        return num;
    }
    
    private static function equals(a1 : ByteArray, offs1 : Int, a2 : ByteArray, offs2 : Int, num : Int) : Bool
    {
        while (num-- > 0)
        if (a1[offs1++] != a2[offs2++])
            return false;
        return true;
    }
    
    private function getShortBigEndian(a : ByteArray, offs : Int) : Int
    {
        return Std.int((a[offs] & 0xFF) << 8 | (a[offs] + 1) & 0xFF);
    }
}
