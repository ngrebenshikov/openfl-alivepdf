package as3hx;

import Type;

/**
 * Collection of functions that just have no real way to be compatible in Haxe 
 **/
class Compat {

    /* According to Adobe:
     * The result is limited to six possible string values: 
     *      boolean, function, number, object, string, and xml.
     * If you apply this operator to an instance of a user-defined class,
     * the result is the string object.
     *
     * TODO: TUnknown returns "undefined" on top of this. Not positive on this
     */

    public static function typeof(v:Dynamic) : String {
        return
        switch(Type.typeof(v)) {
        case TUnknown: "undefined";
        case TObject: "object";
        case TNull: "object";
        case TInt: "number";
        case TFunction: "function";
        case TFloat: "number";
        case TEnum(e): "object";
        case TClass(c):
            switch(Type.getClassName(c)) {
            case "String": "string";
            case "Xml": "xml";
            case "haxe.xml.Fast": "xml";
            default: "object";
            }
        case TBool: "boolean";
        };
    }

    public static function parseFloat(e:Dynamic) : Float { return if (Type.getClassName(Type.getClass(e)) == "String") Std.parseFloat(e) else cast e; }
    public static function parseInt(e:Dynamic) : Int { return if (Type.getClassName(Type.getClass(e)) == "String") Std.parseInt(e) else cast e; }
}
