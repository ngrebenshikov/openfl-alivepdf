package org.alivepdf.fonts;


interface ICidFont extends IFont
{
    
    var desc(get, never) : Dynamic;    
    var up(get, never) : Int;    
    var ut(get, never) : Int;    
    var dw(get, never) : Int;    
    var diff(get, never) : String;    
    var originalsize(get, never) : Int;    
    var enc(get, never) : String;    
    var cidinfo(get, never) : Dynamic;    
    var uni2cid(get, never) : Dynamic;

    function replaceCharactersWidth(value : Dynamic) : Void;
}
