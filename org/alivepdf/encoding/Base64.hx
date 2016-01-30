package org.alivepdf.encoding;



/*
	*	A Base64 encoder/decoder implementation in Actionscript 3
	*   from subhero@gmail.com
	*/

import haxe.ds.StringMap;
import flash.utils.ByteArray;


class Base64
{
    
    private static var lineBreak : Bool;
    
    private static var _b64Chars : Array<String> = [
        
        "A", "B", "C", "D", "E", "F", "G", "H", 
        "I", "J", "K", "L", "M", "N", "O", "P", 
        "Q", "R", "S", "T", "U", "V", "W", "X", 
        "Y", "Z", "a", "b", "c", "d", "e", "f", 
        "g", "h", "i", "j", "k", "l", "m", "n", 
        "o", "p", "q", "r", "s", "t", "u", "v", 
        "w", "x", "y", "z", "0", "1", "2", "3", 
        "4", "5", "6", "7", "8", "9", "+", "/"]  /*
		takes a byteArray as input and return the base64 string
		*/  ;
    
    
    
    
    private static var lookupObject : StringMap<Int> = buildLookUpObject();
    
    private static function buildLookUpObject() : StringMap<Int>
    {
        var obj : StringMap<Int> = new StringMap<Int>();
        
        for (i in 0..._b64Chars.length){
            obj.set(Std.string(_b64Chars[i]), i);
        }
        
        return obj;
    }
    
    public static function encode64String(pString : String) : String
    {
        var bBytes : ByteArray = new ByteArray();
        
        bBytes.writeUTFBytes(pString);
        
        return _encodeBytes(bBytes);
    }
    
    public static function encode64(pByteArray : ByteArray, pLineBreak : Bool = true) : String
    {
        lineBreak = pLineBreak;
        
        return _encodeBytes(pByteArray);
    }
    
    private static function _encodeBytes(pByteArray : ByteArray) : String
    {
        var output : String = "";
        var bufferSize : Int = 0;
        pByteArray.position = 0;
        var col : Int = 0;

        bufferSize = pByteArray.bytesAvailable;
        while (bufferSize > 0){
            
            bufferSize = Std.int(Math.min(3, bufferSize));
            
            var bytePacket : ByteArray = new ByteArray();
            
            pByteArray.readBytes(bytePacket, 0, bufferSize);
            
            output += _encodeBytePacket(bytePacket);
            
            col += 4;
            
            if (lineBreak && (col % 76) == 0) 
            {
                output += "\n";
                col = 0;
            }
            bufferSize = pByteArray.bytesAvailable;
        }
        return output;
    }
    
    private static function _encodeBytePacket(pByteArrayPacket : ByteArray) : String
    {
        var encodedString : String = "";
        var packetLength : Int = pByteArrayPacket.length;
        
        encodedString += _b64Chars[pByteArrayPacket[0] >> 2];
        
        if (packetLength == 1) {
            
            encodedString += (_b64Chars[((pByteArrayPacket[0] << 4) & 0x3F)]);
            encodedString += ("==");
        }
        else if (packetLength == 2) {
            
            encodedString += (_b64Chars[(pByteArrayPacket[0] << 4) & 0x3F | pByteArrayPacket[1] >> 4]);
            encodedString += (_b64Chars[(pByteArrayPacket[1] << 2) & 0x3F]);
            encodedString += ("=");
        }
        else 
        {
            encodedString += (_b64Chars[(pByteArrayPacket[0] << 4) & 0x3F | pByteArrayPacket[1] >> 4]);
            encodedString += (_b64Chars[(pByteArrayPacket[1] << 2) & 0x3F | pByteArrayPacket[2] >> 6]);
            encodedString += (_b64Chars[pByteArrayPacket[2] & 0x3F]);
        }
        return encodedString;
    }
    
    public static function decode64(pString : String) : ByteArray
    {
        return _decodeString(pString);
    }
    
    private static function _decodeString(pString : String) : ByteArray
    {
        var sourceString : String = pString;
        var base64Bytes : ByteArray = new ByteArray();
        var stringPacket : String = "";
        var lng : Int = sourceString.length;
        
        for (i in 0...lng){
            stringPacket += sourceString.charAt(i);
            
            if (stringPacket.length == 4) 
            {
                base64Bytes.writeBytes(_decodeStringPacket(stringPacket));
                
                stringPacket = "";
            }
        }
        return base64Bytes;
    }
    
    private static function _decodeStringPacket(stringBuffer : String) : ByteArray
    {
        var byteStringPacket : ByteArray = new ByteArray();
        
        var charValue1 : Int = Base64.lookupObject.get(stringBuffer.charAt(0));
        var charValue2 : Int = Base64.lookupObject.get(stringBuffer.charAt(1));
        var charValue3 : Int = Base64.lookupObject.get(stringBuffer.charAt(2));
        var charValue4 : Int = Base64.lookupObject.get(stringBuffer.charAt(3));
        
        byteStringPacket.writeByte(charValue1 << 2 | charValue2 >> 4);
        if (stringBuffer.charAt(2) != "=")             byteStringPacket.writeByte(charValue2 << 4 | charValue3 >> 2);
        if (stringBuffer.charAt(3) != "=")             byteStringPacket.writeByte(charValue3 << 6 | charValue4);
        
        return byteStringPacket;
    }

    public function new()
    {
    }
}
