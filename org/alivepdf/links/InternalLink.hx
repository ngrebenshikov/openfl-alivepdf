package org.alivepdf.links;

import flash.errors.Error;

import flash.geom.Rectangle;

@:final class InternalLink implements ILink
{
    public var page : Int = 0;
    public var y : Float;
    public var fit : Bool;
    public var rectangle : Rectangle;
    
    public function new(page : Int = 1, y : Float = 0, fit : Bool = false, rectangle : Rectangle = null)
    {
        if (page == 0) 
            throw new Error("Page number must be over 0 and below the total number of pages.");
        this.page = page;
        this.y = y;
        this.fit = fit;
        this.rectangle = rectangle;
    }
    
    public function toString() : String
    {
        return "[InternalLink page=" + page + " y=" + y + " fit=" + fit + " rectangle=" + rectangle + "]";
    }
}
