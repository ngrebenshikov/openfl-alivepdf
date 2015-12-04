package org.alivepdf.pdf;

import flash.errors.Error;

import flash.utils.ByteArray;

import org.alivepdf.decoding.Filter;
import org.alivepdf.fonts.EmbeddedFont;
import org.alivepdf.fonts.FontDescription;
import org.alivepdf.fonts.FontFamily;
import org.alivepdf.fonts.FontType;
import org.alivepdf.fonts.ICidFont;
import org.alivepdf.fonts.IFont;
import org.alivepdf.layout.Size;
import org.alivepdf.links.ILink;

class UnicodePDF extends PDF
{
    public var isUnicode(get, set) : Bool;

    /* temporaire gestion CID font */
    private var _isUnicode : Bool = false;
    
    /**
		 * Getter/Setter for _cidFont
		 */
    private function get_isunicode() : Bool{return _isUnicode;
    }
    private function set_isunicode(value : Bool) : Bool{_isUnicode = value;
        return value;
    }
    
    public function new(orientation : String = "Portrait", unit : String = "Mm", autoPageBreak : Bool = true, pageSize : Size = null, rotation : Int = 0)
    {
        super(orientation, unit, autoPageBreak, pageSize, rotation);
    }
    
    override public function writeFlashHtmlText(pHeight : Float, pText : String, pLink : ILink = null, pHeightInFontSizePercentage : Float = NaN) : Void
    {
        throw new Error("writeFlashHtmlText is not available with the UnicodePDF class.");
    }
    
    override private function addFont(font : IFont) : IFont
    {
        pushedFontName = font.name;
        
        if (!fonts.some(findFont)) 
            fonts.push(font);
        
        font.id = fonts.length;
        
        fontFamily = font.name;
        
        var addedFont : EmbeddedFont;
        
        //LOR - Ajout pour les ICidFont
        if (Std.is(font, ICidFont)) 
            isUnicode = true;
        
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
                
                fonts[fonts.length - 1].differences = d;
            }
        }
        return font;
    }
    
    override private function insertFonts() : Void
    {
        var nf : Int = n;
        
        for (diff in Reflect.fields(differences))
        {
            newObj();
            write("<</Type /Encoding /BaseEncoding /WinAnsiEncoding /Differences [" + diff + "]>>");
            write("endobj");
        }
        
        var font : IFont;
        var embeddedFont : EmbeddedFont;
        var fontDescription : FontDescription;
        var type : String;
        var name : String;
        var charactersWidth : Dynamic;
        var s : String;
        var lng : Int = 0;
        
        for (font in fonts)
        {
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
            
            if (type == FontType.TYPE1) 
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
            else if (type == FontType.TRUE_TYPE) 
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
                        this.write("/Encoding " + (as3hx.Compat.parseInt(nf) + as3hx.Compat.parseInt(embeddedFont.differences)) + " 0 R");
                    this.write("/Encoding /WinAnsiEncoding");
                }
                write(">>");
                write("endobj");
                newObj();
                s = "[ ";
                for (i in 0...255){s += (embeddedFont.widths[i]) + " ";
                }
                write(s + "]");
                write("endobj");
                newObj();
                write("<</Type /FontDescriptor");
                write("/FontName /" + name);
                write("/FontWeight " + fontDescription.fontWeight);
                write("/Descent " + fontDescription.descent);
                write("/Ascent " + fontDescription.ascent);
                write("/AvgWidth " + fontDescription.averageWidth);
                write("/Flags " + fontDescription.flags);
                write("/FontBBox [" + fontDescription.boundingBox[0] + " " + fontDescription.boundingBox[1] + " " + fontDescription.boundingBox[2] + " " + fontDescription.boundingBox[3] + "]");
                write("/ItalicAngle " + fontDescription.italicAngle);
                write("/StemV " + fontDescription.stemV);
                write("/MissingWidth " + fontDescription.missingWidth);
                write("/CapHeight " + fontDescription.capHeight);
                write("/FontFile" + (type == ("Type1") ? "" : "2") + " " + (embeddedFont.id - 1) + " 0 R>>");
                write("endobj");
            }
            else if (type == "cidfont0") 
                putcidfont0(try cast(font, ICidFont) catch(e:Dynamic) null)
            else throw new Error("Unsupported font type: " + type);
        }
    }
    
    override private function escapeIt(content : String) : String
    {
        var bytes : ByteArray = new ByteArray();
        bytes.writeUTFBytes(content);
        bytes.position = 0;
        content = this.arrUTF8ToUTF16BE(UTF8StringToArray(content, bytes));
        return super.escapeIt(content);
    }
    
    override private function writeStream(stream : String) : Void
    {
        write("stream");
        
        if (stream.indexOf("\xFE\xFF") > 0) 
        {
            var chunks : Array<Dynamic> = stream.split("\xFE\xFF");
            var chunk : String;
            var j : Int = 0;
            var len : Int = chunks.length;
            
            for (i in 0...len){
                chunk = try cast(chunks[i], String) catch(e:Dynamic) null;
                
                for (j in 0...chunk.length){buffer.writeByte(chunk.charCodeAt(j));
                }
                
                if (i == len - 1 && chunk != "")                     {i++;continue;
                };
                buffer.writeByte(0);
            }
            buffer.writeByte(0x0A);
        }
        else 
        {
            for (i in 0...stream.length){buffer.writeByte(stream.charCodeAt(i));
            }
        }
        buffer.writeByte(0x0A);
        write("endstream");
    }
    
    /*******************************************************************************
		 * Gestion CID Font unicode
		 ******************************************************************************/
    
    private static var _cache_maxsize_UTF8StringToArray : Float = 100;
    private var _cache_UTF8StringToArray : Dynamic = new Dynamic();
    private var _cache_UTF8StringToArrayKeys : Array<Dynamic> = new Array<Dynamic>();
    private var _cache_size_UTF8StringToArray : Float = 0;
    
    /**
		 * Converts UTF-8 strings to codepoints array.<br>
		 * Invalid byte sequences will be replaced with 0xFFFD (replacement character)<br>
		 * Based on: http://www.faqs.org/rfcs/rfc3629.html
		 * <pre>
		 * 	  Char. number range  |        UTF-8 octet sequence
		 *       (hexadecimal)    |              (binary)
		 *    --------------------+-----------------------------------------------
		 *    0000 0000-0000 007F | 0xxxxxxx
		 *    0000 0080-0000 07FF | 110xxxxx 10xxxxxx
		 *    0000 0800-0000 FFFF | 1110xxxx 10xxxxxx 10xxxxxx
		 *    0001 0000-0010 FFFF | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
		 *    ---------------------------------------------------------------------
		 *
		 *   ABFN notation:
		 *   ---------------------------------------------------------------------
		 *   UTF8-octets = *( UTF8-char )
		 *   UTF8-char   = UTF8-1 / UTF8-2 / UTF8-3 / UTF8-4
		 *   UTF8-1      = %x00-7F
		 *   UTF8-2      = %xC2-DF UTF8-tail
		 *
		 *   UTF8-3      = %xE0 %xA0-BF UTF8-tail / %xE1-EC 2( UTF8-tail ) /
		 *                 %xED %x80-9F UTF8-tail / %xEE-EF 2( UTF8-tail )
		 *   UTF8-4      = %xF0 %x90-BF 2( UTF8-tail ) / %xF1-F3 3( UTF8-tail ) /
		 *                 %xF4 %x80-8F 2( UTF8-tail )
		 *   UTF8-tail   = %x80-BF
		 *   ---------------------------------------------------------------------
		 * </pre>
		 * @param string $str string to process.
		 * @return array containing codepoints (UTF-8 characters values)
		 * @access protected
		 * @author Nicola Asuni
		 * @since 1.53.0.TC005 (2005-01-05)
		 */
    private function UTF8StringToArray(str : String, strBytes : ByteArray) : Array<Dynamic>
    {
        var strArr : Array<Dynamic>;
        var strLen : Float;
        
        var unicode : Array<Dynamic>;
        var bytes : Array<Dynamic>;
        var numBytes : Float;
        var length : Float;
        
        var i : Float;
        var char : Int = 0;
        
        /* gestion du cache */
        if (_cache_UTF8StringToArray["_" + str] != null) {
            // return cached value
            return (try cast(_cache_UTF8StringToArray["_" + str], Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null);
        }  // check cache size  
        
        if (_cache_size_UTF8StringToArray >= _cache_maxsize_UTF8StringToArray) {
            // remove first element
            _cache_UTF8StringToArray[_cache_UTF8StringToArrayKeys.shift()] = null;
        }
        _cache_size_UTF8StringToArray++;
        
        if (!_isUnicode) {
            // split string into array of equivalent codes
            strArr = new Array<Dynamic>();
            strLen = str.length;
            for (i in 0...strLen){
                strArr.push(str.charCodeAt(i));
            }  // insert new value on cache  
            
            _cache_UTF8StringToArray["_" + str] = strArr;
            _cache_UTF8StringToArrayKeys.push("_" + str);
            return strArr;
        }
        
        unicode = new Array<Dynamic>();  // array containing unicode values  
        bytes = new Array<Dynamic>();  // array containing single character byte sequences  
        numBytes = 1;  // number of octetc needed to represent the UTF-8 character  
        str += "";  // force $str to be a string  
        //length = str.length;
        while (strBytes.bytesAvailable > 0)
        {
            char = strBytes.readUnsignedByte();
            //for (i = 0; i < length; i++) {
            //char = str.charCodeAt(i); // get one string character at time
            if (bytes.length == 0) {  // get starting octect  
                if (char <= 0x7F) {
                    unicode.push(char);  // use the character "as is" because is ASCII  
                    numBytes = 1;
                }
                else if ((char >> 0x05) == 0x06) {  // 2 bytes character (0x06 = 110 BIN)  
                    bytes.push((char - 0xC0) << 0x06);
                    numBytes = 2;
                }
                else if ((char >> 0x04) == 0x0E) {  // 3 bytes character (0x0E = 1110 BIN)  
                    bytes.push((char - 0xE0) << 0x0C);
                    numBytes = 3;
                }
                else if ((char >> 0x03) == 0x1E) {  // 4 bytes character (0x1E = 11110 BIN)  
                    bytes.push((char - 0xF0) << 0x12);
                    numBytes = 4;
                }
                else {
                    // use replacement character for other invalid sequences
                    unicode.push(0xFFFD);
                    bytes = new Array<Dynamic>();
                    numBytes = 1;
                }
            }
            else if ((char >> 0x06) == 0x02) {  // bytes 2, 3 and 4 must start with 0x02 = 10 BIN  
                bytes.push(char - 0x80);
                if (bytes.length == numBytes) {
                    // compose UTF-8 bytes to a single unicode value
                    bytes.position = 0;
                    char = bytes[0];  //readUnsignedByte();  
                    for (j in 1...numBytes){
                        char += (bytes[j] << ((numBytes - j - 1) * 0x06));
                    }
                    
                    if (((char >= 0xD800) && (char <= 0xDFFF)) || (char >= 0x10FFFF)) {
                        /* The definition of UTF-8 prohibits encoding character numbers between
							U+D800 and U+DFFF, which are reserved for use with the UTF-16
							encoding form (as surrogate pairs) and do not directly represent
							characters. */
                        unicode.push(0xFFFD);
                    }
                    else {
                        unicode.push(char);
                    }  // reset data for next char  
                    
                    bytes = new Array<Dynamic>();
                    numBytes = 1;
                }
            }
            else {
                // use replacement character for other invalid sequences
                unicode.push(0xFFFD);
                bytes = new Array<Dynamic>();
                numBytes = 1;
            }
        }  // insert new value on cache  
        
        _cache_UTF8StringToArray["_" + str] = unicode;
        _cache_UTF8StringToArrayKeys.push("_" + str);
        return unicode;
    }
    
    /**
		 * Converts array of UTF-8 characters to UTF16-BE string.<br>
		 * Based on: http://www.faqs.org/rfcs/rfc2781.html
		 * <pre>
		 *   Encoding UTF-16:
		 * 
		 *   Encoding of a single character from an ISO 10646 character value to
		 *    UTF-16 proceeds as follows. Let U be the character number, no greater
		 *    than 0x10FFFF.
		 * 
		 *    1) If U is less than 0x10000, encode U as a 16-bit unsigned integer and
		 *       terminate.
		 * 
		 *    2) Let U' = U - 0x10000. Because U is less than or equal to 0x10FFFF,
		 *       U' must be less than or equal to 0xFFFFF. That is, U' can be
		 *       represented in 20 bits.
		 * 
		 *    3) Initialize two 16-bit unsigned integers, W1 and W2, to 0xD800 and
		 *       0xDC00, respectively. These integers each have 10 bits free to
		 *       encode the character value, for a total of 20 bits.
		 * 
		 *    4) Assign the 10 high-order bits of the 20-bit U' to the 10 low-order
		 *       bits of W1 and the 10 low-order bits of U' to the 10 low-order
		 *       bits of W2. Terminate.
		 * 
		 *    Graphically, steps 2 through 4 look like:
		 *    U' = yyyyyyyyyyxxxxxxxxxx
		 *    W1 = 110110yyyyyyyyyy
		 *    W2 = 110111xxxxxxxxxx
		 * </pre>
		 * @param array $unicode array containing UTF-8 unicode values
		 * @param boolean $setbom if true set the Byte Order Mark (BOM = 0xFEFF)
		 * @return string
		 * @access protected
		 * @author Nicola Asuni
		 * @since 2.1.000 (2008-01-08)
		 * @see UTF8ToUTF16BE()
		 */
    private function arrUTF8ToUTF16BE(unicode : Array<Dynamic>, setbom : Bool = false) : String
    {
        var outStr : String = "";  // string to be returned  
        var w1 : Float;
        var w2 : Float;
        
        var bytes : Array<Dynamic> = new Array<Dynamic>();
        
        if (setbom) 
            outStr += "\xFE\xFF"  // Byte Order Mark (BOM)  ;
        
        var char : Int = 0;
        
        for (i in 0...unicode.length){
            char = unicode[i];
            if (char == 0xFFFD) {
                outStr += "\xFF\xFD";
            }
            else if (char < 0x10000) {
                bytes.push(char >> 0x08);
                bytes.push(char & 0xFF);
                outStr += fromCharCode(char >> 0x08);
                outStr += fromCharCode(char & 0xFF);
            }
            else {
                char -= 0x10000;
                w1 = 0xD800 | (char >> 0x10);
                w2 = 0xDC00 | (char & 0x3FF);
                outStr += fromCharCode(w1 >> 0x08);
                outStr += fromCharCode(w1 & 0xFF);
                outStr += fromCharCode(w2 >> 0x08);
                outStr += fromCharCode(w2 & 0xFF);
            }
        }
        
        return outStr;
    }
    
    /**
		 * 
		 * @param code
		 * @return 
		 * 
		 */
    private function fromCharCode(code : Int) : String
    {
        if (code == 0)             return "\xFE\xFF"  //return double byte order mark, later to be replaced with 0  ;
        return String.fromCharCode(code);
    }
    
    /**
		 * Output CID-0 fonts.
		 * @param array $font font data
		 * @access protected
		 * @author Andrew Whitehead, Nicola Asuni, Yukihiro Nakadaira
		 * @since 3.2.000 (2008-06-23)
		 */
    private function putcidfont0(cdiFont : ICidFont) : Void
    {
        var cidoffset : Int = 31;
        var cw : Dynamic;
        var width : String;
        var cidCode : String;
        
        if (cdiFont.uni2cid != null) {
            // convert unicode to cid.
            cw = new Dynamic();
            for (uni in cdiFont.charactersWidth.keys()){
                width = cdiFont.charactersWidth.get(uni);
                if (cdiFont.uni2cid[uni] != null) {
                    cw[as3hx.Compat.parseInt(cdiFont.uni2cid[uni]) + cidoffset] = width;
                }
                // else unknown character
                else if (as3hx.Compat.parseInt(uni) < 256) {
                    Reflect.setField(cw, uni, width);
                }
            }
            cdiFont.replaceCharactersWidth(cw);
        }
        
        var longName : String;
        if (cdiFont.enc != "") {
            longName = cdiFont.name + "-" + cdiFont.enc;
        }
        else {
            longName = cdiFont.name;
        }
        this.newObj();
        this.write("<</Type /Font");
        this.write("/BaseFont /" + longName);
        this.write("/Subtype /Type0");
        if (cdiFont.enc != "") {
            this.write("/Encoding /" + cdiFont.enc);
        }
        this.write("/DescendantFonts [" + (n + 1) + " 0 R]");
        this.write(">>");
        this.write("endobj");
        
        this.newObj();
        this.write("<</Type /Font");
        this.write("/BaseFont /" + cdiFont.name);
        this.write("/Subtype /CIDFontType0");
        
        var cidInfo : String;
        cidInfo = "/Registry (" + cdiFont.cidinfo.Registry + ")";
        cidInfo += " /Ordering (" + cdiFont.cidinfo.Ordering + ")";
        cidInfo += " /Supplement (" + cdiFont.cidinfo.Supplement + ")";
        this.write("/CIDSystemInfo <<" + cidInfo + ">>");
        this.write("/FontDescriptor " + (n + 1) + " 0 R");
        this.write("/DW " + cdiFont.dw);
        
        _putfontwidths(cdiFont, cidoffset);
        
        this.write(">>");
        this.write("endobj");
        
        this.newObj();
        var s : String;
        s = "<</Type /FontDescriptor /FontName /" + cdiFont.name;
        for (o in Reflect.fields(cdiFont.desc)){
            if (o != "Style") {
                s += " /" + o + " " + cdiFont.desc[o];
            }
        }
        this.write(s + ">>");
        this.write("endobj");
    }
    
    /**
		 * Outputs font widths
		 * @parameter array $font font data
		 * @parameter int $cidoffset offset for CID values
		 * @author Nicola Asuni
		 * @access protected
		 * @since 4.4.000 (2008-12-07)
		 */
    private function _putfontwidths(cidFont : ICidFont, cidoffset : Int = 0) : Void
    {
        var arr : Array<Dynamic> = new Array<Dynamic>();
        var cidArr : Array<Dynamic> = new Array<Dynamic>();
        for (tmpCid in Reflect.fields(cidFont.charactersWidth))
        arr.push({
                    cid : tmpCid,
                    width : cidFont.charactersWidth[tmpCid],

                });
        cidArr = arr.sortOn("cid", Array.NUMERIC);
        arr = null;
        
        var prevCid : Int = -2;
        var prevWidth : Int = -1;
        var range : Dynamic = new Dynamic();
        var rangeId : Int = 0;
        var interval : Bool = false;
        
        for (o in cidArr){
            var cid : Int = as3hx.Compat.parseInt(o.cid);
            var width : Int = as3hx.Compat.parseInt(o.width);
            cid -= cidoffset;
            
            if (width != cidFont.dw) {
                if (cid == (prevCid + 1)) {  //Consecutive CID  
                    if (width == prevWidth) {
                        if (range[rangeId] != null && width == (try cast(range[rangeId], Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null)[0]) {
                            (try cast(range[rangeId], Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null).push(width);
                        }
                        else {
                            if (range[rangeId] != null) {
                                (try cast(range[rangeId], Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null).pop();
                            }  // new range  
                            
                            rangeId = prevCid;
                            range[rangeId] = new Array<Dynamic>();
                            (try cast(range[rangeId], Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null).push(prevWidth);
                            (try cast(range[rangeId], Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null).push(width);
                        }
                        interval = true;
                        (try cast(range[rangeId], Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null)["interval"] = true;
                    }
                    else {
                        if (interval) {
                            // New range
                            rangeId = cid;
                            range[rangeId] = new Array<Dynamic>();
                            (try cast(range[rangeId], Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null).push(width);
                        }
                        else {
                            (try cast(range[rangeId], Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null).push(width);
                        }
                        interval = false;
                    }
                }
                else {
                    // new range
                    rangeId = cid;
                    range[rangeId] = new Array<Dynamic>();
                    (try cast(range[rangeId], Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null).push(width);
                    interval = false;
                }
                prevCid = cid;
                prevWidth = width;
            }
        }  /* on ressort les range ID pour les trier */  
        
        
        
        var rangeIdArr : Array<Dynamic> = new Array<Dynamic>();
        var tmpK : String = "";
        for (tmpK in Reflect.fields(range))
        rangeIdArr.push(tmpK);
        rangeIdArr.sort(Array.NUMERIC);
        
        var prevK : Int = -1;
        var nextK : Int = -1;
        var prevInt : Bool = false;
        var cws : Int = 0;
        var k : Int = -1;
        var ws : Array<Dynamic>;
        for (tmpK in rangeIdArr)
        {
            k = as3hx.Compat.parseInt(tmpK);
            ws = (try cast(Reflect.field(range, Std.string(tmpK)), Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null).concat();
            cws = ws.length;
            if ((try cast(Reflect.field(range, Std.string(tmpK)), Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null)["interval"] != null) 
            {
                ws["interval"] = true;
                cws++;
            }
            if ((k == nextK) && !prevInt && (ws["interval"] == null || cws < 4)) 
            {
                if ((try cast(range[k], Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null)["interval"] != null) {
                    (try cast(range[k], Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null)["interval"] = null;
                }
                if (range[prevK] != null) 
                    range[prevK] = (try cast(range[prevK], Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null).concat(try cast(range[k], Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null)
                else 
                range[prevK] = range[k];
                range[k] = null;
            }
            else {
                prevK = k;
            }
            nextK = k + cws;
            if (ws["interval"] != null) {
                if (cws > 3) {
                    prevInt = true;
                }
                else {
                    prevInt = false;
                }
                if (range[k] != null) 
                    (try cast(range[k], Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null)["interval"] = null--;nextK;
            }
            else {
                prevInt = false;
            }
        }  /* on ressort les range ID pour les trier */  
        
        
        
        rangeIdArr = new Array<Dynamic>();
        for (tmpK in Reflect.fields(range))
        rangeIdArr.push(tmpK);
        rangeIdArr.sort(Array.NUMERIC);
        
        //output data
        var w : String = "";
        for (tmpK in rangeIdArr)
        {
            k = as3hx.Compat.parseInt(tmpK);
            ws = range[k];
            if (ws != null) 
            {
                if (countUniqueValues(ws) == 1) {
                    //interval mode is more compact
                    w += " " + tmpK + " " + (k + ws.length - 1) + " " + ws[0];
                }
                else {
                    w += " " + tmpK + " [" + implode(ws) + "]";
                }
            }
        }
        this.write("/W [" + w + " ]");
    }
    
    private function implode(arr : Array<Dynamic>, sep : String = " ") : String
    {
        var ret : String = sep;
        for (i in 0...arr.length){
            if (arr[i] != null) 
                ret += arr[i] + sep;
        }
        return ret;
    }
    
    private function countUniqueValues(arr : Array<Dynamic>) : Float
    {
        var countArr : Array<Dynamic> = new Array<Dynamic>();
        for (i in 0...arr.length){
            if (arr[i] != null && Lambda.indexOf(countArr, arr[i]) == -1) 
                countArr.push(arr[i]);
        }
        return countArr.length;
    }
}
