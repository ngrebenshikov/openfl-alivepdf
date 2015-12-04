package org.alivepdf.text;


import org.alivepdf.links.ILink;
import org.alivepdf.pdf.PDF;

class Cell
{
    public var width : Float = 0;
    private var height : Float = 0;
    private var text : String = "";
    private var border : Dynamic = 0;
    private var ln : Float = 0;
    private var align : String = "";
    private var fill : Float = 0;
    private var link : ILink;
    
    public function new(width : Float = 0, height : Float = 0, text : String = "", border : Dynamic = 0, ln : Float = 0, align : String = "", fill : Float = 0, link : ILink = null)
    {
        this.width = width;
        this.height = height;
        this.text = text;
        this.border = border;
        this.ln = ln;
        this.align = align;
        this.fill = fill;
        this.link = link;
    }
    
    public function addCell(pdf : PDF) : Void
    {
        pdf.addCell(width, height, text, border, ln, align, fill, link);
    }
}
