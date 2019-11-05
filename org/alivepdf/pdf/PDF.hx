/*
_________________            __________________________
___    |__  /__(_)__   _________  __ \__  __ \__  ____/
__  /| |_  /__  /__ | / /  _ \_  /_/ /_  / / /_  /_    
_  ___ |  / _  / __ |/ //  __/  ____/_  /_/ /_  __/
/_/  |_/_/  /_/  _____/ \___//_/     /_____/ /_/  

* Copyright (c) 2007 Thibault Imbert
*
* This program is distributed under the terms of the MIT License as found 
* in a file called LICENSE. If it is not present, the license
* is always available at http://www.opensource.org/licenses/mit-license.php.
*
* This program is distributed in the hope that it will be useful, but
* without any waranty; without even the implied warranty of merchantability
* or fitness for a particular purpose. See the MIT License for full details.
*/

/**
 * This library lets you generate PDF files with the Adobe Flash Player 9 and 10.
 * AlivePDF contains some code from the FPDF PHP library by Olivier Plathey (http://www.fpdf.org/)
 * Core Team : Thibault Imbert, Mark Lynch, Alexandre Pires, Marc Hugues
 * @version 0.1.5 RC current release
 * @url http://alivepdf.bytearray.org
 */

package org.alivepdf.pdf;

import org.alivepdf.grid.GridColumn;
import org.alivepdf.images.IImage;
import haxe.io.Bytes;
import Xml;
import org.alivepdf.tools.Sprintf;
import haxe.ds.StringMap;
import flash.errors.Error;
import flash.errors.RangeError;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.system.Capabilities;
import flash.utils.ByteArray;
import flash.utils.Endian;


import org.alivepdf.annotations.Annotation;
import org.alivepdf.annotations.MovieAnnotation;
import org.alivepdf.annotations.TextAnnotation;
import org.alivepdf.cells.CellVO;
import org.alivepdf.codabar.CodaBar;
import org.alivepdf.colors.CMYKColor;
import org.alivepdf.colors.GrayColor;
import org.alivepdf.colors.IColor;
import org.alivepdf.colors.RGBColor;
import org.alivepdf.colors.RGBColorCache;
import org.alivepdf.colors.SpotColor;
import org.alivepdf.decoding.Filter;
import org.alivepdf.display.Display;
import org.alivepdf.display.PageMode;
import org.alivepdf.drawing.DashedLine;
import org.alivepdf.drawing.SectorDrawingCommand;
import org.alivepdf.drawing.WindingRule;
import org.alivepdf.encoding.Base64;
import org.alivepdf.encoding.JPEGEncoder;
import org.alivepdf.encoding.PNGEncoder;
import org.alivepdf.encoding.TIFFEncoder;
import org.alivepdf.events.PageEvent;
import org.alivepdf.events.ProcessingEvent;
import org.alivepdf.fonts.CoreFont;
import org.alivepdf.fonts.CoreFontCache;
import org.alivepdf.fonts.EmbeddedFont;
import org.alivepdf.fonts.FontCollections;
import org.alivepdf.fonts.FontDescription;
import org.alivepdf.fonts.FontFamily;
import org.alivepdf.fonts.FontMetrics;
import org.alivepdf.fonts.FontType;
import org.alivepdf.fonts.IFont;
import org.alivepdf.fonts.Style;
import org.alivepdf.gradients.ShadingType;
import org.alivepdf.grid.Grid;
import org.alivepdf.grid.GridCell;
import org.alivepdf.grid.GridRowType;
import org.alivepdf.html.FONTTagAttributes;
import org.alivepdf.html.HTMLTag;
import org.alivepdf.images.ColorSpace;
import org.alivepdf.images.DoJPEGImage;
import org.alivepdf.images.DoPNGImage;
import org.alivepdf.images.DoTIFFImage;
import org.alivepdf.images.GIFImage;
import org.alivepdf.images.ImageFormat;
import org.alivepdf.images.JPEGImage;
import org.alivepdf.images.PDFImage;
import org.alivepdf.images.PNGImage;
import org.alivepdf.images.TIFFImage;
import org.alivepdf.images.gif.player.GIFPlayer;
import org.alivepdf.layout.Align;
import org.alivepdf.layout.Border;
import org.alivepdf.layout.HorizontalAlign;
import org.alivepdf.layout.Layout;
import org.alivepdf.layout.Mode;
import org.alivepdf.layout.Position;
import org.alivepdf.layout.Resize;
import org.alivepdf.layout.Size;
import org.alivepdf.layout.Unit;
import org.alivepdf.links.HTTPLink;
import org.alivepdf.links.ILink;
import org.alivepdf.links.InternalLink;
import org.alivepdf.links.Outline;
import org.alivepdf.operators.Drawing;
import org.alivepdf.pages.Page;
import org.alivepdf.saving.Method;
import org.alivepdf.text.Cell;
import org.alivepdf.tools.Sprintf;
import org.alivepdf.visibility.Visibility;
import org.alivepdf.tools.Sprintf;

/**
	 * Dispatched when a page has been added to the PDF. The addPage() method generate this event
	 *
	 * @eventType org.alivepdf.events.PageEvent.ADDED
	 *
	 * * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * myPDF.addEventListener ( PageEvent.ADDED, pageAdded );
	 * </pre>
	 * </div>
	 */
@:meta(Event(name="added",type="org.alivepdf.events.PageEvent"))


/**
	 * Dispatched when PDF has been generated and available. The save() method generate this event
	 *
	 * @eventType org.alivepdf.events.ProcessingEvent.COMPLETE
	 *
	 * * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * myPDF.addEventListener ( ProcessingEvent.COMPLETE, generationComplete );
	 * </pre>
	 * </div>
	 */
@:meta(Event(name="complete",type="org.alivepdf.events.ProcessingEvent"))


/**
	 * Dispatched when the PDF page tree has been generated. The save() method generate this event
	 *
	 * @eventType org.alivepdf.events.ProcessingEvent.PAGE_TREE
	 *
	 * * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * myPDF.addEventListener ( ProcessingEvent.PAGE_TREE, pageTreeAdded );
	 * </pre>
	 * </div>
	 */
@:meta(Event(name="pageTree",type="org.alivepdf.events.ProcessingEvent"))


/**
	 * Dispatched when the required resources (fonts, images, etc.) haven been written into the PDF. The save() method generate this event
	 *
	 * @eventType org.alivepdf.events.ProcessingEvent.RESOURCES
	 *
	 * * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * myPDF.addEventListener ( ProcessingEvent.RESOURCES, resourcesAdded );
	 * </pre>
	 * </div>
	 */
@:meta(Event(name="resources",type="org.alivepdf.events.ProcessingEvent"))


/**
	 * Dispatched when the PDF generation has been initiated. The save() method generate this event
	 *
	 * @eventType org.alivepdf.events.ProcessingEvent.STARTED
	 *
	 * * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * myPDF.addEventListener ( ProcessingEvent.STARTED, generationStarted );
	 * </pre>
	 * </div>
	 */
@:meta(Event(name="started",type="org.alivepdf.events.ProcessingEvent"))


/**
	 * The PDF class represents a PDF document.
	 * 
	 * @author Thibault Imbert
	 * 
	 * @example
	 * This example shows how to create a PDF document :
	 * <div class="listing">
	 * <pre>
	 * 
	 * var myPDF:PDF = new PDF( Orientation.LANDSCAPE, Unit.MM, Size.A4 );
	 * </pre>
	 * </div>
	 * 
	 * This example shows how to listen for events during PDF creation :
	 * <div class="listing">
	 * <pre>
	 *
	 * myPDF.addEventListener( ProcessingEvent.STARTED, generationStarted );
	 * myPDF.addEventListener( ProcessingEvent.PAGE_TREE, pageTreeGeneration );
	 * myPDF.addEventListener( ProcessingEvent.RESOURCES, resourcesEmbedding );
	 * myPDF.addEventListener( ProcessingEvent.COMPLETE, generationComplete );
	 * </pre>
	 * </div>
	 * 
	 * This example shows how to listen for an event when a page is added to the PDF :
	 * <div class="listing">
	 * <pre>
	 *
	 * myPDF.addEventListener( PageEvent.ADDED, pageAdded );
	 * </pre>
	 * </div>
	 */
class PDF implements IEventDispatcher
{
    public var totalPages(get, never) : Int;
    public var totalFonts(get, never) : Int;

    
    private static inline var PDF_VERSION : String = "1.3";
    private static inline var ALIVEPDF_VERSION : String = "0.1.5 RC";
    private var I1000 : Int = 1000;
    
    private static inline var STATE_0 : Int = 0;
    private static inline var STATE_1 : Int = 1;
    private static inline var STATE_2 : Int = 2;
    private static inline var STATE_3 : Int = 3;
    
    private var format : Array<Dynamic>;
    private var size : Size;
    private var margin : Float;
    private var nbPages : Int = 0;
    private var n : Int = 0;
    private var offsets : Array<Dynamic>;
    private var state : Int = 0;
    private var defaultOrientation : String;
    private var defaultSize : Size;
    private var defaultRotation : Int = 0;
    private var defaultUnit : String;
    private var currentOrientation : String;
    private var orientationChanges : Array<Dynamic>;
    private var strokeColor : IColor;
    private var fillColor : IColor;
    private var strokeStyle : String;
    private var strokeAlpha : Float;
    private var strokeFlatness : Float;
    private var strokeBlendMode : String;
    private var strokeDash : DashedLine;
    private var strokeCaps : String;
    private var strokeJoints : String;
    private var strokeMiter : Float;
    private var textAlpha : Float;
    private var textLeading : Float;
    private var textColor : IColor;
    private var textScale : Float;
    private var textSpace : Float;
    private var textWordSpace : Float;
    private var k : Float;
    private var leftMargin : Float;
    private var leftMarginPt : Null<Float>;
    private var topMargin : Float;
    private var topMarginPt : Null<Float>;
    private var rightMargin : Float;
    private var rightMarginPt : Null<Float>;
    private var bottomMargin : Float;
    private var bottomMarginPt : Null<Float>;
    private var currentMargin : Float;
    private var currentX : Float;
    private var currentY : Float;
    private var currentMatrix : Matrix;
    private var lasth : Float;
    private var strokeThickness : Float;
    private var fonts : Array<Dynamic>;
    private var differences : Array<Dynamic>;
    private var fontFamily : String;
    private var fontStyle : String;
    private var underline : Bool;
    private var fontSizePt : Int = 0;
    private var windingRule : String;
    private var addTextColor : String;
    private var colorFlag : Bool;
    private var ws : Float;
    private var helvetica : IFont;
    private var autoPageBreak : Bool;
    private var pageBreakTrigger : Float;
    private var inHeader : Bool;
    private var inFooter : Bool;
    private var zoomMode : Dynamic;
    private var zoomFactor : Float;
    private var layoutMode : String;
    private var pageMode : String;
    private var isLinux : Bool;
    private var documentTitle : String;
    private var documentSubject : String;
    private var documentAuthor : String;
    private var documentKeywords : String;
    private var documentCreator : String;
    private var aliasNbPages : String;
    private var version : String;
    private var buffer : ByteArray;
    private var streamDictionary : StringMap<Dynamic>;
    private var compressedPages : ByteArray;
    private var image : PDFImage;
    private var fontSize : Float;
    private var name : String;
    private var type : String;
    private var desc : String;
    private var underlinePosition : Float;
    private var underlineThickness : Float;
    private var charactersWidth : StringMap<Int>;
    private var d : Int = 0;
    private var nb : Int = 0;
    private var size1 : Float;
    private var size2 : Float;
    private var currentFont : IFont;
    private var defaultFont : IFont;
    private var b2 : String;
    private var filter : String;
    private var filled : Bool;
    private var dispatcher : EventDispatcher;
    private var arrayPages : Array<Page>;
    private var arrayNotes : Array<Dynamic>;
    private var graphicStates : Array<Dynamic>;
    private var currentPage : Page;
    private var outlines : Array<Outline>;
    private var outlineRoot : Int = 0;
    private var textRendering : Int = 0;
    private var viewerPreferences : String;
    private var reference : String;
    private var pagesReferences : Array<String>;
    private var nameDictionary : String;
    private var displayObjectbounds : Rectangle;
    private var coreFontMetrics : FontMetrics;
    private var columnNames : Array<GridCell>;
    private var columns : Array<GridColumn>;
    private var currentGrid : Grid;
    private var isEven : Int = 0;
    private var matrix : Matrix;
    private var pushedFontName : String;
    private var fontUnderline : Bool;
    private var jsResource : Int = 0;
    private var js : String;
    private var widths : Dynamic;
    private var aligns : Array<Dynamic> = new Array<Dynamic>();
    private var spotColors : Array<SpotColor> = new Array<SpotColor>();
    private var drawColor : String;
    private var bitmapFilled : Bool;
    private var bitmapFillBuffer : Shape = new Shape();
    private var visibility : String = Visibility.ALL;
    private var nOCGPrint : Int = 0;
    private var nOCGView : Int = 0;
    private var startingPageIndex : Int = 0;
    private var nextPageY : Float = 10;
    private var nextPageX : Float = 10;
    private var gradients : Array<ShadingType> = new Array<ShadingType>();
    private var isWrapRow : Bool;
    private var row : Array<Dynamic>;
    private var column : Array<Dynamic>;
    private var rowX : Float;
    private var rowY : Float;
    private var maxY : Float;
    private var angle : Float = 0;
    private var _footer : String;
    private var _header : String;
    private var stroking : Bool;
    
    /**
		 * The PDF class represents a PDF document.
		 *
		 * @example
		 * This example shows how to create a valid PDF document :
		 * <div class="listing">
		 * <pre>
		 *
		 * var myPDF:PDF = new PDF ( Orientation.PORTRAIT, Unit.MM, Size.A4 );
		 * </pre>
		 * </div>
		 */
    public function new(orientation : String = "Portrait", unit : String = "Mm", autoPageBreak : Bool = true, pageSize : Size = null, rotation : Int = 0)
    {
        init(orientation, unit, autoPageBreak, pageSize, rotation);
    }
    
    /**
		 * Lets you specify the left, top, and right margins.
		 *
		 * @param left Left margin
		 * @param top Right number
		 * @param right Top number
		 * @param bottom Bottom number
		 * @example
		 * This example shows how to set margins for the PDF document :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setMargins ( 10, 10, 10, 10 );
		 * </pre>
		 * </div>
		 */
    public function setMargins(left : Float, top : Float, right : Float = -1, bottom : Float = 20) : Void
    {
        leftMargin = left;
        leftMarginPt = leftMargin * k;
        
        topMargin = top;
        topMarginPt = topMargin * k;
        
        bottomMargin = bottom;
        bottomMarginPt = bottomMargin * k;
        
        if (right == -1) 
            right = left;
        
        rightMargin = right;
        rightMarginPt = rightMargin * k;
    }
    
    /**
		 * Lets you reset the margins dimensions.
		 *
		 * @return
		 * @example
		 * This example shows how to reset the margins dimensions :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.resetMargins ();
		 * </pre>
		 * </div>
		 */
    public function resetMargins() : Void
    {
        var margin : Float = 28.35 / k;
        setMargins(margin, margin);
    }
    
    /**
		 * Lets you retrieve the margins dimensions.
		 *
		 * @return Rectangle
		 * @example
		 * This example shows how to get the margins dimensions :
		 * <div class="listing">
		 * <pre>
		 *
		 * var marginsDimensions:Rectangle = myPDF.getMargins ();
		 * // output : (x=10.00, y=10.0012, w=575.27, h=811.88)
		 * trace( marginsDimensions )
		 * </pre>
		 * </div>
		 */
    public function getMargins() : Rectangle
    {
        return new Rectangle(leftMargin, topMargin, getCurrentPage().w - rightMargin - leftMargin, getCurrentPage().h - bottomMargin - topMargin);
    }
    
    /**
		 * Lets you specify the left margin.
		 *
		 * @param margin Left margin
		 * @example
		 * This example shows how set left margin for the PDF document :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setLeftMargin ( 10 );
		 * </pre>
		 * </div>
		 */
    public function setLeftMargin(margin : Float) : Void
    {
        leftMargin = margin;
        leftMarginPt = leftMargin * k;
        
        if (nbPages > 0 && currentX < margin) 
            currentX = margin;
    }
    
    /**
		 * Lets you specify the top margin.
		 *
		 * @param margin Top margin
		 * @example
		 * This example shows how set top margin for the PDF document :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setTopMargin ( 10 );
		 * </pre>
		 * </div>
		 */
    public function setTopMargin(margin : Float) : Void
    {
        topMargin = margin;
        topMarginPt = topMargin * k;
    }
    
    /**
		 * Lets you specify the bottom margin
		 *
		 * @param margin Bottom margin
		 * @example
		 * This example shows how set bottom margin for the PDF document :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setBottomMargin ( 10 );
		 * </pre>
		 * </div>
		 */
    public function setBottomMargin(margin : Float) : Void
    {
        bottomMargin = margin;
        bottomMarginPt = bottomMargin * k;
    }
    
    /**
		 * Lets you specify the right margin.
		 *
		 * @param margin Right margin
		 * @example
		 * This example shows how set right margin for the PDF document :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setRightMargin ( 10 );
		 * </pre>
		 * </div>
		 */
    public function setRightMargin(margin : Float) : Void
    {
        rightMargin = margin;
        rightMarginPt = rightMargin * k;
    }
    
    /**
		 * Lets you enable or disable auto page break mode and triggering margin.
		 * 
		 * @param auto Page break mode
		 * @param margin Bottom margin
		 * 
		 */
    public function setAutoPageBreak(auto : Bool, margin : Float) : Void
    {
        autoPageBreak = auto;
        setBottomMargin(margin);
        if (currentPage != null) 
            pageBreakTrigger = currentPage.h - margin;
    }
    
    /**
		 * Lets you set a specific display mode, the DisplayMode takes care of the general layout of the PDF in the PDF reader
		 *
		 * @param zoom Zoom mode, can be Display.FULL_PAGE, Display.FULL_WIDTH, Display.REAL, Display.DEFAULT
		 * @param layout Layout of the PDF document, can be Layout.SINGLE_PAGE, Layout.ONE_COLUMN, Layout.TWO_COLUMN_LEFT, Layout.TWO_COLUMN_RIGHT
		 * @param mode PageMode can be pageMode.USE_NONE, PageMode.USE_OUTLINES, PageMode.USE_THUMBS, PageMode.FULL_SCREEN
		 * @param zoomValue Zoom factor to be used when the PDF is opened, a value of 1.5 would open the PDF with a 150% zoom
		 * @example
		 * This example creates a PDF which opens at full page scaling, one page at a time :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setDisplayMode ( Display.FULL_PAGE, Layout.SINGLE_PAGE );
		 * </pre>
		 * </div>
		 * To create a full screen PDF you would write :
		 * <div class="listing">
		 * <pre>
		 * 
		 * myPDF.setDisplayMode( Display.FULL_PAGE, Layout.SINGLE_PAGE, PageMode.FULLSCREEN );
		 * </pre>
		 * </div>
		 * 
		 * To create a PDF which will open with a 150% zoom, you would write :
		 * <div class="listing">
		 * <pre>
		 * 
		 * myPDF.setDisplayMode( Display.REAL, Layout.SINGLE_PAGE, PageMode.USE_NONE, 1.5 );
		 * </pre>
		 * </div>
		 */
    public function setDisplayMode(zoom : String = "FullWidth", layout : String = "SinglePage", mode : String = "UseNone", zoomValue : Float = 1) : Void
    {
        zoomMode = zoom;
        zoomFactor = zoomValue;
        layoutMode = layout;
        pageMode = mode;
    }
    
    /**
		 * Lets you set specify the timing (in seconds) a page is shown when the PDF is shown in fullscreen mode.
		 *
		 * @param title The title
		 * @example
		 * This example shows how to set a specific advance timing (5 seconds) for the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setAdvanceTiming ( 5 );
		 * </pre>
		 * </div>
		 * 
		 * You can also specify this on the Page object :
		 * <div class="listing">
		 * <pre>
		 *
		 * var page:Page = new Page ( Orientation.PORTRAIT, Unit.MM );
		 * page.setAdvanceTiming ( 5 );
		 * myPDF.addPage ( page );
		 * </pre>
		 * </div>
		 */
    public function setAdvanceTiming(timing : Int) : Void
    {
        currentPage.advanceTiming = timing;
    }
    
    /**
		 * Lets you set a title for the PDF.
		 *
		 * @param title The title
		 * @example
		 * This example shows how to set a specific title to the PDF tags :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setTitle ( "AlivePDF !" );
		 * </pre>
		 * </div>
		 */
    public function setTitle(title : String) : Void
    {
        documentTitle = title;
    }
    
    /**
		 * Lets you set a subject for the PDF.
		 *
		 * @param subject The subject
		 * @example
		 *  This example shows how to set a specific subject to the PDF tags :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setSubject ( "Any topic" );
		 * </pre>
		 * </div>
		 */
    public function setSubject(subject : String) : Void
    {
        documentSubject = subject;
    }
    
    /**
		 * Sets the specified author for the PDF.
		 *
		 * @param author The author
		 * @example
		 * This example shows how to add a specific author to the PDF tags :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setAuthor ( "Bob" );
		 * </pre>
		 * </div>
		 */
    public function setAuthor(author : String) : Void
    {
        documentAuthor = author;
    }
    
    /**
		 * Sets the specified keywords for the PDF.
		 *
		 * @param keywords The keywords
		 * @example
		 * This example shows how to add some keywords to the PDF tags :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setKeywords ( "Design, Agency, Communication, etc." );
		 * </pre>
		 * </div>
		 */
    public function setKeywords(keywords : String) : Void
    {
        documentKeywords = keywords;
    }
    
    /**
		 * Sets the specified creator for the PDF.
		 *
		 * @param creator Name of the PDF creator
		 * @example
		 * This example shows how to set a creator name to the PDF tags :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setCreator ( "My Application 1.0" );
		 * </pre>
		 * </div>
		 */
    public function setCreator(creator : String) : Void
    {
        documentCreator = creator;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF paging API
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
		 * Lets you specify an alias for the total number of pages.
		 *
		 * @param alias Alias to use
		 * @example
		 * This example shows how to show the total number of pages :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setAliasNbPages ( "[nb]" );
		 * myPDF.textStyle( new RGBColor (0,0,0), 1 );
		 * myPDF.setFont( FontFamily.HELVETICA, Style.NORMAL, 18 );
		 * // then use the alias when needed
		 * myPDF.addText ("There are [nb] pages in the PDF !", 150, 50);
		 * </pre>
		 * </div>
		 */
    public function setAliasNbPages(alias : String = "{nb}") : Void
    {
        aliasNbPages = alias;
    }
    
    /**
		 * Lets you rotate a specific page (between 1 and n-1).
		 *
		 * @param number Page number
		 * @param rotation Page rotation (must be a multiple of 90)
		 * @throws RangeError
		 * @example
		 * This example shows how to rotate the first page 90 clock wise :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.rotatePage ( 1, 90 );
		 * </pre>
		 * </div>
		 * 
		 * This example shows how to rotate the first page 90 counter clock wise :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.rotatePage ( 1, -90 );
		 * </pre>
		 * </div>
		 */
    public function rotatePage(number : Int, rotation : Float) : Void
    {
        if (number > 0 && number <= arrayPages.length)
            arrayPages[number - 1].rotate(Std.int(rotation))
        else throw new RangeError("No page available, please select a page from 1 to " + arrayPages.length);
    }
    
    /**
		 * Lets you add a page to the current PDF.
		 *  
		 * @param page
		 * @returns page
		 * @example
		 * 
		 * This example shows how to add an A4 page with a landscape orientation :
		 * <div class="listing">
		 * <pre>
		 *
		 * var page:Page = new Page ( Orientation.LANDSCAPE, Unit.MM, Size.A4 );
		 * myPDF.addPage( page );
		 * </pre>
		 * </div>
		 * This example shows how to add a page with a custom size :
		 * <div class="listing">
		 * <pre>
		 *
		 * var customSize:Size = new Size ( [420.94, 595.28], "CustomSize", [5.8,  8.3], [148, 210] );
		 * var page:Page = new Page ( Orientation.PORTRAIT, Unit.MM, customSize );
		 * myPDF.addPage ( page );
		 * </pre>
		 * </div>
		 * 
		 */
    public function addPage(page : Page = null) : Page
    {
        if (page == null) 
            page = new Page(defaultOrientation, defaultUnit, defaultSize, defaultRotation);
        
        pagesReferences.push((3 + (arrayPages.length << 1)) + " 0 R");
        
        arrayPages.push(page);
        
        page.number = pagesReferences.length;
        
        if (state == PDF.STATE_0) 
            open();
        
        if (nbPages > 0) 
        {
            inFooter = true;
            footer();
            inFooter = false;
            finishPage();
        }
        
        currentPage = page;
        
        setUnit(currentPage.unit);
        
        startPage(page != (null) ? page.orientation : defaultOrientation);
        
        /*
			if ( strokeColor != null ) 
				lineStyle ( strokeColor, strokeThickness, strokeFlatness, strokeAlpha, windingRule, strokeBlendMode, strokeDash, strokeCaps, strokeJoints, strokeMiter );
			
			if ( fillColor != null ) 
				beginFill( fillColor );*/
        
        if (textColor != null) 
            textStyle(textColor, textAlpha, textRendering, textSpace, textSpace, textScale, textLeading);
        
        if (currentFont != null) 
            setFont(currentFont, fontSizePt)
        else setFont(CoreFontCache.getFont(FontFamily.HELVETICA), 9);
        
        inHeader = true;
        header();
        inHeader = false;
        
        dispatcher.dispatchEvent(new PageEvent(PageEvent.ADDED, currentPage));
        
        return page;
    }
    
    /**
		 * Lets you retrieve a Page object.
		 *
		 * @param page page number, from 1 to total numbers of pages
		 * @return Page
		 * @example
		 * This example shows how to retrieve the first page :
		 * <div class="listing">
		 * <pre>
		 *
		 * var page:Page = myPDF.getPage ( 1 );
		 * </pre>
		 * </div>
		 */
    public function getPage(index : Int) : Page
    {
        var lng : Int = arrayPages.length;
        if (index > 0 && index <= lng) 
            return arrayPages[index - 1]
        else throw new RangeError("Can't retrieve page " + index + ". " + lng + " page(s) available.");
    }
    
    /**
		 * Lets you retrieve all the PDF pages.
		 *
		 * @return Array
		 * @example
		 * This example shows how to retrieve all the PDF pages :
		 * <div class="listing">
		 * <pre>
		 *
		 * var pdfPages:Array = myPDF.getPages ();
		 *
		 * for each ( var p:Page in pdfPages ) trace( p );
		 * 
		 * outputs :
		 * 
		 * [Page orientation=Portrait width=210 height=297]
		 * [Page orientation=Landscape width=297 height=210]
		 * 
		 * </pre>
		 * </div>
		 */
    public function getPages() : Array<Dynamic>
    {
        if (arrayPages.length > 0)
            return arrayPages
        else throw new RangeError("No pages available.");
    }
    
    /**
		 * Lets you move to a Page in the PDF.
		 *
		 * @param page page number, from 1 to total numbers of pages
		 * @example
		 * This example shows how to move to the first page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.gotoPage ( 1 );
		 * // draw on the first page
		 * myPDF.lineStyle( new RGBColor(0xFF0000), 2, 0 );
		 * myPDF.drawRect( 60, 60, 40, 40 ); 
		 * </pre>
		 * </div>
		 */
    public function gotoPage(index : Int) : Void
    {
        var lng : Int = arrayPages.length;
        if (index > 0 && index <= lng) 
            currentPage = arrayPages[index - 1]
        else throw new RangeError("Can't find page " + index + ". " + lng + " page(s) available.");
    }
    
    /**
		 * Lets you remove a Page from the PDF.
		 *
		 * @param page page number, from 1 to total numbers of pages
		 * @return Page
		 * @example
		 * This example shows how to remove the first page :
		 * <div class="listing">
		 * <pre>
		 * myPDF.removePage ( 1 );
		 * </pre>
		 * </div>
		 * 
		 * If you want to remove pages each by each, you can combine removePage with getPageCount:
		 * <div class="listing">
		 * <pre>
		 * myPDF.removePage ( myPDFEncoder.getPageCount() );
		 * </pre>
		 * </div>
		 */
    public function removePage(index : Int) : Page
    {
        if (index > 0 && index <= arrayPages.length) 
            return arrayPages.splice(index - 1, 1)[0]
        else throw new RangeError("Cannot remove page " + index + ".");
    }
    
    /**
		 * Lets you remove all the pages from the PDF.
		 *
		 * @example
		 * This example shows how to remove all the pages :
		 * <div class="listing">
		 * <pre>
		 * myPDF.removeAllPages();
		 * </pre>
		 * </div>
		 */
    public function removeAllPages() : Void
    {
        arrayPages = new Array<Page>();
        pagesReferences = new Array<String>();
    }
    
    /**
		 * Lets you retrieve the current Page.
		 *
		 * @return Page A Page object
		 * @example
		 * This example shows how to retrieve the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * var page:Page = myPDF.getCurrentPage ();
		 * </pre>
		 * </div>
		 */
    public function getCurrentPage() : Page
    {
        if (arrayPages.length > 0) 
            return currentPage
        else throw new RangeError("Can't retrieve the current page, " + arrayPages.length + " pages available.");
    }
    
    /**
		 * Lets you retrieve the number of pages in the PDF document.
		 *
		 * @return int Number of pages in the PDF
		 * @example
		 * This example shows how to retrieve the number of pages :
		 * <div class="listing">
		 * <pre>
		 *
		 * var totalPages:int = myPDF.totalPages;
		 * </pre>
		 * </div>
		 */
    private function get_totalPages() : Int
    {
        return arrayPages.length;
    }
    
    /**
		 * Lets you insert a line break for text.
		 *
		 * @param height Line break height
		 * @example
		 * This example shows how to add a line break :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.newLine ( 10 );
		 * </pre>
		 * </div>
		 */
    public function newLine(height : Dynamic = "") : Void
    {
        currentX = leftMargin;
        currentY += ((Std.is(height, String))) ? lasth : height;
    }
    
    /**
		 * Lets you retrieve the X position for the current page.
		 *
		 * @return Number the X position
		 */
    public function getX() : Float
    {
        return currentX;
    }
    
    /**
		 * Lets you retrieve the Y position for the current page.
		 *
		 * @return Number the Y position
		 */
    public function getY() : Float
    {
        return currentY;
    }
    
    /**
		 * Lets you specify the X position for the current page.
		 *
		 * @param x The X position
		 */
    public function setX(x : Float) : Void
    {
        if (acceptPageBreak()) 
            currentX = ((x >= 0)) ? x : currentPage.w + x
        else currentX = x;
    }
    
    /**
		 * Lets you specify the Y position for the current page.
		 *
		 * @param y The Y position
		 */
    public function setY(y : Float) : Void
    {
        if (acceptPageBreak()) 
        {
            currentX = leftMargin;
            currentY = ((y >= 0)) ? y : currentPage.h + y;
        }
        else currentY = y;
    }
    
    /**
		 * Lets you specify the X and Y position for the current page.
		 *
		 * @param x The X position
		 * @param y The Y position
		 */
    public function setXY(x : Float, y : Float) : Void
    {
        setY(y);
        setX(x);
    }
    
    /**
		 * Returns the default PDF Size.
		 * 
		 * @return Size
		 * 
		 */
    public function getDefaultSize() : Size
    {
        return defaultSize;
    }
    
    /**
		 * Returns the default PDF orientation.
		 * 
		 * @return String
		 * 
		 */
    public function getDefaultOrientation() : String
    {
        return defaultOrientation;
    }
    
    /**
		 * Returns the default PDF unit unit.
		 * 
		 * @return String
		 * 
		 */
    public function getDefaultUnit() : String
    {
        return defaultUnit;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF transform API
		*
		* skew()
		* rotate()
		*
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
		 * Allows you to skew any content drawn after the skew() call  
		 * @param ax X skew angle
		 * @param ay Y skew angle
		 * @param x X position
		 * @param y Y position
		 * 
		 */
    public function skew(ax : Float, ay : Float, x : Float = -1, y : Float = -1) : Void
    {
        if (x == -1) 
            x = getX();
        
        if (y == -1) 
            y = getY();
        
        if (ax == 90 || ay == 90) 
            throw new RangeError("Please use values between -90° and 90° for skewing.");
        
        x *= k;
        y = (currentPage.h - y) * k;
        ax *= Math.PI / 180;
        ay *= Math.PI / 180;
        matrix.identity();
        matrix.a = 1;
        matrix.b = Math.tan(ay);
        matrix.c = Math.tan(ax);
        matrix.d = 1;
        getMatrixTransformPoint(x, y);
        transform(matrix);
    }
    
    /**
		 * Allows you to rotate any content drawn after the rotate() call  
		 * @param angle Rotation angle
		 * @param x X position
		 * @param y Y position
		 * 
		 */
    /*
		public function rotate(angle:Number, x:Number=-1, y:Number=-1, relative:Boolean=true):void
		{
			if(x == -1)
				x = getX();
			
			if(y == -1)
				y = getY();
			
			if ( this.angle != 0 )
				write('Q');
			
			this.angle = angle;
			
			if ( this.angle != 0 )
			{
				angle *= Math.PI / 180;
				x *= k;
				y = (currentPage.h - y) * k;
				matrix.identity();
				matrix.rotate(-angle);
				getMatrixTransformPoint(x, y);
				transform(matrix);
			}
			
			if (!relative)
				write('Q');
		}*/
    
    public function rotate(angle : Float, x : Float = -1, y : Float = -1) : Void
    {
        if (x == -1) 
            x = getX();
        
        if (y == -1) 
            y = getY();
        
        angle *= Math.PI / 180;
        x *= k;
        y = (currentPage.h - y) * k;
        matrix.identity();
        matrix.rotate(-angle);
        getMatrixTransformPoint(x, y);
        transform(matrix);
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF Header and Footer API
		*
		* header()
		* footer()
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public function header(headerText : String = "") : Void
    {
        
        /*			//to be overriden by subclassing (uncomment for a demo )
			var newFont:CoreFont = CoreFontCache.getFont ( FontFamily.HELVETICA );
			this.setFont(newFont, 12);
			this.textStyle( new RGBColor (0x000000) );
			this.addCell(80);
			this.addCell(30,10,headerText,1,0, Align.CENTER);
			this.newLine(20);*/
        
    }
    
    public function footer(footerText : String = "", showPageNumber : Bool = false, position : String = "left") : Void
    {
        
        /*			//to be overriden by subclassing (uncomment for a demo )
			
			switch(position){
				case "left":
									this.setXY (15, -15);
									break;
				case "center":
									this.setXY(100,-15);
									break;
				case "right":
									this.setXY(this.getMargins().width * 0.5,-15);
									break;
			}
			//this.setXY (15, -15);
			var newFont:CoreFont = CoreFontCache.getFont ( FontFamily.HELVETICA );
			this.setFont(newFont, 8);
			this.textStyle( new RGBColor (0x000000) );
			if(showPageNumber){
			this.addCell(0,10, footerText+(totalPages-1),0,0,'C');
			}else{
				this.addCell(0,10, footerText,0,0, Align.CENTER);
			}
			this.newLine(20);*/
        
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF Drawing API
		*
		* moveTo()
		* lineTo()
		* drawLine()
		* end()
		* curveTo()
		* lineStyle()
		* beginFill()
		* beginBitmapFill()
		* endFill()
		* drawRect()
		* drawRoundRect()
		* drawComplexRoundRect()
		* drawCircle()
		* drawEllipse()
		* drawPolygone()
		* drawRegularPolygone()
		* drawPath()
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
		 * Lets you specify the opacity for the next drawing operations, from 0 (100% transparent) to 1 (100% opaque).
		 *
		 * @param alpha Opacity
		 * @param blendMode Blend mode, can be Blend.DIFFERENCE, BLEND.HARDLIGHT, etc.
		 * @example
		 * This example shows how to set the transparency to 50% for any following drawing, image or text operation :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setAlpha ( .5 );
		 * </pre>
		 * </div>
		 */
    public function setAlpha(alpha : Float, blendMode : String = "Normal") : Void
    {
        var graphicState : Int = addExtGState({
                    ca : alpha,
                    SA : true,
                    CA : alpha,
                    BM : "/" + blendMode,
                });
        setExtGState(graphicState);
    }
    
    /**
		 * Lets you move the current drawing point to the specified destination.
		 *
		 * @param x X position
		 * @param y Y position
		 * @example
		 * This example shows how to move the pen to 120,200 :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.moveTo ( 120, 200 );
		 * </pre>
		 * </div>
		 */
    public function moveTo(x : Float, y : Float) : Void
    {
        write(x * k + " " + (currentPage.h - y) * k + " m");
    }
    
    /**
		 * Lets you draw a stroke from the current point to the new point.
		 *
		 * @param x X position
		 * @param y Y position
		 * @example
		 * This example shows how to draw some dashed lines in the current page with specific caps style and joint style :
		 * <br><b>Important : Always call the end() method when you're done</b>
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.lineStyle( new RGBColor ( 0x990000 ), 1, 1 );
		 * myPDF.moveTo ( 10, 20 );
		 * myPDF.lineTo ( 40, 20 );
		 * myPDF.lineTo ( 40, 40 );
		 * myPDF.lineTo ( 10, 40 );
		 * myPDF.lineTo ( 10, 20 );
		 * myPDF.end();
		 * </pre>
		 * </div>
		 */
    public function lineTo(x : Float, y : Float) : Void
    {
        write(x * k + " " + (currentPage.h - y) * k + " l");
    }
    
    /**
		 * The end method closes the stroke.
		 *
		 * @example
		 * This example shows how to draw some dashed lines in the current page with specific caps style and joint style :
		 * <br><b>Important : Always call the end() method when you're done</b>
		 * <div class="listing">
		 * <pre>
		 * 
		 * myPDF.lineStyle( new RGBColor ( 0x990000 ), 1, 1 );
		 * myPDF.moveTo ( 10, 20 );
		 * myPDF.lineTo ( 40, 20 );
		 * myPDF.lineTo ( 40, 40 );
		 * myPDF.lineTo ( 10, 40 );
		 * myPDF.lineTo ( 10, 20 );
		 * // end the stroke
		 * myPDF.end();
		 * </pre>
		 * </div>
		 */
    public function end(closePath : Bool = true) : Void
    {
        if (!filled) 
        {
            if (closePath) 
                write("s")
            else write("S");
        }
        else if (!stroking) 
            write(windingRule == (WindingRule.NON_ZERO) ? "f" : "f*")
        else write(windingRule == (WindingRule.NON_ZERO) ? "b" : "b*");
        
        if (stroking) 
            stroking = false;
    }
    
    /**
		 * 
		 * 
		 * 
		 */
    public function drawLine(x1 : Float, y1 : Float, x2 : Float, y2 : Float) : Void
    {
        write(Sprintf.sprintf("%.2F %.2F m %.2F %.2F l S",[ x1 * k, (currentPage.h - y1) * k, x2 * k, (currentPage.h - y2) * k]));
    }
    
    /**
		 * The curveTo method draws a cubic bezier curve.
		 * 
		 * @param controlX1
		 * @param controlY1
		 * @param controlX2
		 * @param controlY2
		 * @param finalX3
		 * @param finalY3
		 * @example
		 * This example shows how to draw some curves lines in the current page :
		 * <br><b>Important : Always call the end() method when you're done</b>
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.lineStyle ( new RGBColor ( 0x990000 ), 1, 1, null, CapsStyle.NONE, JointStyle.MITER );
		 * myPDF.moveTo ( 10, 200 );
		 * myPDF.curveTo ( 120, 210, 196, 280, 139, 195 );
		 * myPDF.curveTo ( 190, 110, 206, 190, 179, 205 );
		 * myPDF.end();
		 * </pre>
		 * </div>
		 */
    public function curveTo(controlX1 : Float, controlY1 : Float, controlX2 : Float, controlY2 : Float, finalX3 : Float, finalY3 : Float) : Void
    {
        write(controlX1 * k + " " + (currentPage.h - controlY1) * k + " " + controlX2 * k + " " + (currentPage.h - controlY2) * k + " " + finalX3 * k + " " + (currentPage.h - finalY3) * k + " c");
    }
    
    /**
		 * Sets the stroke style.
		 * 
		 * @param color
		 * @param thickness
		 * @param flatness
		 * @param alpha
		 * @param rule
		 * @param blendMode
		 * @param style
		 * @param caps
		 * @param joints
		 * @param miterLimit
		 * @example
		 * This example shows how to draw a star with an "even odd" rule :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.lineStyle( new RGBColor ( 0x990000 ), 1, 0, 1, Rule.EVEN_ODD, null, null, Caps.NONE, Joint.MITER );
		 * 
		 * myPDF.beginFill( new RGBColor ( 0x009900 ) );
		 * myPDF.moveTo ( 66, 10 );
		 * myPDF.lineTo ( 23, 127 );
		 * myPDF.lineTo ( 122, 50 );
		 * myPDF.lineTo ( 10, 49 );
		 * myPDF.lineTo ( 109, 127 );
		 * myPDF.end();
		 * 
		 * </pre>
		 * </div>
		 * This example shows how to draw a star with an "non-zero" winding rule :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.lineStyle( new RGBColor ( 0x990000 ), 1, 0, 1, Rule.NON_ZERO_WINDING, null, null, Caps.NONE, Joint.MITER );
		 * 
		 * myPDF.beginFill( new RGBColor ( 0x009900 ) );
		 * myPDF.moveTo ( 66, 10 );
		 * myPDF.lineTo ( 23, 127 );
		 * myPDF.lineTo ( 122, 50 );
		 * myPDF.lineTo ( 10, 49 );
		 * myPDF.lineTo ( 109, 127 );
		 * myPDF.end();
		 * 
		 * </pre>
		 * </div>
		 * 
		 */
    public function lineStyle(color : IColor, thickness : Float = 1, flatness : Float = 0, alpha : Float = 1, rule : String = "NonZeroWinding", blendMode : String = "Normal", style : DashedLine = null, caps : String = null, joints : String = null, miterLimit : Float = 3) : Void
    {
        stroking = true;
        setStrokeColor(strokeColor = color);
        strokeThickness = thickness;
        strokeAlpha = alpha;
        strokeFlatness = flatness;
        windingRule = rule;
        strokeBlendMode = blendMode;
        strokeDash = style;
        strokeCaps = caps;
        strokeJoints = joints;
        strokeMiter = miterLimit;
        setAlpha(alpha, blendMode);
        if (nbPages > 0) 
            write(Sprintf.sprintf("%.2f w",[ thickness * k]));
        write(flatness + " i ");
        write(style != (null) ? style.pattern : "[] 0 d");
        if (caps != null) 
            write(caps);
        if (joints != null) 
            write(joints);
        write(miterLimit + " M");
    }
    
    /**
		 * Sets the stroke color for different color spaces CMYK, RGB or DEVICEGRAY.
		 */
    private function setStrokeColor(color : IColor, tint : Float = 100) : Void
    {
        var op : String;
        
        if (Std.is(color, RGBColor)) 
        {
            op = "RG";
            var r : Float = (try cast(color, RGBColor) catch(e:Dynamic) null).r / 255;
            var g : Float = (try cast(color, RGBColor) catch(e:Dynamic) null).g / 255;
            var b : Float = (try cast(color, RGBColor) catch(e:Dynamic) null).b / 255;
            write(r + " " + g + " " + b + " " + op);
        }
        else if (Std.is(color, CMYKColor)) 
        {
            op = "K";
            var c : Float = (try cast(color, CMYKColor) catch(e:Dynamic) null).cyan * .01;
            var m : Float = (try cast(color, CMYKColor) catch(e:Dynamic) null).magenta * .01;
            var y : Float = (try cast(color, CMYKColor) catch(e:Dynamic) null).yellow * .01;
            var k : Float = (try cast(color, CMYKColor) catch(e:Dynamic) null).black * .01;
            write(c + " " + m + " " + y + " " + k + " " + op);
        }
        else if (Std.is(color, SpotColor)) 
        {
            var sc: SpotColor = cast color;
            if (Lambda.indexOf(spotColors, sc) == -1)
                spotColors.push(cast(color, SpotColor));
            write(Sprintf.sprintf("/CS%d CS %.3F SCN",[ (try cast(color, SpotColor) catch(e:Dynamic) null).i, tint * .01]));
        }
        else 
        {
            op = "G";
            var gray : Float = (try cast(color, GrayColor) catch(e:Dynamic) null).gray * .01;
            write(gray + " " + op);
        }
    }
    
    /**
		 * Sets the text color for different color spaces CMYK, RGB, or DEVICEGRAY.
		 * @param
		 */
    private function setTextColor(color : IColor, tint : Float = 100) : Void
    {
        var op : String;
        
        if (Std.is(color, RGBColor)) 
        {
            op = !(textRendering != 0) ? "rg" : "RG";
            var r : Float = (try cast(color, RGBColor) catch(e:Dynamic) null).r / 255;
            var g : Float = (try cast(color, RGBColor) catch(e:Dynamic) null).g / 255;
            var b : Float = (try cast(color, RGBColor) catch(e:Dynamic) null).b / 255;
            addTextColor = r + " " + g + " " + b + " " + op;
        }
        else if (Std.is(color, CMYKColor)) 
        {
            op = !(textRendering != 0) ? "k" : "K";
            var c : Float = (try cast(color, CMYKColor) catch(e:Dynamic) null).cyan * .01;
            var m : Float = (try cast(color, CMYKColor) catch(e:Dynamic) null).magenta * .01;
            var y : Float = (try cast(color, CMYKColor) catch(e:Dynamic) null).yellow * .01;
            var k : Float = (try cast(color, CMYKColor) catch(e:Dynamic) null).black * .01;
            addTextColor = c + " " + m + " " + y + " " + k + " " + op;
        }
        else if (Std.is(color, SpotColor)) 
        {
            var sc: SpotColor = cast color;
            if (Lambda.indexOf(spotColors, sc) == -1)
                spotColors.push(sc);
            addTextColor = Sprintf.sprintf("/CS%d cs %.3F scn", [(try cast(color, SpotColor) catch(e:Dynamic) null).i, tint * .01]);
            colorFlag = (fillColor != textColor);
        }
        else 
        {
            op = !(textRendering != 0) ? "g" : "G";
            var gray : Float = (try cast(color, GrayColor) catch(e:Dynamic) null).gray * .01;
            addTextColor = gray + " " + op;
        }
    }
    
    /**
		 * Sets the filling color for different color spaces CMYK, RGB or DEVICEGRAY.
		 *
		 * @param color Color object, can be CMYKColor, GrayColor, or RGBColor
		 * @example
		 * This example shows how to create a red rectangle in the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.beginFill ( new RGBColor ( 0x990000 ) );
		 * myPDF.drawRect ( new Rectangle ( 10, 26, 50, 25 ) );
		 * </pre>
		 * </div>
		 */
    public function beginFill(color : IColor, tint : Float = 100) : Void
    {
        filled = true;
        fillColor = color;
        
        var op : String;
        
        if (Std.is(color, RGBColor)) 
        {
            op = "rg";
            var r : Float = (try cast(color, RGBColor) catch(e:Dynamic) null).r / 255;
            var g : Float = (try cast(color, RGBColor) catch(e:Dynamic) null).g / 255;
            var b : Float = (try cast(color, RGBColor) catch(e:Dynamic) null).b / 255;
            write(r + " " + g + " " + b + " " + op);
        }
        else if (Std.is(color, CMYKColor)) 
        {
            op = "k";
            var c : Float = (try cast(color, CMYKColor) catch(e:Dynamic) null).cyan * .01;
            var m : Float = (try cast(color, CMYKColor) catch(e:Dynamic) null).magenta * .01;
            var y : Float = (try cast(color, CMYKColor) catch(e:Dynamic) null).yellow * .01;
            var k : Float = (try cast(color, CMYKColor) catch(e:Dynamic) null).black * .01;
            write(c + " " + m + " " + y + " " + k + " " + op);
        }
        else if (Std.is(color, SpotColor)) 
        {
            var sc: SpotColor = cast color;
            if (Lambda.indexOf(spotColors, sc) == -1)
                spotColors.push(cast(color, SpotColor));
            write(Sprintf.sprintf("/CS%d cs %.3F scn",[ (try cast(color, SpotColor) catch(e:Dynamic) null).i, tint * .01]));
            colorFlag = (fillColor != textColor);
        }
        else 
        {
            op = "g";
            var gray : Float = (try cast(color, GrayColor) catch(e:Dynamic) null).gray * .01;
            write(gray + " " + op);
        }
    }
    
    /**
		 * The beginBitmapFill method fills a surface with a bitmap as a texture.
		 * 
		 * @param bitmap A flash.display.BitmapData object
		 * @param matrix A flash.geom.Matrix object
		 * 
		 * @example
		 * This example shows how to create a 100*100 rectangle filled with a bitmap texture :
		 * <div class="listing">
		 * <pre>
		 *
		 * var texture:BitmapData = new CustomBitmapData (0,0);
		 * 
		 * myPDF.beginBitmapFill( texture );
		 * myPDF.drawRect ( new Rectangle ( 0, 0, 100, 100 ) );
		 * </pre>
		 * </div>
		 * 
		 */
    public function beginBitmapFill(bitmap : BitmapData, matrix : Matrix = null) : Void
    {
        bitmapFilled = true;
        bitmapFillBuffer = new Shape();
        bitmapFillBuffer.graphics.beginBitmapFill(bitmap, matrix);
    }
    
    /**
		 * Ends all previous filling.
		 *
		 * @example
		 * This example shows how to create a red rectangle in the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.beginFill ( new RGBColor ( 0x990000 ) );
		 * myPDF.moveTo ( 10, 10 );
		 * myPDF.lineTo ( 20, 90 );
		 * myPDF.lineTo ( 90, 50);
		 * myPDF.end()
		 * myPDF.endFill();
		 * </pre>
		 * </div>
		 */
    public function endFill() : Void
    {
        if (!bitmapFilled) 
            filled = false
        else bitmapFilled = false;
    }
    
    /**
		 * The drawRect method draws a rectangle shape.
		 * 
		 * @param rect A flash.geom.Rectange object
		 * @example
		 * This example shows how to create a blue rectangle in the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.lineStyle ( new RGBColor ( 0x990000 ), 1, .3, null, CapsStyle.ROUND, JointStyle.MITER );
		 * myPDF.beginFill ( new RGBColor ( 0x009900 ) );
		 * myPDF.drawRect ( new Rectangle ( 20, 46, 100, 45 ) );
		 * </pre>
		 * </div>
		 */
    public function drawRect(rect : Rectangle) : Void
    {
        if (!bitmapFilled) 
        {
            var style : String = getCurrentStyle();
            write(Sprintf.sprintf("%.2f %.2f %.2f %.2f re %s",[ (rect.x) * k, (currentPage.h - (rect.y)) * k, rect.width * k, -rect.height * k, style]));
            if (stroking) 
                stroking = false;
        }
        else 
        {
            bitmapFillBuffer.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
            addImage(bitmapFillBuffer, null, rect.x, rect.y, rect.width, rect.height);
        }
    }
    
    /**
		 * The drawRoundedRect method draws a rounded rectangle shape.
		 * 
		 * @param rect A flash.geom.Rectange object
		 * @param ellipseWidth Angle radius
		 * @example
		 * This example shows how to create a rounded green rectangle in the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.lineStyle ( new RGBColor ( 0x00FF00 ), 1, 0, .3, BlendMode.NORMAL, null, CapsStyle.ROUND, JointStyle.MITER );
		 * myPDF.beginFill ( new RGBColor ( 0x009900 ) );
		 * myPDF.drawRoundRect ( new Rectangle ( 20, 46, 100, 45 ), 20 );
		 * </pre>
		 * </div>
		 */
    public function drawRoundRect(rect : Rectangle, ellipseWidth : Float) : Void
    {
        if (!bitmapFilled) 
        {
            drawRoundRectComplex(rect, ellipseWidth, ellipseWidth, ellipseWidth, ellipseWidth);
            if (stroking) 
                stroking = false;
        }
        else 
        {
            bitmapFillBuffer.graphics.drawRoundRect(rect.x, rect.y, rect.width, rect.height, ellipseWidth, ellipseWidth);
            addImage(bitmapFillBuffer, null, rect.x, rect.y);
        }
    }
    
    /**
		 * The drawComplexRoundRect method draws a rounded rectangle shape.
		 * 
		 * @param rect A flash.geom.Rectange object
		 * @param topLeftEllipseWidth Angle radius
		 * @param bottomLeftEllipseWidth Angle radius
		 * @param topRightEllipseWidth Angle radius
		 * @param bottomRightEllipseWidth Angle radius
		 * 
		 * @example
		 * This example shows how to create a complex rounded green rectangle (different angles radius) in the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.lineStyle ( new RGBColor ( 0x00FF00 ), 1, 0, .3 );
		 * myPDF.beginFill ( new RGBColor ( 0x007700 ) );
		 * myPDF.drawComplexRoundRect( new Rectangle ( 5, 5, 40, 40 ), 16, 16, 8, 8 );
		 * </pre>
		 * </div>
		 * 
		 */
    public function drawRoundRectComplex(rect : Rectangle, topLeftEllipseWidth : Float, topRightEllipseWidth : Float, bottomLeftEllipseWidth : Float, bottomRightEllipseWidth : Float) : Void
    {
        if (!bitmapFilled) 
        {
            var k : Float = k;
            var hp : Float = currentPage.h;
            var MyArc : Float = 4 / 3 * (Math.sqrt(2) - 1);
            write(Sprintf.sprintf("%.2f %.2f m",[ (rect.x + topLeftEllipseWidth) * k, (hp - rect.y) * k]));
            var xc : Float = rect.x + rect.width - topRightEllipseWidth;
            var yc : Float = rect.y + topRightEllipseWidth;
            write(Sprintf.sprintf("%.2f %.2f l",[ xc * k, (hp - rect.y) * k]));
            curve(xc + topRightEllipseWidth * MyArc, yc - topRightEllipseWidth, xc + topRightEllipseWidth, yc - topRightEllipseWidth * MyArc, xc + topRightEllipseWidth, yc);
            xc = rect.x + rect.width - bottomRightEllipseWidth;
            yc = rect.y + rect.height - bottomRightEllipseWidth;
            write(Sprintf.sprintf("%.2f %.2f l",[ (rect.x + rect.width) * k, (hp - yc) * k]));
            curve(xc + bottomRightEllipseWidth, yc + bottomRightEllipseWidth * MyArc, xc + bottomRightEllipseWidth * MyArc, yc + bottomRightEllipseWidth, xc, yc + bottomRightEllipseWidth);
            xc = rect.x + bottomLeftEllipseWidth;
            yc = rect.y + rect.height - bottomLeftEllipseWidth;
            write(Sprintf.sprintf("%.2f %.2f l",[ xc * k, (hp - (rect.y + rect.height)) * k]));
            curve(xc - bottomLeftEllipseWidth * MyArc, yc + bottomLeftEllipseWidth, xc - bottomLeftEllipseWidth, yc + bottomLeftEllipseWidth * MyArc, xc - bottomLeftEllipseWidth, yc);
            xc = rect.x + topLeftEllipseWidth;
            yc = rect.y + topLeftEllipseWidth;
            write(Sprintf.sprintf("%.2f %.2f l",[ (rect.x) * k, (hp - yc) * k]));
            curve(xc - topLeftEllipseWidth, yc - topLeftEllipseWidth * MyArc, xc - topLeftEllipseWidth * MyArc, yc - topLeftEllipseWidth, xc, yc - topLeftEllipseWidth);
            var style : String = getCurrentStyle();
            write(style);
            if (stroking) 
                stroking = false;
        }
        else 
        {
            bitmapFillBuffer.graphics.drawRoundRectComplex(rect.x, rect.y, rect.width, rect.height, topLeftEllipseWidth, topRightEllipseWidth, bottomLeftEllipseWidth, bottomRightEllipseWidth);
            addImage(bitmapFillBuffer, null, rect.x, rect.y);
        }
    }
    
    /**
		 * The drawEllipse method draws an ellipse.
		 * 
		 * @param x X Position
		 * @param y Y Position
		 * @param radiusX X Radius
		 * @param radiusY Y Radius
		 * @example
		 * This example shows how to create a rounded red ellipse in the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.lineStyle ( new RGBColor ( 0x990000 ), 1, .3, new DashedLine ([0, 1, 2, 6]), CapsStyle.NONE, JointStyle.ROUND );
		 * myPDF.beginFill ( new RGBColor ( 0x990000 ) );
		 * myPDF.drawEllipse( 45, 275, 40, 15 );
		 * </pre>
		 * </div>
		 */
    public function drawEllipse(x : Float, y : Float, radiusX : Float, radiusY : Float) : Void
    {
        if (!bitmapFilled) 
        {
            var style : String = getCurrentStyle();
            
            var lx : Float = 4 / 3 * (1.41421356237309504880 - 1) * radiusX;
            var ly : Float = 4 / 3 * (1.41421356237309504880 - 1) * radiusY;
            var k : Float = k;
            var h : Float = currentPage.h;
            
            write(Sprintf.sprintf("%.2f %.2f m %.2f %.2f %.2f %.2f %.2f %.2f c",[
                            (x + radiusX) * k, (h - y) * k,
                            (x + radiusX) * k, (h - (y - ly)) * k,
                            (x + lx) * k, (h - (y - radiusY)) * k,
                            x * k, (h - (y - radiusY)) * k]));
            write(Sprintf.sprintf("%.2f %.2f %.2f %.2f %.2f %.2f c",[
                            (x - lx) * k, (h - (y - radiusY)) * k,
                            (x - radiusX) * k, (h - (y - ly)) * k,
                            (x - radiusX) * k, (h - y) * k]));
            write(Sprintf.sprintf("%.2f %.2f %.2f %.2f %.2f %.2f c",[
                            (x - radiusX) * k, (h - (y + ly)) * k,
                            (x - lx) * k, (h - (y + radiusY)) * k,
                            x * k, (h - (y + radiusY)) * k]));
            write(Sprintf.sprintf("%.2f %.2f %.2f %.2f %.2f %.2f c %s",[
                            (x + lx) * k, (h - (y + radiusY)) * k,
                            (x + radiusX) * k, (h - (y + ly)) * k,
                            (x + radiusX) * k, (h - y) * k,
                            style]));
            if (stroking) 
                stroking = false;
        }
        else 
        {
            bitmapFillBuffer.graphics.drawEllipse(x, y, radiusX, radiusY);
            addImage(bitmapFillBuffer, null, x, y);
        }
    }
    
    /**
		 * The drawCircle method draws a circle.
		 * 
		 * @param x X Position
		 * @param y Y Position
		 * @param radius Circle Radius
		 * @example
		 * This example shows how to create a rounded red ellipse in the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.beginFill ( new RGBColor ( 0x990000 ) );
		 * myPDF.drawCircle ( 30, 180, 20 );
		 * </pre>
		 * </div>
		 */
    public function drawCircle(x : Float, y : Float, radius : Float) : Void
    {
        drawEllipse(x, y, radius, radius);
    }
    
    /**
		 * The drawPolygone method draws a polygone.
		 * 
		 * @param points Array of points
		 * @example
		 * This example shows how to create a polygone with a few points :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.beginFill ( new RGBColor ( 0x990000 ) );
		 * myPDF.drawPolygone ( [89, 40, 20, 90, 40, 50, 10, 60, 70, 90] );
		 * </pre>
		 * </div>
		 */
    public function drawPolygone(points : Array<Dynamic>) : Void
    {
        var lng : Int = points.length;
        var i : Int = 0;
        var pos : Int = 0;
        
        while (i < lng)
        {
            pos = as3hx.Compat.parseInt(i + 1);
            i == (0) ? moveTo(points[i], points[pos]) : lineTo(points[i], points[pos]);
            i += 2;
        }
        
        end();
    }
    
    /**
		 * The drawSector method draws a sector, which allows you to draw a pie chart.
		 * 
		 * @param xCenter
		 * @param yCenter
		 * @param radius
		 * @param a
		 * @param b
		 * @param style
		 * @param clockWise
		 * @param angleOrigin
		 * @example
		 * This example shows how to create a nice pie chart :
		 * <div class="listing">
		 * <pre>
		 *
		 * var xc:int = 105;
		 * var yc:int = 60;
		 * var radius:int = 40;
		 * 
		 * myPDF.lineStyle( new RGBColor ( 0x000000 ), .1 );
		 * myPDF.beginFill( new RGBColor ( 0x0099CC ) );
		 * myPDF.drawSector(xc, yc, radius, 20, 120);
		 * myPDF.beginFill( new RGBColor ( 0x336699 ) );
		 * myPDF.drawSector(xc, yc, radius, 120, 250);
		 * myPDF.beginFill( new RGBColor ( 0x6598FF ) );
		 * myPDF.drawSector(xc, yc, radius, 250, 20);
		 * </pre>
		 * </div>
		 */
    public function drawSector(xCenter : Float, yCenter : Float, radius : Float, a : Float, b : Float, style : String = "FD", clockWise : Bool = true, angleOrigin : Float = 90) : Void
    {
        var d0 : Float = a - b;
        var d : Float;
        var op : String;
        
        if (clockWise) 
        {
            d = b;
            b = angleOrigin - a;
            a = angleOrigin - d;
        }
        else 
        {
            b += angleOrigin;
            a += angleOrigin;
        }
        
        while (a < 0)
        a += 360;
        while (a > 360)
        a -= 360;
        while (b < 0)
        b += 360;
        while (b > 360)
        b -= 360;
        
        if (a > b) 
            b += 360;
        
        b = b / 360 * 2 * Math.PI;
        a = a / 360 * 2 * Math.PI;
        d = b - a;
        
        if (d == 0 && d0 != 0) 
            d = 2 * Math.PI;
        
        var hp : Float = currentPage.h;
        var myArc : Float;
        
        if (Math.sin(d / 2) != 0)
            myArc = 4 / 3 * (1 - Math.cos(d / 2)) / Math.sin(d / 2) * radius
        else 
        myArc = 0;
        
        //first put the center
        write(Sprintf.sprintf("%.2F %.2F m",[ (xCenter) * k, (hp - yCenter) * k]));
        //put the first point
        write(Sprintf.sprintf("%.2F %.2F l",[ (xCenter + radius * Math.cos(a)) * k, ((hp - (yCenter - radius * Math.sin(a))) * k)] ));
        
        //draw the arc
        if (d < Math.PI / 2) 
        {
            arc(xCenter + radius * Math.cos(a) + myArc * Math.cos(Math.PI / 2 + a),
                    yCenter - radius * Math.sin(a) - myArc * Math.sin(Math.PI / 2 + a),
                    xCenter + radius * Math.cos(b) + myArc * Math.cos(b - Math.PI / 2),
                    yCenter - radius * Math.sin(b) - myArc * Math.sin(b - Math.PI / 2),
                    xCenter + radius * Math.cos(b),
                    yCenter - radius * Math.sin(b)
                    );
        }
        else 
        {
            b = a + d / 4;
            myArc = 4 / 3 * (1 - Math.cos(d / 8)) / Math.sin(d / 8) * radius;
            arc(xCenter + radius * Math.cos(a) + myArc * Math.cos(Math.PI / 2 + a),
                    yCenter - radius * Math.sin(a) - myArc * Math.sin(Math.PI / 2 + a),
                    xCenter + radius * Math.cos(b) + myArc * Math.cos(b - Math.PI / 2),
                    yCenter - radius * Math.sin(b) - myArc * Math.sin(b - Math.PI / 2),
                    xCenter + radius * Math.cos(b),
                    yCenter - radius * Math.sin(b)
                    );
            a = b;
            b = a + d / 4;
            arc(xCenter + radius * Math.cos(a) + myArc * Math.cos(Math.PI / 2 + a),
                    yCenter - radius * Math.sin(a) - myArc * Math.sin(Math.PI / 2 + a),
                    xCenter + radius * Math.cos(b) + myArc * Math.cos(b - Math.PI / 2),
                    yCenter - radius * Math.sin(b) - myArc * Math.sin(b - Math.PI / 2),
                    xCenter + radius * Math.cos(b),
                    yCenter - radius * Math.sin(b)
                    );
            a = b;
            b = a + d / 4;
            arc(xCenter + radius * Math.cos(a) + myArc * Math.cos(Math.PI / 2 + a),
                    yCenter - radius * Math.sin(a) - myArc * Math.sin(Math.PI / 2 + a),
                    xCenter + radius * Math.cos(b) + myArc * Math.cos(b - Math.PI / 2),
                    yCenter - radius * Math.sin(b) - myArc * Math.sin(b - Math.PI / 2),
                    xCenter + radius * Math.cos(b),
                    yCenter - radius * Math.sin(b)
                    );
            a = b;
            b = a + d / 4;
            arc(xCenter + radius * Math.cos(a) + myArc * Math.cos(Math.PI / 2 + a),
                    yCenter - radius * Math.sin(a) - myArc * Math.sin(Math.PI / 2 + a),
                    xCenter + radius * Math.cos(b) + myArc * Math.cos(b - Math.PI / 2),
                    yCenter - radius * Math.sin(b) - myArc * Math.sin(b - Math.PI / 2),
                    xCenter + radius * Math.cos(b),
                    yCenter - radius * Math.sin(b)
                    );
        }  //terminate drawing  
        
        
        
        if (style == SectorDrawingCommand.FILL) 
            op = "f"
        else if (style == SectorDrawingCommand.FILL_DRAW || style == SectorDrawingCommand.DRAW_FILL) 
            op = "b"
        else op = "s";
        
        write(op);
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF Gradient API
		* linearGradient()
		* radialGradient()
		*
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public function linearGradient(x : Float, y : Float, width : Float, height : Float, col1 : Array<Dynamic>, col2 : Array<Dynamic>, coordinates : Array<Dynamic>) : Void
    {
        clip(x, y, width, height);
        gradient(2, col1, col2, coordinates);
    }
    
    public function radialGradient(x : Float, y : Float, width : Float, height : Float, col1 : Array<Dynamic>, col2 : Array<Dynamic>, coordinates : Array<Dynamic>) : Void
    {
        clip(x, y, width, height);
        gradient(3, col1, col2, coordinates);
    }
    
    public function clip(x : Float, y : Float, width : Float, height : Float) : Void
    {
        var s : String = "q";
        s += Sprintf.sprintf(" %.2F %.2F %.2F %.2F re W n",[ x * k, (currentPage.h - y) * k, width * k, -height * k]);
        s += Sprintf.sprintf(" %.3F 0 0 %.3F %.3F %.3F cm",[ width * k, height * k, x * k, (currentPage.h - (y + height)) * k]);
        write(s);
    }
    
    private function gradient(gradientType : Int, col1 : Array<Dynamic>, col2 : Array<Dynamic>, coords : Array<Dynamic>) : Void
    {
        var n : Int = gradients.length + 1;
        if (col1[1] == null) 
            col1[1] = col1[2] = col1[0];
        var colBuffer1 : String = Sprintf.sprintf("%.3F %.3F %.3F", [(col1[0] / 255), (col1[1] / 255), (col1[2] / 255)]);
        if (col2[1] == null) 
            col2[1] = col2[2] = col2[0];
        var colBuffer2 : String = Sprintf.sprintf("%.3F %.3F %.3F", [(col2[0] / 255), (col2[1] / 255), (col2[2] / 255)]);
        var gradient : ShadingType = gradients[n] = new ShadingType(gradientType, coords, colBuffer1, colBuffer2);
        write("/Sh" + n + " sh");
        write("Q");
    }
    
    private function insertShaders() : Void
    {
        var coords : Array<Dynamic>;
        var f1 : Int = 0;
        
        for (grad in gradients)
        {
            coords = grad.coords;
            
            if (grad.type == ShadingType.TYPE2 || grad.type == ShadingType.TYPE3) 
            {
                newObj();
                write("<<");
                write("/FunctionType 2");
                write("/Domain [0.0 1.0]");
                write("/C0 [" + grad.col1 + "]");
                write("/C1 [" + grad.col2 + "]");
                write("/N 1");
                write(">>");
                write("endobj");
                f1 = n;
            }
            
            newObj();
            write("<<");
            write("/ShadingType " + grad.type);
            write("/ColorSpace /DeviceRGB");
            
            if (grad.type == ShadingType.TYPE2) 
            {
                write(Sprintf.sprintf("/Coords [%.3F %.3F %.3F %.3F]", [coords[0], coords[1], coords[2], coords[3]]));
                write("/Function " + f1 + " 0 R");
                write("/Extend [true true] ");
                write(">>");
            }
            else if (grad.type == ShadingType.TYPE3) 
            {
                write(Sprintf.sprintf("/Coords [%.3F %.3F 0 %.3F %.3F %.3F]", [coords[0], coords[1], coords[2], coords[3], coords[4]]));
                write("/Function " + f1 + " 0 R");
                write("/Extend [true true] ");
                write(">>");
            }
            else if (grad.type == ShadingType.TYPE6) 
            {
                write("/BitsPerCoordinate 16");
                write("/BitsPerComponent 8");
                write("/Decode[0 1 0 1 0 1 0 1 0 1]");
                write("/BitsPerFlag 8");
                write("/Length " + grad.stream.length);
                write(">>");
                buffer.writeBytes(grad.stream);
            }
            write("endobj");
            grad.id = n;
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF clipping API
		*
		* clippingText()
		* clippingRect()
		* clippingRoundedRect()
		* clippingEllipse()
		* clippingCircle()
		* clippingPolygon()
		*
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public function clippingText(x : Float, y : Float, text : String, outline : Bool = false) : Void
    {
        var op : Int = (outline) ? 5 : 7;
        write(Sprintf.sprintf("q BT %.2F %.2F Td %d Tr (%s) Tj ET",
                        [x * k,
                        (currentPage.h - y) * k,
                        op,
                        escapeIt(text)]));
    }
    
    public function clippingRect(x : Float, y : Float, width : Float, height : Float, outline : Bool = false) : Void
    {
        var op : String = (outline) ? "S" : "n";
        write(Sprintf.sprintf("q %.2F %.2F %.2F %.2F re W %s",[
                        x * k,
                        (currentPage.h - y - height) * k,
                        width * k, height * k,
                        op]));
    }
    
    private function arc(x1 : Float, y1 : Float, x2 : Float, y2 : Float, x3 : Float, y3 : Float) : Void
    {
        var h : Float = currentPage.h;
        write(Sprintf.sprintf("%.2F %.2F %.2F %.2F %.2F %.2F c ",[ x1 * k, (h - y1) * k,
                        x2 * k, (h - y2) * k, x3 * k, (h - y3) * k]));
    }
    
    public function clippingRoundedRect(x : Float, y : Float, width : Float, height : Float, radius : Float, outline : Bool = false) : Void
    {
        var hp : Float = currentPage.h;
        var op : String = (outline) ? "S" : "n";
        
        var myArc : Float = 4 / 3 * (Math.sqrt(2) - 1);
        
        write(Sprintf.sprintf("q %.2F %.2F m",[ (x + radius) * k, (hp - y) * k]));
        var xc : Float = x + width - radius;
        var yc : Float = y + radius;
        write(Sprintf.sprintf("%.2F %.2F l",[ xc * k, (hp - y) * k]));
        arc(xc + radius * myArc, yc - radius, xc + radius, yc - radius * myArc, xc + radius, yc);
        xc = x + width - radius;
        yc = y + height - radius;
        write(Sprintf.sprintf("%.2F %.2F l",[ (x + width) * k, (hp - yc) * k]));
        arc(xc + radius, yc + radius * myArc, xc + radius * myArc, yc + radius, xc, yc + radius);
        xc = x + radius;
        yc = y + height - radius;
        write(Sprintf.sprintf("%.2F %.2F l",[ xc * k, (hp - (y + height)) * k]));
        arc(xc - radius * myArc, yc + radius, xc - radius, yc + radius * myArc, xc - radius, yc);
        xc = x + radius;
        yc = y + radius;
        write(Sprintf.sprintf("%.2F %.2F l",[ (x) * k, (hp - yc) * k]));
        arc(xc - radius, yc - radius * myArc, xc - radius * myArc, yc - radius, xc, yc - radius);
        write(" W " + op);
    }
    
    public function clippingEllipse(x : Float, y : Float, ty : Float, ry : Float, outline : Bool = false) : Void
    {
        var op : String = (outline) ? "S" : "n";
        var lx : Float = 4 / 3 * (1.41421356237309504880 - 1) * ty;
        var ly : Float = 4 / 3 * (1.41421356237309504880 - 1) * ry;
        var k : Float = k;
        var h : Float = currentPage.h;
        
        write(Sprintf.sprintf("q %.2F %.2F m %.2F %.2F %.2F %.2F %.2F %.2F c",[
                        (x + ty) * k, (h - y) * k,
                        (x + ty) * k, (h - (y - ly)) * k,
                        (x + lx) * k, (h - (y - ry)) * k,
                        x * k, (h - (y - ry)) * k]));
        write(Sprintf.sprintf("%.2F %.2F %.2F %.2F %.2F %.2F c",[
                        (x - lx) * k, (h - (y - ry)) * k,
                        (x - ty) * k, (h - (y - ly)) * k,
                        (x - ty) * k, (h - y) * k]));
        write(Sprintf.sprintf("%.2F %.2F %.2F %.2F %.2F %.2F c",[
                        (x - ty) * k, (h - (y + ly)) * k,
                        (x - lx) * k, (h - (y + ry)) * k,
                        x * k, (h - (y + ry)) * k]));
        write(Sprintf.sprintf("%.2F %.2F %.2F %.2F %.2F %.2F c W %s",[
                        (x + lx) * k, (h - (y + ry)) * k,
                        (x + ty) * k, (h - (y + ly)) * k,
                        (x + ty) * k, (h - y) * k,
                        op]));
    }
    
    public function clippingCircle(x : Float, y : Float, radius : Float, outline : Bool = false) : Void
    {
        clippingEllipse(x, y, radius, radius, outline);
    }
    
    public function clippingPolygon(points : Array<Dynamic>, outline : Bool = false) : Void
    {
        var op : String = (outline) ? "S" : "n";
        var h : Float = currentPage.h;
        var k : Float = k;
        var points_string : String = "";
        
        var i : Int = 0;
        while (i < points.length){
            points_string += Sprintf.sprintf("%.2F %.2F", [points[i] * k, (h - points[as3hx.Compat.parseInt(i + 1)]) * k]);
            if (i == 0) 
                points_string += " m "
            else 
            points_string += " l ";
            i += 2;
        }
        
        write("q " + points_string + "h W " + op);
    }
    
    public function unsetClipping() : Void
    {
        write("Q");
    }
    
    public function clippedCell(width : Float, height : Float = 0, text : String = "", border : Dynamic = 0, ln : Float = 0, align : String = "", fill : Float = 0, link : ILink = null) : Void
    {
        if (border != null || fill != 0 || currentY + height > pageBreakTrigger) 
        {
            addCell(width, height, "", border, 0, "", fill);
            currentX -= width;
        }
        clippingRect(currentX, currentY, width, height);
        addCell(width, height, text, "", ln, align, fill, link);
        unsetClipping();
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF BarCodde API
		*
		* addCodaBar()
		*
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
		 * Allows you to add a CodaBar (Monarch) to the current page at any position.
		 * @param codaBar
		 
		 * This example shows how to add a CodaBar to the current page at position of 20, 20 :
		 * <div class="listing">
		 * <pre>
		 * 
		 * var barCode:CodaBar = new CodaBar ( 20, 20, "0123456789" );
		 * myPDF.addCodaBar( barCode );
		 * </pre>
		 * </div>
		 */
    public function addCodaBar(codaBar : CodaBar) : Void
    {
        setFont(CoreFontCache.getFont(FontFamily.ARIAL));
        addText(codaBar.code, codaBar.x, codaBar.y + codaBar.height + 4);
        lineStyle(RGBColorCache.getColor("0x000000"), 0, 0, 1);
        beginFill(RGBColorCache.getColor("0x000000"));
        
        var code : String = (codaBar.start + codaBar.code + codaBar.end).toUpperCase();
        var char : String;
        var seq : Array<Dynamic>;
        var barChar : Map<Dynamic, Dynamic>;
        var lineWidth : Float = 0;
        var lng : Int = 0x7;
        var lngCode : Int = code.length;
        var rect : Rectangle = new Rectangle(codaBar.x, codaBar.y, lineWidth, codaBar.height);
        
        for (i in 0...lngCode){
            barChar = codaBar.barChar;
            char = code.charAt(i);
            
            if (Reflect.field(barChar, char) == null) 
                throw new Error("Invalid character in barcode: " + char);
            
            seq = Reflect.field(barChar, char);
            
            for (j in 0...lng){
                lineWidth = codaBar.baseWidth * seq[j] / 6.5;
                
                if ((j & 1) == 0) 
                {
                    rect.width = lineWidth;
                    rect.x = codaBar.x;
                    drawRect(rect);
                }
                codaBar.x += lineWidth;
            }
            codaBar.x += codaBar.baseWidth * 10.4 / 6.5;
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF Visibility API
		*
		* setVisible()
		*
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public function setVisible(visible : String) : Void
    {
        if (visibility != Visibility.ALL) 
            write("EMC");
        if (visible == Visibility.PRINT) 
            write("/OC /OC1 BDC")
        else if (visible == Visibility.SCREEN) 
            write("/OC /OC2 BDC")
        else if (visible != Visibility.ALL) 
            throw new Error("Incorrect visibility: " + visible);
        visibility = visible;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF Interactive API
		*
		* addAnnotation()
		* addTransition()
		* addBookmark()
		* addLink()
		*
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
		 * Lets you add an annotation to the current page
		 * @param annotation
		 * 
		 * This example shows how to add an annotation for the current page :
		 * <div class="listing">
		 * <pre>
		 * 
		 * var annotation:Annotation = new TextAnnotation ( AnnotationType.TEXT, "This is a text annotation!", 20, 20, 100, 100 );
		 * myPDF.addAnnotation( annotation );
		 * </pre>
		 * </div>
		 */
    public function addAnnotation(annotation : Annotation) : Void
    {
        var rectangle : String = annotation.x * k + " " + (((currentPage.h - annotation.y) * k) - (annotation.height * k)) + " " + ((annotation.x * k) + (annotation.width * k)) + " " + (currentPage.h - annotation.y) * k;
        
        if (Std.is(annotation, TextAnnotation)) 
        {
            var textAnnotation : TextAnnotation = try cast(annotation, TextAnnotation) catch(e:Dynamic) null;
            currentPage.annotations += ("<</Type /Annot /Border [0 0 1] /Subtype /" + textAnnotation.type + " /Contents " + escapeString(textAnnotation.text) + " /Rect [ " + rectangle + " ]>>");
        }
        else if (Std.is(annotation, MovieAnnotation)) 
        {
            var movieAnnotation : MovieAnnotation = try cast(annotation, MovieAnnotation) catch(e:Dynamic) null;
            currentPage.annotations += ("<</Type /Annot /Border [0 0 1] /Subtype /" + movieAnnotation.type + " /Contents " + escapeString(movieAnnotation.text) + " /Rect [ " + rectangle + " ]>>");
        }
    }
    
    /**
		 * Lets you add a bookmark.
		 * Note : Multiple calls will create a nice table.
		 *
		 * @param text Text appearing in the outline panel
		 * @param level Specify the bookmark's level
		 * @param y Position in the current page to go
		 * @param color RGBColor object
		 * @example
		 * This example shows how to add a bookmark for the current page just added :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addPage();
		 * myPDF.addBookmark("A page bookmark");
		 * </pre>
		 * </div>
		 * 
		 * This example shows how to add a bookmark with a specific color (red) for the current page just added :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addPage();
		 * myPDF.addBookmark("A page bookmark", 0, 0, new RGBColor ( 0x990000 ) );
		 * </pre>
		 * </div>
		 * 
		 * You can also add sublevel bookmarks with the following code, using the level parameter :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addPage();
		 * myPDF.addBookmark("Page 1", 0, 0, new RGBColor ( 0x990000 ) );
		 * myPDF.addBookmark("Page 1 sublink", 1, 0, new RGBColor ( 0x990000 ) );
		 * </pre>
		 * </div>
		 */
    public function addBookmark(text : String, level : Int = 0, y : Float = -1, color : RGBColor = null) : Void
    {
        if (color == null) 
            color = RGBColorCache.getColor("0x000000");
        if (y == -1) 
            y = getY();
        outlines.push(new Outline(text, level, nbPages, y, color.r, color.g, color.b));
    }
    
    /**
		 * Lets you add clickable link to a specific position
		 * Link can be internal (document level navigation) or external (HTTP).
		 *
		 * @param x Page Format, can be Size.A3, Size.A4, Size.A5, Size.LETTER or Size.LEGAL
		 * @param y
		 * @param width
		 * @param height
		 * @param link
		 * @param highlight
		 * @example
		 * This example shows how to add an invisible clickable HTTP link in the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addLink ( 70, 4, 60, 16, new HTTPLink ("http://www.alivepdf.org") );
		 * </pre>
		 * </div>
		 * 
		 * This example shows how to add an invisible clickable internal link (document level navigation) in the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addLink ( 70, 4, 60, 16, new InternalLink (2, 10) );
		 * </pre>
		 * </div>
		 * 
		 * By default, the link highlight mode (when the mouse is pressed over the link) is inverted.
		 * This example shows how change the visual state of the link when pressed :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addLink ( 70, 4, 60, 16, new InternalLink (2, 10), Highlight.OUTLINE );
		 * </pre>
		 * </div>
		 * 
		 * To make the link invisible even when clicked, just pass Highlight.NONE as below :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addLink ( 70, 4, 60, 16, new InternalLink (2, 10), Highlight.NONE );
		 * </pre>
		 * </div>
		 */
    public function addLink(x : Float, y : Float, width : Float, height : Float, link : ILink, highlight : String = "I") : Void
    {
        var rectangle : String = x * k + " " + (currentPage.h - y - height) * k + " " + (x + width) * k + " " + (currentPage.h - y) * k;
        
        currentPage.annotations += "<</Type /Annot /Subtype /Link /Rect [" + rectangle + "] /Border [0 0 0] /H /" + highlight + " ";
        
        if (Std.is(link, HTTPLink)) 
            currentPage.annotations += "/A <</S /URI /URI " + escapeString((try cast(link, HTTPLink) catch(e:Dynamic) null).link) + ">>>>"
        else 
        {
            var currentLink : InternalLink = try cast(link, InternalLink) catch(e:Dynamic) null;
            var h : Float = orientationChanges[currentLink.page] != (null) ? currentPage.wPt : currentPage.hPt;
            
            if (currentLink.rectangle != null) 
                currentPage.annotations += Sprintf.sprintf("/Dest [%d 0 R /FitR %.2f %.2f %.2f %.2f]>>", [1 + 2 * currentLink.page, currentLink.rectangle.x * k, (currentPage.h - currentLink.rectangle.y - currentLink.rectangle.height) * k, (currentLink.rectangle.x + currentLink.rectangle.width) * k, (currentPage.h - currentLink.rectangle.y) * k])
            else if (!currentLink.fit) 
                currentPage.annotations += Sprintf.sprintf("/Dest [%d 0 R /XYZ 0 %.2f null]>>", [1 + 2 * currentLink.page, (currentPage.h - currentLink.y) * k])
            else if (currentLink.fit)                 currentPage.annotations += Sprintf.sprintf("/Dest [%d 0 R /Fit]>>", [1 + 2 * currentLink.page]);
        }
    }
    
    /**
		 * Returns an InternalLink object linked to the current page at the current Y in the page.
		 * 
		 * @return InternalLink
		 * @example
		 * This example shows how to add an internal link using the getInternalLink method :
		 * <div class="listing">
		 * <pre>
		 *
		 * var link:InternalLink = myPDF.getCurrentInternalLink();
		 * myPDF.gotoPage(3);	
		 * myPDF.addCell(40, 8, "Here is a link to another page", 0, 0, "", 0, link);		
		 * </pre>
		 * </div>
		 */
    public function getCurrentInternalLink() : InternalLink
    {
        return new InternalLink(totalPages, currentY);
    }
    
    /**
		 * Lets you add a transition between each PDF page
		 * Note : PDF must be shown in fullscreen to see the transitions, use the setDisplayMode method with the PageMode.FULL_SCREEN parameter.
		 * 
		 * @param style Transition style, can be Transition.SPLIT, Transition.BLINDS, BLINDS.BOX, Transition.WIPE, etc.
		 * @param duration The transition duration
		 * @param dimension The dimension in which the the specified transition effect occurs
		 * @param motionDirection The motion's direction for the specified transition effect
		 * @param transitionDirection The direction in which the specified transition effect moves
		 * @example
		 * This example shows how to add a 4 seconds "Wipe" transition between the first and second page :
		 * <div class="listing">
		 * <pre> 
		 * myPDF.addPage();  
		 * myPDF.addTransition (Transition.WIPE, 4, Dimension.VERTICAL);
		 * </pre>
		 * </div>
		 */
    public function addTransition(style : String = "R", duration : Float = 1, dimension : String = "H", motionDirection : String = "I", transitionDirection : Int = 0) : Void
    {
        currentPage.addTransition(style, duration, dimension, motionDirection, transitionDirection);
    }
    
    /**
		 * Lets you control the way the document is to be presented on the screen or in print.
		 * Note : Very useful to hide any window when the PDF is opened.
		 *
		 * @param toolbar Toolbar behavior
		 * @param menubar Menubar behavior
		 * @param windowUI WindowUI behavior
		 * @param fitWindow Specify whether to resize the document's window to fit the size of the first displayed page.
		 * @param centeredWindow Specify whether to position the document's window in the center of the screen.
		 * @param displayTitle Specify whether the window's title bar should display the document title taken from the value passed to the setTitle method
		 * @example
		 * This example shows how to present the document centered on the screen with no toolbars :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setViewerPreferences (ToolBar.HIDE, MenuBar.HIDE, WindowUI.HIDE, FitWindow.DEFAULT, CenterWindow.CENTERED);
		 * </pre>
		 * </div>
		 */
    public function setViewerPreferences(toolbar : String = "false", menubar : String = "false", windowUI : String = "false", fitWindow : String = "false", centeredWindow : String = "false", displayTitle : String = "false") : Void
    {
        viewerPreferences = "<< /HideToolbar " + toolbar + " /HideMenubar " + menubar + " /HideWindowUI " + windowUI + " /FitWindow " + fitWindow + " /CenterWindow " + centeredWindow + " /DisplayDocTitle " + displayTitle + " >>";
    }
    
    /**
		 * Lets you specify which page should be viewed by default when the document is opened.
		 * Note : This method must be called once all the pages have been created and added through addPage().
		 *
		 * @param index Page number
		 * @example
		 * This example shows how to sepcify the second page to be viewed by default :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setStartingPage (2);
		 * </pre>
		 * </div>
		 */
    public function setStartingPage(index : Int) : Void
    {
        var lng : Int = arrayPages.length;
        if (index > 0 && index <= lng) 
            startingPageIndex = index - 1
        else throw new RangeError("Can't set page " + index + ". " + lng + " page(s) available.");
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF printing API
		*
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private function insertSpotColors() : Void
    {
        for (color in spotColors)
        {
            newObj();
            write("[/Separation /" + findAndReplace(" ", "#20", color.name));
            write("/DeviceCMYK <<");
            write("/Range [0 1 0 1 0 1 0 1] /C0 [0 0 0 0] ");
            write(Sprintf.sprintf("/C1 [%.3F %.3F %.3F %.3F] ",[ color.color.cyan * .01, color.color.magenta * .01, color.color.yellow * .01, color.color.black * .01]));
            write("/FunctionType 2 /Domain [0 1] /N 1>>]");
            write("endobj");
            color.n = n;
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF font API
		*
		* addFont()
		* removeFont()
		* setFont()
		* setFontSize()
		* getTotalFonts()
		* totalFonts
		*
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private function addFont(font : IFont) : IFont
    {
        pushedFontName = font.name;
        
        if (Lambda.count(fonts, findFont) <= 0)
            fonts.push(font);
        
        font.id = fonts.length;
        
        fontFamily = font.name;
        
        var addedFont : EmbeddedFont;
        
        if (Std.is(font, EmbeddedFont)) 
        {
            addedFont = try cast(font, EmbeddedFont) catch(e:Dynamic) null;
            
            if (addedFont.differences != null) 
            {
                d = -1;
                nb = differences.length;
                for (j in 0...nb){
                    if (differences[j] == addedFont.differences) 
                    {
                        d = j;
                        break;
                    }
                }
                
                if (d == -1) 
                {
                    d = nb;
                    differences[d] = addedFont.differences;
                }
                
               addedFont.differencesIndex = d;
            }
        }
        return font;
    }
    
    private function findFont(element : IFont) : Bool
    {
        return element.name == pushedFontName;
    }
    
    /**
		 * Lets you set a specific font.
		 * Note : Since release 0.1.5, you do not need to call the addFont method anymore. It will be called automatically internally if needed.
		 *
		 * @param A font, can be a core font (org.alivepdf.fonts.CoreFont), or an embedded font (org.alivepdf.fonts.EmbeddedFont)
		 * @param size Any font size
		 * @param underlined if text should be underlined
		 * @example
		 * This example shows how to set the Helvetica font, with a bold style :
		 * <div class="listing">
		 * <pre>
		 *
		 * var font:CoreFont = CoreFontCache.getFont ( FontFamily.HELVETICA_BOLD );
		 * myPDF.setFont( font );
		 * </pre>
		 * </div>
		 */
    public function setFont(font : IFont, size : Int = 12, underlined : Bool = false) : Void
    {
        pushedFontName = font.name;
        
        var result : Array<Dynamic> = fonts.filter(findFont);
        currentFont = result.length > (0) ? result[0] : addFont(font);
        
        underline = underlined;
        fontFamily = currentFont.name;
        fontSizePt = size;
        fontSize = size / k;
        
        if (nbPages > 0) 
            write(Sprintf.sprintf("BT /F%d %.2f Tf ET", [currentFont.id, fontSizePt]));
    }
    
    /**
		 * Lets you set a new size for the current font.
		 *
		 * @param size Font size
		 * @example
		 * This example shows how to se the current font to 18 :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setFontSize( 18 );
		 * </pre>
		 * </div>
		 */
    public function setFontSize(size : Int) : Void
    {
        if (fontSizePt == size) 
            return;
        fontSizePt = size;
        fontSize = size / k;
        if (nbPages > 0) 
            write(Sprintf.sprintf("BT /F%d %.2f Tf ET",[ currentFont.id, fontSizePt]));
    }
    
    /**
		 * Lets you remove an embedded font from the PDF.
		 *
		 * @param font The embedded font
		 * @example
		 * This example shows how to remove an embedded font :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.removeFont( myEmbeddedFont );
		 * </pre>
		 * </div>
		 */
    public function removeFont(font : IFont) : Void
    {
        if (!(Std.is(font.type, EmbeddedFont))) 
            throw new Error("The font you have passed is a Core font. Core fonts cannot be removed as they are not embedded in the PDF.");
        var position : Int = Lambda.indexOf(fonts, font);
        if (position != -1) 
            fonts.splice(position, 1)
        else throw new Error("Font cannot be found.");
    }
    
    /**
		 * Lets you retrieve the total number of fonts used in the PDF document.
		 *
		 * @return int Number of fonts (embedded or not) used in the PDF
		 * @example
		 * This example shows how to retrieve the number of fonts used in the PDF document :
		 * <div class="listing">
		 * <pre>
		 *
		 * var totalFonts:int = myPDF.totalFonts;
		 * </pre>
		 * </div>
		 */
    private function get_totalFonts() : Int
    {
        return fonts.length;
    }
    
    /**
		 * Lets you retrieve the fonts used in the PDF document.
		 *
		 * @return Array An Array of fonts objects (CoreFont, EmbeddedFont)
		 * @example
		 * This example shows how to retrieve the fonts :
		 * <div class="listing">
		 * <pre>
		 *
		 * var fonts:Array = myPDF.getFonts();
		 * </pre>
		 * </div>
		 */
    public function getFonts() : Array<Dynamic>
    {
        return fonts;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF text API
		*
		* addText()
		* textStyle()
		* addCell()
		* addCellFitScale()
		* addCellFitScaleForce()
		* addCellFitSpace()
		* addCellFitSpaceForce()
		* addMultiCell()
		* writeText()
		*
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
		 * Lets you set some text to any position on the page.
		 * Note : addText is a low level method which does not handle line returns and paragraph requirements. Use writeText for that or writeFlashHtmlText if you need HTML on top of that.
		 *
		 * @param text The text to add
		 * @param x X position
		 * @param y Y position
		 * @example
		 * This example shows how to set some text to a specific place :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addText ('Some simple text added !', 14, 110);
		 * </pre>
		 * </div>
		 */
    public function addText(text : String, x : Float = 0, y : Float = 0) : Void
    {
        var s : String = Sprintf.sprintf("BT %.2f %.2f Td (%s) Tj ET", [x * k, (currentPage.h - y) * k, escapeIt(text)]);
        if (underline && text != "") 
            s += " " + doUnderline(x, y, text);
        if (colorFlag) 
            s = "q " + addTextColor + " " + s + " Q";
        write(s);
    }
    
    /**
		 * Sets the text style with an appropriate color, alpha etc.
		 *
		 * @param color Color object, can be CMYKColor, GrayColor, or RGBColor
		 * @param alpha Text opacity
		 * @param rendering pRendering Specify the text rendering mode
		 * @param wordSpace Spaces between each words
		 * @param characterSpace Spaces between each characters
		 * @param scale Text scaling
		 * @param leading Text leading
		 * @example
		 * This example shows how to set a specific black text style with full opacity :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.textStyle ( new RGBColor ( 0x000000 ), 1 ); 
		 * </pre>
		 * </div>
		 */
    public function textStyle(color : IColor, alpha : Float = 1, rendering : Int = 0, wordSpace : Float = 0, characterSpace : Float = 0, scale : Float = 100, leading : Float = 0) : Void
    {
        textColor = color;
        textAlpha = alpha;
        textWordSpace = wordSpace;
        textSpace = characterSpace;
        textScale = scale;
        textLeading = leading;
        
        write(Sprintf.sprintf("%d Tr", [textRendering = rendering]));
        setTextColor(color);
        setAlpha(alpha);
        write(wordSpace + " Tw " + characterSpace + " Tc " + scale + " Tz " + leading + " TL ");
        colorFlag = ((cast fillColor) != addTextColor);
    }
    
    /**
		 * Add a cell with some text to the current page.
		 *
		 * @param width Cell width
		 * @param height Cell height
		 * @param text Text to add into the cell
		 * @param ln Sets the new position after cell is drawn, default value is 0
		 * @param align Lets you center or align the text into the cell
		 * @param fill Lets you specify if the cell is colored (1) or transparent (0)
		 * @param link Link can be internal to do document level navigation (InternalLink) or external (HTTPLink)
		 * @return Page
		 * @example
		 * This example shows how to write some text within a cell :
		 * <div class="listing">
		 * <pre>
		 *
		 * var font:CoreFont = CoreFontCache.getFont ( FontFamily.HELVETICA_BOLD );
		 * myPDF.setFont( font );
		 * myPDF.textStyle ( new RGBColor ( 0x990000 ) );
		 * myPDF.addCell(50, 10, 'Some text into a cell !', 1, 1);
		 * </pre>
		 * </div>
		 * 
		 * This example shows how to write some clickable text within a cell :
		 * <div class="listing">
		 * <pre>
		 *
		 * var font:CoreFont = CoreFontCache.getFont ( FontFamily.HELVETICA_BOLD );
		 * myPDF.setFont( font );
		 * myPDF.textStyle ( new RGBColor ( 0x990000 ) );
		 * myPDF.addCell(50, 10, 'A clickable cell !', 1, 1, null, 0, new HTTPLink ("http://www.alivepdf.org") );
		 * </pre>
		 * </div>
		 */
    public function addCell(width : Float = 0, height : Float = 0, text : String = "", border : Dynamic = 0, ln : Float = 0, align : String = "", fill : Float = 0, link : ILink = null,
        column: GridColumn = null) : Void
    {
        if (currentY + height > pageBreakTrigger && !inHeader && !inFooter && acceptPageBreak()) 
        {
            var x : Float = currentX;
            
            if (ws > 0) 
            {
                ws = 0;
                write("0 Tw");
            }
            
            addPage(new Page(currentOrientation, defaultUnit, defaultSize, currentPage.rotation));
            currentX = x;
            
            if (ws > 0) 
                write(Sprintf.sprintf("%.3f Tw", [ws * k]));
        }
        
        if (currentPage.w == 0) 
            currentPage.w = currentPage.w - rightMargin - currentX;
        
        var s : String = "";
        var op : String;
        
        if (fill == 1 || border == 1) 
        {
            if (fill == 1) 
                op = ((border == 1)) ? Drawing.FILL_AND_STROKE : Drawing.FILL
            else op = Drawing.STROKE;
            
            s = Sprintf.sprintf("%.2f %.2f %.2f %.2f re %s ",[ currentX * k, (currentPage.h - currentY) * k, width * k, -height * k, op]);
            endFill();
        }

        if (Std.is(border, String))
        {
            var borderBuffer : String = Std.string(border);
            var currentPageHeight : Float = currentPage.h;
            if (borderBuffer.indexOf(Border.LEFT) != -1) 
                s += Sprintf.sprintf("%.2f %.2f m %.2f %.2f l S ",[ currentX * k, (currentPageHeight - currentY) * k, currentX * k, (currentPageHeight - (currentY + height)) * k]);
            if (borderBuffer.indexOf(Border.TOP) != -1) 
                s += Sprintf.sprintf("%.2f %.2f m %.2f %.2f l S ",[ currentX * k, (currentPageHeight - currentY) * k, (currentX + width) * k, (currentPageHeight - currentY) * k]);
            if (borderBuffer.indexOf(Border.RIGHT) != -1) 
                s += Sprintf.sprintf("%.2f %.2f m %.2f %.2f l S ",[ (currentX + width) * k, (currentPageHeight - currentY) * k, (currentX + width) * k, (currentPageHeight - (currentY + height)) * k]);
            if (borderBuffer.indexOf(Border.BOTTOM) != -1) 
                s += Sprintf.sprintf("%.2f %.2f m %.2f %.2f l S ",[ currentX * k, (currentPageHeight - (currentY + height)) * k, (currentX + width) * k, (currentPageHeight - (currentY + height)) * k]);
        }

        if (null != column && null != column.cellRenderer) {
            column.cellRenderer(text, currentX, currentY, width, height);
        } else if (text != "") {

            var dx : Float;
            
            if (align == HorizontalAlign.RIGHT) 
                dx = width - currentMargin - getStringWidth(text)
            else if (align == HorizontalAlign.CENTER) 
                dx = (width - getStringWidth(text)) * .5
            else dx = currentMargin;
            
            if (colorFlag) 
                s += "q " + addTextColor + " ";
            
            var txt2 : String = escapeIt(text);
            s += Sprintf.sprintf("BT %.2f %.2f Td (%s) Tj ET", [(currentX + dx) * k, (currentPage.h - (currentY + .5 * height + .3 * fontSize)) * k, txt2]);
            
            if (underline) 
                s += " " + doUnderline(currentX + dx, currentY + .5 * height + .3 * fontSize, text);
            if (colorFlag) 
                s += " Q";
            
            if (link != null) 
                addLink(currentX + dx, currentY + .5 * height - .5 * fontSize, getStringWidth(text), fontSize, link);
        }
        
        if (s != "") 
            write(s);
        
        lasth = currentPage.h;
        
        if (ln > 0) 
        {
            currentY += height;
            if (ln == 1) 
                currentX = leftMargin;
        }
        else currentX += width;
    }
    
    private function addCellFit(width : Float, height : Float = 0, text : String = "", border : Dynamic = 0, ln : Float = 0, align : String = "", fill : Float = 0, link : ILink = null, scale : Bool = false, force : Bool = true) : Void
    {
        var stringWidth : Float = getStringWidth(text);
        
        if (width == 0) 
            width = currentPage.w - rightMargin - currentX;
        
        var ratio : Float = (width - currentMargin * 2) / stringWidth;
        var fit : Bool = (ratio < 1 || (ratio > 1 && force));
        
        if (fit) 
        {
            if (scale) 
            {
                var horizScale : Float = ratio * 100.0;
                write(Sprintf.sprintf("BT %.2F Tz ET",[ horizScale]));
            }
            else 
            {
                var charSpace : Float = (width - currentMargin * 2 - stringWidth) / Math.max(getStringLength(text) - 1, 1) * k;
                write(Sprintf.sprintf("BT %.2F Tc ET",[ charSpace]));
            }
            var align : String = "";
        }
        
        addCell(width, height, text, border, ln, align, fill, link);
        
        if (fit) 
            write("BT " + ((scale) ? "100 Tz" : "0 Tc") + " ET");
    }
    
    /**
		 * Adds a cell with horizontal scaling only if necessary
		 * @param width
		 * @param height
		 * @param text
		 * @param border
		 * @param ln
		 * @param align
		 * @param fill
		 * @param link
		 * 
		 */
    public function addCellFitScale(width : Float, height : Float = 0, text : String = "", border : Dynamic = 0, ln : Float = 0, align : String = "", fill : Float = 0, link : ILink = null) : Void
    {
        addCellFit(width, height, text, border, ln, align, fill, link, true, false);
    }
    
    /**
		 * Adds a cell with horizontal scaling always
		 * @param width
		 * @param height
		 * @param text
		 * @param border
		 * @param ln
		 * @param align
		 * @param fill
		 * @param link
		 * 
		 */
    public function addCellFitScaleForce(width : Float, height : Float = 0, text : String = "", border : Dynamic = 0, ln : Float = 0, align : String = "", fill : Float = 0, link : ILink = null) : Void
    {
        addCellFit(width, height, text, border, ln, align, fill, link, true, true);
    }
    
    /**
		 * Adds a cell with character spacing only if necessary
		 * @param width
		 * @param height
		 * @param text
		 * @param border
		 * @param ln
		 * @param align
		 * @param fill
		 * @param link
		 * 
		 */
    public function addCellFitSpace(width : Float, height : Float = 0, text : String = "", border : Dynamic = 0, ln : Float = 0, align : String = "", fill : Float = 0, link : ILink = null) : Void
    {
        addCellFit(width, height, text, border, ln, align, fill, link, false, false);
    }
    
    /**
		 * Adds a cell with character spacing always
		 * @param width
		 * @param height
		 * @param text
		 * @param border
		 * @param ln
		 * @param align
		 * @param fill
		 * @param link
		 * 
		 */
    public function addCellFitSpaceForce(width : Float, height : Float = 0, text : String = "", border : Dynamic = 0, ln : Float = 0, align : String = "", fill : Float = 0, link : ILink = null) : Void
    {
        addCellFit(width, height, text, border, ln, align, fill, link, false, true);
    }
    
    /**
		 * Add a multicell with some text to the current page.
		 *
		 * @param width Cell width
		 * @param height Cell height
		 * @param text Text to add into the cell
		 * @param border Lets you specify if a border should be drawn around the cell
		 * @param align Lets you center or align the text into the cell, values can be L (left align), C (centered), R (right align), J (justified) default value
		 * @param filled Lets you specify if the cell is colored (1) or transparent (0)
		 * @return Page
		 * @example
		 * This example shows how to write a table made of text cells :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setFont( FontFamily.COURIER, Style.BOLD, 14 );
		 * myPDF.textStyle ( new RGBColor ( 0x990000 ) );
		 * myPDF.addMultiCell ( 70, 24, "A multicell :)", 1);
		 * myPDF.addMultiCell ( 70, 24, "A multicell :)", 1);
		 * </pre>
		 * </div>
		 */
    public function addMultiCell(width : Float, height : Float, text : String, border : String = null, align : String = "J", filled : Int = 0, column: GridColumn = null) : Void
    {
        var oldFont: IFont = null;
        var oldFontSize: Int = 0;
        if (null != column && null != column.cellFont && column.cellFontSize > 0) {
            oldFont = currentFont;
            oldFontSize = fontSizePt;
            setFont(column.cellFont, column.cellFontSize);
        }

        charactersWidth = currentFont.charactersWidth;
        
        if (width == 0) 
            width = currentPage.w - rightMargin - currentX;
        
        var wmax : Float = (width - 2 * currentMargin) * I1000 / fontSize;
        var s : String = findAndReplace("\r", "", text);
        var nb : Int = s.length;
        
        if (nb > 0 && s.charAt(nb - 1) == "\n") 
            nb--;
        
        var b : String = null;
        
        if (border != null) 
        {
            if (border != null)
            {
                border = "LTRB";
                b = "LRT";
                b2 = "LR";
            }
            else 
            {
                b2 = "";
                if (border.indexOf(Border.LEFT) != -1) 
                    b2 += Border.LEFT;
                if (border.indexOf(Border.RIGHT) != -1) 
                    b2 += Border.RIGHT;
                b = ((border.indexOf(Border.TOP) != -1)) ? 
                        b2 + Border.TOP : b2;
            }
        }
        
        var sep : Int = -1;
        var i : Int = 0;
        var j : Int = 0;
        var l : Int = 0;
        var ns : Int = 0;
        var nl : Int = 1;
        var c : String;
        var cell : Cell;
        
        var cwAux : Int = 0;
        
        while (i < nb)
        {
            c = s.charAt(i);
            
            if (c == "\n") 
            {
                if (ws > 0) 
                {
                    ws = 0;
                    write("0 Tw");
                }
                
                addCell(width, height, s.substr(j, i - j), b, 2, align, filled, column);
                
                i++;
                sep = -1;
                j = i;
                l = 0;
                ns = 0;
                nl++;
                
                if (border != null && nl == 2) 
                    b = b2;
                continue;
            }

            var ls : Int = 0;
            if (c == " ")
            {
                sep = i;
                ls = l;
                ns++;
            }
            
            cwAux = charactersWidth.get(c);
            
            if (cwAux == 0) 
                cwAux = FontMetrics.DEFAULT_WIDTH;
            
            l += cwAux;
            
            if (l > wmax && (null == column || column.cellRenderer == null))
            {
                if (sep == -1) 
                {
                    if (i == j) 
                        i++;
                    if (ws > 0) 
                    {
                        ws = 0;
                        write("0 Tw");
                    }
                    
                    addCell(width, height, s.substr(j, i - j), b, 2, align, filled, column);
                }
                else 
                {
                    if (align == Align.JUSTIFIED) 
                    {
                        ws = ((ns > 1)) ? ((wmax - ls) * .001) * fontSize / (ns - 1) : 0;
                        write(Sprintf.sprintf("%.3f Tw",[ ws * k]));
                    }
                    
                    addCell(width, height, s.substr(j, sep - j), b, 2, align, filled, column);
                    
                    i = sep + 1;
                }
                
                sep = -1;
                j = i;
                l = 0;
                ns = 0;
                nl++;
                
                if (border != null && nl == 2) 
                    b = b2;
            }
            else i++;
        }
        
        if (ws > 0) 
        {
            ws = 0;
            write("0 Tw");
        }
        
        if (border != null && border.indexOf("B") != -1) 
            b += "B";
        
        addCell(width, height, s.substr(j, i - j), b, 2, align, filled, column);
        
        currentX = leftMargin;

        if (null != column && null != column.cellFont && column.cellFontSize > 0) {
            setFont(oldFont, oldFontSize);
        }
    }
    
    /**
		 * Lets you write some text in the current page.
		 * Note : writeText takes care of line return and paragraphs requirements. If you need HTML in top of that, use writeFlashHtmlText.
		 *
		 * @param lineHeight Line height, lets you specify height between each lines
		 * @param text Text to write, to put a line break just add a \n in the text string
		 * @param link Any link, like http://www.mylink.com, will open te browser when clicked
		 * @example
		 * This example shows how to add some text to the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.writeText ( 5, "Lorem ipsum dolor sit amet, consectetuer adipiscing elit.", "http://www.google.fr");
		 * </pre>
		 * </div>
		 * This example shows how to add some text with a clickable link :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.writeText ( 5, "Lorem ipsum dolor sit amet, consectetuer adipiscing elit.", "http://www.google.fr");
		 * </pre>
		 * </div>
		 */
    public function writeText(lineHeight : Float, text : String, link : ILink = null) : Void
    {
        var cw : Dynamic = currentFont.charactersWidth;
        var w : Float = currentPage.w - rightMargin - currentX;
        var wmax : Float = (w - 2 * currentMargin) * I1000 / fontSize;
        
        var s : String = findAndReplace("\r", "", text);
        var nb : Int = s.length;
        var sep : Int = -1;
        var i : Int = 0;
        var j : Int = 0;
        var l : Int = 0;
        var nl : Int = 1;
        var c : String;
        var cwAux : Int = 0;
        
        while (i < nb)
        {
            c = s.charAt(i);
            
            if (c == "\n") 
            {
                addCell(w, lineHeight, s.substr(j, i - j), 0, 2, "", 0, link);
                i++;
                sep = -1;
                j = i;
                l = 0;
                if (nl == 1) 
                {
                    currentX = leftMargin;
                    w = currentPage.w - rightMargin - currentX;
                    wmax = (w - 2 * currentMargin) * I1000 / fontSize;
                }
                nl++;
                continue;
            }
            
            if (c == " ") 
                sep = i;
            
            cwAux = Std.parseInt(Reflect.field(cw, c));
            
            if (cwAux == 0) 
                cwAux = FontMetrics.DEFAULT_WIDTH;
            
            l += cwAux;
            
            if (l > wmax) 
            {
                //Automatic line break
                if (sep == -1) 
                {
                    if (currentX > leftMargin) 
                    {
                        //Move to next line
                        currentX = leftMargin;
                        currentY += currentPage.h;
                        w = currentPage.w - rightMargin - currentX;
                        wmax = (w - 2 * currentMargin) * I1000 / fontSize;
                        i++;
                        nl++;
                        continue;
                    }
                    if (i == j) 
                        i++;
                    addCell(w, lineHeight, s.substr(j, i - j), 0, 2, "", 0, link);
                }
                else 
                {
                    addCell(w, lineHeight, s.substr(j, sep - j), 0, 2, "", 0, link);
                    i = sep + 1;
                }
                sep = -1;
                j = i;
                l = 0;
                if (nl == 1) 
                {
                    currentX = leftMargin;
                    w = currentPage.w - rightMargin - currentX;
                    wmax = (w - 2 * currentMargin) * I1000 / fontSize;
                }
                nl++;
            }
            else i++;
        }
        if (i != j) 
            addCell((l * .001) * fontSize, lineHeight, s.substr(j), 0, 0, "", 0, link);
    }
    
    /**
		 * Lets you write some text with basic HTML type formatting.
		 *
		 * @param pHeight Line height, lets you specify height between each lines
		 * @param pText Text to write, to put a line break just add a \n in the text string
		 * @param pLink Any link, like http://www.mylink.com, will open te browser when clicked
     * @param pHeightInFontSizePercentage If not null, override the pHeight with the given per FontSize percentage
		 * @example
		 * 
		 * Only a limited subset of tags are currently supported
		 *  <b> </b>
		 *  <i> </i>
		 *  <br />  used to create a new line
		 * 
		 * This example shows how to add some text to the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.writeFlashHtmlText ( 5, "Lorem ipsum <b>dolor</b> sit amet, consectetuer<br /> adipiscing elit.");
		 * </pre>
		 * </div>
     * 
		 * This example shows how to add some text with a clickable link :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.writeFlashHtmlText ( 5, "Lorem ipsum dolor sit amet, consectetuer adipiscing elit.", "http://www.google.com");
		 * </pre>
		 * </div>
     * 
     * This example shows how to add some text using a pHeight of 120% of the fontSize :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.writeFlashHtmlText ( 5, "Lorem ipsum dolor sit amet, consectetuer adipiscing elit.", null, 120);
		 * </pre>
		 * </div>
		 */
    public function writeFlashHtmlText(pHeight : Float, pText : String, pLink : ILink = null, pHeightInFontSizePercentage : Float = null) : Void
    {
        //TODO: implement
//        //Output text in flowing mode
//        var cw : Dynamic = currentFont.charactersWidth;
//        var w : Float = currentPage.w - rightMargin - currentX;
//        var wmax : Float = (w - 2 * currentMargin) * I1000 / fontSize;
//        var s : String = findAndReplace("\r", "", pText);
//
//        // Strip all \n's as we don't use them - use <br /> tag for returns
//        s = findAndReplace("\n", "", s);
//
//        var nb : Int = 0;  // Count of number of characters in section
//        var sep : Int = -1;  // Stores the position of the last seperator
//        var lenAtSep : Float = 0;  // Store the length at the last seprator
//        var i : Int = 0;  // Counter for looping through each string
//        var j : Int = 0;  // Counter which is updated with character count to be actually output (taking auto line breaking into account)
//        var l : Int = 0;  // Length of the the current character string
//        var k : Int = 0;  // Counter for looping through each item in the parsed XML array
//        var ns : Int = 0;  // number of space character
//
//        //TODO: FastXML doesn't support ignoreWhitespace
//        //XML whitespace is important for this text parsing - so save prev value so we can restore it.
//        //var prevWhiteSpace : Bool = FastXML.ignoreWhitespace;
//        //FastXML.ignoreWhitespace = false;
//
//
//        var aTaggedString : Array<HTMLTag>;
//
//        // We want to now if the HTML is comming from a conversion from
//        // some TLF format.
//        // This could be done with
//        // String(TextConverter.export(this.richEditableText.textFlow, TextConverter.TEXT_FIELD_HTML_FORMAT, ConversionType.STRING_TYPE));
//        // And the result will looks like:
//        // <HTML><BODY><TEXTFORMAT><P> ..</P><P> ..</P></TEXTFORMAT></BODY></HTML>
//        //
//        // Or
//        //
//        // if the string comming from the htmlText property of some MX component
//        // For example this.richTextEditor.htmlText
//        // The result will looks like:
//        // <TEXTFORMAT><P> ..</P></TEXTFORMAT><TEXTFORMAT><P> ..</P></TEXTFORMAT>
//        //
//        // This flag is mainly use to change the behavior depending of the HTML
//        // source.
//        // For example when comingFromTLF == true, the lists are as follow:
//        // <UL><LI><TEXFORMAT><P><FONT>first</FONT></P></TEXFORMAT></LI><LI><TEXFORMAT><P><FONT>second</FONT></P></TEXFORMAT></LI></UL>
//        //
//        // when comingFromTLF == true, the lists are as follow:
//        // <TEXFORMAT><LI><FONT>first</FONT></LI></TEXFORMAT><TEXFORMAT><LI><FONT>second</FONT></LI></TEXFORMAT>
//
//        var comingFromTLF : Bool;
//        var insideULList : Bool;
//
//        // If comming from TLF there is already an <HTML> tag
//        if (s.substr(0, 6) == "<HTML>") {
//            comingFromTLF = true;
//            aTaggedString = parseTags(new FastXML(Xml.parse(s)));
//        }
//        else {
//            comingFromTLF = false;
//            aTaggedString = parseTags(new FastXML(Xml.parse("<HTML>" + s + "</HTML>")));
//        }
//        //TODO: FastXML doens't support ignoreWhitespace
////        FastXML.ignoreWhitespace = prevWhiteSpace;
//
//        //Stores the cell snippets for the current line
//        var currentLine : Array<Dynamic> = new Array<Dynamic>();
//        var cellVO : CellVO;
//
//        //Variables to track the state of the current text
//        var newFont : IFont;
//        var fontTagAttr : FONTTagAttributes;  // hold the value of the last <FONT> tag attributes
//        var fontBold : Bool = false;
//        var fontItalic : Bool = false;
//        fontUnderline = false;
//
//        var textAlign : String = "";  // '' or 'C' or 'R' or 'J'
//        var attr : FastXML;
//
//        var cwAux : Int = 0;
//
//        // Sometime <FONT> nodes are nested such as in
//        // <FONT><FONT>foo</FONT>bar</FONT>
//        // this looks to be related to colors (not sure)
//        // So we need to have a stack of FontParams to handle the above situation
//        var fontTagAttrStack : Array<FONTTagAttributes> = new Array<FONTTagAttributes>();
//
//        // begin with default font attributes
//        fontTagAttr = new FONTTagAttributes();
//        setFontSize(fontTagAttr.size);
//        if (null != pHeightInFontSizePercentage)
//            pHeight = pHeightInFontSizePercentage / 100 * fontTagAttr.size / this.k;
//
//        var listLevelDepth : Int = 0;
//
//        var lastParagraphX : Float;
//        var lastParagraphY : Float;
//
//        // total number of HTML tags
//        var lng : Int = aTaggedString.length;
//
//        //Loop through each item in array
//        for (k in 0...lng){
//            //Handle any tags and if unknown then handle as text
//            switch (aTaggedString[k].tag.toUpperCase())
//            {
//                //Process Tags
//                case "<TEXTFORMAT>":
//                case "</TEXTFORMAT>":
//                case "<P>":
//                    lastParagraphX = currentX;
//                    lastParagraphY = currentY;
//
//                    for (attr/* AS3HX WARNING could not determine type for var: attr exp: EField(EArray(EIdent(aTaggedString),EIdent(k)),attr) type: null */ in aTaggedString[k].attr)
//                    {
//                        switch (Std.string(attr.node.name.innerData()).toUpperCase())
//                        {
//                            case "ALIGN":
//                                textAlign = Std.string(attr).toUpperCase().charAt(0);
//                            default:
//                                break;
//                        }
//                    }
//                case "</P>":
//
//                    if (!insideULList) {
//
//                        renderLine(currentLine, textAlign);
//                        currentLine = new Array<Dynamic>();
//                        currentX = leftMargin;
//                        textAlign = "";
//                        ns = 0;
//
//                        if (currentX == lastParagraphX && currentY == lastParagraphY) {
//                            // means we write nothing in that P tag
//                            // we interpret that as a line break
//                            lineBreak(pHeight);
//                        }
//                    }
//                case "<FONT>":
//
//                    // A <FONT> could override only some attributes, so we default
//                    // all the attributes with the actual fontParams
//                    if (fontTagAttr != null) {
//                        fontTagAttr = fontTagAttr.clone();
//                    }
//                    else {
//                        // we use the default attribute if not specified just after
//                        fontTagAttr = new FONTTagAttributes();
//                    }
//
//                    for (attr/* AS3HX WARNING could not determine type for var: attr exp: EField(EArray(EIdent(aTaggedString),EIdent(k)),attr) type: null */ in aTaggedString[k].attr)
//                    {
//                        switch (Std.string(attr.node.name.innerData()).toUpperCase())
//                        {
//                            case "FACE":
//                            // TODO: Add Font Face Support
//                            fontTagAttr.face = Std.string(attr);
//                            case "SIZE":
//                                fontTagAttr.size = parseInt(Std.string(attr));
//                                setFontSize(fontTagAttr.size);
//                                if (null != pHeightInFontSizePercentage)
//                                    pHeight = pHeightInFontSizePercentage / 100 * fontTagAttr.size / this.k;
//                            case "COLOR":
//                                fontTagAttr.color = RGBColorCache.getColor(Std.string(attr));
//                            case "LETTERSPACING":
//                                fontTagAttr.letterspacing = parseInt(Std.string(attr));
//                            case "KERNING":
//                            // TODO
//                            fontTagAttr.kerning = parseInt(Std.string(attr));
//                            default:
//                                break;
//                        }
//                    }
//
//                    fontTagAttrStack.push(fontTagAttr);
//                case "</FONT>":
//
//                    fontTagAttrStack.pop();
//
//                    if (fontTagAttrStack.length > 0) {
//                        fontTagAttr = fontTagAttrStack[fontTagAttrStack.length - 1];
//                    }
//                    else {
//                        // get the default
//                        fontTagAttr = new FONTTagAttributes();
//
//                        if (Std.is(textColor, RGBColor)) {
//                            fontTagAttr.color = cast((textColor), RGBColor);
//                        }
//                    }
//
//                    setFontSize(fontTagAttr.size);
//                    if (null != pHeightInFontSizePercentage)
//                        pHeight = pHeightInFontSizePercentage / 100 * fontTagAttr.size / this.k;
//                case "<A>":
//                    for (attr/* AS3HX WARNING could not determine type for var: attr exp: EField(EArray(EIdent(aTaggedString),EIdent(k)),attr) type: null */ in aTaggedString[k].attr)
//                    {
//                        switch (Std.string(attr.node.name.innerData()).toUpperCase())
//                        {
//                            case "HREF":
//                                pLink = new HTTPLink(Std.string(attr));
//                            default:
//                                break;
//                        }
//                    }
//                case "</A>":
//                    pLink = null;
//                case "<B>":
//                    fontBold = true;
//                case "</B>":
//                    fontBold = false;
//                case "<I>":
//                    fontItalic = true;
//                case "</I>":
//                    fontItalic = false;
//                case "<U>":
//                    fontUnderline = true;
//                case "</U>":
//                    fontUnderline = false;
//                    break;
//                case "<UL>":
//                    listLevelDepth++;
//                    insideULList = true;
//                case "</UL>":
//                    listLevelDepth--;
//                    if (listLevelDepth == 0)
//                        insideULList = false;
//                case "<BR>", "</BR>":
//
//                    switch (aTaggedString[k].tag.toUpperCase())
//                    {case "<BR>":
//                        // Both cases will set line break to true.  It is typically entered as <br />
//                        // but the parser converts this to a start and end tag
//                        lineBreak(pHeight);
//                    }
//                    if (currentLine.length > 0)
//                    {
//                        renderLine(currentLine, textAlign);
//                        currentX = leftMargin;
//                        currentLine = new Array<Dynamic>();
//                    }
//                case "<LI>":
//
//                    if (!comingFromTLF) {
//                        // MX flash html does not use <UL> tag so we assume a depth of 1
//                        listLevelDepth = 1;
//                        insideULList = true;
//                    }  //Create an CellVO to make the indentation
//
//
//
//                    cellVO = new CellVO();
//                    cellVO.text = "";
//
//                    // indentation
//                    for (listPrefixCounter in 0...listLevelDepth){
//                        cellVO.text += "    ";
//                    }
//
//                    cellVO.text += "\u2022 ";  // bullet char
//                    cellVO.x = currentX;
//                    cellVO.y = currentY;
//                    cellVO.width = getStringWidth(cellVO.text);
//                    cellVO.height = pHeight;
//                    cellVO.fontSizePt = fontSizePt;
//                    cellVO.color = RGBColorCache.getColor("0x000000");
//                    cellVO.underlined = fontUnderline;
//
//                    //Set the font for calculation of character widths
//                    newFont = CoreFontCache.getFont(getFontStyleString(fontBold, fontItalic, fontFamily));
//                    setFont(newFont, cellVO.fontSizePt);
//                    cellVO.font = newFont;
//
//                    currentLine.push(cellVO);
//                    currentX += cellVO.width;
//                case "</LI>":
//
//                    if (!comingFromTLF) {
//                        // MX flash html does not use <UL> tag so we must clean up things
//                        listLevelDepth = 0;
//                        insideULList = false;
//                    }  // new line
//
//
//
//                    renderLine(currentLine, textAlign);
//                    currentLine = new Array<Dynamic>();
//                    currentX = leftMargin;
//                    ns = 0;
//                case "NONE":
//                    //Process text
//
//                    //Create a blank CellVO for this part
//                    cellVO = new CellVO();
//                    cellVO.link = pLink;
//                    cellVO.fontSizePt = fontSizePt;
//                    cellVO.color = fontTagAttr.color;
//                    cellVO.underlined = fontUnderline;
//
//                    if (Std.is(currentFont, EmbeddedFont))
//                    {
//                        var style : String = Style.NORMAL;
//
//                        if (fontBold && fontItalic)
//                        {
//                            style = Style.BOLD_ITALIC;
//                        }
//                        else if (fontBold)
//                        {
//                            style = Style.BOLD;
//                        }
//                        else if (fontItalic)
//                        {
//                            style = Style.ITALIC;
//                        }
//
//                        newFont = FontCollections.lookup(currentFont.name, style);
//                    }
//                    else
//                    newFont = CoreFontCache.getFont(getFontStyleString(fontBold, fontItalic, fontFamily));
//
//                    setFont(newFont, cellVO.fontSizePt);
//                    cellVO.font = newFont;
//
//                    //Font character width lookup table
//                    cw = currentFont.charactersWidth;
//
//                    //Current remaining space per line
//                    w = currentPage.w - rightMargin - currentX;
//
//                    //Size of a full line of text
//                    wmax = (w - 2 * currentMargin) * I1000 / fontSize;
//
//                    //get text from string
//                    s = aTaggedString[k].value;
//
//                    //Length of string
//                    nb = s.length;
//
//                    i = 0;
//                    j = 0;
//                    sep = -1;
//                    l = 0;
//
//                    while (i < nb)
//                    {
//                        //Get next character
//                        var c : String = s.charAt(i);
//
//                        //Found a seperator
//                        if (c == " ")
//                        {
//                            sep = i;  //Save seperator index
//                            lenAtSep = l;  //Save seperator length
//                            ns++;
//                        }  //Add the character width to the length;
//
//
//
//                        cwAux = Std.parseInt(Reflect.field(cw, c));
//
//                        if (cwAux == 0)
//                            cwAux = FontMetrics.DEFAULT_WIDTH;
//
//                        l += cwAux;
//
//                        //Are we Over the char width limit?
//                        if (l > wmax)
//                        {
//                            //Automatic line break
//                            if (sep == -1)
//                            {
//                                // No seperator to force at character
//                                if (currentX > leftMargin)
//                                {
//                                    //Move to next line
//                                    currentX = leftMargin;
//                                    currentY += pHeight;
//
//                                    w = currentPage.w - rightMargin - currentX;
//                                    wmax = (w - 2 * currentMargin) * I1000 / fontSize;
//
//                                    i++;
//                                    {k++;continue;
//                                    }
//                                }
//
//                                if (i == j)
//                                    i++;  //Set the length to the size before it was greater than wmax
//
//
//
//                                l -= cwAux;
//
//                                //Add the cell to the current line
//                                cellVO.x = currentX;
//                                cellVO.y = currentY;
//                                cellVO.width = (l * .001) * fontSize;
//                                cellVO.height = pHeight;
//                                cellVO.text = s.substr(j, i - j);
//
//                                currentLine.push(cellVO);
//
//                                //Just done a line break so render the line
//                                renderLine(currentLine, textAlign);
//                                currentLine = new Array<Dynamic>();
//
//                                //Update x and y positions
//                                currentX = leftMargin;
//                            }
//                            else
//                            {
//                                //Split at last seperator
//                                //Add the cell to the current line
//                                cellVO.x = currentX;
//                                cellVO.y = currentY;
//                                cellVO.width = (lenAtSep * .001) * fontSize;
//                                cellVO.height = pHeight;
//                                cellVO.text = s.substr(j, sep - j);
//
//                                currentLine.push(cellVO);
//
//                                if (textAlign == Align.JUSTIFIED)
//                                {
//                                    ws = ((ns > 1)) ? (wmax - lenAtSep) / I1000 * fontSize / (ns - 1) : 0;
//
//                                    // the "this." is important to no use the "k" loop counter (this one was tricky ... :-)
//                                    write(Sprintf.sprintf("%.3f Tw",[ ws * this.k]));
//                                }  //Just done a line break so render the line
//
//
//
//                                renderLine(currentLine, textAlign);
//                                currentLine = new Array<Dynamic>();
//
//                                //Update x and y positions
//                                currentX = leftMargin;
//
//                                w = currentPage.w - 2 * currentMargin;
//                                i = sep + 1;
//                            }
//
//                            sep = -1;
//                            j = i;
//                            l = 0;
//                            ns = 0;
//
//                            currentX = leftMargin;
//
//                            w = currentPage.w - rightMargin - currentX;
//                            wmax = (w - 2 * currentMargin) * I1000 / fontSize;
//                        }
//                        else
//                        i++;
//                    }  //Last chunk    // while( i < nb )
//
//
//
//                    if (i != j)
//                    {
//                        //If any remaining chars then print them out
//                        //Add the cell to the current line
//                        cellVO.x = currentX;
//                        cellVO.y = currentY;
//                        cellVO.width = (l * .001) * fontSize;
//                        cellVO.height = pHeight;
//                        cellVO.text = s.substr(j);
//
//                        //Last chunk
//                        if (ws > 0)
//                        {
//                            ws = 0;
//                            write("0 Tw");
//                        }
//
//                        currentLine.push(cellVO);
//
//                        //Update X positions
//                        currentX += cellVO.width;
//                    }
//                default:
//                    // do nothing for unsuported nodes ...
//                    break;
//            }  // or last line and there is something to display    //Is there a finished line    // switch on tag
//
//
//
//
//
//            if (k == aTaggedString.length && currentLine.length > 0)
//            {
//                renderLine(currentLine, textAlign);
//                lineBreak(pHeight);
//                currentLine = new Array<Dynamic>();
//            }
//        }  //Is there anything left to render before we exit?    // loop k
//
//
//
//        if (currentLine.length > 0)
//        {
//            renderLine(currentLine, textAlign);
//            lineBreak(pHeight);
//            currentLine = new Array<Dynamic>();
//        }  //Set current y off the page to force new page.
//
//
//
//        currentY += currentPage.h;
    }
    
    private function lineBreak(pHeight : Float) : Void
    {
        currentX = leftMargin;
        currentY += pHeight;
    }
    
    private function getFontStyleString(bold : Bool, italic : Bool, family : String) : String
    {
        var font : String = family;
        var position : Int = 0;
        
        if ((position = font.indexOf("-")) != -1) 
            font = font.substr(0, position);
        
        if (bold && italic) 
            if (family == "Times-Roman") 
            font += "-BoldItalic"
        else 
        font += "-BoldOblique"
        else if (bold) 
            font += "-Bold"
        else if (italic) 
            if (family == "Times-Roman") 
            font += "-Italic"
        else 
        font += "-Oblique"
        else if (font == "Times") 
            font = "Times-Roman";
        
        return font;
    }
    
    private function renderLine(lineArray : Array<Dynamic>, align : String = "") : Void
    {
        var cellVO : CellVO;
        var availWidth : Float = currentPage.w - leftMargin - rightMargin;
        var lineLength : Float = 0;
        var offsetX : Float = 0;
        var offsetY : Float = 0;
        var i : Int = 0;
        
        var firstCell : CellVO = cast((lineArray[0]), CellVO);
        
        if (firstCell == null) 
            return;  // Since we later set the font for drawing each cell, save the current  ;
        
        var savedFont : IFont = currentFont;
        var savedFontSizePt : Int = fontSizePt;
        var savedUnderline : Bool = underline;
        
        //Check if we need a new page for this line
        if (firstCell.y + firstCell.height > pageBreakTrigger) 
        {
            addPage();
            //Use offsetY to push already specified coord for this line back up to top of page
            offsetY = currentY - firstCell.y;
        }
        
        var lng : Int = lineArray.length;
        
        //Calculate offset if we are aligning center or right
        for (i in 0...lng){lineLength += (try cast(lineArray[i], CellVO) catch(e:Dynamic) null).width;
        }
        
        //Adjust offset based on alignment
        if (align == Align.CENTER) 
            offsetX = (availWidth - lineLength) * .5
        // Loop through the cells in the line and draw
        else if (align == Align.RIGHT) 
            offsetX = availWidth - lineLength;
        
        
        
        var pages : Int = 0;
        var tmpCellY : Float = 0.0;
        var tmpCellHeight : Float = 0.0;
        for (i in 0...lng){
            cellVO = cast((lineArray[as3hx.Compat.parseInt(i)]), CellVO);
            
            currentX = cellVO.x + offsetX;
            
            if (i == 0) 
            {
                currentY = cellVO.y + offsetY;
            }
            else 
            {
                if (Math.round(cellVO.y) > Math.round(tmpCellY)) 
                    currentY += tmpCellHeight
                else 
                currentY -= tmpCellHeight;
            }
            
            tmpCellHeight = cellVO.height;
            tmpCellY = cellVO.y;
            
            setFont(cellVO.font, cellVO.fontSizePt, cellVO.underlined);
            
            if (cellVO.color != null) 
                setTextColor(cellVO.color);
            
            colorFlag = (cast fillColor) != addTextColor;
            
            addCell(cellVO.width, cellVO.height, cellVO.text, cellVO.border, 2, null, cellVO.fill, cellVO.link);
        }  // finally we restore the "old" curent font  
        
        
        
        setFont(savedFont, savedFontSizePt, savedUnderline);
    }
    
    private function parseTags(myXML : FastXML) : Array<HTMLTag>
    {
        //TODO: implement
//        var aTags : Array<HTMLTag> = new Array<HTMLTag>();
//        var children : FastXMLList = myXML.node.nodes;
//        var returnedTags : Array<HTMLTag>;
//        var lng : Int = children.length();
//        var subLng : Int = 0;
//
//        for (i in 0...lng){
//            if (children.get(i).node.name.innerData != null)
//            {
//                aTags.push(new HTMLTag("<" + children.get(i).node.name + ">", children.get(i).node.attributes.innerData, ""));
//
//                returnedTags = parseTags(children.get(i));
//                subLng = returnedTags.length;
//
//                for (j in 0...subLng){aTags.push(returnedTags[j]);
//                }
//
//                aTags.push(new HTMLTag("</" + children.get(i).node.name.innerData + ">", children.get(i).node.attributes.innerData, ""));
//            }
//            else
//
//            aTags.push(new HTMLTag("none", new FastXMLList(), children.get(i)));
//        }
//        return aTags;
        return [];
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF templates API
		*
		* importTemplate()
		* getTemplate()
		*
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private function importTemplate(template : FastXML) : Void
    {
        // TBD
        
    }
    
    private function getTemplate(template : FastXML) : FastXML
    {
        // TBD
        return null;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF data API
		*
		* addGrid()
		*
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
		 * Adds a dynamic table to the current page. This can be useful if you need to render large amount of data coming from an existing DataGrid or any data collection.
		 * 
		 * @param grid
		 * @param x
		 * @param y
		 * @param repeatHeader
		 * 
		 * This example shows how to add such a grid to the current page :
		 * <div class="listing">
		 * <pre>
		 * 
		 * // create columns to specify the column order
		 * var gridColumnAge:GridColumn = new GridColumn("City", "city", 20, Align.LEFT, Align.LEFT);
		 * var gridColumnEmail:GridColumn = new GridColumn("E-Mail", "email", 20, Align.LEFT, Align.LEFT);
		 * var gridColumnFirstName:GridColumn = new GridColumn("First Name", "firstName", 40, Align.LEFT, Align.LEFT);
		 * var gridColumnLastName:GridColumn = new GridColumn("Last Name", "lastName", 45, Align.LEFT, Align.LEFT);
		 * 
		 * // create a columns Array
		 * // it determines the order shown in the PDF
		 * var columns:Array = new Array ( gridColumnAge, gridColumnEmail, gridColumnFirstName, gridColumnLastName );
		 * 
		 * // create a Grid object as usual
		 * var grid:Grid = new Grid( dp.toArray(), 200, 120, new RGBColor ( 0xCCCCCC ), new RGBColor (0xCCCCCC), true, new RGBColor(0x887711), .1, null, columns );
		 * 
		 * p.addGrid( grid );
		 * </pre>
		 * </div>
		 */
    public function addGrid(grid : Grid, x : Int = 0, y : Int = 0, repeatHeader : Bool = true) : Void
    {
        if (textColor == null) 
            throw new Error("Please call the setFont and textStyle method before adding a Grid.");
        
        currentGrid = grid;
        currentGrid.x = x;
        currentGrid.y = y;
        var i : Int = 0;
        var j : Int = 0;
        
        currentGrid.generateColumns(false);
        columns = currentGrid.columns;

        var row : Array<Dynamic>;
        columnNames = new Array<GridCell>();
        var lngColumns : Int = columns.length;
        var item : Dynamic;
        
        for (i in 0...lngColumns){
            columnNames.push(new GridCell(columns[i].headerText, currentGrid.headerColor));
        }

        var rect : Rectangle = getRect(columnNames, currentGrid.headerHeight);
        if (checkPageBreak(rect.height))
            addPage();
        
        setXY(x + getX(), y + getY());
        addRow(columnNames, GridRowType.HEADER, rect);
        
        if (grid.cells == null) 
            grid.generateCells();
        
        var buffer : Array<Dynamic> = grid.cells;
        var lngRows : Int = buffer.length;

        for (i in 0...lngRows){
            
            item = buffer[i];
            row = new Array<Dynamic>();
            for (j in 0...lngColumns){
                row.push(Reflect.hasField(item, columns[j].dataField) ? Reflect.field(item, columns[j].dataField) : "");
                nb = Std.int(Math.min(nb, nbLines(columns[j].width, row[j])));
            }
            
            row = buffer[i];
            
            
            rect = getRect(row, currentGrid.rowHeight);
            setX(x + getX());
            
            if (checkPageBreak(rect.height)) 
            {
                addPage();
                setXY(x + getX(), nextPageY);
                //setXY ( x+getX(),y+getY() ); hacked to allow user to set the next Page Y of Grid
                if (repeatHeader) 
                {
                    addRow(columnNames, GridRowType.HEADER, getRect(columnNames, currentGrid.headerHeight));  // header  
                    setX(x + getX());
                }
            }
            
            if (grid.useAlternativeRowColor && cast(isEven = i & 1, Bool)) 
                addRow(row, GridRowType.ALTERNATIVE, rect)
            else addRow(row, GridRowType.NORMAL, rect);
        }
    }
    
    
    /**
		 * This method is used to add grid when used in auto mode for big chunck of data into other pages.
		 * This may be helpful when you just want to set x,y of grid.
		 * You may set using setY after addGrid method, but is 2x slow than this simple method.
		 * 
		 * @param x
		 * @param y
		 * 
		 * @return void
		 * @langversion 3.0
		 * 
		 * This example shows how to add such a grid to the current page  :
		 * <div class="listing">
		 * <pre>
		 * 
		 * // create columns to specify the column order
		 * var gridColumnAge:GridColumn = new GridColumn("City", "city", 20, Align.LEFT, Align.LEFT);
		 * var gridColumnEmail:GridColumn = new GridColumn("E-Mail", "email", 20, Align.LEFT, Align.LEFT);
		 * var gridColumnFirstName:GridColumn = new GridColumn("First Name", "firstName", 40, Align.LEFT, Align.LEFT);
		 * var gridColumnLastName:GridColumn = new GridColumn("Last Name", "lastName", 45, Align.LEFT, Align.LEFT);
		 * 
		 * // create a columns Array
		 * // it determines the order shown in the PDF
		 * var columns:Array = new Array ( gridColumnAge, gridColumnEmail, gridColumnFirstName, gridColumnLastName );
		 * 
		 * // create a Grid object as usual
		 * var grid:Grid = new Grid( dp.toArray(), 200, 120, new RGBColor ( 0xCCCCCC ), new RGBColor (0xCCCCCC), true, new RGBColor(0x887711), .1, null, columns );
		 * 
		 * p.addGrid( grid );
		 * p.setsetGridPositionOnNextPages(); // default values are 10,10
		 * </pre>
		 * </div>
		 * */
    public function setGridPositionOnNextPages(xvalue : Float = 10, yvalue : Float = 10) : Void{
        nextPageX = yvalue;
        nextPageY = xvalue;
    }
    
    private function getRect(rows : Array<Dynamic>, rowHeight : Int = 5) : Rectangle
    {
        var nb : Int = 0;
        var nbL : Int = 0;
        var maxH: Float = 0;
        
        for (i in 0...rows.length) {
            var cell = try cast(rows[i], GridCell) catch(e:Dynamic) null;
            if (columns[i].cellRenderer == null && (nbL = nbLines(columns[i].width, cell.text)) > nb) {
                nb = nbL;
            }
            if (null != columns[i].cellRectCalculator) {
                var r = columns[i].cellRectCalculator(cell.text);
                if (r.height > maxH) {
                    maxH = r.height;
                }
            }
        }
        
        return new Rectangle(0, 0, 0, Math.max(Math.max(rowHeight * nb, rowHeight), maxH));
    }
    
    private function addRow(data : Array<Dynamic>, style : String, rect : Rectangle) : Void
    {
        var a : String;
        var x : Float = 0;
        var y : Float = 0;
        var w : Float = 0;
        var h : Int = Std.int(rect.height);
        var lng : Int = Std.int(data.length);
        
        for (i in 0...lng){
            var cell : GridCell = try cast(data[i], GridCell) catch(e:Dynamic) null;

            beginFill(cell.backgroundColor);
            
            a = ((style != GridRowType.HEADER)) ? columns[i].cellAlign : columns[i].headerAlign;
            rect.x = x = getX();
            rect.y = y = getY();
            rect.width = w = columns[i].width;

            lineStyle(currentGrid.borderColor, 0, 0, currentGrid.borderAlpha);
            drawRect(rect);
            setAlpha(1);
            addMultiCell(w, currentGrid.rowHeight, cell.text, null, a, if (style != GridRowType.HEADER) columns[i] else null);
            setXY(x + w, y);
            
            endFill();
        }
        newLine(h);
    }
    
    public function checkPageBreak(height : Float) : Bool
    {
        return getY() + height > pageBreakTrigger;
    }
    
    private function nbLines(width : Int, text : String) : Int
    {
        var cw : StringMap<Int> = currentFont.charactersWidth;
        
        if (width == 0) 
            width = Std.int(currentPage.w - rightMargin - leftMargin);
        
        var wmax : Int = Std.int((width - 2 * currentMargin) * I1000 / fontSize);
        var s : String = findAndReplace("\r", "", text);
        var nb : Int = s.length;
        
        if (nb > 0 && s.charAt(nb - 1) == "\n") 
            nb--;
        
        var sep : Int = -1;
        var i : Int = 0;
        var j : Int = 0;
        var l : Int = 0;
        var nl : Int = 1;
        var c : String;
        var cwAux : Int = 0;
        
        while (i < nb)
        {
            c = s.charAt(i);
            
            if (c == "\n") 
            {
                i++;
                sep = -1;
                j = i;
                l = 0;
                nl++;
                continue;
            }
            
            if (c == " ") 
                sep = i;
            
            cwAux = cw.get(c);
            
            if (cwAux == 0) 
                cwAux = FontMetrics.DEFAULT_WIDTH;
            
            l += cwAux;
            
            if (l > wmax) 
            {
                if (sep == -1) 
                {
                    if (i == j) 
                        i++;
                }
                else i = sep + 1;
                
                sep = -1;
                j = i;
                l = 0;
                nl++;
            }
            else 
            i++;
        }
        return nl;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF saving API
		*
		* save()
		* textStyle()
		* addCell()
		* addMultiCell()
		* writeText()
		*
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
		 * Allows you to save the PDF locally (Flash Player 10 minmum required) or remotely through a server-side script.
		 *
		 * @param method Can be se to Method.LOCAL, the savePDF will return the PDF ByteArray. When Method.REMOTE is passed, just specify the path to the create.php file
		 * @param url The url of the create.php file
		 * @param downloadMethod Lets you specify the way the PDF is going to be available. Use Download.INLINE if you want the PDF to be opened in the browser, use Download.ATTACHMENT if you want to make it available with a save-as dialog box
		 * @param fileName The name of the PDF, only available when Method.REMOTE is used
		 * @param frame The frame where the window whould be opened
		 * @return The ByteArray PDF when Method.LOCAL is used, otherwise the method returns null
		 * @example
		 * This example shows how to save the PDF on the desktop with the AIR runtime :
		 * <div class="listing">
		 * <pre>
		 *
		 * var f:FileStream = new FileStream();
		 * file = File.desktopDirectory.resolvePath("generate.pdf");
		 * f.open( file, FileMode.WRITE);
		 * var bytes:ByteArray = myPDF.save( Method.LOCAL );
		 * f.writeBytes(bytes);
		 * f.close(); 
		 * </pre>
		 * </div>
		 * 
		 * This example shows how to save the PDF through a download dialog-box with Flash or Flex :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.save( Method.REMOTE, "http://localhost/save.php", Download.ATTACHMENT );
		 * </pre>
		 * </div>
		 * 
		 * This example shows how to view the PDF in the browser with Flash or Flex :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.save( Method.REMOTE, "http://localhost/save.php", Download.INLINE );
		 * </pre>
		 * </div>
		 * 
		 * This example shows how to save the PDF through a download dialog-box with Flash or Flex with any server involved (Flash Player 10 required) :
		 * <div class="listing">
		 * <pre>
		 *
		 * var file:FileReference = new FileReference();
		 * var bytes:ByteArray = myPDF.save( Method.LOCAL );
		 * file.save( bytes, "generated.pdf" );
		 * </pre>
		 * </div>
		 * 
		 */
    public function save(method : String, url : String = "", downloadMethod : String = "inline", fileName : String = "generated.pdf", frame : String = "_blank") : Dynamic
    {
        dispatcher.dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED));
        var started : Float = Math.round(haxe.Timer.stamp() * 1000);
        finish();
        dispatcher.dispatchEvent(new ProcessingEvent(ProcessingEvent.COMPLETE, Math.round(haxe.Timer.stamp() * 1000) - started));
        buffer.position = 0;
        var output : Dynamic = null;
        
        switch (method)
        {
            case Method.LOCAL:
                output = buffer;
            
            case Method.BASE_64:
                output = haxe.crypto.Base64.encode(buffer);

            case Method.REMOTE:
                // Since FP 13.0.0.214, octet-stream header can not be used, will cause security error.
                // On server side, replace $GLOBALS["HTTP_RAW_POST_DATA"] by: file_get_contents('php://input');
                //var header:URLRequestHeader = new URLRequestHeader ("Content-type","application/octet-stream");
                var myRequest : URLRequest = new URLRequest(url + "?name=" + fileName + "&method=" + downloadMethod);
                //myRequest.requestHeaders.push (header);
                myRequest.method = URLRequestMethod.POST;
                myRequest.data = buffer;
                openfl.Lib.getURL(myRequest, frame);
            
            default:
                throw new Error("Unknown Method \"" + method + "\"");
        }
        return output;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF SWF API
		*
		* addSWF()
		*
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private function addSWF(swf : ByteArray) : Void
    {
        // coming soon
        
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF JavaScript API
		*
		* addJavaScript()
		*
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
		 * The addJavaScript allows you to inject JavaScript code to be executed when the PDF document is opened.
		 * 
		 * @param script
		 * @example
		 * This example shows how to open the print dialog when the PDF document is opened :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addJavaScript ("print(true);");
		 * </pre>
		 * </div>
		 */
    public function addJavaScript(script : String) : Void
    {
        js = script;
    }
    
    /**
		 * The addEPSImage method takes an incoming EPS (.eps) file or Adobe® Illustrator® file (.ai) and render it on the current page.
		 * Note : Only EPS below or equal to version 8 are handled.
		 * 
		 * @param stream
		 * @param resizeMode 
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * @param alpha
		 * @param blendMode
		 * @param link
		 * @example
		 * This example shows how to add an EPS file stream on the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addEPSImage ( myEPSStream );
		 * </pre>
		 * </div>
		 */
    public function addEPSImage(stream : ByteArray, x : Float = 0, y : Float = 0, w : Float = 0, h : Float = 0, useBoundingBox : Bool = true) : Void
    {
        stream.position = 0;
        var source : String = stream.readUTFBytes(stream.bytesAvailable);
        
        var reg = new EReg('%%Creator:([^\\r\\n]+)', "");
        
        if (reg.match(source))
        {
            var version : String = reg.matched(1);
            
            if (version.indexOf("Adobe Illustrator") != -1) 
            {
                var buffVersion : Array<Dynamic> = version.split(" ");
                var numVersion : Int = buffVersion.pop();
                
                if (numVersion > 8) 
                    throw new Error("Wrong version, only 1.x, 3.x or 8.x AI files are supported for now.");
            }
            else throw new Error("This EPS file was not created with Adobe® Illustrator®");
        }
        
        var start : Int = source.indexOf("%!PS-Adobe");
        
        if (start != -1) 
            source = source.substr(start);
        
        reg = new EReg('%%BoundingBox:([^\\r\\n]+)', "");
        
        var x1 : Float;
        var y1 : Float;
        var x2 : Float;
        var y2 : Float;
        var buffer : Array<Dynamic>;
        
        if (reg.match(source))
        {
            buffer = Std.string(reg.matched(1)).substr(1).split(" ");
            
            x1 = buffer[0];
            y1 = buffer[1];
            x2 = buffer[2];
            y2 = buffer[3];
            
            start = source.indexOf("%%EndSetup");
            
            if (start == -1) 
                start = source.indexOf("%%EndProlog");
            if (start == -1) 
                start = source.indexOf("%%BoundingBox");
            
            source = source.substr(start);
            
            var end : Int = source.indexOf("%%PageTrailer");
            
            if (end == -1) 
                end = source.indexOf("showpage");
            if (end != 0) 
                source = source.substr(0, end);
            
            write("q");
            
            var k : Float = k;
            var dx : Float;
            var dy : Float;
            
            if (useBoundingBox) 
            {
                dx = x * k - x1;
                dy = y * k - y1;
            }
            else 
            {
                dx = x * k;
                dy = y * k;
            }
            
            write(Sprintf.sprintf("%.3F %.3F %.3F %.3F %.3F %.3F cm",[ 1, 0, 0, 1, dx, dy + (currentPage.hPt - 2 * y * k - (y2 - y1))]));
            
            var scaleX : Float = Math.NaN;
            var scaleY : Float = Math.NaN;
            
            if (w > 0) 
            {
                scaleX = w / ((x2 - x1) / k);
                if (h > 0) 
                {
                    scaleY = h / ((y2 - y1) / k);
                }
                else 
                {
                    scaleY = scaleX;
                    h = (y2 - y1) / k * scaleY;
                }
            }
            else 
            {
                if (h > 0) 
                {
                    scaleY = h / ((y2 - y1) / k);
                    scaleX = scaleY;
                    w = (x2 - x1) / k * scaleX;
                }
                else 
                {
                    w = (x2 - x1) / k;
                    h = (y2 - y1) / k;
                }
            }
            
            if (!Math.isNaN(scaleX)) 
                write(Sprintf.sprintf("%.3F %.3F %.3F %.3F %.3F %.3F cm",[ scaleX, 0, 0, scaleY, x1 * (1 - scaleX), y2 * (1 - scaleY)]));
            
            var lines : Array<Dynamic> = new EReg('\\r\\n|[\\r\\n]', "").split(source);
            
            var u : Float = 0;
            var cnt : Int = lines.length;
            var line : String;
            var length : Int = 0;
            var chunks : Array<Dynamic>;
            var c : String;
            var m : String;
            var ty : String;
            var tk : String;
            var cmd : String;
            
            var r : String;
            var g : String;
            var b : String;

            var i = 0;
            while (i < cnt){
                line = lines[i];
                if (line == "" || line.charAt(0) == "%") { i++; continue; }
                length = line.length;
                chunks = line.split(" ");
                cmd = chunks.pop();
                
                if (cmd == "Xa" || cmd == "XA") 
                {
                    b = chunks.pop();
                    g = chunks.pop();
                    r = chunks.pop();
                    write(r + " " + g + " " + b + " " + (cmd == ("Xa") ? "rg" : "RG"));
                    {i++;continue;
                    }
                }
                
                switch (cmd)
                {
                    case "m", "l", "y", "c", "k", "K", "g", "G", "s", "S", "J", "j", "w", "M", "d", "n", "v":  // NO P  
                    write(line);
                    
                    case "x":
                        c = chunks[0];
                        m = chunks[1];
                        ty = chunks[2];
                        tk = chunks[3];
                        write(c + " " + m + " " + ty + " " + tk + " k");
                    
                    case "X":
                        c = chunks[0];
                        m = chunks[1];
                        ty = chunks[2];
                        tk = chunks[3];
                        write(c + " " + m + " " + ty + " " + tk + " K");
                    case "Y", "N", "V", "L", "C":
                        write(line.toLowerCase());
                    case "b", "B":
                        write(cmd + "*");
                    case "f", "F":
                        if (u > 0) 
                        {
                            var isU : Bool = false;
                            var max : Float = (i + 5 < cnt) ? i + 5 : cnt;
                            var j : Int = i + 1;
                                                        while (j < max){isU = (isU || (lines[j] == "U" || lines[j] == "*U"));
                                j++;
                            }
                            if (isU)                                 write("f*");
                        }
                        else 
                        write("f*");
                    
                    case "*u":
                        u++;
                    
                    case "*U":
                        u--;
                }
                i += 1;
            }
            
            write("Q");
        }
        else throw new Error("No bounding box found in the current EPS file");
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* AlivePDF image API
		*
		* addImage()
		* addImageStream()
		*
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
		 * The addImageStream method takes an incoming image as a ByteArray. This method can be used to embed high-quality images (300 dpi) to the PDF.
		 * You must specify the image color space, if you don't know, there is a lot of chance the color space will be ColorSpace.DEVICE_RGB.
		 * 
		 * @param imageBytes The image stream (PNG, JPEG, GIF)
		 * @param colorSpace The image colorspace
		 * @param resizeMode A resizing behavior, like : new Resize ( Mode.FIT_TO_PAGE, Position.CENTERED ) to center the image in the page
		 * @param x The x position
		 * @param y The y position
		 * @param width The width of the image
		 * @param height The height of the image
		 * @param rotation The rotation of the image
		 * @param alpha The image alpha
		 * @param blendMode The blend mode to use if multiple images are overlapping
		 * @param keepTransformation Do you want the image current transformation (scaled, rotated) to be preserved
		 * @param link The link to associate the image with when clicked
		 * @example
		 * This example shows how to add an RGB image as a ByteArray into the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addImageStream( bytes, ColorSpace.DEVICE_RGB );
		 * </pre>
		 * </div>
		 * 
		 * This example shows how to add a CMYK image as a ByteArray into the current page, the image will take the whole page :
		 * <div class="listing">
		 * <pre>
		 * var resize:Resize = new Resize ( Mode.FULL_PAGE, Position.CENTERED ); 
		 * myPDF.addImageStream( bytes, ColorSpace.DEVICE_RGB, resize );
		 * </pre>
		 * </div>
		 * 
		 * This example shows how to add a CMYK image as a ByteArray into the current page, the image will take the whole page but white margins will be preserved :
		 * <div class="listing">
		 * <pre>
		 * var resize:Resize = new Resize ( Mode.RESIZE_PAGE, Position.CENTERED ); 
		 * myPDF.addImageStream( bytes, ColorSpace.DEVICE_CMYK, resize );
		 * </pre>
		 * </div>
		 */
    public function addImageStream(imageBytes : ByteArray, colorSpace : String, resizeMode : Resize = null, x : Float = 0, y : Float = 0, width : Float = 0, height : Float = 0, rotation : Float = 0, alpha : Float = 1, blendMode : String = "Normal", link : ILink = null) : Void
    {
        var idn = haxe.crypto.Md5.make(cast(imageBytes, Bytes)).toString();
        if (!streamDictionary.exists(idn))
        {
            imageBytes.position = 0;
            
            var id : Int = getCount(streamDictionary) + 1;
            
            if (imageBytes.readUnsignedShort() == JPEGImage.HEADER) 
                image = new JPEGImage(imageBytes, colorSpace, id)
            else if ((imageBytes.position = 0) == 0 && imageBytes.readUnsignedShort() == PNGImage.HEADER)
                image = new PNGImage(imageBytes, colorSpace, id)
            else if ((imageBytes.position = 0) == 0 && imageBytes.readUTFBytes(3) == GIFImage.HEADER)
            {
                imageBytes.position = 0;
                var decoder : GIFPlayer = new GIFPlayer(false);
                var capture : BitmapData = decoder.loadBytes(imageBytes);
                var bytes : ByteArray = PNGEncoder.encode(capture);
                image = new DoPNGImage(capture, bytes, id);
            }
            else if ((imageBytes.position = 0) == 0 && (imageBytes.endian = Endian.LITTLE_ENDIAN) == Endian.LITTLE_ENDIAN && imageBytes.readByte() == 73)
            {
                image = new TIFFImage(imageBytes, colorSpace, id);
            }
            else throw new Error("Image format not supported for now.");
            
           streamDictionary.set(idn, image);
        }
        else image = streamDictionary.get(idn);

        setAlpha(alpha, blendMode);
        placeImage(x, y, width, height, rotation, resizeMode, link);
    }
    
    /**
		 * The addImage method takes an incoming DisplayObject. A JPG or PNG (non-transparent) snapshot is done and included in the PDF document.
		 * 
		 * @param displayObject The DisplayObject to embed as a bitmap in the PDF
		 * @param resizeMode A resizing behavior, like : new Resize ( Mode.FIT_TO_PAGE, Position.CENTERED ) to center the image in the page
		 * @param x The x position
		 * @param y The y position
		 * @param width The width of the image
		 * @param height The height of the image
		 * @param rotation The rotation of the image
		 * @param alpha The image alpha
		 * @param keepTransformation Do you want the image current transformation (scaled, rotated) to be preserved
		 * @param imageFormat The compression to use for the image (PNG or JPG)
		 * @param quality The compression quality if JPG is used
		 * @param blendMode The blend mode to use if multiple images are overlapping
		 * @param link The link to associate the image with when clicked
		 * @example
		 * This example shows how to add a 100% compression quality JPG image centerd on the page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addImage( displayObject, new Resize ( Mode.FIT_TO_PAGE, Position.CENTERED ) );
		 * </pre>
		 * </div>
		 * 
		 * This example shows how to add a 100% compression quality JPG image with no resizing behavior positioned at 20, 20 on the page:
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addImage( displayObject, null, 20, 20 );
		 * </pre>
		 * </div>
		 * 
		 */
    public function addImage(displayObject : DisplayObject, resizeMode : Resize = null, x : Float = 0, y : Float = 0, width : Float = 0, height : Float = 0, rotation : Float = 0, alpha : Float = 1, keepTransformation : Bool = true, imageFormat : String = "PNG", quality : Float = 100, blendMode : String = "Normal", link : ILink = null) : Void
    {
        var displayObjectId: String = Std.string(displayObject) + "-" + displayObject.name;
        if (!streamDictionary.exists(displayObjectId))
        {
            var bytes : ByteArray;
            var bitmapDataBuffer : BitmapData;
            var transformMatrix : Matrix;
            
            displayObjectbounds = displayObject.getBounds(displayObject);
            
            if (keepTransformation) 
            {
                bitmapDataBuffer = new BitmapData(Std.int(displayObject.width), Std.int(displayObject.height), false);
                transformMatrix = displayObject.transform.matrix;
                transformMatrix.tx = transformMatrix.ty = 0;
                transformMatrix.translate(-(displayObjectbounds.x * displayObject.scaleX), -(displayObjectbounds.y * displayObject.scaleY));
            }
            else 
            {
                bitmapDataBuffer = new BitmapData(Std.int(displayObject.width), Std.int(displayObject.height), false);
                transformMatrix = new Matrix();
                transformMatrix.translate(-displayObjectbounds.x, -displayObjectbounds.y);
            }
            
            bitmapDataBuffer.draw(displayObject, transformMatrix);
            
            var id : Int = getCount(streamDictionary) + 1;
            
            if (imageFormat == ImageFormat.JPG) 
            {
                var encoder : JPEGEncoder = new JPEGEncoder(quality);
                bytes = encoder.encode(bitmapDataBuffer);
                image = new DoJPEGImage(bitmapDataBuffer, bytes, id);
            }
            else if (imageFormat == ImageFormat.PNG) 
            {
                bytes = PNGEncoder.encode(bitmapDataBuffer);
                image = new DoPNGImage(bitmapDataBuffer, bytes, id);
            }
            else 
            {
                bytes = TIFFEncoder.encode(bitmapDataBuffer);
                image = new DoTIFFImage(bitmapDataBuffer, bytes, id);
            }
            
            streamDictionary.set(displayObjectId, image);
        }
        else image = streamDictionary.get(displayObjectId);
        
        setAlpha(alpha, blendMode);
        placeImage(x, y, width, height, rotation, resizeMode, link);
    }
    
    private function addTransparentImage(displayObject : DisplayObject) : Void
    {
        // TBD
        
    }
    
    private function placeImage(x : Float, y : Float, width : Float, height : Float, rotation : Float, resizeMode : Resize, link : ILink) : Void
    {
        if (width == 0 && height == 0) 
        {
            width = image.width / k;
            height = image.height / k;
        }
        
        if (width == 0) 
            width = height * image.width / image.height;
        if (height == 0) 
            height = width * image.height / image.width;
        
        
        var availableWidth : Float = currentPage.w - (leftMargin + rightMargin);
        var availableHeight : Float = currentPage.h - (bottomMargin + topMargin);
        
        if (resizeMode == null) 
            resizeMode = new Resize(Mode.NONE, Position.LEFT);
        
        if (resizeMode.mode == Mode.RESIZE_PAGE) 
        {
            currentPage.resize(image.width + (leftMargin + rightMargin) * k, image.height + (bottomMargin + topMargin) * k, k);
            
            availableWidth = currentPage.w - (leftMargin + rightMargin);
            availableHeight = currentPage.h - (bottomMargin + topMargin);
        }
        else if (resizeMode.mode == Mode.FIT_TO_PAGE) 
        {
            var ratio : Float = Math.min(availableWidth * k / image.width, availableHeight * k / image.height);
            
            if (ratio < 1) 
            {
                width *= ratio;
                height *= ratio;
            }
        }
        
        if (resizeMode.position == Position.CENTERED) 
        {
            x = (availableWidth - width) * .5;
            y = (availableHeight - height) * .5;
            
            x += leftMargin;
            y += topMargin;
        }
        else if (resizeMode.position == Position.RIGHT) 
        {
            x = availableWidth - width;
            y += topMargin;
        }
        else if (resizeMode.position == Position.LEFT) 
        {
            x += leftMargin;
            y += topMargin;
        }
        
        if (rotation != 0) 
            rotate(rotation);
        write(Sprintf.sprintf("q %.2f 0 0 %.2f %.2f %.2f cm",[ width * k, height * k, x * k, (currentPage.h - y - height) * k]));
        write(Sprintf.sprintf("/I%d Do Q",[ image.resourceId]));
        
        if (link != null) 
            addLink(x, y, width, height, link);
    }
    
    public function toString() : String
    {
        return "[PDF totalPages=" + totalPages + " nbImages=" + getCount(streamDictionary) + " totalFonts=" + totalFonts + " PDFVersion=" + version + " AlivePDFVersion=" + PDF.ALIVEPDF_VERSION + "]";
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
		* protected members
		*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private function init(orientation : String = "Portrait", unit : String = "Mm", autoPageBreak : Bool = true, pageSize : Size = null, rotation : Int = 0) : Void
    {
        size = ((pageSize != null)) ? Size.getSize(pageSize).clone() : Size.A4.clone();
        
        if (size == null) 
            throw new RangeError("Unknown page format : " + pageSize + ", please use a org.alivepdf.layout." +
        "Size object or any of those strings : Size.A3, Size.A4, Size.A5, Size.Letter, Size.Legal, Size.Tabloid");
        
        dispatcher = new EventDispatcher(this);
        
        viewerPreferences = "";
        outlines = new Array<Outline>();
        arrayPages = new Array<Page>();
        arrayNotes = new Array<Dynamic>();
        graphicStates = new Array<Dynamic>();
        orientationChanges = new Array<Dynamic>();
        nbPages = arrayPages.length;
        buffer = new ByteArray();
        offsets = new Array<Dynamic>();
        fonts = new Array<Dynamic>();
        differences = new Array<Dynamic>();
        streamDictionary = new StringMap<Dynamic>();
        inHeader = inFooter = false;
        fontFamily = "";
        fontStyle = "";
        underline = false;
        
        colorFlag = false;
        matrix = new Matrix();
        
        pagesReferences = new Array<String>();
        compressedPages = new ByteArray();
        coreFontMetrics = new FontMetrics();
        
        defaultUnit = setUnit(unit);
        defaultSize = size;
        defaultOrientation = orientation;
        defaultRotation = rotation;
        
        n = 2;
        state = PDF.STATE_0;
        lasth = 0;
        fontSizePt = 12;
        ws = 0;
        margin = 28.35 / k;
        
        setMargins(margin, margin);
        currentMargin = margin / 10;
        strokeThickness = .567 / k;
        setAutoPageBreak(autoPageBreak, margin * 2);
        setDisplayMode(Display.FULL_WIDTH);
        
        isLinux = Capabilities.version.indexOf("LNX") != -1;
        version = PDF.PDF_VERSION;
    }
    
    private function getCurrentStyle() : String
    {
        var style : String;
        
        if (filled && stroking)
            style = Drawing.CLOSE_AND_FILL_AND_STROKE
        else if (filled)
            style = Drawing.FILL
        else if (stroking) 
            style = Drawing.CLOSE_AND_STROKE
        else style = Drawing.CLOSE_AND_STROKE;
        
        return style;
    }
    
    private function getStringLength(string : String) : Int
    {
        if (currentFont.type == FontType.TYPE0) 
        {
            var len : Int = 0;
            var nbbytes : Int = string.length;
            var i = 0;
            while (i < nbbytes){
                if (string.charCodeAt(i) < 128)
                    len++
                else 
                {
                    len++;
                    i++;
                }
            }
            return len;
        }
        else 
        return string.length;
    }
    
    private function transform(tm : Matrix) : Void
    {
        
        write(Sprintf.sprintf("%.3f %.3f %.3f %.3f %.3f %.3f cm",[ tm.a, tm.b, tm.c, tm.d, tm.tx, tm.ty]));
    }
    
    private function getMatrixTransformPoint(px : Float, py : Float) : Void
    {
        var position : Point = new Point(px, py);
        var deltaPoint : Point = matrix.deltaTransformPoint(position);
        matrix.tx = px - deltaPoint.x;
        matrix.ty = py - deltaPoint.y;
    }
    
    private function startTransform() : Void
    {
        write("q");
    }
    
    private function stopTransform() : Void
    {
        write("Q");
    }
    
    private function finish() : Void
    {
        close();
    }
    
    private function setUnit(unit : String) : String
    {
        if (unit == Unit.POINT) 
            k = 1
        else if (unit == Unit.MM) 
            k = 72 / 25.4
        else if (unit == Unit.CM) 
            k = 72 / 2.54
        else if (unit == Unit.INCHES) 
            k = 72
        else throw new RangeError("Incorrect unit: " + unit);
        
        // We recompute the size for the current unit of all unit dependent stuff
        leftMargin = if (null != leftMarginPt) leftMarginPt / k else 0.0;
        topMargin = if (null != topMarginPt) topMarginPt / k else 0.0;
        bottomMargin = if (null != bottomMarginPt) bottomMarginPt / k else 0.0;
        rightMargin = if (null != rightMarginPt) rightMarginPt / k else 0.0;
        
        return unit;
    }
    
    private function acceptPageBreak() : Bool
    {
        return autoPageBreak;
    }
    
    private function curve(x1 : Float, y1 : Float, x2 : Float, y2 : Float, x3 : Float, y3 : Float) : Void
    {
        var h : Float = currentPage.h;
        write(Sprintf.sprintf("%.2f %.2f %.2f %.2f %.2f %.2f c ",[ x1 * k, (h - y1) * k, x2 * k, (h - y2) * k, x3 * k, (h - y3) * k]));
    }
    
    private function getStringWidth(content : String) : Float
    {
        charactersWidth = currentFont.charactersWidth;
        var w : Float = 0;
        var l : Int = content.length;
        
        var cwAux : Int = 0;
        var cw : Int = 0;
        
        while (l-- > 0)
        {
            cw = charactersWidth.get(content.charAt(l));
            
            if (cw == 0) 
                cw = FontMetrics.DEFAULT_WIDTH;
            
            cwAux += cw;
        }
        
        w = cwAux;
        return w * fontSize * .001;
    }
    
    private function open() : Void
    {
        state = PDF.STATE_1;
    }
    
    private function close() : Void
    {
        if (arrayPages.length == 0) 
            addPage();
        inFooter = true;
        footer();
        inFooter = false;
        finishPage();
        finishDocument();
    }
    
    private function addExtGState(graphicState : Dynamic) : Int
    {
        graphicStates.push(graphicState);
        return graphicStates.length - 1;
    }
    
    private function saveGraphicsState() : Void
    {
        write("q");
    }
    
    private function restoreGraphicsState() : Void
    {
        write("Q");
    }
    
    private function setExtGState(graphicState : Int) : Void
    {
        write(Sprintf.sprintf("/GS%d gs", [graphicState]));
    }
    
    private function insertExtGState() : Void
    {
        var lng : Int = graphicStates.length;
        
        for (i in 0...lng){
            newObj();
            graphicStates[i].n = n;
            write("<</Type /ExtGState");
            for (k in Reflect.fields(graphicStates[i]))
                write("/" + k + " " + Reflect.field(graphicStates[i], k));
            write(">>");
            write("endobj");
        }
    }
    
    private function getChannels(color : Int) : String
    {
        var r : Float = (color & 0xFF0000) >> 16;
        var g : Float = (color & 0x00FF00) >> 8;
        var b : Float = (color & 0x0000FF);
        return (r / 0xFF) + " " + (g / 0xFF) + " " + (b / 0xFF);
    }
    
    private function leftPad(stringToPad : String, desiredLength : Int = 2, paddingChar : String = " ") : String
    {
        if (stringToPad == null) 
            return null;
        
        if (stringToPad.length >= desiredLength) 
            return stringToPad;
        
        var paddedString : String = stringToPad;
        while (paddedString.length < desiredLength){
            paddedString = paddingChar + paddedString;
        }
        
        return paddedString;
    }
    
    private function formatDate(myDate : Date) : String
    {
        var year : String = Std.string(myDate.getFullYear());
        var month : String = leftPad(Std.string(myDate.getMonth() + 1), 2, "0");
        var day : String = leftPad(Std.string(myDate.getDate()), 2, "0");
        var hours : String = leftPad(Std.string(myDate.getHours()), 2, "0");
        var min : String = leftPad(Std.string(myDate.getMinutes()), 2, "0");
        var sec : String = leftPad(Std.string(myDate.getSeconds()), 2, "0");
        //TODO: implement
//        var offSet : String = "";
//        if (myDate.timezoneOffset > 0) {
//            offSet += "-";
//        }
//        else {
//            offSet += "+";
//        }  // hours
//
//        offSet += leftPad(Std.string(as3hx.Compat.parseInt(Math.abs(myDate.timezoneOffset) / 60)), 2, "0") + "'";
//        //minutes
//        offSet += leftPad(Std.string(Math.abs(myDate.timezoneOffset) % 60), 2, "0") + "'";
        
        var formatedDate : String = year + "" + month + "" + day + "" + hours + "" + min + "" + sec; // + "" + offSet;
        
        return formatedDate;
    }
    
    private function findAndReplace(search : String, replace : String, source : String) : String
    {
        return Std.string(source).split(Std.string(search)).join(Std.string(replace));
    }
    
    private function createPageTree() : Void
    {
        compressedPages = new ByteArray();
        
        nb = arrayPages.length;
        
        if (aliasNbPages != null) 
            for (i in 0...nb){arrayPages[i].content = findAndReplace(aliasNbPages, (Std.string(nb)), arrayPages[i].content);
        };
        
        filter = "";
        
        offsets[1] = buffer.length;
        write("1 0 obj");
        write("<</Type /Pages");
        write("/Kids [" + pagesReferences.join(" ") + "]");
        write("/Count " + nb + ">>");
        write("endobj");
        
        for (p in arrayPages)
        {
            var page: Page = p;
            newObj();
            write("<</Type /Page");
            write("/Parent 1 0 R");
            write(Sprintf.sprintf("/MediaBox [0 0 %.2f %.2f]",[ page.width, page.height]));
            write("/Resources 2 0 R");
            if (page.annotations != "") 
                write("/Annots [" + page.annotations + "]");
            write("/Rotate " + page.rotation);
            if (page.advanceTiming != 0) 
                write("/Dur " + page.advanceTiming);
            if (page.transitions.length > 0) 
                write(page.transitions);
            write("/Contents " + (n + 1) + " 0 R>>");
            write("endobj");
            newObj();
            write("<<" + filter + "/Length " + page.content.length + ">>");
            writeStream(page.content.substr(0, page.content.length - 1));
            write("endobj");
        }
    }
    
    private function writeXObjectDictionary() : Void
    {
        for (img in streamDictionary) {
            var image: PDFImage = cast img;
            write("/I" + image.resourceId + " " + image.n + " 0 R");
        }
    }
    
    private function writeResourcesDictionary() : Void
    {
        write("/ProcSet [/PDF /Text /ImageB /ImageC /ImageI]");
        write("/Font <<");
        for (f in fonts) {
            var font: IFont = cast f;
            write("/F" + font.id + " " + font.resourceId + " 0 R");
        }
        write(">>");
        write("/XObject <<");
        writeXObjectDictionary();
        write(">>");
        write("/ExtGState <<");
        var gsIndex = 0;
        for (gs in graphicStates) {
            write("/GS" + Std.string(gsIndex) + " " + gs.n + " 0 R");
            gsIndex += 1;
        }
        write(">>");
        write("/ColorSpace <<");
        for (color in spotColors) {
            write("/CS" + color.i + " " + color.n + " 0 R");
        }
        write(">>");
        write("/Properties <</OC1 " + nOCGPrint + " 0 R /OC2 " + nOCGView + " 0 R>>");
        write("/Shading <<");
        var gradientIndex = 0;
        for (gradient in gradients) {
            write("/Sh" + gradientIndex + " " + gradient.id + " 0 R");
            gradientIndex += 1;
        }
        write(">>");
    }
    
    private function insertImages() : Void
    {
        var filter : String = "";
        var stream : ByteArray;
        
        for (img in streamDictionary)
        {
            var image: PDFImage = cast img;
            newObj();
            image.n = n;
            write("<</Type /XObject");
            write("/Subtype /Image");
            write("/Width " + image.width);
            write("/Height " + image.height);
            
            if (image.masked) 
                write("/SMask " + (n - 1) + " 0 R");
            
            if (image.colorSpace == ColorSpace.INDEXED) 
                write("/ColorSpace [/" + ColorSpace.INDEXED + " /" + ColorSpace.DEVICE_RGB + " " + ((try cast(image, PNGImage) catch(e:Dynamic) null).pal.length / 3 - 1) + " " + (n + 1) + " 0 R]")
            else 
            {
                write("/ColorSpace /" + image.colorSpace);
                if (image.colorSpace == ColorSpace.DEVICE_CMYK) 
                    write("/Decode [1 0 1 0 1 0 1 0]");
            }
            
            write("/BitsPerComponent " + image.bitsPerComponent);
            
            if (image.filter != null) 
                write("/Filter /" + image.filter);
            
            if (Std.is(image, PNGImage) || Std.is(image, GIFImage)) 
            {
                if (image.parameters != null) 
                    write(image.parameters);
                
                if (image.transparency != null && Std.is(image.transparency, Array)) 
                {
                    var trns : String = "";
                    var lng : Int = image.transparency.length;
                    for (i in 0...lng){ trns += image.transparency.charAt(i) + " " + image.transparency.charAt(i) + " ";
                    }
                    write("/Mask [" + trns + "]");
                }
            }
            
            stream = image.bytes;
            write("/Length " + stream.length + ">>");
            write("stream");
            buffer.writeBytes(stream);
            buffer.writeUTFBytes("\n");
            write("endstream");
            write("endobj");
            
            if (image.colorSpace == ColorSpace.INDEXED) 
            {
                newObj();
                var pal : String = (try cast(image, PNGImage) catch(e:Dynamic) null).pal;
                write("<<" + filter + "/Length " + pal.length + ">>");
                writeStream(pal);
                write("endobj");
            }
        }
    }
    
    private function insertFonts() : Void
    {
        var nf : Int = n;
        
        for (diff in differences)
        {
            newObj();
            write("<</Type /Encoding /BaseEncoding /WinAnsiEncoding /Differences [" + diff + "]>>");
            write("endobj");
        }
        
        var font : IFont;
        var embeddedFont : EmbeddedFont = null;
        var fontDescription : FontDescription = null;
        var type : String;
        var name : String;
        var charactersWidth : Dynamic;
        var s : String;
        var lng : Int = 0;
        
        for (f in fonts)
        {
            var font: CoreFont = cast f;
            if (Std.is(font, EmbeddedFont))
            {
                if (font.type == FontType.TRUE_TYPE) 
                {
                    embeddedFont = try cast(font, EmbeddedFont) catch(e:Dynamic) null;
                    fontDescription = embeddedFont.description;
                    newObj();
                    write("<</Length " + embeddedFont.stream.length);
                    write("/Filter /" + Filter.FLATE_DECODE);
                    write("/Length1 " + embeddedFont.originalSize + ">>");
                    write("stream");
                    buffer.writeBytes(embeddedFont.stream);
                    buffer.writeByte(0x0A);
                    write("endstream");
                    write("endobj");
                }
            }
            
            font.resourceId = n + 1;
            type = font.type;
            name = font.name;
            
            if (!(Std.is(font, EmbeddedFont))) 
            {
                newObj();
                write("<</Type /Font");
                write("/BaseFont /" + name);
                write("/Subtype /Type1");
                if (name != FontFamily.SYMBOL && name != FontFamily.ZAPFDINGBATS) 
                    write("/Encoding /WinAnsiEncoding");
                write(">>");
                write("endobj");
            }
            else if (Std.is(font, EmbeddedFont)) 
            {
                newObj();
                write("<</Type /Font");
                write("/BaseFont /" + name);
                write("/Subtype /" + type);
                write("/FirstChar 32");
                write("/LastChar 255");
                write("/Widths " + (n + 1) + " 0 R");
                write("/FontDescriptor " + (n + 2) + " 0 R");
                if (embeddedFont.encoding != null) 
                {
                    if (embeddedFont.differences != null)
                        write("/Encoding " + (nf + embeddedFont.differencesIndex + 1) + " 0 R")
                    else write("/Encoding /WinAnsiEncoding");
                }
                write(">>");
                write("endobj");
                newObj();
                s = "[ ";
                for (i in 32...0x100){
                    var c = String.fromCharCode(i);
                    s += (if (embeddedFont.widths.exists(c)) embeddedFont.widths.get(c) else 0) + " ";
                }
                write(s + "]");
                write("endobj");
                newObj();
                write("<</Type /FontDescriptor");
                write("/FontName /" + name);
                write("/FontWeight /" + fontDescription.fontWeight);
                write("/Descent " + fontDescription.descent);
                write("/Ascent " + fontDescription.ascent);
                write("/AvgWidth " + fontDescription.averageWidth);
                write("/Flags " + fontDescription.flags);
                write("/FontBBox [" + fontDescription.boundingBox[0] + " " + fontDescription.boundingBox[1] + " " + fontDescription.boundingBox[2] + " " + fontDescription.boundingBox[3] + "]");
                write("/ItalicAngle " + fontDescription.italicAngle);
                write("/StemV " + fontDescription.stemV);
                write("/MissingWidth " + fontDescription.missingWidth);
                write("/CapHeight " + fontDescription.capHeight);
                write("/FontFile" + (type == ("Type1") ? "" : "2") + " " + (embeddedFont.resourceId - 1) + " 0 R");
                write(">>");
                write("endobj");
            }
            else throw new Error("Unsupported font type: " + type + "\nMake sure you used the UnicodePDF class if you used the ArialUnicodeMS font class");
        }
    }
    private function insertSWF() : Void
    {
        /// TO BE DONE on next release
        
    }
    
    private function insertJS() : Void
    {
        newObj();
        jsResource = n;
        write("<<");
        write("/Names [(EmbeddedJS) " + (n + 1) + " 0 R]");
        write(">>");
        write("endobj");
        newObj();
        write("<<");
        write("/S /JavaScript");
        write("/JS " + escapeString(js));
        write(">>");
        write("endobj");
    }
    
    private function writeResources() : Void
    {
        insertShaders();
        insertOCG();
        insertSpotColors();
        insertExtGState();
        insertFonts();
        insertImages();
        if (js != null) 
            insertJS();
        offsets[2] = buffer.length;
        write("2 0 obj");
        write("<<");
        writeResourcesDictionary();
        write(">>");
        write("endobj");
        insertBookmarks();
    }
    
    private function insertOCG() : Void
    {
        newObj();
        nOCGPrint = n;
        write("<</Type /OCG /Name (print)");
        write("/Usage <</Print <</PrintState /ON>> /View <</ViewState /OFF>>>>>>");
        write("endobj");
        newObj();
        nOCGView = n;
        write("<</Type /OCG /Name (view)");
        write("/Usage <</Print <</PrintState /OFF>> /View <</ViewState /ON>>>>>>");
        write("endobj");
    }
    
    private function insertBookmarks() : Void
    {
        var nb : Int = outlines.length;
        if (nb == 0)             return;
        
        var lru : Array<Int> = new Array<Int>();
        var level : Int = 0;
        var o : Outline;
        
        for (i in 0...outlines.length)
        {
            var o = outlines[i];
            if (o.level > 0)
            {
                var parent : Int = lru[o.level - 1];
                //Set parent and last pointers
                outlines[i].parent = parent;
                outlines[parent].last = i;
                if (o.level > level) 
                {
                    //Level increasing: set first pointer
                    outlines[parent].first = i;
                }
            }
            else outlines[i].parent = nb;
            
            if (o.level <= level && i > 0)
            {
                //Set prev and next pointers
                var prev : Int = lru[o.level];
                outlines[prev].next = i;
                outlines[i].prev = prev;
            }
            lru[o.level] = i;
            level = o.level;
        }  //Outline items  
        
        
        
        var n : Int = n + 1;
        
        for (p in outlines)
        {
            newObj();
            write("<</Title " + escapeString(p.text));
            write("/Parent " + (n + as3hx.Compat.parseInt(p.parent)) + " 0 R");
            if (p.prev >= 0)
                write("/Prev " + (n + as3hx.Compat.parseInt(p.prev)) + " 0 R");
            if (p.next >= 0)
                write("/Next " + (n + as3hx.Compat.parseInt(p.next)) + " 0 R");
            if (p.first >= 0)
                write("/First " + (n + as3hx.Compat.parseInt(p.first)) + " 0 R");
            if (p.last >= 0)
                write("/Last " + (n + as3hx.Compat.parseInt(p.last)) + " 0 R");
            write("/C [" + p.redMultiplier + " " + p.greenMultiplier + " " + p.blueMultiplier + "]");
            write(Sprintf.sprintf("/Dest [%d 0 R /XYZ 0 %.2f null]",[ 1 + 2 * p.pages, (currentPage.h - p.y) * k]));
            write("/Count 0>>");
            write("endobj");
        }  //Outline root  
        
        
        
        newObj();
        outlineRoot = this.n;
        write("<</Type /Outlines /First " + n + " 0 R");
        write("/Last " + (this.n - 1) + " 0 R>>");
        write("endobj");
    }
    
    private function insertInfos() : Void
    {
        write("/Producer " + escapeString("AlivePDF " + PDF.ALIVEPDF_VERSION));
        if ((documentTitle != null)) 
            write("/Title " + escapeString(documentTitle));
        if ((documentSubject != null)) 
            write("/Subject " + escapeString(documentSubject));
        if ((documentAuthor != null)) 
            write("/Author " + escapeString(documentAuthor));
        if ((documentKeywords != null)) 
            write("/Keywords " + escapeString(documentKeywords));
        if ((documentCreator != null)) 
            write("/Creator " + escapeString(documentCreator));
        write("/CreationDate " + escapeString("D:" + formatDate(Date.now())));
        write("/ModDate " + escapeString("D:" + formatDate(Date.now())));
    }
    
    private function createCatalog() : Void
    {
        write("/Type /Catalog");
        write("/Pages 1 0 R");
        
        var startingPage : String = pagesReferences[startingPageIndex];
        
        if (zoomMode == Display.FULL_PAGE) 
            write("/OpenAction [" + startingPage + " /Fit]")
        else if (zoomMode == Display.FULL_WIDTH) 
            write("/OpenAction [" + startingPage + " /FitH null]")
        else if (zoomMode == Display.REAL) 
            write("/OpenAction [" + startingPage + " /XYZ null null " + zoomFactor + "]")
        else if (!(Std.is(zoomMode, String))) 
            write("/OpenAction [" + startingPage + " /XYZ null null " + (zoomMode * .01) + "]");
        
        write("/PageLayout /" + layoutMode);
        
        if (viewerPreferences.length > 0)
            write("/ViewerPreferences " + viewerPreferences);
        
        if (outlines.length > 0)
        {
            write("/Outlines " + outlineRoot + " 0 R");
            write("/PageMode /UseOutlines");
        }
        else write("/PageMode /" + pageMode);
        
        if (js != null) 
            write("/Names <</JavaScript " + (jsResource) + " 0 R>>");
        
        var p : String = nOCGPrint + " 0 R";
        var v : String = nOCGView + " 0 R";
        var ast : String = "<</Event /Print /OCGs [" + p + " " + v + "] /Category [/Print]>> <</Event /View /OCGs [" + p + " " + v + "] /Category [/View]>>";
        write("/OCProperties <</OCGs [" + p + " " + v + "] /D <</ON [" + p + "] /OFF [" + v + "] /AS [" + ast + "]>>>>");
    }
    
    private function createHeader() : Void
    {
        write("%PDF-" + version);
    }
    
    private function createTrailer() : Void
    {
        write("/Size " + (n + 1));
        write("/Root " + n + " 0 R");
        write("/Info " + (n - 1) + " 0 R");
    }
    
    private function finishDocument() : Void
    {
        if (pageMode == PageMode.USE_ATTACHMENTS) 
            version = "1.6"
        else if (layoutMode == Layout.TWO_PAGE_LEFT || layoutMode == Layout.TWO_PAGE_RIGHT || visibility != null) 
            version = "1.5"
        else if (graphicStates.length > 0 && version < "1.4")
            version = "1.4"
        //Resources
        else if (outlines.length > 0)
            version = "1.4";
        
        createHeader();
        var started : Float;
        started = Math.round(haxe.Timer.stamp() * 1000);
        createPageTree();
        dispatcher.dispatchEvent(new ProcessingEvent(ProcessingEvent.PAGE_TREE, Math.round(haxe.Timer.stamp() * 1000) - started));
        started = Math.round(haxe.Timer.stamp() * 1000);
        writeResources();
        dispatcher.dispatchEvent(new ProcessingEvent(ProcessingEvent.RESOURCES, Math.round(haxe.Timer.stamp() * 1000) - started));
        //Info
        newObj();
        write("<<");
        insertInfos();
        write(">>");
        write("endobj");
        //Catalog
        insertSWF();
        newObj();
        write("<<");
        createCatalog();
        write(">>");
        write("endobj");
        //Cross-ref
        var o : Int = buffer.length;
        write("xref");
        write("0 " + (n + 1));
        write("0000000000 65535 f ");
        for (i in 1...n + 1){write(Sprintf.sprintf("%010d 00000 n ", [offsets[i]]));
        }
        //Trailer
        write("trailer");
        write("<<");
        createTrailer();
        write(">>");
        write("startxref");
        write(Std.string(o));
        write("%%EOF");
        state = PDF.STATE_3;
    }
    
    private function startPage(newOrientation : String) : Void
    {
        nbPages = arrayPages.length;
        state = PDF.STATE_2;
        
        setXY(leftMargin, topMargin);
        
        if (newOrientation == "") 
            newOrientation = defaultOrientation
        else if (newOrientation != defaultOrientation) 
            orientationChanges[nbPages] = true;
        
        pageBreakTrigger = arrayPages[nbPages - 1].h - bottomMargin;
        currentOrientation = newOrientation;
    }
    
    private function finishPage() : Void
    {
        setVisible(Visibility.ALL);
        state = PDF.STATE_1;
    }
    
    private function newObj() : Void
    {
        offsets[++n] = buffer.length;
        write(n + " 0 obj");
    }
    
    private function doUnderline(x : Float, y : Float, content : String) : String
    {
        underlinePosition = currentFont.underlinePosition;
        underlineThickness = currentFont.underlineThickness;
        var w : Float = getStringWidth(content) + ws * substrCount(content, " ");
        return Sprintf.sprintf("%.2f %.2f %.2f %.2f re f",[ x * k, (currentPage.h - (y - (underlinePosition * .001) * fontSize)) * k, w * k, (-underlineThickness * .001) * fontSizePt]);
    }
    
    private function substrCount(content : String, search : String) : Int
    {
        return content.split(search).length;
    }
    
    private function getCount<A>(object: Iterable<A>) : Int
    {
        return Lambda.count(object);
    }
    
    private function escapeString(content : String) : String
    {
        return "(" + escapeIt(content) + ")";
    }
    
    private function escapeIt(content : String) : String
    {
        content = findAndReplace('\\n', '\\\\n', content);
        content = findAndReplace('\\r', '\\\\r', content);
        content = findAndReplace('\\t', '\\\\t', content);
        content = findAndReplace('\\b', '\\\\b', content);
        content = findAndReplace('\\f', '\\\\f', content);
        return findAndReplace(")", '\\)', findAndReplace("(", '\\(', findAndReplace('\\\\', '\\\\\\\\', content)));
    }
    
    private function writeStream(stream : String) : Void
    {
        write("stream");
        write(stream);
        write("endstream");
    }
    
    private function write(content : String) : Void
    {
        if (currentPage == null) 
            throw new Error("No pages available, please call the addPage method first.");
        if (state == PDF.STATE_2) 
            currentPage.content += content + "\n"
        else 
        {
            if (content.indexOf("\u00FE\u00FF") > 0)
            {
                var chunks : Array<Dynamic> = content.split("\u00FE\u00FF");
                var chunk : String;
                var len : Int = chunks.length;

                var i = 0;
                while (i < len){
                    chunk = try cast(chunks[i], String) catch(e:Dynamic) null;
                    doWriteString(chunk);
                    if (i == len - 1 && chunk != "") {
                        i++; continue;
                    };
                    buffer.writeByte(0);
                    i += 1;
                }
                buffer.writeByte(0x0A);
            }
            else doWriteString(content + "\n");
        }
    }

    private function doWriteString(content: String) {
        var contentTxt : String = Std.string(content);
        var lng : Int = contentTxt.length;
        for (i in 0...lng){buffer.writeByte(contentTxt.charCodeAt(i));
        }
    }
    
    //--
    //-- IEventDispatcher
    //--
    
    public function addEventListener(type : String, listener : Dynamic, useCapture : Bool = false, priority : Int = 0, useWeakReference : Bool = false) : Void
    {
        dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    
    public function dispatchEvent(event : Event) : Bool
    {
        return dispatcher.dispatchEvent(event);
    }
    
    public function hasEventListener(type : String) : Bool
    {
        return dispatcher.hasEventListener(type);
    }
    
    public function removeEventListener(type : String, listener : Dynamic, useCapture : Bool = false) : Void
    {
        dispatcher.removeEventListener(type, listener, useCapture);
    }
    
    public function willTrigger(type : String) : Bool
    {
        return dispatcher.willTrigger(type);
    }
}
