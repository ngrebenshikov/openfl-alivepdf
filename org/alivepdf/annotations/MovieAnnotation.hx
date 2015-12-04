package org.alivepdf.annotations;


class MovieAnnotation extends Annotation
{
    public function new(type : String, text : String, x : Int = 0, y : Int = 0, width : Int = 100, height : Int = 100)
    {
        super(type, text, x, y, width, height);
    }
}
