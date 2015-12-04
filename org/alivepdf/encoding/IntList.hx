package org.alivepdf.encoding;


@:final class IntList
{
    public var data : Int = 0;
    public var next : IntList;
    
    public function new(dt : Int, nx : IntList)
    {
        data = dt;
        next = nx;
    }
    
    public static function create(arr : Array<Dynamic>) : IntList
    {
        var i : Int = arr.length;
        var itm : IntList = new IntList(arr[--i], null);
        while (--i > -1){
            itm = new IntList(arr[i], itm);
        }
        return itm;
    }
}

