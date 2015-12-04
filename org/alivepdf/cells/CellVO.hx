package org.alivepdf.cells;


import org.alivepdf.colors.IColor;
import org.alivepdf.fonts.IFont;
import org.alivepdf.links.ILink;

/**
	 * the Cell VO is a description of a Text Cell to be rendered to PDF
	 * 
	 */
class CellVO
{
    public var x : Float;
    public var y : Float;
    public var color : IColor;
    public var width : Float;
    public var height : Float;
    public var font : IFont;
    public var fontSizePt : Int = 0;
    public var underlined : Bool;
    public var text : String;
    public var border : Bool = false;
    public var fill : Float = 0;
    public var link : ILink;

    public function new()
    {
    }
}
