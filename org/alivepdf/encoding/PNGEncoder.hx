/**
* PNG encoding class from kaourantin.net, optimised by 5etdemi.com/blog
* AlivePDF modification : encode() method has been modified to return only the needed IDAT chunk for AlivePDF.
* @author kaourantin
* @version 0.1
*/

package org.alivepdf.encoding;


import flash.utils.CompressionAlgorithm;
import flash.geom.Point;
import flash.display.PNGEncoderOptions;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

using pako.ByteArrayHelper;

@:final class PNGEncoder
{
    
    /**
		 * Allows you to encode a BitmapData to a PNG stream for AlivePDF. 
		 * @param image The BitmapData to encode
		 * @param transparent Specify if the PNG is transparent or not. The value of this parameter is false by default.
		 * @return 
		 * 
		 */
    public static function encode(image : BitmapData, transparent : Bool = false) : ByteArray
    {
        // Build IDAT chunk
        var IDAT : ByteArray = new ByteArray();

        if (transparent)
            writeRaw(image, IDAT)
        else writeSub(image, IDAT);

        return IDAT.compressEx(CompressionAlgorithm.DEFLATE);
    }
    
    private static function writeRaw(img : BitmapData, IDAT : ByteArray) : Void
    {
        var h : Int = img.height;
        var w : Int = img.width;
        var transparent : Bool = img.transparent;
        var subImage : ByteArray;
        var rectangle : Rectangle = new Rectangle(0, 0, w, 1);
        
        for (i in 0...h){
            // no filter
            if (!transparent) 
            {
                rectangle.y = i;
                subImage = img.getPixels(rectangle);
                //Here we overwrite the alpha value of the first pixel
                //to be the filter 0 flag
                subImage.__set(0, 0);
                IDAT.writeBytes(subImage);
                //And we add a byte at the end to wrap the alpha values
                IDAT.writeByte(0xff);
            }
            else 
            {
                IDAT.writeByte(0);
                var p : Int = 0;
                for (j in 0...w){
                    p = img.getPixel32(j, i);
                    IDAT.writeUnsignedInt(Std.int(((p & 0xFFFFFF) << 8) | (p >>> 24)));
                }
            }
        }
    }
    
    private static function writeSub(image : BitmapData, IDAT : ByteArray) : Void
    {
        var r1 : Int = 0;
        var g1 : Int = 0;
        var b1 : Int = 0;
        var a1 : Int = 0;
        
        var r2 : Int = 0;
        var g2 : Int = 0;
        var b2 : Int = 0;
        var a2 : Int = 0;
        
        var r3 : Int = 0;
        var g3 : Int = 0;
        var b3 : Int = 0;
        var a3 : Int = 0;
        
        var p : Int = 0;
        var h : Int = image.height;
        var w : Int = image.width;
        
        for (i in 0...h){
            // no filter
            IDAT.writeByte(1);
            
            if (!image.transparent) 
            {
                r1 = 0;
                g1 = 0;
                b1 = 0;
                a1 = 0xff;
                
                for (j in 0...w){
                    p = image.getPixel(j, i);
                    
                    r2 = p >> 16 & 0xff;
                    g2 = p >> 8 & 0xff;
                    b2 = p & 0xff;
                    
                    r3 = (r2 - r1 + 256) & 0xff;
                    g3 = (g2 - g1 + 256) & 0xff;
                    b3 = (b2 - b1 + 256) & 0xff;
                    
                    IDAT.writeByte(r3);
                    IDAT.writeByte(g3);
                    IDAT.writeByte(b3);
                    
                    r1 = r2;
                    g1 = g2;
                    b1 = b2;
                    a1 = 0;
                }
            }
            else 
            {
                r1 = 0;
                g1 = 0;
                b1 = 0;
                a1 = 0;
                
                for (k in 0...w){
                    p = image.getPixel32(k, i);
                    
                    a2 = p >> 24 & 0xff;
                    r2 = p >> 16 & 0xff;
                    g2 = p >> 8 & 0xff;
                    b2 = p & 0xff;
                    
                    r3 = (r2 - r1 + 256) & 0xff;
                    g3 = (g2 - g1 + 256) & 0xff;
                    b3 = (b2 - b1 + 256) & 0xff;
                    a3 = (a2 - a1 + 256) & 0xff;
                    
                    IDAT.writeByte(r3);
                    IDAT.writeByte(g3);
                    IDAT.writeByte(b3);
                    IDAT.writeByte(a3);
                    
                    r1 = r2;
                    g1 = g2;
                    b1 = b2;
                    a1 = a2;
                }
            }
        }
    }

    public function new()
    {
    }
}
