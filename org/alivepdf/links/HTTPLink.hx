package org.alivepdf.links;

import org.alivepdf.links.ILink;

@:final class HTTPLink implements ILink
{
    public var link : String;
    
    public function new(link : String)
    {
        this.link = link;
    }
    
    public function toString() : String
    {
        return "[HTTPLink link=" + link + "]";
    }
}
