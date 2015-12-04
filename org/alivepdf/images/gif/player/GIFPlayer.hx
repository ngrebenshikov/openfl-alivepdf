/**
* This class lets you play animated GIF files in AS3
* @author Thibault Imbert (bytearray.org)
* @version 0.4
*/

package org.alivepdf.images.gif.player;

import flash.errors.Error;
import flash.errors.RangeError;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Timer;

import org.alivepdf.images.gif.decoder.GIFDecoder;
import org.alivepdf.images.gif.errors.FileTypeError;
import org.alivepdf.images.gif.events.FileTypeEvent;
import org.alivepdf.images.gif.events.FrameEvent;
import org.alivepdf.images.gif.events.GIFPlayerEvent;
import org.alivepdf.images.gif.events.TimeoutEvent;
import org.alivepdf.images.gif.frames.GIFFrame;

class GIFPlayer extends Bitmap
{
    public var currentFrame(get, never) : Int;
    public var totalFrames(get, never) : Int;
    public var loopCount(get, never) : Int;
    public var autoPlay(get, never) : Bool;
    public var frames(get, never) : Array<Dynamic>;

    private var urlLoader : URLLoader;
    private var gifDecoder : GIFDecoder;
    private var aFrames : Array<Dynamic>;
    private var myTimer : Timer;
    private var iInc : Int = 0;
    private var iIndex : Int = 0;
    private var auto : Bool;
    private var arrayLng : Int = 0;
    
    public var preWidth : Float;
    public var preHeight : Float;
    
    public function new(pAutoPlay : Bool = true)
    {
        super();
        auto = pAutoPlay;
        iIndex = iInc = 0;
        
        myTimer = new Timer(0, 0);
        aFrames = new Array<Dynamic>();
        urlLoader = new URLLoader();
        urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
        
        urlLoader.addEventListener(Event.COMPLETE, onComplete);
        urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        
        myTimer.addEventListener(TimerEvent.TIMER, update);
        
        gifDecoder = new GIFDecoder();
    }
    
    private function onIOError(pEvt : IOErrorEvent) : Void
    {
        dispatchEvent(pEvt);
    }
    
    private function onComplete(pEvt : Event) : Void
    {
        readStream(pEvt.target.data);
    }
    
    private function readStream(pBytes : ByteArray) : BitmapData
    {
        var gifStream : ByteArray = pBytes;
        
        aFrames = new Array<Dynamic>();
        iInc = 0;
        
        try {
            gifDecoder.read(gifStream);
            
            var lng : Int = gifDecoder.getFrameCount();
            
            for (i in 0...lng){aFrames[as3hx.Compat.parseInt(i)] = gifDecoder.getFrame(i);
            }
            
            arrayLng = aFrames.length;
            
            (auto) ? play() : gotoAndStop(1);
            
            dispatchEvent(new GIFPlayerEvent(GIFPlayerEvent.COMPLETE, aFrames[0].bitmapData.rect));
        } catch (e : FileTypeError) {
            dispatchEvent(new FileTypeEvent(FileTypeEvent.INVALID));
        } catch (e : Dynamic) {
            throw new Error("An unknown error occured, make sure the GIF file contains at least one frame\nNumber of frames : " + aFrames.length);
        }
        
        return aFrames[0].bitmapData;
    }
    
    private function update(pEvt : TimerEvent) : Void
    {
        var delay : Int = aFrames[iIndex = iInc++ % arrayLng].delay;
        
        pEvt.target.delay = ((delay > 0)) ? delay : 100;
        
        var _sw0_ = (gifDecoder.disposeValue);        

        switch (_sw0_)
        {
            
            case 1:
                if (iIndex == 0)                     bitmapData = aFrames[0].bitmapData.clone();
                bitmapData.draw(aFrames[iIndex].bitmapData);
            case 2:
                bitmapData = aFrames[iIndex].bitmapData;
        }
        
        dispatchEvent(new FrameEvent(FrameEvent.FRAME_RENDERED, aFrames[iIndex]));
    }
    
    private function concat(pIndex : Int) : Int
    {
        bitmapData.lock();
        for (i in 0...pIndex){
            bitmapData.draw(aFrames[i].bitmapData);
        }
        bitmapData.unlock();
        
        return pIndex;
    }
    
    /**
		 * Load any GIF file
		 *
		 * @return void
		*/
    public function load(pRequest : URLRequest) : Void
    {
        stop();
        
        urlLoader.load(pRequest);
    }
    
    /**
		 * Load any valid GIF ByteArray
		 *
		 * @return void
		*/
    public function loadBytes(pBytes : ByteArray) : BitmapData
    {
        return readStream(pBytes);
    }
    
    /**
		 * Start playing
		 *
		 * @return void
		*/
    public function play() : Void
    {
        if (aFrames.length > 0)
        {
            
            if (!myTimer.running)                 myTimer.start();
        }
        else throw new Error("Nothing to play");
    }
    
    /**
		 * Stop playing
		 *
		 * @return void
		*/
    public function stop() : Void
    {
        if (myTimer.running)             myTimer.stop();
    }
    
    /**
		 * Returns current frame being played
		 *
		 * @return frame number
		*/
    private function get_currentFrame() : Int
    {
        return iIndex + 1;
    }
    
    /**
		 * Returns GIF's total frames
		 *
		 * @return number of frames
		*/
    private function get_totalFrames() : Int
    {
        return aFrames.length;
    }
    
    /**
		 * Returns how many times the GIF file is played
		 * A loop value of 0 means repeat indefinitiely.
		 *
		 * @return loop value
		*/
    private function get_loopCount() : Int
    {
        return gifDecoder.getLoopCount();
    }
    
    /**
		 * Returns is the autoPlay value
		 *
		 * @return autoPlay value
		*/
    private function get_autoPlay() : Bool
    {
        return auto;
    }
    
    /**
		 * Returns an array of GIFFrame objects
		 *
		 * @return aFrames
		*/
    private function get_frames() : Array<Dynamic>
    {
        return aFrames;
    }
    
    /**
		 * Moves the playhead to the specified frame and stops playing
		 *
		 * @return void
		*/
    public function gotoAndStop(pFrame : Int) : Void
    {
        if (pFrame >= 1 && pFrame <= aFrames.length) 
        {
            
            iInc = as3hx.Compat.parseInt(as3hx.Compat.parseInt(pFrame) - 1);
            
            var _sw1_ = (gifDecoder.disposeValue);            

            switch (_sw1_)
            {
                
                case 1:
                    bitmapData = aFrames[0].bitmapData.clone();
                    bitmapData.draw(aFrames[concat(iInc)].bitmapData);
                case 2:
                    bitmapData = aFrames[iInc].bitmapData;
            }
            
            if (myTimer.running)                 myTimer.stop();
        }
        else throw new RangeError("Frame out of range, please specify a frame between 1 and " + aFrames.length);
    }
    
    /**
		 * Starts playing the GIF at the frame specified as parameter
		 *
		 * @return void
		*/
    public function gotoAndPlay(pFrame : Int) : Void
    {
        if (pFrame >= 1 && pFrame <= aFrames.length) 
        {
            
            iInc = as3hx.Compat.parseInt(as3hx.Compat.parseInt(pFrame) - 1);
            
            var _sw2_ = (gifDecoder.disposeValue);            

            switch (_sw2_)
            {
                
                case 1:
                    bitmapData = aFrames[0].bitmapData.clone();
                    bitmapData.draw(aFrames[concat(iInc)].bitmapData);
                case 2:
                    bitmapData = aFrames[iInc].bitmapData;
            }
            
            if (!myTimer.running)                 myTimer.start();
        }
        else throw new RangeError("Frame out of range, please specify a frame between 1 and " + aFrames.length);
    }
    
    /**
		 * Retrieves a frame from the GIF file as a BitmapData
		 *
		 * @return BitmapData object
		*/
    public function getFrame(pFrame : Int) : GIFFrame
    {
        var frame : GIFFrame;
        
        if (pFrame >= 1 && pFrame <= aFrames.length)             frame = aFrames[pFrame - 1]
        else throw new RangeError("Frame out of range, please specify a frame between 1 and " + aFrames.length);
        
        return frame;
    }
    
    /**
		 * Retrieves the delay for a specific frame
		 *
		 * @return int
		*/
    public function getDelay(pFrame : Int) : Int
    {
        var delay : Int = 0;
        
        if (pFrame >= 1 && pFrame <= aFrames.length)             delay = aFrames[pFrame - 1].delay
        else throw new RangeError("Frame out of range, please specify a frame between 1 and " + aFrames.length);
        
        return delay;
    }
}
