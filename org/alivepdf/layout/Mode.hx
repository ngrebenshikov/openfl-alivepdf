package org.alivepdf.layout;


@:final class Mode
{
    /**
		 * No resizing behavior involved.
		 */
    public static inline var NONE : String = "None";
    /**
		 * Resizes the image so that it fits the page dimensions.
		 * This will never stretch your image.
		 */
    public static inline var FIT_TO_PAGE : String = "FitToPage";
    /**
		 * Resizes the page to the image dimensions. White margins will be preserved.
		 * Use PDF.setMargins() to modify them.
		 */
    public static inline var RESIZE_PAGE : String = "ResizePage";

    public function new()
    {
    }
}
