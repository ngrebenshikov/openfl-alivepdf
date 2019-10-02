/*  Sprintf.sprintf(3) implementation in ActionScript 3.0.
 *
 *  Author:  Manish Jethani (manish.jethani@gmail.com)
 *  Date:    April 3, 2006
 *  Version: 0.1
 *
 *  Copyright (c) 2006 Manish Jethani
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a
 *  copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *  DEALINGS IN THE SOFTWARE.  
 */

package org.alivepdf.tools;


class Sprintf
{
    
    /*  Sprintf.sprintf(3) implementation in ActionScript 3.0.
 *
 *  http://www.die.net/doc/linux/man/man3/sprintf.3.html
 *
 *  The following flags are supported: '#', '0', '-', '+'
 *
 *  Field widths are fully supported.  '*' is not supported.
 *
 *  Precision is supported except one difference from the standard: for an
 *  explicit precision of 0 and a result string of "0", the output is "0"
 *  instead of an empty string.
 *
 *  Length modifiers are not supported.
 *
 *  The following conversion specifiers are supported: 'd', 'i', 'o', 'u', 'x',
 *  'X', 'f', 'F', 'c', 's', '%'
 *
 *  Report bugs to manish.jethani@gmail.com
 */
    public static function sprintf(format : String, args: Array<Dynamic>) : String
    {
        var result : String = "";
        
        var length : Int = format.length;
        var next : Dynamic;
        var str : String;
        var i = 0;
        while (i < length){
            var c : String = format.charAt(i);
            
            if (c == "%") 
            {
                var pastFieldWidth : Bool = false;
                var pastFlags : Bool = false;
                
                var flagAlternateForm : Bool = false;
                var flagZeroPad : Bool = false;
                var flagLeftJustify : Bool = false;
                var flagSpace : Bool = false;
                var flagSign : Bool = false;
                
                var fieldWidth : String = "";
                var precision : String = "";
                
                c = format.charAt(++i);
                
                while (c != "d" && c != "i" && c != "o" && c != "u" && c != "x" && c != "X" && c != "f" && c != "F" && c != "c" && c != "s" && c != "%")
                {
                    if (!pastFlags) 
                    {
                        if (!flagAlternateForm && c == "#") 
                            flagAlternateForm = true
                        else if (!flagZeroPad && c == "0") 
                            flagZeroPad = true
                        else if (!flagLeftJustify && c == "-") 
                            flagLeftJustify = true
                        else if (!flagSpace && c == " ") 
                            flagSpace = true
                        else if (!flagSign && c == "+") 
                            flagSign = true
                        else 
                        pastFlags = true;
                    }
                    
                    if (!pastFieldWidth && c == ".") 
                    {
                        pastFlags = true;
                        pastFieldWidth = true;
                        
                        c = format.charAt(++i);
                        continue;
                    }
                    
                    if (pastFlags) 
                    {
                        if (!pastFieldWidth) 
                            fieldWidth += c
                        else 
                        precision += c;
                    }
                    
                    c = format.charAt(++i);
                }
                
                switch (c)
                {
                    case "d", "i":
                        next = args.shift();
                        str = Std.string(Math.abs(as3hx.Compat.parseInt(next)));
                        
                        if (precision != "") 
                            str = leftPad(str, as3hx.Compat.parseInt(precision), "0");
                        
                        if (as3hx.Compat.parseInt(next) < 0) 
                            str = "-" + str
                        else if (flagSign && as3hx.Compat.parseInt(next) >= 0) 
                            str = "+" + str;
                        
                        if (fieldWidth != "") 
                        {
                            if (flagLeftJustify) 
                                str = rightPad(str, as3hx.Compat.parseInt(fieldWidth))
                            else if (flagZeroPad && precision == "") 
                                str = leftPad(str, as3hx.Compat.parseInt(fieldWidth), "0")
                            else 
                            str = leftPad(str, as3hx.Compat.parseInt(fieldWidth));
                        }
                        
                        result += str;
                    
                    case "o":
                        next = args.shift();
                        str = Std.string(Std.int(next));
                        
                        if (flagAlternateForm && str != "0") 
                            str = "0" + str;
                        
                        if (precision != "") 
                            str = leftPad(str, as3hx.Compat.parseInt(precision), "0");
                        
                        if (fieldWidth != "") 
                        {
                            if (flagLeftJustify) 
                                str = rightPad(str, as3hx.Compat.parseInt(fieldWidth))
                            else if (flagZeroPad && precision == "") 
                                str = leftPad(str, as3hx.Compat.parseInt(fieldWidth), "0")
                            else 
                            str = leftPad(str, as3hx.Compat.parseInt(fieldWidth));
                        }
                        
                        result += str;
                    
                    case "u":
                        next = args.shift();
                        str = Std.string(Std.int(next));
                        
                        if (precision != "") 
                            str = leftPad(str, as3hx.Compat.parseInt(precision), "0");
                        
                        if (fieldWidth != "") 
                        {
                            if (flagLeftJustify) 
                                str = rightPad(str, as3hx.Compat.parseInt(fieldWidth))
                            else if (flagZeroPad && precision == "") 
                                str = leftPad(str, as3hx.Compat.parseInt(fieldWidth), "0")
                            else 
                            str = leftPad(str, as3hx.Compat.parseInt(fieldWidth));
                        }
                        
                        result += str;
                    case "X", "x":

                        var capitalise : Bool = false;

                        switch (c)
                        {
                            case "X":
                                capitalise = true;
                        }

                        next = args.shift();
                        str = Std.string(Std.int(next));
                        
                        if (precision != "") 
                            str = leftPad(str, as3hx.Compat.parseInt(precision), "0");
                        
                        var prepend : Bool = flagAlternateForm && Std.int(next) != 0;
                        
                        if (fieldWidth != "" && !flagLeftJustify && flagZeroPad && precision == "") 
                            str = leftPad(str, (prepend) ? as3hx.Compat.parseInt(fieldWidth) - 2 : as3hx.Compat.parseInt(fieldWidth), "0");
                        
                        if (prepend) 
                            str = "0x" + str;
                        
                        if (fieldWidth != "") 
                        {
                            if (flagLeftJustify) 
                                str = rightPad(str, as3hx.Compat.parseInt(fieldWidth))
                            else 
                            str = leftPad(str, as3hx.Compat.parseInt(fieldWidth));
                        }
                        
                        if (capitalise) 
                            str = str.toUpperCase();
                        
                        result += str;
                    case "f", "F":
                        next = args.shift();
                        str = formatFloat(Math.abs(as3hx.Compat.parseFloat(next)), precision != ("") ? Std.parseInt(precision) : 6);
                        
                        if (next < 0)
                            str = "-" + str
                        else if (flagSign && next >= 0)
                            str = "+" + str;
                        
                        if (flagAlternateForm && str.indexOf(".") == -1) 
                            str += ".";
                        
                        if (fieldWidth != "") 
                        {
                            if (flagLeftJustify) 
                                str = rightPad(str, as3hx.Compat.parseInt(fieldWidth))
                            else if (flagZeroPad && precision == "") 
                                str = leftPad(str, as3hx.Compat.parseInt(fieldWidth), "0")
                            else 
                            str = leftPad(str, as3hx.Compat.parseInt(fieldWidth));
                        }
                        
                        result += str;
                    
                    case "c":
                        next = args.shift();
                        str = String.fromCharCode(as3hx.Compat.parseInt(next));
                        
                        if (fieldWidth != "") 
                        {
                            if (flagLeftJustify) 
                                str = rightPad(str, as3hx.Compat.parseInt(fieldWidth))
                            else 
                            str = leftPad(str, as3hx.Compat.parseInt(fieldWidth));
                        }
                        
                        result += str;
                    
                    case "s":
                        next = args.shift();
                        str = Std.string(next);
                        
                        if (precision != "") 
                            str = str.substring(0, as3hx.Compat.parseInt(precision));
                        
                        if (fieldWidth != "") 
                        {
                            if (flagLeftJustify) 
                                str = rightPad(str, as3hx.Compat.parseInt(fieldWidth))
                            else 
                            str = leftPad(str, as3hx.Compat.parseInt(fieldWidth));
                        }
                        
                        result += str;
                    
                    case "%":
                        result += "%";
                }
            }
            else 
            {
                result += c;
            }
            i += 1;
        }
        
        return result;
    }

    // Private functions

    public static function formatFloat(f: Float, precision: Int): String {
        var factor: Float = Math.pow(10, precision);
        return Std.string(Math.fround(f * factor)/factor);
    }

    private static function leftPad(source : String, targetLength : Int, padChar : String = " ") : String
    {
        if (source.length < targetLength) 
        {
            var padding : String = "";
            
            while (padding.length + source.length < targetLength)
            padding += padChar;
            
            return padding + source;
        }
        
        return source;
    }

    private static function rightPad(source : String, targetLength : Int, padChar : String = " ") : String
    {
        while (source.length < targetLength)
        source += padChar;
        
        return source;
    }

}

