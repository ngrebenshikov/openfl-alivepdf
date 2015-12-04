package org.alivepdf.layout;


/**
	 * Represents the size of the printed page.
	 **/
@:final class Size
{
    public var fullLabel(get, never) : String;

    /**
		 * Constants representing the various paper sizes.
		 **/
    public static var A3 : Size = new Size([841.89, 1190.55], "A3", [11.7, 16.5], [297, 420]);
    public static var A4 : Size = new Size([595.28, 841.89], "A4", [8.3, 11.7], [210, 297]);
    public static var A5 : Size = new Size([420.94, 595.28], "A5", [5.8, 8.3], [148, 210]);
    public static var LETTER : Size = new Size([612, 792], "Letter", [8.5, 11], [216, 279]);
    public static var LEGAL : Size = new Size([612, 1008], "Legal", [8.5, 14], [216, 356]);
    public static var TABLOID : Size = new Size([792, 1224], "Tabloid", [11, 17], [279, 432]);
    
    /**
		 * An array containing all the available paper sizes.
		 **/
    public static var sizes : Array<Dynamic> = [A3, A4, A5, LETTER, LEGAL, TABLOID];
    
    /**
		 * The dimensions used by the PDF engine to determine page extents.
		 **/
    public var dimensions : Array<Dynamic>;
    
    /**
		 * A friendly label for users.
		 **/
    public var label : String = "";
    /**
		 * The dimensions, in inches.  This should be used for a friendly display for
		 * users and not in dimension calculations.
		 */
    public var inchesSize : Array<Dynamic>;
    /**
		 * The dimensions, in mm.  This should be used for a friendly display for
		 * users and not in dimension calculations.
		 */
    public var mmSize : Array<Dynamic>;
    
    /**
		 * Given a String representing the label of a size, or a Size object, this
		 * returns the Size object that corresponds to it.  Returns null on invalid
		 * size.
		 **/
    public static function getSize(value : Dynamic) : Size
    {
        if (Std.is(value, Size)) {return cast((value), Size);
        }
        
        if (Std.is(value, String)) 
        {
            for (s in sizes)
            {
                if (s.label == (Std.string(value))) 
                {
                    return s;
                }
            }
        }
        return null;
    }
    
    private function get_fullLabel() : String
    {
        //Returns format like: Letter - 8.5"x11" - 216x356mm
        return label + " - " + inchesSize[0] + "x" + inchesSize[1] + "\" - " + mmSize[0] + "x" + mmSize[1] + "mm";
    }
    
    public function toString() : String
    {
        return fullLabel;
    }
    
    public function clone() : Size
    {
        return new Size(dimensions.copy(), label, inchesSize.copy(), mmSize.copy());
    }
    
    public function new(pixelsSize : Array<Dynamic>, label : String, inchesSize : Array<Dynamic>, mmSize : Array<Dynamic>)
    {
        this.dimensions = pixelsSize;
        this.label = label;
        this.inchesSize = inchesSize;
        this.mmSize = mmSize;
    }
}
