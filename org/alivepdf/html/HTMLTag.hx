package org.alivepdf.html;


@:final class HTMLTag
{
    public var tag : String;
    public var attr : FastXMLList;
    public var value : String;
    
    public function new(tag : String, attr : FastXMLList, value : String)
    {
        this.tag = tag;
        this.attr = attr;
        this.value = value;
    }
}
