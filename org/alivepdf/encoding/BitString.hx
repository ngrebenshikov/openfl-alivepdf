package org.alivepdf.encoding;


class BitString
{
    public var len : Int = 0;
    public var val : Int = 0;
    
    public function new(vl : Int, ln : Int)
    {
        val = vl;
        len = ln;
    }
}

