/**
* This class lets you encode animated GIF files
* Base class :  http://www.java2s.com/Code/Java/2D-Graphics-GUI/AnimatedGifEncoder.htm
* @author Kevin Weiner (original Java version - kweiner(at)fmsware.com)
* @author Thibault Imbert (AS3 version - bytearray.org)
* @version 0.1 AS3 implementation
*/

package org.alivepdf.images.gif.encoder;

import flash.errors.Error;
import org.alivepdf.images.gif.encoder.LZWEncoder;

import flash.utils.ByteArray;
import flash.display.BitmapData;
import flash.display.Bitmap;
import org.alivepdf.images.gif.encoder.NeuQuant;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLRequest;
import flash.net.NavigateToURL;

class GIFEncoder
{
    public var stream(get, never) : ByteArray;

    
    private var width : Int = 0;  // image size
    private var height : Int = 0;
    private var transparent : Dynamic = null;  // transparent color if given  
    private var transIndex : Int = 0;  // transparent index in color table
    private var repeat : Int = -1;  // no repeat  
    private var delay : Int = 0;  // frame delay (hundredths)  
    private var started : Bool = false;  // ready to output frames  
    private var out : ByteArray;
    private var image : Bitmap;  // current frame  
    private var pixels : ByteArray;  // BGR byte array from frame  
    private var indexedPixels : ByteArray;  // converted frame indexed to palette  
    private var colorDepth : Int = 0;  // number of bit planes
    private var colorTab : ByteArray;  // RGB palette  
    private var usedEntry : Array<Dynamic> = new Array<Dynamic>();  // active palette entries  
    private var palSize : Int = 7;  // color table size (bits-1)  
    private var dispose : Int = -1;  // disposal code (-1 = use default)  
    private var closeStream : Bool = false;  // close stream when finished  
    private var firstFrame : Bool = true;
    private var sizeSet : Bool = false;  // if false, get size from first frame  
    private var sample : Int = 10;  // default sample interval for quantizer  
    
    /**
		* Sets the delay time between each frame, or changes it for subsequent frames
		* (applies to last frame added)
		* int delay time in milliseconds
		* @param ms
		*/
    
    public function setDelay(ms : Int) : Void
    {
        
        delay = Math.round(ms / 10);
    }
    
    /**
		* Sets the GIF frame disposal code for the last added frame and any
		* 
		* subsequent frames. Default is 0 if no transparent color has been set,
		* otherwise 2.
		* @param code
		* int disposal code.
		*/
    
    public function setDispose(code : Int) : Void
    {
        
        if (code >= 0)             dispose = code;
    }
    
    /**
		* Sets the number of times the set of GIF frames should be played. Default is
		* 1; 0 means play indefinitely. Must be invoked before the first image is
		* added.
		* 
		* @param iter
		* int number of iterations.
		* @return
		*/
    
    public function setRepeat(iter : Int) : Void
    {
        
        if (iter >= 0)             repeat = iter;
    }
    
    /**
		* Sets the transparent color for the last added frame and any subsequent
		* frames. Since all colors are subject to modification in the quantization
		* process, the color in the final palette for each frame closest to the given
		* color becomes the transparent color for that frame. May be set to null to
		* indicate no transparent color.
		* @param
		* Color to be treated as transparent on display.
		*/
    
    public function setTransparent(c : Float) : Void
    {
        
        transparent = c;
    }
    
    /**
		* The addFrame method takes an incoming BitmapData object to create each frames
		* @param
		* BitmapData object to be treated as a GIF's frame
		*/
    
    public function addFrame(im : BitmapData) : Bool
    {
        
        if ((im == null) || !started || out == null) 
        
        {
            throw new Error("Please call start method before calling addFrame");
            return false;
        }
        
        var ok : Bool = true;
        
        try{
            
            image = new Bitmap(im);
            if (!sizeSet)                 setSize(image.width, image.height);
            getImagePixels();  // convert to correct format if necessary  
            analyzePixels();  // build color table & map pixels  
            
            if (firstFrame) 
            {
                writeLSD();  // logical screen descriptior  
                writePalette();  // global color table  
                if (repeat >= 0) 
                {
                    // use NS app extension to indicate reps
                    writeNetscapeExt();
                }
            }
            
            writeGraphicCtrlExt();  // write graphic control extension  
            writeImageDesc();  // image descriptor  
            if (!firstFrame)                 writePalette()  // local color table  ;
            writePixels();  // encode and write pixel data  
            firstFrame = false;
        }        catch (e : Error){
            ok = false;
        }
        
        return ok;
    }
    
    /**
		* Adds final trailer to the GIF stream, if you don't call the finish method
		* the GIF stream will not be valid.
		*/
    
    public function finish() : Bool
    {
        if (!started)             return false;
        var ok : Bool = true;
        started = false;
        try{
            out.writeByte(0x3b);
        }        catch (e : Error){
            ok = false;
        }
        
        return ok;
    }
    
    /**
		* Resets some members so that a new stream can be started.
		* This method is actually called by the start method
		*/
    
    private function reset() : Void
    {
        
        // reset for subsequent use
        transIndex = 0;
        image = null;
        pixels = null;
        indexedPixels = null;
        colorTab = null;
        closeStream = false;
        firstFrame = true;
    }
    
    /**
		* * Sets frame rate in frames per second. Equivalent to
		* <code>setDelay(1000/fps)</code>.
		* @param fps
		* float frame rate (frames per second)         
		*/
    
    public function setFrameRate(fps : Float) : Void
    {
        
        if (fps != 0xf)             delay = Math.round(100 / fps);
    }
    
    /**
		* Sets quality of color quantization (conversion of images to the maximum 256
		* colors allowed by the GIF specification). Lower values (minimum = 1)
		* produce better colors, but slow processing significantly. 10 is the
		* default, and produces good color mapping at reasonable speeds. Values
		* greater than 20 do not yield significant improvements in speed.
		* @param quality
		* int greater than 0.
		* @return
		*/
    
    public function setQuality(quality : Int) : Void
    {
        
        if (quality < 1)             quality = 1;
        sample = quality;
    }
    
    /**
		* Sets the GIF frame size. The default size is the size of the first frame
		* added if this method is not invoked.
		* @param w
		* int frame width.
		* @param h
		* int frame width.
		*/
    
    private function setSize(w : Int, h : Int) : Void
    {
        
        if (started && !firstFrame)             return;
        width = w;
        height = h;
        if (width < 1)             width = 320;
        if (height < 1)             height = 240;
        sizeSet = true;
    }
    
    /**
		* Initiates GIF file creation on the given stream.
		* @param os
		* OutputStream on which GIF images are written.
		* @return false if initial write failed.
		* 
		*/
    
    public function start() : Bool
    {
        
        reset();
        var ok : Bool = true;
        closeStream = false;
        out = new ByteArray();
        try{
            out.writeUTFBytes("GIF89a");
        }        catch (e : Error){
            ok = false;
        }
        
        return started = ok;
    }
    
    /**
		* Analyzes image colors and creates color map.
		*/
    
    private function analyzePixels() : Void
    {
        
        var len : Int = pixels.length;
        var nPix : Int = len / 3;
        indexedPixels = new ByteArray();
        var nq : NeuQuant = new NeuQuant(pixels, len, sample);
        // initialize quantizer
        colorTab = nq.process();  // create reduced palette  
        // map image pixels to new palette
        var k : Int = 0;
        for (j in 0...nPix){
            var index : Int = nq.map(pixels[k++] & 0xff, pixels[k++] & 0xff, pixels[k++] & 0xff);
            usedEntry[index] = true;
            indexedPixels[j] = index;
        }
        pixels = null;
        colorDepth = 8;
        palSize = 7;
        // get closest match to transparent color if specified
        if (transparent != null) {
            transIndex = findClosest(transparent);
        }
    }
    
    /**
		* Returns index of palette color closest to c
		*
		*/
    
    private function findClosest(c : Float) : Int
    {
        
        if (colorTab == null)             return -1;
        var r : Int = (c & 0xFF0000) >> 16;
        var g : Int = (c & 0x00FF00) >> 8;
        var b : Int = (c & 0x0000FF);
        var minpos : Int = 0;
        var dmin : Int = 256 * 256 * 256;
        var len : Int = colorTab.length;
        
        var i : Int = 0;
        while (i < len){
            var dr : Int = r - (colorTab[i++] & 0xff);
            var dg : Int = g - (colorTab[i++] & 0xff);
            var db : Int = b - (colorTab[i] & 0xff);
            var d : Int = dr * dr + dg * dg + db * db;
            var index : Int = i / 3;
            if (usedEntry[index] && (d < dmin)) {
                dmin = d;
                minpos = index;
            }
            i++;
        }
        return minpos;
    }
    
    /**
		* Extracts image pixels into byte array "pixels
		*/
    
    private function getImagePixels() : Void
    {
        
        var w : Int = image.width;
        var h : Int = image.height;
        pixels = new ByteArray();
        
        var count : Int = 0;
        
        for (i in 0...h){
            
            for (j in 0...w){
                
                var pixel : Float = image.bitmapData.getPixel(j, i);
                
                pixels[count] = (pixel & 0xFF0000) >> 16;
                count++;
                pixels[count] = (pixel & 0x00FF00) >> 8;
                count++;
                pixels[count] = (pixel & 0x0000FF);
                count++;
            }
        }
    }
    
    /**
		* Writes Graphic Control Extension
		*/
    
    private function writeGraphicCtrlExt() : Void
    {
        
        out.writeByte(0x21);  // extension introducer  
        out.writeByte(0xf9);  // GCE label  
        out.writeByte(4);  // data block size  
        var transp : Int = 0;
        var disp : Int = 0;
        if (transparent == null) {
            transp = 0;
            disp = 0;
        }
        else {
            transp = 1;
            disp = 2;
        }
        if (dispose >= 0) {
            disp = dispose & 7;
        }
        disp <<= 2;
        // packed fields
        out.writeByte(0 |  // 1:3 reserved  
                disp |  // 4:6 disposal  
                0 |  // 7 user input - 0 = none  
                transp);  // 8 transparency flag  
        
        cast((delay), WriteShort);  // delay x 1/100 sec  
        out.writeByte(transIndex);  // transparent color index  
        out.writeByte(0);
    }
    
    /**
		* Writes Image Descriptor
		*/
    
    private function writeImageDesc() : Void
    {
        
        out.writeByte(0x2c);  // image separator  
        cast((0), WriteShort);  // image position x,y = 0,0  
        cast((0), WriteShort);
        cast((width), WriteShort);  // image size  
        cast((height), WriteShort);
        
        // packed fields
        if (firstFrame) {
            // no LCT - GCT is used for first (or only) frame
            out.writeByte(0);
        }
        else {
            // specify normal LCT
            out.writeByte(0x80 |  // 1 local color table 1=yes  
                    0 |  // 2 interlace - 0=no  
                    0 |  // 3 sorted - 0=no  
                    0 |  // 4-5 reserved  
                    palSize);
        }
    }
    
    /**
		* Writes Logical Screen Descriptor
		*/
    
    private function writeLSD() : Void
    {
        
        // logical screen size
        cast((width), WriteShort);
        cast((height), WriteShort);
        // packed fields
        out.writeByte((0x80 |  // 1 : global color table flag = 1 (gct used)  
                0x70 |  // 2-4 : color resolution = 7  
                0x00 |  // 5 : gct sort flag = 0  
                palSize));  // 6-8 : gct size  
        
        out.writeByte(0);  // background color index  
        out.writeByte(0);
    }
    
    /**
		* Writes Netscape application extension to define repeat count.
		*/
    
    private function writeNetscapeExt() : Void
    {
        
        out.writeByte(0x21);  // extension introducer  
        out.writeByte(0xff);  // app extension label  
        out.writeByte(11);  // block size  
        out.writeUTFBytes("NETSCAPE" + "2.0");  // app id + auth code  
        out.writeByte(3);  // sub-block size  
        out.writeByte(1);  // loop sub-block id  
        cast((repeat), WriteShort);  // loop count (extra iterations, 0=repeat forever)  
        out.writeByte(0);
    }
    
    /**
		* Writes color table
		*/
    
    private function writePalette() : Void
    {
        
        out.writeBytes(colorTab, 0, colorTab.length);
        var n : Int = (3 * 256) - colorTab.length;
        for (i in 0...n){out.writeByte(0);
        }
    }
    
    private function WriteShort(pValue : Int) : Void
    {
        
        out.writeByte(pValue & 0xFF);
        out.writeByte((pValue >> 8) & 0xFF);
    }
    
    /**
		* Encodes and writes pixel data
		*/
    
    private function writePixels() : Void
    {
        
        var myencoder : LZWEncoder = new LZWEncoder(width, height, indexedPixels, colorDepth);
        myencoder.encode(out);
    }
    
    /**
		* retrieves the GIF stream
		*/
    private function get_stream() : ByteArray
    {
        
        return out;
    }

    public function new()
    {
    }
}
