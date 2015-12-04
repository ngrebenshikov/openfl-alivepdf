package org.alivepdf.drawing;



@:final class DashedLine
{
    public var pattern(get, never) : String;

    
    private var _aPattern : Array<Dynamic>;
    private var _sPattern : String;
    
    public function new(pDashedPattern : Array<Dynamic>)
    {
        
        _aPattern = pDashedPattern;
        _sPattern = "[";
        
        var lng : Int = _aPattern.length;
        
        for (i in 0...lng){((i < lng - 1)) ? _sPattern += _aPattern[i] + " " : _sPattern += _aPattern[i];
        }
        
        _sPattern += "] 0 d";
    }
    
    private function get_pattern() : String
    
    {
        
        return _sPattern;
    }
}

